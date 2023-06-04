#pragma MIME image/tga
#pragma endian little

#include <std/mem.pat>

struct ColorMapSpec {
  u16 entryIndex;
  u16 entryLength;
  u8  bpp;
} [[static]];

bitfield ImageDesc {
  alphaDepth       : 4;
  orderRightToLeft : 1;
  orderTopToBottom : 1;
  padding          : 2;
};

struct ImageSpec {
  u16       xOrigin;
  u16       yOrigin;
  u16       width;
  u16       height;
  u8        depth;
  ImageDesc imageDesc;
} [[static]];

enum ColorMapType : u8 {
  None,
  ColorPalette,
};

enum ImageType : u8 {
  NoData,
  UncompressedColorMapped,
  UncompressedRGB,
  UncompressedGreyscale,
  RLEColorMapped = 9,
  RLERGB,
  RLEGreyscale,
  // huffman + delta + rle
  CompressedColorMapped = 32,
  // huffman + delta + rle, 4-pass quadtree-type
  CompressedColorMapped4Pass,
};

fn GetImageDataSize(ImageSpec imSpec) {
  return imSpec.height * imSpec.width * (imSpec.depth / 8);
};

fn GetColorMapDataSize(ColorMapSpec cmSpec) {
  return cmSpec.entryLength * (cmSpec.bpp / 8);
};

struct Header {
  u8           idLength;
  ColorMapType colorMapType;
  ImageType    imageType;
  ColorMapSpec colorMapSpec;
  ImageSpec    imageSpec;
  char         imageId[idLength];
  
  if (colorMapType == ColorMapType::ColorPalette) {
    u8 colorMapData[GetColorMapDataSize(colorMapSpec)];
  }

  u8 imageData[GetImageDataSize(imageSpec)];
};

struct Footer {
  u32 extensionOffset;
  u32 developerDirectoryOffset;
  char signature[0x10];
  char dot;
  char zero;
};

u8 visualizer[std::mem::size()] @ 0 [[sealed,hex::visualize("image", this)]];
Header header @ 0x0;
Footer footer @ std::mem::size() - 0x1A;
