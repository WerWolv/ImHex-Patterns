#pragma author applecuckoo
#pragma description PKM (PacKMan) files containing ETC (Ericsson Texture Compression)
#pragma endian big
#pragma magic [ 50 4B 4D 20 ] @ 0x00

enum PKMFormat : u16 {
    ETC1_RGB_NO_MIPMAPS,
    ETC2PACKAGE_RGB_NO_MIPMAPS,
    ETC2PACKAGE_RGBA_NO_MIPMAPS_OLD,
    ETC2PACKAGE_RGBA_NO_MIPMAPS,
    ETC2PACKAGE_RGBA1_NO_MIPMAPS,
    ETC2PACKAGE_R_NO_MIPMAPS,
    ETC2PACKAGE_RG_NO_MIPMAPS,
    ETC2PACKAGE_R_SIGNED_NO_MIPMAPS,
    ETC2PACKAGE_RG_SIGNED_NO_MIPMAPS
};

struct PKMHeader {
    char id[4];
    char version[2];
    PKMFormat pkm_format;
    u16 width;
    u16 height;
    u16 original_width;
    u16 original_height;
};

PKMHeader pkm_header @ 0x00 [[comment("PKM file header"), name("Header")]];