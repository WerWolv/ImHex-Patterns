#pragma author saturnaliam
#pragma description SWF file header
#pragma endian little
#include <type/magic.pat>


// RECTs are more complicated, but for the header,
// this works fine.
bitfield Rect {
    nSize : 5 [[name("N Size")]];
    signed xMin : 15 [[name("X Min")]];
    signed xMax : 15 [[name("X Max")]];
    signed yMin : 15 [[name("Y Min")]];
    signed yMax : 15 [[name("Y Max")]];
};


struct Header {
    char compressionSignature [[name("Compression"), comment("F - Uncompressed\nC - zlib Compressed\nZ - LZMA compressed")]];
    type::Magic<"WS"> signature [[name("Signature")]];
    u8 swfVersion [[name("SWF Version")]];
    u32 bytesSize [[name("Uncompressed Size")]];
    be Rect rect [[name("Frame Size"), comment("Needs to be uncompressed to have the correct value.")]];
    padding[1];
    u8 frameRate [[name("Framerate"), comment("Needs to be uncompressed to have the correct value.")]];
    u16 frameCount [[name("Frame Count"), comment("Needs to be uncompressed to have the correct value.")]];
};

Header header @ 0x00;