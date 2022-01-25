#pragma MIME image/png
#pragma endian big

struct header_t
{
    u8 highBitByte;
	char signature[3];
	char dosLineEnding[2];
	char dosEOF;
	char unixLineEnding;
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
    char type[4];

    #define IHDR_k "IHDR"
    #define PLTE_k "PLTE"
    #define pHYs_k "pHYs"
    #define iTXt_k "iTXt"
    #define IDAT_k "IDAT"
    #define IEND_k "IEND"

    if (type == IHDR_k) {
        ihdr_t ihdr [[comment("header chunk"), name("IHDR")]];
    } else if (type == PLTE_k) {
        palette_entry_t entries[length / 3];
    } else if (type == pHYs_k) {
        phys_t phys;
    } else if (type == iTXt_k) {
        itxt_t text;
    } else {
        u8 data[length];
    }

    u32 crc;
};

header_t header @ 0x00 [[comment("PNG file signature"), name("Signature")]];
chunk_t chunk_set[while(std::mem::read_string($ + 4, 4) != "IEND")] @ 0x08 [[comment("PNG file chunks"), name("Chunks")]];
chunk_t iend_chunk @ $;

