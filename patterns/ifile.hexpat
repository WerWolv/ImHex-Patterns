#pragma author RedHare-Exe
#pragma description Windows Recycling Bin $I file
#pragma magic [ 02 00 00 00 00 00 00 00 ] @ 0x00

import std.time;
import type.time;
import std.string;

using NullString16 = std::string::NullString16;

struct DelTime {
    u64 raw;
} [[format_read("parse_filetime")]];

fn parse_filetime(DelTime raw_ft) {
    // Convert raw FILETIME to Unix time
    u64 unix_time = type::impl::format_filetime_as_unix(raw_ft.raw);

    // Convert Unix time to structured UTC time
    std::time::Time ts = std::time::to_utc(unix_time);

    // Format as string
    str formatted = std::time::format(ts, "%Y-%m-%d %H:%M:%S");

    return formatted;
};

struct IFile {
    u64 Version;
    u64 Size;
    DelTime DelTime [[name("Deleted Time")]];
    u32 NameSize [[name("Size of Path in Characters")]];
    NullString16 Path;
};

IFile IFile @ 0x00;