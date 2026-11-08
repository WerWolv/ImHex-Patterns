#pragma author Scott Anderson
#pragma description Palworld Save Game
#pragma magic [ 50 6C 5A 30 47 56 41 53 ] @ 0x08
#pragma magic [ 50 6C 5A 31 78 ] @ 0x08
#pragma magic [ 50 6C 5A 32 78 ] @ 0x08
#pragma endian little

import std.core;
import std.mem;
import std.sys;

#ifdef __IMHEX__
import hex.dec;
#endif

/// The last byte of the magic gives the compression
enum PalworldCompression : u32 {
    None      = u32("PlZ0"),
    Zlib      = u32("PlZ1"),
    ZlibTwice = u32("PlZ2")
};

struct PlZHeader {
    u32 uncompressedSize;
    u32 compressedSize; // for PlZ2, the size after one inflate
    PalworldCompression compression;
};

/// The header, then the save game, which is inflated into a section unless it's PlZ0
struct PalworldSaveGame {
    PlZHeader header;
    std::mem::Section section = 0;
    if (header.compression != PalworldCompression::None) {
#ifdef __IMHEX__
        u8 compressed[std::mem::size() - sizeof(header)] [[hidden]];
        section = std::mem::create_section("Palworld save game");
        hex::dec::zlib_decompress(compressed, section, 15);
        if (header.compression == PalworldCompression::ZlibTwice) {
            u8 inflatedOnce[std::mem::get_section_size(section)] @ 0 in section [[hidden]];
            section = std::mem::create_section("Palworld save game");
            hex::dec::zlib_decompress(inflatedOnce, section, 15);
        }
        std::assert_warn(std::mem::get_section_size(section) == header.uncompressedSize,
            "The inflated size doesn't match the header");
#endif
#ifndef __IMHEX__
        std::error("Only ImHex can inflate Palworld save games");
#endif
    }
};

PalworldSaveGame palworld @ 0;

#define GVAS_USE_LIB
const std::mem::Section gvasSection = palworld.section;
const u128 gvasAddress = gvasSection == 0 ? sizeof(palworld.header) : 0;
const u128 gvasSize = gvasSection == 0 ? std::mem::size() - gvasAddress : palworld.header.uncompressedSize;
#include "gvas.hexpat"
