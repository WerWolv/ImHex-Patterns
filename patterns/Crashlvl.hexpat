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

enum Music : u32 {
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

enum Type : u32 {
    Unset,
    Flashback,
    Trial
};

enum Time : u32 {
    Night,
    Day,
    Storm,
    Dawn
};

enum Terrain : u32 {
    None,
    Machines,
    Trees,
    Waterfall,
    Snow,
    Fortress,
};

struct Options {
    Type type;
    Time time;
    Terrain terrain;
    Music music;
};

struct Object {
    std::string::SizedString<u8> objName;
    u32 x;
    u32 y;
};

struct Objects{
    u32 objCount;
    std::Array<Object, objCount> objArray;
};

Header header @ 0x0;
Options options @ $;
Objects objects @ $;