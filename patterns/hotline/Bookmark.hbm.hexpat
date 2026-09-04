#pragma author Scott Anderson
#pragma description Hotline Client bookmark
#pragma magic [ 48 54 73 63 ] @ 0x00
#pragma endian big
#pragma encoding mac

import type.magic;
import type.size;

struct hl_bookmark_string {
    u16 len;
    char data[len];
    if (len < 32) padding[32 - len];
} [[sealed, format("format_string")]];

fn format_string(auto string) {
    return std::format("\"{}\"", type::escape_bytes(string.data));
};

struct hl_bookmark {
    type::Magic<"HTsc"> magic;
    u16 version;
    padding[128];
    hl_bookmark_string login, password, addr;
    padding[40];
    u16 icon;
    hl_bookmark_string nick;
    padding[148];
};

hl_bookmark bookmark @ 0 [[inline]];
