#pragma author itsmeow
#pragma description BYOND Resource Cache file

import std.mem;
import std.time;
import std.hash;

// Whether to validate CRC32 for RSCEntries or not.
const bool check_crc = true;

using time_t = std::time::EpochTime [[format("format_unix_time")]];
fn format_unix_time(time_t t) {
    return std::time::format(std::time::to_local(t), "%c");
};

// Based on alexkar598/rsc-tools
// Copyright (c) alexkar598
// Permissioned granted for use in pattern
enum Type : u8 {
  // Unknown file
  Unknown = 0x0,
  // Sequencer file (.mid, .midi, .mod, .s3m, .xm, .it, .oxm)
  Sequencer = 0x1,
  // Audio file (.wav, .ogg, .raw, .wma, .aiff, .mp3)
  Audio = 0x2,
  // Sprite sheet file (.dmi)
  SpriteSheet = 0x3,
  // Bitmap file (.bmp)
  Bitmap = 0x5,
  // Lossless image file (.png)
  LosslessImage = 0x6,
  // Archive file (.zip)
  Archive = 0x9,
  // Resource archive file (.rsc)
  Resource = 0xa,
  // Lossy image file (.jpg, .jpeg)
  LossyImage = 0xb,
  // Dynamic sprite sheet file (.ddmi)
  DynamicSpriteSheet = 0xc,
  // Animated image file (.gif)
  AnimatedImage = 0xd,
  // Font file (.ttf)
  Font = 0xe,
};

struct RSCEntry {
    u32 byteLength [[comment("Size of the entry, starting after this field")]];
    u8 used [[comment("Whether or not this entry is used in the DMB. This is updated on a rebuild to 'skip' now unused entries")]];
    if(used) {
        u8 type_raw;
        Type type = type_raw [[export]];
        bool encrypted = (type_raw & 0b10000000) == 0b10000000 [[export, comment("Encrypted entries are unable to have their content decoded at this time")]];
        u32 checksum_crc32 [[comment("CRC32 of content array with a poly of 0xaf and a XOR-in/init of 0xffffffff")]];
        time_t modified [[comment("Unix/epoch timestamp of modification datetime")]];
        time_t added [[comment("Unix/epoch timestamp of creation/addition to RSC datetime")]];
        u32 contentLength [[comment("Length of the content array")]];
        char filename[] [[comment("Name of the source file")]];
              
        u32 expectedContentLength = byteLength - 17 - sizeof(filename);
        // Use the encoded length rather than computed length
        // because this is what is used for checksum calculation
        u8 content [contentLength];
        if (contentLength < expectedContentLength) {
            // continue to end of block
            // RSC files can contain leftover data, much like a filesystem with unlinked files
            padding [expectedContentLength - contentLength];
        }
        if (expectedContentLength != contentLength) {
            u32 computedByteLength = contentLength + 17 + sizeof(filename);
            std::warning(std::format("Length mismatch for RSCEntry at 0x{:x}: contentLength={} expectedContentLength={} byteLength={} computedByteLength={}", $, contentLength, expectedContentLength, byteLength, computedByteLength));
        }
        if (check_crc) {
            u32 computed_checksum_crc32 = std::hash::crc32(content, 0xffffffff, 0xaf, 0, false, false) [[export]];
            if(computed_checksum_crc32 != checksum_crc32) {
                std::warning(std::format("Checksum mismatch at 0x{:x}: stored={} computed={}", $, checksum_crc32, computed_checksum_crc32));
            }
        }
    } else {
        u8 content [ byteLength ];
    }
};

RSCEntry entries[while(!std::mem::eof())] @ 0x00;