#pragma endian little
#include <ffx/utils.hexpat>
#include <std/math.pat>
#include <std/mem.pat>
#include <std/core.pat>

enum OpCode : u8 {
    NOP = 0x0,
    OPLOR = 0x1,
    OPLAND = 0x2,
    OPOR = 0x3,
    OPEOR = 0x4,
    OPAND = 0x5,
    OPEQ = 0x6,
    OPNE = 0x7,
    OPGTU = 0x8,
    OPLSU = 0x9,
    OPGT = 0xA,
    OPLS = 0xB,
    OPGTEU = 0xC,
    OPLSEU = 0xD,
    OPGTE = 0xE,
    OPLSE = 0xF,
    OPBON = 0x10,
    OPBOFF = 0x11,
    OPSLL = 0x12,
    OPSRL = 0x13,
    OPADD = 0x14,
    OPSUB = 0x15,
    OPMUL = 0x16,
    OPDIV = 0x17,
    OPMOD = 0x18,
    OPNOT = 0x19,
    OPUMINUS = 0x1A,
    OPFIXADRS = 0x1B,
    OPBNOT = 0x1C,
    LABEL = 0x9D,
    TAG = 0x9E,
    PUSHV = 0x9F,
    POPV = 0xA0,
    POPVL = 0xA1,
    PUSHAR = 0xA2,
    POPAR = 0xA3,
    POPARL = 0xA4,
    POPA = 0x25,
    PUSHA = 0x26,
    PUSHARP = 0xA7,
    PUSHX = 0x28,
    PUSHY = 0x29,
    POPX = 0x2A,
    REPUSH = 0x2B,
    POPY = 0x2C,
    PUSHI = 0xAD,
    PUSHII = 0xAE,
    PUSHF = 0xAF,
    JMP = 0xB0,
    CJMP = 0xB1,
    NCJMP = 0xB2,
    JSR = 0xB3,
    RTS = 0x34,
    CALL = 0xB5,
    REQ = 0x36,
    REQSW = 0x37,
    REQEW = 0x38,
    PREQ = 0x39,
    PREQSW = 0x3A,
    PREQEW = 0x3B,
    RET = 0x3C,
    RETN = 0x3D,
    RETT = 0x3E,
    RETTN = 0x3F,
    HALT = 0x40,
    PUSHN = 0xC1,
    PUSHT = 0xC2,
    PUSHVP = 0xC3,
    PUSHFIX = 0xC4,
    FREQ = 0x45,
    TREQ = 0x46,
    BREQ = 0x47,
    BFREQ = 0x48,
    BTREQ = 0x49,
    FREQSW = 0x4A,
    TREQSW = 0x4B,
    BREQSW = 0x4C,
    BFREQSW = 0x4D,
    BTREQSW = 0x4E,
    FREQEW = 0x4F,
    TREQEW = 0x50,
    BREQEW = 0x51,
    BFREQEW = 0x52,
    BTREQEW = 0x53,
    DRET = 0x54,
    POPXJMP = 0xD5,
    POPXCJMP = 0xD6,
    POPXNCJMP = 0xD7,
    CALLPOPA = 0xD8,
    POPI0 = 0x59,
    POPI1 = 0x5A,
    POPI2 = 0x5B,
    POPI3 = 0x5C,
    POPF0 = 0x5D,
    POPF1 = 0x5E,
    POPF2 = 0x5F,
    POPF3 = 0x60,
    POPF4 = 0x61,
    POPF5 = 0x62,
    POPF6 = 0x63,
    POPF7 = 0x64,
    POPF8 = 0x65,
    POPF9 = 0x66,
    PUSHI0 = 0x67,
    PUSHI1 = 0x68,
    PUSHI2 = 0x69,
    PUSHI3 = 0x6A,
    PUSHF0 = 0x6B,
    PUSHF1 = 0x6C,
    PUSHF2 = 0x6D,
    PUSHF3 = 0x6E,
    PUSHF4 = 0x6F,
    PUSHF5 = 0x70,
    PUSHF6 = 0x71,
    PUSHF7 = 0x72,
    PUSHF8 = 0x73,
    PUSHF9 = 0x74,
    PUSHAINTER = 0xF5,
    SYSTEM = 0xF6,
    REQWAIT = 0x77,
    PREQWAIT = 0x78,
    REQCHG = 0x79,
    ACTREQ = 0x7A,
};

struct Oper {
    OpCode opcode [[color("5D3FD3")]];
    match (opcode) {
        (OpCode::PUSHV | OpCode::POPV | OpCode::POPVL | OpCode::PUSHAR | OpCode::POPAR | OpCode::POPARL | OpCode::PUSHARP | OpCode::PUSHI | OpCode::PUSHF | OpCode::JMP | OpCode::CJMP | OpCode::NCJMP | OpCode::JSR | OpCode::PUSHVP | OpCode::POPXJMP  | OpCode::POPXCJMP | OpCode::POPXNCJMP): { u16 id [[color("5D3FD3")]]; }
        (OpCode::CALL | OpCode::CALLPOPA): { u16 addr [[color("5D3FD3")]]; }
        (OpCode::PUSHII): { u16 value [[color("5D3FD3")]]; }
        (OpCode::PUSHN | OpCode::PUSHT | OpCode::PUSHFIX | OpCode::PUSHAINTER | OpCode::SYSTEM): { u16 unk [[color("5D3FD3")]]; }
    }
} [[format("format_opcode"), single_color]];

fn format_opcode(ref auto oper) {
    u16 thing;
    bool set = false;
    
    match (oper.opcode) {
        (OpCode::PUSHV | OpCode::POPV | OpCode::POPVL | OpCode::PUSHAR | OpCode::POPAR | OpCode::POPARL | OpCode::PUSHARP | OpCode::PUSHI | OpCode::PUSHF | OpCode::JMP | OpCode::CJMP | OpCode::NCJMP | OpCode::JSR | OpCode::PUSHVP | OpCode::POPXJMP  | OpCode::POPXCJMP | OpCode::POPXNCJMP): { thing = oper.id; set = true; }
        (OpCode::CALL | OpCode::CALLPOPA): { thing = oper.addr; set = true; }
        (OpCode::PUSHII): { thing = oper.value; set = true; }
        (OpCode::PUSHN | OpCode::PUSHT | OpCode::PUSHFIX | OpCode::PUSHAINTER | OpCode::SYSTEM): { thing = oper.unk; set = true; }
    }
    
    if (set) {
        return std::string::substr(std::string::to_string(oper.opcode), 8, std::string::length(std::string::to_string(oper.opcode)) - 8) + " (0x" + std::format("{:X}", thing) + ")";
    }

    return std::string::substr(std::string::to_string(oper.opcode), 8, std::string::length(std::string::to_string(oper.opcode)) - 8);
};

struct EntryPoint<auto parent_id> {
    u16 id = std::core::array_index();
    u8 entry_point @ chunk_offsets[0] + parent.parent.code_offset + parent.entry_point_offsets[id] [[color("FFFFFF")]];
} [[format("format_entry_point")]];

fn format_entry_point(ref auto entry_point) {
    return "s" + std::format("{:0>2d}", entry_point.parent_id) + "e" + std::format("{:0>2d}", entry_point.id);
};

struct JumpPoint<auto parent_id> {
    u16 id = std::core::array_index();
    u8 jump_point @ chunk_offsets[0] + parent.parent.code_offset + parent.jump_offsets[id] [[color("FF00FF")]];
} [[format("format_jump_point")]];

fn format_jump_point(ref auto jump_point) {
    return "s" + std::format("{:0>2d}", jump_point.parent_id) + "j" + std::format("{:0>2d}", jump_point.id);
};

struct ScriptHeader {
    u16 id = std::core::array_index();
    u16 script_type;
    u16 var_count;
    u16 ref_int_count;
    u16 ref_float_count;
    u16 entry_point_count;
    u16 jump_count;
    padding[0x4];
    u32 priv_data_len;
    u32 var_table_offset [[highlight_hidden]];
    u32 int_table_offset [[highlight_hidden]];
    u32 float_table_offset [[highlight_hidden]];
    u32 script_begin_table_offset [[highlight_hidden]];
    u32 jumps_begin_table_offset [[highlight_hidden]];
    padding[0x4];
    u32 priv_data_offset;
    u32 shared_data_offset;

    u64 var_table[var_count] @ chunk_offsets[0] + var_table_offset;
    u32 int_table[ref_int_count] @ chunk_offsets[0] + int_table_offset;
    float float_table[ref_float_count] @ chunk_offsets[0] + float_table_offset;
    
    u32 entry_point_offsets[entry_point_count] @ chunk_offsets[0] + script_begin_table_offset;
    u32 jump_offsets[jump_count] @ chunk_offsets[0] + jumps_begin_table_offset;
    EntryPoint<id> entry_points[entry_point_count];
    JumpPoint<id> jump_points[jump_count];
};

struct WeirdBlock {
    u32 len;
    u32 data[len/sizeof(u32)];
};

struct SecondWeirdBlock {
    u32 len;
    u32 data[(len/sizeof(u32)) - 1];
};

struct ScriptChunk {
    u32 code_length;
    u32 map_start;
    u32 author_offset [[highlight_hidden]];
    u32 name_offset [[highlight_hidden]];
    u32 jumps_end_offset;
    u16 unk4;
    u16 unk5;
    u16 main_script_idx;
    u16 unk6;
    u16 unk7;
    u16 zone_bytes;
    u32 event_data_offset;
    u32 unk8;
    u32 area_offset;
    u32 other_offset;
    u32 code_offset;
    u16 script_num;
    u16 script_num_except_subroutines;
    u32 script_header_offsets[script_num];
    Oper script[while($ < code_length + code_offset + chunk_offsets[0])] @ chunk_offsets[0] + code_offset;
    ScriptHeader script_headers[script_num];
    
    u128 old_ds = $;
    $ = chunk_offsets[0] + code_offset + code_length;
    padding[std::math::ceil((float(code_offset) + float(code_length))/float(0x40)) * 0x40 - (code_offset + code_length)];
    padding[0x8];
    char timestamp[while($[$] != 0x00)];
    padding[0xA];
    u8 FFs[0x40];
    WeirdBlock weird_block;
    SecondWeirdBlock weird_block2;
    $ = old_ds;
    
    char author[name_offset - author_offset - 1] @ chunk_offsets[0] + author_offset;
    char name[script_headers[0].var_table_offset - name_offset - 1] @ chunk_offsets[0] + name_offset;
    u16 jumps_end @ chunk_offsets[0] + jumps_end_offset [[color("FF0000")]];
    u16 event_data @ chunk_offsets[0] + event_data_offset [[color("00FF00")]];
    u16 area @ chunk_offsets[0] + area_offset [[color("0000FF")]];
    u16 other @ chunk_offsets[0] + other_offset [[color("FF00FF")]];
};

struct ScriptDataEntry {
    u8 script_idx;
    u8 script_type;
    u16 entry_points_offset;
};

struct AiEntries {
    u16 on_turn;
    u16 pre_turn;
    u16 on_targetted;
    u16 on_hit;
    u16 on_death;
    u16 on_attack;
    u16 pre_poison_tick;
    u16 unk;
    u16 post_poison_tick;
    padding[0x18];
};

struct ScriptDataBlock<auto ScriptType> {
    u16 entry_point_count;
    u128 old_ds = $;
    u16 entry_point_indexes[entry_point_count] [[highlight_hidden]];
    u128 new_ds = $;
    $ = old_ds;
    
    match (ScriptType) {
        (2): {
            AiEntries ai_entry_points;
        }
    }
    $ = new_ds;
};

struct ScriptDataChunk {
    u8 script_count;
    u8;
    u8;
    padding[0x3];
    u8;
    u8 a1[0x1C];
    u8;
    u8;
    u8;
    padding[0x1];
    u8;
    u8;
    u8;
    u8;
    u8 a2[0xF];
    padding[0x5];
    u8;
    padding[0x2];
    u8;
    padding[0xE];
    u8 a3[0x1C];
    padding[0x2];
    u8 a4[0x1C];
    padding[0x1];
    ScriptDataEntry data_entries[script_count];
    ScriptDataBlock<data_entries[std::core::array_index()].script_type> blocks[script_count];
};

bitfield MonProps {
    armored: 1;
    immune_fractional_dmg: 1;
    immune_life: 1;
    immune_sensor: 1;
    padding: 1;
    immune_phys_dmg: 1;
    immune_mag_dmg: 1;
    padding: 1;
    immune_delay: 1;
};

bitfield Elements {
    fire: 1;
    ice: 1;
    thunder: 1;
    water: 1;
    holy: 1;
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
    u8 nul_ice;
    u8 regen;
    u8 haste;
    u8 slow;
};

bitfield AutoStatus {
    death: 1;
    zombie: 1;
    petrify: 1;
    poison: 1;
    power_break: 1;
    magic_break: 1;
    armor_break: 1;
    mental_break: 1;
    confuse: 1;
    berserk: 1;
    provoke: 1;
    threaten: 1;
    sleep: 1;
    silence: 1;
    darkness: 1;
    padding: 4;
    shell: 1;
    protect: 1;
    reflect: 1;
    nul_water: 1;
    nul_fire: 1;
    nul_thunder: 1;
    nul_ice: 1;
    regen: 1;
    haste: 1;
    slow: 1;
};

bitfield ExtraImmunities {
    scan: 1;
    distill_power: 1;
    distill_mana: 1;
    distill_speed: 1;
    distill_move: 1;
    distill_ability: 1;
    shield: 1;
    boost: 1;
    eject: 1;
    auto_life: 1;
    curse: 1;
    defend: 1;
    guard: 1;
    sentinel: 1;
    doom: 1;
    padding: 1;
};

struct MonStatsChunk<auto BlockIdx> {
    u16 name_offset [[hidden]];
    u16 [[hidden]];
    u16 help_offset [[hidden]];
    u16 [[hidden]];
    u16 help_hira_offset [[hidden]];
    u16 [[hidden]];
    u16 scan_offset [[hidden]];
    u16 [[hidden]];
    u16 scan_hira_offset [[hidden]];
    u16 [[hidden]];
        
    u32 hp;
    u32 mp;
    u32 overkill;
    u8 strength;
    u8 defense;
    u8 magic;
    u8 magic_defense;
    u8 agility;
    u8 luck;
    u8 evasion;
    u8 accuracy;
    MonProps props;
    u8 poison_dmg;
    Elements absorbs;
    Elements immune_to;
    Elements resists;
    Elements weak_to;
    Status status_resist;
    AutoStatus auto_status;
    padding[0x2];
    ExtraImmunities extra_status_immunities;
    padding[0x20];
    u16 forced_move;
    u16 monster_idx;
    u16 model_idx;
    u8 doom_counter;
    u16 monster_arena_idx;
    padding[0x1];
    u16 unk;
    padding[0x4];
    
    
    if (BlockIdx == 2) {
        char name[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + name_offset [[format("ffx2jp")]];
        char help[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + help_offset [[format("ffx2jp")]];
        char help_hira[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + help_hira_offset [[format("ffx2jp")]];
        char scan[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + scan_offset [[format("ffx2jp")]];
        char scan_hira[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + scan_hira_offset [[format("ffx2jp")]];
    } else {
        char name[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + name_offset [[format("ffx2ascii")]];
        char help[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + help_offset [[format("ffx2ascii")]];
        char help_hira[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + help_hira_offset [[format("ffx2ascii")]];
        char scan[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + scan_offset [[format("ffx2ascii")]];
        char scan_hira[while($[$] != 0x00)] @ chunk_offsets[BlockIdx] + 0x80 + scan_hira_offset [[format("ffx2ascii")]];
    }
};

enum Item : u16 {
    Null = 0x00,
    None = 0xFF,
    Potion = 0x2000,
    HiPotion,
    XPotion,
    MegaPotion,
    Ether,
    TurboEther,
    PhoenixDown,
    MegaPhoenix,
    Elixir,
    Megalixir,
    Antidote,
    Soft,
    EyeDrops,
    EchoScreen,
    HolyWater,
    Remedy,
    PowerDistiller,
    ManaDistiller,
    SpeedDistiller,
    AbilityDistiller,
    AlBhedPotion,
    HealingWater,
    TetraElemental,
    AntarcticWind,
    ArcticWind,
    IceGem,
    BombFragment,
    BombCore,
    FireGem,
    ElectroMarble,
    LightningMarble,
    LightningGem,
    FishScale,
    DragonScale,
    WaterGem,
    Grenade,
    FragGrenade,
    SleepingPowder,
    DreamPowder,
    SilenceGrenade,
    SmokeBomb,
    ShadowGem,
    ShiningGem,
    BlessedGem,
    SupremeGem,
    PoisonFang,
    SilverHourglass,
    GoldHourglass,
    CandleOfLife,
    PetrifyGrenade,
    FarplaneShadow,
    FarplaneWind,
    DesignerWallet,
    DarkMatter,
    ChocoboFeather,
    ChocoboWing,
    LunarCurtain,
    LightCurtain,
    StarCurtain,
    HealingSpring,
    ManaSpring,
    StaminaSpring,
    SoulSpring,
    PurifyingSalt,
    StaminaTablet,
    ManaTablet,
    TwinStars,
    StaminaTonic,
    ManaTonic,
    ThreeStars,
    PowerSphere,
    ManaSphere,
    SpeedSphere,
    AbilitySphere,
    FortuneSphere,
    AttributteSphere,
    SpecialSphere,
    SkillSphere,
    WhtMagicSphere,
    BlkMagicSphere,
    MasterSphere,
    Lv1KeySphere,
    Lv2KeySphere,
    Lv3KeySphere,
    Lv4KeySphere,
    HpSphere,
    MpSphere,
    StrengthSphere,
    DefenseSphere,
    MagicSphere,
    MagicDefSphere,
    AgilitySphere,
    EvasionSphere,
    AccuracySphere,
    LuckSphere,
    ClearSphere,
    ReturnSphere,
    FriendSphere,
    TeleportSphere,
    WarpSphere,
    Map,
    RenameCard,
    Musk,
    HypelloPotion,
    ShiningThorn,
    Pendulum,
    Amulet,
    DoorToTomorrow,
    WingsToDiscovery,
    GamblersSpirit,
    UnderdogsSecret,
    WinningFormula,
};

enum AutoAbility : u16 {
    Null = 0x00,
    None = 0xFF,
    Sensor = 0x8000,
    FirstStrike,
    Initiative,
    Counterattack,
    EvadeNCounter,
    MagicCounter,
    MagicBooster,
    Alchemy,
    AutoPotion,
    AutoMed,
    AutoPhoenix,
    Piercing,
    HalfMpCost,
    OneMpCost,
    DoubleOverdrive,
    TripleOverdrive,
    SosOverdrive,
    OverdriveToAp,
    DoubleAp,
    TripleAp,
    NoAp,
    Pickpocket,
    MasterThief,
    BreakHpLimit,
    BreakMpLimit,
    BreakDamageLimit,
    Gillionaire,
    HpStroll,
    MpStroll,
    NoEncounters,
    Firestrike,
    FireWard,
    Fireproof,
    FireEater,
    Icestrike,
    IceWard,
    Iceproof,
    IceEater,
    Lightningstrike,
    LightningWard,
    Lightningproof,
    LightningEater,
    Waterstrike,
    WaterWard,
    Waterproof,
    WaterEater,
    Deathstrike,
    Deathtouch,
    Deathproof,
    DeathWard,
    Zombiestrike,
    Zombietouch,
    Zombieproof,
    ZombieWard,
    Stonestrike,
    Stonetouch,
    Stoneproof,
    StoneWard,
    Poisonstrike,
    Poisontouch,
    Poisonproof,
    PoisonWard,
    Sleepstrike,
    Sleeptouch,
    Sleepproof,
    SleepWard,
    Silencestrike,
    Silencetouch,
    Silenceproof,
    SilenceWard,
    Darkstrike,
    Darktouch,
    Darkproof,
    DarkWard,
    Slowstrike,
    Slowtouch,
    Slowproof,
    SlowWard,
    Confuseproof,
    ConfuseWard,
    Berserkproof,
    BerserkWard,
    Curseproof,
    CurseWard,
    AutoShell,
    AutoProtect,
    AutoHaste,
    AutoRegen,
    AutoReflect,
    SosShell,
    SosProtect,
    SosHaste,
    SosRegen,
    SosReflect,
    SosNulTide,
    SosNulFrost,
    SosNulShock,
    SosNulBlaze,
    Strength3,
    Strength5,
    Strength10,
    Strength20,
    Magic3,
    Magic5,
    Magic10,
    Magic20,
    Defense3,
    Defense5,
    Defense10,
    Defense20,
    MagicDef3,
    MagicDef5,
    MagicDef10,
    MagicDef20,
    Hp5,
    Hp10,
    Hp20,
    Hp30,
    Mp5,
    Mp10,
    Mp20,
    Mp30,
    Capture,
    AeonImmunities,
    DistillPower,
    DistillMana,
    DistillSpeed,
    DistillAbility,
    Ribbon,
};

struct Spoils {
    Item item_primary_common;
    Item item_primary_rare;
    Item item_secondary_common;
    Item item_secondary_rare;
    u8 amount_primary_common;
    u8 amount_primary_rare;
    u8 amount_secondary_common;
    u8 amount_secondary_rare;
};

struct StealSpoils {
    Item item_common;
    Item item_rare;
    u8 amount_common;
    u8 amount_rare;
    Item item_bribe;
    u8 amount_bribe;
};

struct GearAbilities {
    AutoAbility weapon_abilities[8];
    AutoAbility armor_abilities[8];
};

struct GearSpoils {
    u8 slot_count;
    u8 formula;
    u8 crit;
    u8 power;
    u8 ability_count;
    GearAbilities abilities[7];
};

struct MonSpoilsChunk {
    u16 gil;
    u16 ap;
    u16 ap_overkill;
    u16 ronso_rage;
    u8 drop_chance_primary;
    u8 drop_chance_secondary;
    u8 steal_chance;
    u8 drop_chance_gear;
    Spoils drop_normal;
    Spoils drop_overkill;
    StealSpoils steal_spoils;
    GearSpoils gear_spoils;
    u8 zanmato_level;
    u8 can_steal_gil;
    u32;
};

struct ChunkFiveHeader<auto base> {
    if (base != chunk_offsets[5]) {
        u128 old_ds = $;
        $ = base;
        char thingy[8];
        u32 unk;
        u32 header_length;
        $ = old_ds;
    }
};

struct ChunkFiveWd {
    char magic[2];
};

struct Chunk5 {
    u32;
    u32;
    u32;
    u32;
    u32 header_offsets[24];
    u32 wd_block_offset;
    u32;
    u32;
    u32 chunk_len;
    
    ChunkFiveHeader<chunk_offsets[5] + header_offsets[std::core::array_index()]> headers[24];
    ChunkFiveWd wd @ chunk_offsets[5] + wd_block_offset;
};

u32 chunk_count @ 0x0;
u32 chunk_offsets[chunk_count] @ 0x4;

ScriptChunk script_chunk @ chunk_offsets[0];
ScriptDataChunk script_data_chunk @ chunk_offsets[1];
MonStatsChunk<2> stats_chunk @ chunk_offsets[2]; // Stats + Japanese strings
// chunk_offsets[3] is unused
MonSpoilsChunk spoils_chunk @ chunk_offsets[4];
Chunk5 chunk5 @ chunk_offsets[5];
MonStatsChunk<6> en_stats_chunk @ chunk_offsets[6]; // English strings