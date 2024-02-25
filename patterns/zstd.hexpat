#pragma description Zstandard compressed data format

// https://github.com/facebook/zstd/blob/dev/doc/zstd_compression_format.md

#pragma MIME application/zstd

import std.core;
import std.io;
import std.mem;
import std.sys;

using BitfieldOrder = std::core::BitfieldOrder;

#define ZSTD_MAGIC_NUMBER 0xFD2FB528

bitfield frame_header_descriptor_t {
    frame_content_size_flag : 2;
    single_segment_flag : 1;
    unused_bit : 1;
    reserved_bit : 1;
    content_checksum_flag : 1;
    dictionary_id_flag : 2;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

bitfield window_descriptor_t {
    exponent : 5;
    mantissa : 3;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

fn window_size(window_descriptor_t window_descriptor) {
    u64 window_log = 10 + window_descriptor.exponent;
    u64 window_base = 1 << window_log;
    u64 window_add = (window_base / 8) * window_descriptor.mantissa;
    u64 window_size = window_base + window_add;
    return window_size;
};

struct frame_header_t {
    frame_header_descriptor_t frame_header_descriptor;

    if (!frame_header_descriptor.single_segment_flag){
        window_descriptor_t window_descriptor;
    }

    if (frame_header_descriptor.dictionary_id_flag == 1) {
        le u8 dictionary_id;
    }
    else if (frame_header_descriptor.dictionary_id_flag == 2) {
        le u16 dictionary_id;
    }
    else if (frame_header_descriptor.dictionary_id_flag == 3) {
        le u32 dictionary_id;
    }

    if (frame_header_descriptor.frame_content_size_flag == 0) { // 0
        if (frame_header_descriptor.single_segment_flag) {
            le u8 content_size;
        }
    }
    else if (frame_header_descriptor.frame_content_size_flag == 1) {
        le u16 content_size;
    }
    else if (frame_header_descriptor.frame_content_size_flag == 2) {
        le u32 content_size;
    }
    else {
        le u64 content_size;
    }
};

bitfield block_header_t {
    last_block : 1;
    block_type : 2;
    block_size : 21;
};

enum block_type : u8 {
    raw_block = 0,
    rle_block = 1,
    compressed_block = 2,
    reserved = 3
};

struct data_block_t {
    block_header_t block_header;

    if (block_header.last_block) {
        last_block_flag = true;
    }

    if (block_header.block_type == block_type::raw_block) {
        le u8 block_content[block_header.block_size];
    }
    else if (block_header.block_type == block_type::rle_block) {
        le u8 block_content[1];
    }
    else if (block_header.block_type == block_type::compressed_block) {
        le u8 block_content[block_header.block_size];
    }
    else {
        std::error("The data block seems to be corrupted!");
    }
};

struct content_checksum_t {
    le u32 xxh64_hash;
};

struct zstd_frame_t {
    le u32 magic_number;
    std::assert(magic_number == ZSTD_MAGIC_NUMBER, "Invalid magic number!");
    frame_header_t frame_header;
    data_block_t data_block[while(!last_block_flag)];
    if (frame_header.frame_header_descriptor.content_checksum_flag) {
        content_checksum_t content_checksum;
    }
};

bool last_block_flag = false;
zstd_frame_t zstd_frame @ 0x00;
