#pragma author Gemini
#pragma description LZ4 Frame Format
#pragma MIME application/x-lz4
#pragma endian little

import std.io;
import std.sys;
import std.mem;
import std.core;

enum MagicNumber : u32 {
    Standard  = 0x184D2204,
    Legacy    = 0x184C2102,
    
    Skippable_0 = 0x184D2A50,
    Skippable_1 = 0x184D2A51,
    Skippable_2 = 0x184D2A52,
    Skippable_3 = 0x184D2A53,
    Skippable_4 = 0x184D2A54,
    Skippable_5 = 0x184D2A55,
    Skippable_6 = 0x184D2A56,
    Skippable_7 = 0x184D2A57,
    Skippable_8 = 0x184D2A58,
    Skippable_9 = 0x184D2A59,
    Skippable_A = 0x184D2A5A,
    Skippable_B = 0x184D2A5B,
    Skippable_C = 0x184D2A5C,
    Skippable_D = 0x184D2A5D,
    Skippable_E = 0x184D2A5E,
    Skippable_F = 0x184D2A5F
};

bitfield FLG {
    dictionary_id_present    : 1;
    reserved_1               : 1;
    content_checksum_present : 1;
    content_size_present     : 1;
    block_checksum_present   : 1;
    block_independence       : 1;
    version                  : 2;
};

bitfield BD {
    reserved_0      : 4;
    block_max_size  : 3;
    reserved_7      : 1;
};

struct FrameDescriptor {
    FLG flg;
    BD bd;

    std::assert(flg.version == 1, "Invalid LZ4 frame version (must be 01)");
    std::assert(bd.block_max_size >= 4, "Invalid block maximum size");

    if (flg.content_size_present) {
        u64 content_size;
    }
    if (flg.dictionary_id_present) {
        u32 dictionary_id;
    }
    
    u8 header_checksum;
};

bitfield BlockSize {
    size         : 31;
    uncompressed : 1;
};

struct DataBlock<auto block_checksum_present> {
    BlockSize size;

    u8 data[size.size];
    if (block_checksum_present) {
        u32 block_checksum;
    }
};

struct StandardFrame {
    FrameDescriptor descriptor;
    
    DataBlock<descriptor.flg.block_checksum_present> blocks[while($ + 4 <= std::mem::size() && std::mem::read_unsigned($, 4) != 0)];

    if ($ + 4 <= std::mem::size()) {
        u32 end_mark;
        std::assert(end_mark == 0x00000000, "Invalid EndMark");
    }

    if (descriptor.flg.content_checksum_present && $ + 4 <= std::mem::size()) {
        u32 content_checksum;
    }
};

struct SkippableFrame {
    u32 frame_size;
    u8 user_data[frame_size];
};

struct LegacyBlock {
    u32 compressed_size;
    u8 data[compressed_size];
};

struct LegacyFrame {
    LegacyBlock blocks[while($ + 4 <= std::mem::size() && std::mem::read_unsigned($, 4) != 0x184D2204 && std::mem::read_unsigned($, 4) != 0x184C2102 && (std::mem::read_unsigned($, 4) & 0xFFFFFFF0) != 0x184D2A50)];
};

struct Frame {
    MagicNumber magic;
    
    if (magic == MagicNumber::Standard) {
        StandardFrame frame;
    } else if (magic == MagicNumber::Legacy) {
        LegacyFrame frame;
    } else if ((u32(magic) & 0xFFFFFFF0) == 0x184D2A50) {
        SkippableFrame frame;
    } else {
        std::error("Unknown Magic Number");
    }
};

Frame frames[while($ < std::mem::size())] @ 0x00;
