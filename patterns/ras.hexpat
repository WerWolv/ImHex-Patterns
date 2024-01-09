#pragma author Fl3ch4

#pragma MIME image/webp
#pragma endian big


#include <std/mem.pat>
#include <type/magic.pat>


struct RAS{

  //Magic Bytes
  type::Magic<"Y¦j"> signature;
 
  //BE -> px -> mm
  u32 width [[name("Width")]];
  u32 height [[name("Height")]];
  
  //BE
  u32 depth;
  u32 leght;
  u32 type2;
  u32 colorMapType;
  u32 colorMapLenght;
  
  //Data Viewer
  u8 image_data[leght]; 
};

RAS header @0x00;
