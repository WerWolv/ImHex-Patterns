#pragma MIME image/png
#pragma endian big

struct header_t
{
    u8 signature[8] [[comment("signature"), name("PNG Signature")]];
};

struct ihdr_t
{
    u32 width;
    u32 height;
    u8 bit_depth;
    u8 color_type;
    u8 compression_method;
    u8 filter_method;
    u8 interlace_method;
};

struct palette_entry_t {
    u8 r;
    u8 g;
    u8 b;
};

struct phys_t {
    u32 ppu_x;
    u32 ppu_y;
    u8 unit;
};

struct itxt_t {
    char keyword[];
    u8 compression_flag;
    u8 compression_method;
    char language_tag[];
    char translated_keyword[];
    char text[parent.length - ($ - addressof(keyword))];
};

struct chunk_t {
    u32 length;
    u32 type;

    if (type == 0x49484452) {
        ihdr_t ihdr [[comment("header chunk"), name("IHDR")]];
    } else if (type == 0x504c5445) {
        palette_entry_t entries[length / 3];
    } else if (type == 0x70485973) {
        phys_t phys;
    } else if (type == 0x69545874) {
        itxt_t text;
    } else if (type == 0x49444154) {
        u8 data[length];
    } else if (type == 0x49454e44) {
        // IEND. No data.
    }

    u32 crc;
};

struct main_t {
    header_t header;
    chunk_t  chunk_set[6];
};

main_t main @ 0x00;
