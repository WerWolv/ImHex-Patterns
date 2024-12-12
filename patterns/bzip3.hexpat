#pragma author Sewer56
#pragma Parses BZip3 compression (file format) by Kamila Szewczyk
#pragma MIME application/x-bzip3
#pragma endian little
#pragma magic [42 5A 33 76 31] @ 0x00
import std.mem;

// Helper function for bit counting
fn popcount(u8 b) {
    u32 count = 0;
    while (b != 0) {
        count = count + (b & 1);
        b = b >> 1;
    }
    return count;
};

// Frame header structure
struct FrameHeader {
    char magic[5];         // "BZ3v1"
    u32 blockSize;         // Maximum block size
};

// Small block header (for blocks < 64 bytes)
struct SmallBlock {
    u32 crc32;           // CRC32 checksum
    u32 literal;         // Always 0xFFFFFFFF for small blocks
    u8 data[parent.compressedSize - 8]; // Uncompressed data
};

// Regular block (blocks > 64 bytes)
struct Block {
    u32 crc32;            // CRC32 checksum of uncompressed data
    u32 bwtIndex;         // Burrows-Wheeler transform index
    u8  model;            // Compression model flags
    
    if ((model & 0x02) != 0)     
        u32 lzpSize;      // Size after LZP compression
    if ((model & 0x04) != 0)     
        u32 rleSize;      // Size after RLE compression
        
    u8 data[parent.compressedSize - (popcount(model) * 4 + 9)];
};

// Main block structure
struct Chunk {
    u32 compressedSize;   // Size of compressed block
    u32 origSize;         // Original uncompressed size
        
    if (compressedSize < 64) {
        SmallBlock block;
    } else {
        Block block;
    }
};

// Main parsing structure
struct BZip3File {
    FrameHeader header;
    // Read blocks until end of file
    Chunk chunks[while(!std::mem::eof())];
};

BZip3File file @ 0x0;