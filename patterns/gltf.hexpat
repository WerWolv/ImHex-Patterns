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
import hex.type.json;
import std.core;

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
    match (type) {
        (gltf_chunk_type_t::JSON): hex::type::Json<length> json;
        (gltf_chunk_type_t::BIN): u8 data[length];
    }      /**< The chunk data. */
};

fn gltf_format(gltf_chunk_type_t x)
{
         if (x == gltf_chunk_type_t::JSON) return "JSON";
    else if (x == gltf_chunk_type_t::BIN) return "BIN";

    return "";
};

u64 json_offset = 0;
u64 json_length = 0;

struct StrideType<InnerType, auto Stride> {
    InnerType value [[inline]];
    if (Stride > 0) {
        padding[Stride - sizeof(value)];
    }
};

struct Scalar<ComponentType> {
    ComponentType scalar;
} [[static, sealed]];

struct Vec2<ComponentType> {
    ComponentType x;
    ComponentType y;
} [[static]];

struct Vec3<ComponentType> {
    ComponentType x;
    ComponentType y;
    ComponentType z;
} [[static]];

struct Vec4<ComponentType> {
    ComponentType x;
    ComponentType y;
    ComponentType z;
    ComponentType w;
} [[static]];

struct Mat2<ComponentType> {
    ComponentType a11;
    ComponentType a21;
    ComponentType a12;
    ComponentType a22;
} [[static]];

struct Mat3<ComponentType> {
    ComponentType a11;
    ComponentType a21;
    ComponentType a31;
    ComponentType a12;
    ComponentType a22;
    ComponentType a32;
    ComponentType a13;
    ComponentType a23;
    ComponentType a33;
} [[static]];

struct Mat4<ComponentType> {
    ComponentType a11;
    ComponentType a21;
    ComponentType a31;
    ComponentType a41;
    ComponentType a12;
    ComponentType a22;
    ComponentType a32;
    ComponentType a42;
    ComponentType a13;
    ComponentType a23;
    ComponentType a33;
    ComponentType a43;
    ComponentType a14;
    ComponentType a24;
    ComponentType a34;
    ComponentType a44;
} [[static]];

enum ComponentType : u64 {
    BYTE = 5120,
    UNSIGNED_BYTE = 5121,
    SHORT = 5122,
    UNSIGNED_SHORT = 5123,
    UNSIGNED_INT = 5125,
    FLOAT = 5126,
};

struct Accessor<auto Offset> {
    hex::type::Json<json_length> Json @ json_offset;
    hex::type::Json<json_length> Json2 @ json_offset;
    hex::type::Json<json_length> Json3 @ json_offset;
    u64 accessor_index = std::core::array_index();
    u64 view_index = Json.accessors[accessor_index].bufferView [[export]];
    u64 view_offset = Json.bufferViews[view_index].byteOffset [[export]];
    if (std::core::has_member(Json2.bufferViews[view_index], "byteStride")) {
        u64 byte_stride = Json.bufferViews[view_index].byteStride [[export]];
    } else {
        u64 byte_stride = 0 [[export]];
    }
    if (std::core::has_member(Json3.accessors[accessor_index], "byteOffset")) {
        u64 accessor_offset = Json.accessors[accessor_index].byteOffset [[export]];
    } else {
        u64 accessor_offset = 0 [[export]];
    }
    view_offset = view_offset + accessor_offset;
    u64 count_elements = Json.accessors[accessor_index].count;
    ComponentType component_type = Json.accessors[accessor_index].componentType [[export]];

    match (Json.accessors[accessor_index].type, component_type) {
        ("SCALAR", ComponentType::BYTE): StrideType<Scalar<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("SCALAR", ComponentType::UNSIGNED_BYTE): StrideType<Scalar<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("SCALAR", ComponentType::SHORT): StrideType<Scalar<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("SCALAR", ComponentType::UNSIGNED_SHORT): StrideType<Scalar<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("SCALAR", ComponentType::UNSIGNED_INT): StrideType<Scalar<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("SCALAR", ComponentType::FLOAT): StrideType<Scalar<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::FLOAT): StrideType<Vec2<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::UNSIGNED_INT): StrideType<Vec2<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::UNSIGNED_SHORT): StrideType<Vec2<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::SHORT): StrideType<Vec2<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::UNSIGNED_BYTE): StrideType<Vec2<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC2", ComponentType::BYTE): StrideType<Vec2<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::FLOAT): StrideType<Vec3<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::UNSIGNED_INT): StrideType<Vec3<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::UNSIGNED_SHORT): StrideType<Vec3<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::SHORT): StrideType<Vec3<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::UNSIGNED_BYTE): StrideType<Vec3<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC3", ComponentType::BYTE): StrideType<Vec3<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::FLOAT): StrideType<Vec4<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::UNSIGNED_INT): StrideType<Vec4<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::UNSIGNED_SHORT): StrideType<Vec4<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::SHORT): StrideType<Vec4<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::UNSIGNED_BYTE): StrideType<Vec4<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("VEC4", ComponentType::BYTE): StrideType<Vec4<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::FLOAT): StrideType<Mat2<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::UNSIGNED_INT): StrideType<Mat2<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::UNSIGNED_SHORT): StrideType<Mat2<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::SHORT): StrideType<Mat2<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::UNSIGNED_BYTE): StrideType<Mat2<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT2", ComponentType::BYTE): StrideType<Mat2<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::FLOAT): StrideType<Mat3<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::UNSIGNED_INT): StrideType<Mat3<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::UNSIGNED_SHORT): StrideType<Mat3<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::SHORT): StrideType<Mat3<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::UNSIGNED_BYTE): StrideType<Mat3<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT3", ComponentType::BYTE): StrideType<Mat3<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::FLOAT): StrideType<Mat4<float>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::UNSIGNED_INT): StrideType<Mat4<u32>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::UNSIGNED_SHORT): StrideType<Mat4<u16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::SHORT): StrideType<Mat4<s16>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::UNSIGNED_BYTE): StrideType<Mat4<u8>, byte_stride> content[count_elements] @ view_offset + Offset;
        ("MAT4", ComponentType::BYTE): StrideType<Mat4<s8>, byte_stride> content[count_elements] @ view_offset + Offset;
    }
};

fn mem_cnt(auto value) {
    return std::core::member_count(value);
};

struct ImageBuffer<auto Offset> {
    hex::type::Json<json_length> Json @ json_offset;
    u64 image_index = std::core::array_index();
    u64 buffer_view_index = Json.images[image_index].bufferView;
    u64 byte_offset = Json.bufferViews[buffer_view_index].byteOffset;
    u64 byte_length = Json.bufferViews[buffer_view_index].byteLength;
    u8 image[byte_length] @ Offset + byte_offset;
} [[hex::visualize("image", image)]];

struct BufferView<auto Offset> {
    hex::type::Json<json_length> Json @ json_offset;
    u64 buffer_view_index = std::core::array_index();
    u64 byte_offset = Json.bufferViews[buffer_view_index].byteOffset;
    u64 byte_length = Json.bufferViews[buffer_view_index].byteLength;
    u8 data[byte_length] @ Offset + byte_offset;
};

struct Glb {
    gltf_magic_t magic;
    gltf_chunk_t json_chunk;
    gltf_chunk_t chunks[while(!std::mem::eof())];

    json_offset = addressof(json_chunk.json);
    json_length = json_chunk.length;

    std::assert_warn(std::mem::size() == magic.length, "file size mismatch");

    if (std::core::member_count(chunks) == 1) {
        u128 bin_chunk = addressof(chunks[0].data);
        hex::type::Json<json_length> Json @ json_offset;
        if (std::core::has_member(Json, "images")) {
            ImageBuffer<bin_chunk> images[mem_cnt(json_chunk.json.images)];
        }
        BufferView<bin_chunk> buffer_views[mem_cnt(json_chunk.json.bufferViews)];
        Accessor<bin_chunk> accessors[mem_cnt(json_chunk.json.accessors)];
    }
};

Glb glb @ 0x00;