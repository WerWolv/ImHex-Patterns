#pragma description Assassin's Creed: Unity's Compressed .data file
#pragma MIME archives/data

// author = haru233, many thanks to AxCut
// ImHex Hex Pattern File for Assassin's Creed: Unity's Compressed .data files


import std.core;
import std.mem;

enum CompressionType : u8 {
    LZO1X_ = 0x00, // Both 0x00 and 0x01 mean LZO1X
    LZO1X = 0x01,
    LZO2A = 0x02,
    xmemdecompress = 0x03,
    LZO1C = 0x05
};

struct CHUNK {
    u16 Uncompressed_Size;
    u16 Compressed_Size;
};

struct CHUNK_Data {
    u32 Hash;
    
    u64 i = std::core::array_index();
    u8 data[parent.chunk[i].Compressed_Size];
};

struct PACK {
    u64 ID;
    padding[2];
    CompressionType Compression_Type;
    padding[3];
    u8 Version;
    u16 CHUNK_Count;
    
    CHUNK chunk[CHUNK_Count];
    CHUNK_Data data[CHUNK_Count];

    
};



PACK pack[while(!std::mem::eof())] @0x00;

