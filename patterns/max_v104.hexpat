#pragma description Mechanized Assault and Exploration v1.04 (strategy game) save file format

#include <std/sys.pat>
#include <std/mem.pat>

#pragma array_limit 12544
#pragma pattern_limit 2000000
#pragma eval_depth 32

enum FileType : u8
{
  Custom,
  Tutorial,
  Campaign,
  Hot_seat,
  Multiplayer,
  Demo,
  Debug,
  Text,
  Scenario,
  Multi_scenario
};

enum PlanetType : u8
{
  Snowcrab,
  Frigia,
  Ice_Berg,
  The_Cooler,
  Ultima_Thule,
  Long_Floes,
  Iron_Cross,
  Splatterscape,
  Peak_a_boo,
  Valentines_Planet,
  Three_Rings,
  Great_divide,
  New_Luzon,
  Middle_Sea,
  High_Impact,
  Sanctuary,
  Islandia,
  Hammerhead,
  Freckles,
  Sandspit,
  Great_Circle,
  Long_Passage,
  Flash_Point,
  Bottleneck
};

enum TeamType : u8
{
  None = 0,
  Human = 1,
  Computer = 2,
  Remote = 3,
  Eliminated = 4
};

enum TeamIndex : u8
{
  Red = 0,
  Green = 1,
  Blue = 2,
  Gray = 3
};

enum TeamIndex16 : u16
{
  Red = 0,
  Green = 1,
  Blue = 2,
  Gray = 3
};

enum PlayMode : u8
{
  Turn_Based = 0,
  Simultaneous_Moves = 1
};

enum TeamClan : u8
{
  None = 0,
  The_Chosen = 1,
  Crimson_Path = 2,
  Von_Griffin = 3,
  Ayers_Hand = 4,
  Musashi = 5,
  Sacred_Eights = 6,
  Seven_Knights = 7,
  Axis_Inc = 8
};

enum OpponentType : u8
{
  Clueless = 0,
  Apprentice = 1,
  Average = 2,
  Expert = 3,
  Master = 4,
  God = 5
};

enum VictoryType : u8
{
  Duration = 0,
  Score = 1
};

struct IniOptions
{
  s32 world;
  s32 turn_timer;
  s32 endturn;
  s32 start_gold;
  s32 play_mode;
  s32 victory_type;
  s32 victory_limit;
  s32 opponent;
  s32 raw_resource;
  s32 fuel_resource;
  s32 gold_resource;
  s32 alien_derelicts;
};

struct IniPreferences
{
  s32 effects;
  s32 click_scroll;
  s32 quick_scroll;
  s32 fast_movement;
  s32 follow_unit;
  s32 auto_select;
  s32 enemy_halt;
};

enum SurfaceType : u8
{
  Land = 1,
  Water = 2,
  Coast = 4,
  Air = 8
};

enum AiStrategy : u8
{
  Random,
  Defensive,
  Missiles,
  Air,
  Sea,
  Scout_horde,
  Tank_horde,
  Fast_attack,
  Combined_arms,
  Espionage
};

bitfield GridResourceMapEntry
{
  padding : 2;
  team_visibility_gray : 1;
  team_visibility_blue : 1;
  team_visibility_green : 1;
  team_visibility_red : 1;
  padding : 2;
  cargo_amount : 5;
  cargo_type_fuel : 1;
  cargo_type_gold : 1;
  cargo_type_material : 1;
};

bitfield UnitFlags
{
  // MSB
  requires_slab: 1;
  turret_sprite: 1;
  sentry_unit: 1;
  spinning_turret: 1;
  padding: 4;

  hovering: 1;
  has_firing_sprite: 1;
  fires_missiles: 1;
  constructor_unit: 1;
  padding: 1;
  electronic_unit: 1;
  selectable: 1;
  standalone: 1;

  mobile_land_unit: 1;
  stationary: 1;
  padding: 4;
  upgradeable: 1;
  padding: 1;

  // LSB
  ground_cover : 1;
  exploding: 1;
  animated: 1;
  connector_unit: 1;
  building: 1;
  missile_unit: 1;
  mobile_air_unit: 1;
  mobile_sea_unit: 1;
};

struct Point
{
  s16 x;
  s16 y;
};

struct ResearchTopicInfo
{
  u32 research_level;
  u32 turns_to_complete;
  s32 allocation;
};

struct ScreenLocation
{
  s8 x;
  s8 y;
};

struct TeamInfo
{
  Point markers[10];
  TeamType team_type;
  s8 field_41;
  TeamClan team_clan;
  ResearchTopicInfo research_topics[8];
  u32 victory_points;
  u16 next_unit_id;
  u8 unit_counters[93];
  ScreenLocation screen_location[6];
  u16 score_graph[50];
  u16 selected_unit;
  u16 zoom_level;
  Point screen_position;
  bool gui_button_state_range;
  bool gui_button_state_scan;
  bool gui_button_state_status;
  bool gui_button_state_colors;
  bool gui_button_state_hits;
  bool gui_button_state_ammo;
  bool gui_button_state_names;
  bool gui_button_state_minimap_2x;
  bool gui_button_state_minimap_tnt;
  bool gui_button_state_grid;
  bool gui_button_state_survey;
  u16 stats_factories_built;
  u16 stats_mines_built;
  u16 stats_buildings_built;
  u16 stats_units_built;
  u16 casualties[93];
  u16 stats_gold_spent_on_upgrades;
};

struct UnitValues
{
  u16 object_index;

  if(CheckObjectId(object_index, true) == true)
  {
    u16 class_type;
    u16 turns;
    u16 hits;
    u16 armor;
    u16 attack;
    u16 speed;
    u16 range;
    u16 rounds;
    bool move_and_fire;
    u16 scan;
    u16 storage;
    u16 ammo;
    u16 attack_radius;
    u16 agent_adjust;
    u16 version;
    u8 units_built;
  }
};

struct Complex
{
  u16 object_index;
  
  if(CheckObjectId(object_index, true) == true)
  {
    u16 class_type;
    s16 material;
    s16 fuel;
    s16 gold;
    s16 power;
    s16 workers;
    s16 buildings;
    s16 id;
  }
};

struct TeamUnits
{
  s16 gold;
  UnitValues base_unit_values[93];
  UnitValues current_unit_values[93];
  u16 complex_count;
  Complex complexes[complex_count];
};

enum UnitType : u16
{
  UNIT_TYPE_GOLD_REFINERY = 0,
  UNIT_TYPE_POWER_STATION = 1,
  UNIT_TYPE_POWER_GENERATOR = 2,
  UNIT_TYPE_BARRACKS = 3,
  UNIT_TYPE_ALIEN_BUILDING_1 = 4,
  UNIT_TYPE_RADAR = 5,
  UNIT_TYPE_STORAGE_UNIT = 6,
  UNIT_TYPE_FUEL_TANK = 7,
  UNIT_TYPE_GOLD_VAULT = 8,
  UNIT_TYPE_DEPOT = 9,
  UNIT_TYPE_HANGAR = 10,
  UNIT_TYPE_DOCK = 11,
  UNIT_TYPE_CONNECTOR = 12,
  UNIT_TYPE_LARGE_RUBBLE_1 = 13,
  UNIT_TYPE_SMALL_RUBBLE_1 = 14,
  UNIT_TYPE_LARGE_TAPE = 15,
  UNIT_TYPE_SMALL_TAPE = 16,
  UNIT_TYPE_LARGE_SLAB = 17,
  UNIT_TYPE_SMALL_SLAB = 18,
  UNIT_TYPE_LARGE_CONES = 19,
  UNIT_TYPE_SMALL_CONES = 20,
  UNIT_TYPE_ROAD = 21,
  UNIT_TYPE_LANDING_PAD = 22,
  UNIT_TYPE_SHIPYARD = 23,
  UNIT_TYPE_LIGHT_VEHICLE_PLANT = 24,
  UNIT_TYPE_HEAVY_VEHICLE_PLANT = 25,
  UNIT_TYPE_ALIEN_BUILDING_2 = 26,
  UNIT_TYPE_AIR_UNITS_PLANT = 27,
  UNIT_TYPE_HABITAT = 28,
  UNIT_TYPE_RESEARCH_CENTER = 29,
  UNIT_TYPE_ECOSPHERE = 30,
  UNIT_TYPE_ALIEN_BUILDING_3 = 31,
  UNIT_TYPE_TRAINING_HALL = 32,
  UNIT_TYPE_WATER_PLATFORM = 33,
  UNIT_TYPE_GUN_TURRET = 34,
  UNIT_TYPE_ANTI_AIRCRAFT = 35,
  UNIT_TYPE_ARTILLERY = 36,
  UNIT_TYPE_MISSILE_LAUNCHER = 37,
  UNIT_TYPE_CONCRETE_BLOCK = 38,
  UNIT_TYPE_BRIDGE = 39,
  UNIT_TYPE_MINING_STATION = 40,
  UNIT_TYPE_LAND_MINE = 41,
  UNIT_TYPE_SEA_MINE = 42,
  UNIT_TYPE_LAND_EXPLOSION = 43,
  UNIT_TYPE_AIR_EXPLOSION = 44,
  UNIT_TYPE_SEA_EXPLOSION = 45,
  UNIT_TYPE_BUILDING_EXPLOSION = 46,
  UNIT_TYPE_HIT_EXPLOSION = 47,
  UNIT_TYPE_MASTER_BUILDER = 48,
  UNIT_TYPE_CONSTRUCTOR = 49,
  UNIT_TYPE_SCOUT = 50,
  UNIT_TYPE_TANK = 51,
  UNIT_TYPE_ASSAULT_GUN  = 52,
  UNIT_TYPE_ROCKET_LAUNCHER = 53,
  UNIT_TYPE_MISSILE_CRAWLER = 54,
  UNIT_TYPE_MOBILE_ANTI_AIRCRAFT = 55,
  UNIT_TYPE_MINE_LAYER = 56,
  UNIT_TYPE_SURVEYOR = 57,
  UNIT_TYPE_SCANNER = 58,
  UNIT_TYPE_SUPPLY_TRUCK = 59,
  UNIT_TYPE_GOLD_TRUCK = 60,
  UNIT_TYPE_ENGINEER = 61,
  UNIT_TYPE_BULLDOZER = 62,
  UNIT_TYPE_REPAIR_UNIT = 63,
  UNIT_TYPE_FUEL_TRUCK = 64,
  UNIT_TYPE_PERSONNEL_CARRIER = 65,
  UNIT_TYPE_INFILTRATOR = 66,
  UNIT_TYPE_INFANTRY = 67,
  UNIT_TYPE_ESCORT = 68,
  UNIT_TYPE_CORVETTE = 69,
  UNIT_TYPE_GUNBOAT = 70,
  UNIT_TYPE_SUBMARINE = 71,
  UNIT_TYPE_SEA_TRANSPORT = 72,
  UNIT_TYPE_MISSILE_CRUISER = 73,
  UNIT_TYPE_SEA_MINE_LAYER = 74,
  UNIT_TYPE_CARGO_SHIP = 75,
  UNIT_TYPE_FIGHTER = 76,
  UNIT_TYPE_GROUND_ATTACK_PLANE = 77,
  UNIT_TYPE_AIR_TRANSPORT = 78,
  UNIT_TYPE_AWAC = 79,
  UNIT_TYPE_ALIEN_GUNBOAT = 80,
  UNIT_TYPE_ALIEN_TANK = 81,
  UNIT_TYPE_ALIEN_ASSAULT_GUN = 82,
  UNIT_TYPE_ALIEN_ATTACK_PLANE = 83,
  UNIT_TYPE_MISSILE = 84,
  UNIT_TYPE_TORPEDO = 85,
  UNIT_TYPE_ALIEN_MISSILE = 86,
  UNIT_TYPE_TANK_PLASMA_BALL = 87,
  UNIT_TYPE_ARTILLERY_PLASMA_BALL = 88,
  UNIT_TYPE_SMOKE_TRAIL = 89,
  UNIT_TYPE_BUBBLE_TRAIL = 90,
  UNIT_TYPE_HARVESTER = 91,
  UNIT_TYPE_DEAD_WALDO = 92
};

enum OrderType : u8
{
  ORDER_TYPE_AWAITING = 0x0,
  ORDER_TYPE_TRANSFORMING = 0x1,
  ORDER_TYPE_MOVING = 0x2,
  ORDER_TYPE_FIRING = 0x3,
  ORDER_TYPE_ORDER_BUILDING = 0x4,
  ORDER_TYPE_ACTIVATE_ORDER = 0x5,
  ORDER_TYPE_NEW_ALLOCATE_ORDER = 0x6,
  ORDER_TYPE_POWER_ON = 0x7,
  ORDER_TYPE_POWER_OFF = 0x8,
  ORDER_TYPE_EXPLODING = 0x9,
  ORDER_TYPE_UNLOADING = 0xA,
  ORDER_TYPE_CLEARING = 0xB,
  ORDER_TYPE_SENTRY = 0xC,
  ORDER_TYPE_LANDING = 0xD,
  ORDER_TYPE_TAKING_OFF = 0xE,
  ORDER_TYPE_LOADING = 0xF,
  ORDER_TYPE_IDLE = 0x10,
  ORDER_TYPE_REPAIRING = 0x11,
  ORDER_TYPE_REFUELING = 0x12,
  ORDER_TYPE_RELOADING = 0x13,
  ORDER_TYPE_TRANSFERRING = 0x14,
  ORDER_TYPE_AWAITING_21 = 0x15,
  ORDER_TYPE_AWAITING_22 = 0x16,
  ORDER_TYPE_AWAITING_23 = 0x17,
  ORDER_TYPE_AWAITING_24 = 0x18,
  ORDER_TYPE_AWAITING_25 = 0x19,
  ORDER_TYPE_DISABLED = 0x1A,
  ORDER_TYPE_MOVING_27 = 0x1B,
  ORDER_TYPE_REPAIRING_28 = 0x1C,
  ORDER_TYPE_TRANSFERRING_29 = 0x1D,
  ORDER_TYPE_ATTACKING = 0x1E,
  ORDER_TYPE_BUILDING_HALTED = 0x1F
};

struct Rect
{
  s32 ulx;
  s32 uly;
  s32 lrx;
  s32 lry;
};

struct PathStep
{
  s8 x;
  s8 y;
};

struct Path
{
  u16 object_index;
  
  if(CheckObjectId(object_index, true) == true)
  {
    u16 class_type;
    
    // Air path
    if (class_type == 1)
    {
      s16 length;
      u8 angle;
      Point pixel_start;
      Point pixel_end;
      s32 x_step;
      s32 y_step;
      s32 delta_x;
      s32 delta_y;
    }
    // Ground path
    else if (class_type == 4)
    {
      Point pixel_end;
      s16 index;
      s16 steps_count;
      PathStep steps[steps_count];
    }
    // Builder path
    else if (class_type == 2)
    {
      Point coordinate;
    }
    else
    {
      std::assert(0, "Unknown path class");
    }
  }
};

struct UnitTypeArray
{
  u16 object_count;

  UnitType array[object_count];
};

struct UnitInfo
{
  u16 object_index;

  if(CheckObjectId(object_index, true) == true)
  {
    u16 class_type;
    UnitType unit_type;
    
    if (unit_type == UnitType::UNIT_TYPE_DEAD_WALDO)
    {
      std::print("Found Waldo!");
    }
    
    u16 hash_id;
    UnitFlags flags;
    Point pixel_position;
    Point grid_position;
    u16 name_length;
    s8 name[name_length];
    Point shadow_offset;
    TeamIndex team;
    u8 name_index;
    u8 brightness;
    u8 angle;
    u8 visible_to_team[5];
    u8 spotted_by_team[5];
    u8 max_velocity;
    u8 velocity;
    u8 sound;
    u8 scaler_adjust;
    Rect sprite_bounds;
    Rect shadow_bounds;
    u8 turret_angle;
    s8 turret_offset_x;
    s8 turret_offset_y;
    u16 total_images;
    u16 image_base;
    u16 turret_image_base;
    u16 firing_image_base;
    u16 connector_image_base;
    u16 image_index;
    u16 turret_image_index;
    u16 image_index_max;
    OrderType orders;
    u8 state;
    OrderType prior_orders;
    u8 prior_state;
    u8 laying_state;
    Point target_grid;
    u8 build_time;
    u8 total_mining;
    u8 raw_mining;
    u8 fuel_mining;
    u8 gold_mining;
    u8 raw_mining_max;
    u8 gold_mining_max;
    u8 fuel_mining_max;
    u8 hits;
    u8 speed;
    u8 shots;
    u8 move_and_fire;
    u16 storage;
    u8 ammo;
    u8 targeting_mode;
    u8 enter_mode;
    u8 cursor;
    u8 recoil_delay;
    u8 delayed_reaction;
    u8 damaged_this_turn;
    u8 research_topic;
    u8 moved;
    u8 bobbed;
    u8 shake_effect_state;
    u8 engine;
    u8 weapon;
    u8 comm;
    u8 fuel_distance;
    u8 move_fraction;
    u8 energized;
    u8 repeat_build;
    u16 build_rate;
    u8 disabled_reaction_fire;
    u8 auto_survey;
    u32 field_221;
    Path path;
    u16 connectors;
    UnitValues base_values;
    Complex complex;
    UnitInfo parent_unit;
    UnitInfo enemy_unit;
    UnitTypeArray build_list;
  }
};

struct UnitInfoList
{
  u16 unitinfo_count;
  UnitInfo units[unitinfo_count];
};

struct HashMapUnitInfo
{
  u16 hash_size;
  UnitInfoList map[hash_size];
};

struct MapHash
{
  Point coordinates;
  UnitInfoList units;
};

struct MapHashList
{
  u16 maphash_count;
  MapHash objects[maphash_count];
};

struct HashMapMapHash
{
  u16 hash_size;
  s16 x_shift;
  MapHashList map[hash_size];
};

struct TeamHeatMaps
{
  u8 heatmap_complete[12544];
  u8 heatmap_stealth_sea[12544];
  u8 heatmap_stealth_land[12544];
};

struct MessageLog
{
  s16 length;
  char text[length];
  UnitInfo unit;
  Point coordinates;
  bool is_alert_message;
  u16 resource_id;
};

struct MessageLogList
{
  u16 message_log_count;
  MessageLog entires[message_log_count];
};

struct AiMap
{
  UnitInfo unit;
  TeamIndex16 team;
  bool visible_to_team;
  Point point;
};

struct AiMapList
{
  u16 ai_map_count;
  AiMap objects[ai_map_count];
};

struct AiPlayer
{
  TeamIndex16 team;
  AiStrategy strategy;
  s16 field_3;
  s16 field_5;
  s16 field_7;
  TeamIndex16 target_team;
  AiMapList map_list;
  u16 has_info_map;
  
  if (has_info_map)
  {
  	u8 info_map[12544];
  }
  
  u16 has_mine_map;
  
  if (has_mine_map)
  {
    u8 mine_map[12544];
  }
  
  Point target_location;
};

u16 last_object_index;
bool context;

fn Init()
{
    context = false;
	last_object_index = 0;
};

fn CheckObjectId(u16 index, bool caller)
{
  bool result = false;

  // ImHex bug workaround
  if (context) { context = false; return result; }

  // null object?
  if (index == 0)
  {
    return false;
  }

  // already serialized object?
  if (last_object_index < index)
  {
  	last_object_index = index;
  	result = true;
  }
  
  return result;
};

struct SaveFile
{
  Init();

  s16 version;
  FileType save_file_type;
  char save_game_name[30];
  PlanetType planet;
  s16 mission_index;
  char team_name_red[30];
  char team_name_green[30];
  char team_name_blue[30];
  char team_name_gray[30];
  TeamType team_type_red;
  TeamType team_type_green;
  TeamType team_type_blue;
  TeamType team_type_gray;
  TeamType team_type_alien;
  TeamClan team_clan_red;
  TeamClan team_clan_green;
  TeamClan team_clan_blue;
  TeamClan team_clan_gray;
  TeamClan team_clan_alien;
  u32 rng_seed;
  OpponentType opponent;
  s16 turn_timer;
  s16 endturn;
  PlayMode play_mode;
  IniOptions options;
  SurfaceType surface_map[12544];
  GridResourceMapEntry GridResourceMap[12544];
  TeamInfo team_info_red;
  TeamInfo team_info_green;
  TeamInfo team_info_blue;
  TeamInfo team_info_gray;
  TeamIndex active_turn_team;
  TeamIndex player_team;
  s32 turn_counter;
  s16 game_state;
  u16 turn_timer_;
  IniPreferences preferences;
  TeamUnits team_units_red;
  TeamUnits team_units_green;
  TeamUnits team_units_blue;
  TeamUnits team_units_gray;
  UnitInfoList unit_info_list_ground_cover_units;
  UnitInfoList unit_info_list_mobile_land_sea_units;
  UnitInfoList unit_info_list_stationary_units;
  UnitInfoList unit_info_list_mobile_air_units;
  UnitInfoList unit_info_list_particles;
  HashMapUnitInfo hash_map_unit_info;
  HashMapMapHash hash_map_map_hash;

  if (team_type_red != TeamType::None)
  {
    TeamHeatMaps heat_maps_red;
  }

  if (team_type_green != TeamType::None)
  {
    TeamHeatMaps heat_maps_green;
  }

  if (team_type_blue != TeamType::None)
  {
    TeamHeatMaps heat_maps_blue;
  }

  if (team_type_gray != TeamType::None)
  {
    TeamHeatMaps heat_maps_gray;
  }

  MessageLogList message_log_red;
  MessageLogList message_log_green;
  MessageLogList message_log_blue;
  MessageLogList message_log_gray;
  
  if (team_type_red == TeamType::Computer)
  {
    AiPlayer ai_player_red;
  }

  if (team_type_green == TeamType::Computer)
  {
    AiPlayer ai_player_green;
  }

  if (team_type_blue == TeamType::Computer)
  {
    AiPlayer ai_player_blue;
  }

  if (team_type_gray == TeamType::Computer)
  {
    AiPlayer ai_player_gray;
  }

};

SaveFile save @ 0x0;

std::assert($ == std::mem::size(), "Extra data found after parsed data");


