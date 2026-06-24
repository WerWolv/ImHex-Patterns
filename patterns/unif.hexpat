#pragma author gmestanley
#pragma description Universal NES Image Format

import std.mem;

struct Header {
    char signature[4];
    u32 version;
};

Header header @ 0x00;

struct Chunk {
    char type[4];
    u32 length;
    match (type) {
        ("MAPR"): char mapper[length];
        ("PRG0"): if (length<std::mem::size()) u8 prgROM[length];
        ("CHR0"): u8 chrROM[length];
        (_): u8 chunk[length];
    }
};

Chunk chunks[while($<std::mem::size())] @ 0x20-0x18*($[0x08]>0);