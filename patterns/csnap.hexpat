import std.io;
import std.time;
import type.time;

fn id_to_format(u32 format) {
    if (format == 0x008E) return "CF_DSPENHMETAFILE";
    if (format == 0x0083) return "CF_DSPMETAFILEPICT";
    if (format == 14) return "CF_ENHMETAFILE";
    if (format == 3) return "CF_METAFILEPICT";
    if (format == 2) return "CF_BITMAP";
    if (format == 0x0082) return "CF_DSPBITMAP";
    if (format == 9) return "CF_PALETTE";
    if (format == 8) return "CF_DIB";
    if (format == 17) return "CF_DIBV5";
    if (format == 0x0081) return "CF_DSPTEXT";
    if (format == 7) return "CF_OEMTEXT";
    if (format == 1) return "CF_TEXT";
    if (format == 13) return "CF_UNICODETEXT";
    if (format == 15) return "CF_HDROP";
    if (format == 5) return "CF_DIF";
    if (format == 16) return "CF_LOCALE";
    if (format == 0x0080) return "CF_OWNERDISPLAY";
    if (format == 10) return "CF_PENDATA";
    if (format == 11) return "CF_RIFF";
    if (format == 4) return "CF_SYLK";
    if (format == 6) return "CF_TIFF";
    if (format == 12) return "CF_WAVE";
    
    return std::format("0x{:X} ({})", format, format);
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