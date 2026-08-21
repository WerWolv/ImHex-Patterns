#pragma little endian
#include <std/string.pat>

fn format_str(auto s) {
    return std::format("{}", s);
};

struct FormationData {
    u8 idx;
    u8 weight;
} [[format("format_formation_data")]];

fn format_formation_data(ref auto data) {
    return std::format("_{:0>2}x{}", data.idx, data.weight);
};

struct GroupData {
    u8 formation_count;
    u16 battlefield;
    u8 danger;
    u8 total_weight;
    FormationData formations[formation_count];
} [[format("format_group_data")]];

fn format_group_data(ref auto group_data) {
    return std::format("{} formations", group_data.formation_count);
};

struct EncounterData {
    u8 total_formation_count;
    u8 group_count;
    GroupData groups[group_count];
} [[format("format_encounter_data")]];


fn format_encounter_data(ref auto encounter_data) {
    return std::format("{} formations", encounter_data.total_formation_count);
};

struct Field {
    u16 id;
    u16 data_offset;
    u16 unk;
    char name[8] [[format("format_str")]];
    
    EncounterData data @ chunk_offsets[1] + data_offset;
} [[format("format_field")]];

fn format_field(ref auto field) {
    return std::format("[{:0>4X}] {}: {} in {}", field.data_offset, field.name, field.data.total_formation_count, field.data.group_count);
};

struct Data {
    Field fields[while($ < chunk_offsets[1])];
};

u32 chunk_count @ 0x0;
u32 chunk_offsets[chunk_count] @ 0x4;
u32 filesize @ 0xC;
Data data @ chunk_offsets[0];