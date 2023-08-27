#pragma description QOI image files

#pragma MIME image/qoi
#pragma endian big

#include <std/mem.pat>

namespace qoi {

enum channels_t : u8 {
    RGB = 3,
    RGBA = 4
};

enum color_space_t : u8 {
    sRGB = 0,
    linear = 1
};

struct header_t {
    char magic[4];
    u32 width;
    u32 height;
    channels_t channels;
    color_space_t color_space;
};

enum tags_t : u8 {
    index = 0b00000000 ... 0b00111111,
    diff  = 0b01000000 ... 0b01111111,
    luma  = 0b10000000 ... 0b10111111,
    run   = 0b11000000 ... 0b11111101,
    rgb   = 0b11111110,
    rgba  = 0b11111111,
};

bitfield op_index {
    tag: 2;
    index: 6;
} [[color("0000FF")]];

bitfield op_diff {
    tag: 2;
    dr: 2;
    dg: 2;
    db: 2;
} [[color("FFFFFF")]];

bitfield op_luma {
    tag: 2;
    diff_green: 6;
    dr_dg: 4;
    db_dg: 4;
} [[color("FFFF00")]];

bitfield op_run {
    tag: 2;
    run_length: 6;
} [[color("00FF00")]];

struct op_rgb {
    u8 tag;
    u8 red;
    u8 green;
    u8 blue;
} [[color("FF7700")]];

struct op_rgba {
    u8 tag;
    u8 red;
    u8 green;
    u8 blue;
    u8 alpha;
} [[color("FF0000")]];

u8 op_type;
fn get_op_type() {
    op_type = std::mem::read_unsigned($, 1);
    if (op_type < tags_t::rgb)
        op_type &= 0b11000000;
};

struct op_t {
    qoi::get_op_type();
    if      (op_type == tags_t::index) op_index;
    else if (op_type == tags_t::diff)  op_diff;
    else if (op_type == tags_t::luma)  op_luma;
    else if (op_type == tags_t::run)   op_run;
    else if (op_type == tags_t::rgb)   op_rgb;
    else if (op_type == tags_t::rgba)  op_rgba;
};

struct file_t {
    header_t header;
    op_t data[while(!std::mem::eof())];
};

} // namespace qoi

qoi::file_t qoi_picture @ 0x0;
