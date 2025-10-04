/*
Apache Parquet File Format
With help from Claude AI

Known Limits:
- Not all metadata fields named in Pattern Data
- DataPageHeaderV2 not supported

References:
https://parquet.apache.org/docs/file-format/ß
https://issues.apache.org/jira/secure/attachment/12399869/compact-proto-spec-2.txt
https://issues.apache.org/jira/secure/attachment/12399879/thrift-110-v12.patch
https://raw.githubusercontent.com/apache/parquet-format/refs/heads/master/src/main/thrift/parquet.thrift
*/

#pragma description Apache Parquet File Format
#pragma endian little
#pragma MIME application/x-thrift-compact

import std.mem;
import std.sys;
import std.core;
import type.leb128;

s16 last_field_id = 0;
std::mem::Section last_field_id_stack = 
    std::mem::create_section("last_field_id_stack");
u16 last_field_id_stack_size = 0 [[export]];  // Should be 0 at end of parse
u16 last_field_id_stack_size_max = 0;
fn push_last_field_id() {
    s16 last_field_id_stack_top @
        last_field_id_stack_size * sizeof(s16) in last_field_id_stack;
    last_field_id_stack_top = last_field_id;
    last_field_id_stack_size += 1;
    if (last_field_id_stack_size_max < last_field_id_stack_size)
        last_field_id_stack_size_max = last_field_id_stack_size;
};
fn pop_last_field_id() {
    last_field_id_stack_size -= 1;
    s16 last_field_id_stack_top @ 
        last_field_id_stack_size * sizeof(s16) in last_field_id_stack;
    last_field_id = last_field_id_stack_top;
};

std::mem::Section column_offset_list = std::mem::create_section("column_offset_list");
auto column_offset_list_size = 0;
fn push_column_offset(s64 page_offset) {
    s64 column_offset_list_end @ column_offset_list_size * sizeof(s64) in column_offset_list;
    column_offset_list_end = page_offset;
    column_offset_list_size += 1;
};

using CompactI16;
using CompactI32;
using CompactI64;
using CompactBinary;
using CompactList;
using CompactMap;
using ThriftStruct;

// TCompactProtocol Type Constants
enum TCompactType : u8 {
    CT_STOP             = 0x00,
    CT_BOOLEAN_TRUE     = 0x01,
    CT_BOOLEAN_FALSE    = 0x02,
    CT_BYTE             = 0x03,
    CT_I16              = 0x04,
    CT_I32              = 0x05,
    CT_I64              = 0x06,
    CT_DOUBLE           = 0x07,
    CT_BINARY           = 0x08,
    CT_LIST             = 0x09,
    CT_SET              = 0x0A,
//    CT_MAP              = 0x0B,  // Thrift Map not used in Parquet Metadata
    CT_STRUCT           = 0x0C,
    CT_EXTENDED         = 0x0F
};

using VarInt = type::LEB128;

// ZigZag decode for signed integers
fn zigzag_decode_32(u32 n) {
    return s32((n >> 1) ^ (-(n & 1)));
};

fn zigzag_decode_64(u64 n) {
    return s64((n >> 1) ^ (-(n & 1)));
};

/// Field header structure
/// Do not place ThriftFieldHeader directly
/// Always place ThriftStruct
/// Because ThriftFieldHeader depends on global last_field_id_stack
struct ThriftFieldHeader {
    u8 type_and_delta;
    // Extract type (lower 4 bits)
    TCompactType field_type = type_and_delta & 0x0F [[export]];
    if (type_and_delta == 0x0) break;
    
    // Extract field ID delta (upper 4 bits)
    u8 field_id_delta = (type_and_delta & 0xF0) >> 4 [[export]];
    
    // If delta is 0, field ID follows as varint
    if (field_id_delta == 0) {
        VarInt field_id_varint;
        s16 field_id = s16(zigzag_decode_32(u32(field_id_varint))) [[export]];
        last_field_id = field_id;
    } else {
        // Field ID is previous_field_id + delta
        s16 field_id = last_field_id + field_id_delta [[export]];
        last_field_id = field_id;
    }
} [[format("field_header_format")]];

fn field_header_format(ThriftFieldHeader header) {
    if (header.type_and_delta == 0) return "STOP field";
    if (header.field_id_delta == 0) {
        return std::format("Field ID: {}, Type: {:#02x} {}", 
            header.field_id, u8(header.field_type), header.field_type);
    } else {
        return std::format("Field ID Delta: {}, Type: {:#02x} {}", 
            header.field_id_delta, u8(header.field_type), header.field_type);
    }
};

// Variable-length string/binary
struct CompactBinary {
    VarInt length;
    char data[length];
} [[format("compact_binary_format")]];

fn compact_binary_format(CompactBinary bin) {
    return std::format("Length: {}, Data: {}", bin.length, bin.data);
};

// Variable-length integer types
struct CompactI32 {
    VarInt raw_varint;
    s32 value = zigzag_decode_32(u32(raw_varint)) [[export]];
} [[format("compact_i32_format")]];

fn compact_i32_format(CompactI32 val) {
    return std::format("I32: {}", val.value);
};

struct CompactI64 {
    VarInt raw_varint;
    s64 value = zigzag_decode_64(raw_varint) [[export]];
} [[format("compact_i64_format")]];

fn compact_i64_format(CompactI64 val) {
    return std::format("I64: {}", val.value);
};

struct CompactI16 {
    VarInt raw_varint;
    s16 value = s16(zigzag_decode_32(u32(raw_varint.value))) [[export]];
} [[format("compact_i16_format")]];

fn compact_i16_format(CompactI16 val) {
    return std::format("I16: {}", val.value);
};

// List/Set structure
struct CompactList {
    u8 size_and_type;
    
    TCompactType element_type = size_and_type & 0x0F [[export]];
    u8 size_info = (size_and_type & 0xF0) >> 4;
    
    // If size_info >= 15, actual size follows as varint
    u32 size = 0 [[export]];
    if (size_info == 0x0F) {
        VarInt size_varint;
        size = u32(size_varint);
    } else {
        size = size_info;
    }
    
    match (element_type) {
        (TCompactType::CT_BOOLEAN_TRUE): {
            bool value = true [[export]];
        }
        (TCompactType::CT_BOOLEAN_FALSE): {
            bool value = false [[export]];
        }
        (TCompactType::CT_BYTE): {
            s8 value[size];
        }
        (TCompactType::CT_I16): {
            CompactI16 value[size];
        }
        (TCompactType::CT_I32): {
            CompactI32 value[size];
        }
        (TCompactType::CT_I64): {
            CompactI64 value[size];
        }
        (TCompactType::CT_DOUBLE): {
            double value[size];
        }
        (TCompactType::CT_BINARY): {
            CompactBinary value[size];
        }
        (TCompactType::CT_LIST): {
            CompactList value[size];
        }
        (TCompactType::CT_SET): {
            CompactList value[size];  // Same encoding as list
        }
        (TCompactType::CT_STRUCT): {
           ThriftStruct value[size];
        }
    }
} [[format("compact_list_format")]];

fn compact_list_format(ref CompactList list) {
    return std::format("List: {} elements of type {:#02x}", 
        list.size, u8(list.element_type));
};

/// Thrift field structure
/// Do not place ThriftField directly
/// Either place ThriftStruct or place its value
/// Because FieldHeader depends on global last_field_id_stack
struct ThriftField {
    ThriftFieldHeader header;
    if (header.field_type == TCompactType::CT_STOP) break;
    
    // Only parse value if not STOP
    if (header.field_type != TCompactType::CT_STOP) {
        match (header.field_type) {
            (TCompactType::CT_BOOLEAN_TRUE): {
                bool value;
            }
            (TCompactType::CT_BOOLEAN_FALSE): {
                bool value;
            }
            (TCompactType::CT_BYTE): {
                s8 value;
            }
            (TCompactType::CT_I16): {
                CompactI16 value;
            }
            (TCompactType::CT_I32): {
                CompactI32 value;
            }
            (TCompactType::CT_I64): {
                CompactI64 value;
            }
            (TCompactType::CT_DOUBLE): {
                double value;
            }
            (TCompactType::CT_BINARY): {
                CompactBinary value;
            }
            (TCompactType::CT_LIST): {
                CompactList value;
            }
            (TCompactType::CT_SET): {
                CompactList value;  // Same encoding as list
            }
            (TCompactType::CT_STRUCT): {
                ThriftStruct value;
            }
        }
    }
} [[format("thrift_field_format")]];

fn thrift_field_format(ref ThriftField field) {
    if (field.header.field_type == TCompactType::CT_STOP) {
        return "STOP field";
    } else {
        return std::format("Field ID: {}, Value: {}", 
            field.header.field_id, field.value);
    }
};

// Thrift struct
struct ThriftStruct {
    push_last_field_id();
    last_field_id = 0;
    
    ThriftField fields[while(!std::mem::eof())];
    
    pop_last_field_id();
} [[format("thrift_struct_format")]];

fn thrift_struct_format(ref ThriftStruct thrift_struct) {
    return std::format("Thrift Struct with {} fields", 
        std::core::member_count(thrift_struct.fields));
};

fn ptr_field_value_by_id(ref ThriftStruct s, s16 field_id) {
    for (auto i = 0, i < std::core::member_count(s.fields), i += 1) {
        if (s.fields[i].header.field_id == field_id) {
            return addressof(s.fields[i].value);
        }
    }
    std::error("Cannot find field with id {} in {}", field_id, s);   
};

fn idx_field_by_id(ref ThriftStruct s, s16 field_id, s16 since_idx = 0) {
    for (auto i = since_idx, i < std::core::member_count(s.fields), i += 1) {
        if (s.fields[i].header.type_and_delta == 0x0) {
            // std::print("is STOP field");
            continue;
        }
        if (s.fields[i].header.field_id == field_id) {
            return i;
        }
    }
    std::error(std::format("Cannot find field with id {} in {}", field_id, s));
};


/*
struct SchemaElement {
  1: optional Type type;
  2: optional i32 type_length;
  3: optional FieldRepetitionType repetition_type;
  4: required string name;
  5: optional i32 num_children;
  6: optional ConvertedType converted_type;
  7: optional i32 scale
  8: optional i32 precision
  9: optional i32 field_id;
  10: optional LogicalType logicalType
}
*/
fn set_field_names_SchemaElement(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "type");
            (2): std::core::set_display_name(fields[i], "type_length");
            (3): std::core::set_display_name(fields[i], "repetition_type");
            (4): std::core::set_display_name(fields[i], "name");
            (5): std::core::set_display_name(fields[i], "num_children");
            (6): std::core::set_display_name(fields[i], "converted_type");
            (7): std::core::set_display_name(fields[i], "scale");
            (8): std::core::set_display_name(fields[i], "precision");
            (9): std::core::set_display_name(fields[i], "field_id");
            (10): std::core::set_display_name(fields[i], "logicalType");
        }
    }
};

/*
struct ColumnMetaData {
  1: required Type type
  2: required list<Encoding> encodings
  3: required list<string> path_in_schema
  4: required CompressionCodec codec
  5: required i64 num_values
  6: required i64 total_uncompressed_size
  7: required i64 total_compressed_size
  8: optional list<KeyValue> key_value_metadata
  9: required i64 data_page_offset
  10: optional i64 index_page_offset
  11: optional i64 dictionary_page_offset
  12: optional Statistics statistics;
  13: optional list<PageEncodingStats> encoding_stats;
  14: optional i64 bloom_filter_offset;
  15: optional i32 bloom_filter_length;
  16: optional SizeStatistics size_statistics;
  17: optional GeospatialStatistics geospatial_statistics;
}
*/
fn set_field_names_ColumnMetaData(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "type");
            (2): std::core::set_display_name(fields[i], "encodings");
            (3): std::core::set_display_name(fields[i], "path_in_schema");
            (4): std::core::set_display_name(fields[i], "codec");
            (5): std::core::set_display_name(fields[i], "num_values");
            (6): std::core::set_display_name(fields[i], "total_uncompressed_size");
            (7): std::core::set_display_name(fields[i], "total_compressed_size");
            (8): std::core::set_display_name(fields[i], "key_value_metadata");
            (9): std::core::set_display_name(fields[i], "data_page_offset");
            (10): std::core::set_display_name(fields[i], "index_page_offset");
            (11): std::core::set_display_name(fields[i], "dictionary_page_offset");
            (12): std::core::set_display_name(fields[i], "statistics");
            (13): std::core::set_display_name(fields[i], "encoding_stats");
            (14): std::core::set_display_name(fields[i], "bloom_filter_offset");
            (15): std::core::set_display_name(fields[i], "bloom_filter_length");
            (16): std::core::set_display_name(fields[i], "size_statistics");
            (17): std::core::set_display_name(fields[i], "geospatial_statistics");
        }
    }
};

/*
struct ColumnChunk {
  1: optional string file_path
  2: required i64 file_offset = 0
  3: optional ColumnMetaData meta_data  // actually required
  4: optional i64 offset_index_offset
  5: optional i32 offset_index_length
  6: optional i64 column_index_offset
  7: optional i32 column_index_length
  8: optional ColumnCryptoMetaData crypto_metadata
  9: optional binary encrypted_column_metadata
}
*/
fn set_field_names_ColumnChunk(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "file_path");
            (2): std::core::set_display_name(fields[i], "file_offset");
            (3): std::core::set_display_name(fields[i], "meta_data");
            (4): std::core::set_display_name(fields[i], "offset_index_offset");
            (5): std::core::set_display_name(fields[i], "offset_index_length");
            (6): std::core::set_display_name(fields[i], "column_index_offset");
            (7): std::core::set_display_name(fields[i], "column_index_length");
            (8): std::core::set_display_name(fields[i], "crypto_metadata");
            (9): std::core::set_display_name(fields[i], "encrypted_column_metadata");
        }
        if (fields[i].header.field_id == 3) {
            set_field_names_ColumnMetaData(fields[i].value.fields);
        }
    }
};

/*
struct RowGroup {
  1: required list<ColumnChunk> columns
  2: required i64 total_byte_size
  3: required i64 num_rows
  4: optional list<SortingColumn> sorting_columns
  5: optional i64 file_offset
  6: optional i64 total_compressed_size
  7: optional i16 ordinal
}
*/
fn set_field_names_RowGroup(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "columns");
            (2): std::core::set_display_name(fields[i], "total_byte_size");
            (3): std::core::set_display_name(fields[i], "num_rows");
            (4): std::core::set_display_name(fields[i], "sorting_columns");
            (5): std::core::set_display_name(fields[i], "file_offset");
            (6): std::core::set_display_name(fields[i], "total_compressed_size");
            (7): std::core::set_display_name(fields[i], "ordinal");
        }
        if (fields[i].header.field_id == 1) {
            auto n_fields = std::core::member_count(fields[i].value.value);
            for (auto j = 0, j < n_fields, j += 1) {
                set_field_names_ColumnChunk(fields[i].value.value[j].fields);
            }
        }
    }
};

/*
struct FileMetaData {
  1: required i32 version
  2: required list<SchemaElement> schema;
  3: required i64 num_rows
  4: required list<RowGroup> row_groups
  5: optional list<KeyValue> key_value_metadata
  6: optional string created_by
  7: optional list<ColumnOrder> column_orders;
  8: optional EncryptionAlgorithm encryption_algorithm
  9: optional binary footer_signing_key_metadata
}
*/
fn set_field_names_FileMetadata(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        // STOP should always be the last field
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "version");
            (2): std::core::set_display_name(fields[i], "schema");
            (3): std::core::set_display_name(fields[i], "num_rows");
            (4): std::core::set_display_name(fields[i], "row_groups");
            (5): std::core::set_display_name(fields[i], "key_value_metadata");
            (6): std::core::set_display_name(fields[i], "created_by");
            (7): std::core::set_display_name(fields[i], "column_orders");
            (8): std::core::set_display_name(fields[i], "encryption_algorithm");
            (9): std::core::set_display_name(fields[i], "footer_signing_key_metadata");
        }
        if (fields[i].header.field_id == 2) {
            auto n_fields = std::core::member_count(fields[i].value.value);
            for (auto j = 0, j < n_fields, j += 1) {
                set_field_names_SchemaElement(fields[i].value.value[j].fields);
            }
        }
        if (fields[i].header.field_id == 4) {
            auto n_fields = std::core::member_count(fields[i].value.value);
            for (auto j = 0, j < n_fields, j += 1) {
                set_field_names_RowGroup(fields[i].value.value[j].fields);
            }
        }
    }
};

struct FileMetadata : ThriftStruct {
    //std::core::set_display_name(fields[0], "version");
    set_field_names_FileMetadata(fields);
};

fn extract_column_offset_list(ref ThriftStruct file_metadata_struct) {
    // Get index for row_groups id 4
    auto idx_row_groups = idx_field_by_id(file_metadata_struct, 4);
    //std::print("idx_row_groups: {}", idx_row_groups);
    
    // For each RowGroup in row_groups
    auto n_row_groups = std::core::member_count(
            file_metadata_struct
                .fields[idx_row_groups].value.value);
    //std::print("n_row_groups: {}", n_row_groups);
    for (u32 i = 0, i < n_row_groups, i += 1) {
        // Get index for columns id 1
        auto idx_columns = idx_field_by_id(
            file_metadata_struct
                .fields[idx_row_groups].value.value[i],
            1);
        //std::print("idx_columns: {}", idx_columns);
        
        // For each ColumnChunk in columns
        auto n_columns = std::core::member_count(
            file_metadata_struct
                .fields[idx_row_groups].value.value[i]
                .fields[idx_columns].value.value);
        //std::print("n_columns: {}", n_columns);
        for (u32 j = 0, j < n_columns, j += 1) {
        
            // Get index for meta_data id 3
            auto idx_meta_data = idx_field_by_id(
                file_metadata_struct
                    .fields[idx_row_groups].value.value[i]
                    .fields[idx_columns].value.value[j],
                3);
            //std::print("idx_meta_data: {}", idx_meta_data);
                      
            // For ColumnMetadata in meta_data
            // First PageHeader is at: 
            // dictionary_page_offset if present
            // else data_page_offset
            
            try {
                // Get index for dictionary_page_offset id 11
                auto idx_dictionary_page_offset = idx_field_by_id(
                    file_metadata_struct
                        .fields[idx_row_groups].value.value[i]
                        .fields[idx_columns].value.value[j]
                        .fields[idx_meta_data].value,
                    11);
                
                auto dictionary_page_offset =
                    file_metadata_struct
                        .fields[idx_row_groups].value.value[i]
                        .fields[idx_columns].value.value[j]
                        .fields[idx_meta_data].value
                        .fields[idx_dictionary_page_offset].value.value;
                
                push_column_offset(dictionary_page_offset);
            } catch {
            
                // Get index for data_page_offset id 9
                auto idx_data_page_offset = idx_field_by_id(
                    file_metadata_struct
                        .fields[idx_row_groups].value.value[i]
                        .fields[idx_columns].value.value[j]
                        .fields[idx_meta_data].value,
                    9);
                
                auto data_page_offset = 
                    file_metadata_struct
                        .fields[idx_row_groups].value.value[i]
                        .fields[idx_columns].value.value[j]
                        .fields[idx_meta_data].value
                        .fields[idx_data_page_offset].value.value;
                
                push_column_offset(data_page_offset);
            }
        }
    }
};

/*
struct DataPageHeader {
  1: required i32 num_values
  2: required Encoding encoding
  3: required Encoding definition_level_encoding;
  4: required Encoding repetition_level_encoding;
  5: optional Statistics statistics;
}
*/
fn set_field_names_DataPageHeader(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "num_values");
            (2): std::core::set_display_name(fields[i], "encoding");
            (3): std::core::set_display_name(fields[i], "definition_level_encoding");
            (4): std::core::set_display_name(fields[i], "repetition_level_encoding");
            (5): std::core::set_display_name(fields[i], "statistics");
        }
    }
};

/*
struct PageHeader {
  1: required PageType type
  2: required i32 uncompressed_page_size
  3: required i32 compressed_page_size
  4: optional i32 crc
  5: optional DataPageHeader data_page_header;
  6: optional IndexPageHeader index_page_header;
  7: optional DictionaryPageHeader dictionary_page_header;
  8: optional DataPageHeaderV2 data_page_header_v2;
}
*/
fn set_field_names_PageHeader(ref auto fields) {
    for (auto i = 0, i < std::core::member_count(fields), i += 1) {
        if (fields[i].header.type_and_delta == 0) {
            std::core::set_display_name(fields[i], "STOP");
            break;
        }
        match (fields[i].header.field_id) {
            (1): std::core::set_display_name(fields[i], "type");
            (2): std::core::set_display_name(fields[i], "uncompressed_page_size");
            (3): std::core::set_display_name(fields[i], "compressed_page_size");
            (4): std::core::set_display_name(fields[i], "crc");
            (5): std::core::set_display_name(fields[i], "data_page_header");
            (6): std::core::set_display_name(fields[i], "index_page_header");
            (7): std::core::set_display_name(fields[i], "dictionary_page_header");
            (8): std::core::set_display_name(fields[i], "data_page_header_v2");
        }
        if (fields[i].header.field_id == 5) {
            // std::print("{}", fields[i].value);
            set_field_names_DataPageHeader(fields[i].value.fields);
        }
    }
};


fn get_compressed_page_size(ref ThriftStruct page_header) {
    auto idx = idx_field_by_id(page_header, 3);
    return page_header.fields[idx].value.value;
};
struct DataPage {
    ThriftStruct page_header;
    try {
        auto compressed_page_size = get_compressed_page_size(page_header);
        u8 page_data[compressed_page_size];
    }
    set_field_names_PageHeader(page_header.fields);
};

struct ColumnChunk<auto End> {
    DataPage data_pages[while($<End)];
};

struct ColumnChunkPlacer {
    auto i = std::core::array_index();
    s64 column_offset_list_cur @ i * sizeof(s64) in column_offset_list;
    
    //std::print("i + 1: {}, size: {}", i + 1, column_offset_list_size);
    if ((i + 1) < column_offset_list_size) {
        s64 column_offset_list_next @ (i + 1) * sizeof(s64) in column_offset_list;
    } else {
        s64 column_offset_list_next = parent.footer_begin;
    }
    
    ColumnChunk<column_offset_list_next> column_chunk @ column_offset_list_cur;
};

struct ParquetFile {
    char header_magic[4];
    char footer_magic[4] @ sizeof($) - 4;
    s32 footer_length @ sizeof($) - 8;
    auto footer_begin = sizeof($) - 8 - footer_length;
    
    FileMetadata file_metadata_struct @ footer_begin;
        
    extract_column_offset_list(file_metadata_struct);
    
    ColumnChunkPlacer column_chunks[column_offset_list_size] @ 0x0;
    
    s16 last_field_id_stack_view[last_field_id_stack_size_max] @ 0x0 in last_field_id_stack;
};
ParquetFile parquet_file @ 0x0;
//std::print("{}", parquet_file);
