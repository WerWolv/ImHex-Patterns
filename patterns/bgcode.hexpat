#pragma author Shadlock0133 (aka Aurora)
#pragma description Prusa Binary G-Code

import type.magic;
import std.mem;

enum ChecksumType : u16 {
    None,
    CRC32,
};

enum BlockType : u16 {
    FileMetadata,
    GCode,
    SlicerMetadata,
    PrinterMetadata,
    PrintMetadata,
    Thumbnail,
};

enum Compression : u16 {
    None,
    Deflate,
    Heatshrink11_4,
    Heatshrink12_4,
};

enum Encoding : u16 {
    Ini,
};

enum ImageFormat : u16 {
    Png,
    Jpg,
    Qoi,
};

struct Header {
    type::Magic<"GCDE"> magic;
    u32 version;
    ChecksumType checksum_type;
};

Header header @ 0;
std::assert(header.version == 1, "only version 1 supported");
    
struct Block {
    BlockType type;
    Compression compression;
    u32 uncompressed_size;
    auto size = uncompressed_size;
    if (compression != Compression::None) {
        u32 compressed_size;
        size = compressed_size;
    }
    match (type) {
        (BlockType::FileMetadata
        | BlockType::PrinterMetadata
        | BlockType::PrintMetadata
        | BlockType::SlicerMetadata): {
            Encoding encoding;
        }
        (BlockType::Thumbnail): {
            ImageFormat image_format;
            u16 width;
            u16 height;
        }
        (BlockType::GCode): {
            u16;
        }
        (_): { std::assert(false, "unknown type"); }
    }
    u8 data[size];
    match (header.checksum_type) {
        (ChecksumType::None): {}
        (ChecksumType::CRC32): { u32 checksum; }
    }
};

Block blocks[while(!std::mem::eof())] @ $;