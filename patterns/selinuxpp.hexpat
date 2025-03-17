#pragma description SE Linux package

// SE Linux Policy Package
// Extension: PP
// https://github.com/SELinuxProject/selinux/blob/master/libsepol/src/module.c

#pragma magic [ 8F FF 7C F9 ] @ 0x00
#pragma endian little
import std.sys;

enum section_types : u32 {
    file_context = 0xf97cff90,
    module = 0xf97cff8d,
    user = 0x097cff91,
    user_extra = 0x097cff92,
    netfilter = 0x097cff93,
};

struct section_s {
    section_types *type : u32;
};

struct header_s {
    u32 magic;
    std::assert(magic == 0xf97cff8f, "invalid magic");
    u32 version;
    u32 sections_count;
    section_s sections[sections_count];
};

header_s header @ 0x00;
