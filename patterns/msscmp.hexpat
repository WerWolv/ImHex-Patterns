#pragma author DexrnZacAttack
#pragma description MSSCMP (Miles Sound System Compressed Archive)
#pragma magic [ 42 41 4E 4B ] @ 0x00
#pragma magic [ 4B 4E 41 42 ] @ 0x00
#pragma array_limit 0
#pragma pattern_limit 0

import type.magic;
import std.core;
#ifdef __IMHEX__
    import hex.core;
#endif

struct msscmp_file_header {
  u32  pathaddr;
  char path[] @ pathaddr;
  u32  nameaddr;
  char name[] @ nameaddr +  parent.headeraddr;

  le u32 fileaddr;
  padding[8];
  u32 samplerate;
  u32 filesize;
};

struct msscmp_file {
  padding [4];
  u32 headeraddr;
  msscmp_file_header header @ headeraddr;
  u8 data[header.filesize] @ header.fileaddr;

  #ifdef __IMHEX__
    hex::core::add_virtual_file(std::string::to_string(header.name) + ".binka", data);
  #endif
};

struct msscmp_fileinfo
{
  u32  pathaddr;
  char path[] @ pathaddr;

  u32  infoaddr;
  char info[] @ infoaddr;
};

struct msscmp_header32 {
  padding [16];
  u32  infoaddr;
  padding [8];
  u32  entryaddr;
  padding [4];
  u32  infocount;
  padding [8];
  u32  entrycount;
  char name[];
};

struct msscmp_header64 {
  padding[20];
  u64  infoaddr;
  u64  infocount;
  padding[8];
  u64  entryaddr;
  padding[20];
  u64  entrycount;
  char name[];
};

struct msscmp {
  u32  check1 @ 0x18 [[hidden]];
  u32  check2 @ 0x1C [[hidden]];
  char magic[4];

  if (magic == "BANK")
    std::core::set_endian(std::mem::Endian::Big);
  else if (magic == "KNAB")
    std::core::set_endian(std::mem::Endian::Little);
  else
    std::error("Magic does not match BANK or KNAB");

  if (check1 == check2)
    msscmp_header32 header;
  else
    msscmp_header64 header;
  
  msscmp_file entries[header.entrycount] @ header.entryaddr;
  msscmp_fileinfo info[header.infocount] @ header.infoaddr;
};

msscmp file @ 0x00;