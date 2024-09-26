#pragma description Blender file
#pragma magic [42 4C 45 4E 44 45 52] @ 0x00

/*
 * References:
 * https://projects.blender.org/blender/blender
 *
 * Refer to the following files/structs:
 * source/blender/blenloader/intern/writefile.cc
 * source/blender/blenkernel/BKE_main.hh BlendThumbnail
 * source/blender/makesdna/DNA_sdna_types.h BHead
 */

// Increased the pattern limit to be able to evaluate all pixels of the embedded thumbnail.
#pragma pattern_limit 1000000

import std.core;
import std.io;
import std.mem;
import std.string;
import std.sys;
import type.color;
import type.magic;

// Useful for extracting the thumbnail if the rest of the blend file is corrupted or truncated.
bool quitAfterThumbnailIsParsed in;
// Allow the pattern evaluator to skip the thumbnail e.g. if evaluation takes too long.
bool skipThumbnail in;

struct BHead<Ptr> {
    char code[4];
    s32 len;
    Ptr old;
    s32 SDNAnr; 
    s32 nr;

    // ENDB marks the last data block in the file.
    if (code == "ENDB") {
        break;
    }
};

struct ThumbnailLine<auto width> {
    type::RGBA8 pixels[width];
};

fn copyThumbnail(u32 height, ref auto lines, std::mem::Section target) {
    for (s64 l = (height - 1), l >= 0, l = l - 1) {
        u64 currentSectionSize = std::mem::get_section_size(target);
        // Append the current line to section.
        std::mem::copy_value_to_section(lines[l], target, currentSectionSize);
    }
};

struct Thumbnail {
    u32 width;
    u32 height;
    u128 size = width * height;
    ThumbnailLine<width> lines[height];

    // Generate the thumbnail section.
    std::mem::Section thumbnailFlipped = std::mem::create_section("thumbnail");
    copyThumbnail(height, lines, thumbnailFlipped);
    type::RGBA8 image[size] @ 0x00 in thumbnailFlipped;
}
#ifdef __IMHEX__
[[hex::visualize("bitmap", image, width, height)]]
#endif
;

struct DataBlock<Ptr> {
    BHead<Ptr> bHead;

    if (bHead.SDNAnr == 0 && bHead.code == "TEST") {
        if (skipThumbnail) {
            u8 thumbnail[bHead.len]; // Interpret as raw binary data.
        } else {
            Thumbnail thumbnail;
            auto thumbnailSize = sizeof(thumbnail);
            std::assert(thumbnailSize == bHead.len,
                std::format("The thumbnail (size={:#x}) does not fit exactly into its DataBlock (len={:#x})!",
                            thumbnailSize, bHead.len));
        }

        if (quitAfterThumbnailIsParsed) {
            break;
        }
    } else {
        u8 data[bHead.len]; // Unknown. Interpret as raw binary data.
    }
};

enum PointerSize : char {
    POINTER_4BYTE = '_',
    POINTER_8BYTE = '-'
};

enum Endianness : char {
    BIG_ENDIAN = 'V',
    LITTLE_ENDIAN = 'v'
};

struct Blend {
    type::Magic<"BLENDER"> magic;
    PointerSize pointerSize;
    Endianness endianness;
    char version[3];

    match (endianness) {
        (Endianness::LITTLE_ENDIAN): std::core::set_endian(std::mem::Endian::Little);
        (Endianness::BIG_ENDIAN): std::core::set_endian(std::mem::Endian::Big);
        (_): std::error("Invalid value for endianness!");
    }

    match (pointerSize) {
        (PointerSize::POINTER_4BYTE): DataBlock<u32> dataBlock[while($ < sizeof($))];
        (PointerSize::POINTER_8BYTE): DataBlock<u64> dataBlock[while($ < sizeof($))];
        (_): std::error("Invalid pointer size!");
    }
};

char magic[4] @ 0x00 [[hidden]];

if (magic == "\x28\xB5\x2F\xFD") { // ZSTD magic
    std::error("ZSTD compressed blend files are not supported!");
}

Blend blend @ 0x00;