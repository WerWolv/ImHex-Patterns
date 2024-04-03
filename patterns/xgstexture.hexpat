//By LolHacksRule

enum XGSPlatform : u8
{
    WIN32_OR_ANDROID, //Android sure but Win32 p much was only used in EOP (Edge of Perception)?
    PS3, //PlayStation 3,
    iOS_OR_PSP, //iPhone/iPad or PSP (confusion, I think PSP was renamed to iOS but idk)
    REVOLUTION, //Nintendo Wii
    XENON, //Xbox 360
    iOS_IPHONE_LEGACY, //Legacy iPhone/iPad since ABGO V1
    CTR, //Nintendo 3DS
    PSP2, //PlayStation Vita
    OSX, //Mac OS X
    ANDROID_LEGACY, //Definitely Android since ABGO V1
    METRO_OR_WINSTORE, //WP7?
    CAFE, //Wii U
    BLACKBERRY,
    OGL, //?
    ORBIS, //PlayStation 4
    DURANGO, //Xbox One
    WINPHONE, //PCOGL
    WINPHONE_LEGACY, //WP8
    APPLE_TV, //Apple TV    
};

enum XGSTextureFormat : u16
{
    RGB565_SWIZZLED,                //AB SW Console, Vita/PS3 uses no swizzle
    RGB565,                         //ABTF but supported in GO
    RGBA4444,                       //On PS3 this is BGRA8888/ARGB8888?
    RGBA4444_2_OR_RGBA8888_OR_LA88, //On PS4/X360/XENON this is ARGB8888, on Win this is RGBA8888, on current Android this is RGBA4444 OR RGBA8888 (ABTF2017 Chi?), on caFe/Wii U or legacy iOS this is RGBA8888, on current iOS it's both, on Orbis/PS4 it's BGRA8888, on Wii it's linear indexed 32BPP LA88 with BC swizzle, on legacy Android or ABGO v101 crashes
    RGBA8888,                       //On GO v101, nothing is read
    PALLETIZED_RGBA5A3,             //Palletized RGB5A3, AB SW Wii, doesn't crash in EOP or ABGO v101 (Android) but doesn't return any data
    //6,                            //crash on EOP and PS3 but not ABGO v101 but doesn't return any data
    //7,                            //crash on EOP and PS3 but not ABGO v101 but doesn't return any data
    AL88_OR_DXT1_OR_RGB565 = 8,     //On Xbox 360/PS3 this is usually DXT, on Wii U, RGBA8888, on Android, this is usually AL88 unless the format is DXT, on 3DS, swizzled RGB565, on EOP, crash, on ABGO v101, nothing
    UNKNOWN_DXT,                    //DXT3? no XGS games so far use this one, crashes on EOP, on ABGO v101, nothing
    DXT5_SWIZZLED,                  //ABSW PS3/WinPhone/Legacy Android only? on ABGO v101, nothing
    PVR_UNK,                        //2BPP no alpha? Crashes in ABGO v101
    RGB888,                         //Greyscale? unused, crashes in EOP but works in ABGO v101
    AL88,
    //14,                           //8BPP something? Crash on EOP and PS3, on ABGO v101, nothing 
    PVRTC_2BPP_RGBA = 15,           //Crash on PS3, on ABGO v101, nothing 
    PVRTC_4BPP_RGBA,                //Crash on PS3 or is this 2bppRGBA, on ABGO v101, nothing 
    PVRTC_4BPP_RGBA_2,              //May need to swap these two, crash on PS3, on ABGO v101, nothing 
    PVRTC_4BPP_RGBA_3,              //Crashes on EOP and PS3, on ABGO v101, nothing 
    //19,                           //Crash on PS3 and EOP, on ABGO v101, nothing 
    //20,                           //Crash on PS3 and EOP, on ABGO v101, nothing 
    //21,                           //Crash on PS3 and EOP, on ABGO v101, nothing 
    RG88_OR_GR88 = 22,              //Unused. On PS3, it's unswizzled GR88, crashes on EOP, on ABGO v101, nothing 
    L4,                             //Unused, crashes on EOP, on ABGO v101, nothing 
    DXT1_OR_ETC1,                   //On Android this is usually DXT1, old Android has this DXT1 swizzled, null on PS3, crash on EOP, on ABGO v101, nothing 
    LA44,                           //Crash on EOP, on ABGO v101, nothing
    DXT5,                           //Crash on EOP, on ABGO v101, nothing
    //?,                            //Crash on EOP, on ABGO v101, nothing, note starting here PS3 crashes
    //?,                            //Crash on EOP, on ABGO v101, nothing
    PVRTC_2BPP_RGBA_2 = 29,         //on ABGO v101, nothing
    PVRTC_4BPP_RGBA_V2,             //on ABGO v101, nothing
    PVRTC_4BPP_RGB_V3,              //on ABGO v101, nothing
    //?                             //on ABGO v101, nothing
    //?                             //on ABGO v101, nothing
    //?                             //on ABGO v101, nothing
    ETC2_RGB = 35,                  //on ABGO v101, nothing
    //?                             //on ABGO v101, nothing
    ATC = 37,                       //BC Swizzled, on ABGO v101, nothing
    //ATC_RGBA_Exp,                 //? on ABGO v101, nothing
    ATCA_Interpolated = 39,         //BC Swizzled, on ABGO v101, nothing
    //?                             //on ABGO v101, nothing
    RGBA5A3 = 250,                  //on ABGO v101, nothing
    CMPR,                           //CMPR/DXT1 with different blocks, nothing on ABGO v101
    ETC2_RGB_2_OR_ETC1,             //On CTR, ETC1 Z-Order 1, works on ABGO v101 (ETC1)
    ETC1_RGB_SPLITALPHA,            //CTR only, nothing on ABGO v101
    ATC_RGB,                        //Confirm, nothing on ABGO v101
    ATC_RGBA_EXPLICIT,              //Prob nothing on ABGO v101
    ATC_RGBA_INTERPOLATED,          //Prob nothing on ABGO v101
    XGSTEXFMT_257,                  //Defined in ABGO v101 but idk what it is
    //258-263 are unknown
    DXT1_EXT = 264,                 //DXT1 EXT (?)
    DXT3_EXT,                       //DXT3 EXT (?)
    DXT5_EXT,                       //DXT1 EXT (?)
};

bitfield XGSTextureFlags
{
    Mips : 2; Twiddle : 2; Normal : 2; Border : 2; CubeMap : 2; MipMapDebugColoring : 2; Volume3D : 2; AlphaChannelPresent : 2; VFlip : 2;
    //Idk how this works
};

struct XGSTextureHeader
{
    char magic[4]; //XGST
    u8 dataOffset;
    XGSPlatform compilationPlatform; //Definitely platform, this has no harm when modifying (except in Edge of Perception) but does help with knowing platform specific compressions, usually
    u16 headerSize; //?
    //byte dmy;
    u8 numMips;
    //? start
    XGSTextureFlags flags;
    //? end
    //char format[4];
    XGSTextureFormat format;
    u16 numColors; //Modifying this seems to have no known effect but idk
    u16 width;
    u16 height;
    u16 width2; //No use modifying
    u16 height2; //No use modifying
    u32 paletteSize; //Modifying this affects the game badly, take care
    u32 dataSize;
};

XGSTextureHeader Head @ 0x0;
u8 Texture[Head.dataSize] @ Head.headerSize+4;