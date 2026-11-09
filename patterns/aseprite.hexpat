#pragma description Aseprite sprite file
#pragma endian little
#pragma magic [ E0 A5 ] @ 0x04

// Format reference: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md

import std.sys;
import std.io;
import type.color;

struct AseString {
    u16 length;
    char value[length];
} [[sealed, format("format_ase_string")]];

fn format_ase_string(ref AseString s) {
    return std::format("\"{}\"", s.value);
};

using Fixed = s32 [[format("format_fixed")]];

fn format_fixed(Fixed value) {
    return std::format("{}", float(value) / 65536.0);
};

struct Uuid {
    u8 bytes[16];
} [[sealed, format("format_uuid")]];

fn format_uuid(ref Uuid u) {
    return std::format("{:02x}{:02x}{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}",
        u.bytes[0], u.bytes[1], u.bytes[2], u.bytes[3], u.bytes[4], u.bytes[5], u.bytes[6], u.bytes[7],
        u.bytes[8], u.bytes[9], u.bytes[10], u.bytes[11], u.bytes[12], u.bytes[13], u.bytes[14], u.bytes[15]);
};

enum ColorDepth : u16 {
    Indexed = 8,
    Grayscale = 16,
    RGBA = 32
};

bitfield HeaderFlags {
    layer_opacity_valid : 1;
    group_blend_valid : 1;
    layers_have_uuid : 1;
    padding : 29;
};

struct Header {
    u32 file_size;
    u16 magic;
    std::assert(magic == 0xA5E0, "Invalid Aseprite magic number");
    u16 frames;
    u16 width;
    u16 height;
    ColorDepth color_depth;
    HeaderFlags flags;
    u16 speed [[comment("Deprecated, use the frame duration instead")]];
    u32 reserved[2];
    u8 transparent_index [[comment("Only used by indexed sprites")]];
    padding[3];
    u16 color_count [[comment("0 means 256 in old sprites")]];
    u8 pixel_width;
    u8 pixel_height;
    s16 grid_x;
    s16 grid_y;
    u16 grid_width;
    u16 grid_height;
    padding[84];
};

enum ChunkType : u16 {
    OldPalette256 = 0x0004,
    OldPalette64 = 0x0011,     // Channels are 0-63
    Layer = 0x2004,
    Cel = 0x2005,
    CelExtra = 0x2006,
    ColorProfile = 0x2007,
    ExternalFiles = 0x2008,
    Mask = 0x2016,
    Path = 0x2017,
    Tags = 0x2018,
    Palette = 0x2019,
    UserData = 0x2020,
    Slice = 0x2022,
    Tileset = 0x2023
};

struct OldPalettePacket {
    u8 skip;
    u8 count [[comment("0 means 256")]];
    type::RGB8 colors[count == 0 ? 256 : count];
};

struct OldPaletteChunk {
    u16 packet_count;
    OldPalettePacket packets[packet_count];
};

bitfield LayerFlags {
    visible : 1;
    editable : 1;
    lock_movement : 1;
    background : 1;
    prefer_linked_cels : 1;
    collapsed : 1;
    reference : 1;
    padding : 9;
};

enum LayerType : u16 {
    Normal = 0,
    Group = 1,
    Tilemap = 2
};

enum BlendMode : u16 {
    Normal = 0,
    Multiply = 1,
    Screen = 2,
    Overlay = 3,
    Darken = 4,
    Lighten = 5,
    ColorDodge = 6,
    ColorBurn = 7,
    HardLight = 8,
    SoftLight = 9,
    Difference = 10,
    Exclusion = 11,
    Hue = 12,
    Saturation = 13,
    Color = 14,
    Luminosity = 15,
    Addition = 16,
    Subtract = 17,
    Divide = 18
};

struct LayerChunk {
    LayerFlags flags;
    LayerType layer_type;
    u16 child_level;
    u16 default_width [[comment("Ignored")]];
    u16 default_height [[comment("Ignored")]];
    BlendMode blend_mode;
    u8 opacity;
    padding[3];
    AseString name;
    if (layer_type == LayerType::Tilemap)
        u32 tileset_index;
    if (header.flags.layers_have_uuid)
        Uuid uuid;
};

enum CelType : u16 {
    RawImage = 0,
    Linked = 1,
    CompressedImage = 2,
    CompressedTilemap = 3
};

struct CelChunk {
    u16 layer_index;
    s16 x;
    s16 y;
    u8 opacity;
    CelType cel_type;
    s16 z_index;
    padding[5];

    match (cel_type) {
        (CelType::RawImage): {
            u16 width;
            u16 height;
            u8 pixels[parent.end - $];
        }
        (CelType::Linked): {
            u16 linked_frame;
        }
        (CelType::CompressedImage): {
            u16 width;
            u16 height;
            u8 pixels[parent.end - $] [[comment("zlib compressed, row by row")]];
        }
        (CelType::CompressedTilemap): {
            u16 width [[comment("In tiles")]];
            u16 height [[comment("In tiles")]];
            u16 bits_per_tile;
            u32 tile_id_mask;
            u32 x_flip_mask;
            u32 y_flip_mask;
            u32 diagonal_flip_mask;
            padding[10];
            u8 tiles[parent.end - $] [[comment("zlib compressed, row by row")]];
        }
    }
};

struct CelExtraChunk {
    u32 flags [[comment("1 = precise bounds are set")]];
    Fixed x;
    Fixed y;
    Fixed width;
    Fixed height;
    padding[16];
};

enum ColorProfileType : u16 {
    None = 0,
    sRGB = 1,
    ICC = 2
};

struct ColorProfileChunk {
    ColorProfileType profile_type;
    u16 flags [[comment("1 = use fixed gamma")]];
    Fixed gamma;
    padding[8];
    if (profile_type == ColorProfileType::ICC) {
        u32 icc_length;
        u8 icc_data[icc_length];
    }
};

enum ExternalFileType : u8 {
    Palette = 0,
    Tileset = 1,
    PropertiesExtension = 2,
    TileManagementExtension = 3
};

struct ExternalFile {
    u32 id;
    ExternalFileType file_type;
    padding[7];
    AseString name;
};

struct ExternalFilesChunk {
    u32 count;
    padding[8];
    ExternalFile entries[count];
};

struct MaskChunk {
    s16 x;
    s16 y;
    u16 width;
    u16 height;
    padding[8];
    AseString name;
    u8 bitmap[height * ((width + 7) / 8)];
};

enum LoopDirection : u8 {
    Forward = 0,
    Reverse = 1,
    PingPong = 2,
    PingPongReverse = 3
};

struct Tag {
    u16 from_frame;
    u16 to_frame;
    LoopDirection direction;
    u16 repeat [[comment("0 = not specified")]];
    padding[6];
    type::RGB8 color [[comment("Deprecated, the user data after the tags chunk holds the color")]];
    padding[1];
    AseString name;
};

struct TagsChunk {
    u16 count;
    padding[8];
    Tag tags[count];
};

struct PaletteEntry {
    u16 flags [[comment("1 = has name")]];
    u8 r;
    u8 g;
    u8 b;
    u8 a;
    if (flags & 1)
        AseString name;
} [[hex::inline_visualize("color", r, g, b, a)]];

struct PaletteChunk {
    u32 palette_size;
    u32 first_index;
    u32 last_index;
    padding[8];
    PaletteEntry entries[last_index - first_index + 1];
};

bitfield UserDataFlags {
    has_text : 1;
    has_color : 1;
    has_properties : 1;
    padding : 29;
};

struct UserDataChunk {
    UserDataFlags flags;
    if (flags.has_text)
        AseString text;
    if (flags.has_color)
        type::RGBA8 color;
    if (flags.has_properties) {
        u32 properties_size [[comment("Includes this field and the map count")]];
        u32 map_count;
        u8 properties[properties_size - 8];
    }
};

bitfield SliceFlags {
    nine_patch : 1;
    has_pivot : 1;
    padding : 30;
};

struct SliceKey {
    u32 frame;
    s32 x;
    s32 y;
    u32 width;
    u32 height;
    if (parent.flags.nine_patch) {
        s32 center_x;
        s32 center_y;
        u32 center_width;
        u32 center_height;
    }
    if (parent.flags.has_pivot) {
        s32 pivot_x;
        s32 pivot_y;
    }
};

struct SliceChunk {
    u32 key_count;
    SliceFlags flags;
    u32 reserved;
    AseString name;
    SliceKey keys[key_count];
};

bitfield TilesetFlags {
    external_file : 1;
    tiles_in_file : 1;
    tile_0_is_empty : 1;
    auto_x_flip : 1;
    auto_y_flip : 1;
    auto_diagonal_flip : 1;
    padding : 26;
};

struct TilesetChunk {
    u32 id;
    TilesetFlags flags;
    u32 tile_count;
    u16 tile_width;
    u16 tile_height;
    s16 base_index;
    padding[14];
    AseString name;
    if (flags.external_file) {
        u32 external_file_id;
        u32 external_tileset_id;
    }
    if (flags.tiles_in_file) {
        u32 data_length;
        u8 data[data_length] [[comment("zlib compressed tileset image")]];
    }
};

struct Chunk {
    u32 size;
    ChunkType chunk_type;
    u64 end = addressof(this) + size;
    std::assert(size >= 6, "Chunk size must be at least 6");

    match (chunk_type) {
        (ChunkType::OldPalette256 | ChunkType::OldPalette64): OldPaletteChunk data;
        (ChunkType::Layer): LayerChunk data;
        (ChunkType::Cel): CelChunk data;
        (ChunkType::CelExtra): CelExtraChunk data;
        (ChunkType::ColorProfile): ColorProfileChunk data;
        (ChunkType::ExternalFiles): ExternalFilesChunk data;
        (ChunkType::Mask): MaskChunk data;
        (ChunkType::Tags): TagsChunk data;
        (ChunkType::Palette): PaletteChunk data;
        (ChunkType::UserData): UserDataChunk data;
        (ChunkType::Slice): SliceChunk data;
        (ChunkType::Tileset): TilesetChunk data;
        (_): u8 data[size - 6];
    }

    if ($ < end)
        padding[end - $];
} [[format("format_chunk")]];

fn format_chunk(ref Chunk c) {
    return std::format("{}", c.chunk_type);
};

struct Frame {
    u32 size;
    u16 magic;
    std::assert(magic == 0xF1FA, "Invalid frame magic number");
    u16 old_chunk_count [[comment("0xFFFF means the new field holds the count")]];
    u16 duration [[comment("Milliseconds")]];
    padding[2];
    u32 new_chunk_count [[comment("0 means use the old field")]];
    u64 end = addressof(this) + size;

    Chunk chunks[new_chunk_count != 0 ? new_chunk_count : old_chunk_count];

    if ($ < end)
        padding[end - $];
} [[format("format_frame")]];

fn format_frame(ref Frame f) {
    return std::format("{} ms", f.duration);
};

Header header @ 0x00;
Frame frames[header.frames] @ 0x80;
