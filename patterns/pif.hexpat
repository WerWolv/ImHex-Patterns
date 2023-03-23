/* PIF - Portable Image Format
 *
 * Basic decoder for the PIF file structure
 * https://github.com/gfcwfzkm/PIF-Image-Format
 */

#pragma MIME image/pif
#pragma endian little

enum imageType_t : u16 {
	RGB888 = 0x433C,
	RGB565 = 0xE5C5,
	RGB332 = 0x1E53,
	RGB16C = 0xB895,
	BLWH   = 0x7DAA,
	IND24  = 0x4952,
	IND16  = 0x4947,
	IND8   = 0x4942
};

enum compression_t : u16 {
	NO_COMPRESSION  = 0,
	RLE_COMPRESSION = 0x7DDE
};

struct PIFFileHeader {
	char  Signature[4];
	u32 FileSize;
	u32 ImageOffset;
};

struct PIFInfoHeader {
	imageType_t ImageType;
	u16 BitsPerPixel;
	u16 ImageWidth;
	u16 ImageHeight;
	u32 ImageSize;
	u16 ColorTableSize;
	compression_t Compression;
};

struct PIF {
	PIFFileHeader PIF_FileHeader;
	PIFInfoHeader PIF_ImageHeader;
	
	if (PIF_ImageHeader.ImageType == imageType_t::IND24)
	{
		u24 ColorTable[PIF_ImageHeader.ColorTableSize/3];
	}
	else if (PIF_ImageHeader.ImageType == imageType_t::IND16)
	{
		u16 ColorTable[PIF_ImageHeader.ColorTableSize/2];
	}
	else if (PIF_ImageHeader.ImageType == imageType_t::IND8)
	{
		u8 ColorTable[PIF_ImageHeader.ColorTableSize];
	}
	
	if ((PIF_ImageHeader.ImageType == imageType_t::RGB888) ||
		(PIF_ImageHeader.ImageType == imageType_t::IND24))
	{
		u24 ImageData[(PIF_FileHeader.FileSize - PIF_FileHeader.ImageOffset)/3];
	}
	else if ((PIF_ImageHeader.ImageType == imageType_t::RGB565) ||
			 (PIF_ImageHeader.ImageType == imageType_t::IND16))
	{
		u16 ImageData[(PIF_FileHeader.FileSize - PIF_FileHeader.ImageOffset)/2];
	}
	else if ((PIF_ImageHeader.ImageType == imageType_t::RGB332) ||
			 (PIF_ImageHeader.ImageType == imageType_t::IND8))
	{
		u8 ImageData[(PIF_FileHeader.FileSize - PIF_FileHeader.ImageOffset)/1];
	}
};

PIF pif @ 0x00;
