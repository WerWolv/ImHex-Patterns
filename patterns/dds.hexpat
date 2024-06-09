#pragma description DirectDraw Surface

#pragma MIME image/vnd-ms.dds
#pragma endian little

enum DXGI_FORMAT : u32 {
  DXGI_FORMAT_UNKNOWN,
  DXGI_FORMAT_R32G32B32A32_TYPELESS,
  DXGI_FORMAT_R32G32B32A32_FLOAT,
  DXGI_FORMAT_R32G32B32A32_UINT,
  DXGI_FORMAT_R32G32B32A32_SINT,
  DXGI_FORMAT_R32G32B32_TYPELESS,
  DXGI_FORMAT_R32G32B32_FLOAT,
  DXGI_FORMAT_R32G32B32_UINT,
  DXGI_FORMAT_R32G32B32_SINT,
  DXGI_FORMAT_R16G16B16A16_TYPELESS,
  DXGI_FORMAT_R16G16B16A16_FLOAT,
  DXGI_FORMAT_R16G16B16A16_UNORM,
  DXGI_FORMAT_R16G16B16A16_UINT,
  DXGI_FORMAT_R16G16B16A16_SNORM,
  DXGI_FORMAT_R16G16B16A16_SINT,
  DXGI_FORMAT_R32G32_TYPELESS,
  DXGI_FORMAT_R32G32_FLOAT,
  DXGI_FORMAT_R32G32_UINT,
  DXGI_FORMAT_R32G32_SINT,
  DXGI_FORMAT_R32G8X24_TYPELESS,
  DXGI_FORMAT_D32_FLOAT_S8X24_UINT,
  DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS,
  DXGI_FORMAT_X32_TYPELESS_G8X24_UINT,
  DXGI_FORMAT_R10G10B10A2_TYPELESS,
  DXGI_FORMAT_R10G10B10A2_UNORM,
  DXGI_FORMAT_R10G10B10A2_UINT,
  DXGI_FORMAT_R11G11B10_FLOAT,
  DXGI_FORMAT_R8G8B8A8_TYPELESS,
  DXGI_FORMAT_R8G8B8A8_UNORM,
  DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
  DXGI_FORMAT_R8G8B8A8_UINT,
  DXGI_FORMAT_R8G8B8A8_SNORM,
  DXGI_FORMAT_R8G8B8A8_SINT,
  DXGI_FORMAT_R16G16_TYPELESS,
  DXGI_FORMAT_R16G16_FLOAT,
  DXGI_FORMAT_R16G16_UNORM,
  DXGI_FORMAT_R16G16_UINT,
  DXGI_FORMAT_R16G16_SNORM,
  DXGI_FORMAT_R16G16_SINT,
  DXGI_FORMAT_R32_TYPELESS,
  DXGI_FORMAT_D32_FLOAT,
  DXGI_FORMAT_R32_FLOAT,
  DXGI_FORMAT_R32_UINT,
  DXGI_FORMAT_R32_SINT,
  DXGI_FORMAT_R24G8_TYPELESS,
  DXGI_FORMAT_D24_UNORM_S8_UINT,
  DXGI_FORMAT_R24_UNORM_X8_TYPELESS,
  DXGI_FORMAT_X24_TYPELESS_G8_UINT,
  DXGI_FORMAT_R8G8_TYPELESS,
  DXGI_FORMAT_R8G8_UNORM,
  DXGI_FORMAT_R8G8_UINT,
  DXGI_FORMAT_R8G8_SNORM,
  DXGI_FORMAT_R8G8_SINT,
  DXGI_FORMAT_R16_TYPELESS,
  DXGI_FORMAT_R16_FLOAT,
  DXGI_FORMAT_D16_UNORM,
  DXGI_FORMAT_R16_UNORM,
  DXGI_FORMAT_R16_UINT,
  DXGI_FORMAT_R16_SNORM,
  DXGI_FORMAT_R16_SINT,
  DXGI_FORMAT_R8_TYPELESS,
  DXGI_FORMAT_R8_UNORM,
  DXGI_FORMAT_R8_UINT,
  DXGI_FORMAT_R8_SNORM,
  DXGI_FORMAT_R8_SINT,
  DXGI_FORMAT_A8_UNORM,
  DXGI_FORMAT_R1_UNORM,
  DXGI_FORMAT_R9G9B9E5_SHAREDEXP,
  DXGI_FORMAT_R8G8_B8G8_UNORM,
  DXGI_FORMAT_G8R8_G8B8_UNORM,
  DXGI_FORMAT_BC1_TYPELESS,
  DXGI_FORMAT_BC1_UNORM,
  DXGI_FORMAT_BC1_UNORM_SRGB,
  DXGI_FORMAT_BC2_TYPELESS,
  DXGI_FORMAT_BC2_UNORM,
  DXGI_FORMAT_BC2_UNORM_SRGB,
  DXGI_FORMAT_BC3_TYPELESS,
  DXGI_FORMAT_BC3_UNORM,
  DXGI_FORMAT_BC3_UNORM_SRGB,
  DXGI_FORMAT_BC4_TYPELESS,
  DXGI_FORMAT_BC4_UNORM,
  DXGI_FORMAT_BC4_SNORM,
  DXGI_FORMAT_BC5_TYPELESS,
  DXGI_FORMAT_BC5_UNORM,
  DXGI_FORMAT_BC5_SNORM,
  DXGI_FORMAT_B5G6R5_UNORM,
  DXGI_FORMAT_B5G5R5A1_UNORM,
  DXGI_FORMAT_B8G8R8A8_UNORM,
  DXGI_FORMAT_B8G8R8X8_UNORM,
  DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM,
  DXGI_FORMAT_B8G8R8A8_TYPELESS,
  DXGI_FORMAT_B8G8R8A8_UNORM_SRGB,
  DXGI_FORMAT_B8G8R8X8_TYPELESS,
  DXGI_FORMAT_B8G8R8X8_UNORM_SRGB,
  DXGI_FORMAT_BC6H_TYPELESS,
  DXGI_FORMAT_BC6H_UF16,
  DXGI_FORMAT_BC6H_SF16,
  DXGI_FORMAT_BC7_TYPELESS,
  DXGI_FORMAT_BC7_UNORM,
  DXGI_FORMAT_BC7_UNORM_SRGB,
  DXGI_FORMAT_AYUV,
  DXGI_FORMAT_Y410,
  DXGI_FORMAT_Y416,
  DXGI_FORMAT_NV12,
  DXGI_FORMAT_P010,
  DXGI_FORMAT_P016,
  DXGI_FORMAT_420_OPAQUE,
  DXGI_FORMAT_YUY2,
  DXGI_FORMAT_Y210,
  DXGI_FORMAT_Y216,
  DXGI_FORMAT_NV11,
  DXGI_FORMAT_AI44,
  DXGI_FORMAT_IA44,
  DXGI_FORMAT_P8,
  DXGI_FORMAT_A8P8,
  DXGI_FORMAT_B4G4R4A4_UNORM,
  DXGI_FORMAT_P208,
  DXGI_FORMAT_V208,
  DXGI_FORMAT_V408,
  DXGI_FORMAT_FORCE_UINT,
};

bitfield HeaderFlags {
  caps        : 1;
  height      : 1;
  width       : 1;
  pitch       : 1;
  padding     : 8;
  pixelFormat : 1; // 0x1000
  padding     : 4;
  mipMapCount : 1; // 0x20000
  padding     : 1;
  linearSize  : 1; // 0x80000
  padding     : 3;
  depth       : 1; // 0x800000
  padding     : 7;
};

bitfield CapsFlags {
  padding    : 3;
  complex    : 1; // 0x8
  padding    : 8;
  texture    : 1; // 0x1000
  padding    : 9;
  mipmap     : 1; // 0x400000
  padding    : 9;
};

bitfield Caps2Flags {
  padding        : 9;
  cubemap        : 1;
  cubemap_plusX  : 1;
  cubemap_minusX : 1;
  cubemap_plusY  : 1;
  cubemap_minusY : 1;
  cubemap_plusZ  : 1;
  cubemap_minusZ : 1;
  padding        : 5;
  volume         : 1; // 0x200000
  padding        : 10;
};

bitfield PixelFormatFlags {
  alphaPixels 	    : 1;  // DDPF_ALPHAPIXELS
  alpha       	    : 1;  // DDPF_ALPHA
  fourCC      	    : 1;  // DDPF_FOURCC
  paletteIndexed4   : 1;  // DDPF_PALETTEINDEXED4
  paletteIndexedTo8 : 1;  // DDPF_PALETTEINDEXEDTO8
  paletteIndexed8   : 1;  // DDPF_PALETTEINDEXED8
  rgb               : 1;  // DDPF_RGB
  compressed        : 1;  // DDPF_COMPRESSED
  rgbToYuv          : 1;  // DDPF_RGBTOYUV
  yuv               : 1;  // DDPF_YUV
  zBuffer           : 1;  // DDPF_ZBUFFER
  paletteIndexed1   : 1;  // DDPF_PALETTEINDEXED1
  paletteIndexed2   : 1;  // DDPF_PALETTEINDEXED2
  zPixels           : 1;  // DDPF_ZPIXELS
  stencilBuffer     : 1;  // DDPF_STENCILBUFFER
  alphaResult       : 1;  // DDPF_ALPHARESULT
  luminance         : 1;  // DDPF_LUMINANCE
  bumpLuminance     : 1;  // DDPF_BUMPLUMINANCE
  bumpDudv          : 1;  // DDPF_BUMPDUDV
  padding           : 13; // Padding bits to complete 32-bit structure
};

enum DX10ResourceDimension : u32 {
  Unknown,
  Buffer,
  Texture1D,
  Texture2D,
  Texture3D,
};

enum DX10AlphaMode : u32 {
  Unknown,
  Straight,
  PreMultiplied,
  Opaque,
  Custom,	
};

bitfield DX10MiscFlags {
  generateMips : 1;
  shared       : 1;
  textureCube  : 1;
  // following data are D3D10_RESOURCE_MISC_FLAG or D3D11_RESOURCE_MISC_FLAG
  // dependent and probably aren't used
  reserved     : 29;
};

struct DDS_HEADER_DX10 {
  DXGI_FORMAT           dxgiFormat;
  DX10ResourceDimension resourceDimension;
  DX10MiscFlags         miscFlags;
  u32                   arraySize;
  DX10AlphaMode         miscFlags2;
} [[static]];

struct DDS_PIXELFORMAT {
  u32                 size;
  PixelFormatFlags    flags;
  char                fourCC[4];
  u32                 RGBBitCount;
  u32                 rBitMask;
  u32                 gBitMask;
  u32                 bBitMask;
  u32                 aBitMask;
} [[static]];

struct DDS_HEADER {
  u32             size;
  HeaderFlags     flags;
  u32             height;
  u32             width;
  u32             pitchOrLinearSize;
  u32             depth;
  u32             mipMapCount;
  u32             reserved0[11];
  DDS_PIXELFORMAT ddspf;
  CapsFlags       caps;
  Caps2Flags      caps2;
  u32             caps3;
  u32             caps4;
  u32             reserved1;

  if (ddspf.fourCC == "DX10") {
    DDS_HEADER_DX10 dx10Header;
  }
} [[static]];

char id[4] @ 0x0;
DDS_HEADER header @ 0x4;
