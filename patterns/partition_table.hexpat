#pragma author RadxaYuntian
#pragma description Master Boot Record & GUID Partition Table
#pragma endian little

import type.base;
import type.guid;

#ifndef SECTOR_SIZE
#define SECTOR_SIZE 512
#endif

bitfield CHSAddress {
    u8 head;
    sector : 6;
    cylinder: 10;
};

struct MBREntry {
    u8 status;
    CHSAddress first_chs;
    u8 type;
    CHSAddress last_chs;
    u32 first_lba;
    u32 sector_count;
};

struct MasterBootRecord {
    padding[446];
    MBREntry entries[4];
    type::Hex<u16> boot_signature;
    padding[SECTOR_SIZE - 512];
};

bitfield GPTAttributes {
    bool platform_required : 1;
    padding : 59;
    bool read_only : 1;
    bool shadow_copy : 1;
    bool hidden : 1;
    bool no_drive_letter : 1;
};

struct GPTEntry {
    type::GUID partition_type;
    type::GUID partition_guid;
    u64 first_lba;
    u64 last_lba;
    GPTAttributes attribute;
    char16 partition_name[36];
    padding[parent.entry_size - 128];
};

struct GUIDPartitionTable {
    char signature[8];  // "EFI PART"
    u16 version_minor;
    u16 version_major;
    u32 header_size;
    type::Hex<u32> header_crc32;   // from 0x0 to 0x5b
    u32 reserved;       // must be 0
    u64 current_lba;
    u64 backup_lba;
    u64 first_usable_lba;
    u64 last_usable_lba;
    type::GUID disk_guid;
    u64 entry_lba;
    u32 entry_count;
    u32 entry_size;
    type::Hex<u32> entry_crc32;
    padding[SECTOR_SIZE - 92]; // end of first LBA
    padding[SECTOR_SIZE * (entry_lba - current_lba - 1)]; // non-GPT data
    GPTEntry entries[entry_count];
};

MasterBootRecord mbr @ 0 * SECTOR_SIZE;
GUIDPartitionTable gpt @ 1 * SECTOR_SIZE;
