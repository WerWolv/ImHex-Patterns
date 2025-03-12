#pragma author MrMcX
#pragma description Windows thumbcache files
/*
Thanks to Joachim Metz for his work that helped improve the pattern:
https://github.com/libyal/libwtcdb/blob/main/documentation/Windows%20Explorer%20Thumbnail%20Cache%20database%20format.asciidoc
*/

#pragma magic [0x43 0x4D 0x4D 0x4D] @ 0x00

#pragma endian little
import std.mem;
import type.magic;
import hex.core;
import std.string;

enum WinVer : u32 {
    WIN_VISTA = 20,
    WIN_7     = 21,
    WIN_8     = 30,
    WIN_8_1   = 31,
    WIN_10    = 32
};

enum Win7Vista_Type : u32 {
    THUMBCACHE_32_DB             = 0x0,
    THUMBCACHE_96_DB             = 0x1,
    THUMBCACHE_256_DB            = 0x2,
    THUMBCACHE_1024_DB           = 0x3,
    THUMBCACHE_SR_DB             = 0x4    
};

enum Win8_Type: u32 {
    THUMBCACHE_16_DB             = 0x0,
    THUMBCACHE_32_DB             = 0x1,
    THUMBCACHE_48_DB             = 0x2,
    THUMBCACHE_96_DB             = 0x3,
    THUMBCACHE_256_DB            = 0x4,
    THUMBCACHE_1024_DB           = 0x5,
    THUMBCACHE_SR_DB             = 0x6,
    THUMBCACHE_WIDE_DB           = 0x7,
    THUMBCACHE_EXIF_DB           = 0x8
};

enum Win81_Type: u32 {
    THUMBCACHE_16_DB             = 0x0,
    THUMBCACHE_32_DB             = 0x1,
    THUMBCACHE_48_DB             = 0x2,
    THUMBCACHE_96_DB             = 0x3,
    THUMBCACHE_256_DB            = 0x4,
    THUMBCACHE_1024_DB           = 0x5,
    THUMBCACHE_1600_DB           = 0x6,
    THUMBCACHE_SR_DB             = 0x7,
    THUMBCACHE_WIDE_DB           = 0x8,
    THUMBCACHE_EXIF_DB           = 0x9,
    THUMBCACHE_WIDE_ALTERNATE_DB = 0xA
};

enum Win10_Type: u32 {
    THUMBCACHE_16_DB             = 0x0,
    THUMBCACHE_32_DB             = 0x1,
    THUMBCACHE_48_DB             = 0x2,
    THUMBCACHE_96_DB             = 0x3,
    THUMBCACHE_256_DB            = 0x4,
    THUMBCACHE_768_DB            = 0x5,
    THUMBCACHE_1280_DB           = 0x6,
    THUMBCACHE_1920_DB           = 0x7,
    THUMBCACHE_2560_DB           = 0x8,
    THUMBCACHE_WIDE_DB           = 0x9,
    THUMBCACHE_SR_DB             = 0xA,
    THUMBCACHE_EXIF_DB           = 0xB,
    THUMBCACHE_WIDE_ALTERNATE_DB = 0xC,
    THUMBCACHE_CUSTOM_STREAM_DB  = 0xD,
};

struct ThumbCacheHeader {
    type::Magic<"CMMM"> signature;
    WinVer version;
    if(version == WinVer::WIN_10) {
        Win10_Type type;
    } else if(version == WinVer::WIN_8_1) {
        Win81_Type type;
    } else if(version == WinVer::WIN_8) {
        Win8_Type type;
    } else if(version <= WinVer::WIN_7) {
        Win7Vista_Type type;
    } else {
        u32 type;
        std::print("Unknown cache type: {}", type);
    }

    if(version >= WinVer::WIN_8) {
        u32;
    }
    u32 header_size;
    u32 offset_to_first_empty;
    if(version <= WinVer::WIN_7) {
        u32 count;
    }
};

struct CacheRecord {
    char signature[4];
    if (signature != "CMMM") {
        std::warning(std::format("Invalid cache entry at 0x{:08x}, skipping: {} ", $, type::escape_bytes(signature)));
        padding[while(std::mem::read_string($, 4) != "CMMM")];
        continue; 
    }
    u32 size;
    u64 entry_hash;
    
    if(header.version == WinVer::WIN_VISTA) {
        char16 extension[4];
    }

    u32 name_size;
    u32 padding_size;
    u32 data_size;
    
    if(header.version == WinVer::WIN_10) {
        u32 width;
        u32 height;
    }
    
    u32;
    u64 data_checksum;
    u64 header_checksum;
    char16 name[(name_size / 2)];
    if(padding_size > 0) {
        padding[padding_size];
    }
    if(data_size > 0) {
        u8 data[data_size];
        if(data[0] == 0x42 && data[1] == 0x4D) {
            str suffix = ".bmp";
        } else if(data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF && data[3] == 0xE0) {
            str suffix = ".jpg";
        } else if(data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47) {
            str suffix = ".png"; 
        } else {
            str suffix = "";
            std::warning("Thumbnail file type unknown, no suffix added");
        }
        hex::core::add_virtual_file(std::string::to_string(name) + suffix, data);
    }
    padding[while(std::mem::read_unsigned($, 1) == 0x00)];
};

ThumbCacheHeader header @ 0x00;
CacheRecord records[while(!std::mem::reached(header.offset_to_first_empty))] @ header.header_size;
