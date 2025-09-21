#pragma author WerWolv
#pragma description Windows Icon (.ico) or Cursor (.cur)

#pragma endian little

import std.sys;
import std.mem;
import std.string;
import * from bmp as BMP;
import * from png as PNG;

#pragma MIME image/vnd.microsoft.icon
#pragma MIME image/x-icon
#pragma MIME image/icon
#pragma MIME image/ico
#pragma MIME text/ico
#pragma MIME application/ico

enum ImageType : u16 {
    Icon = 1,
    Cursor = 2
};

struct ICONDIR {
    u16 reserved [[hidden]];
    ImageType type;
    u16 num_images;
};

struct BMPData {
    u8 data[sizeof(parent.raw_data)] [[hidden, no_unique_address]];
    std::mem::Section section = std::mem::create_section("BMP Image " + std::string::to_string(addressof(this)));
    std::mem::set_section_size(section, sizeof(data) + 14);
    u8 headerData[14] @ 0x00 in section [[hidden]];
    headerData[0x00] = 0x42;
    headerData[0x01] = 0x4D;
    u32 size @ 0x02 in section [[hidden]];
    size = std::mem::get_section_size(section);
    std::mem::copy_value_to_section(data, section, 0x0E);
    BMP image @ 0x00 in section;
    u32 offset @ 0x0D in section [[hidden]];
    offset = addressof(image.lineData);
};

struct ImageData {
    std::mem::Bytes<parent.image_data_size> raw_data [[no_unique_address]];
    be u64 png_magic [[hidden, no_unique_address]];
    if (png_magic == 0x89504e470d0a1a0a) {
        PNG png_image @ $ [[inline, highlight_hidden]];
    } 
    
    // TODO: Sections currently can't be properly accessed accross imported types
    // TODO: Uncomment this again once that's been fixed
    /*else {
        BMPData data [[hidden]];
        BMP bmp_image @ addressof(this) - 14 [[inline, highlight_hidden]];
    }*/
};

struct ICONDIRENTRY {
    u8 width, height;
    u8 num_colors;
    u8 reserved [[hidden]];

    if (header.type == ImageType::Icon) {
        u16 color_planes;
        u16 bits_per_pixel;
    } else if (header.type == ImageType::Cursor) {
        u16 horizontal_hotspot_coordinate;
        u16 vertical_hotspot_coordinate;
    }

    u32 image_data_size;
    u32 image_data_offset;
    ImageData image_data @ image_data_offset;
};

ICONDIR header @ 0x00;
ICONDIRENTRY images[header.num_images] @ $;

std::assert(header.reserved == 0x00, "Invalid ICO header");
