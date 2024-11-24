#pragma author DexrnZacAttack
#pragma description MSSCMP (Miles Sound System Compressed Archive)
#pragma magic [ 42 41 4E 4B ] @ 0x00
#pragma magic [ 4B 4E 41 42 ] @ 0x00
#pragma array_limit 4294967295
#pragma pattern_limit 4294967295

import type.magic;
import std.core;
#ifdef __IMHEX__
    import hex.core;
#endif

struct FileDataEntry {
    u32 nameOffset;
    char name[] @ nameOffset;
    u32 folderOffset;
    char folder[] @ folderOffset;
    le u32 fileDataOffset;
    padding[8];
    u32 sampleRate;
    u32 fileSize;
    u8 data[fileSize] @ fileDataOffset;
    #ifdef __IMHEX__
        hex::core::add_virtual_file(std::string::to_string(name) + ".binka", data);
    #endif
};

struct Index2Entry {
    u32 entryOffset;
    u32 fStructureOffset;
    FileDataEntry fileDataEntry @ entryOffset;
};

struct MsscmpEntry {
    char name[12];
    Index2Entry entries[parent.header.index2EntryCount] @ parent.header.index1LastEntryOffset + 4;
};


struct Header<T> {
    padding[4]; // unk
    T fileDataOffset;
    padding[8]; // unk
    T index1Offset;
    T index1LastEntryOffset;
    if (sizeof(T) == 4)
        padding[8];
    else
        padding[16];

    T unkOffset;
    T index1EntryCount;

    if (sizeof(T) == 4)
        padding[8];
    else
        padding[4];

    u32 index2EntryCount;
};

using OldGenHeader = Header<u32>;
using NewGenHeader = Header<u64>;

struct MSSCMP {
    char magic[4];
    if (magic == "BANK")
        std::core::set_endian(std::mem::Endian::Big);
    else if (magic == "KNAB")
        std::core::set_endian(std::mem::Endian::Little);
    else
        std::error("Magic does not match BANK or KNAB");

    u32 check1 @ 0x1c [[hidden]]; // use this to check if old gen or new gen
    u32 check2 @ 0x20 [[hidden]];

    if (check1 == check2)
        OldGenHeader header;
    else
        NewGenHeader header;
    MsscmpEntry entry;
};

MSSCMP msscmp @ 0x00;
