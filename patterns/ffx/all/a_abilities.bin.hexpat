#include "std/core.pat"
#include <ffx/utils.hexpat>

bitfield Element {
    Fire : 1;
    Ice : 1;
    Thunder : 1;
    Water : 1;
    Holy : 1;
    padding : 3;
};

bitfield AutoStatus {
    Death : 1;
    Zombie : 1;
    Petrify : 1;
    Poison : 1;
    PowerBreak : 1;
    MagicBreak : 1;
    ArmorBreak : 1;
    MentalBreak : 1;
    Confuse : 1;
    Berserk : 1;
    Provoke : 1;
    Threaten : 1;
    Sleep : 1;
    Silence : 1;
    Darkness : 1;
    Shell : 1;
    Protect : 1;
    Reflect : 1;
    NulWater : 1;
    NulFire : 1;
    NulThunder : 1;
    NulBlizzard : 1;
    Regen : 1;
    Haste : 1;
    Slow : 1;
};

bitfield ExtraStatusFlags {
    Scan : 1;
    DistillPower : 1;
    DistillMana : 1;
    DistillSpeed : 1;
    _DistillMove : 1;
    DistillAbility : 1;
    Shield : 1;
    Boost : 1;
    Eject : 1;
    AutoLife : 1;
    Curse : 1;
    Defend : 1;
    Guard : 1;
    Sentinel : 1;
    Doom : 1;
    _Unk : 1;
};

bitfield Stats {
    Hp : 1;
    Mp : 1;
    Str : 1;
    Mag : 1;
    Def : 1;
    MDef : 1;
};

bitfield Abilities {
    Sensor : 1;
    FirstStrike : 1;
    Initiative : 1;
    Counterattack : 1;
    EvadeNCounter : 1;
    MagicCounter : 1;
    MagicBooster : 1;
    Unk1 : 1;
    Unk2 : 1;
    Alchemy : 1;
    AutoPotion : 1;
    AutoMed : 1;
    AutoPhoenix : 1;
    Piercing : 1;
    HalfMpCost : 1;
    OneMpCost : 1;
    DoubleOverdrive : 1;
    TripleOverdrive : 1;
    SosOverdrive : 1;
    OverdriveToAp : 1;
    DoubleAp : 1;
    TripleAp : 1;
    NoAp : 1;
    Pickpocket : 1;
    MasterThief : 1;
    Bhpl : 1;
    Bmpl : 1;
    Bdl : 1;
    Unk3 : 1;
    Unk4 : 1;
    Gillionaire : 1;
    HpStroll : 1;
    MpStroll : 1;
    NoEncounters : 1;
    Capture : 1;
    Unk5 : 1;
    Unk6 : 1;
    Unk7 : 1;
    Unk8 : 1;
    Unk9 : 1;
};

struct Status {
    u8 death;
    u8 zombie;
    u8 petrify;
    u8 poison;
    u8 power_break;
    u8 magic_break;
    u8 armor_break;
    u8 mental_break;
    u8 confuse;
    u8 berserk;
    u8 provoke;
    u8 threaten;
    u8 sleep;
    u8 silence;
    u8 darkness;
    u8 shell;
    u8 protect;
    u8 reflect;
    u8 nul_water;
    u8 nul_fire;
    u8 nul_thunder;
    u8 nul_blizzard;
    u8 regen;
    u8 haste;
    u8 slow;
};

struct StatusDur {
    u8 sleep;
    u8 silence;
    u8 darkness;
    u8 shell;
    u8 protect;
    u8 reflect;
    u8 nul_water;
    u8 nul_fire;
    u8 nul_thunder;
    u8 nul_blizzard;
    u8 regen;
    u8 haste;
    u8 slow;
};

struct AutoAbility {
    String name;
    String dash;
    String description;
    String misc;
    bool is_sos;
    Element element_strike;
    Element element_absorb;
    Element element_immune;
    Element element_resist;
    Element element_weak;
    Status status_inflict;
    StatusDur status_durations;
    Status status_resist;
    u8 stat_inc_amount;
    u8 unk1;
    Stats stat_inc_flags;
    AutoStatus auto_status;
    u8 unk2;
    u8 unk3;
    ExtraStatusFlags extra_status_inflict_flags;
    ExtraStatusFlags extra_status_resist_flags;
    Abilities ability_flags;
    u8 unk4;
    u8 icon;
    u8 group_idx;
    u8 group_level;
    u8 international_bonus_idx;
} [[format("format_auto_ability")]];

fn format_auto_ability(ref auto ability) {
    return std::format("0x{:0>4X}", std::core::array_index() + 0x8000);
};

AutoAbility abilities[block_count] @ start_offset;