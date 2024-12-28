#pragma author Shadlock0133 (aka Aurora) / WerWolv
#pragma description Prusa Binary G-Code

import type.magic;
import std.mem;

enum ChecksumType : u16 {
    None = 0,
    CRC32 = 1
};

enum BlockType : u16 {
    FileMetadata = 0,
    GCode = 1,
    SlicerMetadata = 2,
    PrinterMetadata = 3,
    PrintMetadata = 4,
    Thumbnail = 5
};

enum CompressionType : u16 {
    NoCompression = 0,
    Deflate = 1,
    HeatshrinkWindowSize11 = 2,
    HeatshrinkWindowSize12 = 3
};

struct BlockHeader {
    BlockType type;
    CompressionType compressionType;
    u32 uncompressedSize;
    
    if (compressionType != CompressionType::NoCompression) {
        u32 compressedSize;
    }
    
    u32 dataSize = compressionType == CompressionType::NoCompression ? uncompressedSize : compressedSize;
};

enum Encoding : u16 {
    INI = 0
};

struct Metadata {
    Encoding encoding;
    char data[parent.header.dataSize];
};

enum ImageFormat : u16 {
    PNG = 0,
    JPG = 1,
    QOI = 2
};

struct Thumbnail {
    ImageFormat format;
    u16 width, height;
    std::mem::Bytes<parent.header.dataSize> imageData;
} [[hex::visualize("image", imageData)]];

enum GCodeEncoding : u16 {
    NoEncoding = 0,
    MeatPack = 1,
    MeatPackWithComments = 2
};

struct GCode {
    GCodeEncoding encoding;
    
    std::mem::Bytes<parent.header.dataSize> gcode;
};

struct Block {
    BlockHeader header;
    
    match (header.type) {
        (BlockType::FileMetadata):    Metadata fileMetadata;
        (BlockType::PrinterMetadata): Metadata printerMetadata;
        (BlockType::Thumbnail):       Thumbnail thumbnail;
        (BlockType::PrintMetadata):   Metadata printMetadata;
        (BlockType::SlicerMetadata):  Metadata slicerMetadata;
        (BlockType::GCode):           GCode gcode;
        (_):                          std::error("Invalid Block type!");
    }
    
    if (parent.checksumType != ChecksumType::None)
        u32 checksum;
};

struct BGCode {
    type::Magic<"GCDE"> magic;
    u32 version;
    std::assert(version == 1, "Only Version 1 is supported");
    
    ChecksumType checksumType;
    
    Block blocks[while(!std::mem::eof())];
};

BGCode bgcode @ 0x00;