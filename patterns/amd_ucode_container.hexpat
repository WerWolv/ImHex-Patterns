#pragma author Antonio Vázquez Blanco <antoniovazquezblanco@gmail.com>
#pragma description AMD Linux Kernel microcode container
#pragma once
#pragma magic [ "DMA\x00" ] @ 0x00

// AMD microcode container (Linux kernel / linux-firmware format)
//
// A concatenation of type/size framed sections:
//   - a 4-byte magic ("DMA\0", i.e. UCODE_MAGIC = 0x00414d44)
//   - one equivalence-CPU table section (type 0x0000), and
//   - one or more microcode patch sections (type 0x0001), each holding a full
//     AMD microcode patch (decoded via amd_ucode_patch.hexpat).
// See Linux arch/x86/kernel/cpu/microcode/amd.c

#pragma endian little

#include <std/io.pat>
#include <std/mem.pat>
#include <std/sys.pat>

// Reuse the patch types (header, date/cpuid decoders, signature block, verified
// header and the sized AmdUcodePatch) instead of duplicating them here. The
// AMD_UCODE_PATCH_USE_LIB define suppresses the standalone patch placement.
#define AMD_UCODE_PATCH_USE_LIB
#include "amd_ucode_patch.hexpat"

// Magic is "AMD\0" byte-reversed.
#define AMD_UCODE_MAGIC "DMA\x00"

// Equivalence-CPU table (Linux `struct equiv_cpu_entry`).
struct EquivCpuEntry {
    u32 installed_cpu [[format("format_hex32")]];  // CPUID(1).EAX signature
    u32 fixed_errata_mask;
    u32 fixed_errata_compare;
    u16 equiv_cpu;                                 // matches patch processor_rev_id
    u16 res;
};

enum FileSectionType : u32 {
    EQUIV_CPU_TABLE = 0x0000,
    UCODE           = 0x0001,
};

struct FileSection {
    FileSectionType section_type;
    u32 section_size;
    if (section_type == FileSectionType::EQUIV_CPU_TABLE) {
        EquivCpuEntry equiv_cpu_table[section_size / sizeof(EquivCpuEntry)];
    } else if (section_type == FileSectionType::UCODE) {
        AmdUcodePatch<section_size> patch;
    } else {
        u8 section_data[section_size];
    }
};

struct AmdUcodeContainer {
    char magic[4];
    FileSection sections[while(!std::mem::eof())];
};

AmdUcodeContainer container @ 0x00;
std::assert(container.magic == AMD_UCODE_MAGIC, "File magic is not a valid AMD microcode container!");
