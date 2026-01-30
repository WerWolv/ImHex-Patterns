#pragma author Noxde
#pragma description Bloodborne Save file

// Made while working on https://github.com/Noxde/Bloodborne-save-editor
/** Resources:
* https://www.bloodborne-wiki.com/2017/05/modded-save.html
* https://docs.google.com/spreadsheets/d/1zFIzhnXHhYomlR-tFJcyk3cPywf1snqkDH900j6rtAI/
* https://www.youtube.com/watch?v=DXMcs402kKQ (character stats, weapons and more)
* https://www.youtube.com/watch?v=Sh0sYyZ4stM (appearance)
**/

import std.io;
import std.mem;
import std.string;

fn get_inventory_offset() {
    return std::mem::find_sequence(0, 0x40, 0xf0, 0xff, 0xff);
};

fn get_lced_offset() {
    return std::mem::find_sequence(0, 0x4C, 0x43, 0x45, 0x44);
};

fn get_aob() {
    return std::mem::find_sequence(0, 0x03, 0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0x00);
};

fn get_username_offset() {
    return get_inventory_offset() - 469;
};

auto first_dungeon = get_inventory_offset() + 88328;

using NullString16 = std::string::NullString16; 

auto u = get_username_offset();
auto l = get_lced_offset();
auto aob = get_aob();
auto pattern_offset = std::mem::find_sequence_in_range(0, l, l + 10000, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00);

// Save data //

struct Dungeon {
    padding[1];
    u8 AreaDepth;
    u16 Layout;
    u64 IdServer;
    padding[1];
    u8 AreaDepth2;
    u16 Layout2;
    u32 JoinReq;
    u64 SpecialEnemyShop;
    u64 UniqueItem;
    u64 GemEffect;
    u64 FourthLayer;
    u64 Poison;
    u64 Fetid;
    u64 Rotted;
    u64 Cursed;
    u64 Unused;
    u128 Psn;
    u128 CharName;
    padding[1];
};

struct Flags {
    u8 MoonPhase @ aob + 6102;
};

struct Coordinates {
    float X;
    float Y;
    float Z;
};

struct ClericBeast {
    u8 Defeated @ aob + 21714; // dead = 08
};

struct FatherGascoigne {
    u8 Defeated @ aob + 21727; // dead = 80
};

struct VicarAmelia {
    u8 Defeated @ aob + 21602; // dead = 80
};

struct BloodStarvedBeast {
    u8 Defeated @ aob + 21477; // dead = 80
};

struct DarkBeastPaarl {
    u8 Defeated @ aob + 21464; // dead = 08
};

struct WitchOfHemwick {
    u8 Defeated @ aob + 21352; // dead = 80
};

struct CelestialEmissary {
    u8 Defeated @ aob + 21839; // dead = 08
};

struct Ebrietas {
    u8 Defeated @ aob + 21852; // dead = 80
};

struct MartyrLogarius {
    u8 Defeated @ aob + 21977; // dead = 80
};

struct MergoWetNurse {
    u8 Defeated @ aob + 22102; // dead = 80
};

struct Micolash {
    u8 Defeated @ aob + 22108; // dead = 3F
};

struct ShadowsOfYharnam {
    u8 Defeated @ aob + 22227; // dead = 80
};

struct OneReborn {
    u8 Defeated @ aob + 22352; // dead = 80
};

struct Rom {
    u8 Defeated @ aob + 22602; // dead = 80
};

struct Amygdala {
    u8 Defeated @ aob + 22727; // dead = 80
};

struct Ludwig {
    u8 Defeated @ aob + 22852; // dead = 80
    // I'm not so sure about the head flags but they are here just in case
    u8 HeadAlive @ aob + 22852 - 64; // show = 20 
    u8 HeadDead @ aob + 22852 - 64; // show = 02
    // Set both enables to 0 to actually revive him, these are kinda weird but it's what I found trying to make him work
    u8 Enable @ aob + 22852 - 16792; // dead = 82
    u8 Enable2 @ aob + 22852 - 16792 - 15; // dead = 01; alive = 02; midfight = 82
};

// All of these dead values will re-trigger cinematics
struct Laurence {
    u8 Defeated @ aob + 22858; // dead = 20
};

struct LadyMaria {
    u8 Defeated @ aob + 22977; // dead = 80
};

struct LivingFailures {
    u8 Defeated @ aob + 22983; // dead = 20
};

struct Kos {
    u8 Defeated @ aob + 23102; // dead = 80
};

struct MoonPresence {
    u8 Defeated @ aob + 21108; // dead = 20
};

struct Gehrman {
    u8 Defeated @ aob + 21102; // dead = 80
};

struct Bosses {
    ClericBeast ClericBeast;
    FatherGascoigne FatherGascoigne;
    VicarAmelia VicarAmelia;
    ShadowsOfYharnam ShadowsOfYharnam;
    Rom Rom;
    OneReborn OneReborn;
    Micolash Micolash;
    Amygdala Amygdala;
    Ludwig Ludwig;
    Laurence Laurence;
    LadyMaria LadyMaria;
    LivingFailures LivingFailures;
    Kos Kos;
    BloodStarvedBeast BloodStarvedBeast;
    DarkBeastPaarl DarkBeastPaarl;
    WitchOfHemwick WitchOfHemwick;
    CelestialEmissary CelestialEmissary;
    Ebrietas Ebrietas;
    MartyrLogarius MartyrLogarius;
    MergoWetNurse MergoWetNurse;
    Gehrman Gehrman;
    MoonPresence MoonPresence;
};

struct Save {
    u32 loadedMap @ 4;
    u32 Playtime @ 8;
    Dungeon Dungeons[6] @ first_dungeon;
    Flags Flags;
    Bosses Bosses;
};

// Player data //

struct Appearance {
    u32 start @ get_inventory_offset() + 34028;
};

struct Health {
  u32 current_health;
  u32 max_health_buff;
  u32 max_health; 
};

struct Stamina {
  u32 current_stamina;
  u32 max_stamina_buff;
  u32 max_stamina; 
};

struct Stats {
    u32 Vitality @ u - 103;
    u32 Endurance @ u - 95;
    u32 Strength @ u - 79;
    u32 Skill @ u - 71;
    u32 Bloodtinge @ u -63;
    u32 Arcane @ u - 55;
};

struct InventoryData {
    u32 Inventory_Start @ get_inventory_offset();
    u8  Inventory_First_Counter @ u + 453;
    u8  Inventory_Second_Counter @ u + 34257;
};

struct StorageData {
    u32 Storage_Start @ get_inventory_offset() + 34268;
    u8  Storage_First_Counter @ u + 34737;
    u8  Storage_Second_Counter @ u + 68541;
};

struct Player {
    NullString16 Username @ u + 1;
    Health Health @ u - 147;
    Stamina Stamina @ u - 119;
    u32 Echoes @ u - 19;
    u32 Insight @ u - 35;
    u32 Level @ u - 23;
    Stats Stats;
    u8 Gender @ u + 35;
    u8 Voice @ u + 36;
    u8 Origin @ u + 39;
    Appearance Appearance;
    u8 Ng @ u + 68831;
    InventoryData Inventory;  
    StorageData Storage;
    Coordinates Coordinates @ pattern_offset + 12;
    u32 DeathCount @ aob + 360;
};

Player Player @ get_username_offset();
Save Save @ get_username_offset();