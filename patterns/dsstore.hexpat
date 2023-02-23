// Apple macOS .DS_Store format
#pragma endian big

struct BuddyAllocator {
  char header[4];
  u32 offsetBookkeeping;
  u32 sizeBookkeeping;
  u32 offsetBookkeeping2;
  u8 reserved[16];
};

BuddyAllocator buddy @0x04;
