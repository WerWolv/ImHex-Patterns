#pragma author sakharov-me

#pragma description Arx Fatalis data file
#pragma endian little
#pragma loop_limit 1048576

//based on https://github.com/arx/ArxLibertatis/blob/5b95e4c5ca9d583f1b11c085326979772645e0f3/src/io/resource/PakReader.cpp

import std.mem;
import std.core;
#include <std/string.pat>

const str PAK_KEY_DEMO = "NSIARKPRQPHBTE50GRIH3AYXJP2AMF3FCEYAVQO5QGA0JGIIH2AYXKVOA1VOGGU5GSQKKYEOIAQG1XRX0J4F5OEAEFI4DD3LL45VJTVOA1VOGGUKE50GRI";
const str PAK_KEY_FULL = "AVQF3FCKE50GRIAYXJP2AMEYO5QGA0JGIIH2NHBTVOA1VOGGU5H3GSSIARKPRQPQKKYEOIAQG1XRX0J4F5OEAEFI4DD3LL45VJTVOA1VOGGUKE50GRIAYX";

enum key_id_t: u32 {
    demo = 0x4149534E,
    full = 0x46515641,
};

bitfield file_flags {
    bool compressed : 1;
    padding : 31;
};

struct file_data<auto _name, auto _compressed, auto _uncsize, auto _size> {
    str filenamename = _name [[export]];
    bool compressed = _compressed [[export]];
    u32 uncompressed_size = _uncsize [[export]];
    u8 data[_size];
}[[format("format_file_data"), name("file")]];

fn format_file_data(auto val) {
    return std::format("{}", val.filenamename);
};

struct far_directory_file {
    char name[while(std::mem::read_unsigned($, 1) != 0)];
    padding[1];
    u32 offset;
    file_flags flags;
    u32 uncompressed_size;
    u32 size;
    file_data <parent.name + name, flags.compressed, uncompressed_size, size> data @ offset in 0;
};

struct fat_directory {
    char name[while(std::mem::read_unsigned($, 1) != 0)];
    padding[1];
    u32 file_count;
    far_directory_file files[file_count];
};

struct fat_raw {
    u32 fat_size;
    key_id_t key_id;
    $ -= 4;
    u8 fat_data[fat_size];
};

u32 fat_offset @ 0;
fat_raw encoded_fat @ fat_offset; 

std::mem::Section decodedFat = std::mem::create_section("Decoded fat");

str key = "";
if(encoded_fat.key_id == key_id_t::full) {
    key = PAK_KEY_FULL;
} else {
    key = PAK_KEY_DEMO;
}

u32 key_len = std::string::length(key);
u32 i;
u8 decoded_fat_u8[encoded_fat.fat_size] @ 0 in decodedFat [[hidden]];
for(i=0, i<encoded_fat.fat_size, i += 1) {
    u8 xor_byte = u8(key[i % key_len]);
    decoded_fat_u8[i] = encoded_fat.fat_data[i] ^ xor_byte;
}

fat_directory dirs[while($ < std::mem::get_section_size(decodedFat))] @ 0 in decodedFat [[inline]];
