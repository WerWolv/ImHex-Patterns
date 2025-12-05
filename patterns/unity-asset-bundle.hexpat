#pragma author Khoo Hao Yit
#pragma description Unity Asset Bundle

#pragma magic [ "UnityWeb\0" ] @ 0x00
#pragma magic [ "UnityRaw\0" ] @ 0x00
#pragma magic [ "UnityArchive\0" ] @ 0x00
#pragma magic [ "UnityFS\0" ] @ 0x00
#pragma endian big

// Reference:
// https://archive.vg-resource.com/thread-43269.html
// https://github.com/K0lb3/UnityPy
// https://github.com/Perfare/AssetStudio
// https://docs.unity3d.com/550/Documentation/Manual/AssetBundleInternalStructure.html

import std.core;
import std.sys;
import hex.dec;

enum Compression: u8 {
    None = 0,
    Lzma = 1,
    Lz4 = 2,
    Lz4hc = 3,
    Lzham = 4,
};

enum Flag : u32 {
    CompressionMask                = 0b0000111111,
    BlocksAndDirectoryInfoCombined = 0b0001000000,
    BlockInfoAtTheEnd              = 0b0010000000,
    OldWebPluginCompatibility      = 0b0100000000,
    BlockInfoNeedPaddingAtStart    = 0b1000000000,
};

std::mem::Section blockData;
auto cursor = -1;

namespace v1 {
    struct Level {
        u32 compressedSize;
        u32 decompressedSize;
    };

    struct DirectoryRecord {
        char path[];
        u32 offset;
        u32 size;

        std::mem::Bytes<size> data @ offset in blockData;
    };

    struct Header {
        u32 nodeCount;
        v1::DirectoryRecord nodes[nodeCount];
    };
}

namespace v2 {
    struct BlockInfo {
        u32 decompressedSize;
        u32 compressedSize;
        u16 flags;

        u8 compressedData[compressedSize] @ cursor in 0 [[sealed, name(std::format("blockInfo{:d}", std::core::array_index()))]];
        cursor += compressedSize;

        std::mem::Section decompressedData = std::mem::create_section("decompressedData");
        match (flags & Flag::CompressionMask) {
            (_): std::unimplemented();
            (Compression::None): std::mem::copy_value_to_section(compressedData, decompressedData, 0);
            (Compression::Lzma): hex::dec::lzma_decompress(compressedData, decompressedData);
            (Compression::Lz4): hex::dec::lz4_decompress(compressedData, decompressedData, false);
            (Compression::Lz4hc): hex::dec::lz4_decompress(compressedData, decompressedData, false);
            (Compression::Lzham): std::unimplemented();
        }
        std::mem::copy_section_to_section(
            decompressedData,
            0,
            blockData,
            std::mem::get_section_size(blockData),
            std::mem::get_section_size(decompressedData)
        );
        std::mem::delete_section(decompressedData);
    };

    struct DirectoryRecord {
        s64 offset;
        s64 size;
        u32 flags;
        char path[];

        std::mem::Bytes<size> data @ offset in blockData;
    };

    struct Header {
        blockData = std::mem::create_section("BlockData");
        std::mem::Bytes<16> dataHash;
        s32 blockInfoCount;
        v2::BlockInfo blockInfos[blockInfoCount];
        u32 nodeCount;
        v2::DirectoryRecord nodes[nodeCount];
    };
}

struct AssetBundle {
    char signature[];
    u32 version;
    char unityVersion[];
    char unityRevision[];
    if (signature == "UnityArchive\0") {
        std::unimplemented();
    }
    if (signature != "UnityFS\0" && version != 6) {
        if (version >= 4) {
            std::mem::Bytes<16> hash;
            u32 crc;
        }
        u32 minimumStreamedBytes;
        u32 size;
        u32 numberOfLevelsToDownloadBeforeStreaming;
        s32 levelCount;
        v1::Level levels[levelCount];
        if (version >= 2) {
            u32 completeFileSize;
        }
        if (version >= 3) {
            u32 fileInfoHeaderSize;
        }
        $ = size;
        u8 compressedBlockInfo[levels[std::core::member_count(levels) - 1].compressedSize] [[sealed]];
        blockData = std::mem::create_section("BlockInfoAndData");
        if (signature == "UnityWeb\0") {
            hex::dec::lzma_decompress(compressedBlockInfo, blockData);
        } else {
            std::mem::copy_value_to_section(compressedBlockInfo, blockData, 0);
        }
        v1::Header header @ 0 in blockData;
        return;
    }
    s64 size;
    u32 compressedBlockInfoSize;
    u32 decompressedBlockInfoSize;
    u32 flags;
    if (signature != "UnityFS\0") {
        $ += 1;
    }
    if (version >= 7) {
        $ += -$ & 0b1111;
    }

    if (flags & Flag::BlockInfoAtTheEnd) {
        u8 compressedBlockInfo[compressedBlockInfoSize] @ std::mem::size() - compressedBlockInfo [[sealed]];
    } else {
        std::assert_warn(flags & Flag::BlocksAndDirectoryInfoCombined, "Expected BlocksAndDirectoryInfoCombined to be true");
        u8 compressedBlockInfo[compressedBlockInfoSize] [[sealed]];
    }

    if (flags & Flag::BlockInfoNeedPaddingAtStart) {
        $ += -$ & 0b1111;
    }

    std::mem::Section blockInfo = std::mem::create_section("BlockInfo");
    match (flags & Flag::CompressionMask) {
        (_): std::unimplemented();
        (Compression::None): std::mem::copy_value_to_section(compressedBlockInfo, blockInfo, 0);
        (Compression::Lzma): hex::dec::lzma_decompress(compressedBlockInfo, blockInfo);
        (Compression::Lz4): hex::dec::lz4_decompress(compressedBlockInfo, blockInfo, false);
        (Compression::Lz4hc): hex::dec::lz4_decompress(compressedBlockInfo, blockInfo, false);
        (Compression::Lzham): std::unimplemented();
    }

    cursor = $;
    v2::Header header @ 0 in blockInfo;
};

AssetBundle assetBundle @ 0;
