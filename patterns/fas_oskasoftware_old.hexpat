#pragma author DmitriLeon2000
#pragma description Oska Software DeskMates FAS (Frames and Sequences) (Oska DeskMate 1.03 and 2.06)
#pragma endian little

import std.math;

enum Compression : u32 {
    BI_RGB,
    BI_RLE8,
    BI_RLE4,
    BI_BITFIELDS,
    BI_JPEG,
    BI_PNG,
    BI_ALPHABITFIELDS,
    BI_CMYK,
    BI_CMYKRLE8,
    BI_CMYKRLE4,
};

struct Colors {
    u8 blue;
    u8 green;
    u8 red;
    u8 reserved;
};

struct FASHeader {
    s32 width; // width of the animation (in pixels)
    s32 height; // height of the animation (in pixels)
    u16 reserved1;
    u16 reserved2;
    u16 frameSizeCombined; // a sum of frameSizeColor and frameSizeMask
    u16 frameSizeColor; // size of the animation ((frameWidth * 4 + 31) // 32 * 4 * frameHeight)
    u16 frameSizeMask; // size of the animation's mask ((frameWidth * 1 + 31) // 32 * 4 * frameHeight)
    u16 headerCount; // amount of DIB headers
};

struct BitmapInfoHeader { // bog-standard BitmapInfoHeaderV1
    u32 biSize;
    s32 biWidth;
    s32 biHeight;
    u16 biPlanes;
    u16 biBitCount;
    Compression compression;
    u32 biSizeImage;
    s32 biXPelsPerMeter;
    s32 biYPelsPerMeter;
    u32 biClrUsed;
    u32 biClrImportant;
};

struct BitmapInfo {
    BitmapInfoHeader header;
    le u32 colorMap[header.biClrUsed == 0 ?
        std::math::pow(2, header.biBitCount) : header.biClrUsed];
};

struct AnimSequence {
    char name[];
    char sequence[];
};

struct SeqHeader {
    le u32       size;
    le u32       count;
    le u32       strPointers[count*2];
};

struct Frame {
    u8 colorBitmap[parent.fasHeader.frameSizeColor] [[sealed]];
    u8 maskBitmap[parent.fasHeader.frameSizeMask] [[sealed]];
};

struct FramesHeader {
    le u32 count;
    le s16 frameID[count];
};

struct FAS {
    FASHeader fasHeader;
    BitmapInfo dibHeaders[fasHeader.headerCount];
    SeqHeader seqHeader;
    AnimSequence sequences[seqHeader.count];
    FramesHeader framesHeader;
    Frame frames[framesHeader.count];
};

FAS fas @ 0x00;
