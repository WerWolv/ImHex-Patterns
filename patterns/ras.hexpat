#pragma author Fl3ch4

#pragma MIME image/webp
#pragma endian big


import std.mem;
import type.magic;


struct RAS{

  //Magic Bytes
  type::Magic<"\x59\xa6\x6a\x95"> signature;
 
  //BE -> px -> mm
  u32 width [[name("Width")]];
  u32 height [[name("Height")]];
  
  //BE
  u32 depth;
  u32 length;
  u32 type;
  u32 colorMapType;
  u32 colorMapLenght;
  
  //Data Viewer
  u8 image_data[length]; 
};

RAS header @0x00;
