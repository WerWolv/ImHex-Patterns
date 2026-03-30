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

struct FileDataEntry {
    u32 nameOffset;
    char name[] @ nameOffset;
    u32 folderOffset;
    char folder[] @ folderOffset;
    le u32 fileDataOffset;
    padding[8];
    u32 sampleRate;
    u32 fileSize;
    u8 data[fileSize] @ fileDataOffset;
    #ifdef __IMHEX__
        hex::core::add_virtual_file(std::string::to_string(name) + ".binka", data);
    #endif
};

struct Index2Entry {
    u32 entryOffset;
    u32 fStructureOffset;
    FileDataEntry fileDataEntry @ entryOffset;
};

struct MsscmpEntry {
    char name[12];
    Index2Entry entries[parent.header.index2EntryCount] @ parent.header.index1LastEntryOffset + 4;
};

struct msscmp_header32 {
  padding[4]; // unk
  u32 fileDataOffset;
  padding[8]; // unk
  u32 index1Offset;
  u32 index1LastEntryOffset;
  padding[8];
  u32 unkOffset;
  u32 index1EntryCount;
  padding[8];
  u32 index2EntryCount;
};

struct msscmp_header64 {
  padding[4]; // unk
  u64 fileDataOffset;
  padding[8]; // unk
  u64 index1Offset;
  u64 index1LastEntryOffset;
  padding[16];
  u64 unkOffset;
  u64 index1EntryCount;
  padding[4];
  u32 index2EntryCount;
};

struct MSSCMP {
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
  
  MsscmpEntry entry;
};

MSSCMP msscmp @ 0x00;
