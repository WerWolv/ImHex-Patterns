// Apple macOS .DS_Store format
#pragma endian big
#include <std/io.pat>

struct RecordEntry {
  u32 length;
  char16 filename[length];
  
  char id[4];
  // either blob or length
  char type[4];
  
  if (type == "blob") {
    u32 blobCount;
    u8 blobData[blobCount];
  }
  else if (type == "long") {
    u32 value;
  }
  else if (type == "shor") {
    u32 value;
  }
  else if (type == "bool") {
    u8 value;
  }
};

struct TreeBlock {
  u32 mode;
  u32 count;
  RecordEntry entries[count];
};

struct BuddyRootBlockOffsets {
  u32 count;
  u8 reserved[4];
  u32 addresses[count];
  padding[(1024 - (count * 4))];
};

struct BuddyTableOfContentEntry {
  u8 count;
  char name[count];
  u32 value;
};

struct BuddyTableOfContents {
  u32 count;
  BuddyTableOfContentEntry toc[count];
};

struct BuddyFreeList {
  u32 count;
  u32 offsets[count];
};

struct BuddyRootBlock {
  BuddyRootBlockOffsets offsets;
  BuddyTableOfContents toc;
  BuddyFreeList freelists[32];
};

struct BuddyBlock {
  u32 blockCount;
  u8 reserved[4];
  // padding for next multiple of 256 entries (1024 bytes)
  u32 addresses[blockCount];
  
  // u8 padding[paddingCount];
  u32 directoryCount;
  
  // directory entries
  u8 count;
  u8 name[count];
  u32 blockNumber;
  
  // free lists
  // 32 free lists
  BuddyRootBlockOffsets off[32];
};

struct BlocksList {
  u32 blockId [[color("E57373")]];
  u32 internalBlocks [[color("80CBC4")]];
  u32 countRecords [[color("ffeb3b")]];
  u32 countBlocks [[color("64b5f6")]];
  u32 reserved [[color("a1887f")]];
};

struct BuddyAllocator {
  char header[4];
  u32 offsetBookkeeping;
  u32 sizeBookkeeping;
  u32 offsetBookkeeping2;
  u32 offsetData;
  u8 reserved[12];
  
  BuddyRootBlock root @ offsetBookkeeping + 4;

  std::print("TOC {} address 0x{:08x}",
    root.toc.toc[0].value,
    root.offsets.addresses[root.toc.toc[0].value] >> 0x5 << 0x5);

  BlocksList blocks @ (root.offsets.addresses[root.toc.toc[0].value] >> 0x5 << 0x5) + 4;
  
  std::print("Blocks start at address 0x{:08x}, size 0x{:04x}",
    root.offsets.addresses[blocks.blockId] >> 0x5 << 0x5,
    1 << (root.offsets.addresses[blocks.blockId] & 0x1f));

  TreeBlock entries @ (root.offsets.addresses[blocks.blockId] >> 0x5 << 0x5) + 4;
};

BuddyAllocator buddy @0x04;
