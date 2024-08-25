#pragma author sethhall
#pragma description Windows Notepad Cache Files

// This was written based on the following blog post: 
//    https://u0041.co/posts/articals/exploring-windows-artifacts-notepad-files/

import type.leb128;
import type.time;
import type.magic;
import std.time;

using uLEB128 = type::uLEB128;

enum Encodings: u8 {
    ANSI = 0x01,
    UTF_16LE = 0x02,
    UTF_16BE = 0x03,
    UTF_8BOM = 0x04,
    UTF_8 = 0x05,
};

enum LineEndings: u8 {
    CRLF = 0x01,
    CR = 0x02,
    LF = 0x03,
};

struct ConfigBlock {
    bool word_wrap;
    bool rtl;
    bool show_unicode;
    uLEB128 version;
    u16 unknown;
};

struct UnsavedChunk {
    uLEB128 cursor_position;
    uLEB128 deletion_number;
    uLEB128 addition_number;
    char16 chars[addition_number];
    char crc32[4] [[format("hash_format"), comment("CRC32 hash of the entire unsaved chunk structure")]];
};

struct Notepad_File {
    type::Magic<"NP\0"> signature [[comment("File signature")]];
    bool is_saved;
    if ( is_saved ) {
        uLEB128 path_length;
        char16 path[path_length] [[comment("Path of saved file on disk")]];
        uLEB128 file_size;
        Encodings encoding;
        LineEndings line_endings;
        uLEB128 last_write [[format("format_filetime")]];
        char sha256[32] [[format("hash_format")]];
        u8 unknown1;
    }
    u8 unknown2;
    uLEB128 selection_start;
    uLEB128 selection_end;
    ConfigBlock config_block;
    type::uLEB128 content_length;
    char16 content[content_length];
    bool contain_unsaved_data;
    char crc32[4] [[format("hash_format")]];
    UnsavedChunk unsaved_chunks[while(!std::mem::eof())];
};

fn hash_format(auto bytes) {
    str hash_hex;
    for(u8 i=0, i < sizeof(bytes), i+=1) {
        hash_hex = hash_hex + std::format("{:02X}",bytes[i]);
    }
    return hash_hex;
};

fn format_filetime(uLEB128 data) {
    // We will only support dates back to the epoch
    std::time::Time time64 = std::time::to_utc((data / 10000000.0) - 11644473600.0);
    return std::time::format(time64, "%c");
};

Notepad_File file @ $;