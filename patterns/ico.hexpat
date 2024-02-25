#pragma author WerWolv
#pragma description Icon (.ico) or Cursor (.cur) files

#pragma endian little

import std.sys;

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

struct ImageData {
	u8 data[parent.image_data_size] [[inline]];
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
	ImageData *image_data : u32;
};

ICONDIR header @ 0x00;
ICONDIRENTRY images[header.num_images] @ $;

std::assert(header.reserved == 0x00, "Invalid ICO header");