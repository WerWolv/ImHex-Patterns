#pragma author Lexi Mayfield
#pragma description Khronos TeXture
#pragma MIME image/ktx
#pragma magic [ AB 4B 54 58 20 31 31 BB 0D 0A 1A 0A ] @ 0x00

#include "std/mem.pat"
#include "type/magic.pat"

import std.io;

enum GLType : u32 {
    compressed = 0x0,
    UNSIGNED_BYTE = 0x1401,
    BYTE = 0x1400,
    UNSIGNED_SHORT = 0x1403,
    SHORT = 0x1402,
    UNSIGNED_INT = 0x1405,
    INT = 0x1404,
    HALF_FLOAT = 0x140B,
    FLOAT = 0x1406,
    UNSIGNED_BYTE_3_3_2 = 0x8032,
    UNSIGNED_BYTE_2_3_3_REV = 0x8362,
    UNSIGNED_SHORT_5_6_5 = 0x8363,
    UNSIGNED_SHORT_5_6_5_REV = 0x8364,
    UNSIGNED_SHORT_4_4_4_4 = 0x8033,
    UNSIGNED_SHORT_4_4_4_4_REV = 0x8365,
    UNSIGNED_SHORT_5_5_5_1 = 0x8034,
    UNSIGNED_SHORT_1_5_5_5_REV = 0x8366,
    UNSIGNED_INT_8_8_8_8 = 0x8035,
    UNSIGNED_INT_8_8_8_8_REV = 0x8367,
    UNSIGNED_INT_10_10_10_2 = 0x8036,
    UNSIGNED_INT_2_10_10_10_REV = 0x8368,
    UNSIGNED_INT_24_8 = 0x84FA,
    UNSIGNED_INT_10F_11F_11F_REV = 0x8C3B,
    UNSIGNED_INT_5_9_9_9_REV = 0x8C3E,
    FLOAT_32_UNSIGNED_INT_24_8_REV = 0x8DAD,
};

enum GLFormat : u32 {
    compressed = 0x0,
    RED = 0x1903,
    RG = 0x8227,
    RGB = 0x1907,
    BGR = 0x80E0,
    RGBA = 0x1908,
    BGRA = 0x80E1,
    RED_INTEGER = 0x8D94,
    RG_INTEGER = 0x8228,
    RGB_INTEGER = 0x8D98,
    BGR_INTEGER = 0x8D9A,
    RGBA_INTEGER = 0x8D99,
    BGRA_INTEGER = 0x8D9B,
    STENCIL_INDEX = 0x1901,
    DEPTH_COMPONENT = 0x1902,
    DEPTH_STENCIL = 0x84F9,
};

enum GLInternalFormat : u32 {
    R8 = 0x8229,
    R8_SNORM = 0x8F94,
    R16 = 0x822A,
    R16_SNORM = 0x8F98,
    RG8 = 0x822B,
    RG8_SNORM = 0x8F95,
    RG16 = 0x822C,
    RG16_SNORM = 0x8F99,
    R3_G3_B2 = 0x2A10,
    RGB4 = 0x804F,
    RGB5 = 0x8050,
    RGB8 = 0x8051,
    RGB8_SNORM = 0x8F96,
    RGB10 = 0x8052,
    RGB12 = 0x8053,
    RGB16_SNORM = 0x8F9A,
    RGBA2 = 0x8055,
    RGBA4 = 0x8056,
    RGB5_A1 = 0x8057,
    RGBA8 = 0x8058,
    RGBA8_SNORM = 0x8F97,
    RGB10_A2 = 0x8059,
    RGB10_A2UI = 0x906F,
    RGBA12 = 0x805A,
    RGBA16 = 0x805B,
    SRGB8 = 0x8C41,
    SRGB8_ALPHA8 = 0x8C43,
    R16F = 0x822D,
    RG16F = 0x822F,
    RGB16F = 0x881B,
    RGBA16F = 0x881A,
    R32F = 0x822E,
    RG32F = 0x8230,
    RGB32F = 0x8815,
    RGBA32F = 0x8814,
    R11F_G11F_B10F = 0x8C3A,
    RGB9_E5 = 0x8C3D,
    R8I = 0x8231,
    R8UI = 0x8232,
    R16I = 0x8233,
    R16UI = 0x8234,
    R32I = 0x8235,
    R32UI = 0x8236,
    RG8I = 0x8237,
    RG8UI = 0x8238,
    RG16I = 0x8239,
    RG16UI = 0x823A,
    RG32I = 0x823B,
    RG32UI = 0x823C,
    RGB8I = 0x8D8F,
    RGB8UI = 0x8D7D,
    RGB16I = 0x8D89,
    RGB16UI = 0x8D77,
    RGB32I = 0x8D83,
    RGB32UI = 0x8D71,
    RGBA8I = 0x8D8E,
    RGBA8UI = 0x8D7C,
    RGBA16I = 0x8D88,
    RGBA16UI = 0x8D76,
    RGBA32I = 0x8D82,
    RGBA32UI = 0x8D70,
    COMPRESSED_RGB_S3TC_DXT1_EXT = 0x83F0,               // BC1
    COMPRESSED_RGBA_S3TC_DXT1_EXT = 0x83F1,              // BC1
    COMPRESSED_RGBA_S3TC_DXT3_EXT = 0x83F2,              // BC2
    COMPRESSED_RGBA_S3TC_DXT5_EXT = 0x83F3,              // BC3
    COMPRESSED_SRGB_S3TC_DXT1_EXT = 0x8C4C,              // BC1
    COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT = 0x8C4D,        // BC1
    COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT = 0x8C4E,        // BC2
    COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT = 0x8C4F,        // BC3
    COMPRESSED_RED_RGTC1 = 0x8DBB,                       // BC4
    COMPRESSED_SIGNED_RED_RGTC1 = 0x8DBC,                // BC4
    COMPRESSED_RG_RGTC2 = 0x8DBD,                        // BC5
    COMPRESSED_SIGNED_RG_RGTC2 = 0x8DBE,                 // BC5
    COMPRESSED_RGBA_BPTC_UNORM = 0x8E8C,                 // BC7
    COMPRESSED_SRGB_ALPHA_BPTC_UNORM = 0x8E8D,           // BC7
    COMPRESSED_RGB_BPTC_SIGNED_FLOAT = 0x8E8E,           // BC6H
    COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT = 0x8E8F,         // BC6H
    ETC1_RGB8_OES = 0x8D64,                              // ETC1
    COMPRESSED_R11_EAC = 0x9270,                         // EAC
    COMPRESSED_SIGNED_R11_EAC = 0x9271,                  // EAC
    COMPRESSED_RG11_EAC = 0x9272,                        // EAC
    COMPRESSED_SIGNED_RG11_EAC = 0x9273,                 // EAC
    COMPRESSED_RGB8_ETC2 = 0x9274,                       // ETC2
    COMPRESSED_SRGB8_ETC2 = 0x9275,                      // ETC2
    COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9276,   // ETC2
    COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = 0x9277,  // ETC2
    COMPRESSED_RGBA8_ETC2_EAC = 0x9278,                  // ETC2
    COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = 0x9279,           // ETC2
    COMPRESSED_RGBA_ASTC_4x4_KHR = 0x93B0,               // ASTC...
    COMPRESSED_RGBA_ASTC_5x4_KHR = 0x93B1,
    COMPRESSED_RGBA_ASTC_5x5_KHR = 0x93B2,
    COMPRESSED_RGBA_ASTC_6x5_KHR = 0x93B3,
    COMPRESSED_RGBA_ASTC_6x6_KHR = 0x93B4,
    COMPRESSED_RGBA_ASTC_8x5_KHR = 0x93B5,
    COMPRESSED_RGBA_ASTC_8x6_KHR = 0x93B6,
    COMPRESSED_RGBA_ASTC_8x8_KHR = 0x93B7,
    COMPRESSED_RGBA_ASTC_10x5_KHR = 0x93B8,
    COMPRESSED_RGBA_ASTC_10x6_KHR = 0x93B9,
    COMPRESSED_RGBA_ASTC_10x8_KHR = 0x93BA,
    COMPRESSED_RGBA_ASTC_10x10_KHR = 0x93BB,
    COMPRESSED_RGBA_ASTC_12x10_KHR = 0x93BC,
    COMPRESSED_RGBA_ASTC_12x12_KHR = 0x93BD,
    COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR = 0x93D0,
    COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR = 0x93D1,
    COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR = 0x93D2,
    COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR = 0x93D3,
    COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR = 0x93D4,
    COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR = 0x93D5,
    COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR = 0x93D6,
    COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR = 0x93D7,
    COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR = 0x93D8,
    COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR = 0x93D9,
    COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR = 0x93DA,
    COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR = 0x93DB,
    COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR = 0x93DC,
    COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR = 0x93DD,
};

enum GLBaseInternalFormat : u32 {
    RED = 0x1903,
    RG = 0x8227,
    RGB = 0x1907,
    BGR = 0x80E0,
    RGBA = 0x1908,
    BGRA = 0x80E1,
    RED_INTEGER = 0x8D94,
    RG_INTEGER = 0x8228,
    RGB_INTEGER = 0x8D98,
    BGR_INTEGER = 0x8D9A,
    RGBA_INTEGER = 0x8D99,
    BGRA_INTEGER = 0x8D9B,
    SRGB = 0x8C40,
    SRGB8 = 0x8C41,
    SRGB_ALPHA = 0x8C42,
    SRGB8_ALPHA8 = 0x8C43,
};

struct KeyValue {
    u32 keyAndValueByteSize;
    char keyAndValue[keyAndValueByteSize];
    std::mem::AlignTo<4>;
};
    
struct Header {
    u32 endianness;
    GLType glType;
    u32 glTypeSize;
    GLFormat glFormat;
    GLInternalFormat glInternalFormat;
    GLBaseInternalFormat glBaseInternalFormat;
    u32 pixelWidth;
    u32 pixelHeight;
    u32 pixelDepth;
    u32 numberOfArrayElements;
    u32 numberOfFaces;
    u32 numberOfMipmapLevels;
    u32 bytesOfKeyValueData;
};
        
struct MipLevel {
    u32 imageSize;
    u8 imageData[imageSize];
    std::mem::AlignTo<4>;
};

struct KhronosTexture {
    type::Magic<"\xABKTX 11\xBB\x0D\x0A\x1A\x0A"> identifier;
    Header header;
    u32 keyValueEnd = $ + header.bytesOfKeyValueData;
    KeyValue kv[while($ < keyValueEnd)];
    MipLevel mipLevels[header.numberOfMipmapLevels];
};

KhronosTexture khronosTexture @ 0x00;