#pragma author AdventureT
#pragma description Crash Bandicoot - Back in Time (fan game) User created level
#pragma history
#pragma   0.3  2024-05-15 Added support for version 0.95
#pragma   0.2  2023-10-29 Added support for version 0.94c
#pragma   0.1  2023-04-25 Initial support
// Supports all versions till 0.95, newer versions might be compatible!

import type.magic;
import std.string;
import std.array;

struct Header {
    type::Magic<"CRASHLVL"> magic;
    u8 version;
    if (version >= 4) {
        std::string::SizedString<u8> gameVersion;
    }
    std::string::SizedString<u8> levelName;
    std::string::SizedString<u8> author;
};

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
    Cortex02BGM
};

// v0.95
enum BGMV3 : BGMV2 {
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
    MedievalBGM,
    PreHistoricBGM,
    UnderWaterBGM,
    BrioRevisitedBGM,
    EgyptChaseBGM,
    RuinsLoopBGM,
    DingoSynthBGM
};

enum Type : u32 {
    Unset,
    Flashback,
    Trial
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

// 0.95
enum SkyboxV3 : u32 {
    Default = 1,
    Briolab,
    Fort,
    Moon,
    Toxic,
    AboutRight,
    Crash1Island,
    Arabia,
    RoadToRuin,
    MotorcycleDay,
    MotorcycleNoon,
    MotorcycleMoon,
    MotorcycleNight,
    Black
};

enum Scenery : u32 {
    None,
    FutureTense,
    Forest,
    Waterfall,
    Snow,
    Fortress
};

enum SceneryV2 : u32 {
    None,
    FutureTense,
    Forest,
    Waterfall,
    None2,
    Fortress,
    None3,
    Lava,
    TheGreatGate,
    Mountain,
    KoalaKong,
    SunsetVista,
    HangemHigh,
    Sphynxinator,
    Tunnel,
    Pipes
};

enum SceneryV4 : u32 {
    None,
    FutureTense,
    Forest,
    Waterfall,
    Snow,
    Fortress,
    None2,
    Lava,
    TheGreatGate,
    Mountain,
    KoalaKong,
    SunsetVista,
    HangemHigh,
    Sphynxinator,
    Tunnel,
    Pipes
};

// 0.95
enum SceneryV5 : u32 {
    None,
    FutureTense,
    Forest,
    Waterfall,
    Snow,
    Fortress,
    None2,
    Lava,
    TheGreatGate,
    Mountain,
    KoalaKong,
    SunsetVista,
    HangemHigh,
    Sphynxinator,
    Tunnel,
    Pipes,
    Medieval,
    FutureCity,
    TinyArena,
    HeavyMachinery,
    CrystalCave,
    MedievalWithHouses,
    CortexBonusChamber
};

enum Weather : u32 {
    Default,
    Snow,
    Rain
};

// 0.95
enum WeatherV2 : u32 {
    Default,
    Snow,
    Rain,
    Night,
    UnderWater
};


struct Options {
    // Type
    if (header.version > 1) {
        TypeV2 type;
    }
    else {
        Type type;
    }
    // Skybox
    if (header.version > 1) {
        if (header.gameVersion == "0.95") {
            SkyboxV3 skybox;
        }
        else {
            SkyboxV2 skybox;
        }
    }
    else {
        Skybox skybox;
    }
    // Scenery
    if (header.version == 1) {
        Scenery scenery;
    }
    else if (header.version > 1 && header.version < 4) {
        SceneryV2 scenery;
    }
    else {
        if (header.gameVersion == "0.95") {
            SceneryV5 skybox;
        }
        else {
            SceneryV4 skybox;
        }
    }
    // Weather
    if (header.version > 2) {
        if (header.gameVersion == "0.95") {
            WeatherV2 weather;
        }
        else {
            Weather weather;
        }
    }
    // Background music
    if (header.version > 1) {
        BGMV2 bgm;
    }
    else {
        BGM bgm;
    }
    // Time Trial
    if (type == Type::Trial) {
        u32 timeTrialTicksBronze;
        u32 timeTrialTicksSilver;
        u32 timeTrialTicksGold;
    }
};

struct Object {
    std::string::SizedString<u8> objName;
    if (header.version > 1) {
        u16 x;
        u16 y;
        bool hasMetafields;
        if (hasMetafields) {
            u16 numOfMetafields;
            u8 metafields[numOfMetafields];
        }
    } 
    else {
        u32 x;
        u32 y;
    }
};

struct Objects{
    u32 objCount;
    std::Array<Object, objCount> objArray;
};

Header header   @ $;
Options options @ $;
Objects objects @ $;