import std.core;

u64 bytesPerCluster;

struct FSInfo {
    u32 leadSignature;
    padding[480];
    u32 structSignature;
    u32 freeClusterCount;
    u32 nextFreeCluster;
    padding[12];
    u32 trailSignature;
};

bitfield SequenceNumber {
    padding : 1;
    lastLogical : 1;
    padding : 1;
    number : 5;
} [[bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 8)]];

enum EntryStatus : u8 {
    Regular = 0x00,
    DotEntry = 0x2E,
    DeletedEntry = 0xE5
};

union EntryStatusOrSequenceNumber {
    EntryStatus entryStatus;
    SequenceNumber sequenceNumber;
};

bitfield Attributes {
    readOnly : 1;
    hidden : 1;
    systemFile : 1;
    volumeLabel : 1;
    subdirectory : 1;
    archive : 1;
    padding : 2;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

struct DirEntry {
    char fileName[8];
    char extension[3];
    Attributes attributes;
    u8 reserved[10];
    u16 time, date;
    u16 startingCluster;
    u32 fileSize;

    u8 data[fileSize] @ startingCluster * bytesPerCluster;
};

struct VFATDirEntry {
    EntryStatusOrSequenceNumber entryStatusOrSequenceNumber;
    char16 name1[5];
    Attributes attributes;
    u8 type;
    u8 nameChecksum;
    char16 name2[6];
    u16 startingCluster;
    char16 name3[2];

    if (entryStatusOrSequenceNumber.sequenceNumber.number > 1)
        VFATDirEntry nextLogicalEntry;
    else
        DirEntry physicalEntry;
};

struct FAT32 {
    u8 jmpCode[3];
    char oemName[8];
    u16 bytesPerSector;
    u8 sectorsPerCluster;
    u16 reservedAreaSize;
    u8 numFats;
    u16 rootEntryCount;
    u16 numSectors;
    u8 mediaType;
    u16 fatSize;
    u16 sectorsPerTrack;
    u16 numHeads;
    u32 numHiddenSectors;
    u32 numFsSectors;
    u32 numFatSectors;
    u16 extFlags;
    u16 fsVersion;
    u32 rootCluster;
    u16 fsInfoSector;
    u16 backupBootSector;
    padding[12];
    u8 driveNumber;
    padding[1];
    u8 bootSignature;
    u32 volumeID;
    char volumeLabel[11];
    char fsType[8];
    u8 bootstrapCode[420];
    u16 signature;

    bytesPerCluster = (sectorsPerCluster * 1024) * bytesPerSector;

    FSInfo fsInfo @ addressof(this) + fsInfoSector * bytesPerSector;
    VFATDirEntry rootDirEntry @ addressof(this) + rootCluster * bytesPerCluster;
};

FAT32 fat32 @ 0x00;