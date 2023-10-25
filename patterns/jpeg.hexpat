#pragma author WerWolv
#pragma description JPEG Image Format

#include <std/mem.pat>
#include <type/magic.pat>
#pragma endian big

#pragma MIME image/jpeg

enum Marker : u8 {
    TEM     = 0x01,
    SOF0    = 0xC0,
    SOF1    = 0xC1,
    SOF2    = 0xC2,
    SOF3    = 0xC3,
    DHT     = 0xC4,
    SOF5    = 0xC5,
    SOF6    = 0xC6,
    SOF7    = 0xC7,
    SOI     = 0xD8,
    EOI     = 0xD9,
    SOS     = 0xDA,
    DQT     = 0xDB,
    DNL     = 0xDC,
    DRI     = 0xDD,
    DHP     = 0xDE,
    APP0    = 0xE0,
    APP1    = 0xE1,
    APP2    = 0xE2,
    APP3    = 0xE3,
    APP4    = 0xE4,
    APP5    = 0xE5,
    APP6    = 0xE6,
    APP7    = 0xE7,
    APP8    = 0xE8,
    APP9    = 0xE9,
    APP10   = 0xEA,
    APP11   = 0xEB,
    APP12   = 0xEC,
    APP13   = 0xED,
    APP14   = 0xEE,
    APP15   = 0xEF,
    COM     = 0xFE
};

enum DensityUnit : u8 {
    NoUnit = 0x00,
    PixelsPerInch = 0x01,
    PixelsPerCm = 0x02
};

struct Pixel {
    u8 r, g, b;
} [[sealed, transform("transform_pixel")]];

fn transform_pixel(Pixel pixel) {
    return (0xFF << 24) | (pixel.b << 16) | (pixel.g << 8) | (pixel.r << 0);
};


struct APP0 {
    type::Magic<"JFIF\x00"> magic;
    u8 versionMajor, versionMinor;
    DensityUnit densityUnit;
    u16 densityX, densityY;
    u8 thumbnailX, thumbnailY;
    Pixel thumbnail[thumbnailX * thumbnailY] [[sealed]];
};

enum ComponentId : u8 {
    Y   = 1,
    CB  = 2,
    CR  = 3,
    I   = 4,
    Q   = 5
};

struct SOF0Component {
    ComponentId componentId;
    u8 samplingFactors;
    u8 quantizationTableId;
};

struct SOF0 {
    u8 bitsPerSample;
    u16 imageHeight, imageWidth;
    u8 numComponents;
    SOF0Component components[numComponents];
};

struct SOSComponent {
    ComponentId componentId;
    u8 huffmanTable;
};

struct SOS {
    u8 numComponents;
    SOSComponent components[numComponents];
    u8 startSpectralSelection;
    u8 endSpectral;
    u8 apprBitPos;
    
    u8 image_data[std::mem::size() - $ - 2] [[sealed]];
};

struct Segment {
    type::Magic<"\xff"> magic;
    Marker marker;
    
    if (marker == Marker::SOI || marker == Marker::EOI) {
        
    } else {
        u16 length;
        if (marker == Marker::APP0) {
            APP0 data;
        } else if (marker == Marker::SOF0) {
            SOF0 data;
        } else if (marker == Marker::SOS) {
            SOS data;
        } else {
            u8 data[length - sizeof(length)] [[sealed]];
        }
    }
};

Segment segments[while(!std::mem::eof())] @ 0x00 [[hex::visualize("image", this)]];