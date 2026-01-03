#pragma author gunjambi
#pragma description Portable ASCII CPIO
#pragma magic [ 30 37 30 37 30 37 ] @ 0x00

import std.time;
import std.string;

namespace portable_ascii {
    fn format_octal_time(str value) {
        return std::time::format(std::time::to_utc(std::string::parse_int(value, 8)));
    };
    fn parse_octal_string(str field) {
        return std::string::parse_int(field, 8);
    };

    struct Cpio {
        char c_magic[6];
        if (c_magic != "070707") {
            std::error("Invalid CPIO Magic!");
        }

        char c_dev[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_ino[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_mode[6];
        char c_uid[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_gid[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_nlink[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_rdev[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_mtime[11] [[format("portable_ascii::format_octal_time")]];
        char c_namesize[6] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];
        char c_filesize[11] [[format("portable_ascii::parse_octal_string"), transform("portable_ascii::parse_octal_string")]];

        char filename[c_namesize - 1];
        padding[1];
        if (filename == "TRAILER!!!")
            break;

        u8 data[c_filesize];
    };
}
portable_ascii::Cpio cpio[while(true)] @ 0x00;
