#pragma author WerWolv
#pragma description Old Binary CPIO Format

import type.base;

import std.time;
import std.core;
import std.sys;
import std.mem;

#pragma MIME application/x-cpio

namespace old_binary {

    using Time = u32 [[format("old_binary::format_time")]];

    fn swap_32bit(u32 value) {
        return ((value >> 16) & 0xFFFF) | ((value & 0xFFFF) << 16);
    };

    fn format_time(u32 value) {
        return std::time::format(std::time::to_utc(swap_32bit(value)));
    };

    using SwappedU32 = u32 [[transform("old_binary::swap_32bit"), format("old_binary::swap_32bit")]];

    bitfield Mode {
        x           : 3;
        w           : 3;
        r           : 3;
        sticky      : 1;
        sgid        : 1;
        suid        : 1;
        file_type   : 4;
    };

    struct CpioHeader {
        type::Oct<u16> magic;
        if (magic == be u16(0o070707))
            std::core::set_endian(std::mem::Endian::Big);
        else if (magic == le u16(0o070707))
            std::core::set_endian(std::mem::Endian::Little);
        else
            std::error("Invalid CPIO Magic!");
        
        u16 dev;
        u16 ino;
        Mode mode;
        u16 uid;
        u16 gid;
        u16 nlink;
        u16 rdev;
        Time mtime;
        u16 namesize;
        SwappedU32 filesize;
    };

    struct Cpio {
        CpioHeader header;
        char pathname[header.namesize % 2 == 0 ? header.namesize : header.namesize + 1];
        u8 data[header.filesize % 2 == 0 ? header.filesize : header.filesize + 1];
        
        if (pathname == "TRAILER!!!\x00\x00")
            break;
    };

}

old_binary::Cpio cpio[while(true)] @ 0x00;
