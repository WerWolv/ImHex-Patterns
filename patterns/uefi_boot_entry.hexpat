// subsections in this pattern refer to subsections in the
// UEFI Specification Release 2.10 from Aug 29 2022

#pragma author iTrooz
#pragma description UEFI Boot Entry (Load option)

import std.io;
import type.guid;

// subsection 10.3.5.1
struct HARD_DRIVE {
    u32 partitionNumber;
    u64 partitionStart;
    u64 partitionSize;
    type::GUID partitionSig;
    u8 format;
    u8 sigType;
};

// subsection 10.3.5.4
struct FILE_PATH {
    char16 path[];
};

// subsection 10.3.1
enum MEDIA_DEVICE_PATH_SUBTYPE : u8 {
  HARD_DRIVE = 0x01,
  FILE_PATH = 0x04,
};

enum DEVICE_PATH_TYPE : u8 {
    MEDIA_DEVICE_PATH = 0x04,
};

// subsection 10.2
// EFI_DEVICE_PATH_PROTOCOL
struct DEVICE_PATH {
    u8 type;
    u8 subtype;
    // length of this DEVICE_PATH structure
    u16 length;
    // the size of the data is the size of the structure minus the fields we know.
    // not always used
    u16 dataSize = length-1-1-2;

    match (type, subtype) {
        (DEVICE_PATH_TYPE::MEDIA_DEVICE_PATH, MEDIA_DEVICE_PATH_SUBTYPE::HARD_DRIVE): HARD_DRIVE data;
        (DEVICE_PATH_TYPE::MEDIA_DEVICE_PATH, MEDIA_DEVICE_PATH_SUBTYPE::FILE_PATH): FILE_PATH data;
        (_, _): u8 data[dataSize];
    }
};

// subsections 3.1.3
// EFI_LOAD_OPTION
struct LOAD_OPTION {
    u32 attributes;
    // length of the filePathList data
    u16 filePathLength;
    char16 description[];

    u64 startOffset = $;
    DEVICE_PATH filePathList[while($ - startOffset < filePathLength)];
    u8 optionalData;
};

// on Linux, variables are found in /sys/firmware/efi/efivars,
// and will be prefixed by their attributes
struct EFI_VAR {
    u32 attributes;
    LOAD_OPTION loadOption;
};


EFI_VAR data @0x0;
