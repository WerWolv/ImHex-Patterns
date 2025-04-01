#pragma description Digital Terrain Elevation Data
#pragma endian big

#pragma magic [ 4C 48 55 ] @ 0x00

import std.core;
import std.io;
import std.mem;
import std.string;


enum Magic:u24 {
    UHL = 0x55484C,
    DSI = 0x445349,
    ACC = 0x414343,
};

struct UHL {
    Magic magic;
    char one;
    char lon[8];
    char lat[8];
    char lon_data_interval[4];
    char lat_data_interval[4];
    char accuracy[4];
    char security_code[3];
    char uniq_ref[12];
    char lon_lines[4];
    char lat_points[4];
    char multi_accuracy;
    char reserved[24];
};

struct DSI {
    Magic magic;
    char classification;
    char stuff1[29];
    char stuff2[26];
    char product_level[5];
    char uniq_ref[15];
    char reserved[8];
    char data_edition[2];
    char match_version;
    char maint_date[4];
    char match_date[4];
    char main_desc_code[4];
    char producer_code[8];
    char reserved2[16];
    char product_spec[9];
    char numbers[2];
    char product_spec_date[4];
    char vertical_datum[3];
    char horizontal_datum[5];
    char digitizing_system[10];
    char compilation_date[4];
    char reserved3[22];
    char lat_origin[9];
    char lon_origin[10];
    char lat_sw_corner[7];
    char lon_sw_corner[8];
    char lat_nw_corner[7];
    char lon_nw_corner[8];
    char lat_ne_corner[7];
    char lon_ne_corner[8];
    char lat_se_corner[7];
    char lon_se_corner[8];
    char clockwise_orientation[9];
    char lat_interval[4];
    char lon_interval[4];
    char lat_lines[4];
    char lon_lines[4];
    char partial_cell[2];
    char reserved4[101];
    char reserved5[100];
    char reserved6[156];
};

struct ACCSub {
    char abs_vertical_accuracy[4];
    char abs_horizontal_accuracy[4];
    char rel_vertical_accuracy[4];
    char rel_horizontal_accuracy[4];
    char num_coords[2];
    char pairs[19*14];
};

struct ACC {
    Magic magic;
    char abs_horizontal_accuracy[4];
    char abs_vertical_accuracy[4];
    char rel_horizontal_accuracy[4];
    char rel_vertical_accuracy[4];
    char reserved1[4];
    char reserved2[1];
    char reserved3[31];
    char multi_accuracy_outline[2]; // determines sub regions
    ACCSub subs[9];
    char reserved4[18];
    char reserved5[69];

};

struct DataRecords {
    char magic;
    s24 data_block_count;
    s16 lon_count;
    s16 lat_count;
    s16 elevation[std::string::parse_int(parent.dsi.lat_lines, 10)];
    u32 checksum;
};

struct DTED {
    UHL uhl;
    DSI dsi;
    ACC acc;
    DataRecords records[std::string::parse_int(this.dsi.lon_lines, 10)];
};

DTED dted @ 0x00;
