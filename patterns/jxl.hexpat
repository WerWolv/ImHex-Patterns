#pragma author dxan29a
#pragma description JPEG XL Container Format

import std.io;
import std.mem;
#pragma endian big
#pragma MIME image/jxl

enum Type : u32 {
    SIGNATURE               = 0x4A584C20,   // JXL 
    FILETYPE                = 0x66747970,   // ftyp
    LEVEL                   = 0x6A786C6C,   // jxll
    JUMBF                   = 0x6A756D62,   // jumb
    EXIF                    = 0x45786966,   // Exif
    XML                     = 0x786D6C20,   // xml
    BROTILCOMPRESSED        = 0x62726F62,   // brob
    FRAMEIDX                = 0x6A786C69,   // jxlu
    CODESTREAM              = 0x6A786C63,   // jxlc
    PARTIALCODESTREAM       = 0x6A786C70,   // jxlp
    BITSTREAMRECONSTRUCTION = 0x6A627264,   // jbrd
    GAINMAPIMAGE            = 0x6872676D    // hrgm
};

struct Header {
    u32 LBox;
    u64 lbox = LBox;
    Type box_type;
    if (LBox == 1) {
        u64 XLBox;
        u64xlbox = XLBox;
    } else {
        u64 xlbox = 0;
    }
};

struct Signature {
    u32 validation;
};

struct FileType {
    u8 JXL_JXL[12];
};

struct Level {
    u8 Level;
};

struct Jumbf<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 JumbfBoxes[xlbox - 16];
    } else {
        u8 JumbfBoxes[lbox - 8];
    }
};

struct Exif<auto lbox, auto xlbox> {
    u32 tiff_header_offset;
    if (lbox == 1) {
        u8 ExifPayload[xlbox - 16 - sizeof(tiff_header_offset)];
    } else {
        u8 ExifPayload[lbox - 8 - sizeof(tiff_header_offset)];
    }
};

struct XML<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 XMLdata[xlbox - 16 - sizeof(tiff_header_offset)];
    } else {
        u8 XMLdata[lbox - 8 - sizeof(tiff_header_offset)];
    }
};

struct PartialCodeStream<auto lbox, auto xlbox> {
    u32 Index;
    if (lbox == 1) {
        u8 CodeStream[xlbox - 16 - sizeof(Index)];
    } else {
        u8 CodeStream[lbox - 8 - sizeof(Index)];
    }
};

struct BrotilCompressed<auto lbox, auto xlbox> {
    u32 PayloadTypes;
    if (lbox == 1) {
        u8 RemainingBytes[xlbox - 16 - sizeof(PayloadTypes)];
    } else {
        u8 RemainingBytes[lbox - 8 - sizeof(PayloadTypes)];
    }
};

struct FrameIndex<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 RemainingBytes[xlbox - 16];
    } else {
        u8 RemainingBytes[lbox - 8];
    }
};

struct BitStreamReconstruction<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 RemainingBytes[xlbox - 16];
    } else {
        u8 RemainingBytes[lbox - 8];
    }
};

struct GainMapImage<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 GainMapImage[xlbox - 16];
    } else {
        u8 GainMapImage[lbox - 8];
    }
};

struct UnknownBox<auto lbox, auto xlbox> {
    if (lbox == 1) {
        u8 remaining_bytes[xlbox - 16];
    } else {
        u8 remaining_bytes[lbox - 8];
    }
};

struct Box {
    Header header;
    match (header.box_type) {   
        (Type::SIGNATURE):                  Signature                                           signature;
        (Type::FILETYPE):                   FileType                                            filetype;
        (Type::LEVEL):                      Level                                               level;
        (Type::JUMBF):                      Jumbf<header.lbox, header.xlbox>                    jumbf;
        (Type::EXIF):                       Exif<header.lbox, header.xlbox>                     exif;
        (Type::PARTIALCODESTREAM):          PartialCodeStream<header.lbox, header.xlbox>        partial_codestream;
        (Type::FRAMEIDX):                   FrameIndex<header.lbox, header.xlbox>               frame_index;
        (Type::BROTILCOMPRESSED):           BrotilCompressed<header.lbox, header.xlbox>         brotil_compressed;
        (Type::BITSTREAMRECONSTRUCTION):    BitStreamReconstruction<header.lbox, header.xlbox>  bitstream_reconstruction;
        (Type::GAINMAPIMAGE):               GainMapImage<header.lbox, header.xlbox>             gain_map_image;;
        (_):                                UnknownBox<header.lbox, header.xlbox>               unknown_box;
    }
};

Box boxes[while(!std::mem::eof())] @ 0x00;