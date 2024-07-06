#pragma author Surasia
#pragma description Halo Infinite Module
#pragma array_limit 4294967295
#pragma pattern_limit 4294967295

import std.string;

struct ModuleHeader 
{
    char magic[4];
    s32 version;
    s64 moduleId;
    u32 fileCount;
    s32 manifest0Count;
    s32 manifest1Count;
    s32 manifest2Count;
    s32 resourceIndex;
    u32 stringSize;
    u32 resourceCount;
    u32 blockCount;
    u64 buildVersion;
    s64 hd1Delta;
    u64 dataSize;
};


struct ModuleFile
{
    u32 resourceCount;
    s32 parentIndex;
    s16 pad;
    u16 blockCount;
    s32 blockIndex;
    s32 resourceIndex;
    char class[4] [[format("std::string::reverse")]];
    u64 dataOffsetBytes;
    u64 dataOffset = dataOffsetBytes & 0x0000FFFFFFFFFFFF [[export]];
    u16 dataOffsetFlags = dataOffsetBytes >> 48 [[export]];
    u32 totalCompressedSize;
    u32 totalUncompressedSize;
    u32 globalTagId;
    u32 uncompressedHeaderSize;
    u32 uncompressedTagDataSize;
    u32 uncompressedResourceDataSize;
    u32 uncompressedActualResourceDataSize;
    u32 resourceBlockCount;
    u32 nameOffset;
    s32 parentResource;
    u64 assetChecksum;
    u64 assetId;
};


struct ModuleBlock
{
    u32 compressedOffset;
    u32 compressedSize;
    u32 decompressedOffset;
    u32 decompressedSize;
    bool compressed;
    s24 pad;
};


struct Module
{
    ModuleHeader module_header;
    ModuleFile files[module_header.fileCount];
    $ = $ + 8;
    s32 resources[module_header.resourceCount];
    ModuleBlock blocks[module_header.blockCount]; 
    padding[while($[$] == 0)];
    std::print("Compressed Tag Data starts at: {}", $);
};


Module module_root @ 0x00;