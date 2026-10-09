#pragma author Imad Chalouan
#pragma description FAT12 / FAT16 File System
#pragma magic [ 46 41 54 31 32 20 20 20 ] @ 0x36
#pragma magic [ 46 41 54 31 36 20 20 20 ] @ 0x36
#pragma endian little

// References:
//  - Microsoft Extensible Firmware Initiative FAT32 File System Specification v1.03 (fatgen103)
//  - https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system
//
// Parses the boot sector, every FAT, the fixed root directory and then follows each
// subdirectory and file through its cluster chain, including fragmented chains.
// VFAT long file name entries are shown in front of the short entry they belong to.
// The FAT type is chosen from the cluster count as the specification requires, not
// from the informational "FAT12   " / "FAT16   " string. FAT32 volumes are rejected,
// use fs/fat32.hexpat for those.

import std.io;
import std.math;
import std.mem;
import std.string;
import type.time;

// Subdirectories nest, their depth is bounded by MaxDirectoryDepth below
#pragma eval_depth 0

// Volume geometry, set once the boot sector has been parsed
u32 bytesPerSector;
u32 bytesPerCluster;
u64 fatAddress;
u64 fatBytes;
u64 dataAddress;
u32 clusterCount;
u8  fatBits;

// Guards for corrupted images: directories already open further up the tree are not
// entered again, nesting depth and the total number of directories followed are capped
str openDirectories = "";
u32 directoriesFollowed = 0;
u32 directoryDepth = 0;
const u32 MaxDirectories = 10000;
const u32 MaxDirectoryDepth = 64;

// Cluster chains are walked iteratively: each run of physically consecutive clusters is one
// element of an array, these hold the state of the chain currently being walked. A chain is
// never followed for more clusters than the volume has, so cycles in the FAT terminate.
u32 chainCluster = 0;
u32 chainVisited = 0;
u64 chainRemaining = 0;

enum MediaType : u8 {
    Fixed          = 0xF8,
    Floppy_1_44MB  = 0xF0,
    Floppy_720K    = 0xF9,
    Floppy_320K    = 0xFA,
    Floppy_640K    = 0xFB,
    Floppy_180K    = 0xFC,
    Floppy_360K    = 0xFD,
    Floppy_160K    = 0xFE,
    Floppy_320K_DS = 0xFF
};

struct BIOSParameterBlock {
    u16 bytesPerSector;
    u8  sectorsPerCluster;
    u16 reservedSectorCount;
    u8  numFats;
    u16 rootEntryCount;
    u16 totalSectors16;
    MediaType media;
    u16 fatSize16;
    u16 sectorsPerTrack;
    u16 numHeads;
    u32 hiddenSectors;
    u32 totalSectors32;
};

// Extended BPB, fields after bootSignature are only valid if it is 0x29 (or 0x28 for DOS 4.0)
struct ExtendedBIOSParameterBlock {
    u8  driveNumber;
    u8  reserved;
    u8  bootSignature;
    if (bootSignature == 0x29 || bootSignature == 0x28) {
        u32 volumeID;
        if (bootSignature == 0x29) {
            char volumeLabel[11];
            char fileSystemType[8];
        }
    }
};

struct BootSector {
    u8   jumpBoot[3];
    char oemName[8];
    BIOSParameterBlock bpb;
    ExtendedBIOSParameterBlock ebpb;
    u8   bootCode[0x1FE - ($ - addressof(this))];
    u16  signature;
};

// ---- File Allocation Table ----

// Entries 0 and 1 are reserved: entry 0 holds the media type, entry 1 the end-of-chain marker
fn fat_entry_format(u16 value) {
    u16 eoc = fatBits == 12 ? 0xFF8 : 0xFFF8;
    u16 bad = fatBits == 12 ? 0xFF7 : 0xFFF7;

    if (value == 0x0000)
        return "Free";
    else if (value == 0x0001)
        return "Reserved (0x1)";
    else if (value == bad)
        return "Bad cluster";
    else if (value >= eoc)
        return std::format("End of chain (0x{:X})", value);
    else if (value >= clusterCount + 2)
        return std::format("Reserved (0x{:X})", value);
    else
        return std::format("-> {}", value);
};

using FAT16Entry = u16 [[format("fat_entry_format")]];

// FAT12 packs two 12 bit entries into three bytes
bitfield FAT12EntryPair {
    even : 12 [[format("fat_entry_format")]];
    odd  : 12 [[format("fat_entry_format")]];
};

struct FileAllocationTable {
    // A FAT always occupies fatSize16 whole sectors, less if the image is cut off
    u64 available = std::math::min(fatBytes, std::mem::size() - addressof(this));
    if (fatBits == 12)
        FAT12EntryPair entries[std::math::min((clusterCount + 2 + 1) / 2, available / 3)];
    else
        FAT16Entry entries[std::math::min(clusterCount + 2, available / 2)];

    padding[available - ($ - addressof(this))];
};

// Reads the FAT entry of a cluster from the first FAT; past the end of a cut off image the
// chain is treated as ended
fn fat_next(u32 cluster) {
    if (fatAddress + cluster * 2 + 2 > std::mem::size())
        return fatBits == 12 ? 0xFFF : 0xFFFF;
    if (fatBits == 12) {
        u16 pair = std::mem::read_unsigned(fatAddress + cluster + cluster / 2, 2, std::mem::Endian::Little);
        if (cluster & 1)
            return pair >> 4;
        else
            return pair & 0xFFF;
    }

    return std::mem::read_unsigned(fatAddress + cluster * 2, 2, std::mem::Endian::Little);
};

fn is_valid_cluster(u32 cluster) {
    return cluster >= 2 && cluster < clusterCount + 2;
};

fn cluster_address(u32 cluster) {
    return dataAddress + u64(cluster - 2) * bytesPerCluster;
};

// Number of physically consecutive clusters of a chain, starting at `cluster`
fn run_length(u32 cluster) {
    u32 length = 1;
    u32 current = cluster;
    while (length < clusterCount) {
        u32 next = fat_next(current);
        if (next != current + 1 || !is_valid_cluster(next))
            break;
        current = next;
        length += 1;
    }
    return length;
};

fn run_next(u32 cluster, u32 length) {
    return fat_next(cluster + length - 1);
};

// ---- Directory entries ----

bitfield Attributes {
    readOnly     : 1;
    hidden       : 1;
    system       : 1;
    volumeLabel  : 1;
    subdirectory : 1;
    archive      : 1;
    padding      : 2;
};

bitfield LFNOrdinal {
    number      : 5;
    padding     : 1;
    lastLogical : 1;
    padding     : 1;
};

struct LongNameEntry {
    LFNOrdinal ordinal;
    char16 name1[5];
    Attributes attributes;
    u8  type;
    u8  checksum;
    char16 name2[6];
    u16 firstCluster;
    char16 name3[2];
} [[format("format_lfn")]];

// LFN fragments end with 0x0000 and are padded with 0xFFFF
fn lfn_char(ref LongNameEntry entry, u8 index) {
    if (index < 5)
        return entry.name1[index];
    else if (index < 11)
        return entry.name2[index - 5];
    else
        return entry.name3[index - 11];
};

fn format_lfn(ref LongNameEntry entry) {
    str name = "";
    for (u8 i = 0, i < 13, i += 1) {
        char16 c = lfn_char(entry, i);
        if (u16(c) == 0x0000 || u16(c) == 0xFFFF)
            break;
        name += std::format("{}", c);
    }

    return std::format("LFN part {}{}: \"{}\"", entry.ordinal.number, entry.ordinal.lastLogical ? " (last)" : "", name);
};

// Windows NT stores all-lowercase 8.3 names without an LFN entry by setting these bits
bitfield CaseFlags {
    padding        : 3;
    lowerBase      : 1;
    lowerExtension : 1;
    padding        : 3;
};

using Directory<auto Cluster>;
using FileData<auto Cluster, auto Size>;

struct ShortNameEntry {
    char name[8];
    char extension[3];
    Attributes attributes;
    CaseFlags caseFlags;
    u8  creationTimeTenths;
    type::DOSTime creationTime;
    type::DOSDate creationDate;
    type::DOSDate lastAccessDate;
    u16 firstClusterHigh;
    type::DOSTime writeTime;
    type::DOSDate writeDate;
    u16 firstCluster;
    u32 fileSize;

    bool deleted = u8(name[0]) == 0xE5;
    bool dotEntry = name[0] == '.';

    bool inImage = is_valid_cluster(firstCluster) && cluster_address(firstCluster) < std::mem::size();
    if (!deleted && !dotEntry && !attributes.volumeLabel && is_valid_cluster(firstCluster) && !inImage)
        std::warning(std::format("Cluster {} lies beyond the end of the image", firstCluster));

    if (!deleted && !dotEntry && !attributes.volumeLabel && inImage) {
        if (attributes.subdirectory) {
            str key = std::format("|{}|", firstCluster);
            if (std::string::contains(openDirectories, key)) {
                std::warning(std::format("Directory at cluster {} loops back to a parent directory, not following it", firstCluster));
            } else if (directoriesFollowed >= MaxDirectories) {
                std::warning(std::format("More than {} directories, not following cluster {}", MaxDirectories, firstCluster));
            } else if (directoryDepth >= MaxDirectoryDepth) {
                std::warning(std::format("Directories nested deeper than {} levels, not following cluster {}", MaxDirectoryDepth, firstCluster));
            } else {
                u32 openLength = std::string::length(openDirectories);
                openDirectories += key;
                directoriesFollowed += 1;
                directoryDepth += 1;
                Directory<firstCluster> contents @ cluster_address(firstCluster);
                directoryDepth -= 1;
                openDirectories = std::string::substr(openDirectories, 0, openLength);
            }
        } else if (fileSize > 0) {
            FileData<firstCluster, fileSize> data @ cluster_address(firstCluster);
        }
    }
} [[format("format_short_name")]];

// 8.3 names are padded with spaces
fn trim_padding(str value) {
    u32 length = std::string::length(value);
    while (length > 0 && std::string::at(value, length - 1) == ' ')
        length -= 1;
    return std::string::substr(value, 0, length);
};

fn format_short_name(ref ShortNameEntry entry) {
    str name = trim_padding(entry.name);
    str extension = trim_padding(entry.extension);
    u8 first = u8(entry.name[0]);

    // 0xE5 marks a deleted entry, 0x05 stands for a real leading 0xE5 byte
    if (first == 0xE5 || first == 0x05)
        name = "?" + std::string::substr(name, 1, std::string::length(name) - 1);
    if (entry.caseFlags.lowerBase)
        name = std::string::to_lower(name);
    if (entry.caseFlags.lowerExtension)
        extension = std::string::to_lower(extension);
    if (extension != "")
        name = name + "." + extension;

    if (entry.attributes.volumeLabel)
        return std::format("Volume label \"{}\"", trim_padding(std::string::to_string(entry.name) + std::string::to_string(entry.extension)));
    else if (first == 0xE5)
        return std::format("Deleted: {}", name);
    else if (entry.attributes.subdirectory)
        return std::format("<DIR> {}", name);
    else
        return std::format("{} ({} bytes)", name, entry.fileSize);
};

struct DirectoryEntry {
    u8 firstByte @ addressof(this) [[hidden]];
    u8 attributeByte @ addressof(this) + 11 [[hidden]];

    if ((attributeByte & 0x3F) == 0x0F && firstByte != 0xE5)
        LongNameEntry longName;
    else
        ShortNameEntry entry;
} [[inline]];

fn is_end_of_directory(u64 address) {
    return std::mem::read_unsigned(address, 1) == 0x00;
};

// The fixed size root directory of FAT12/16, up to the 0x00 end marker
struct RootDirectory<auto End> {
    DirectoryEntry entries[while($ + 32 <= End && !is_end_of_directory($))] [[inline]];
} [[name("Root Directory")]];

// Decides where the chain continues after a run, and stops it on a cycle or a broken link
fn chain_advance(u32 cluster, u32 runLength, bool wantMore) {
    chainVisited += runLength;
    u32 next = run_next(cluster, runLength);
    if (!wantMore) {
        chainCluster = 0;
    } else if (!is_valid_cluster(next)) {
        std::warning(std::format("Cluster chain ends early at cluster {} (FAT entry 0x{:X})", cluster + runLength - 1, next));
        chainCluster = 0;
    } else if (chainVisited >= clusterCount) {
        std::warning(std::format("Cluster chain is longer than the volume, it loops back at cluster {}", next));
        chainCluster = 0;
    } else {
        chainCluster = next;
    }
};

struct DirectoryEntries<auto End> {
    DirectoryEntry entries[while($ + 32 <= End && !is_end_of_directory($))] [[inline]];
} [[inline]];

// One run of physically consecutive clusters of a directory
struct DirectoryRun {
    // Subdirectories walk their own chains while this run is parsed, keep ours in locals
    u32 cluster = chainCluster;
    u32 visited = chainVisited;
    u32 runLength = run_length(cluster);
    u64 runStart = cluster_address(cluster);
    u64 runEnd = runStart + u64(runLength) * bytesPerCluster;
    bool cutOff = runEnd > std::mem::size();
    if (cutOff) {
        std::warning(std::format("Directory cluster {} lies beyond the end of the image", cluster));
        runEnd = std::math::max(runStart, std::mem::size());
    }

    if (runStart < runEnd)
        DirectoryEntries<runEnd> entries @ runStart;

    // Only the last run of a directory may end with the end marker
    chainCluster = cluster;
    chainVisited = visited;
    chain_advance(cluster, runLength, !cutOff && runStart + sizeof(entries) == runEnd);
} [[inline]];

struct Directory<auto Cluster> {
    chainCluster = Cluster;
    chainVisited = 0;
    DirectoryRun runs[while(chainCluster != 0)] [[inline]];
} [[name(std::format("Directory @ cluster {}", Cluster))]];

// One run of physically consecutive clusters of a file
struct FileRun {
    u32 cluster = chainCluster;
    u32 runLength = run_length(cluster);
    u64 size = std::math::min(u64(runLength) * bytesPerCluster, chainRemaining);
    u64 address = cluster_address(cluster);
    bool cutOff = address + size > std::mem::size();
    if (cutOff) {
        std::warning(std::format("File data at cluster {} lies beyond the end of the image", cluster));
        size = address < std::mem::size() ? std::mem::size() - address : 0;
    }

    if (size > 0)
        std::mem::Bytes<size> data @ address;

    chainRemaining -= size;
    chain_advance(cluster, runLength, chainRemaining > 0 && !cutOff);
} [[format("format_file_run")]];

fn format_file_run(ref FileRun run) {
    return std::format("{} bytes at cluster {}", run.size, run.cluster);
};

struct FileData<auto Cluster, auto Size> {
    chainCluster = Cluster;
    chainVisited = 0;
    chainRemaining = Size;
    FileRun runs[while(chainCluster != 0)] [[inline]];
} [[name(std::format("File Data @ cluster {}", Cluster))]];

// ---- Volume ----

struct FATVolume {
    BootSector bootSector;

    bytesPerSector = bootSector.bpb.bytesPerSector;
    bytesPerCluster = bytesPerSector * bootSector.bpb.sectorsPerCluster;

    if (bootSector.signature != 0xAA55)
        std::warning(std::format("Unexpected boot sector signature 0x{:04X}", bootSector.signature));
    if (bytesPerCluster == 0)
        std::error("Invalid BIOS Parameter Block: bytes per cluster is zero");
    if (bootSector.bpb.fatSize16 == 0)
        std::error("fatSize16 is zero, this is a FAT32 volume. Use fs/fat32.hexpat instead");

    u32 totalSectors = bootSector.bpb.totalSectors16 != 0 ? bootSector.bpb.totalSectors16 : bootSector.bpb.totalSectors32;
    u32 rootDirSectors = (u32(bootSector.bpb.rootEntryCount) * 32 + bytesPerSector - 1) / bytesPerSector;
    u32 firstRootDirSector = bootSector.bpb.reservedSectorCount + u32(bootSector.bpb.numFats) * bootSector.bpb.fatSize16;
    u32 firstDataSector = firstRootDirSector + rootDirSectors;

    fatAddress = addressof(this) + u64(bootSector.bpb.reservedSectorCount) * bytesPerSector;
    fatBytes = u64(bootSector.bpb.fatSize16) * bytesPerSector;
    dataAddress = addressof(this) + u64(firstDataSector) * bytesPerSector;
    clusterCount = (totalSectors - firstDataSector) / bootSector.bpb.sectorsPerCluster;

    // The FAT type depends on the cluster count only (fatgen103, "FAT Type Determination")
    if (clusterCount < 4085)
        fatBits = 12;
    else if (clusterCount < 65525)
        fatBits = 16;
    else
        std::error(std::format("{} clusters is too many for FAT12/16, this is a FAT32 volume. Use fs/fat32.hexpat instead", clusterCount));

    // A damaged BPB can claim more clusters than its FAT has entries for
    u32 fatCapacity = fatBits == 12 ? fatBytes * 2 / 3 : fatBytes / 2;
    if (clusterCount + 2 > fatCapacity) {
        std::warning(std::format("The BPB describes {} clusters but each FAT only has room for {} entries", clusterCount, fatCapacity));
        clusterCount = fatCapacity > 2 ? fatCapacity - 2 : 0;
    }

    // FATs and the root directory, as far as a cut off image still holds them
    u32 fatsInImage = fatAddress >= std::mem::size() || fatBytes == 0 ? 0 :
                      std::math::min(bootSector.bpb.numFats, (std::mem::size() - fatAddress + fatBytes - 1) / fatBytes);
    if (fatsInImage < bootSector.bpb.numFats)
        std::warning(std::format("The image ends before FAT {} of {}", fatsInImage + 1, bootSector.bpb.numFats));
    FileAllocationTable fats[fatsInImage] @ fatAddress;

    u64 rootDirAddress = addressof(this) + u64(firstRootDirSector) * bytesPerSector;
    u64 rootDirEnd = std::math::min(rootDirAddress + u64(bootSector.bpb.rootEntryCount) * 32, std::mem::size());
    if (rootDirAddress < rootDirEnd)
        RootDirectory<rootDirEnd> rootDirectory @ rootDirAddress;
} [[format("format_volume")]];

fn format_volume(ref FATVolume volume) {
    return std::format("FAT{} volume, {} clusters of {} bytes", fatBits, clusterCount, bytesPerCluster);
};

struct FATImage {
    if (std::mem::size() >= 512)
        FATVolume fat;
    else
        u8 truncatedBootSector[std::mem::size()];
} [[inline]];

FATImage image @ 0x00;
