#pragma author Enaium
#pragma description Valve VPK

import std.io;
import std.mem;
import std.string;

struct string {
    char text[while(std::mem::read_unsigned($, 1) != 0x0)];
    u8 end [[hidden]];
    if (text == "") {
        break;
    }
};

struct entry {
    string name;
    u32 crc;
    u16 preload_bytes;
    u16 archive_index;
    u32 entry_offset;
    u32 entry_length;
    u16 terminator;

    if (preload_bytes > 0x0) {
        u8 preload[preload_bytes];
    }

    if (archive_index == 0x7fff) {
        u8 data[entry_length] @ entry_offset;
    }
};

struct path {
    string name;
    entry entry[while(true)];
};

struct extension {
    string name;
    path path[while(true)];
};

struct header {
    u32 signature;
    u32 version;
    u32 tree_size;
    
    if (version == 0x2) {
        u32 file_data_section_size;
        u32 archive_md5_section_size;
        u32 ohter_md5_section_size;
        u32 signature_section_size;
    }
};

struct vpk {
    header header;
    extension extension[while(true)];
};

vpk vpk @ 0x0;