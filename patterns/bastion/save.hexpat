#include <type/time.pat>
#include <bastion/util.hexpat>

struct TimeStamp {
    type::time64_t value;
} [[format("fmt_timestamp")]];

fn fmt_timestamp(ref auto timestamp) {
    return type::impl::format_time_t(timestamp.value);
};

struct Generator {
    List<s32> plot_ids;
    List<StringLEB128> plant_names;
    Map<s32, TimeStamp> last_date_time_used;
};

struct WorldStateData {
    s32 version;
    if (version < 1) return;
    
    StringLEB128 name;
    type::time64_t;
    List<s32> activated_things;
    List<s32> dead_things;
    List<s32> explored_tiles;
    Generator generator;
} [[format("fmt_named")]];

struct Counter {
    StringLEB128 name;
    s32 amount;
    type::time64_t file_time;
} [[format("fmt_counter")]];

fn fmt_counter(ref auto c) {
    return std::format("{}: {}", c.name, c.amount);
};

struct ActiveWeaponData {
    StringLEB128 name;
    StringLEB128 slot;
} [[format("fmt_weapon")]];

fn fmt_weapon(ref auto w) {
    return std::format("{} ({})", w.name, w.slot);
};

struct PlayerData {
    List<StringLEB128> stored_weapons;
    List<ActiveWeaponData> active_weapons;
};

struct SaveData {
    s32 version;
    if (version != 2) return;
    
    Map<StringLEB128, WorldStateData> world_states;
    List<Set<StringLEB128>> flag_sets;
    List<Set<Counter>> counter_sets;
    PlayerData player_data;
};

s32 checksum @ 0x0;
SaveData save @ 0x4;