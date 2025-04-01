// Analyzed and reverse engineered by xtex
#pragma author xtex

#pragma description HiSilicon HSDT device-tree table
#pragma endian little
#pragma magic [ 48 53 44 54 ] @ 0x00

import std.sys;
import std.mem;

u32 dt_hdr_offset;
if (std::mem::read_unsigned(4096, 4, std::mem::Endian::Little) == 0x54445348) {
    // for DTS dumped from UPDATE.APP
    // everything is offseted 4096 bytes
    dt_hdr_offset = 0x1000;
} else {
    // for DTS dumped from Huawei device
    // /dev/block/bootdevice/by-name/dts
    dt_hdr_offset = 0;
}

struct dt_table_t {
    u32 magic [[comment("should always be 0x54445348")]];
    std::assert(magic == 0x54445348, "bad dt_table_t magic");
    u32 version [[comment("should always be 1")]];
    u32 num_entries;
};

struct dt_entry_t { // 0x28 bytes
    u8 board_id[4] [[sealed, format("format_board_id")]];
    // in my reverse project, undefined0 is always zero
    // and is not used by the fastboot
    u32 undefined0 [[sealed]];
    std::assert_warn(undefined0 == 0, "undefined0 is not zero");
    u32 dtb_len;
    // VRL is for verifying the DTB
    // set VRL to 0 to skip verifying
    u32 vrl_len;
    u32 dtb_offset;
    u32 vrl_offset;
    u8 undefined1[16] [[sealed]];

    // the real GZIPped DTB should start at dtb_offset + 4096
    u8 dtb[dtb_len] @ (dtb_offset + 4096 + dt_hdr_offset) [[sealed]];
    if (vrl_len != 0)
        u8 vrl[vrl_len] @ (vrl_offset + dt_hdr_offset) [[sealed]];
} [[format("format_dt_entry")]];

fn format_dt_entry(auto dt_entry) {
    if (dt_entry.vrl_len != 0) {
        return std::format(
            "{}, with VRL",
            format_board_id(dt_entry.board_id)
        );
    } else {
        return format_board_id(dt_entry.board_id);
    }
};

fn format_board_id(auto board_id) {
    return std::format(
        "<0x{:02x} 0x{:02x} 0x{:02x} 0x{:02x}>",
        board_id[0], board_id[1],
        board_id[2], board_id[3]
    );
};

dt_table_t dt_hdr @ (dt_hdr_offset + 0x0);
dt_entry_t dt_entries[dt_hdr.num_entries] @ (dt_hdr_offset + 0xc);
