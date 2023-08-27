#pragma description PCX Image format

#pragma MIME application/x-pcx

#include <std/io.pat>

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

PCX pcx @ 0x00;