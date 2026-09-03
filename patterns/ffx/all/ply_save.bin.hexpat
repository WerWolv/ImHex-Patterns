#include <std/core.pat>
#include <std/io.pat>
#include <std/string.pat>
#pragma endian little

enum Character : u8 {
    Tidus = 0x00,
    Yuna = 0x01,
    Auron = 0x02,
    Kimahri = 0x03,
    Wakka = 0x04,
    Lulu = 0x05,
    Rikku = 0x06,
    Seymour = 0x07,
    Valefor = 0x08,
    Ifrit = 0x09,
    Ixion = 0x0A,
    Shiva = 0x0B,
    Bahamut = 0x0C,
    Anima = 0x0D,
    Yojimbo = 0x0E,
    Cindy = 0x0F,
    Sandy = 0x10,
    Mindy = 0x11,
    Dummy1 = 0x12,
    Dummy2 = 0x13,
};

struct Stats {
    u8 strength;
    u8 defense;
    u8 magic;
    u8 magic_defense;
    u8 agility;
    u8 luck;
    u8 evasion;
    u8 accuracy;
};

bitfield AbiMap {
    Attack : 1;
    Item : 1;
    Switch : 1;
    Escape : 1;
    Weapon : 1;
    Armor : 1;
    DelayAttack : 1;
    DelayBuster : 1;
    SleepAttack : 1;
    SilenceAttack : 1;
    DarkAttack : 1;
    ZombieAttack : 1;
    SleepBuster : 1;
    SilenceBuster : 1;
    DarkBuster : 1;
    TripleFoul : 1;
    PowerBreak : 1;
    MagicBreak : 1;
    ArmorBreak : 1;
    MentalBreak : 1;
    Mug : 1;
    QuickHit : 1;
    Steal : 1;
    Use : 1;
    Flee : 1;
    Pray : 1;
    Cheer : 1;
    Aim : 1;
    Focus : 1;
    Reflex : 1;
    Luck : 1;
    Jinx : 1;
    Lancet : 1;
    Unused : 1;
    Guard : 1;
    Sentinel : 1;
    SpareChange : 1;
    Threaten : 1;
    Provoke : 1;
    Entrust : 1;
    Copycat : 1;
    Doublecast : 1;
    Bribe : 1;
    Cure : 1;
    Cura : 1;
    Curaga : 1;
    NulBlizzard : 1;
    NulFire : 1;
    NulThunder : 1;
    NulWater : 1;
    Scan : 1;
    Esuna : 1;
    Life : 1;
    FullLife : 1;
    Haste : 1;
    Hastega : 1;
    Slow : 1;
    Slowga : 1;
    Shell : 1;
    Protect : 1;
    Reflect : 1;
    Dispel : 1;
    Regen : 1;
    Holy : 1;
    AutoLife : 1;
    Blizzard : 1;
    Fire : 1;
    Thunder : 1;
    Water : 1;
    Fira : 1;
    Blizzara : 1;
    Thundara : 1;
    Watera : 1;
    Firaga : 1;
    Blizzaga : 1;
    Thundaga : 1;
    Waterga : 1;
    Bio : 1;
    Demi : 1;
    Death : 1;
    Drain : 1;
    Osmose : 1;
    Flare : 1;
    Ultima : 1;
    Shield : 1;
    Boost : 1;
    Dismiss : 1;
    DismissYojimbo : 1;
    PilferGil : 1;
    FullBreak : 1;
    DistillPower : 1;
    DistillMana : 1;
    DistillSpeed : 1;
    DistillAbility : 1;
    NabGil : 1;
    QuickPockets : 1;
};

enum OverdriveModes : u8 {
    Warrior = 0x00,
    Comrade = 0x01,
    Stoic = 0x02,
    Healer =  0x03,
    Tactician = 0x04,
    Victim = 0x05,
    Dancer = 0x06,
    Avenger = 0x07,
    Slayer = 0x08,
    Hero = 0x09,
    Rook = 0x0A,
    Victor = 0x0B,
    Coward = 0x0C,
    Ally = 0x0D,
    Sufferer = 0x0E,
    Daredevil = 0x0F,
    Loner = 0x10,
    Unused1 = 0x11,
    Unused2 = 0x12,
    Aeon = 0x13,
};

struct OverdriveModeCounts {
    u16 warrior;
    u16 comrade;
    u16 stoic;
    u16 healer;
    u16 tactician;
    u16 victim;
    u16 dancer;
    u16 avenger;
    u16 slayer;
    u16 hero;
    u16 rook;
    u16 victor;
    u16 coward;
    u16 ally;
    u16 sufferer;
    u16 daredevil;
    u16 loner;
    u16 unused1;
    u16 unused2;
    u16 aeon;
};

bitfield OverdriveModeFlags {
    Warrior : 1;
    Comrade : 1;
    Stoic : 1;
    Healer : 1;
    Tactician : 1;
    Victim : 1;
    Dancer : 1;
    Avenger : 1;
    Slayer : 1;
    Hero : 1;
    Rook : 1;
    Victor : 1;
    Coward : 1;
    Ally : 1;
    Sufferer : 1;
    Daredevil : 1;
    Loner : 1;
    Unused1 : 1;
    Unused2 : 1;
    Aeon : 1;
    padding: 8;
};

struct Char {
    u32 _0x00;
    u32 base_hp;
    u32 base_mp;
    Stats base_stats;
    u16 __0x14;
    u16 __0x16;
    u32 ap;
    u32 hp;
    u32 mp;
    u32 max_hp;
    u32 max_mp;
    u8 flags;
    u8 wpn_inv_idx;
    u8 arm_inv_idx;
    Stats cur_stats;
    u8 poison_dmg;
    OverdriveModes overdrive_mode_selected;
    u8 overdrive_charge;
    u8 overdrive_max_charge;
    u8 slv_available;
    u8 slv_expended;
    u8 __0x3D;
    AbiMap abilities;
    u16 __0x4A;
    u16 __0x4C;
    u16 __0x4E;
    u32 encounter_count;
    u32 enemies_defeated;
    u32 __0x58;
    u32 __0x5C;
    OverdriveModeCounts overdrive_mode_counts;
    OverdriveModeFlags overdrive_modes;
    u32 __0x8C;
    u32 __0x90;
};

u32 start_offset @ 0x10 [[hidden]];
Char tidus @ start_offset + 0x94 * 0;
Char yuna @ start_offset + 0x94 * 1;
Char auron @ start_offset + 0x94 * 2;
Char kimahri @ start_offset + 0x94 * 3;
Char wakka @ start_offset + 0x94 * 4;
Char lulu @ start_offset + 0x94 * 5;
Char rikku @ start_offset + 0x94 * 6;
Char seymour @ start_offset + 0x94 * 7;
Char valefor @ start_offset + 0x94 * 8;
Char ifrit @ start_offset + 0x94 * 9;
Char ixion @ start_offset + 0x94 * 10;
Char shiva @ start_offset + 0x94 * 11;
Char bahamut @ start_offset + 0x94 * 12;
Char anima @ start_offset + 0x94 * 13;
Char yojimbo @ start_offset + 0x94 * 14;
Char cindy @ start_offset + 0x94 * 15;
Char sandy @ start_offset + 0x94 * 16;
Char mindy @ start_offset + 0x94 * 17;
Char dummy1 @ start_offset + 0x94 * 18;
Char dummy2 @ start_offset + 0x94 * 19;