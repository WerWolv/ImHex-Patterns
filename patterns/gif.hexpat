#include <std/mem.pat>

#pragma MIME image/gif

#pragma bitfield_order left_to_right

// gif89a

struct data_subblock_t {
    u8 block_size;
    u8 data_values[block_size];
};

struct data_subblocks_t {
    data_subblock_t data[while (std::mem::read_unsigned($, 1) != 0x00)];
    u8 block_terminator;        // 0x00
} [[inline]];

struct header_t {
    char header[3];
    char version[3];
};

bitfield lsd_fields_t {
    global_color_table_flag : 1;
    color_resolution        : 3;
    sort_flag               : 1;
    size_of_global_color_table : 3;
} [[inline]];

struct logical_screen_descriptor_t {
    u16 width;
    u16 height;
    lsd_fields_t fields;
    u8 background_color_index;
    u8 pixel_aspect_ratio;
};

struct color_table_entry_t {
    u8 red;
    u8 green;
    u8 blue;
};

bitfield gce_fields_t {
    padding         : 3;
    disposal_method : 3;
    user_input_flag : 1;
    transparent_color_flag : 1;
} [[inline]];

struct graphic_coltrol_extension_t {
    u8 extension_introducer;    // 0x21
    u8 graphic_control_label;   // 0xf9
    u8 block_size;
    gce_fields_t fields;
    u16 delay_time;
    u8 transparent_color_index;
    u8 block_terminator;
};

struct comment_extension_t {
    u8 extension_introducer;    // 0x21
    u8 comment_label;           // 0xfe
    data_subblocks_t comment_data;
};

struct plaintext_extension_t {
    u8 extension_introducer;    // 0x21
    u8 plain_text_label;        // 0x01

    u8 block_size;              // 12
    u16 text_grid_left_position;
    u16 text_grid_top_position;
    u16 text_grid_width;
    u16 text_grid_height;
    u8 character_cell_width;
    u8 character_cell_height;
    u8 text_foreground_color_index;
    u8 text_background_color_index;
    data_subblocks_t plain_text_data;
};

struct application_extension_t {
    u8 extension_introducer;    // 0x21
    u8 extension_label;         // 0xff

    u8 block_size;              // 11
    u8 application_identifier[8];
    u8 application_authentication_code[3];
    
    data_subblocks_t data;
};

bitfield id_fields_t {
    local_color_table : 1;
    interlace_flag    : 1;
    sort_fla          : 1;
    padding           : 2;
    size_of_local_color_table : 3;
} [[inline]];

struct image_descriptor_t {
    u8 image_separator;         // 0x2c
    u16 image_left_position;
    u16 image_top_position;
    u16 image_width;
    u16 image_height;
    id_fields_t fields;
};

struct table_based_image_t {
    u8 lzw_minimum_code_size;
    data_subblocks_t data;
};

struct gif_block_t {
    if (std::mem::read_unsigned($, 1) == 0x21) {
        if (std::mem::read_unsigned($+1, 1) == 0x01) {
            plaintext_extension_t plaintext_extension;
        }
        else if (std::mem::read_unsigned($+1, 1) == 0xf9) {
            graphic_coltrol_extension_t graphic_coltrol_extension;
        }
        else if (std::mem::read_unsigned($+1, 1) == 0xfe) {
            comment_extension_t comment;
        } else {
            application_extension_t application_extension;
        }
    }
    else if (std::mem::read_unsigned($, 1) == 0x2c) {
        image_descriptor_t image_descriptor;
        if (image_descriptor.fields.local_color_table) {
            color_table_entry_t local_color_table[1<<(image_descriptor.fields.size_of_local_color_table + 1)];
        }
        table_based_image_t image;
    }
} [[inline]];

struct gif_t {
    header_t header;
    logical_screen_descriptor_t logical_screen_descriptor;
    if (logical_screen_descriptor.fields.global_color_table_flag) {
        color_table_entry_t global_color_table[1<<(logical_screen_descriptor.fields.size_of_global_color_table + 1)];
    }
    
    gif_block_t blocks[while (std::mem::read_unsigned($, 1) != 0x3b)];

    u8 trailer;                 // 0x3b
};

gif_t gif @ 0x00;

