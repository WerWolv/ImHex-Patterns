#pragma author DexrnZacAttack
#pragma description Minecraft LCE ARC File
#pragma endian big

import std.string;
import hex.core;

struct Table {
    u16 nameSize;
    char fileName[nameSize];
    u32 offset;
    u32 size;
    u8 file[size] @ offset;
    hex::core::add_virtual_file(fileName, file);
} [[name(std::string::to_string(fileName))]];

struct ARC {
    u32 count;
    Table table[count];
};

ARC arc @ 0x00;
