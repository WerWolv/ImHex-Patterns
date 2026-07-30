#pragma author Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
#pragma description AMD microcode patch
#pragma once

#pragma endian little

#include <std/io.pat>
#include <std/mem.pat>

// AMD microcode patch
//
// A single AMD microcode patch, as distributed standalone or embedded inside a
// container (see amd_ucode_container.hexpat). The layout mirrors the reference
// parser at https://github.com/amd-zenith/amd-ucode-patch.


// Patches are cryptographically signed starting with Zen (family 0x17).
#define AMD_SIGNED_MIN_FAMILY 0x17

fn format_hex32(u32 v) {
    return std::format("{:08X}", v);
};

// Build date (data_code)
// A packed BCD laid out as 0xMMDDYYYY.
struct PatchDate {
    u16 year;   // BCD, 4 digits
    u8  day;    // BCD, 2 digits
    u8  month;  // BCD, 2 digits
} [[format("format_patch_date")]];

fn format_patch_date(PatchDate d) {
    return std::format("{:04X}-{:02X}-{:02X}", d.year, d.month, d.day);
};

// processor_rev_id
// The target CPU encoded.
bitfield UcodeCpuid {
    stepping   : 4;
    model_lo   : 4;
    model_hi   : 4;
    family_ext : 4;
} [[format("format_ucode_cpuid")]];

fn format_ucode_cpuid(UcodeCpuid c) {
    u32 family = 0xF + c.family_ext;
    u32 model  = (c.model_hi << 4) | c.model_lo;
    // Re-encode as a standard CPUID(1).EAX signature for display.
    u32 sig = c.stepping
            | (c.model_lo   << 4)
            | (0xF          << 8)
            | (c.model_hi   << 16)
            | (c.family_ext << 20);
    return std::format("{:08X} (family {:#04x}, model {:#04x}, stepping {:#x})",
                       sig, family, model, c.stepping);
};

// Zen (v2) patch level
// The whole 32-bit patch id decodes to the target family/model/stepping and
// only `rev` (the low byte) increments between updates for a given CPU.
bitfield ZenPatchLevel {
    rev        : 8;
    stepping   : 4;
    model_lo   : 4;
    reserved   : 4;
    model_hi   : 4;
    family_ext : 8;
} [[format("format_zen_patch_level")]];

fn format_zen_patch_level(ZenPatchLevel p) {
    u32 family = 0xF + p.family_ext;
    u32 model  = (p.model_hi << 4) | p.model_lo;
    return std::format("rev {:#04x} (family {:#04x}, model {:#04x}, stepping {:#x})",
                       p.rev, family, model, p.stepping);
};

// Fixed 32-byte header.
struct AmdUcodeHeader {
    PatchDate  date;                    // 0x00  data_code: build date (BCD)
    u32        patch_id [[format("format_hex32")]]; // 0x04  patch level / revision (MSR 0x8B)
    u16        mc_patch_data_id;        // 0x08  loader id, a.k.a. "format"
    u8         mc_patch_data_len;       // 0x0A
    u8         init_flag;               // 0x0B
    u32        mc_patch_data_checksum;  // 0x0C
    u32        nb_dev_id;               // 0x10
    u32        sb_dev_id;               // 0x14
    UcodeCpuid processor_rev_id;        // 0x18  target CPU (u16)
    u8         nb_rev_id;               // 0x1A
    u8         sb_rev_id;               // 0x1B
    u8         bios_api_rev;            // 0x1C
    u8         reserved1[3];            // 0x1D..0x1F
};

// RSA-2048 signature block (Zen and later only).
struct Signature {
    u8 signature[256];  // RSA-2048 signature (PKCS#1 v1.5, e = 0x10001)
    u8 modulus[256];    // RSA-2048 public modulus embedded in the patch
    u8 check[256];      // Montgomery helper derived from the modulus
};

// Verified header (Zen and later only).
struct VerifiedHeader {
    u8            autorun;
    u8            encrypted;
    u8            unk0;
    u8            unk1;
    ZenPatchLevel patch_level;   // mirrors header.patch_id, decoded
};

// A whole patch, sized to `totalSize` bytes so it can be reused when the patch
// is embedded in a container (pass the section size) or parsed standalone (pass
// the file size).
struct AmdUcodePatch<auto totalSize> {
    u64 begin = $;
    AmdUcodeHeader header;
    // Effective family = 0xF + family_ext; the signature block and verified
    // header are present on Zen and later only.
    if ((0xF + header.processor_rev_id.family_ext) >= AMD_SIGNED_MIN_FAMILY) {
        Signature      signature;
        VerifiedHeader verified_header;
    }
    // Remaining bytes: match registers + (usually encrypted) microcode opquads.
    u8 body[totalSize - ($ - begin)];
};

// Define AMD_UCODE_PATCH_USE_LIB before including this file to reuse the types
// above without placing a patch at offset 0 (e.g. from the container pattern).
#ifndef AMD_UCODE_PATCH_USE_LIB
AmdUcodePatch<std::mem::size()> patch @ 0x00;
#endif
