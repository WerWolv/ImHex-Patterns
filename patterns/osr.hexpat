#pragma description osu! replay file
#pragma MIME application/x-osu-replay
#pragma author Electrobytes

import std.io;
import std.string;
import type.leb128;


enum GameMode : u8 {
    gm_osu   = 0, 
    gm_taiko = 1,
    gm_catch = 2,
    gm_mania = 3
};

fn formatGameMode(GameMode gameMode) {
    match (gameMode) {
        (GameMode::gm_osu):   return "osu"  ;
        (GameMode::gm_taiko): return "taiko";
        (GameMode::gm_catch): return "catch";
        (GameMode::gm_mania): return "mania";
    }
    
};

enum StringIndicator : u8 {
    si_absent  = 0x00,
    si_present = 0x0b,
};

fn formatStringIndicator(StringIndicator si) {
    match (si) {
        (StringIndicator::si_absent):  return "Absent";
        (StringIndicator::si_present): return "Present";
    }
};

bitfield ModsUsed {
    NoFail : 1;
    Easy : 1;
    TouchDevice : 1;
    Hidden : 1;
    HardRock : 1;
    SuddenDeath : 1;
    DoubleTime : 1;
    Relax : 1;
    HalfTime : 1;
    Nightcore : 1;
    Flashlight : 1;
    Autoplay : 1;
    SpunOut : 1;
    Relax2 : 1;
    Perfect : 1;
    Key4 : 1;
    Key5 : 1;
    Key6 : 1;
    Key7 : 1;
    Key8 : 1;
    FadeIn : 1;
    Random : 1;
    Cinema : 1;
    TargetPractice : 1;
    Key9 : 1;
    Coop : 1;
    Key1 : 1;
    Key3 : 1;
    Key2 : 1;
    ScoreV2 : 1;
    Mirror : 1;
};

struct OSUString {
    StringIndicator indicator [[format("formatStringIndicator")]];
    if (indicator == StringIndicator::si_present) {
        type::uLEB128 length;
        char content[length];
    }
    
};

struct Hits {
    u16 great;
    u16 ok;
    u16 meh;
    u16 gekis;
    u16 katus;
    u16 misses;
};

struct OSRPattern {
    GameMode gameMode [[format("formatGameMode")]];
    u32 gameVersion;
    OSUString beatmapHashMd5;
    OSUString username;
    OSUString replayHashMd5;
    Hits hits;
    u32 totalScore [[comment("Uses classic/stable scoring")]];
    u16 greatestCombo;
    bool fullCombo;
    ModsUsed modsUsed;
    OSUString lifeBarGraph;
    u64 timeStampInTicks;
    u32 replayDataLength;
    u8 replayData[replayDataLength] [[comment("LZMA Archive")]];
    u64 onlineScoreID;
    if (!std::mem::eof()) { // Laser-only spec
        float targetPracticeAccuracy;
        u8 replayInputStream[while(!std::mem::eof())] [[comment("LZMA Archive")]];
    }
};

OSRPattern OsuReplay @ 0x0 [[name("osu! replay")]];