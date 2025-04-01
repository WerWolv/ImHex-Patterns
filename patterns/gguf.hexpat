// https://github.com/ggerganov/ggml/blob/master/docs/gguf.md
// https://github.com/openxla/iree/blob/main/runtime/src/iree/io/formats/gguf/gguf_parser.c

#pragma description ggml GGUF v3
#pragma authors @leonjza, jessie @ imhex discord
#pragma magic [ 47 47 55 46 ] @ 0x00

#pragma pattern_limit 300000

enum ggml_type: u32 {
    GGML_TYPE_F32     = 0,
    GGML_TYPE_F16     = 1,
    GGML_TYPE_Q4_0    = 2,
    GGML_TYPE_Q4_1    = 3,
    // GGML_TYPE_Q4_2 = 4, support has been removed
    // GGML_TYPE_Q4_3 = 5, support has been removed
    GGML_TYPE_Q5_0    = 6,
    GGML_TYPE_Q5_1    = 7,
    GGML_TYPE_Q8_0    = 8,
    GGML_TYPE_Q8_1    = 9,
    GGML_TYPE_Q2_K    = 10,
    GGML_TYPE_Q3_K    = 11,
    GGML_TYPE_Q4_K    = 12,
    GGML_TYPE_Q5_K    = 13,
    GGML_TYPE_Q6_K    = 14,
    GGML_TYPE_Q8_K    = 15,
    GGML_TYPE_IQ2_XXS = 16,
    GGML_TYPE_IQ2_XS  = 17,
    GGML_TYPE_IQ3_XXS = 18,
    GGML_TYPE_IQ1_S   = 19,
    GGML_TYPE_IQ4_NL  = 20,
    GGML_TYPE_IQ3_S   = 21,
    GGML_TYPE_IQ2_S   = 22,
    GGML_TYPE_IQ4_XS  = 23,
    GGML_TYPE_I8      = 24,
    GGML_TYPE_I16     = 25,
    GGML_TYPE_I32     = 26,
    GGML_TYPE_I64     = 27,
    GGML_TYPE_F64     = 28,
    GGML_TYPE_IQ1_M   = 29,
    GGML_TYPE_COUNT,
};

enum gguf_metadata_value_type: u32 {
    // The value is a 8-bit unsigned integer.
    GGUF_METADATA_VALUE_TYPE_UINT8 = 0,
    // The value is a 8-bit signed integer.
    GGUF_METADATA_VALUE_TYPE_INT8 = 1,
    // The value is a 16-bit unsigned little-endian integer.
    GGUF_METADATA_VALUE_TYPE_UINT16 = 2,
    // The value is a 16-bit signed little-endian integer.
    GGUF_METADATA_VALUE_TYPE_INT16 = 3,
    // The value is a 32-bit unsigned little-endian integer.
    GGUF_METADATA_VALUE_TYPE_UINT32 = 4,
    // The value is a 32-bit signed little-endian integer.
    GGUF_METADATA_VALUE_TYPE_INT32 = 5,
    // The value is a 32-bit IEEE754 floating point number.
    GGUF_METADATA_VALUE_TYPE_FLOAT32 = 6,
    // The value is a boolean.
    // 1-byte value where 0 is false and 1 is true.
    // Anything else is invalid, and should be treated as either the model being invalid or the reader being buggy.
    GGUF_METADATA_VALUE_TYPE_BOOL = 7,
    // The value is a UTF-8 non-null-terminated string, with length prepended.
    GGUF_METADATA_VALUE_TYPE_STRING = 8,
    // The value is an array of other values, with the length and type prepended.
    ///
    // Arrays can be nested, and the length of the array is the number of elements in the array, not the number of bytes.
    GGUF_METADATA_VALUE_TYPE_ARRAY = 9,
    // The value is a 64-bit unsigned little-endian integer.
    GGUF_METADATA_VALUE_TYPE_UINT64 = 10,
    // The value is a 64-bit signed little-endian integer.
    GGUF_METADATA_VALUE_TYPE_INT64 = 11,
    // The value is a 64-bit IEEE754 floating point number.
    GGUF_METADATA_VALUE_TYPE_FLOAT64 = 12,
};

// A string in GGUF.
struct gguf_string_t {
    // The length of the string, in bytes.
    u64 len;
    // The string as a UTF-8 non-null-terminated string.
    char string[len];
};


struct gguf_metadata_value_t {
    gguf_metadata_value_type type;
    u64 length;

    match(type) {
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT8): u8 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT8): s8 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT16): u16 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT16): s16 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT32): u32 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT32): s32 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_FLOAT32): float value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_BOOL): bool value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_STRING): gguf_string_t value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT64): u64 value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_FLOAT64): double value[length];
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_ARRAY): double value[length];
    }
};

struct gguf_metadata_value {
    gguf_metadata_value_type type;

    match(type) {
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT8): u8 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT8): s8 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT16): u16 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT16): s16 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT32): u32 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_INT32): s32 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_FLOAT32): float value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_BOOL): bool value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_STRING): gguf_string_t value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_UINT64): u64 value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_FLOAT64): double value;
        (gguf_metadata_value_type::GGUF_METADATA_VALUE_TYPE_ARRAY): gguf_metadata_value_t value;
    }
};

struct gguf_metadata_kv_t {
    // The key of the metadata. It is a standard GGUF string, with the following caveats:
    // - It must be a valid ASCII string.
    // - It must be a hierarchical key, where each segment is `lower_snake_case` and separated by a `.`.
    // - It must be at most 2^16-1/65535 bytes long.
    // Any keys that do not follow these rules are invalid.
    gguf_string_t key;

    // The type of the value.
    // Must be one of the `gguf_metadata_value_type` values.
    // gguf_metadata_value_type value_type;

    // The value.
    gguf_metadata_value value;
};

struct gguf_header_t {
    // Magic number to announce that this is a GGUF file.
    // Must be `GGUF` at the byte level: `0x47` `0x47` `0x55` `0x46`.
    // Your executor might do little-endian byte order, so it might be
    // check for 0x46554747 and letting the endianness cancel out.
    // Consider being *very* explicit about the byte order here.
    u32 magic;
    // The version of the format implemented.
    // Must be `3` for version described in this spec, which introduces big-endian support.
    //
    // This version should only be increased for structural changes to the format.
    // Changes that do not affect the structure of the file should instead update the metadata
    // to signify the change.
    u32 version;
    // The number of tensors in the file.
    // This is explicit, instead of being included in the metadata, to ensure it is always present
    // for loading the tensors.
    u64 tensor_count;
    // The number of metadata key-value pairs.
    u64 metadata_kv_count;
    // The metadata key-value pairs.
    gguf_metadata_kv_t metadata_kv[metadata_kv_count];
};

struct gguf_tensor_info_t {
    // The name of the tensor. It is a standard GGUF string, with the caveat that
    // it must be at most 64 bytes long.
    gguf_string_t name;
    // The number of dimensions in the tensor.
    // Currently at most 4, but this may change in the future.
    u32 n_dimensions;
    // The dimensions of the tensor.
    u64 dimensions[n_dimensions];
    // The type of the tensor.
    ggml_type type;
    // The offset of the tensor's data in this file in bytes.
    //
    // This offset is relative to `tensor_data`, not to the start
    // of the file, to make it easier for writers to write the file.
    // Readers should consider exposing this offset relative to the
    // file to make it easier to read the data.
    //
    // Must be a multiple of `ALIGNMENT`. That is, `align_offset(offset) == offset`.
    u64 offset;
};

struct gguf_file_t {
    // The header of the file.
    gguf_header_t header;

    // Tensor infos, which can be used to locate the tensor data.
    gguf_tensor_info_t tensor_infos[header.tensor_count];

    // Padding to the nearest multiple of `ALIGNMENT`.
    //
    // That is, if `sizeof(header) + sizeof(tensor_infos)` is not a multiple of `ALIGNMENT`,
    // this padding is added to make it so.
    //
    // This can be calculated as `align_offset(position) - position`, where `position` is
    // the position of the end of `tensor_infos` (i.e. `sizeof(header) + sizeof(tensor_infos)`).
    u8 _padding[];

    // Tensor data.
    //
    // This is arbitrary binary data corresponding to the weights of the model. This data should be close
    // or identical to the data in the original model file, but may be different due to quantization or
    // other optimizations for inference. Any such deviations should be recorded in the metadata or as
    // part of the architecture definition.
    //
    // Each tensor's data must be stored within this array, and located through its `tensor_infos` entry.
    // The offset of each tensor's data must be a multiple of `ALIGNMENT`, and the space between tensors
    // should be padded to `ALIGNMENT` bytes.
    u8 tensor_data[];
};

gguf_file_t GGUF @ 0x00;
