#pragma endian little
#pragma magic 0x0F1B0A6D @ 0x00
#pragma author FireBlade
#pragma description ClipboardEdit Clipboard Snapshot format


import std.io;
import std.core;
import std.time;
import type.time;
import std.string;

enum ID : u32 {
    CF_TEXT = 1,
    CF_BITMAP,
    CF_METAFILEPICT,
    CF_SYLK,
    CF_DIF,
    CF_TIFF,
    CF_OEMTEXT,
    CF_DIB,
    CF_PALETTE,
    CF_PENDATA,
    CF_RIFF,
    CF_WAVE,
    CF_UNICODETEXT,
    CF_ENHMETAFILE,
    CF_HDROP,
    CF_LOCALE,
    CF_DIBV5,
    CF_OWNERDISPLAY = 0x80,
    CF_DSPTEXT,
    CF_DSPBITMAP,
    CF_DSPMETAFILEPICT,
    CF_DSPENHMETAFILE = 0x8E,
};

fn id_to_format(auto v) {
    ID id = v;
    str result = std::format("{}",id);
    u32 resultLength = std::string::length(result)-4;
    result = std::string::substr(result,4,resultLength);
    if (result == "???")
        return std::format("{:#X} {}",v,v);
    return result;
};

struct ClipboardEntry
{
    u32 format [[format("id_to_format")]];
    u32 length;
    u8 data[length];
};

fn to_utc(auto v) {
    type::time64_t unix_time = std::time::filetime_to_unix(v);
    return type::impl::format_time_t(unix_time);
};

struct ClipboardSnapshot
{
    u32 magic;
    u32 version;
    u32 count;

    ClipboardEntry entries[count];

    type::FILETIME filetimeTakenUtc [[format("to_utc")]];
};

ClipboardSnapshot snapshot @ 0x00;

if (snapshot.magic != 0x0F1B0A6D)
    std::error("Invalid Clipboard Snapshot file");