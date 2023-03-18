// Apple pbz compressed file
// Used by Apple on .xip files and OTA updates,
// and can be created with macOS compression_tool.
//
// Copyright (c) 2023 Nicolás Alvarez <nicolas.alvarez@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include <std/mem.pat>
#include <type/magic.pat>

#pragma endian big

#define SHOW_DATA 0

enum CompressionType: char {
    ZLIB  = 'z',
    LZMA  = 'x',
    LZ4   = '4',
    LZFSE = 'e'
};

struct Chunk {
    u64 uncompressed_size;
    u64 compressed_size;
    if (SHOW_DATA) {
        u8 data[compressed_size] [[sealed]];
    } else {
        padding[compressed_size];
    }
};

struct PBZ {
    type::Magic<"pbz"> magic;
    CompressionType compression;
    u64 chunk_size;
    Chunk chunks[while(!std::mem::eof())];
};

PBZ pbz @ 0;
