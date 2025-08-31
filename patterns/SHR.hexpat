/*!
    Apple IIgs Super Hi-Res (SHR) + PaintWorks Animation (ANI) — ImHex pattern

    Supports:
      • PIC $C1/$0000 — 32 KB uncompressed SHR screen image
      • PIC $C1/$0002 — 3200-color (“Brooks”) per-scanline palettes
      • ANI $C2/$0000 — PaintWorks animation:
            0x0000..0x7FFF : base SHR $C1/$0000 image
            0x8000..      : animation header + chunks

    PaintWorks animation structure (per reversed docs):
      - Base image: uncompressed SHR ($C1/$0000)
      - +0x8000 u32: total animation data length after header (file_len - 0x8008)
      - +0x8004 u16: global frame delay in VBLs
      - +0x8006 u16: flag/? (commonly 0x00C0 or 0x00C1)
      - +0x8008 ...: one or more animation chunks:
            chunk:
              u32 chunk_len           (includes this length field)
              repeated { u16 offset; u16 value; } pairs
              offset==0x0000 marks End-of-Frame (value is ignored)
      - Offsets may target any byte in the 32 KB SHR space (pixels, SCBs, palettes).
        This enables palette-cycling and SCB effects.

    References:
      - CiderPress2 PaintWorks Animation notes (file structure, fields, semantics).
*/

import std.core;
import std.sys;
import std.math;

#pragma endian little
#include <std/mem.pat>

#pragma description Apple IIgs Super Hi-Res (SHR) + PaintWorks Animation (ANI)
#pragma author hasseily


// ------------------------------ Constants ------------------------------

const u32 SHR_ROWS                 = 200;
const u32 SHR_BYTES_PER_ROW        = 160;
const u32 SHR_PIXEL_DATA_SIZE      = SHR_ROWS * SHR_BYTES_PER_ROW; // 32000 (0x7D00)

const u32 PIC0000_FILE_SIZE        = 0x8000;  // 32768
const u32 PIC0002_FILE_SIZE        = 0x9600;  // 38400 (32000 + 200*32)

const u32 PIC0000_OFF_PIXELS       = 0x0000;
const u32 PIC0000_OFF_SCB          = 0x7D00;
const u32 PIC0000_OFF_RESERVED     = 0x7DC8;
const u32 PIC0000_OFF_PALETTES     = 0x7E00;

const u32 PALETTE_COUNT            = 16;
const u32 PALETTE_COLORS           = 16;

const u32 ANI_BASE_SHR_SIZE        = 0x8000;  // First 32 KB is a $C1/$0000 image
const u32 ANI_HDR_OFF              = 0x8000;  // Animation header starts here
const u32 ANI_MIN_TOTAL_SIZE       = 0x8008;  // base + header (no chunks)

// ------------------------------ Types: SHR core ------------------------------

struct Row160 { u8 data[SHR_BYTES_PER_ROW]; };

// Scanline Control Byte
bitfield ShrSCB {
    palette    : 4;  // 0..15
    reserved   : 1;
    color_fill : 1;
    interrupt  : 1;
    mode_640   : 1;  // 0=320, 1=640
};

// helper: expand a 4-bit channel to 8-bit (0x0..0xF -> 0x00..0xFF)
fn expand4(u8 v) { return (v << 4) | v; };

bitfield Colors_gb {
    blue : 4;   // Blue  (B3..B0)
    green : 4;   // Green (G3..G0)
};

bitfield Colors_r0 {
    red : 4;      // Red   (R3..R0)
    unused : 4;   // Unused / reserved
};
    
// RGB444 stored as 0RGB
struct Rgb444_0RGB {
    Colors_gb gb;
    Colors_r0 r0;
} [[color(std::format("{:02X}{:02X}{:02X}", expand4(r0.red), expand4(gb.green), expand4(gb.blue)))]];

struct Palette16 { Rgb444_0RGB color[PALETTE_COLORS]; };

// $C1/$0000 raw 32 KB screen dump
struct SHR_PIC0000 {
    Row160    pixels[SHR_ROWS]            @ PIC0000_OFF_PIXELS;
    ShrSCB    scb[SHR_ROWS]               @ PIC0000_OFF_SCB;
    u8        reserved[56]                @ PIC0000_OFF_RESERVED;
    Palette16 palettes[PALETTE_COUNT]     @ PIC0000_OFF_PALETTES;
};

// “Brooks” 3200-color: pixels + 200 per-line palettes (no SCBs)
struct BrooksLinePalette { Rgb444_0RGB color[PALETTE_COLORS]; };

struct SHR_PIC0002 {
    Row160             pixels[SHR_ROWS]                 @ 0x0000;
    BrooksLinePalette  line_palettes[SHR_ROWS]          @ SHR_PIXEL_DATA_SIZE; // 0x7D00
};

// ------------------------------ Types: PaintWorks ANI ($C2/$0000) ------------------------------

/* Each operation modifies 1 word at an absolute offset in the 32 KB SHR area.
   End-of-frame marker: offset == 0x0000 (value is ignored). */
struct AniOp {
    u16 offset [[color("0000AA")]];   // 0x0000..0x7FFE valid; 0x0000 = End-of-Frame
    u16 value [[color("00AAAA")]];    // word to store at [offset]
    // For convenience in the sidebar:
    bool is_eof = (offset == 0x0000);
};

// A contiguous animation chunk: length + packed AniOp pairs.
// Most files have exactly one chunk that spans all frames.
struct AniChunk {
    u32  chunk_len;   // includes this field

    // ops_count = (chunk_len - 4)/4, unless chunk_len == 4
    // in which case: (__file_size - 0x8000 - 12)/4
    u64 ops_count64 =
        (chunk_len == 4)
            ? ( (__file_size > (0x8000 + 12)) ? ((__file_size - 0x8000 - 12) / 4) : 0 )
            : ( (chunk_len >= 4) ? (u64(chunk_len - 4) / 4) : 0 );

    u32 ops_count = u32(ops_count64);

    // ops start immediately after chunk_len (offset +4)
    AniOp ops[ops_count];
};

// Header located at 0x8000 after the base 32 KB image
struct AniHeader {
    u32 anim_data_len [[color("660000")]];    // total bytes of animation data after header
    u16 frame_delay_vbl [[color("CC0000")]];  // global per-frame delay in VBLs (NTSC/PAL differ)
    u16 flag_unknown;     // usually 0x00C0 or 0x00C1
};

// Full PaintWorks animation container
struct ANI_PaintWorks {
    // Base frame: a normal uncompressed SHR image
    SHR_PIC0000 base                                  @ 0x0000;

    // Global animation header
    AniHeader   hdr                                   @ ANI_HDR_OFF;

    // One or more chunks, typically exactly one:
    AniChunk    chunks[ std::math::min(
                          u32(16), // cap to keep ImHex happy in pathological cases
                          u32((__file_size - (ANI_HDR_OFF + sizeof(AniHeader))) > 3 ?
                                1 + u32((__file_size - (ANI_HDR_OFF + sizeof(AniHeader))) / 0x10000000) :
                                1)
                      ) ]                              @ (ANI_HDR_OFF + sizeof(AniHeader));

    // Helpful computed values for inspection:
    u64 file_len              = __file_size;
    u64 expected_anim_end     = ANI_HDR_OFF + sizeof(AniHeader) + u64(hdr.anim_data_len);
};

// ------------------------------ Dispatcher ------------------------------

u64 __file_size = std::mem::size();

if (__file_size == PIC0000_FILE_SIZE) {
    // Plain SHR dump
    SHR_PIC0000 pic0000 @ 0x0000;

} else if (__file_size == PIC0002_FILE_SIZE) {
    // Brooks 3200-color
    SHR_PIC0002 pic0002 @ 0x0000;

} else if (__file_size >= ANI_MIN_TOTAL_SIZE) {
    // Heuristic: treat as PaintWorks ANI if there’s room for base+header.
    // (Many PW ANI files use ProDOS type $C2/$0000.)
    ANI_PaintWorks ani @ 0x0000;

} else if (__file_size >= SHR_PIXEL_DATA_SIZE) {
    // Fallback: show pixels only for odd dumps
    Row160 pixels_only[SHR_ROWS] @ 0x0000;
}

ANI_PaintWorks ani_paintworks_at_0 @ 0;