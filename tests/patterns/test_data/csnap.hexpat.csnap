import std.io;

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

const u64 FILETIME_EPOCH_DIFF = 116444736000000000;

fn filetime_to_unix(s64 ft)
{
    return (ft - FILETIME_EPOCH_DIFF) / 10000000;
};

fn is_leap(s32 year)
{
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
};

fn days_in_month(s32 month, s32 year)
{
    if (month == 1) return 31;
    if (month == 2) return is_leap(year) ? 29 : 28;
    if (month == 3) return 31;
    if (month == 4) return 30;
    if (month == 5) return 31;
    if (month == 6) return 30;
    if (month == 7) return 31;
    if (month == 8) return 31;
    if (month == 9) return 30;
    if (month == 10) return 31;
    if (month == 11) return 30;
    if (month == 12) return 31;
    return 30;
};

fn unix_to_datetime(s64 unix)
{
    s64 seconds = unix;
    s32 year = 1970;

    // compute year
    while (true)
    {
        s64 seconds_in_year = is_leap(year) ? 31622400 : 31536000;

        if (seconds >= seconds_in_year)
        {
            seconds -= seconds_in_year;
            year += 1;
        }
        else
        {
            break;
        }
    }

    // compute month
    s32 month = 1;

    while (true)
    {
        s64 dim = days_in_month(month, year) * 86400;

        if (seconds >= dim)
        {
            seconds -= dim;
            month += 1;
        }
        else
        {
            break;
        }
    }

    // day
    s32 day = (seconds / 86400) + 1;
    seconds = seconds % 86400;

    // time
    s32 hour = seconds / 3600;
    seconds = seconds % 3600;

    s32 minute = seconds / 60;
    s32 second = seconds % 60;

    return std::format(
        "{:04}-{:02}-{:02} {:02}:{:02}:{:02}",
        year, month, day, hour, minute, second
    );
};

fn filetime_to_string(s64 ft)
{
    return unix_to_datetime(filetime_to_unix(ft));
};

struct ClipboardSnapshot
{
    u32 magic;
    u32 version;
    u32 count;

    ClipboardEntry entries[count];

    s64 filetimeTakenUtc [[format("filetime_to_string")]];
};

ClipboardSnapshot snapshot @ 0x00;

if (snapshot.magic != 0x0F1B0A6D)
    std::error("Invalid Clipboard Snapshot file");