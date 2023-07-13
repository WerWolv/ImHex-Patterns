#pragma endian big

#include <std/sys.pat>
#include <std/io.pat>
#include <std/mem.pat>

#include <type/magic.pat>
#include <type/size.pat>

struct FDTHeader {
    type::Magic<"\xD0\x0D\xFE\xED"> magic;
    u32 totalsize;
    u32 off_dt_struct;
    u32 off_dt_strings;
    u32 off_mem_rsvmap;
    u32 version;
    u32 last_comp_version;
    u32 boot_cpuid_phys;
    u32 size_dt_strings;
    u32 size_dt_struct;
};

struct AlignTo<auto Alignment> {
    padding[Alignment- ((($ - 1) % Alignment) + 1)];
};

struct FDTReserveEntry {
    u64 address;
    type::Size<u64> size;

    if (address == 0x00 && size == 0x00)
        break;
};

enum FDTToken : u32 {
    FDT_BEGIN_NODE = 0x00000001,
    FDT_END_NODE   = 0x00000002,
    FDT_PROP       = 0x00000003,
    FDT_NOP        = 0x00000004,
    FDT_END        = 0x00000009
};

struct FDTStructureBlock {
    FDTToken token;
    if (token == FDTToken::FDT_BEGIN_NODE) {
        char nodeName[];
        AlignTo<4>;
    } else if (token == FDTToken::FDT_END) {
        break;
    } else if (token == FDTToken::FDT_PROP) {
        u32 len;
        u32 nameoff;
        char value[len];
        AlignTo<4>;
        char name[] @ parent.header.off_dt_strings + nameoff;
    } else if (token == FDTToken::FDT_NOP || token == FDTToken::FDT_END_NODE) {
        // Nothing to do
    } else {
        std::error(std::format("Invalid token at address 0x{:02X}", addressof(token)));
    }
};

struct FDT {
    FDTHeader header;
    std::assert(header.version == 17, "Unsupported format version");

    FDTStructureBlock structureBlocks[while(true)] @ addressof(this) + header.off_dt_struct;
    FDTReserveEntry reserveEntries[while(true)] @ addressof(this) + header.off_mem_rsvmap;
};

std::mem::MagicSearch<"\xD0\x0D\xFE\xED", FDT> fdt @ std::mem::base_address();
