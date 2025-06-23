/**
 * @file <gltf.hexpat> ImHex Pattern for glTF binary files.
 *
 * Copyright (c) 2023 H. Utku Maden <utkumaden@hotmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#pragma author H. Utku Maden, xZise
#pragma description GL Transmission Format binary 3D model (.glb)
#pragma MIME model/gltf-binary
#pragma magic [67 6C 54 46] @ 0x00

import std.mem;
import std.io;
import type.magic;
import std.core;
#ifdef __IMHEX__
import hex.type.json;
#endif

/**
 * @brief The glTF magic section.
 */
struct gltf_magic_t {
    type::Magic<"glTF"> magic;  /**< The magic value. Must be "glTF" */
    u32 version;    /**< The version. Must be 2 for glTF 2.0. */
    u32 length;     /**< Length of the file in bytes, including magic section. */
};

/**
 * @brief Enumeration of well defined glTF chunks.
 */
enum gltf_chunk_type_t : u32 {
    JSON = 1313821514 /* "JSON"  */,  /**< JSON chunk. */
    BIN  = 5130562    /* "BIN\0" */,  /**< Binary data chunk. Could be an image or model data. */
};

/**
 * @brief A glTF chunk.
 */
struct gltf_chunk_t {
    u32 length;             /**< Length of this chunk. */
    gltf_chunk_type_t type [[format("gltf_format")]]; /**< Type of the chunk. JSON or BIN expected. */
#ifndef __IMHEX__
    u8 data[length];        /**< The chunk data. */
#endif
#ifdef __IMHEX__
    match (type) {
        (gltf_chunk_type_t::JSON): hex::type::Json<length> json;
        (gltf_chunk_type_t::BIN): u8 data[length];
    }      /**< The chunk data. */
#endif
};

fn gltf_format(gltf_chunk_type_t x)
{
         if (x == gltf_chunk_type_t::JSON) return "JSON";
    else if (x == gltf_chunk_type_t::BIN) return "BIN";

    return "";
};

struct stride_type_t<InnerType, auto Stride> {
    InnerType value [[inline]];
    if (Stride > 0) {
        padding[Stride - sizeof(value)];
    }
};

struct scalar_t<ComponentType> {
    ComponentType scalar;
} [[static, sealed]];

struct vec2_t<ComponentType> {
    ComponentType x;
    ComponentType y;
} [[static]];

struct vec3_t<ComponentType> {
    ComponentType x;
    ComponentType y;
    ComponentType z;
} [[static]];

struct vec4_t<ComponentType> {
    ComponentType x;
    ComponentType y;
    ComponentType z;
    ComponentType w;
} [[static]];

struct mat2_t<ComponentType> {
    ComponentType a11, a21;
    ComponentType a12, a22;
} [[static]];

struct mat3_t<ComponentType> {
    ComponentType a11, a21, a31;
    ComponentType a12, a22, a32;
    ComponentType a13, a23, a33;
} [[static]];

struct mat4_t<ComponentType> {
    ComponentType a11, a21, a31, a41;
    ComponentType a12, a22, a32, a42;
    ComponentType a13, a23, a33, a43;
    ComponentType a14, a24, a34, a44;
} [[static]];

enum component_types_t : u64 {
    BYTE = 5120,
    UNSIGNED_BYTE = 5121,
    SHORT = 5122,
    UNSIGNED_SHORT = 5123,
    UNSIGNED_INT = 5125,
    FLOAT = 5126,
};

fn mem_cnt(auto value) {
    return std::core::member_count(value);
};

fn has_mem(auto value, str member) {
    return std::core::has_member(value, member);
};

struct accessor_t {
    u64 accessor_index = std::core::array_index();
    u64 view_index = glb.json_chunk.json.accessors[accessor_index].bufferView [[export]];
    u64 view_offset = glb.json_chunk.json.bufferViews[view_index].byteOffset [[export]];
    if (has_mem(glb.json_chunk.json.bufferViews[view_index], "byteStride")) {
        u64 byte_stride = glb.json_chunk.json.bufferViews[view_index].byteStride [[export]];
    } else {
        u64 byte_stride = 0 [[export]];
    }
    if (has_mem(glb.json_chunk.json.accessors[accessor_index], "byteOffset")) {
        u64 accessor_offset = glb.json_chunk.json.accessors[accessor_index].byteOffset [[export]];
    } else {
        u64 accessor_offset = 0 [[export]];
    }
    view_offset = view_offset + accessor_offset;
    u64 count_elements = glb.json_chunk.json.accessors[accessor_index].count;
    component_types_t component_type = glb.json_chunk.json.accessors[accessor_index].componentType [[export]];
    str element_type = glb.json_chunk.json.accessors[accessor_index].type [[export]];

    match (element_type, component_type) {
        ("SCALAR", component_types_t::BYTE): stride_type_t<scalar_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("SCALAR", component_types_t::UNSIGNED_BYTE): stride_type_t<scalar_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("SCALAR", component_types_t::SHORT): stride_type_t<scalar_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("SCALAR", component_types_t::UNSIGNED_SHORT): stride_type_t<scalar_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("SCALAR", component_types_t::UNSIGNED_INT): stride_type_t<scalar_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("SCALAR", component_types_t::FLOAT): stride_type_t<scalar_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::FLOAT): stride_type_t<vec2_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::UNSIGNED_INT): stride_type_t<vec2_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::UNSIGNED_SHORT): stride_type_t<vec2_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::SHORT): stride_type_t<vec2_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::UNSIGNED_BYTE): stride_type_t<vec2_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC2", component_types_t::BYTE): stride_type_t<vec2_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::FLOAT): stride_type_t<vec3_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::UNSIGNED_INT): stride_type_t<vec3_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::UNSIGNED_SHORT): stride_type_t<vec3_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::SHORT): stride_type_t<vec3_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::UNSIGNED_BYTE): stride_type_t<vec3_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC3", component_types_t::BYTE): stride_type_t<vec3_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::FLOAT): stride_type_t<vec4_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::UNSIGNED_INT): stride_type_t<vec4_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::UNSIGNED_SHORT): stride_type_t<vec4_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::SHORT): stride_type_t<vec4_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::UNSIGNED_BYTE): stride_type_t<vec4_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("VEC4", component_types_t::BYTE): stride_type_t<vec4_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::FLOAT): stride_type_t<mat2_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::UNSIGNED_INT): stride_type_t<mat2_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::UNSIGNED_SHORT): stride_type_t<mat2_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::SHORT): stride_type_t<mat2_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::UNSIGNED_BYTE): stride_type_t<mat2_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT2", component_types_t::BYTE): stride_type_t<mat2_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::FLOAT): stride_type_t<mat3_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::UNSIGNED_INT): stride_type_t<mat3_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::UNSIGNED_SHORT): stride_type_t<mat3_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::SHORT): stride_type_t<mat3_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::UNSIGNED_BYTE): stride_type_t<mat3_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT3", component_types_t::BYTE): stride_type_t<mat3_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::FLOAT): stride_type_t<mat4_t<float>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::UNSIGNED_INT): stride_type_t<mat4_t<u32>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::UNSIGNED_SHORT): stride_type_t<mat4_t<u16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::SHORT): stride_type_t<mat4_t<s16>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::UNSIGNED_BYTE): stride_type_t<mat4_t<u8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
        ("MAT4", component_types_t::BYTE): stride_type_t<mat4_t<s8>, byte_stride> content[count_elements] @ view_offset + addressof(glb.chunks[0]);
    }
};

struct image_buffer_t {
    u64 image_index = std::core::array_index();
    u64 buffer_view_index = glb.json_chunk.json.images[image_index].bufferView;
    u64 byte_offset = glb.json_chunk.json.bufferViews[buffer_view_index].byteOffset;
    u64 byte_length = glb.json_chunk.json.bufferViews[buffer_view_index].byteLength;
    u8 image[byte_length] @ addressof(glb.chunks[0]) + byte_offset;
} [[hex::visualize("image", image)]];

struct buffer_view_t {
    u64 buffer_view_index = std::core::array_index();
    u64 byte_offset = glb.json_chunk.json.bufferViews[buffer_view_index].byteOffset;
    u64 byte_length = glb.json_chunk.json.bufferViews[buffer_view_index].byteLength;
    u8 data[byte_length] @ addressof(glb.chunks[0]) + byte_offset;
};

struct glb_file_t {
    gltf_magic_t magic;
    gltf_chunk_t json_chunk;
    gltf_chunk_t chunks[while(!std::mem::eof())];

    std::assert_warn(std::mem::size() == magic.length, "file size mismatch");
};

glb_file_t glb @ 0x00;

#ifdef __IMHEX__
struct glb_objects_t {
    if (std::core::member_count(glb.chunks) == 1) {
        u128 bin_chunk = addressof(glb.chunks[0].data);
        if (has_mem(glb.json_chunk.json, "images")) {
            image_buffer_t images[mem_cnt(glb.json_chunk.json.images)];
        }
        buffer_view_t buffer_views[mem_cnt(glb.json_chunk.json.bufferViews)];
        accessor_t accessors[mem_cnt(glb.json_chunk.json.accessors)];
    }
};

glb_objects_t objects @ 0x00;
#endif