#pragma author WerWolv
#pragma description Nintendo Switch PFS0 archive (NSP files)

import type.magic;
import type.size;

import std.core;

struct FileEntry {
    u64 dataOffset;
    type::Size<u64> dataSize;
    u32 nameOffset;
    padding[4];
};

struct String {
    char value[];
};

struct Header {
    type::Magic<"PFS0"> magic;
    u32 numFiles;
    type::Size<u32> stringTableSize;
    padding[4];
    
    FileEntry fileEntryTable[numFiles];
    String strings[numFiles];
};

struct File {
    char name[] @ addressof(parent.header.strings) + parent.header.fileEntryTable[std::core::array_index()].nameOffset;
    u8 data[parent.header.fileEntryTable[std::core::array_index()].dataSize] @ parent.header.fileEntryTable[std::core::array_index()].dataOffset [[sealed]];
};

struct PFS0 {
    Header header; 
    
    File files[header.numFiles];
};

PFS0 pfs0 @ 0x00;