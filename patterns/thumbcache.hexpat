#pragma author MrMcX
#pragma description Windows thumbcache files

#pragma magic [0x43 0x4D 0x4D 0x4D] @ 0x00

#pragma endian little
import std.mem;

enum WinVer : u32 {
    WIN_VISTA = 0x14,
    WIN_7     = 0x15,
    WIN_8     = 0x1A ... 0x1E,
    WIN_8_1   = 0x1F,
    WIN_10    = 0x20
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
    char signature[4];
    if (signature != "CMMM") {
        std::print("Thumbcache-Signatur ungültig: {}", signature);
        break; 
    }
    WinVer version;
    if(version == WinVer::WIN_VISTA || version == WinVer::WIN_7) {
        Win7Vista_Type type;
    } else if(version == WinVer::WIN_8) {
        Win8_Type type;
    } else if(version == WinVer::WIN_8_1) {
        Win81_Type type;
    } else if(version == WinVer::WIN_10) {
        Win10_Type type;
    }

    if(version == WinVer::WIN_8 || version == WinVer::WIN_8_1 || version == WinVer::WIN_10) {
        u32;
    }
    u32 header_size;
    u32 offset_to_first_empty;
    if(version == WinVer::WIN_VISTA || version == WinVer::WIN_7) {
        u32 count;
    }
};

struct CMMMRecord {
    char signature[4];
    if (signature != "CMMM") {
        std::print("CMMMRecord-Signatur ungültig: {}", signature);
        break; 
    }
    u32 size;
    u64 id1;
    
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
    
    if(name_size > 0) {
        char16 name[(name_size / 2)];
    }
    if(padding_size > 0) {
        u8 p[padding_size];
    }
    if(data_size > 0) {
        u8 data[data_size];
    }
    u8 zero[while(std::mem::read_unsigned($, 1) == 0x00)];
};

ThumbCacheHeader header @ 0x00;
CMMMRecord record[while(!std::mem::reached(header.offset_to_first_empty))] @ header.header_size;