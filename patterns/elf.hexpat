#pragma MIME application/x-executable
#pragma MIME application/x-sharedlib

namespace elf {

  enum Class : u8 {
    _32Bit = 1,
    _64Bit = 2
  };
  
  enum Endian : u8 {
    Little 	= 1,
    Big 	  = 2
  };
  
  enum OSABI : u8 {
    SystemV             = 0x00,
    HP_UX               = 0x01,
    NetBSD              = 0x02,
    Linux               = 0x03,
    GNU_Hurd            = 0x04,
    Solaris             = 0x06,
    AIX                 = 0x07,
    IRIX                = 0x08,
    FreeBSD             = 0x09,
    Tru64               = 0x0A,
    NovellModesto       = 0x0B,
    OpenBSD             = 0x0C,
    OpenVMS             = 0x0D,
    NonStop_Kernel      = 0x0E,
    AROS                = 0x0F,
    FenixOS             = 0x10,
    CloudABI            = 0x11,
    Stratus_Technologies_OpenVOS  = 0x12
  };
  
  enum Type : u16 {
    NONE    = 0x00,
    REL     = 0x01,
    EXEC    = 0x02,
    DYN     = 0x03,
    CORE    = 0x04,
    LOOS    = 0xFE00,
    HIOS    = 0xFEFF,
    LOPROC  = 0xFF00,
    HIPROC  = 0xFFFF
  };
  
  enum Machine : u16 {
    Undefined                 = 0x00,
    ATNT_WE_32100             = 0x01,
    SPARC                     = 0x02,
    x86                       = 0x03,
    Motorola_68000            = 0x04,
    Motorola_88000            = 0x05,
    IntelMCU                  = 0x06,
    Intel_80860               = 0x07,
    MIPS                      = 0x08,
    IBM_System370             = 0x09,
    MIPS_RS300_LE             = 0x0A,
    /* 0x0B - 0x0D: Reserved */
    HP_PA_RISC                = 0x0E,
    /* 0x0F: Reserved */
    Intel_80960               = 0x13,
    PowerPC                   = 0x14,
    PowerPC_64                = 0x15,
    S390                      = 0x16,
    IBM_SPU_SPC               = 0x17,
    /* 0x18 - 0x23: Reserved */
    NEC_V800                  = 0x24,
    Fujitsu_FR20              = 0x25,
    TRW_RH_32                 = 0x26,
    Motorola_RCE              = 0x27,
    ARM32                     = 0x28,
    Digital_Alpha             = 0x29,
    SuperH                    = 0x2A,
    SPARCv9                   = 0x2B,
    Siemens_TriCore           = 0x2C,
    Argonaut_RISC_Core        = 0x2D,
    Hitachi_H8_300            = 0x2E,
    Hitachi_H8_300H           = 0x2F,
    Hitachi_H8S               = 0x30,
    Hitachi_H8_500            = 0x31,
    IA_64                     = 0x32,
    Standford_MIPS_X          = 0x33,
    Motorola_ColdFire         = 0x34,
    Motorola_M68HC12          = 0x35,
    Fujitsu_MMA               = 0x36,
    Siemens_PCP               = 0x37,
    Sony_nCPU                 = 0x38,
    Denso_NDR1                = 0x39,
    Motorola_StarCore         = 0x3A,
    Toyota_ME16               = 0x3B,
    STMicroelectronics_ST100  = 0x3C,
    Advanced_Logic_Corp_TinyJ = 0x3D,
    AMD_x86_64                = 0x3E,
    TMS320C6000               = 0x8C,
    MCST_Elbrus_e2k           = 0xAF,
    ARM64                     = 0xB7,
    RISC_V                    = 0xF3,
    Berkeley_Packet_Filter    = 0xF7,
    WDC_65C816                = 0x101
  };
  
  struct Identity {
    char magic[4];
    Class class;
    Endian endian;
    u8 version;
    OSABI os_abi;
    
    if (os_abi == elf::OSABI::Linux)
      u8 dynamic_linker_version;
    else
      u8 abi_version;
  };

  struct Header {
    Identity identity;
    padding[7];
    Type type;
    Machine machine;
    u32 version;
    
    if (identity.class == elf::Class::_32Bit) {
      u32 entry_point;
      u32 program_header_offset;
      u32 section_header_offset;
    } else {
      u64 entry_point;
      u64 program_header_offset;
      u64 section_header_offset;
    }
    
    u32 flags;
    
    u16 elf_header_size;
    u16 program_header_entry_size;
    u16 program_header_entry_count;
    u16 section_header_entry_size;
    u16 section_header_entry_count;
    u16 section_name_entry_id;
  };

}

namespace program {

  enum Type : u32 {
    NULL    = 0x00,
    LOAD    = 0x01,
    DYNAMIC = 0x02,
    INTERP  = 0x03,
    NOTE    = 0x04,
    SHLIB   = 0x05,
    PHDR    = 0x06,
    TLS     = 0x07,
    LOOS    = 0x60000000,
    HIOS    = 0x6FFFFFFF,
    LOPROC  = 0x70000000,
    HIPROC  = 0x7FFFFFFF
  };

  struct Header {
    Type type;
    
    if (parent.header.identity.class == elf::Class::_32Bit) {
      u32 offset;
      u32 virtual_address;
      u32 physical_address;
      u32 file_size;
      u32 memory_size;
      u32 flags;
      u32 alignment;
    } else {
      u32 flags;
      u64 offset;
      u64 virtual_address;
      u64 physical_address;
      u64 file_size;
      u64 memory_size;
      u64 alignment;
    }
  } [[static]];

}

namespace section {

  struct String {
    char characters[];
  };
  
  enum Type : u32 {
    NULL          = 0x00,
    PROGBITS      = 0x01,
    SYMTAB        = 0x02,
    STRTAB        = 0x03,
    RELA          = 0x04,
    HASH          = 0x05,
    DYNAMIC       = 0x06,
    NOTE          = 0x07,
    NOBITS        = 0x08,
    REL           = 0x09,
    SHLIB         = 0x0A,
    DYNSYM        = 0x0B,
    INIT_ARRAY    = 0x0E,
    FINI_ARRAY    = 0x0F,
    PREINIT_ARRAY = 0x10,
    GROUP         = 0x11,
    SYMTAB_SHNDX  = 0x12,
    NUM           = 0x13,
    LOOS          = 0x60000000
  };
  
  bitfield Flags {
    WRITE             : 1;
    ALLOC             : 1;
    EXECINSTR         : 1;
    pad1              : 1;
    MERGE             : 1;
    STRINGS           : 1;
    INFO_LINK         : 1;
    LINK_ORDER        : 1;
    OS_NONCONFORMING  : 1;
    GROUP             : 1;
    TLS               : 1;
  };

  struct Header {
    u32 name_offset;
    section::Type type;
    Flags flags;
    padding[2];
    
    if (parent.header.identity.class == elf::Class::_32Bit) {
      u32 address;
      u32 offset;
      u32 size;
      u32 link;
      u32 info;
      u32 address_alignment;
      u32 entry_size;
    } else {
      padding[4];
      u64 address;
      u64 offset;
      u64 size;
      u32 link;
      u32 info;
      u64 address_alignment;
      u64 entry_size;
    }
  } [[static]];

}


elf::Header header @ 0x00;
program::Header program_headers[header.program_header_entry_count] @ header.program_header_offset;
section::Header section_headers[header.section_header_entry_count] @ header.section_header_offset;