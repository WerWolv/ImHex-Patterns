#pragma author ttimasdf
#pragma description BeyondCompare Snapshot (BCSS) file

#pragma magic [42 43 53 53] @ 0x00

#pragma array_limit 4294967295
#pragma pattern_limit 4294967295


import std.io;
import std.mem;
import std.array;
import std.string;
import type.magic;
import hex.dec;

#ifdef __IMHEX__
import hex.core;
#endif


const u8 max_path_size = 1000;
str current_path[max_path_size];
u8 current_path_level = 0;

enum EntryType : u8 {
    DIRECTORY   = 0x01,
    FILE        = 0x02,
    SYMLINK     = 0x03,
    // NULL        = 0x00,
    DIR_END     = 0xFF,
};

struct BCSSEntry {
    EntryType type;
    match (type) {
        (EntryType::DIRECTORY) : {
            // FileName name;
            std::string::SizedString<u8> name;
            if (name.size != 0) {
                u8 unknown[12];
                on_dir_enter(name.data);  // std::string::to_string(name)
            } else {
                // some buggy edge cases
                u8 unknown[6];
                std::warning(std::format("invalid empty entry current_lvl={} current_pos=0x{:02x}", current_path_level, $));
            }
        }
        (EntryType::FILE) : {
            std::string::SizedString<u8> name;
            if (name.size != 0) {
                u8 unknown[20];
                #ifdef __IMHEX__
                    hex::core::add_virtual_file(get_vfs_path(name), this);  // std::string::to_string(name)
                #endif
            } else {
                // some buggy edge cases
                u8 unknown[6];
                std::warning(std::format("invalid empty entry current_lvl={} current_pos=0x{:02x}", current_path_level, $));
            }
            //try {
            //    u8 unknown[20];
            //} catch {
            //    u8 unknown[0];
            //}
        }
        (EntryType::SYMLINK) : {
            std::string::SizedString<u8> name;
            u8 unknown[23];
            std::string::SizedString<u8> target;
            #ifdef __IMHEX__
                hex::core::add_virtual_file(get_vfs_path(name + " [s]"), this);  // std::string::to_string(name)
            #endif
        }
        (EntryType::DIR_END) : {
            on_dir_exit();
        }
        // (EntryType::NULL) : {
        //     // some buggy edge cases
        //     u8 unknown[7];
        //     std::warning(std::format("invalid empty entry current_lvl={} current_pos=0x{:02x}", current_path_level, $));
        // }
        (_): {
            std::error(std::format("unknown EntryType idx={} current_pos=0x{:02x}", std::core::array_index(), $));
        }
    }
}[[format_read("fmt_BCSSEntry")]];

fn on_dir_enter(str folder_name) {
    // std::print("on_dir_enter folder={} current_lvl={}", folder_name, current_path_level);
    if (std::string::length(folder_name) > 0) {
        current_path[current_path_level] = folder_name;
        current_path_level += 1;
    } else {
        std::warning(std::format("invalid folder name {} current_lvl={} current_pos=0x{:02x}", folder_name, current_path_level, $));
    }
};

fn on_dir_exit() {
    if (current_path_level > 0) {
        current_path_level -= 1;
    } else if (!std::mem::eof()) {
        std::warning(std::format("on_dir_exit current_lvl already == 0 current_pos=0x{:02x}", $));
    }
    // std::print("on_dir_exit current_lvl={}", current_path_level);
};

fn get_vfs_path(str file_name) {
    str vfs_path = "";
    if (current_path_level > 0) {
        vfs_path = current_path[0];
        for(u8 i = 1, i < current_path_level, i += 1) {
            //hash_hex = hash_hex + std::format("{:02X}",bytes[i]);
            vfs_path = vfs_path + "/" + current_path[i];
        }
        return vfs_path + "/" + file_name;
    } else {
        return file_name;
    }
};


fn fmt_BCSSEntry(BCSSEntry e) {
    try {
        match (e.type) {
            (EntryType::DIRECTORY | EntryType::FILE) : {
                return std::format("{}: {}", (e.type == EntryType::DIRECTORY ? "Dir" : "File"), e.name.data);
            }
            (EntryType::SYMLINK) : {
                return std::format("Symlink: {} -> {}", e.name.data, e.target.data);
            }
            (EntryType::DIR_END) : {
                return "Directory End";
            }
        }
    } catch {
        return "[FmtErr]";
    }
};

struct BCSSFile {
    if (std::mem::read_unsigned(0, 4) == 0x53534342) {
        type::Magic<"BCSS"> magic;
        u8 unknown[14];
        std::string::SizedString<u16> root_path;

        u8 zlib_content[std::mem::size()-$];

        // manually add zlib header which is essential for hex::dec::zlib_decompress
        const str zlib_header = "\x78\x9c";
        std::mem::Section zlib_compressed = std::mem::create_section("zlib_compressed");
        std::mem::copy_value_to_section(zlib_header, zlib_compressed, 0);
        std::mem::copy_value_to_section(zlib_content, zlib_compressed, 2);
        u8 zlib[std::mem::get_section_size(zlib_compressed)] @ 0x00 in zlib_compressed;

        std::mem::Section zlib_decompressed = std::mem::create_section("zlib_decompressed");
        hex::dec::zlib_decompress(zlib, zlib_decompressed, 15);
        u8 decompressed_content[std::mem::get_section_size(zlib_decompressed)] @ 0x00 in zlib_decompressed;
        #ifdef __IMHEX__
        hex::core::add_virtual_file("bcss_content", decompressed_content);
        #endif
        std::warning("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n! BCSS file content is compressed !\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nopen `bcss_content` file from the Virtual Filesystem tab and run this pattern on it.");
    } else {
        BCSSEntry entries[while(!std::mem::eof())];
    }
};

BCSSFile bcss_file @ 0x00;
