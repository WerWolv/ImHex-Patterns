#pragma author Lexi Mayfield
#pragma description AppleSingle/AppleDouble file format
#pragma endian big
#pragma magic [00 05 16 0?] @ 0x00

import type.magic;

enum EntryID : u32 {
    DataFork = 1,
    ResourceFork = 2,
    RealName = 3,
    Comment = 4,
    IconBW = 5,
    IconColor = 6,
    FileDatesInfo = 8,
    FinderInfo = 9,
    MacFileInfo = 10,
    ProDOSFileInfo = 11,
    MSDOSFileInfo = 12,
    ShortName = 13,
    AFPFileInfo = 14,
    DirectoryID = 15,
};

struct Entry {
    EntryID entryID;
    u32 offset;
    u32 length;
    u8 data[length] @ offset [[sealed]];
};

enum FileType : u32 {
    AppleSingle = 0x00051600,
    AppleDouble = 0x00051607,
};

enum Version : u32 {
    V1 = 0x00010000,
    V2 = 0x00020000,
};

struct AppleSingleDouble {
    FileType fileType;
    Version version;
    char homeFileSystem[16];
    u16 numEntries;
    Entry entryDescs[numEntries];
};

AppleSingleDouble appleSingleDouble @ 0x00;