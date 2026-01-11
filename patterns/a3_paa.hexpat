#pragma author MrClock
#pragma description Arma 3 PAA image format

#pragma endian little

#pragma MIME image/x.a3-paa

import type.color;
import std.mem;
import std.sys;

struct Color<auto alpha> {
    u8 b;
    u8 g;
    u8 r;
    if (alpha) u8 a;
} [[sealed, format("type::impl::format_color"), color(std::format("{0:02X}{1:02X}{2:02X}", r, g, b))]];

using BGR8 = Color<false>;
using BGRA8 = Color<true>;

enum PixelFormat: u16 {
    DXT1 = 0xFF01,
    DXT2 = 0xFF02,
    DXT3 = 0xFF03,
    DXT4 = 0xFF04,
    DXT5 = 0xFF05,
    RGBA4 = 0x4444,
    RGBA5 = 0x1555,
    RGBA8 = 0x8888,
    GRAY = 0x8080
};

enum AlphaMode: u32 {
    NONE = 0,
    INTERPOLATED = 1,
    BINARY = 2
};

enum Swizzle: u8 {
    ALPHA = 0,
    RED = 1,
    GREEN = 2,
    BLUE = 3,
    INVERTED_ALPHA = 4,
    INVERTED_RED = 5,
    INVERTED_GREEN = 6,
    INVERTED_BLUE = 7,
    BLANK_WHITE = 8,
    BLANK_BLACK = 9
};

struct Tagg {    
    char signature[8];
    u32 length;
    
    match (signature) {
        ("GGATCGVA"): BGRA8 color;
        ("GGATCXAM"): BGRA8 color;
        ("GGATGALF"): AlphaMode alpha;
        ("GGATSFFO"): u32 offsets[16];
        ("GGATZIWS"): Swizzle copies[4];
        (_): u8 data[length];
    }    
} [[format("format_tagg_name")]];

struct Palette {
    u16 length;
    BGR8 colors[length];
};

struct Mipmap {
    u16 width_and_lzo [[format("format_width_lzo")]];
    u16 height;
    
    u16 width = width_and_lzo & 0x7FFF;
    
    if (width == 0 && height == 0) {
        break;
    }
    
    u24 size;
    u8 data[size];
} [[format("format_resolution")]];

struct PAA {
    PixelFormat format;
    Tagg taggs[while(std::mem::read_string($, 4) == "GGAT")];
    Palette palette;
    Mipmap mipmaps[while(true)];
    u16 EOF;
    
    std::assert_warn(EOF == 0, "Invalid EOF sentinel");
};

fn format_resolution(ref auto mip) {
    return std::format("{0:d} x {1:d}", mip.width, mip.height);
};

fn format_width_lzo(u16 value) {
    u16 width = value & 0x7FFF;
    if (value & 0x8000) {
        return std::format("{0:d} (+LZO)", width);
    } else {
        return std::format("{0:d}", width);
    }
};

fn format_tagg_name(Tagg data) {
    match (data.signature) {
        ("GGATCGVA"): return "Average color";
        ("GGATCXAM"): return "Max color";
        ("GGATGALF"): return "Alpha flag";
        ("GGATZIWS"): return "Swizzle";
        ("GGATSFFO"): return "Mipmap offsets";
        (_): return "Unknown";
    }
};

PAA file @ 0x0000;
