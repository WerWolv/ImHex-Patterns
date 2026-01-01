#pragma author gunjambi
#pragma description "New" ASCII CPIO
#pragma magic [ 30 37 30 37 30 31 ] @ 0x00

import std.time;
import std.string;

namespace new_ascii {
    fn format_hex_time(str value) {
        return std::time::format(std::time::to_utc(std::string::parse_int(value, 16)));
    };
    fn parse_hex(str field) {
        return std::string::parse_int(field, 16);
    };

    struct Cpio {
        char c_magic[6];
        if (c_magic != "070701") {
            std::error("Invalid CPIO Magic!");
        }

        char c_ino[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_mode[8];
        char c_uid[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_gid[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_nlink[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_mtime[8] [[format("new_ascii::format_hex_time")]];
        char c_filesize[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_devmajor[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_devminor[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_rdevmajor[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_rdevminor[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_namesize[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];
        char c_check[8] [[format("new_ascii::parse_hex"), transform("new_ascii::parse_hex")]];

        char filename[c_namesize - 1];
        padding[1];
        if (filename == "TRAILER!!!")
            break;
        padding[(4 - ((6 + c_namesize) % 4)) % 4];

        u8 data[c_filesize];
        padding[(4 - (c_filesize % 4)) % 4];
    };
}
new_ascii::Cpio cpio[while(true)] @ 0x00;
