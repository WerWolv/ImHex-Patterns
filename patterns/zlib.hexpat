#pragma description ZLIB compressed data

#pragma MIME application/zlib

import std.core;
import std.sys;

#define HEADER_SIZE 2
#define CSUM_SIZE 4

using BitfieldOrder = std::core::BitfieldOrder;

/// Entire stream minus header (2) and checksum (4)
u64 data_len = std::mem::size();

if (data_len > (HEADER_SIZE + CSUM_SIZE)) {
    data_len -= (HEADER_SIZE + CSUM_SIZE);
} else {
    data_len = 0;
}

/// Compression method; only Deflate is used
enum CM: u8 {
    Deflate = 8,
    Reserved = 15,
};

/// Compression level
enum Level: u8 {
    Fastest = 0,
    Fast = 1,
    Default = 2,
    Smallest = 3, // slowest
};

// Compression method & flags
bitfield Header {
    CM method : 4;
    info: 4;
    fcheck: 5;
    bool fdict: 1;
    Level flevel: 2;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];


/// Validate the header's checksum
fn validate_hdr_checksum(Header hdr) {
    // Reassemble as a 2-byte big endian value
    u16 value = (
        (u8(hdr.method) << 8) +
        (hdr.info << 12) +
        (hdr.fcheck << 0) +
        (hdr.fdict << 5) +
        (u8(hdr.flevel) << 6)
    );

    if (value % 31 == 0) {
        std::print("Zlib header checksum OK. Value: {}", value);
    } else {
        std::warning(std::format("Zlib header checksum failed! Value: {}", value));
    }
};

/// Representation of a Zlib stream
struct Zlib {
    /// Configuration
    Header header;

    if (header.fdict) {
        /// Adler checksum of the optional dictionary
        u32 dict;
    }

    /// Compressed data
    u8 data[data_len];
    /// Adler-32 checksum of uncompressed data
    u32 checksum;
};


// start parsing at the beginning of stream
Zlib zlib @ 0x00;

// Only mode 8 (deflate) is recognized
std::assert_warn(
    zlib.header.method == CM::Deflate,
    "Unrecognized compression method"
);

validate_hdr_checksum(zlib.header);
