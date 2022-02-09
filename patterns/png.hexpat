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
    u32 width [[comment("Image width")]];
    u32 height [[comment("Image height")]];
    u8 bit_depth;
    u8 color_type [[comment("PNG Image Type\n0: greyscale\n2: truecolour\n3: indexed-color\n4: greyscale with alpha\n6: truecolour with alpha")]];
    u8 compression_method;
    u8 filter_method;
    u8 interlace_method [[comment("values 0 \"no interlace\" or 1 \"Adam7 interlace\"")]];
};

struct palette_entry_t {
    u8 r;
    u8 g;
    u8 b;
};

struct phys_t {
    u32 ppu_x [[comment("Pixels per unit, X axis")]];
    u32 ppu_y [[comment("Pixels per unit, Y axis")]];
    u8 unit [[comment("Unit Specifier\n0: unit is unknown\n1: unit is the metre")]];
};

struct itxt_t {
    char keyword[];
    u8 compression_flag;
    u8 compression_method;
    char language_tag[];
    char translated_keyword[];
    char text[parent.length - ($ - addressof(keyword))];
};

struct iccp_t {
	char profile [];
	u8 compression_method;
	u8 compressed_profile[parent.length - ($ - addressof(profile))];
};

struct chunk_t {
    u32 length [[color("17BECF")]];
    char type[4];

    #define IHDR_k "IHDR"
    #define PLTE_k "PLTE"
    #define pHYs_k "pHYs"
    #define iTXt_k "iTXt"
    #define IDAT_k "IDAT"
    #define IEND_k "IEND"
    #define gAMA_k "gAMA"
    #define iCCP_k "iCCP"

    if (type == IHDR_k) {
        ihdr_t ihdr [[comment("Image Header chunk"), name("IHDR")]];
    } else if (type == PLTE_k) {
        palette_entry_t entries[length / 3];
    } else if (type == pHYs_k) {
        phys_t phys;
    } else if (type == iTXt_k) {
        itxt_t text;
    } else if (type == gAMA_k) {
    	u32 gamma [[name("image gamma"), comment("4 byte unsigned integer representing gamma times 100000")]];
    } else if (type == iCCP_k) {
    	iccp_t iccp;
    } else {
        u8 data[length];
    }

    u32 crc;
};

header_t header @ 0x00 [[comment("PNG file signature"), name("Signature")]];
chunk_t ihdr_chunk @ 0x08 [[comment("PNG Header chunk"), name("IHDR")]];
chunk_t chunk_set[while(builtin::std::mem::read_string($ + 4, 4) != "IEND")] @ $ [[comment("PNG file chunks"), name("Chunks"), inline]];
chunk_t iend_chunk @ $ [[name("IEND"), comment("Image End Chunk")]];
