#pragma author Lexi Mayfield
#pragma description KEX Engine TARC format
#pragma magic [0x54 0x41 0x52 0x43] @ 0x00

enum PixelFormat : u16 {
    DXT1 = 14,
    DXT5 = 16,
    BC7 = 33,
};

struct TARCEntry1 {
    char fileName[64];
    u64 offset;
    u32 size;
    u16 width;
    u16 height;
    u16 numMipMaps;
    PixelFormat pixelFormat;
};

struct TARCEntry2 {
    char fileName[64];
    u64 offset;
    u32 size;
    u16 x;
    u16 y;
    u16 width;
    u16 height;
    u16 numMipMaps;
    PixelFormat pixelFormat;
    u16 origWidth;
    u16 origHeight;
    s16 offsetX;
    s16 offsetY;
};

struct TARC {
    char id[4];
    u32 version;
    u32 numEntries;
    u64 pixelDataOffset;
    
    if (version == 1) {
        TARCEntry1 entries[numEntries];
    } else if (version == 2) {
        TARCEntry2 entries[numEntries];
    }
};

TARC tarc @ 0x00;