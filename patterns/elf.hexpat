#pragma MIME application/x-executable

#define EI_NIDENT 16

using Elf32_Addr  = u32;
using Elf32_Half  = u16;
using Elf32_Off   = u32;
using Elf32_Sword = s32;
using Elf32_Word  = u32;

using Elf64_Addr  = u64;
using Elf64_Half  = u16;
using Elf64_Off   = u64;
using Elf64_Sword = s32;
using Elf64_Word  = u32;

struct Elf32_Ehdr {
  u8            e_ident[EI_NIDENT];
  Elf32_Half	e_type;
  Elf32_Half	e_machine;
  Elf32_Word	e_version;
  Elf32_Addr	e_entry;
  Elf32_Off	e_phoff;
  Elf32_Off     e_shoff;
  Elf32_Word	e_flags;
  Elf32_Half	e_ehsize;
  Elf32_Half	e_phentsize;
  Elf32_Half	e_phnum;
  Elf32_Half	e_shentsize;
  Elf32_Half	e_shnum;
  Elf32_Half	e_shstrndx;
};

struct Elf64_Ehdr {
  u8            e_ident[EI_NIDENT];
  Elf64_Half    e_type;
  Elf64_Half    e_machine;
  Elf64_Word    e_version;
  Elf64_Addr    e_entry;
  Elf64_Off     e_phoff;
  Elf64_Off     e_shoff;
  Elf64_Word    e_flags;
  Elf64_Half    e_ehsize;
  Elf64_Half    e_phentsize;
  Elf64_Half    e_phnum;
  Elf64_Half    e_shentsize;
  Elf64_Half    e_shnum;
  Elf64_Half    e_shstrndx;
};

