#pragma description Dig Or Die Save File
#pragma endian little
#pragma magic [ 1F 09 53 41 56 45 20 46 49 4C 45 ] @ 0x00
#pragma author ddmitv

// === Pattern for ImHex Editor ===
//
// This Dig or Die save file pattern is reverse engineered from the game's C# disassembly of save's load and write functionality.
// More specifically from methods:
// - SDataSave.Save
// - SDataSave.LoadData
//
// Dig or Die Steam page: https://store.steampowered.com/app/315460/Dig_or_Die
//
// This pattern supports both compressed and decompressed save files.
// If the file is compressed, open the "Decompressed Save" section in the Pattern Data to view decompressed save file,
// or alternatively open the virtual file that contains decompressed data (again, in the Pattern Data view).
//
// By default, World Data cells pattern is disabled.
// You can enable it (show_world_data_pattern) via the Settings tab of the Pattern Editor view (WARNING: It will take ~10 seconds to load pattern data and ImHex could freeze).
// If the save file uses non-ordinary world dimensions (not 1024x1024), set world_width and world_height
// `in` variables via Settings tab of the Pattern Editor view.
//
// This pattern also supports game versions down to build 481 and includes some corruption checking functionality.
//
// General information about this binary format:
// The file is split into 8 sections: Header, Params Data, Items Data, Players, Environments, World Data, Units Data, Vars Data.
// Each section has its own magic string at the end of the section (and also every save file starts with the magic string).
// Uses C# BinaryFormatter to serialize "CParams" and "GVars" classes.
// The original save files are compressed using the LZF compression algorithm (see CLZF2 class).
//
// Original LZF algorithm: liblzf (by Marc Alexander Lehmann):
// - http://software.schmorp.de/pkg/liblzf.html (use Wayback Machine to see since it may be unavailable)
// liblzf Github mirror:
// - https://github.com/nemequ/liblzf
// Possible C# implementation used in game:
// - https://github.com/Chaser324/LZF/blob/master/CLZF2.cs (although some parts of code are different)

import type.magic;
import std.core;

#ifdef __IMHEX__
    import hex.core;
    import hex.provider;
    import hex.dec;
#endif

bool show_world_data_pattern in = false;
s32 world_width in = 1024;
s32 world_height in = 1024;

// ImHex-Patterns test file settings (for unit testing)
#ifdef __PL_UNIT_TESTS__
    show_world_data_pattern = true;
    world_width = 64;
    world_height = 64;
#endif

// Reverse engineered from DigOrDie!DllGetSaveOffset@0x1470 function from helper library DigOrDie.dll,
// provided in C# via SWorldDll.GetSaveOffset
// Likely used as an anti-tamper measure (didn't work)
fn get_save_offset(u32 x) {
    u32 hash = x * 0x9e3779b1U;
    hash = ((hash >> 15) ^ hash) * 0x85ebca77U;
    hash = ((hash >> 13) ^ hash) * 0xc2b2ae3dU;
    hash = (hash >> 16) ^ hash;
    return s32((u64(hash) * 10U) / 0xffffffffU);
};

fn total_save_offset(u32 x) {
    u32 offset = 0;
    for (u32 i = 0, i < x, i += 1) {
        offset += get_save_offset(i);
    }
    return offset;
};

fn lookup_code_name(s16 id) {
    std::assert(id >= 1, std::format("Invalid item id: {}", id));
    std::assert(id < data.save.items_data.count, std::format("Item id out of range: {} (max id: {})", id, data.save.items_data.count - 1));
    // id - 1 for accounting for the 0th `null` item
    return data.save.items_data.code_names[id - 1];
};

// Layout of serialized 7-bit encoded int via System.IO.BinaryWriter.Write7BitEncodedInt
struct EncodedInt7Bit {
    u8 chunks[while($ == addressof(this) || $[$-1] & 0x80 != 0)];

    std::assert(sizeof(chunks) <= 5, "Too many bytes in what should have been a 7 bit encoded Int32");
} [[format("format_EncodedInt7Bit"), transform("transform_EncodedInt7Bit"), format_write("format_write_EncodedInt7Bit"), sealed]];

// see System.IO.BinaryReader.Read7BitEncodedInt
fn transform_EncodedInt7Bit(ref auto x) {
    u32 res = x.chunks[0] & 0x7F;
    for (u8 i = 1, i < 5 && x.chunks[i-1] & 0x80 != 0, i += 1) {
        res |= u32(x.chunks[i] & 0x7F) << (7 * i);
    }
    return res;
};
fn format_EncodedInt7Bit(ref auto x) { return u32(x); };

// see System.IO.BinaryWriter.Write7BitEncodedInt
fn format_write_EncodedInt7Bit(ref str s) {
    auto value = std::string::parse_int(s, 10);
    u8 bytes[5];
    for (u8 i = 0, value != 0, i += 1) {
        u8 chunk = u8(value & 127);
        value = (value >> 7) & 0x1FFFFFF;
        if (value != 0) {
            chunk |= 0x80;
        }
        bytes[i] = chunk;
    }
    return bytes;
};

// Layout of C# System.String serialized via System.IO.BinaryWriter
struct String {
    EncodedInt7Bit length [[comment("C# strings length is encoded with 7-bit signed integer")]];
    std::assert(length >= 0, "Invalid string (length < 0)");
    
    char data[length];
} [[format("format_string"), transform("transform_string")]];
fn format_string(ref auto value) {
    return std::format("\"{}\"", value.data);
};
fn transform_string(ref auto value) {
    return value.data;  
};

struct MagicString<auto Expected> {
    String string;
    
    std::assert(string == Expected, std::format(
        "Invalid magic value! Expected \"{}\", got \"{}\" at position 0x{:X}", type::escape_bytes(Expected), type::escape_bytes(string), $ - std::string::length(Expected))
    );
} [[sealed, format("format_magic_sized_string")]];

fn format_magic_sized_string(ref auto magic) {
    return std::format("\"{}\"", type::escape_bytes(magic.string));
};

struct Color24 {
    u8 r;
    u8 g;
    u8 b;
} [[format("format_Color24")]];
fn format_Color24(ref auto value) {
    return std::format("rgb({}, {}, {})", value.r, value.g, value.b);
};

struct Vector2 {
    float x;
    float y;
} [[format("format_vector2")]];
fn format_vector2(ref auto x) { return std::format("({:.3f}, {:.3f})", x.x, x.y); };

struct int2 {
    s32 x;
    s32 y;
} [[format("format_int2")]];
fn format_int2(ref int2 x) { return std::format("({}, {})", x.x, x.y); };

fn format_item_id(auto id) {
    if (id == 0) {
        return "[empty]";
    } else {
        return std::format("{} ({})", lookup_code_name(id), id);
    }
};

// System.Runtime.Serialization.Formatters.Binary.BinaryElement
enum NrbfElement : u8 {
    Header                  = 0x00, // SerializationHeaderRecord
    RefTypeObject           = 0x01, // ClassWithMembersAndTypes
    UntypedRuntimeObject    = 0x02, // ClassWithMembers
    UntypedExternalObject   = 0x03, // SystemClassWithMembers
    RuntimeObject           = 0x04, // ClassWithId
    ExternalObject          = 0x05, // SystemClassWithMembersAndTypes
    String                  = 0x06, // BinaryObjectString
    GenericArray            = 0x07, // ClassWithMembersAndTypes (array variant)
    BoxedPrimitiveTypeValue = 0x08, // BinaryArray (primitive boxed types)
    ObjectReference         = 0x09, // MemberReference
    NullValue               = 0x0A, // NULL record
    End                     = 0x0B, // MessageEnd
    Assembly                = 0x0C, // Assembly
    ArrayFiller8b           = 0x0D, // BinaryArray (8-bit filler)
    ArrayFiller32b          = 0x0E, // BinaryArray (32-bit filler)
    ArrayOfPrimitiveType    = 0x0F, // BinaryArray (primitive types)
    ArrayOfObject           = 0x10, // BinaryArray (object references)
    ArrayOfString           = 0x11, // BinaryArray (strings)
    Method                  = 0x12, // MethodCall / MethodReturn wrapper
    _Unknown4               = 0x13, // Reserved/unused in public specs
    _Unknown5               = 0x14, // Reserved/unused in public specs
    MethodCall              = 0x15, // MethodCall record
    MethodResponse          = 0x16  // MethodReturn record
};

// Layout of C# System.String serialized via BinaryFormatter (NRBF)
struct NrbfString {
    NrbfElement object_type [[hidden]];
    std::assert(object_type == NrbfElement::String, "Invalid BinaryFormatter object type for System.String");
    s32 object_id [[hidden]];
    std::assert(object_id > 0, "Invalid BinaryFormatter object id");
    String value [[inline]];
} [[format("format_NrbfString")]];
fn format_NrbfString(ref auto string) {
    return std::format("\"{}\"", string.value);
};

// see System.Runtime.Serialization.Formatters.Binary.ObjectWriter.WriteStringArray
// note: only works if there are no null gaps in array
struct ListOfStrings {
    s32 length; // list length
    std::assert(length >= 0, "Invalid List<string> length (length < 0)");
    padding[4];
    
    NrbfElement object_type [[hidden]];
    std::assert(object_type == NrbfElement::ArrayOfString, "Invalid NRBF object type for System.String[]");
    
    s32 object_id [[hidden]];
    
    s32 capacity; // array length
    std::assert(capacity >= length, "List<string> capacity is less than length");
    NrbfString strings[length];
    
    // skip null filler (see System.Runtime.Serialization.Formatters.Binary.ObjectWriter.WriteNullFiller)
    match (capacity - length) {
        (0): padding[0];
        (1): padding[1]; // BinaryElement.NullValue
        (2 ... 255): padding[2]; // BinaryElement.ArrayFiller8b + 1-byte count
        (_): padding[5]; // BinaryElement.ArrayFiller32b + 4-byte count
    }
} [[format("format_ListOfStrings")]];
fn format_ListOfStrings(ref auto list) {
    return list.length == 0 ? "[ empty ]" : std::format("[ ... ] (length: {})", list.length);
};

struct SaveDataHeader {
    float version;
    
    s32 build;
    std::assert_warn(build >= 481, std::format("build '{}' is not compatible with the game version", build));
    save_build = build; // set global for save file backward compatibility
    
    String game_name [[comment("Name of the mode/custom world the save file was created in")]];
    MagicString<"Header">;
};

// The game uses its own format for storing class field data, built on top of BinaryFormatter (NRBF)
// It is used to not store field's default values (compared against a default object, and if different the field data is stored)
// Before each field's data, its name is written as a string (MemberInfo.Name), and then its data serialized with BinaryFormatter
struct ParamsField {
    String fieldName [[hidden]];
    
    // 0 length denotes an end of list of fields
    if (fieldName.length == 0) {
        break;
    }
    // Hardcoded padding values represent C# BinaryFormatter (NRBF) metadata overhead
    // The padding contains (usually) constant bytes that never change and don't carry actual save data,
    // they are needed for BinaryFormatter to correctly deserialize them later
    match (fieldName) {
        ("m_difficulty"): { padding[49]; s32 m_difficulty; }
        ("m_startCheated"): { padding[51]; bool m_startCheated; }
        ("m_eventsActive"): { padding[51]; bool m_eventsActive; }
        ("m_spawnPos"): { padding[64]; int2 m_spawnPos; }
        ("m_shipPos"): { padding[64]; int2 m_shipPos; }
        ("m_gridSize"): { padding[64]; int2 m_gridSize; }
        ("m_seed"): { padding[49]; s32 m_seed; }
        ("m_gameName"): { padding[17]; NrbfString m_gameName; }
        ("m_visibility"): { padding[49]; s32 m_visibility; }
        ("m_passwordMD5"): { padding[17]; NrbfString m_passwordMD5; }
        ("m_hostId"): { padding[50]; u64 m_hostId; }
        ("m_hostName"): { padding[17]; NrbfString m_hostName; }
        ("m_gameOverIfAllDead"): { padding[51]; bool m_gameOverIfAllDead; }
        ("m_nbPlayersMax"): { padding[49]; s32 m_nbPlayersMax; }
        ("m_clientGetHostItems"): { padding[51]; bool m_clientGetHostItems; }
        ("m_banGiveLootToHost"): { padding[51]; bool m_banGiveLootToHost; }
        ("m_devMode"): { padding[51]; bool m_devMode; }
        ("m_checkMinerals"): { padding[51]; bool m_checkMinerals; }
        ("m_dynamicSpawn"): { padding[51]; bool m_dynamicSpawn; }
        ("m_cloudCycleDistance"): { padding[50]; float m_cloudCycleDistance; }
        ("m_cloudCycleDuration"): { padding[50]; float m_cloudCycleDuration; }
        ("m_cloudRadius"): { padding[50]; float m_cloudRadius; }
        ("m_rainQuantity"): { padding[50]; float m_rainQuantity; }
        ("m_generationOreDiv"): { padding[50]; float m_generationOreDiv; }
        ("m_weightMult"): { padding[50]; float m_weightMult; }
        ("m_dropChanceMult"): { padding[50]; float m_dropChanceMult; }
        ("m_lavaPressureBottomCycle"): { padding[50]; float m_lavaPressureBottomCycle; }
        ("m_lavaPressureTopCycle"): { padding[50]; float m_lavaPressureTopCycle; }
        ("m_eruptionDurationTotal"): { padding[50]; float m_eruptionDurationTotal; }
        ("m_eruptionDurationAcc"): { padding[50]; float m_eruptionDurationAcc; }
        ("m_eruptionDurationUp"): { padding[50]; float m_eruptionDurationUp; }
        ("m_eruptionPressure"): { padding[50]; float m_eruptionPressure; }
        ("m_eruptionCheckMinY"): { padding[50]; float m_eruptionCheckMinY; }
        ("m_dayDurationTotal"): { padding[50]; float m_dayDurationTotal; }
        ("m_nightDuration"): { padding[50]; float m_nightDuration; }
        ("m_gravityPlayers"): { padding[50]; float m_gravityPlayers; }
        ("m_eventsDelayMin"): { padding[50]; float m_eventsDelayMin; }
        ("m_eventsDelayMax"): { padding[50]; float m_eventsDelayMax; }
        ("m_rocketPreparationDuration"): { padding[49]; s32 m_rocketPreparationDuration; }
        ("m_speedSimu"): { padding[50]; float m_speedSimu; }
        ("m_speedSimuWorld"): { padding[50]; float m_speedSimuWorld; }
        ("m_speedSimuWorldLocked"): { padding[51]; bool m_speedSimuWorldLocked; }
        ("m_rainY"): { padding[49]; s32 m_rainY; }
        ("m_fastEvaporationYMax"): { padding[49]; s32 m_fastEvaporationYMax; }
        ("m_sunLightYMin"): { padding[49]; s32 m_sunLightYMin; }
        ("m_sunLightYMax"): { padding[49]; s32 m_sunLightYMax; }
        ("m_respawnDelay"): { padding[49]; s32 m_respawnDelay; }
        ("m_dropAtDeathPercent_Peaceful"): { padding[50]; float m_dropAtDeathPercent_Peaceful; }
        ("m_dropAtDeathPercent_Easy"): { padding[50]; float m_dropAtDeathPercent_Easy; }
        ("m_dropAtDeathPercent_Normal"): { padding[50]; float m_dropAtDeathPercent_Normal; }
        ("m_dropAtDeathPercent_Hard"): { padding[50]; float m_dropAtDeathPercent_Hard; }
        ("m_dropAtDeathPercent_Brutal"): { padding[50]; float m_dropAtDeathPercent_Brutal; }
        ("m_dropAtDeathMax"): { padding[49]; s32 m_dropAtDeathMax; }
        ("m_monstersDayNb"): { padding[49]; s32 m_monstersDayNb; }
        ("m_monstersDayNbAddPerPlayer"): { padding[49]; s32 m_monstersDayNbAddPerPlayer; }
        ("m_bossRespawnDelay"): { padding[50]; float m_bossRespawnDelay; }
        ("m_monstersNightSpawnRateMult"): { padding[50]; float m_monstersNightSpawnRateMult; }
        ("m_monstersNightSpawnRateAddPerPlayer"): { padding[50]; float m_monstersNightSpawnRateAddPerPlayer; }
        ("m_monstersHpMult"): { padding[50]; float m_monstersHpMult; }
        ("m_monstersHpAddPerPlayer"): { padding[50]; float m_monstersHpAddPerPlayer; }
        ("m_monstersDamagesMult"): { padding[50]; float m_monstersDamagesMult; }
        ("m_monstersDamagesAddPerPlayer"): { padding[50]; float m_monstersDamagesAddPerPlayer; }
        ("m_mod"): { padding[17]; NrbfString m_mod [[comment("Inherited from CDesc")]]; }
        ("m_id"): { padding[17]; NrbfString m_id [[comment("Inherited from CDesc")]]; }
        ("m_idNum"): { padding[49]; s32 m_idNum [[comment("Inherited from CDesc")]]; }
        (_): {
            std::error(std::format("Unknown CParams field: \"{}\"", fieldName));
        }
    }
    
    // see System.Runtime.Serialization.Formatters.Binary.ObjectWriter.WriteSerializationEnd
    NrbfElement object_type [[hidden]];
    std::assert(object_type == NrbfElement::End, "BinaryFormatter (NRBF) serialized data must end with 0x0B byte");
} [[inline]];

struct GameParamsData {
    ParamsField fields[while(true)] [[inline]];

    MagicString<"Game Params Data">;
};

struct Pickup {
    s16 id;
    std::assert(id >= 0, "Invalid pickup id (id < 0)");
    
    Vector2 position;
    float creation_time;
} [[format("format_pickup")]];
fn format_pickup(ref auto pickup) {
    return std::format("{} ({})", lookup_code_name(pickup.id), pickup.id);
};

struct ItemsData {
    s32 count [[comment("Number of all items in the game. Note that this also includes 0th 'null' item")]];
    std::assert(count >= 1, "Invalid code names count (size < 1)");
    String code_names[count - 1] [[single_color]];
    
    s32 pickups_actives_count;
    std::assert(pickups_actives_count >= 0, "Invalid pickups actives count (size < 0)");
    Pickup pickups[pickups_actives_count] [[single_color]];
    MagicString<"Items Data">;
};

struct Item {
    u16 id;
    s32 amount;
} [[format("format_item"), static]];
fn format_item(ref auto value) { return std::format("{} ({}) x{}", lookup_code_name(value.id), value.id, value.amount); };

struct BarItem {
    u16 id [[comment("`0` for empty bar item slot")]];
} [[format("format_bar_item"), static]];
fn format_bar_item(ref auto x) { return format_item_id(x.id); };

struct PlayerInventory {
    s32 items_count;
    std::assert(items_count >= 0, "Invalid items count in player's inventory (size < 0)");
    Item items[items_count];
    
    s32 bar_items_count;
    std::assert_warn(bar_items_count == 20, std::format("Bar items count should equal to 20 (instead of {})", bar_items_count));
    std::assert(bar_items_count >= 0, "Invalid bar items count in player's inventory (size < 0)");
    BarItem bar_items[bar_items_count];
    
    u16 item_selected_id [[format("format_item_id"), comment("`0` for empty selected item slot")]];
};

struct ItemVarDico {
    String name;
    float value;
} [[format("format_item_var_dico")]];
fn format_item_var_dico(ref auto x) { return std::format("{} = {}", x.name, x.value); };

struct ItemVar {
    bool exists;
    if (exists) {
        float time_last_use [[comment("`float.MinValue` for unused item")]];
        float time_activation [[comment("`float.MinValue` for unused item")]];
        s32 dictionary_size;
        std::assert(dictionary_size >= 0, "Invalid item var dictionary size (size < 0)");
        ItemVarDico dictionary[dictionary_size];
    }
} [[format("format_item_var")]];
fn format_item_var(ref auto x) {
    if (!x.exists) { return "-"; }
    return format_item_id(std::core::array_index());
};

struct PlayerSkin {
    bool is_female;
    float color;
    s32 hair_style;
    Color24 color_hair [[single_color]];
    Color24 color_eyes [[single_color]];
} [[static]];

struct Player {
    u64 steam_id;
    String name;
    Vector2 position;
    u16 unit_player_id;
    if (save_build >= 495) {
        PlayerSkin skin;
    }
    PlayerInventory inventory;
    s32 item_vars_count;
    std::assert(item_vars_count >= 0, "Invalid item vars count (size < 0)");
    ItemVar item_vars[item_vars_count];
} [[format("format_player")]];
fn format_player(ref auto x) { return std::format("{} ({})", x.name, x.steam_id); };

struct PlayersData {
    s32 players_count;
    std::assert(players_count >= 0, "Invalid players count (size < 0)");
    Player players[players_count];
    MagicString<"Players">;
};

struct EnvironmentsData {
    s32 last_events_count;
    std::assert(last_events_count >= 0, "Invalid last events count (size < 0)");
    String last_events[last_events_count];
    MagicString<"Environments">;
};

bitfield CellFlags {
    bool CustomData0      : 1; // Bit 0 (0x00000001)
    bool CustomData1      : 1; // Bit 1 (0x00000002)
    bool CustomData2      : 1; // Bit 2 (0x00000004)
    bool UNUSED0          : 1; // Bit 3 (gap)
    bool IsXReversed      : 1; // Bit 4 (0x00000010)
    bool IsBurning        : 1; // Bit 5 (0x00000020)
    bool IsMapped         : 1; // Bit 6 (0x00000040)
    bool UNUSED1          : 1; // Bit 7 (gap)
    bool BackWall_0       : 1; // Bit 8 (0x00000100)
    bool BgSurface_0      : 1; // Bit 9 (0x00000200)
    bool BgSurface_1      : 1; // Bit 10 (0x00000400)
    bool BgSurface_2      : 1; // Bit 11 (0x00000800)
    bool WaterFall        : 1; // Bit 12 (0x00001000)
    bool StreamLFast      : 1; // Bit 13 (0x00002000)
    bool StreamRFast      : 1; // Bit 14 (0x00004000)
    bool IsLava           : 1; // Bit 15 (0x00008000)
    bool HasWireRight     : 1; // Bit 16 (0x00010000)
    bool HasWireTop       : 1; // Bit 17 (0x00020000)
    bool ElectricAlgoState: 1; // Bit 18 (0x00040000)
    bool IsPowered        : 1; // Bit 19 (0x00080000)
    bool UNUSED2          : 1; // Bit 20 (gap)
    bool UNUSED3          : 1; // Bit 21 (gap)
    bool UNUSED4          : 1; // Bit 22 (gap)
    bool UNUSED5          : 1; // Bit 23 (gap)
    bool UNUSED6          : 1; // Bit 24 (gap)
    bool UNUSED7          : 1; // Bit 25 (gap)
    bool UNUSED8          : 1; // Bit 26 (gap)
    bool UNUSED9          : 1; // Bit 27 (gap)
    bool UNUSED10         : 1; // Bit 28 (gap)
    bool UNUSED11         : 1; // Bit 29 (gap)
    bool UNUSED12         : 1; // Bit 30 (gap)
    bool UNUSED13         : 1; // Bit 31 (gap)
};
std::assert(sizeof(CellFlags) == sizeof(u32), "");

// see CCell.Save and CCell.Load
struct Cell {
    // fields m_temp, m_elecCons and m_elecProd are not stored inside save file
    CellFlags flags;
    u16 content_id;
    u16 content_hp;
    float water [[comment("Note that this also includes lava")]];
    s16 force_x;
    s16 force_y;
    Color24 light;
    
    // std::assert_warn(content_id < data.items_data.count, "Invalid content id");
    // std::assert(sizeof(Cell) == 19, "");
} [[static]];

// cannot use [[static]] since padding is changes dynamically
struct CellsColumn {
    padding[get_save_offset(std::core::array_index())];
    Cell row[world_height] [[inline]];
};

struct WorldData {
    // Since the game purely relies on save's Mode / Custom world information to determine world cell grid dimensions
    // that we cannot access or reliably get, we need to get world width and height from user,
    // defaulting to 1024x1024 (since it's the standard world size that all vanilla modes have)
    std::assert(world_width >= 0, "Invalid world width");
    std::assert(world_height >= 0, "Invalid world height");
    
    // Opt-in to enable parsing cell grid (since it's quite laggy for ImHex to process)
    if (show_world_data_pattern) {
        CellsColumn columns[world_width];
    } else {
        u8 @ $ [[name("Note: set show_world_data_pattern `in` var to true to view cell grid")]];
        padding[total_save_offset(world_width) + sizeof(Cell) * world_width * world_height];
    }
    MagicString<"World Data">;
};

fn is_monster_id(str id) {
    return id != "player" && id != "playerLocal" && id != "defense" && id != "drone" && id != "droneCombat" && id != "droneWar";
};
struct Unit {
    String code_name;
    Vector2 position;
    u16 id;
    float hp;
    float air;
    std::assert_warn(air >= 0.F && air <= 1.F, std::format("Unit ID {} has impossible air state: {} (air < 0 or air > 1)", id, air));
     
    bool is_monster = is_monster_id(code_name) [[export, comment("Only works on non-modded monsters")]];
    if (is_monster) {
        bool is_night_spawn;
        if (save_build >= 626) {
            u16 target_id [[comment("`0xFFFF` for no target")]];
        }
        if (save_build >= 830) {
            bool is_creative_spawn;
        }
    }
} [[single_color, format("format_unit")]];
fn format_unit(ref auto unit) { return std::format("{} ({})", unit.code_name, unit.id); };

struct SpecieKilled {
    String code_name;
    s32 amount;
    float last_kill_time;  
} [[single_color, format("format_specie_killed")]];
fn format_specie_killed(ref auto value) { return std::format("{} x{}", value.code_name, value.amount); };

struct UnitsData {
    s32 units_count;
    std::assert(units_count >= 0, "Invalid units count (size < 0)");
    Unit units[units_count];
    s32 species_killed_count;
    std::assert(species_killed_count >= 0, "Invalid species killed count (size < 0)");
    SpecieKilled species_killed[species_killed_count];
    
    MagicString<"Units Data">;
};

enum RocketStep : s32 {
    _Inactive = 0x00,
    Count0_50 = 0x01,
    Count50_Wait = 0x02,
    Count50to100 = 0x03,
    Liftoff = 0x04,
};

// see ParamsField for more info
struct VarsField {
    String fieldName [[hidden]];
    
    // 0 length denotes an end of list of fields
    if (fieldName.length == 0) {
        break;
    }
    // see ParamsField for explanation
    match (fieldName) {
        ("m_lastSaveDate"): { padding[17]; NrbfString m_lastSaveDate; }
        ("m_simuTimeD"): { padding[50]; double m_simuTimeD; }
        ("m_worldTimeD"): { padding[50]; double m_worldTimeD; }
        ("m_clock"): { padding[50]; float m_clock; }
        ("m_cloudPosRatio"): { padding[50]; float m_cloudPosRatio; }
        ("m_droneTargetId"): { padding[50]; u16 m_droneTargetId; }
        ("m_achievementsLocked"): { padding[51]; bool m_achievementsLocked; }
        ("m_eventIdNum"): { padding[49]; s32 m_eventIdNum; }
        ("m_eventStartTime"): { padding[50]; float m_eventStartTime; }
        ("m_lavaCycleSkipped"): { padding[51]; bool m_lavaCycleSkipped; }
        ("m_bossAreas"): { padding[17]; NrbfString m_bossAreas; }
        ("m_monsterT2AlreadyHit"): { padding[51]; bool m_monsterT2AlreadyHit; }
        ("m_eruptionTime"): { padding[50]; float m_eruptionTime; }
        ("m_eruptionStartPressure"): { padding[50]; float m_eruptionStartPressure; }
        ("m_brokenHeart"): { padding[51]; bool m_brokenHeart; }
        ("m_heartPos"): { padding[64]; int2 m_heartPos; }
        ("m_cinematicIntroTime"): { padding[50]; float m_cinematicIntroTime; }
        ("m_cinematicRocketPos"): { padding[75]; Vector2 m_cinematicRocketPos; }
        ("m_cinematicRocketStep"): { padding[78]; RocketStep m_cinematicRocketStep; }
        ("m_cinematicRocketStepStartTime"): { padding[50]; float m_cinematicRocketStepStartTime; }
        ("m_postGame"): { padding[51]; bool m_postGame; }
        ("m_autoBuilderLastTimeFound"): { padding[50]; float m_autoBuilderLastTimeFound; }
        ("m_achievNoElectricity"): { padding[51]; bool m_achievNoElectricity; }
        ("m_achievNoShoot"): { padding[51]; bool m_achievNoShoot; }
        ("m_achievNoCraft"): { padding[51]; bool m_achievNoCraft; }
        ("m_achievNoMK2"): { padding[51]; bool m_achievNoMK2; }
        ("m_achievWentToSea"): { padding[51]; bool m_achievWentToSea; }
        ("m_achievEarlyDive"): { padding[51]; bool m_achievEarlyDive; }
        ("m_aiSentencesTold"): { padding[186]; ListOfStrings m_aiSentencesTold; }
        ("m_autoBuilderLevelBuilt"): { padding[49]; s32 m_autoBuilderLevelBuilt; }
        ("m_autoBuilderLevelUsed"): { padding[49]; s32 m_autoBuilderLevelUsed; }
        ("m_nbNightsSurvived"): { padding[49]; s32 m_nbNightsSurvived; }
        ("m_bossKilled_Madcrab"): { padding[51]; bool m_bossKilled_Madcrab; }
        ("m_bossKilled_FireflyQueen"): { padding[51]; bool m_bossKilled_FireflyQueen; }
        ("m_bossKilled_DwellerLord"): { padding[51]; bool m_bossKilled_DwellerLord; }
        ("m_bossKilled_Balrog"): { padding[51]; bool m_bossKilled_Balrog; }
        ("m_droneLastTimeEnters"): { padding[50]; float m_droneLastTimeEnters; }
        ("m_droneLastTimeDontEnter"): { padding[50]; float m_droneLastTimeDontEnter; }
        ("m_droneComboNb"): { padding[49]; s32 m_droneComboNb; }
        (_): {
            std::error(std::format("Unknown GVars field: \"{}\"", fieldName));
        }
    }
    NrbfElement object_type [[hidden]];
    std::assert(object_type == NrbfElement::End, "BinaryFormatter (NRBF) serialized data must end with 0x0B byte");
} [[inline]];

struct VarsData {
    VarsField fields[while(true)] [[inline]];

    MagicString<"Vars Data">;
};

struct SaveData {
    MagicString<"SAVE FILE">;
    SaveDataHeader header [[name("Header")]];
    GameParamsData game_params_data [[name("Game Params Data"), comment("Contains C# BinaryFormatter-serialized data")]];
    ItemsData items_data [[name("Items Data")]];
    PlayersData players_data [[name("Players")]];
    if (save_build >= 815) {
        EnvironmentsData environments_data [[name("Environments")]];
    }
    WorldData world_data [[name("World Data")]];
    UnitsData units_data [[name("Units Data")]];
    VarsData vars_data [[name("Vars Data"), comment("Contains C# BinaryFormatter-serialized data")]];
};

struct MaybeCompressedSaveData {
    String magic_test @ 0x00 [[hidden]];
    if (magic_test == "SAVE FILE") {
        SaveData save @ 0x00 [[inline]];
    } else {
        #ifdef __IMHEX__
            u8 compressed_data[sizeof($)] [[hidden]];
            std::mem::Section decompressed_section = std::mem::create_section("Decompressed Save");
            hex::dec::lzf_decompress(compressed_data, decompressed_section);

            u8 raw_data[std::mem::get_section_size(decompressed_section)] @ 0x00 in decompressed_section [[hidden]];
            // do not pass `save` because it will output some weird bytes
            hex::core::add_virtual_file(std::format("{}-uncompressed", hex::prv::get_information("file_name")), raw_data);

            SaveData save @ 0x00 in decompressed_section [[inline]];

            std::warning("!! Dig or Die save content is compressed !!\n!! Open the \"Decompressed Save\" tab in Pattern Data view or from the Virtual Filesystem tab open the decompressed file and run this pattern on it !!");
        #endif
        #ifndef __IMHEX__
            std::error("Save file decompression is only supported in ImHex pattern language environment (requires plugin \"decompress\")");
        #endif
    }
};

s32 save_build = 0;

MaybeCompressedSaveData data @ 0x00 [[inline]];
