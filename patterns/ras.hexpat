#pragma author Fl3ch4
#pragma MIME image/webp
#pragma endian big

#include <std/mem.pat>


struct Header {
  
  //Magic Bytes
  char signature[4] [[name("File Signature")]];
  
  //BE -> px -> mm
  u32 width [[name("Width")]];
  u32 height [[name("Height")]];
  
  //BE
  u32 depth ;
  u32 leght;
  u32 type;
  u32 colorMapType;
  u32 colormapLenght;
  
  //Data Viewer
  u8 image_data[leght]; 
};


//u8 visualizer[std::mem::size()] @ 0x00 [[sealed]];
//Header2 header2 @0x10;
//Data data[while (!std::mem::eof())] @ $;
Header header @0x00;