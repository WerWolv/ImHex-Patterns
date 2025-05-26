#pragma author WerWolv
#pragma description Drive File System
#pragma MIME application/x-ima

import std.io;
import std.core;
import type.magic;
import type.guid;
import type.base;

import * from fs.fat32 as FAT32Partition;
import * from fs.exfat as ExFATPartition;
import * from fs.ntfs as NTFSPartition;

const u32 SectorSize = 512;

struct DiskTimeStamp {
    u8 seconds, minutes, hours;
};

enum DiskProtection : u16 {
    None = 0x0000,
    CopyProtected = 0x5A5A
};

bitfield CHS {
    h : 8;
    s : 6;
    c : 10;
} [[format("chs_formatter")]];

fn chs_formatter(CHS chs) {
    return std::format("({:X}, {:X}, {:X}) | 0x{:X}", chs.c, chs.h, chs.s, (chs.c * 16 + chs.h) * 63 + (chs.s - 1));
};

enum PartitionStatus : u8 {
    None = 0x00,
    Active = 0x80
};

enum MBRPartitionType : u8 {
    Empty = 0x00,
    FAT12 = 0x01,
    XENIXRoot = 0x02,
    XENIXUsr = 0x03,
    FAT16_16_32MB = 0x04,
    ExtendedCHS = 0x05,
    FAT16_32MBPlus = 0x06,
    NTFS = 0x07,
    AIX = 0x08,
    AIXBootable = 0x09,
    OS2BootManager = 0x0A,
    FAT32_CHS = 0x0B,
    FAT32_LBA = 0x0C,
    FAT16_LBA = 0x0E,
    ExtendedLBA = 0x0F,
    OPUS = 0x10,
    HiddenFAT12 = 0x11,
    CompaqDiagnostics = 0x12,
    HiddenFAT16_16_32MB = 0x14,
    HiddenFAT16_32MBPlus = 0x16,
    HiddenNTFS = 0x17,
    ASTSmartSleep = 0x18,
    HiddenFAT32_CHS = 0x1B,
    HiddenFAT32_LBA = 0x1C,
    HiddenFAT16_LBA = 0x1E,
    NEC_DOS = 0x24,
    WindowsRecovery = 0x27,
    Plan9 = 0x39,
    PowerQuest = 0x3C,
    Venix286 = 0x40,
    PPC_PReP_Boot = 0x41,
    SFS = 0x42,
    QNX4_x = 0x4D,
    QNX4_x_2ndPart = 0x4E,
    QNX4_x_3rdPart = 0x4F,
    OnTrackDM = 0x50,
    OnTrackDM6Aux1 = 0x51,
    CP_M = 0x52,
    OnTrackDM6Aux3 = 0x53,
    OnTrackDM6 = 0x54,
    EZDrive = 0x55,
    GoldenBow = 0x56,
    PriamEDisk = 0x5C,
    SpeedStor = 0x61,
    GNU_HURD = 0x63,
    NovellNetware286 = 0x64,
    NovellNetware386 = 0x65,
    DiskSecureMultiBoot = 0x70,
    PC_IX = 0x75,
    XOSL = 0x78,
    OldMinix = 0x80,
    LinuxMinix = 0x81,
    LinuxSwap = 0x82,
    Linux = 0x83,
    OS2HiddenCDrive = 0x84,
    LinuxExtended = 0x85,
    NTFSVolumeSet = 0x86,
    NTFSVolumeSet2 = 0x87,
    LinuxLVM = 0x8E,
    Amoeba = 0x93,
    AmoebaBBT = 0x94,
    BSD_OS = 0x9F,
    IBMThinkpadHibernation = 0xA0,
    FreeBSD = 0xA5,
    OpenBSD = 0xA6,
    NeXTSTEP = 0xA7,
    MacOSX = 0xA8,
    NetBSD = 0xA9,
    BSDIFS = 0xB7,
    BSDISwap = 0xB8,
    BootWizardHidden = 0xBB,
    DRDOSFAT12 = 0xC1,
    DRDOSFAT16 = 0xC4,
    DRDOSFAT16B = 0xC6,
    Syrinx = 0xC7,
    NonFSData = 0xDA,
    CP_M_CTOS = 0xDB,
    DellUtility = 0xDE,
    BootIt = 0xDF,
    DOSAccess = 0xE1,
    DOSRO = 0xE3,
    SpeedStor2 = 0xE4,
    BeOS = 0xEB,
    GPTProtective = 0xEE,
    EFI_System = 0xEF,
    LinuxPA_RISC = 0xF0,
    SpeedStor3 = 0xF1,
    DOSSecondary = 0xF2,
    LinuxRAID = 0xFD,
    LANstep = 0xFE,
    Unknown = 0xFF
};

enum GPTPartitionType : u128 {
    UnusedEntry                 = u128("\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"),
    MicrosoftReservedPartition  = u128("\x16\xE3\xC9\xE3\x5C\x0B\xB8\x4D\x81\x7D\xF9\x2D\xF0\x02\x15\xAE"),
    PartitionBasicData          = u128("\xA2\xA0\xD0\xEB\xE5\xB9\x33\x44\x87\xC0\x68\xB6\xB7\x26\x99\xC7")
};

bitfield GPTAttributes {
    bool platform_required : 1;
    padding : 59;
    bool read_only : 1;
    bool shadow_copy : 1;
    bool hidden : 1;
    bool no_drive_letter : 1;
};

struct GPTEntry {
    GPTPartitionType partitionType [[no_unique_address]];
    type::GUID partitionTypeGuid;
    type::GUID partitionGuid;
    u64 firstLba;
    u64 lastLba;
    GPTAttributes attribute;
    char16 partitionName[36];
    padding[parent.entrySize - 128];
    
    u64 partitionOffset = firstLba * SectorSize [[export]];
    match (partitionType) {
        (GPTPartitionType::UnusedEntry): {}
        (GPTPartitionType::MicrosoftReservedPartition):
            std::mem::Bytes<(lastLba - firstLba + 1) * SectorSize> microsoftReservedPartition @ partitionOffset;
        (GPTPartitionType::PartitionBasicData): {}
        (_): std::error(std::format("Unknown GPT Partition Type {}", partitionType));
    }
};

struct GUIDPartitionTable {
    type::Magic<"EFI PART"> signature;
    u16 versionMinor;
    u16 versionMajor;
    u32 headerSize;
    type::Hex<u32> headerCrc32;
    u32 reserved;
    u64 currentLba;
    u64 backupLba;
    u64 firstUsableLba;
    u64 lastUsableLba;
    type::GUID diskGuid;
    u64 entryLba;
    u32 entryCount;
    u32 entrySize;
    type::Hex<u32> entryCrc32;

    GPTEntry entries[entryCount] @ addressof(this) + (entryLba - currentLba) * SectorSize;
};

struct PartitionEntry {
    PartitionStatus status;
    CHS chsFirstSectorAddress;
    MBRPartitionType type;
    CHS chsLastSectorAddress;
    u32 lbaFirstSectorAddress;
    u32 numSectors;

    u64 partitionOffset = lbaFirstSectorAddress * SectorSize [[export]];
    match (type) {
        (MBRPartitionType::Empty): continue;
        (MBRPartitionType::FAT32_LBA | MBRPartitionType::FAT32_CHS): 
            FAT32Partition fat32Partition @ partitionOffset;
        (MBRPartitionType::NTFS): {
            char magic[8] @ partitionOffset + 3;
            if (magic == "NTFS    ")
                NTFSPartition ntfsPartition @ partitionOffset;
            else if (magic == "EXFAT   ") 
                ExFATPartition exfatPartiton @ partitionOffset;
            else
                std::error("Unknown MBR partition with NTFS Type ID");
        }
        (MBRPartitionType::GPTProtective): 
            GUIDPartitionTable gpt @ partitionOffset;

        (_): std::error(std::format("Unknown MBR Partition Type {}", type));
    }
};

struct MasterBootRecord {
    u8 bootstrapCodeArea1[218];
    padding[2];
    u8 originalPhysicalDrive;
    DiskTimeStamp diskTimeStamp;
    u8 bootstrapCodeArea2[216];
    u32 diskSignature;
    DiskProtection diskProtection;
    PartitionEntry partitionEntries[4];
    u16 bootSignature;
};

MasterBootRecord mbr @ 0x00;
