#pragma author WerWolv
#pragma description PCX Image

#pragma MIME application/x-pcx

import std.io;
import std.mem;

enum Encoding : u8 {
    NoEncoding = 0x00,
    RunLengthEncoding = 0x01
};

enum PaletteType : u16 {
    MonochromeOrColorInformation = 0x01,
    GrayscaleInformation = 0x02
};

enum Version : u8 {
    V2_5 = 0x00,
    V2_8WithPalette = 0x02,
    V2_8_WithoutPalette = 0x03,
    PaintbrushForWindows = 0x04,
    V3_0 = 0x05
};

struct Header {
    u8 magic;
    Version version;
    Encoding encoding;
    u8 bitsPerPixel;
    u16 xMin, yMin;
    u16 xMax, yMax;
    u16 hdpi, vdpi;
};

struct RGB8 {
    u8 r, g, b;
} [[sealed, color(std::format("{:02X}{:02X}{:02X}", this.r, this.g, this.b))]];

struct Palette {
    RGB8 color[16];
};

struct PCX {
    Header header;
    Palette palette;
    padding[1];
    u8 numPlanes;
    u16 bytesPerLine;
    PaletteType paletteType;
    u16 hres, vres;
    padding[54];
};

struct ExtendedPalette {
    if (std::mem::size() > sizeof(pcx) + 256*3 + 1) {
        if (std::mem::read_unsigned(std::mem::size() - 256*3 - 1, 1) == 0x0C) {
            u8 extended_palette_marker @ std::mem::size() - 256*3 - 1;
            RGB8 palette256[256] @ std::mem::size() - 256*3;
        }
    }
};


PCX pcx @ 0x00;
ExtendedPalette ExtendedPalette @ std::mem::size();
