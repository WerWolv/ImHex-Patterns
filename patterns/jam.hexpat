// JAM Service Blob (.jam) — ImHex Pattern
//
// Decodes .jam files produced by polkavm-to-jam (metadata_spi / deblob).
//
// Outer layout (GP eq A.38):
//   [metadata_len : varNat]             — GP Def 275 general integer
//   [metadata     : u8[metadata_len]]
//   [ro_data_size : u24 LE]             — E3(|o|)
//   [rw_data_size : u24 LE]             — E3(|w|)
//   [heap_pages   : u16 LE]             — E2(z)
//   [stack_size   : u24 LE]             — E3(s)
//   [ro_data      : u8[ro_data_size]]   — o
//   [rw_data      : u8[rw_data_size]]   — w
//   [program_len  : u32 LE]             — E4(|c|)
//   [program      : deblob(...)]        — c
//
// Inner program blob — deblob (GP eq A.2):
//   E(|j|)  — jump table entry count (JAM natural)
//   E1(z)   — bytes per jump table entry
//   E(|c|)  — code length (JAM natural)
//   Ez(j)   — jump table (|j| * z bytes LE)
//   E(c)    — PVM bytecode
//   E(k)    — instruction boundary bitmask, ceil(|c|/8) bytes, packed LSB-first

#pragma endian little
#pragma pattern_limit 4194304

import std.io;
import std.mem;

// ============================================================================
// JAM Natural Number (GP Appendix C / eq A.2 codec)
// ============================================================================
//   0x00..0x7F  -> value directly (1 byte)
//   0x80..0xBF  -> 2 bytes: ((first & 0x3F) << 8) | byte[1]
//   0xC0..0xDF  -> 3 bytes: ((first & 0x1F) << 16) | LE16(byte[1..2])
//   0xE0..0xFF  -> 4 bytes: ((first & 0x0F) << 24) | LE24(byte[1..3])

fn jam_nat_trailing(u8 first) {
    if (first < 0x80) return 0;
    if (first < 0xC0) return 1;
    if (first < 0xE0) return 2;
    return 3;
};

struct JamNat {
    u8 first;
    u8 rest[jam_nat_trailing(first)];
} [[sealed, format("format_jam_nat")]];

fn decode_jam_nat(JamNat v) {
    if (v.first < 0x80) return u32(v.first);
    if (v.first < 0xC0)
        return (u32(v.first & 0x3F) << 8) | u32(v.rest[0]);
    if (v.first < 0xE0)
        return (u32(v.first & 0x1F) << 16) | (u32(v.rest[1]) << 8) | u32(v.rest[0]);
    return (u32(v.first & 0x0F) << 24) | (u32(v.rest[2]) << 16)
         | (u32(v.rest[1]) << 8) | u32(v.rest[0]);
};

fn format_jam_nat(JamNat v) {
    return std::format("{}", decode_jam_nat(v));
};

// ============================================================================
// GP Def 275 general integer (metadata prefix in outer blob)
// ============================================================================

fn varint_trailing_bytes(u8 prefix) {
    if (prefix < 0x80) return 0;
    if (prefix <= 0xBF) return 1;
    if (prefix <= 0xDF) return 2;
    if (prefix <= 0xEF) return 3;
    if (prefix <= 0xF7) return 4;
    if (prefix <= 0xFB) return 5;
    if (prefix <= 0xFD) return 6;
    if (prefix == 0xFE) return 7;
    return 8;
};

fn varint_base_offset(u8 prefix) {
    if (prefix < 0x80) return 0;
    if (prefix <= 0xBF) return 128;
    if (prefix <= 0xDF) return 192;
    if (prefix <= 0xEF) return 224;
    if (prefix <= 0xF7) return 240;
    if (prefix <= 0xFB) return 248;
    if (prefix <= 0xFD) return 252;
    if (prefix == 0xFE) return 254;
    return 0;
};

struct VarUInt {
    u8 prefix;
    u8 trailing[varint_trailing_bytes(prefix)];
} [[sealed, format("format_varuint")]];

fn decode_varuint(VarUInt v) {
    u8 prefix = v.prefix;
    if (prefix == 0) return 0;
    if (prefix < 0x80) return prefix;
    u8 n = varint_trailing_bytes(prefix);
    if (prefix == 0xFF) {
        u64 result = 0;
        for (u8 i = 0, i < 8, i = i + 1)
            result = result | (u64(v.trailing[i]) << (8 * i));
        return result;
    }
    u64 m = varint_base_offset(prefix);
    u64 m_val = u64(prefix) - m;
    u64 result = 0;
    for (u8 i = 0, i < n, i = i + 1)
        result = result | (u64(v.trailing[i]) << (8 * i));
    result = result + (m_val << (8 * n));
    return result;
};

fn format_varuint(VarUInt v) {
    return std::format("{}", decode_varuint(v));
};

// ============================================================================
// u24 LE helper
// ============================================================================

struct U24LE {
    u8 bytes[3];
} [[sealed, format("format_u24le")]];

fn decode_u24le(U24LE v) {
    return u32(v.bytes[0]) | (u32(v.bytes[1]) << 8) | (u32(v.bytes[2]) << 16);
};

fn format_u24le(U24LE v) {
    return std::format("{} (0x{:06X})", decode_u24le(v), decode_u24le(v));
};

// ============================================================================
// SPI Header
// ============================================================================

struct SPIHeader {
    U24LE ro_data_size    [[comment("Read-only data size")]];
    U24LE rw_data_size    [[comment("Read-write data size")]];
    u16   heap_pages      [[comment("Heap zero-pages")]];
    U24LE stack_size      [[comment("Stack size in bytes")]];
};

// ============================================================================
// Jump Table entry formatters
// ============================================================================

fn format_jt1(u8 v)  { return std::format("-> code[{}]", v); };
fn format_jt2(u16 v) { return std::format("-> code[{}]", v); };
fn format_jt4(u32 v) { return std::format("-> code[{}]", v); };

// ============================================================================
// ProgramBlob — deblob format (GP eq A.2)
// ============================================================================
// Layout: E(|j|) . E1(z) . E(|c|) . Ez(j) . code . bitmask

struct ProgramBlob {
    JamNat jt_count    [[comment("Jump table entry count |j|")]];
    u8     jt_z        [[comment("Bytes per jump table entry (z)")]];
    JamNat code_len    [[comment("Code length |c|")]];

    // Jump table: |j| entries of z bytes each
    if (decode_jam_nat(jt_count) > 0) {
        if (jt_z == 1)
            u8  jump_table[decode_jam_nat(jt_count)]
                [[comment("Jump table (code offsets)"), format("format_jt1")]];
        else if (jt_z == 2)
            u16 jump_table[decode_jam_nat(jt_count)]
                [[comment("Jump table (code offsets)"), format("format_jt2")]];
        else if (jt_z == 4)
            u32 jump_table[decode_jam_nat(jt_count)]
                [[comment("Jump table (code offsets)"), format("format_jt4")]];
        else
            u8  jump_table_raw[decode_jam_nat(jt_count) * jt_z]
                [[comment("Jump table (raw)")]];
    }

    // Code: raw PVM bytecode
    u32 cl = decode_jam_nat(code_len);
    u8 code[cl] [[comment("PVM bytecode")]];

    // Bitmask: packed bit array, ceil(|c|/8) bytes, LSB-first
    u8 bitmask[(cl + 7) / 8]
        [[comment("Instruction boundary bitmask (packed, LSB-first)")]];
};

// ============================================================================
// Top-level JAM Blob (metadata_spi)
// ============================================================================

struct JAMBlob {
    // Metadata
    VarUInt metadata_len  [[comment("Metadata length")]];
    if (decode_varuint(metadata_len) > 0)
        u8 metadata[decode_varuint(metadata_len)] [[comment("Service metadata")]];

    // SPI Header
    SPIHeader header      [[comment("Service Program Image header")]];

    // Data segments
    if (decode_u24le(header.ro_data_size) > 0)
        u8 ro_data[decode_u24le(header.ro_data_size)]
            [[comment("Read-only data")]];
    if (decode_u24le(header.rw_data_size) > 0)
        u8 rw_data[decode_u24le(header.rw_data_size)]
            [[comment("Read-write data")]];

    // Program blob (deblob)
    u32 program_len       [[comment("Program blob length (bytes)")]];
    ProgramBlob program   [[comment("PVM program (deblob)")]];
};

JAMBlob blob @ 0x0;
