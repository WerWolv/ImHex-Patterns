#pragma author DmitriLeon2000
#pragma description Oska Software DeskMates FAS (Frames and Sequences)
#pragma endian little

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
    char name[50]; // name of the pack, may include garbage data
    u16 version; // Format version number
    s16 frameIDFirst; // assigned ID of the first frame
    s16 frameIDLast; // assigned ID of the last frame
    s32 width; // width of the animation (in pixels)
    s32 height; // height of the animation (in pixels)
    u16 frameSize; // size of the animation ((frameWidth * BPP + 31) // 32 * 4 * frameHeight)
    u16 DblHeaderCount; // amount of BitmapInfoHeader pairs (one for color, one for masking)
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
    Colors colorMap[header.biClrUsed == 0 ?
        1 << header.biBitCount : header.biClrUsed];
};

struct ExtraSprite {
    char name[];
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

struct Bitmap {
    u8 byte[parent.fasHeader.version >= 3 ? parent.fasHeader.frameSize + (parent.frameSizeHigh << 16) : parent.fasHeader.frameSize] [[sealed]];
};

struct FramesHeader {
    le u32 count;
    le s16 frameID[count];
    u8     frameDblHdrID[count];
};

struct FAS {
    FASHeader fasHeader;
    BitmapInfo dibHeaders[fasHeader.DblHeaderCount * 2];
        if (fasHeader.version >= 1)
        u8 charID;
    if (fasHeader.version >= 2)
    {
        u32 extraEndOffset;
        u16 extraSpritesCount;
        if (extraSpritesCount)
            // char extraSpriteList[touchOffset - 6];
            ExtraSprite extraSprites[extraSpritesCount];
    }
    if (fasHeader.version >= 3)
      le u16 frameSizeHigh;
    le u16 touchColors;
    if (touchColors)
    {
        u32 touchColorMap[touchColors];
        u16 touchWidth;
        u8 touchBitmap[this.touchWidth * fasHeader.height];
    }
    SeqHeader seqHeader;
    if (fasHeader.version >= 1)
        u8 filenameChecksum; // a checksum for a filename in ASCII
    AnimSequence sequences[seqHeader.count];
    FramesHeader framesHeader;
    Bitmap framesBitmap[framesHeader.count];
};

FAS fas @ 0x00;
