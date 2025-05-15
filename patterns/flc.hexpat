#pragma description FLC/FLIC animation file
#pragma endian little
#pragma magic [12 AF] @ 0x4

// A flic file could contain many DELTA_FLC chunks, which contain many RLE packets
//#define DECODE_DELTA_FLC

import std.mem;
import std.core;
import std.io;
import type.color;

using Color = type::RGB8 [[hex::inline_visualize("color", r, g, b, 0xff)]];
bitfield Color64 {
    r : 6;
    padding : 2;
    g : 6;
    padding : 2;
    b : 6;
    padding : 2;

    u8 r8 = r << 2 | r >> 4;
    u8 g8 = g << 2 | g >> 4;
    u8 b8 = b << 2 | b >> 4;
} [[hex::inline_visualize("color", r8, g8, b8, 0xff)]];

enum FlicType : u16 {
    FLI = 0xAF11,
    FLC_8bit = 0xAF12,
    FLIC_other = 0xAF44,
    FLIC_Huffmann = 0xAF30,
    FLIC_frame_shift = 0xAF31,
};

enum ChunkType : u16 {
    CEL_DATA = 3,               // Registration and transparency
    COLOR_256 = 4,              // 256-level colour palette
    DELTA_FLC = 7,              // Delta image, word oriented RLE (FLI_SS2)
    COLOR_64 = 11,              // 64-level colour palette
    DELTA_FLI = 12,             // Delta image, byte oriented RLE (FLI_LC)
    BLACK = 13,                 // Full black frame (rare)
    BYTE_RUN = 15,              // Full image, byte oriented RLE (FLI_BRUN)
    FLI_COPY = 16,              // Uncompressed image (rare)
    PSTAMP = 18,                // Postage stamp (icon of the first frame)
    DTA_BRUN = 25,              // Full image, pixel oriented RLE
    DTA_COPY = 26,              // Uncompressed image
    DTA_LC = 27,                // Delta image, pixel oriented RLE
    LABEL = 31,                 // Frame label
    BMP_MASK = 32,              // Bitmap mask
    MLEV_MASK = 33,             // Multilevel mask
    SEGMENT = 34,               // Segment information
    KEY_IMAGE = 35,             // Key image, similar to BYTE_RUN / DTA_BRUN
    KEY_PAL = 36,               // Key palette, similar to COLOR_256
    REGION = 37,                // Region of frame differences
    WAVE = 38,                  // Digitized audio
    USERSTRING = 39,            // General purpose user data
    RGN_MASK = 40,              // Region mask
    LABELEX = 41,               // Extended frame label (includes symbolic name)
    SHIFT = 42,                 // Scanline delta shifts (compression)
    PATHMAP = 43,               // Path map (segment transitions)

    PREFIX_TYPE = 0xF100,       // Prefix chunk
    SCRIPT_CHUNK = 0xF1E0,      // Embedded "Small" script
    FRAME_TYPE = 0xF1FA,        // Frame chunk
    SEGMENT_TABLE = 0xF1FB,     // Segment table chunk
    HUFFMAN_TABLE = 0xF1FC      // Huffman compression table chunk
};

bitfield ExtFlags {
    segment_table_present : 1;
    regular_key_imagees : 1;
    identical_palette : 1;
    huffmann_compressed : 1;
    bwt_huffmann_compressed : 1;
    bitmap_masks_present : 1;
    multilevel_masks_present : 1;
    region_data_present : 1;
    password_protected : 1;
    digitized_audio : 1;
    contains_script : 1;
    region_masks_present : 1;
    contains_overlays : 1;
    frame_shift_compressed : 1;
    padding : 2;
};

u16 pixels_per_line = 0;
u16 lines = 0;

struct Header {
    u32 size           [[comment("Size of FLIC including this header")]];
    FlicType type      [[comment("File type 0xAF11, 0xAF12, 0xAF30, 0xAF44, ...")]];
    u16 frames         [[comment("Number of frames in first segment")]];
    u16 width          [[comment("FLIC width in pixels")]];
    u16 height         [[comment("FLIC height in pixels")]];
    u16 depth          [[comment("Bits per pixel (usually 8)")]];
    u16 flags          [[comment("Set to zero or to three")]];
    u32 speed          [[comment("Delay between frames")]];
    u16 reserved1      [[comment("Set to zero")]];
    u32 created        [[comment("Date of FLIC creation (FLC only)")]];
    u32 creator        [[comment("Serial number or compiler id (FLC only)")]];
    u32 updated        [[comment("Date of FLIC update (FLC only)")]];
    u32 updater        [[comment("Serial number (FLC only), see creator")]];
    u16 aspect_dx      [[comment("Width of square rectangle (FLC only)")]];
    u16 aspect_dy      [[comment("Height of square rectangle (FLC only)")]];
    ExtFlags ext_flags [[comment("EGI: flags for specific EGI extensions")]];
    u16 keyframes      [[comment("EGI: key-image frequency")]];
    u16 totalframes    [[comment("EGI: total number of frames (segments)")]];
    u32 req_memory     [[comment("EGI: maximum chunk size (uncompressed)")]];
    u16 max_regions    [[comment("EGI: max. number of regions in a CHK_REGION chunk")]];
    u16 transp_num     [[comment("EGI: number of transparent levels")]];
    u8  reserved2[24]  [[comment("Set to zero")]];
    u32 oframe1        [[comment("Offset to frame 1 (FLC only)")]];
    u32 oframe2        [[comment("Offset to frame 2 (FLC only)")]];
    u8  reserved3[40]  [[comment("Set to zero")]];

    pixels_per_line = width;
    lines = height;
};

namespace DeltaFLCChunk {
    enum OpcodeType : u8 {
        Count = 0b00,
        Undefined = 0b01,
        LowByte = 0b10,
        LineSkipCount = 0b11,
    };

    struct Packet {
        u8 skip_count;
        s8 count;
        if (count < 0) {
            u8 replicate_bytes[2];
        } else {
            u8 literal_bytes[count * 2];
        }
    };

    u16 packets_in_line;

    fn format_opcode(auto opcode) {
        match (opcode.type) {
            (OpcodeType::Count): return std::format("Packet(s): {0}", opcode.value);
            (OpcodeType::Undefined): return "Undefined";
            (OpcodeType::LowByte): return std::format("Last byte: {0:02x}", opcode.value);
            (OpcodeType::LineSkipCount): {
                s16 total = 0xC000 | opcode.value;
                return std::format("Lines skipped: {0}", total);
            }
        }
    };

    bitfield Opcode {
        value: 14;
        OpcodeType type: 2;

        if (type == OpcodeType::Count) {
            packets_in_line = value;
            break;
        }
    } [[format("DeltaFLCChunk::format_opcode")]];

    struct Line {
        packets_in_line = 0;
        Opcode opcodes[while(true)];
        Packet packets[packets_in_line];
    };
}

namespace ByteRunChunk {
    u16 pixels_in_line_counter = 0;

    struct Packet {
        s8 count;
        if (count < 0) {
            pixels_in_line_counter = -count + pixels_in_line_counter;
            u8 literal_bytes[-count];
        } else {
            pixels_in_line_counter = count + pixels_in_line_counter;
            u8 replicate_byte;
        }
    } [[format("format_byte_run_packet")]];

    struct Line {
        pixels_in_line_counter = 0;
        u8 packet_count;
        Packet packets[while(pixels_in_line_counter < pixels_per_line)];
    };
}

struct ColorPalettePacket<C> {
    u8 skip;
    u8 copy;
    if (copy == 0) {
        C color[256];
    } else {
        C color[copy];
    }
};

fn format_chunk(auto chunk) {
    return std::format("{}", chunk.type);
};

fn format_byte_run_packet(auto packet) {
    if (packet.count == -1) {
        return std::format("One {}", packet.literal_bytes[0]);
    } else if (packet.count < 0) {
        return std::format("{} bytes", -packet.count);
    } else {
        return std::format("{}x color {}", packet.count, packet.replicate_byte);
    }
};

struct Chunk {
    u32 size;
    ChunkType type;

    if (type == ChunkType::FRAME_TYPE) {
        u16 chunks;
        u16 delay;
        u16 reserved;
        u16 width;
        u16 height;
        // Not sure if this is the intended operation here?
        if (width > 0) {
            pixels_per_line = width;
        }
        if (height > 0) {
            lines = height;
        }
        Chunk subchunks[chunks];
    } else if (type == ChunkType::COLOR_256) {
        u16 num_packets;
        ColorPalettePacket<Color> packets[num_packets];
    } else if (type == ChunkType::COLOR_64) {
        u16 num_packets;
        ColorPalettePacket<Color64> packets[num_packets];
    } else if (type == ChunkType::BYTE_RUN) {
        ByteRunChunk::Line lines[lines];
    } else if (type == ChunkType::DELTA_FLC) {
        u16 line_count;
        #ifdef DECODE_DELTA_FLC
        DeltaFLCChunk::Line lines[line_count];
        #endif
        #ifndef DECODE_DELTA_FLC
        u8 data[size - ($ - addressof(this))];
        #endif
    } else if (type == ChunkType::PSTAMP) {
        u16 height;
        u16 width;
        u16 xlate;
        u8 data[size - ($ - addressof(this))];
    } else if (type == ChunkType::FLI_COPY) {
        u8 pixels[lines * pixels_per_line];
    }
    s128 remainingBytes = size - ($ - addressof(this));
    // When the chunk size is rounded up to the next even number, it might need a padding byte.
    // Unrecognized chunk types will also fill out the padding
    if (remainingBytes > 0) {
        padding[size - ($ - addressof(this))];
    } else if (remainingBytes < 0) {
        std::warning("Chunk size wasn't large enough");
    }
} [[format("format_chunk")]];

Header header @ $;
Chunk chunks[while(!std::mem::eof())] @ $;