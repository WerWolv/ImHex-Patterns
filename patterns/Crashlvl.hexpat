#pragma description Crash Bandicoot - Back in Time (fan game) User created flashback tapes level format

#include <type/magic.pat>
#include <std/string.pat>
#include <std/array.pat>

// Crash Bandicoot - Back in Time (fan game) user created tapes
// author AdventureT

struct Header {
    type::Magic<"CRASHLVL"> magic;
    u8 version;
    std::string::SizedString<u8> levelName;
    std::string::SizedString<u8> author;
};

Header header @ 0x0;

// Background Music
enum BGM : u32 {
    None,
    BonusBGM,
    CrashCreatorBGM,
    MainMenuBGM,
    WarpRoomBGM,
    Level01BGM,
    Level02BGM,
    Level03BGM,
    Level04BGM,
    Level05BGM,
    SewerBGM,
    EgyptBGM,
    NBrioBGM
};

enum BGMV2 : u32 {
    None,
    N_TropyBGM,
    CrashCreatorBGM,
    MainMenuBGM,
    WarpRoomBGM,
    Jungle01BGM,
    SnowBGM,
    RiverBGM,
    FutureBGM,
    LabBGM,
    SewerBGM,
    EgyptBGM,
    NBrioBGM,
    AdventureBGM,
    SpyBGM,
    ChaseBGM,
    TrialsBGM,
    SpaceBGM,
    Jungle02BGM,
    RipperBGM,
    TheGreatWallBGM,
    RoadToSomewhereBGM,
    LavaKoalaBGM,
    CortexBGM,
    CyberCortexBGM,
    ArabicBGM,
    N_Tropy2BGM,
    JazzBGM,
    Space2BGM,
    TawnaBonusBGM,
    CortexPowerBGM,
    ArabicBonusBGM,
    EgyptBonusBGM,
    FutureBonusBGM,
    LostCityBGM,
    PolarBGM,
    RiverBonusBGM,
    RuinsBonusBGM,
    SewerBonusBGM,
    SnowBonusBGM,
    RoadToRuinBGM,
    NGinBGM,
    Arabia01BGM,
    Arabia02BGM,
    BashBGM,
    Cortex02BGM,
};

enum Type : u32 {
    Unset,
    Flashback,
    Trial,
};

enum TypeV2 : u32 {
    Practice,
    Flashback,
    Trial,
    Adventure
};

enum Skybox : u32 {
    Night,
    Day,
    Storm,
    Dawn
};

enum SkyboxV2 : u32 {
    Default = 1,
    Briolab,
    Fort,
    Moon,
    Toxic,
    AboutRight,
    Crash1Island,
    Arabia,
    RoadToRuin,
    Black
};

enum Scenery : u32 {
    None,
    Machines,
    Trees,
    Waterfall,
    Snow,
    Fortress,
};

enum Weather : u32 {
    None
};

struct Options {
    
    if (header.version > 1)
        TypeV2 type;
    else
        Type type;
        
    if (header.version > 1)
        SkyboxV2 skybox;
    else
        Skybox skybox;
    
    Scenery scenery;
    
    if (header.version > 2)
    {
        Weather weather;
    }
    
    if (header.version > 1)
        BGMV2 bgm;
    else
        BGM bgm;
    
    
    if (type == Type::Trial)
    {
        u32 timeTrialTicksBronze;
        u32 timeTrialTicksSilver;
        u32 timeTrialTicksGold;
    }
};

struct Object {

    std::string::SizedString<u8> objName;
    
    if (header.version > 1)
    {
        u16 x;
        u16 y;
        bool hasMetafields;
        if (hasMetafields)
        {
            u16 numOfMetafields;
            u8 metafields[numOfMetafields];
        }   
    }
    else
    {
        u32 x;
        u32 y;
    }
};

struct Objects{
    u32 objCount;
    std::Array<Object, objCount> objArray;
};


Options options @ $;
Objects objects @ $;
