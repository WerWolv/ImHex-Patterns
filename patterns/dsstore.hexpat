// Apple macOS .DS_Store format
#pragma endian big

struct StoreBlockEntry {
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

struct StoreBlockEntriesList {
  u16 count;
  StoreBlockEntry entries[count];
};

struct BuddyAllocator {
  char header[4];
  u32 offsetBookkeeping;
  u32 sizeBookkeeping;
  u32 offsetBookkeeping2;
  u32 offsetData;
  u8 reserved[12];
  
  StoreBlockEntriesList entries @ offsetData-2;
};

BuddyAllocator buddy @0x04;
