#pragma MIME image/bmp
#pragma endian little
#include "std/mem.pat"

struct BitmapFileHeader {
	u8 bfType[2];
	u32 bfSize;
	u16 bfReserved1;
	u16 bfReserved2;
	u32 bfOffBits;
};

struct BitmapInfoHeader {
	u32 biSize;
	s32 biWidth;
	s32 biHeight;
	u16 biPlanes;
	u16 biBitCount;
	u32 biCompression;
	u32 biSizeImage;
	s32 biXPelsPerMeter;
	s32 biYPelsPerMeter;
	u32 biClrUsed;
	u32 biClrImportant;
};

struct Colors {
	u8 blue;
	u8 green;
	u8 red;
	u8 reserved;
};

struct Bitmap {
    u8 data[std::mem::size()] [[no_unique_address,hidden]];
	BitmapFileHeader bmfh;
	BitmapInfoHeader bmih;
	
	if ((bmih.biBitCount != 24) && (bmih.biBitCount != 32))
	{
		if (bmih.biClrUsed > 0 )
			Colors rgbq[bmih.biClrUsed];
		else
			Colors rgbq[1 << bmih.biBitCount];
	}
	
	if (bmih.biSizeImage > 0 )
		u8 lineData[bmih.biSizeImage];
	else
		u8 lineData[bmfh.bfSize - $];
}[[hex::visualize("image", data)]];

Bitmap bitmap @ 0x00;
