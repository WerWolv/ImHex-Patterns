#pragma magic [45 58 46 41 54 20 20 20] @ 0x03
#pragma description Extensible File Allocation Table (exFAT)
#pragma author Khoo Hao Yit

import std.mem;
import std.string;
import std.core;

#pragma eval_depth 0

struct BootSector {
    std::mem::Bytes<3> jumpBoot;
    char fileSystemName[8];
    std::mem::Bytes<53> mustBeZero;
    u64 partitionOffset;
    u64 volumeLength;
    u32 fatOffset;
    u32 fatLength;
    u32 clusterHeapOffset;
    u32 clusterCount;
    u32 firstClusterOfRootDirectory;
    u32 volumeSerialNumber;
    u16 fileSystemRevision;
    u16 volumeFlags;
    u8 bytesPerSectorShift;
    u8 sectorsPerClusterShift;
    u8 numberOfFats;
    u8 driveSelect;
    u8 percentInUse;
    std::mem::Bytes<7> reserved;
    std::mem::Bytes<390> bootCode;
    std::mem::Bytes<2> bootSignature;
};

struct ExtendedBootSector {
    std::mem::Bytes<bytesPerSector - 4> bootCode;
    std::mem::Bytes<4> bootSignature;
};

struct Parameter {
    std::mem::Bytes<16> guid;
    std::mem::Bytes<32> data;
};

struct OemParameter {
    Parameter parameters[10];
    std::mem::Bytes<bytesPerSector - 480> reserved;
};

u64 bytesPerSector;
u64 startOfClusterHeap;
u64 bytesPerCluster;
u64 fatAddress;

struct BootRegion {
    BootSector bootSector;

    bytesPerSector = 1 << bootSector.bytesPerSectorShift;
    bytesPerCluster = bytesPerSector << bootSector.sectorsPerClusterShift;

    ExtendedBootSector extendedBootSectors[8];
    OemParameter oemParameter;
    std::mem::Bytes<bytesPerSector> reservedSector;
    std::mem::Bytes<bytesPerSector> bootChecksum;
};

struct VolumeLabelEntry {
    u8 entryType;
    u8 characterCount;
    char volumeLabel[22];
    std::mem::Bytes<8> reserved;
};

bitfield FileAttribute {
    readOnly : 1;
    hidden : 1;
    system : 1;
    reserved : 1;
    directory : 1;
    archive : 1;
    reserved1 : 10;
};

auto currentClusterIndex = -1;
auto currentClusterSize = -1;
auto currentIsDirectory = -1;

struct FileEntry {
    u8 entryType;
    u8 secondayEntryCount;
    u16 checksum;
    FileAttribute attributes;
    std::mem::Bytes<2> reserved;
    u32 creationDatetime;
    u32 modificationDatetime;
    u32 accessDatetime;
    u8 creationTimeHundredths;
    u8 modificationTimeHundredths;
    u8 creationUtcOffset;
    u8 modificationUtcOffset;
    u8 accessUtcOffset;
    std::mem::Bytes<7> reserved1;

    currentIsDirectory = attributes.directory;
};

bitfield GeneralSecondaryFlags {
    allocationPossible : 1;
    noFatChain : 1;
    customDefined : 6;
};

struct FileNameEntry {
    u8 entryType;
    u8 flags;
    char16 name[15];
};

fn divideCeil(auto a, auto b) {
    auto result = a / b;
    auto remain = a % b;
    if (remain) {
        result += 1;
    }
    return result;
};

struct ContinuousFatRange<auto ClusterIndex, auto ClusterSize> {
    u32 fatRange[ClusterSize] @ fatAddress + ClusterIndex * 4 [[sealed]];
} [[name(std::format("ContinuousFatRange<{}, {}>", ClusterIndex, ClusterSize))]];

struct FatChain {
    auto clusterIndex = currentClusterIndex;
    auto clusterSize = currentClusterSize;
    currentClusterIndex = -1;
    currentClusterSize = -1;
    if (clusterIndex == -1) {
        std::error(std::format("Invalid cluster index: {}", clusterIndex));
    }
    if (clusterSize == -1) {
        auto startingFatRange = fatAddress + clusterIndex * 4;
        u32 clusters[while(
            $ == startingFatRange
            || $ == fatAddress + std::mem::read_unsigned($ - 4, 4) * 4
        )] @ startingFatRange [[hidden]];
        clusterSize = std::core::member_count(clusters);
    }
    ContinuousFatRange<clusterIndex, clusterSize> data @ 0;
    try {
        auto nextClusterIndex = clusters[clusterSize - 1];
        if (nextClusterIndex != 0xffffffff && nextClusterIndex != 0) {
            currentClusterIndex = nextClusterIndex;
            FatChain next @ 0 [[inline]];
        }
    }
} [[name(std::format("FatChain<{}>", clusterIndex))]];

struct ContinuousDataRange<auto ClusterIndex, auto ClusterSize> {
    std::mem::Bytes<ClusterSize * bytesPerCluster> dataRange @
        startOfClusterHeap + ClusterIndex * bytesPerCluster;
} [[name(std::format("ContinuousDataRange<{}, {}>", ClusterIndex, ClusterSize))]];

struct DataChain {
    auto clusterIndex = currentClusterIndex;
    auto clusterSize = currentClusterSize;
    currentClusterIndex = -1;
    currentClusterSize = -1;
    if (clusterIndex == -1) {
        std::error(std::format("Invalid cluster index: {}", clusterIndex));
    }
    if (clusterSize == -1) {
        auto startingFatRange = fatAddress + clusterIndex * 4;
        u32 clusters[while(
            $ == startingFatRange
            || $ == fatAddress + std::mem::read_unsigned($ - 4, 4) * 4
        )] @ startingFatRange [[hidden]];
        clusterSize = std::core::member_count(clusters);
    }
    ContinuousDataRange<clusterIndex, clusterSize> data @ 0;
    try {
        auto nextClusterIndex = clusters[clusterSize - 1];
        if (nextClusterIndex != 0xffffffff && nextClusterIndex != 0) {
            currentClusterIndex = nextClusterIndex;
            DataChain next @ 0 [[inline]];
        }
    }
} [[name(std::format("DataChain<{}>", clusterIndex))]];

struct UpcaseTableEntry {
    u8 entryType;
    std::mem::Bytes<3> reserved;
    u32 tableChecksum;
    std::mem::Bytes<12> reserved1;
    u32 firstCluster;
    u64 dataLength;

    ContinuousFatRange<firstCluster, 1> fatRange;
    ContinuousDataRange<firstCluster, 1> dataRange;
};

struct AllocationBitmapEntry {
    u8 entryType;
    u8 bitmapFlags;
    std::mem::Bytes<18> reserved;
    u32 firstCluster;
    u64 dataLength;

    ContinuousFatRange<firstCluster, 1> fatRange;
    ContinuousDataRange<firstCluster, 1> dataRange;
};

using StreamExtensionEntry;
struct DirectoryEntry {
    u8 entryType @ addressof(this) [[hidden]];
    match (entryType) {
        (0x83 | 0x03): VolumeLabelEntry;
        (0x81): AllocationBitmapEntry;
        (0x82): UpcaseTableEntry;
        (0x85 | 0x05): FileEntry;
        (0xc0 | 0x40): StreamExtensionEntry;
        (0xc1 | 0x41): FileNameEntry;
        (_): std::mem::Bytes<32> [[name(std::format("UnknownEntry @ {:#X}", addressof(this)))]];
    }
} [[inline]];

struct ContinuousDirectoryEntry<auto ClusterIndex, auto ClusterSize> {
    DirectoryEntry entry[ClusterSize * bytesPerCluster / 32] @
        startOfClusterHeap + ClusterIndex * bytesPerCluster
        [[inline]];
} [[name(std::format("ContinuousDirectoryEntry<{}, {}>", ClusterIndex, ClusterSize))]];

struct DirectoryEntryChain {
    auto clusterIndex = currentClusterIndex;
    auto clusterSize = currentClusterSize;
    currentClusterIndex = -1;
    currentClusterSize = -1;
    if (clusterIndex == -1) {
        std::error(std::format("Invalid cluster index: {}", clusterIndex));
    }
    if (clusterSize == -1) {
        auto startingFatRange = fatAddress + clusterIndex * 4;
        u32 clusters[while(
            $ == startingFatRange
            || $ == fatAddress + std::mem::read_unsigned($ - 4, 4) * 4
        )] @ startingFatRange [[hidden]];
        clusterSize = std::core::member_count(clusters);
    }
    ContinuousDirectoryEntry<clusterIndex, clusterSize> data @ 0;
    try {
        auto nextClusterIndex = clusters[clusterSize - 1];
        if (nextClusterIndex != 0xffffffff && nextClusterIndex != 0) {
            currentClusterIndex = nextClusterIndex;
            DirectoryEntryChain next @ 0 [[inline]];
        }
    }
    currentIsDirectory = -1;
} [[name(std::format("DirectoryEntryChain<{}>", clusterIndex))]];

struct StreamExtensionEntry {
    u8 entryType;
    GeneralSecondaryFlags secondaryFlags;
    std::mem::Bytes<1> reserved;
    u8 nameLength;
    u16 nameHash;
    std::mem::Bytes<2> reserved1;
    u64 validDateLength;
    std::mem::Bytes<4> reserved2;
    u32 firstCluster;
    u64 dataLength;
    
    if (entryType & 0x80 && currentIsDirectory == 1) {
        currentClusterIndex = firstCluster;
        if (secondaryFlags.noFatChain) {
            currentClusterSize = divideCeil(dataLength, bytesPerCluster);
        }
        FatChain fatChain;
        currentClusterIndex = firstCluster;
        if (secondaryFlags.noFatChain) {
            currentClusterSize = divideCeil(dataLength, bytesPerCluster);
        }
        DirectoryEntryChain directoryChain;
    }
    else if (dataLength) {
        currentClusterIndex = firstCluster;
        if (secondaryFlags.noFatChain) {
            currentClusterSize = divideCeil(dataLength, bytesPerCluster);
        }
        FatChain fatChain;
        currentClusterIndex = firstCluster;
        if (secondaryFlags.noFatChain) {
            currentClusterSize = divideCeil(dataLength, bytesPerCluster);
        }
        DataChain data @ 0;
    }
};

BootRegion bootRegion @ 0 [[name("BootRegion")]];
BootRegion backupBootRegion @ 12 * bytesPerSector [[name("BackupBootRegion")]];

startOfClusterHeap = 
    bootRegion.bootSector.clusterHeapOffset * bytesPerSector
    - 2 * bytesPerCluster;
fatAddress = 
    bootRegion.bootSector.fatOffset * bytesPerSector;

std::mem::Bytes<bootRegion.bootSector.fatLength * bytesPerSector> fat @ fatAddress [[hidden]];

currentClusterIndex = bootRegion.bootSector.firstClusterOfRootDirectory;
FatChain rootDirectoryFatChain @ 0;
currentClusterIndex = bootRegion.bootSector.firstClusterOfRootDirectory;
DirectoryEntryChain rootDirectory @ 0;
