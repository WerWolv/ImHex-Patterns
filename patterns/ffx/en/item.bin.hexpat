#include <std/core.pat>
#include <std/io.pat>
#include <ffx/utils.hexpat>

enum SphereRole : u8 {
    Power = 0x00,
    Mana = 0x01,
    Speed = 0x02,
    Ability = 0x03,
    Fortune = 0x04,
    Special = 0x05,
    Skill = 0x06,
    WhiteMagic = 0x07,
    BlackMagic = 0x08,
    Master = 0x09,
    Lv1Key = 0x0A,
    Lv2Key = 0x0B,
    Lv3Key = 0x0C,
    Lv4Key = 0x0D,
    Luck = 0x0E,
    Hp = 0x0F,
    Mp = 0x10,
    Return = 0x11,
    Friend = 0x12,
    Teleport = 0x13,
    Warp = 0x14,
    Strength = 0x15,
    Defense = 0x16,
    Magic = 0x17,
    MagicDefense = 0x18,
    Agility = 0x19,
    Evasion = 0x1A,
    Accuracy = 0x1B,
    Clear = 0x1C,
    Attribute = 0x1D,
};

enum DamageFormula : u8 {
    None = 0x00,
    StrVsDef = 0x01,
    StrIgnoreDef = 0x02,
    MagVsMDef = 0x03,
    MagIgnoreMDef = 0x04,
    CurrentDiv16 = 0x05,
    Multiple50 = 0x06,
    Healing = 0x07,
    MaxDiv16 = 0x08,
    Multiple50WithVariance = 0x09,
    TicksDiv16 = 0x0D,
    SpecialMag = 0x0F,
    FixedUserMaxHP = 0x10,
    FixedChosenGil = 0x15,
    FixedKills = 0x16,
    Fixed9999 = 0x17,
};

enum SubMenus : u8 {
    None = 0x0,
    BlackMagic = 0x01,
    WhiteMagic = 0x02,
    Skill = 0x03,
    Overdrive = 0x04,
    Summon = 0x05,
    Items = 0x06,
    WeaponChange = 0x07,
    Escape = 0x08,
    SwitchCharacter = 0x0A,
    Special = 0xE,
    ArmorChange = 0xF,
    Use = 0x11,
    Mix = 0x14,
    Gil = 0x15,
    Yojimbo = 0x16,
};

enum OverdriveCategory : u8 {
    None = 0x0,
    MenuCommand = 0x1,
    Tier1 = 0x2,
    Tier2 = 0x3,
    Tier3 = 0x4,
    Tier4 = 0x5,
};

enum Characters : u8 {
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
    Dummy = 0x12,
    Dummy2 = 0x13,
    None = 0xFF,
};

bitfield Elements {
	fire : 1;
	ice : 1;
	thunder : 1;
	water : 1;
	holy : 1;
	flag6 : 1;
	flag7 : 1;
	flag8 : 1;
};

bitfield TargetFlags {
	enabled : 1;
	enemies : 1;
	multi : 1;
	self_only : 1;
	flag5 : 1;
	either_team : 1;
	dead : 1;
	flag8 : 1;
};

bitfield MenuPropFlags {
	top_level_in_menu : 1;
    padding : 3;
	opens_sub_menu : 1;
};

	
bitfield MiscProps {
	usable_outside_combat : 1;
	usable_in_combat : 1;
	display_move_name : 1;
	flag4 : 1;
	can_miss : 1;
	flag6 : 1;
	affected_by_darkness : 1;
	can_be_reflected : 1;
	absorb_dmg : 1;
	steal_item : 1;
	in_use_menu : 1;
	in_sub_menu : 1;
	in_trigger_menu : 1;
	inflict_delay_weak : 1;
	inflict_delay_strong : 1;
	random_targets : 1;
	is_piercing : 1;
	affect_by_silence : 1;
	uses_weapon_props : 1;
	is_trigger_command : 1;
	use_tier1_cast_anim : 1;
	use_tier3_cast_anim : 1;
	destroy_user : 1;
	miss_if_alive : 1;
};

bitfield AnimProps {
	flag1 : 1;
	flag2 : 1; 
	flag3 : 1; 
	user_runs_off : 1;
	flag5 : 1; 
	flag6 : 1;
	flag7 : 1; 
	flag8 : 1; 
};

bitfield DmgProps {
	is_physical : 1;
	is_magical : 1;
	can_crit : 1;
    gives_crit_bonus : 1; 
	is_healing : 1;
	is_cleansing : 1; 
	supress_bdl : 1; 
	break_dmg_limit : 1;
};

bitfield PartyPreviewProps {
	uses_preview : 1;
	heals_mp : 1;
	heal_status : 1;
	heal_hp : 1;
};

bitfield DamageClass {
	hp : 1;
	mp : 1;
	ctb : 1;
	flag4 : 1;
};

bitfield InflictSpecialStatusFlags {
	scan : 1;
	distill_power : 1;
	distill_mana : 1;
	distill_speed : 1;
	unused1 : 1;
	distill_ability : 1;
	shield : 1;
	boost : 1;
	eject : 1;
	auto_life : 1;
	curse : 1;
	defend : 1;
	guard : 1;
	sentinel : 1;
	doom : 1;
	unused2 : 1;
};

bitfield StatBuffFlags {
	cheer : 1;
	aim : 1;
	focus : 1;
	reflex : 1;
	luck : 1;
	jinx : 1;
	unused1 : 1;
	unused2 : 1;
};

bitfield SpecialBuffFlags {
	double_hp : 1;
	double_mp : 1;
	spellspring : 1;
	dmg_9999 : 1;
	always_crit : 1;
	overdrive_150 : 1;
	overdrive_200 : 1;
	unused1 : 1;
};

struct Status {
	u8 chance_death;
	u8 chance_zombie;
	u8 chance_petrify;
	u8 chance_poison;
	u8 chance_power_break;
	u8 chance_magic_break;
	u8 chance_armor_break;
	u8 chance_mental_break;
	u8 chance_confuse;
	u8 chance_berserk;
	u8 chance_provoke;
	u8 chance_threaten;
	u8 chance_sleep;
	u8 chance_silence;
	u8 chance_darkness;
	u8 chance_shell;
	u8 chance_protect;
	u8 chance_reflect;
	u8 chance_nul_water;
	u8 chance_nul_fire;
	u8 chance_nul_thunder;
	u8 chance_nul_ice;
	u8 chance_regen;
	u8 chance_haste;
	u8 chance_slow;

	u8 dur_sleep;
	u8 dur_silence;
	u8 dur_darkness;
	u8 dur_shell;
	u8 dur_protect;
	u8 dur_reflect;
	u8 dur_nul_water;
	u8 dur_nul_fire;
	u8 dur_nul_thunder;
	u8 dur_nul_ice;
	u8 dur_regen;
	u8 dur_haste;
	u8 dur_slow;
};

bitfield ExtraStatusFlags {
    scan : 1;
    distill_power : 1;
    distill_mana : 1;
    distill_speed : 1;
    distill_move : 1;
    distill_ability : 1;
    shield : 1;
    boost : 1;
    eject : 1;
    auto_life : 1;
    curse : 1;
    defend : 1;
    guard : 1;
    sentinel : 1;
    doom : 1;
    unused : 1;
};

struct Command {
    String2 name;
    String2 desc;
    u16 anim1;
    u16 anim2;
    u8 icon;
    u8 caster_anim;
    MenuPropFlags menu_props;
    SubMenus sub_menu_cat_2;
    SubMenus sub_menu_cat;
    Characters chr_user;
    TargetFlags target_flags;
    u8 unk_props;
    MiscProps misc_props;
    AnimProps anim_props;
    DmgProps dmg_props;
    bool steal_gil;
    bool party_preview;
    DamageClass dmg_class;
    u8 move_rank;
    u8 mp_cost;
    u8 overdrive_cost;
    u8 crit_bonus;
    DamageFormula dmg_formula;
    u8 accuracy;
    u8 power;
    u8 hit_count;
    u8 shatter_chance;
    Elements elements;
    Status status;
    ExtraStatusFlags extra_status;
    StatBuffFlags stat_buffs;
    u8 unk_0x57;
    OverdriveCategory overdrive_cat;
    u8 stat_buffs_value;
    SpecialBuffFlags special_buffs;
    u8 unk_0x5b;
    u8 ordering_idx_in_menu;
    SphereRole sphere_grid_role;
    u8 unk_0x5e;
    u8 unk_0x5f;
} [[format("format_item")]];

fn format_item(ref Command item) {
    return std::format("0x{:0>3X} - {} ({})", std::core::array_index(), ffx2ascii(item.name.text), ffx2ascii(item.desc.text));
};

Command moves[block_count] @ start_offset;