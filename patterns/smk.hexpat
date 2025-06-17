#pragma author xZise
#pragma description Smacker video file
#pragma endian little
#pragma magic [53 4D 4B 32] @ 0x0

import std.core;
import std.io;
import std.mem;

bitfield HeaderFlags {
    ContainsRingFrame : 1;
    YInterlaced : 1;
    YDoubled : 1;
    padding : 29;
};

bitfield HeaderAudioFlags {
    isCompressed : 1;
    hasAudio : 1;
    is16BitAudio : 1;
    isStereo : 1;
    soundDecompression : 2;
    padding : 2;
    audioSampleRate : 24;
};

fn format_frame_rate(auto frame_rate) {
    float fps;
    if (frame_rate > 0) {
        fps = 1000.0 / frame_rate;
    } else if (frame_rate < 0) {
        fps = 100000.0 / (-frame_rate);
    } else {
        fps = 10;
    }
    return std::format("{} fps", fps);
};

struct Header {
  char Signature[4];
  u32 Width;
  u32 Height;
  u32 FrameCount;
  s32 FrameRate [[format("format_frame_rate")]];
  HeaderFlags Flags;
  u32 AudioSize[7];
  u32 TreesSize;
  u32 MMap_Size;
  u32 MClr_Size;
  u32 Full_Size;
  u32 Type_Size;
  HeaderAudioFlags AudioRate[7];
  padding[4];
};

fn format_size(auto size) {
    if (size.keyframe != 0) {
        return std::format("[K] {} B", size.size);
    }
    return std::format("[ ] {} B", size.size);
};

bitfield Size {
    keyframe : 1;
    padding : 1;
    dwordCount : 30;

    u32 size = dwordCount * 4;
} [[format("format_size")]];


bitfield FrameType {
    ContainsPaletteRecord : 1;
    ContainsAudioTrack0 : 1;
    ContainsAudioTrack1 : 1;
    ContainsAudioTrack2 : 1;
    ContainsAudioTrack3 : 1;
    ContainsAudioTrack4 : 1;
    ContainsAudioTrack5 : 1;
    ContainsAudioTrack6 : 1;
};

fn format_palette_copy_only(auto copy_only) {
    return std::format("copy: {0}", copy_only.copy);
};

bitfield PaletteCopyOnly {
    copy: 7;
    mode: 1;
} [[format("format_palette_copy_only")]];

fn format_palette_copy_skip(auto copy_skip) {
    return std::format("copy: {0}, skip: {1}", copy_skip.copy, copy_skip.skip);
};

bitfield PaletteCopySkip {
    copy: 6;
    mode: 2;
    skip: 8;
} [[format("format_palette_copy_skip")]];

bitfield PaletteColor {
    blue: 6 [[color("0000FF")]];
    mode: 2;
    green: 6 [[color("00FF00")]];
    padding: 2;
    red: 6 [[color("FF0000")]];
    padding: 2;

    u8 r8 = red << 2 | red >> 4;
    u8 g8 = green << 2 | green >> 4;
    u8 b8 = blue << 2 | blue >> 4;
} [[hex::inline_visualize("color", r8, g8, b8, 0xff)]];

fn format_palette_chunk_block(auto entry) {
    u8 first = entry.type;
    if (first & 0x80 == 0x80) {
        return format_palette_copy_only(entry.copy);
    } else if (first & 0x40 == 0x40) {
        return format_palette_copy_skip(entry.copy_skip);
    } else {
        return std::format("color: 0x{0:02x}{1:02x}{2:02x}", entry.color.r8, entry.color.g8, entry.color.b8);
    }
};

enum PaletteChunkBlockType: u8 {
    Color = 0x00 ... 0x3F,
    CopySkip = 0x40 ... 0x7F,
    CopyOnly = 0x80 ... 0xFF
};

// Unfortunately the match expression does not support ranges, so this is a helper for the following code:
// PaletteChunkBlockType type = std::mem::read_unsigned($, 1)
fn get_palette_chunk_block_type() {
    u8 type = std::mem::read_unsigned($, 1);
    if (type & 0x80 == 0x80) {
        return PaletteChunkBlockType::CopyOnly;
    } else if (type & 0x40 == 0x40) {
        return PaletteChunkBlockType::CopySkip;
    } else {
        return PaletteChunkBlockType::Color;
    }
};

fn get_last_position() {
    PaletteChunkBlockType type = get_palette_chunk_block_type();
    match (type) {
        (PaletteChunkBlockType::CopyOnly): return $;
        (PaletteChunkBlockType::CopySkip): return $ + 1;
        (PaletteChunkBlockType::Color): return $ + 2;
    }
};

struct PaletteChunkBlock {
    PaletteChunkBlockType type = get_palette_chunk_block_type() [[export]];
    match (type) {
        (PaletteChunkBlockType::CopyOnly): PaletteCopyOnly copy;
        (PaletteChunkBlockType::CopySkip): PaletteCopySkip copy_skip;
        (PaletteChunkBlockType::Color): PaletteColor color;
    }
} [[format("format_palette_chunk_block")]];

struct PaletteChunk {
    u8 length;
    u128 end = $ + length * 4 - 1;
    PaletteChunkBlock blocks[while(get_last_position() < end)];
    if ($ < end) {
        padding[end - $];
    }
};

struct AudioTrack<auto trackIndex> {
    u32 length;
    if (parent.parent.header.AudioRate[trackIndex].isCompressed) {
        u32 decompressedSize;
    }
    u8 trackData[length - ($ - addressof(this))];
};

struct FramesData {
    u32 frame_index = std::core::array_index();
    u32 size = parent.sizes[frame_index].size;
    if (parent.frameTypes[frame_index].ContainsPaletteRecord) {
        PaletteChunk palette;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack0) {
        AudioTrack<0> audioTrack0;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack1) {
        AudioTrack<1> audioTrack1;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack2) {
        AudioTrack<2> audioTrack2;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack3) {
        AudioTrack<3> audioTrack3;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack4) {
        AudioTrack<4> audioTrack4;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack5) {
        AudioTrack<5> audioTrack5;
    }
    if (parent.frameTypes[frame_index].ContainsAudioTrack6) {
        AudioTrack<6> audioTrack6;
    }
    u8 video[size - ($ - addressof(this))];
};

struct SMK {
    Header header;
    Size sizes[header.FrameCount];
    FrameType frameTypes[header.FrameCount] ;
    u8 trees[header.TreesSize];
    FramesData frames[header.FrameCount];
};

SMK smk @ 0x00 [[inline]];
