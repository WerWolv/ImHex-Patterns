// pbzx compression stream
// Used by Apple on .xip files and OTA updates.
//
// Copyright (c) 2022 Nicolás Alvarez <nicolas.alvarez@gmail.com>
//
// SPDX-License-Identifier: GPL-2.0-or-later

#include <std/mem.pat>

#pragma endian big

#define SHOW_DATA 0

struct Chunk {
    u64 uncompressed_size;
    u64 compressed_size;
    if (SHOW_DATA) {
        u8 data[compressed_size] [[sealed]];
    } else {
        padding[compressed_size];
    }
};

struct PBZX {
    char magic[4];
    u64 chunk_size;
    Chunk chunks[while(!std::mem::eof())];
};

PBZX pbzx @ 0;
