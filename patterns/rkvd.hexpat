#pragma description Rockchip Vendor Storage
#pragma author Tom Roozen

import std.io;
import std.mem;
// See explanation in the Header struct.
// import type.magic;
#pragma pattern_limit 0
#pragma array_limit 65536
#pragma endian little
#pragma magic [ 44 56 4B 52 ] @ 0x00

// Amount of items (used to calculate the data offset).
// Example for eMMC/NAND: 126
// Example for NOR flash: 62
u64 item_num in;
// In bytes: part_blocks * block_size.
// Example for eMMC/NAND: 128 * 512 = 0x10000 = 65536
// Example for NOR flash: 8 * 512 = 0x1000 = 4096
u64 size in;

struct Item {
    u16 id;
    u16 offset;
    u16 size;
    u16 flag;
};

struct Header {
    // Sadly cannot use `type::Magic` since the sizeof(Header) statement below
    // when calculating the `data` offset requires the parser to know the static
    // size of the type. `type::Magic` is dynamic in the sense that its size is
    // based off of the value of the template.
    //
    // type::Magic<"DVKR"> tag;
    char tag[4];
    u32 version;
    u16 next_index;
    u16 total_items;
    u16 free_offset;
    u16 free_size;
};

fn calculate_data_size() {
    u64 result = 0;
    for (u16 i = 0, i < parent.header.total_items, i = i + 1)
    {
        result += parent.item[i].size;
    }
    return result;
};

struct VendorStorage {
    Header header;
    Item item[header.total_items];

    char data[calculate_data_size()] @ vendor_storage_offset + sizeof(Header) + item_num * sizeof(Item);

    u32 hash @ vendor_storage_offset + size - 0x08;
    u32 version2 @ vendor_storage_offset + size - 0x04;
};

if (item_num == 0) {
    std::error(
        "Please configure the `item_num` property in the settings\n" +
        "The default configuration for eMMC/NAND would be 126\n" +
        "The default configuration for NOR flash would be 62"
    );
}
if (size == 0) {
    std::error(
        "Please configure the total `size` property (in bytes) in the settings\n" +
        "The default configuration for eMMC/NAND would be 65536\n" +
        "The default configuration for NOR flash would be 4096"
    );
}

auto vendor_storage_offset = std::mem::find_string(0, "DVKR");
VendorStorage vendor_storage @ vendor_storage_offset;