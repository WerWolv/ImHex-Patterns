#pragma author MrClock
#pragma description Arma 3 texture index file format

#pragma endian little

#pragma MIME application/x.a3-texheaders

fn get_data_description() {
    return "TexHeaders.bin files are texture index files used in Arma 3 PBO archives.\nThe files are generated during the PBO packing process, and contain basic information about all the PAA texture files in the PBO.\nThe index for each texture includes the file paths relative to the PBO root, pixel format, suffix, number of mipmaps and their resolutions among other things.";
};

import std.string;
import std.math;
import type.color;

using asciiz = std::string::NullString;

struct BGRA8 {
    u8 b;
    u8 g;
    u8 r;
    u8 a;
} [[
    static,
    sealed,
    format("type::impl::format_color"),
    color(std::format("{0:02X}{1:02X}{2:02X}", r, g, b))
]];

struct RGBAfloat {
    float r [[transform("float2u8")]];
    float g [[transform("float2u8")]];
    float b [[transform("float2u8")]];
    float a [[transform("float2u8")]];
} [[
    static,
    sealed,
    format("type::impl::format_color"),
    color(std::format("{0:02X}{1:02X}{2:02X}", r, g, b))
]];

enum PixelFormat: u8 {
    INDEXED = 0,
    GRAY = 1,
    RGB565 = 2,
    RGBA5551 = 3,
    RGBA4444 = 4,
    RGBA8888 = 5,
    DXT1 = 6,
    DXT2 = 7,
    DXT3 = 8,
    DXT4 = 9,
    DXT5 = 10
};

enum Suffix: u32 {
    DEFAULT = 0,
    DIFFUSE_LINEAR = 1,
    DETAIL = 2,
    NORMAL = 3,
    IRRADIANCE = 4,
    RANDOM = 5,
    TREECROWN = 6,
    MACRO = 7,
    SHADOW = 8,
    SPECILAR = 9,
    DITHERING = 10,
    DETAIL_SPECULAR = 11,
    MASK = 12,
    THERMAL = 13
};

struct Mipmap {
    u16 width;
    u16 height;
    padding[2];
    PixelFormat format;
    padding[1];
    u32 offset [[comment("Byte offset in file")]];
} [[static,format("formatMipmap")]];

struct Texture {
    u32 count_color_pallets [[comment("Always 1")]];
    u32 pallet_pointer [[comment("Always 0")]];
    RGBAfloat average_color_float;
    BGRA8 average_color;
    BGRA8 max_color;
    u32 clamp_flags [[comment("Always 0")]];
    u32 transparency [[comment("Always 0xffffffff")]];
    bool maxcolor_defined [[comment("GGATCXAM was found in PAA")]];
    bool alpha_interpolated;
    bool alpha_binary;
    bool non_opaque [[comment("Interpolated alpha and average alpha < 127")]];
    u32 count_mipmaps;
    /*
    Technically the format is listed as u32 on the community wiki, but
    for the sake of reusability in the Mipmap struct, it is broken up into
    a u8 + 3 padding bytes here. (The enum values are in the u8 range
    anyway.)
    */
    PixelFormat format;
    padding[3];
    bool little_endian [[comment("Always true")]];
    bool is_paa [[comment("File is PAA not PAC")]];
    asciiz path [[comment("Path relative to texHeaders.bin file")]];
    Suffix suffix;
    u32 count_mipmaps_again;
    Mipmap mipmaps[count_mipmaps];
    u32 filesize;
}[[format("formatTexture")]];

struct TexHeaders {
    char signature[4];
    u32 version [[comment("Always 1")]];
    u32 count_textures;
    Texture textures[count_textures];
};

fn float2u8(float value) {
    return u8(std::math::round(value * 255));
};

fn formatMipmap(ref Mipmap mip) {
    return std::format("{0:d} x {1:d}", mip.width, mip.height);
};

fn formatTexture(ref Texture tex) {
    return std::format("{0:d} x {1:d} @ {2:s}", tex.mipmaps[0].width, tex.mipmaps[0].height, tex.path);
};

TexHeaders file @ 0x0000;
