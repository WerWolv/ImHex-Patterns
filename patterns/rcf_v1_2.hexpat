// Ported from LRCFB @ https://donutteam.com/@lucasc190/releases
// Tested with files from:
// - Hulk (PS2)
// - Tetris Worlds (Gamecube)
// - The Simpsons Hit and Run (PC)

#pragma author blu
#pragma description Radcore Cement Library file header (.rcf) v1.2

import std.core;
import type.time;

struct DataEntry {
    u32 hash;
    u32 position;
    u32 size;
};

struct NameEntry {
    le u32 length;
    char name[length];
    le type::time32_t time;
};

struct Header {
    char signature[32];
    u8 version_major;
    u8 version_minor;
    bool is_bigendian; // true for gamecube
    u8 unk_0; //always "1" according to LRCFB
    if (is_bigendian) {
        std::core::set_endian(std::mem::Endian::Big);
    }
    u32 alignment;
    u32 unk_1;
    u32 directory_position;
    $ = directory_position;
    s32 data_count;
    u32 names_position;
    u32 data_position;
    le u32 data_pointer;
    DataEntry data_entries[data_count];
    $ = names_position;
    le u32 names_count;
    le u32 names_pointer;
    NameEntry name_entries[names_count];
};

Header header @ 0x00;
