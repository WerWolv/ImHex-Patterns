/*
 * ImHex Pattern for UEFI Firmware Volume Variable Store
 *
 * This file type is commonly used with virtual machine UEFI variable files, like OVMF.fd
 * used with QEMU. You could also extract a UEFI firmware binary from a flash device,
 * search for the FV Variable Store, and set this pattern to the FV address.
 *
 *  A 'custom_vars.fd' can be generated with these tools:
 *
 * https://gitlab.com/kraxel/virt-firmware
 * https://github.com/rhuefi/qemu-ovmf-secureboot/tree/master
 * https://github.com/LongSoft/UEFITool
 *
 * 1. Generate a blank .fd file with ovmfvartool.
 *
 *   $ ovmfvartool generate-blank blank.fd
 *
 * 2. Enroll the Redhat and Microsoft keys with virt-fw-vars in custom_vars.fd.
 *
 *   $ virt-fw-vars -i blank.fd -o custom_vars.fd --enroll-redhat --secure-boot
 *
 * 3. Dump custom_vars.fd contents
 *
 *   $virt-fw-vars -i custom_vars.fd -pvx
 *
 *  or
 *
 *   $ uefitool custom_vars.fd
 *
 * or use this pattern with ImHex!
 */

#pragma author Marc Jones
#pragma UEFI Firmware Volume Variable Store
// #pragma debug

import std.core;
import std.mem;
import type.guid;


// --- GUIDs ---

#define NVRAM_FV       "{FFF12B8D-7696-4C8B-A985-2747075B4F50}"
#define NVRAM_VARSTORE "{AAF32C78-947B-439A-A180-2E144EC37792}"


// --- Enumerations and Bitfields ---

// Describes the type of a file within the Firmware File System.
enum FfsFileType : u8 {
    RAW             = 0x01,
    FREEFORM        = 0x02,
    SECURITY_CORE   = 0x03,
    PEI_CORE        = 0x04,
    DXE_CORE        = 0x05,
    PEIM            = 0x06,
    DRIVER          = 0x07,
    COMBINED_PEIM_DRIVER = 0x08,
    APPLICATION     = 0x09,
    SMM             = 0x0A,
    FIRMWARE_VOLUME_IMAGE = 0x0B,
    COMBINED_SMM_DXE = 0x0C,
    SMM_CORE        = 0x0D,
    FFS_PAD         = 0xF0,
};

// Attributes for a UEFI variable, indicating its properties and accessibility.
bitfield VariableAttributes{
    NON_VOLATILE : 1;
    BOOTSERVICE_ACCESS : 1;
    RUNTIME_ACCESS : 1;
    HARDWARE_ERROR_RECORD : 1;
    AUTHENTICATED_WRITE_ACCESS : 1;
    TIME_BASED_AUTHENTICATED_WRITE_ACCESS : 1;
    APPEND_WRITE : 1;
    RSVD: 25;
};

//
// Variable Store Header Format & State flags
//
enum VariableStoreFormat : u8 {
    VARIABLE_STORE_FORMATTED =         0x5a,
};

enum VariableStoreState : u8 {
    VARIABLE_STORE_HEALTHY =           0xfe,
};


//
// Variable State flags. See https://countchu.blogspot.com/2014/09/the-life-cycle-of-uefi-variable-in.html
//
enum VariableState : u8 {
    VAR_IN_DELETED_TRANSITION =  0xfe,
    VAR_DELETED               =  0xfd,
    VAR_HEADER_VALID_ONLY     =  0x7f,
    VAR_ADDED                 =  0x3f,
    VAR_ADDED__VAR_IN_DELETED_TRANSITION__VAR_DELETED = 0x3c,
    VAR_ADDED__VAR_IN_DELETED_TRANSITION = 0x3e,
    VAR_ADDED__VAR_DELETED = 0x3d,
};


// --- Other Structures ---

struct EFI_TIME {
    u16 Year;
    u8  Month;
    u8  Day;
    u8  Hour;
    u8  Minute;
    u8  Second;
    u8  Pad1;
    u32 Nanosecond;
    u16 TimeZone;
    u8  Daylight;
    u8  Pad2;
};


// --- Firmware Volume Structures ---

// Header for a block in the firmware volume map.
struct EFI_FV_BLOCK_MAP_ENTRY {
    u32 NumBlocks;
    u32 Length;
};

// The main header for a Firmware Volume.
struct EFI_FIRMWARE_VOLUME_HEADER {
    u128 ZeroVector;
    type::GUID FileSystemGuid;
    u64 FvLength;
    u32 Signature;
    u32 Attributes;
    u16 HeaderLength;
    u16 Checksum;
    u16 ExtHeaderOffset;
    u8 Reserved;
    u8 Revision;
    EFI_FV_BLOCK_MAP_ENTRY BlockMap[while(std::mem::read_unsigned($, 4) != 0 || std::mem::read_unsigned($ + 4, 4) != 0)];
    EFI_FV_BLOCK_MAP_ENTRY BlockMapTerminator; // After the loop, explicitly parse the (0,0) terminator entry
}[[single_color]];


// --- UEFI Variable Structures ---

struct VARIABLE_STORE_HEADER {
    type::GUID Signature;
    u32 Size;
    VariableStoreFormat Format;
    VariableStoreState State;
    u16 Reserved;
    u32 Reserved1;
}[[single_color]];


#define VAR_START_ID 0x55AA

struct VARIABLE_HEADER {
    u16 StartId;
    VariableState State;
    u8 Reserved;
    VariableAttributes Attributes;
    u32 NameSize;
    u32 DataSize;
    type::GUID VendorGuid;
};

struct AUTHENTICATED_VARIABLE_HEADER {
    u16 StartId;
    VariableState State;
    u8 Reserved;
    VariableAttributes Attributes;
    u64 MonotonicCount;
    EFI_TIME TimeStamp;
    u32 PubKeyIndex;
    u32 NameSize;
    u32 DataSize;
    type::GUID VendorGuid;
};

struct UEFI_VARIABLE {
    AUTHENTICATED_VARIABLE_HEADER Header; // TODO: Check authenticated vs normal variable...
    char16 Name[Header.NameSize / 2];     // Name is a UTF-16 string
    u8 Data[Header.DataSize];
    // Align to the next 4-byte boundary for the next variable.
    u8 pad[std::mem::align_to(4, sizeof(this)) - sizeof(this)];
} [[name(this.Name), single_color]];


// --- Main Pattern Entry Point ---

EFI_FIRMWARE_VOLUME_HEADER FV_Header @ 0;

if (std::core::formatted_value(FV_Header.FileSystemGuid) != "{FFF12B8D-7696-4C8B-A985-2747075B4F50}") {
  std::error(std::format("Unknown FV_Header.FileSystemGuid {}", std::core::formatted_value(FV_Header.FileSystemGuid)));
}

// The next structure should be the Variable Store Header
VARIABLE_STORE_HEADER VarStore @ $;

if (std::core::formatted_value(VarStore.Signature) != NVRAM_VARSTORE) {
  std::error(std::format("Unknown VarStore.Signature {}", std::core::formatted_value(VarStore.Signature)));
}

// Index through the Uefi variables until we don't find a Variable Signature 0x55AA
UEFI_VARIABLE UefiVars[while(std::mem::read_unsigned($, 2) == VAR_START_ID)] @ $;

// TODO: grey out the Uefi variables that are in the non-active state, != VAR_ADDED.
