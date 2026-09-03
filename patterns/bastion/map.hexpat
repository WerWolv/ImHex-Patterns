#include <std/string.pat>
#include <type/color.pat>
#include <bastion/util.hexpat>

struct AiData {
    bool use_target_ai;
    bool use_move_ai;
    bool use_attack_ai;
} [[format("fmt_aidata")]];

fn fmt_aidata(ref auto data) {
    return std::format(
            "Target: {}, Move: {}, Attack: {}",
            data.use_target_ai,
            data.use_move_ai,
            data.use_attack_ai);
};

struct OrthoData {
    bool horizontal;
    bool vertical;
} [[format("fmt_orthodata")]];

fn fmt_orthodata(ref auto data) {
    return std::format("Horizontal: {}, Vertical: {}", data.horizontal, data.vertical);
};

struct UnexploredData {
    float contrast;
    float saturation;
} [[format("fmt_unexploreddata")]];

fn fmt_unexploreddata(ref auto data) {
    return std::format("Contrast: {:.4}, Saturation: {:.4}", data.contrast, data.saturation);
};

struct TerrainLightData {
    StringLEB128 texture;
    Vector2<float> velocity;
} [[format("fmt_terrainlightdata")]];

fn fmt_terrainlightdata(ref auto data) {
    return std::format("{} @ {}", data.texture, data.velocity);
};

struct RefractData {
    float rate;
    float amount;
} [[format("fmt_refractdata")]];

fn fmt_refractdata(ref auto data) {
    return std::format("-> {:.4} @ {:.4}", data.amount, data.rate);
};

struct ScrollData {
    float speed;
    float angle;
} [[format("fmt_scrolldata")]];

fn fmt_scrolldata(ref auto data) {
    return std::format("Speed: {:.4}, Angle: {:.4}", data.speed, data.angle);
};

struct CamData {
    Vector2<float> pos;
    float zoom;
} [[format("fmt_camdata")]];

fn fmt_camdata(ref auto data) {
    return std::format("{} @ {:.4}%", data.pos, data.zoom);
};

struct MapThing {
    s32 version;
    
    if (version >= 1) {
        StringLEB128 type;
        StringLEB128 name;
        Vector2<s32> location;
    }
    
    if (version >= 2) {
        bool active;
        bool activate_when_seen;
    }
    
    if (version >= 3) Vector2<s32> end_location;
    if (version >= 4) s32 id;
    if (version >= 5) s32 activate_on_enter_id;
    if (version >= 6) StringLEB128 activate_on_enter_name;
    if (version >= 7) List<StringLEB128> activate_on_enter_names;
    if (version >= 8) bool requires_solid_ground;
    if (version >= 9) StringLEB128 group_name;
    if (version >= 10) AiData ai_data;
    if (version >= 11) s32 flip_effect;
    if (version >= 12) OrthoData flip_data;
    if (version >= 13) List<s32> activate_on_enter_ids;
    if (version >= 14) bool drop_loot;
    if (version >= 15) s32 sort_modifier;
    if (version >= 16) type::RGBA8 color;
    if (version >= 17) float scale;
    if (version >= 18) bool use_unexplored_hue;
    if (version >= 19) float health_fraction;
    if (version >= 20) bool walkable;
    if (version >= 21) bool invulnerable;
    
    if (version >= 22) {
        bool use_as_fx;
        float rotation_speed;
        StringLEB128 draw_layer;
    }
    
    if (version >= 23) float offset_z;
    if (version >= 24) float angle;
    if (version >= 25) bool fall_in;
    if (version >= 26) s32 attach_to_id;
    if (version >= 27) float activation_range;
    if (version >= 28) StringLEB128 help_text_id;
    if (version >= 29) bool flying;
    if (version >= 30) List<StringLEB128> group_names;
    if (version >= 31) bool give_xp;
    if (version >= 32) bool friendly;
    if (version >= 33) bool parallax;
    if (version >= 34) bool ignore_grid_manager;
    if (version >= 35) bool wobble;
} [[format("fmt_mapthing")]];

fn fmt_mapthing(ref auto thing) {
    return std::format("{} ({})", thing.name, thing.type);
};

struct MapThingGroup {
    s32 version;
    if (version < 1) return;
    
    StringLEB128 name;
    List<MapThing> map_things;
    bool visible;
    bool selectable;
} [[format("fmt_mapthinggroup")]];

fn fmt_mapthinggroup(ref auto group) {
    if (group.version < 1) return "Empty";
    return std::format("{} ({} things)", group.name, group.map_things.length);
};

struct BackdropFlyerData {
    List<StringLEB128> flyers;
    Range<float> interval;
    Range<float> speed;
    type::RGBA8 color;
};

struct BloomSettings {
    StringLEB128 name;
    float bloom_threshold;
    float blur_amount;
    float bloom_intensity;
    float base_intensity;
    float bloom_saturation;
    float base_saturation;
} [[format("fmt_named")]];

struct TerrainLayerData {
    s32 version;
    
    if (version >= 1) {
        StringLEB128 name;
        type::RGBA8 color;
    }
    
    if (version >= 2) List<MapThing> tiles;
    if (version >= 3) List<TerrainLayerData> linked_layers;
    if (version >= 4) bool mask;
    
    if (version >= 5) {
        s32 blend_filter;
    }
    
    if (version >= 6) {
        s32 shader;
        float contrast;
    }
    
    if (version >= 7) float saturation;
} [[format("fmt_named")]];

struct SpawnData {
    s32 version;
    
    if (version >= 1) {
        StringLEB128 name;
        s32 num;
    }
    
    if (version >= 2) s32 max_attempts;
} [[format("fmt_spawndata")]];

fn fmt_spawndata(ref auto data) {
    return std::format("{}x {}", data.num, data.name);
};

struct SpawnWaveData {
    s32 version;
    
    if (version >= 1) {
        Range<float> interval;
        List<SpawnData> spawn_data;
        s32 loop_to_wave;
        s32 repeat_times;
        float count_scalar;
        float interval_scalar;
    }
    
    if (version >= 2) Range<float> first_spawn_interval;
};

struct SpawnPointData {
    s32 version;
    
    if (version >= 1) {
        StringLEB128 name;
        Range<s32> offset_x;
        Range<s32> offset_y;
        List<SpawnWaveData> spawn_waves;
    }
    
    if (version >= 2) OrthoData snap_data;
} [[format("fmt_spawnpoint")]];

fn fmt_spawnpoint(ref auto data) {
    return std::format("{} ({} waves)", data.name, data.spawn_waves.length);
};

struct MapData {
    s32 version;
    
    if (version >= 1) {
        if (version < 20) List<MapThing> map_things;
        List<SpawnPointData> spawn_point_data;
        s32 starting_cash;
        StringLEB128 name;
        StringLEB128 loot_table_name;
    }
    
    if (version >= 2) float pathfinder_bonus;
    if (version >= 3) ScrollData scroll_data;
    if (version >= 4) Vector2<s32> size;
    if (version >= 5) StringLEB128 music_name;
    if (version >= 6) StringLEB128 ambience_name;
    if (version >= 7) List<TerrainLayerData> terrain_layer_data;
    if (version >= 8) List<StringLEB128> scripts;
    
    if (version >= 9) {
        List<StringLEB128> backdrop_tiles;
        s32 backdrop_columns;
        type::RGBA8 backdrop_color;
    }
    
    if (version >= 10) BackdropFlyerData backdrop_flyer_data;
    
    if (version >= 11) {
        float full_black_time;
        float fade_in_time;
    }
    
    if (version >= 12) RefractData backdrop_flyer_refract_data;
    if (version >= 13) s32 backdrop_rows;
    if (version >= 14) RefractData backdrop_tile_refract_data;
    if (version >= 15) List<MapThing> preplaced_backdrop_flyers;
    
    if (version >= 16) {
        BloomSettings background_bloom;
        BloomSettings terrain_bloom;
    }
    
    if (version >= 17) float backdrop_flyer_parallax;
    if (version >= 18) StringLEB128 tile_assemble_sound;
    
    if (version >= 19) {
        StringLEB128 terrain_type;
        type::RGBA8 unexplored_color;
    }
    
    if (version >= 20) List<MapThingGroup> map_thing_groups;
    if (version >= 21) float brightness;
    if (version >= 22) bool start_falling;
    if (version >= 23) UnexploredData unexplored_data;
    if (version >= 24) Range<float> tile_phasein_time;
    if (version >= 25) TerrainLightData terrain_light_data;
    if (version >= 26) bool keep_weapons;
    if (version >= 27) bool can_plant_seeds;
    if (version >= 28) StringLEB128 title_id;
    if (version >= 29) bool no_weapons;
    if (version >= 30) float parallax;
    if (version >= 31) float backdrop_saturation;
    if (version >= 32) CamData cam_data;
};

MapData map @ 0x00;