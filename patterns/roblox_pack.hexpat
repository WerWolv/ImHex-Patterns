#pragma author marduk.ru
#pragma description Roblox .pack shader archive format
#pragma magic [ 52 42 58 53 ] @ 0x00

import std.string;
import hex.core;
import type.magic;

struct Header {
    type::Magic<"RBXS"> magic;
    u32 fileCount;
};

struct FileIndex {
    char name[0x40];
    u8 unknown[0x10] [[hidden]];
    u32  startAddress;
    u32  size;
    u64  unknown_2 [[hidden]];
    
    u8 file[size] @ startAddress;
    
    #ifdef __IMHEX__
    hex::core::add_virtual_file(name, file);
    #endif
} [[name(name)]];

struct RBXPack {
    Header header;
    FileIndex files[header.fileCount];
};

RBXPack pack @ 0x0;