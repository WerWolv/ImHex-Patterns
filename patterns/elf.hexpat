#pragma author WerWolv
#pragma description Executable and Linkable Format executable (ELF)

#pragma MIME application/x-executable
#pragma MIME application/x-elf
#pragma MIME application/x-coredump
#pragma MIME application/x-object
#pragma MIME application/x-sharedlib

import std.core;
import std.io;
import std.mem;

using BitfieldOrder = std::core::BitfieldOrder;

using EI_ABIVERSION     = u8;
using Elf32_Addr        = u32;
using Elf32_BaseAddr    = u32;
using Elf32_BaseOff     = u32;
using Elf32_Half        = u16;
using Elf32_Off         = u32;
using Elf32_Sword       = s32;
using Elf32_VAddr       = u32;
using Elf32_Word        = u32;
using Elf64_Addr        = u64;
using Elf64_BaseAddr    = u64;
using Elf64_BaseOff     = u64;
using Elf64_Half        = u16;
using Elf64_Off         = u64;
using Elf64_Sword       = s32;
using Elf64_Sxword      = s64;
using Elf64_VAddr       = u64;
using Elf64_Word        = u32;
using Elf64_Xword       = u64;
using E_VERSION         = u32;

enum EI_CLASS : u8 {
    ELFCLASSNONE = 0x00,
    ELFCLASS32   = 0x01,
    ELFCLASS64   = 0x02,
};

enum EI_DATA : u8 {
    ELFDATANONE = 0x00,
    ELFDATA2LSB = 0x01,
    ELFDATA2MSB = 0x02,
};

enum EI_OSABI : u8 {
    SYSV           = 0x00,
    HPUX           = 0x01,
    NetBSD         = 0x02,
    Linux          = 0x03,
    GNUHurd        = 0x04,
    Solaris        = 0x06,
    AIX            = 0x07,
    IRIX           = 0x08,
    FreeBSD        = 0x09,
    Tru64          = 0x0A,
    NovellModesto  = 0x0B,
    OpenBSD        = 0x0C,
    OpenVMS        = 0x0D,
    NonStopKernel  = 0x0E,
    AROS           = 0x0F,
    FenixOS        = 0x10,
    CloudABI       = 0x11,
    OpenVOS        = 0x12,
    ARM_EABI       = 0x40,
    STANDALONE     = 0xFF,
};

enum EI_VERSION : u8 {
    NONE    = 0x00,
    CURRENT = 0x01,
};

enum EM : u16 {
    EM_NONE          = 0x0000,
    EM_M32           = 0x0001,
    EM_SPARC         = 0x0002,
    EM_386           = 0x0003,
    EM_68K           = 0x0004,
    EM_88K           = 0x0005,
    EM_IAMCU         = 0x0006,
    EM_860           = 0x0007,
    EM_MIPS          = 0x0008,
    EM_S370          = 0x0009,
    EM_MIPS_RS4_BE   = 0x000a,
    EM_PARISC        = 0x000f,
    EM_VPP500        = 0x0011,
    EM_SPARC32PLUS   = 0x0012,
    EM_960           = 0x0013,
    EM_PPC           = 0x0014,
    EM_PPC64         = 0x0015,
    EM_S390          = 0x0016,
    EM_SPU           = 0x0017,
    EM_V800          = 0x0024,
    EM_FR20          = 0x0025,
    EM_RH32          = 0x0026,
    EM_RCE           = 0x0027,
    EM_ARM           = 0x0028,
    EM_ALPHA         = 0x0029,
    EM_SH            = 0x002A,
    EM_SPARCV9       = 0x002B,
    EM_TRICORE       = 0x002C,
    EM_ARC           = 0x002D,
    EM_H8_300        = 0x002E,
    EM_H8_300H       = 0x002F,
    EM_H8S           = 0x0030,
    EM_H8_500        = 0x0031,
    EM_IA_64         = 0x0032,
    EM_MIPS_X        = 0x0033,
    EM_COLDFIRE      = 0x0034,
    EM_68HC12        = 0x0035,
    EM_MMA           = 0x0036,
    EM_PCP           = 0x0037,
    EM_NCPU          = 0x0038,
    EM_NDR1          = 0x0039,
    EM_STARCORE      = 0x003A,
    EM_ME16          = 0x003B,
    EM_ST100         = 0x003C,
    EM_TINYJ         = 0x003D,
    EM_X86_64        = 0x003E,
    EM_PDSP          = 0x003F,
    EM_PDP10         = 0x0040,
    EM_PDP11         = 0x0041,
    EM_FX66          = 0x0042,
    EM_ST9PLUS       = 0x0043,
    EM_ST7           = 0x0044,
    EM_68HC16        = 0x0045,
    EM_68HC11        = 0x0046,
    EM_68HC08        = 0x0047,
    EM_68HC05        = 0x0048,
    EM_SVX           = 0x0049,
    EM_ST19          = 0x004A,
    EM_VAX           = 0x004B,
    EM_CRIS          = 0x004C,
    EM_JAVELIN       = 0x004D,
    EM_FIREPATH      = 0x004E,
    EM_ZSP           = 0x004F,
    EM_MMIX          = 0x0050,
    EM_HUANY         = 0x0051,
    EM_PRISM         = 0x0052,
    EM_AVR           = 0x0053,
    EM_FR30          = 0x0054,
    EM_D10V          = 0x0055,
    EM_D30V          = 0x0056,
    EM_V850          = 0x0057,
    EM_M32R          = 0x0058,
    EM_MN10300       = 0x0059,
    EM_MN10200       = 0x005A,
    EM_PJ            = 0x005B,
    EM_OPENRISC      = 0x005C,
    EM_ARC_COMPACT   = 0x005D,
    EM_XTENSA        = 0x005E,
    EM_VIDEOCORE     = 0x005F,
    EM_TMM_GPP       = 0x0060,
    EM_NS32K         = 0x0061,
    EM_TPC           = 0x0062,
    EM_SNP1K         = 0x0063,
    EM_ST200         = 0x0064,
    EM_IP2K          = 0x0065,
    EM_MAX           = 0x0066,
    EM_CR            = 0x0067,
    EM_F2MC16        = 0x0068,
    EM_MSP430        = 0x0069,
    EM_BLACKFIN      = 0x006A,
    EM_SE_C33        = 0x006B,
    EM_SEP           = 0x006C,
    EM_ARCA          = 0x006D,
    EM_UNICORE       = 0x006E,
    EM_EXCESS        = 0x006F,
    EM_DXP           = 0x0070,
    EM_ALTERA_NIOS2  = 0x0071,
    EM_CRX           = 0x0072,
    EM_XGATE         = 0x0073,
    EM_C166          = 0x0074,
    EM_M16C          = 0x0075,
    EM_DSPIC30F      = 0x0076,
    EM_CE            = 0x0077,
    EM_M32C          = 0x0078,
    EM_TSK3000       = 0x0083,
    EM_RS08          = 0x0084,
    EM_SHARC         = 0x0085,
    EM_ECOG2         = 0x0086,
    EM_SCORE7        = 0x0087,
    EM_DSP24         = 0x0088,
    EM_VIDEOCORE3    = 0x0089,
    EM_LATTICEMICO32 = 0x008A,
    EM_SE_C17        = 0x008B,
    EM_TI_C6000      = 0x008C,
    EM_TI_C2000      = 0x008D,
    EM_TI_C5500      = 0x008E,
    EM_TI_ARP32      = 0x008F,
    EM_TI_PRU        = 0x0090,
    EM_MMDSP_PLUS    = 0x00A0,
    EM_CYPRESS_M8C   = 0x00A1,
    EM_R32C          = 0x00A2,
    EM_TRIMEDIA      = 0x00A3,
    EM_QDSP6         = 0x00A4,
    EM_8051          = 0x00A5,
    EM_STXP7X        = 0x00A6,
    EM_NDS32         = 0x00A7,
    EM_ECOG1         = 0x00A8,
    EM_ECOG1X        = 0x00A8,
    EM_MAXQ30        = 0x00A9,
    EM_XIMO16        = 0x00AA,
    EM_MANIK         = 0x00AB,
    EM_CRAYNV2       = 0x00AC,
    EM_RX            = 0x00AD,
    EM_METAG         = 0x00AE,
    EM_MCST_ELBRUS   = 0x00AF,
    EM_ECOG16        = 0x00B0,
    EM_CR16          = 0x00B1,
    EM_ETPU          = 0x00B2,
    EM_SLE9X         = 0x00B3,
    EM_L10M          = 0x00B4,
    EM_K10M          = 0x00B5,
    EM_AARCH64       = 0x00B7,
    EM_AVR32         = 0x00B9,
    EM_STM8          = 0x00BA,
    EM_TILE64        = 0x00BB,
    EM_TILEPRO       = 0x00BC,
    EM_MICROBLAZE    = 0x00BD,
    EM_CUDA          = 0x00BE,
    EM_TILEGX        = 0x00BF,
    EM_CLOUDSHIELD   = 0x00C0,
    EM_COREA_1ST     = 0x00C1,
    EM_COREA_2ND     = 0x00C2,
    EM_ARC_COMPACT2  = 0x00C3,
    EM_OPEN8         = 0x00C4,
    EM_RL78          = 0x00C5,
    EM_VIDEOCORE5    = 0x00C6,
    EM_78KOR         = 0x00C7,
    EM_56800EX       = 0x00C8,
    EM_BA1           = 0x00C9,
    EM_BA2           = 0x00CA,
    EM_XCORE         = 0x00CB,
    EM_MCHP_PIC      = 0x00CC,
    EM_INTEL205      = 0x00CD,
    EM_INTEL206      = 0x00CE,
    EM_INTEL207      = 0x00CF,
    EM_INTEL208      = 0x00D0,
    EM_INTEL209      = 0x00D1,
    EM_KM32          = 0x00D2,
    EM_KMX32         = 0x00D3,
    EM_KMX16         = 0x00D4,
    EM_KMX8          = 0x00D5,
    EM_KVARC         = 0x00D6,
    EM_CDP           = 0x00D7,
    EM_COGE          = 0x00D8,
    EM_COOL          = 0x00D9,
    EM_NORC          = 0x00DA,
    EM_CSR_KALIMBA   = 0x00DB,
    EM_Z80           = 0x00DC,
    EM_VISIUM        = 0x00DD,
    EM_FT32          = 0x00DE,
    EM_MOXIE         = 0x00DF,
    EM_AMDGPU        = 0x00E0,
    EM_RISCV         = 0x00F3,
};

enum ET : u16 {
    NONE = 0x0000,
    REL  = 0x0001,
    EXEC = 0x0002,
    DYN  = 0x0003,
    CORE = 0x0004,
};

enum DT : u32 {
    DT_NULL                      = 0x0,
    DT_NEEDED                    = 0x1,
    DT_PLTRELSZ                  = 0x2,
    DT_PLTGOT                    = 0x3,
    DT_HASH                      = 0x4,
    DT_STRTAB                    = 0x5,
    DT_SYMTAB                    = 0x6,
    DT_RELA                      = 0x7,
    DT_RELASZ                    = 0x8,
    DT_RELAENT                   = 0x9,
    DT_STRSZ                     = 0xA,
    DT_SYMENT                    = 0xB,
    DT_INIT                      = 0xC,
    DT_FINI                      = 0xD,
    DT_SONAME                    = 0xE,
    DT_RPATH                     = 0xF,
    DT_SYMBOLIC                  = 0x10,
    DT_REL                       = 0x11,
    DT_RELSZ                     = 0x12,
    DT_RELENT                    = 0x13,
    DT_PLTREL                    = 0x14,
    DT_DEBUG                     = 0x15,
    DT_TEXTREL                   = 0x16,
    DT_JMPREL                    = 0x17,
    DT_BIND_NOW                  = 0x18,
    DT_INIT_ARRAY                = 0x19,
    DT_FINI_ARRAY                = 0x1A,
    DT_INIT_ARRAYSZ              = 0x1B,
    DT_FINI_ARRAYSZ              = 0x1C,
    DT_RUNPATH                   = 0x1D,
    DT_FLAGS                     = 0x1E,
    DT_PREINIT_ARRAY             = 0x20,
    DT_PREINIT_ARRAYSZ           = 0x21,
    DT_MAXPOSTAGS                = 0x22,
    DT_NUM                       = 0x23,
    DT_GNU_PRELINKED             = 0x6FFFFDF5,
    DT_GNU_CONFLICTSZ            = 0x6FFFFDF6,
    DT_GNU_LIBLISTSZ             = 0x6FFFFDF7,
    DT_CHECKSUM                  = 0x6FFFFDF8,
    DT_PLTPADSZ                  = 0x6FFFFDF9,
    DT_MOVEENT                   = 0x6FFFFDFA,
    DT_MOVESZ                    = 0x6FFFFDFB,
    DT_FEATURE_1                 = 0x6FFFFDFC,
    DT_POSFLAG_1                 = 0x6FFFFDFD,
    DT_SYMINSZ                   = 0x6FFFFDFE,
    DT_SYMINENT                  = 0x6FFFFDFF,
    DT_GNU_HASH                  = 0x6FFFFEF5,
    DT_TLSDESC_PLT               = 0x6FFFFEF6,
    DT_TLSDESC_GOT               = 0x6FFFFEF7,
    DT_GNU_CONFLICT              = 0x6FFFFEF8,
    DT_GNU_LIBLIST               = 0x6FFFFEF9,
    DT_CONFIG                    = 0x6FFFFEFA,
    DT_DEPAUDIT                  = 0x6FFFFEFB,
    DT_AUDIT                     = 0x6FFFFEFC,
    DT_PLTPAD                    = 0x6FFFFEFD,
    DT_MOVETAB                   = 0x6FFFFEFE,
    DT_SYMINFO                   = 0x6FFFFEFF,
    DT_VERSYM                    = 0x6FFFFFF0,
    DT_RELACOUNT                 = 0x6FFFFFF9,
    DT_RELCOUNT                  = 0x6FFFFFFA,
    DT_FLAGS_1                   = 0x6FFFFFFB,
    DT_VERDEF                    = 0x6FFFFFFC,
    DT_VERDEFNUM                 = 0x6FFFFFFD,
    DT_VERNEED                   = 0x6FFFFFFE,
    DT_VERNEEDNUM                = 0x6FFFFFFF,
    DT_AUXILIARY                 = 0x7FFFFFFD,
    DT_USED                      = 0x7FFFFFFE,
    DT_FILTER                    = 0x7FFFFFFF,
    DT_DEPRECATED_SPARC_REGISTER = 0x7000001,
    DT_SUNW_AUXILIARY            = 0x6000000D,
    DT_SUNW_RTLDINF              = 0x6000000E,
    DT_SUNW_FILTER               = 0x6000000F,
    DT_SUNW_CAP                  = 0x60000010,
    DT_SUNW_SYMTAB               = 0x60000011,
    DT_SUNW_SYMSZ                = 0x60000012,
    DT_SUNW_SORTENT              = 0x60000013,
    DT_SUNW_SYMSORT              = 0x60000014,
    DT_SUNW_SYMSORTSZ            = 0x60000015,
    DT_SUNW_TLSSORT              = 0x60000016,
    DT_SUNW_TLSSORTSZ            = 0x60000017,
    DT_SUNW_STRPAD               = 0x60000019,
    DT_SUNW_LDMACH               = 0x6000001B,
};

enum RT : Elf32_Word {
    CONSISTENT = 0x00,
    ADD        = 0x01,
    DELETE     = 0x02,
};

enum PT : Elf32_Word {
    NULL         = 0x00,
    LOAD         = 0x01,
    DYNAMIC      = 0x02,
    INTERP       = 0x03,
    NOTE         = 0x04,
    SHLIB        = 0x05,
    PHDR         = 0x06,
    TLS          = 0x07,
    LOOS         = 0x60000000,
    HIOS         = 0x6FFFFFFF,
    GNU_EH_FRAME = PT::LOOS + 0x474E550,
    GNU_STACK    = PT::LOOS + 0x474E551,
    GNU_RELRO    = PT::LOOS + 0x474E552,
    GNU_PROPERTY = PT::LOOS + 0x474E553,
    SUNWBSS      = 0x6FFFFFFA,
    SUNWSTACK    = 0x6FFFFFFB,
    ARM_ARCHEXT  = 0x70000000,
    ARM_UNWIND   = 0x70000001,
};

enum ELFCOMPRESS : u8 {
    ZLIB = 0x01,
};

enum SHN : u16 {
    UNDEF  = 0x00,
    BEFORE = 0xFF00,
    AFTER  = 0xFF01,
    ABS    = 0xFFF1,
    COMMON = 0xFFF2,
    XINDEX = 0xFFFF,
};

enum SHT : Elf32_Word {
    NULL                   = 0x00,
    PROGBITS               = 0x01,
    SYMTAB                 = 0x02,
    STRTAB                 = 0x03,
    RELA                   = 0x04,
    HASH                   = 0x05,
    DYNAMIC                = 0x06,
    NOTE                   = 0x07,
    NOBITS                 = 0x08,
    REL                    = 0x09,
    SHLIB                  = 0x0A,
    DYNSYM                 = 0x0B,
    UNKNOWN12              = 0x0C,
    UNKNOWN13              = 0x0D,
    INIT_ARRAY             = 0x0E,
    FINI_ARRAY             = 0x0F,
    PREINIT_ARRAY          = 0x10,
    GROUP                  = 0x11,
    SYMTAB_SHNDX           = 0x12,
    GNU_INCREMENTAL_INPUTS = 0x6FFF4700,
    GNU_ATTRIBUTES         = 0x6FFFFFF5,
    GNU_HASH               = 0x6FFFFFF6,
    GNU_LIBLIST            = 0x6FFFFFF7,
    CHECKSUM               = 0x6FFFFFF8,
    SUNW_move              = 0x6FFFFFFA,
    SUNW_COMDAT            = 0x6FFFFFFB,
    SUNW_syminfo           = 0x6FFFFFFC,
    GNU_verdef             = 0x6FFFFFFD,
    GNU_verneed            = 0x6FFFFFFE,
    GNU_versym             = 0x6FFFFFFF,
    ARM_EXIDX              = 0x70000001,
    ARM_PREEMPTMAP         = 0x70000002,
    ARM_ATTRIBUTES         = 0x70000003,
    ARM_DEBUGOVERLAY       = 0x70000004,
    ARM_OVERLAYSECTION     = 0x70000005,
};

enum STV : u8 {
    DEFAULT   = 0x00,
    INTERNAL  = 0x01,
    HIDDEN    = 0x02,
    PROTECTED = 0x03,
};

enum SYMINFO_BT : Elf32_Half {
    SELF   = 0xFFFF,
    PARENT = 0xFFFE,
    NONE   = 0xFFFD,
};

enum VER_DEF : Elf32_Half {
    NON     = 0x00,
    CURRENT = 0x01,
    NUM     = 0x02,
};

enum VER_NDX : Elf32_Half {
    LOCAL     = 0x00,
    GLOBAL    = 0x01,
    ELIMINATE = 0xFF01,
};

enum VER_NEED : Elf32_Half {
    NONE    = 0x00,
    CURRENT = 0x01,
    NUM     = 0x02,
};

bitfield SYMINFO_FLG {
    DIRECT      : 1;
    RESERVED    : 1;
    COPY        : 1;
    LAZYLOAD    : 1;
    DIRECTBIND  : 1;
    NOEXTDIRECT : 1;
    padding     : 10;
};

bitfield ST {
    ST_BIND : 4;
    ST_TYPE : 4;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

bitfield SHF {
    WRITE            : 1;
    ALLOC            : 1;
    EXECINSTR        : 1;
    padding          : 1;
    MERGE            : 1;
    STRINGS          : 1;
    INFO_LINK        : 1;
    LINK_ORDER       : 1;
    OS_NONCONFORMING : 1;
    GROUP            : 1;
    TLS              : 1;
    COMPRESSED       : 1;
    UNKNOWN          : 8;
    MASKOS           : 8;
    MASKPROC         : 4;
};

bitfield ELF32_R_INFO {
    SYM  : 8;
    TYPE : 8;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 16)]];

bitfield ELF64_R_INFO {
    SYM  : 32;
    TYPE : 32;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 64)]];

bitfield PF {
    X        : 1;
    W        : 1;
    R        : 1;
    padding  : 17;
    MASKOS   : 4;
    MASKPROC : 4;
};

struct E_IDENT {
    char EI_MAG[4];
    EI_CLASS EI_CLASS;
    EI_DATA EI_DATA;
    EI_VERSION EI_VERSION;
    EI_OSABI EI_OSABI;
    EI_ABIVERSION EI_ABIVERSION;
    padding[7];
};

struct Elf32_Ehdr {
    ET e_type;
    EM e_machine;
    E_VERSION e_version;
    Elf32_VAddr e_entry;
    Elf32_Off e_phoff;
    Elf32_Off e_shoff;
    Elf32_Word e_flags;
    Elf32_Half e_ehsize;
    Elf32_Half e_phentsize;
    Elf32_Half e_phnum;
    Elf32_Half e_shentsize;
    Elf32_Half e_shnum;
    Elf32_Half e_shstrndx;
};

struct Elf64_Ehdr {
    ET e_type;
    EM e_machine;
    E_VERSION e_version;
    Elf64_VAddr e_entry;
    Elf64_Off e_phoff;
    Elf64_Off e_shoff;
    Elf64_Word e_flags;
    Elf64_Half e_ehsize;
    Elf64_Half e_phentsize;
    Elf64_Half e_phnum;
    Elf64_Half e_shentsize;
    Elf64_Half e_shnum;
    Elf64_Half e_shstrndx;
};

struct Elf32_Phdr {
    PT p_type;
    Elf32_Off p_offset;
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;
    Elf32_Word p_filesz;
    Elf32_Word p_memsz;
    PF p_flags;
    Elf32_Word p_align;
    
    if (p_offset >= 0 && p_filesz > 0 && (p_offset + p_filesz) <= std::mem::size() && p_filesz <= std::mem::size())
        u8 p_data[p_filesz] @ p_offset [[sealed]];
};

struct Elf64_Phdr {
    PT p_type;
    PF p_flags;
    Elf64_Off p_offset;
    Elf64_Addr p_vaddr;
    Elf64_Addr p_paddr;
    Elf64_Xword p_filesz;
    Elf64_Xword p_memsz;
    Elf64_Xword p_align;
    
    if (p_offset >= 0 && p_filesz > 0 && (p_offset + p_filesz) <= std::mem::size() && p_filesz <= std::mem::size())
        u8 p_data[p_filesz] @ p_offset [[sealed]];
};

struct Elf32_Chdr {
    u32 ch_type;
    Elf32_Word ch_size;
    Elf32_Word ch_addralign;
};

struct Elf32_Rel {
    Elf32_Off r_offset;
    ELF32_R_INFO r_info;
};

struct Elf32_Rela {
    Elf32_Off r_offset;
    ELF32_R_INFO r_info;
    Elf32_Sword r_addend;
};

struct Elf32_Sym {
    u32 st_name;
    Elf32_VAddr st_value;
    Elf32_Word st_size;
    ST st_info;
    STV st_other;
    u16 st_shndx;
};

struct Elf32_Syminfo {
    u16 si_boundto;
    SYMINFO_FLG si_flags;
};

s64 stringTableIndex;

struct String {
	char value[];
} [[sealed, format("format_string")]];

fn format_string(String string) {
	return string.value;
};

struct Elf32_Shdr {
    u32 sh_name;
    SHT sh_type;
    SHF sh_flags;
    u32 sh_addr;
    u32 sh_offset;
    Elf32_Word sh_size;
    Elf32_Word sh_link;
    Elf32_Word sh_info;
    Elf32_Word sh_addralign;
    Elf32_Word sh_entsize;
    
    if (sh_size > 0 && sh_offset + sh_size < std::mem::size()) {
    	if (sh_type == SHT::NOBITS || sh_type == SHT::NULL) {
		// Section has no data
		} else if (sh_type == SHT::STRTAB) {
			String stringTable[while($ < (sh_offset + sh_size))] @ sh_offset;
			stringTableIndex = std::core::array_index();	
		} else if (sh_type == SHT::SYMTAB || sh_type == SHT::DYNSYM) {
			Elf32_Sym symbolTable[sh_size / sh_entsize] @ sh_offset;
		} else if (sh_type == SHT::INIT_ARRAY || sh_type == SHT::FINI_ARRAY) {
			u32 pointer[while($ < (sh_offset + sh_size))] @ sh_offset;
		} else {
			u8 data[sh_size] @ sh_offset [[sealed]];
		}
    }
} [[format("format_section_header")]];;

struct Elf64_Chdr {
    u32 ch_type;
    Elf64_Word ch_size;
    Elf64_Word ch_addralign;
};

struct Elf64_Rel {
    Elf64_Off r_offset;
    ELF64_R_INFO r_info;
};

struct Elf64_Rela {
    Elf64_Off r_offset;
    ELF64_R_INFO r_info;
    Elf64_Sxword r_addend;
};

struct Elf64_Sym {
    u32 st_name;
    ST st_info;
    STV st_other;
    u16 st_shndx;
    Elf64_VAddr st_value;
    Elf64_Xword st_size;
};

struct Elf64_Syminfo {
    u16 si_boundto;
    SYMINFO_FLG si_flags;
};

struct Elf64_Shdr {
    u32 sh_name;
    SHT sh_type;
    SHF sh_flags;
    padding[4];
    u64 sh_addr;
    u64 sh_offset;
    Elf64_Xword sh_size;
    Elf64_Word sh_link;
    Elf64_Word sh_info;
    Elf64_Xword sh_addralign;
    Elf64_Xword sh_entsize;
    
    if (sh_size > 0 && sh_offset + sh_size < std::mem::size()) {
    	if (sh_type == SHT::NOBITS || sh_type == SHT::NULL) {
			// Section has no data
		} else if (sh_type == SHT::STRTAB) {
			String stringTable[while($ < (sh_offset + sh_size))] @ sh_offset;
			stringTableIndex = std::core::array_index();	
		} else if (sh_type == SHT::SYMTAB || sh_type == SHT::DYNSYM) {
			Elf64_Sym symbolTable[sh_size / sh_entsize] @ sh_offset;
		} else if (sh_type == SHT::INIT_ARRAY || sh_type == SHT::FINI_ARRAY) {
			u32 pointer[while($ < (sh_offset + sh_size))] @ sh_offset;
		} else {
			u8 data[sh_size] @ sh_offset [[sealed]];
		}
    }
} [[format("format_section_header")]];

fn format_section_header(auto shdr) {
	u32 i = 0;
	
	u32 nameAddress = addressof(elf.shdr[stringTableIndex].stringTable) + shdr.sh_name;
	String string @ nameAddress;

	return string;
};


struct ELF {
	E_IDENT e_ident;
	
	if (e_ident.EI_DATA == EI_DATA::ELFDATA2LSB)
		std::core::set_endian(std::mem::Endian::Little);
	else
		std::core::set_endian(std::mem::Endian::Big);
	
	if (e_ident.EI_CLASS == EI_CLASS::ELFCLASS32) {
		Elf32_Ehdr ehdr;
		Elf32_Phdr phdr[ehdr.e_phnum] @ ehdr.e_phoff;
		Elf32_Shdr shdr[ehdr.e_shnum] @ ehdr.e_shoff;
	} else if (e_ident.EI_CLASS == EI_CLASS::ELFCLASS64) {
		Elf64_Ehdr ehdr;
		Elf64_Phdr phdr[ehdr.e_phnum] @ ehdr.e_phoff;
		Elf64_Shdr shdr[ehdr.e_shnum] @ ehdr.e_shoff;
	}
};

ELF elf @ 0x00;


fn gen_shdr_disp_name(ref auto pattern, str member_name, u8 member_index) {
    return std::format(
        "{}@shdr[{}]({})",
        member_name,
        member_index,
        format_section_header(pattern)
    );
};

fn gen_shdr_sub_disp_name(ref auto pattern, str member_name, u8 member_index, u64 submember_index) {
    return std::format(
        "{}[{}]@shdr[{}]({})",
        member_name,
        submember_index,
        member_index,
        format_section_header(pattern)
    );
};

fn gen_phdr_disp_name(ref auto pattern, str member_name, u8 member_index) {
    return std::format(
        "{}@phdr[{}]({})",
        member_name,
        member_index,
        pattern.p_type
    );
};

bool displaySectionNames in;

fn main() {
    if (!displaySectionNames)
        return;

    for (u32 i = 0, i < std::core::member_count(elf.shdr), i += 1) {
        if (std::core::has_member(elf.shdr[i], "stringTable")) {
            std::core::set_display_name(
                elf.shdr[i].stringTable,
                gen_shdr_disp_name(elf.shdr[i], "stringTable", i)
            );
            for (u64 j = 0, j < std::core::member_count(elf.shdr[i].stringTable), j += 1) {
                std::core::set_display_name(
                    elf.shdr[i].stringTable[j],
                    gen_shdr_sub_disp_name(elf.shdr[i], "String", i, j)
                );
            }
        } else if (std::core::has_member(elf.shdr[i], "symbolTable")) {
            std::core::set_display_name(
                elf.shdr[i].symbolTable,
                gen_shdr_disp_name(elf.shdr[i], "symbolTable", i)
            );
        } else if (std::core::has_member(elf.shdr[i], "pointer")) {
            std::core::set_display_name(
                elf.shdr[i].pointer,
                gen_shdr_disp_name(elf.shdr[i], "pointer", i)
            );
        } else if (std::core::has_member(elf.shdr[i], "data")) {
            std::core::set_display_name(
                elf.shdr[i].data,
                gen_shdr_disp_name(elf.shdr[i], "data", i)
            );
        }
    }

    for (u32 i = 0, i < std::core::member_count(elf.phdr), i += 1) {
        if (std::core::has_member(elf.phdr[i], "p_data")) {
            std::core::set_display_name(
                elf.phdr[i].p_data,
                gen_phdr_disp_name(elf.phdr[i], "p_data", i)
            );
        }
    }
};
