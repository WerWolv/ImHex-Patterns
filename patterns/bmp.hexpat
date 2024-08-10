#pragma description OS2/Windows Bitmap

#pragma MIME image/bmp
#pragma endian little
import std.mem;

struct BitmapFileHeader {
	u8 bfType[2];
	u32 bfSize;
	u16 bfReserved1;
	u16 bfReserved2;
	u32 bfOffBits;
};

enum Compression : u32 {
	BI_RGB,
	BI_RLE8,
	BI_RLE4,
	BI_BITFIELDS,
	BI_JPEG,
	BI_PNG,
	BI_ALPHABITFIELDS,
	BI_CMYK,
	BI_CMYKRLE8,
	BI_CMYKRLE4,
};

struct CIEXYZ {
	u32 ciexyzX;
	u32 ciexyzY;
	u32 ciexyzZ;
};

struct CIEXYZTRIPLE {
	CIEXYZ ciexyzRed;
	CIEXYZ ciexyzGreen;
	CIEXYZ ciexyzBlue;
};

struct BitmapInfoHeaderV1 {
	u32 biSize;
	s32 biWidth;
	s32 biHeight;
	u16 biPlanes;
	u16 biBitCount;
	Compression biCompression;
	u32 biSizeImage;
	s32 biXPelsPerMeter;
	s32 biYPelsPerMeter;
	u32 biClrUsed;
	u32 biClrImportant;
};

struct BitmapInfoHeaderV2 : BitmapInfoHeaderV1 {
	u32 biRedMask;
	u32 biGreenMask;
	u32 biBlueMask;
};

struct BitmapInfoHeaderV3 : BitmapInfoHeaderV2 {
	u32 biAlphaMask;
};

struct BitmapInfoHeaderV4 : BitmapInfoHeaderV3 {
	u32 biCSType;
	CIEXYZTRIPLE biEndpoints;
	u32 biGammaRed;
	u32 biGammaGreen;
	u32 biGammaBlue;
};

struct BitmapInfoHeaderV5 : BitmapInfoHeaderV4 {
	u32 biIntent;
	u32 biProfileData;
	u32 biProfileSize;
	u32 biReserved;
};

struct Colors {
	u8 blue;
	u8 green;
	u8 red;
	u8 reserved;
};

struct Bitmap {
	u8 data[std::mem::size()] [[no_unique_address, hidden]];
	BitmapFileHeader bmfh;
	// Deduce the header version from its size
	u32 bmInfoHeaderSize [[hidden, no_unique_address]];
	match (bmInfoHeaderSize) {
		(40):  BitmapInfoHeaderV1 bmih;
		(52):  BitmapInfoHeaderV2 bmih;
		(56):  BitmapInfoHeaderV3 bmih;
		(108): BitmapInfoHeaderV4 bmih;
		(124): BitmapInfoHeaderV5 bmih;
		(_):   BitmapInfoHeaderV1 bmih;
	}
	padding[bmih.biSize - sizeof(bmih)];
	
	if (bmih.biBitCount <= 8)
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
} [[hex::visualize("image", this.data)]];

Bitmap bitmap @ 0x00;
