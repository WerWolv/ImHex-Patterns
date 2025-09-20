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
    u128 md5Hash;
    u32  offset;
    u32  size;
    u64  reserved;
    
    u8 file[size] @ offset;
    
    #ifdef __IMHEX__
    hex::core::add_virtual_file(name, file);
    #endif
} [[name(name)]];

struct RBXPack {
    Header header;
    FileIndex files[header.fileCount];
};

RBXPack pack @ 0x0;