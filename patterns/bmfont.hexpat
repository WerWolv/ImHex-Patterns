#pragma description AngelCode BMFont binary font descriptor
#pragma endian little
#pragma magic [ 42 4D 46 03 ] @ 0x00

// Format reference: https://www.angelcode.com/products/bmfont/doc/file_format.html
// The binary version written by BMFont 1.10 and later (version 3). Text and
// XML descriptors use the same .fnt extension but are not covered here.

import std.io;
import std.mem;
import std.sys;

struct NullString {
    char value[];
} [[sealed, format("format_null_string")]];

fn format_null_string(ref NullString s) {
    return std::format("\"{}\"", s.value);
};

enum BlockType : u8 {
    Info = 1,
    Common = 2,
    Pages = 3,
    Chars = 4,
    KerningPairs = 5
};

// The spec numbers these bits from the most significant one, so bit 0 is 0x80.
bitfield InfoFlags {
    padding : 3;
    fixed_height : 1;
    bold : 1;
    italic : 1;
    unicode : 1;
    smooth : 1;
};

struct InfoBlock {
    s16 font_size [[comment("Negative when the size matches character height instead of cell height")]];
    InfoFlags flags;
    u8 charset [[comment("OEM charset when not unicode")]];
    u16 stretch_h [[comment("Height stretch in percent")]];
    u8 antialiasing [[comment("Supersampling level, 1 = none")]];
    u8 padding_up;
    u8 padding_right;
    u8 padding_down;
    u8 padding_left;
    u8 spacing_horizontal;
    u8 spacing_vertical;
    u8 outline;
    NullString font_name;
};

bitfield CommonFlags {
    padding : 7;
    packed : 1 [[comment("Monochrome characters packed in each texture channel")]];
};

enum ChannelContent : u8 {
    Glyph = 0,
    Outline = 1,
    GlyphAndOutline = 2,
    Zero = 3,
    One = 4
};

struct CommonBlock {
    u16 line_height;
    u16 base [[comment("Distance from the top of the line to the baseline")]];
    u16 scale_w [[comment("Texture width")]];
    u16 scale_h [[comment("Texture height")]];
    u16 pages;
    CommonFlags flags;
    ChannelContent alpha_channel;
    ChannelContent red_channel;
    ChannelContent green_channel;
    ChannelContent blue_channel;
};

bitfield CharChannel {
    blue : 1;
    green : 1;
    red : 1;
    alpha : 1;
    padding : 4;
} [[comment("15 means all channels")]];

struct Char {
    u32 id [[comment("Character code")]];
    u16 x;
    u16 y;
    u16 width;
    u16 height;
    s16 x_offset;
    s16 y_offset;
    s16 x_advance;
    u8 page;
    CharChannel channel;
} [[format("format_char")]];

fn format_char(ref Char c) {
    if (c.id >= 0x20 && c.id < 0x7F)
        return std::format("'{}' ({}x{} at {}, {})", char(c.id), c.width, c.height, c.x, c.y);
    return std::format("U+{:04X} ({}x{} at {}, {})", c.id, c.width, c.height, c.x, c.y);
};

struct KerningPair {
    u32 first;
    u32 second;
    s16 amount;
};

struct Block {
    BlockType block_type;
    u32 size [[comment("Size of the block data, not counting this 5 byte header")]];
    u64 end = $ + size;

    match (block_type) {
        (BlockType::Info): InfoBlock data;
        (BlockType::Common): CommonBlock data;
        (BlockType::Pages): NullString page_names[while($ < end)] [[comment("Texture file names, all the same length")]];
        (BlockType::Chars): Char chars[size / 20];
        (BlockType::KerningPairs): KerningPair pairs[size / 10];
        (_): u8 data[size];
    }

    if ($ < end)
        padding[end - $];
} [[format("format_block")]];

fn format_block(ref Block b) {
    return std::format("{}", b.block_type);
};

struct BMFont {
    char magic[3];
    std::assert(magic == "BMF", "Not a binary BMFont file");
    u8 version;
    std::assert(version == 3, "Only version 3 of the binary format is supported");
    Block blocks[while(!std::mem::eof())];
};

BMFont font @ 0x00;
