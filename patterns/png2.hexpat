#pragma description PNG image

#pragma MIME image/png
#pragma endian big

import std.mem;

struct header_t {
    u8 highBitByte;
    char signature[3];
    char dosLineEnding[2];
    char dosEOF;
    char unixLineEnding;
};

struct actl_t {
    u32 frames [[comment("Total № of frames in animation")]];
    u32 plays [[comment("№ of times animation will loop")]];
} [[comment("Animation control chunk"), name("acTL")]];

enum ColorType: u8 {
    Grayscale = 0x0,
    RGBTriple = 0x2,
    Palette,
    GrayscaleAlpha,
    RGBA = 0x6
};

enum Interlacing: u8 {
    None,
    Adam7
};

struct ihdr_t {
    u32 width [[comment("Image width")]];
    u32 height [[comment("Image height")]];
    u8 bit_depth;
    ColorType color_type [[comment("PNG Image Type")]];
    u8 compression_method [[comment("Only 0x0 = zlib supported by most")]];
    u8 filter_method [[comment("Only 0x0 = adaptive supported by most")]];
    Interlacing interlacing;
};

enum sRGB: u8 {
    Perceptual = 0x0,
    RelativeColorimetric,
    Saturation,
    AbsoluteColorimetric
};

enum Unit: u8 {
    Unknown,
    Meter
};

struct phys_t {
    u32 ppu_x [[comment("Pixels per unit, X axis")]];
    u32 ppu_y [[comment("Pixels per unit, Y axis")]];
    Unit unit;
};

enum BlendOp: u8 {
    Source = 0x0,
    Over
};

enum DisposeOp: u8 {
    None = 0x0,
    Background,
    Previous
};

struct fctl_t {
    u32 sequence_no [[comment("Sequence №")]];
    u32 width [[comment("Frame width")]];
    u32 height;
    u32 xoff;
    u32 yoff;
    u16 delay_num;
    u16 delay_den;
    DisposeOp dispose_op;
    BlendOp blend_op;
};

struct fdat_t {
    u32 sequence_no;
};

fn text_len() {
   u64 len = parent.parent.length - ($ - addressof(parent.keyword));
   return len;
};

struct itxt_t {
    char keyword[];
    u8 compression_flag;
    u8 compression_method;
    char language_tag[];
    char translated_keyword[];
    char text[text_len()];
};

struct ztxt_t {
    char keyword[];
    u8 compression_method;
    char text[text_len()];
};

struct text_t {
    char keyword[];
    char text[text_len()];
};

struct iccp_t {
    char keyword[];
    u8 compression_method;
    u8 compressed_profile[text_len()];
};

struct palette_entry_t {
    u24 color;
} [[inline]];

struct chrm_t {
    u32 white_point_x;
    u32 white_point_y;
    u32 red_x;
    u32 red_y;
    u32 green_x;
    u32 green_y;
    u32 blue_x;
    u32 blue_y;
};

struct time_t {
    u16 year;
    u8 month;
    u8 day;
    u8 hour;
    u8 minute;
    u8 second;
};

struct chunk_t {
    u32 length [[color("17BECF")]];
    char name[4];

    #define IHDR_k "IHDR"
    #define PLTE_k "PLTE"
    #define sRGB_k "sRGB"
    #define pHYs_k "pHYs"
    #define iTXt_k "iTXt"
    #define tEXt_k "tEXt"
    #define zTXt_k "zTXt"
    #define IDAT_k "IDAT"
    #define IEND_k "IEND"
    #define gAMA_k "gAMA"
    #define iCCP_k "iCCP"
    #define acTL_k "acTL"
    #define fdAT_k "fdAT"
    #define fcTL_k "fcTL"
    #define cHRM_k "cHRM"
    #define tIME_k "tIME"

    if (name == IHDR_k) {
        ihdr_t ihdr [[comment("Image Header chunk"), name("IHDR")]];
    } else if (name == PLTE_k) {
        palette_entry_t entries[length / 3];
    } else if (name == sRGB_k) {
        sRGB srgb;
    } else if (name == pHYs_k) {
        phys_t phys;
    } else if (name == acTL_k) {
        actl_t  actl [[comment("Animation control chunk")]];
    } else if (name == fcTL_k) {
        fctl_t fctl [[comment("Frame control chunk")]];
    } else if (name == iTXt_k) {
        itxt_t text;
    } else if (name == gAMA_k) {
    	u32 gamma [[name("image gamma"), comment("4 byte unsigned integer representing gamma times 100000")]];
    } else if (name == iCCP_k) {
    	iccp_t iccp;
    } else if (name == tEXt_k) {
        text_t text;
    } else if (name == zTXt_k) {
        ztxt_t text;
    } else if (name == iCCP_k) {
        iccp_t iccp;
    } else if (name == fdAT_k) {
        fdat_t fdat [[comment("Frame data chunk")]];
        u8 data[length-sizeof(u32)];
    } else if (name == cHRM_k) {
        chrm_t chrm;
    } else if (name == tIME_k) {
        time_t time;
    } else {
        u8 data[length];
    }

    u32 crc;
} [[name(chunkValueName(this))]];

fn chunkValueName(ref chunk_t chunk) {
    return chunk.name;
};

struct chunk_set {
    chunk_t chunks[while(builtin::std::mem::read_string($ + 4, 4) != "IEND")] [[inline]];
} [[inline]];

struct Chunks {
    chunk_t ihdr_chunk [[comment("PNG Header chunk")]];
    chunk_set set [[comment("PNG Chunks"), name("Chunks"), inline]];
    chunk_t iend_chunk [[comment("Image End Chunk")]];
};

struct Png {
    header_t header [[comment("PNG file signature"), name("Signature")]];
    Chunks chunks [[name("Chunks")]];
    u128 length = $ - addressof(this);
    u8 visualizer[length] @ addressof(this) [[sealed, hex::visualize("image", this), no_unique_address]];
};

Png png @ 0x00;