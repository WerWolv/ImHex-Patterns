#pragma author WerWolv
#pragma description GZip compressed data

#pragma MIME application/gzip

import type.time;
import type.size;
import std.core;
import std.mem;

using BitfieldOrder = std::core::BitfieldOrder;

bitfield Flags {
    FTEXT       : 1;
    FHCRC       : 1;
    FEXTRA      : 1;
    FNAME       : 1;
    FCOMMENT    : 1;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield ExtraFlags {
    padding : 1;
    maximumCompression : 1;
    fastestCompression : 1;
    padding : 5;
};

enum CompressionMethod : u8 {
    Reserved = 0 ... 7,
    Deflate = 8
};

enum OperatingSystemID : u8 {
    FATFileSystem = 0x00,
    Amiga = 0x01,
    VMS = 0x02,
    Unix = 0x03,
    VM_CMS = 0x04,
    AtariTOS = 0x05,
    HPFSFileSystem = 0x06,
    Macintosh = 0x07,
    ZSystem = 0x08,
    CP_M = 0x09,
    TOPS_20 = 0x0A,
    NTFSFileSystem = 0x0B,
    QDOS = 0x0C,
    AcordRISCOS = 0x0D,
    Unknown = 0xFF
};

struct GZip {
    u16 signature;
    CompressionMethod compressionMethod;
    Flags flags;
    type::time32_t modificationTime;
    ExtraFlags extraFlags;
    OperatingSystemID operatingSystemId;

    if (flags.FEXTRA) {
        u16 extraLength;
        u8 extraField[extraLength];
    }

    if (flags.FNAME) {
        char originalFileName[];
    }

    if (flags.FCOMMENT) {
        char comment[];
    }

    if (flags.FHCRC) {
        u16 crc16;
    }

    u8 data[while($ < std::mem::size() - 8)] [[sealed]];

    u32 crc32;
    type::Size<u32> isize;
};

GZip gzip @ 0x00;