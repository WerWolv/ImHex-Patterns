#include <type/leb128.pat>

struct header_item {
    u8 magic[8];
    u32 checksum;
    u8 signature[20];
    u32 file_size;
    u32 header_size;
    u32 endian_tag;
    u32 link_size;
    u32 link_off;
    u32 map_off;
    u32 string_ids_size;
    u32 string_ids_off;
    u32 type_ids_size;
    u32 type_ids_off;
    u32 proto_ids_size;
    u32 proto_ids_off;
    u32 file_ids_size;
    u32 file_ids_off;
    u32 method_ids_size;
    u32 method_ids_off;
    u32 class_defs_size;
    u32 class_defs_off;
    u32 data_size;
    u32 data_off;
};

struct string_id_item {
    u32 string_data_off;
};

struct string_data_item {
    type::uLEB128 utf16_size;
    u8 data[utf16_size];
};

struct type_id_item {
    u32 descriptor_idx;
};

struct proto_id_item {
    u32 shorty_idx;
    u32 return_type_idx;
    u32 parameters_off;
};

struct field_id_item {
    u16 class_idx;
    u16 type_idx;
    u32 name_idx;
};

struct method_id_item {
    u16 class_idx;
    u16 proto_idx;
    u32 name_idx;
};

struct class_def_item {
    u32 class_idx;
    u32 access_flags;
    u32 superclass_idx;
    u32 interfaces_off;
    u32 source_file_idx;
    u32 annotations_off;
    u32 class_data_off;
    u32 static_values_off;
};

struct class_site_id_item {
    u32 call_site_off;
};

struct method_handle_item {
    u16 method_handle_type;
    u16 unused;
    u16 field_or_method_id;
    u16 unused2;
};

struct encoded_field {
    type::uLEB128 field_idx_diff;
    type::uLEB128 access_flags;
};

struct encoded_method {
    type::uLEB128 method_idx_diff;
    type::uLEB128 access_flags;
    type::uLEB128 code_off;
};

struct class_data_item {
    type::uLEB128 static_fields_size;
    type::uLEB128 instance_fields_size;
    type::uLEB128 direct_methods_size;
    type::uLEB128 virtual_methods_size;
    encoded_field static_fields[static_fields_size];
    encoded_field instance_fields[instance_fields_size];
    encoded_method direct_methods[direct_methods_size];
    encoded_method virtual_methods[virtual_methods_size];
};

struct type_item {
    u16 type_idx;
};

struct type_list {
    u32 size;
    type_item list[size];
};

struct code_item {
    u16 registers_size;
    u16 ins_size;
    u16 outs_size;
    u16 tries_size;
    u32 debug_info_off;
    u32 insns_size;
    u16 insns[insns_size];
};

struct try_item {
    u32 start_addr;
    u16 insn_count;
    u16 handler_off;
};


struct Dex {
    header_item header;
    string_id_item string_ids[header.string_ids_size];
    type_id_item type_ids[header.type_ids_size];
    proto_id_item proto_ids[header.proto_ids_size];
    field_id_item field_ids[header.file_ids_size];
    method_id_item method_ids[header.method_ids_size];
    class_def_item class_defs[header.class_defs_size];
    

};
Dex dex @ 0x00;
string_data_item string_data_item_at_0x1AA @ 0x1AA;