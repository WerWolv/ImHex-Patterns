/**
 * @file <gltf.pat> ImHex Pattern for glTF binary files.
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

import std.mem;
import std.io;

/**
 * @brief The glTF magic section.
 */
struct gltf_magic_t {
    char magic[4];  /**< The magic value. Must be "glTF" */
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
    u8 string[length];      /**< The chunk data. */
};

fn gltf_format(gltf_chunk_type_t x)
{
         if (x == gltf_chunk_type_t::JSON) return "JSON";
    else if (x == gltf_chunk_type_t::BIN) return "BIN";
    
    return "";
};

gltf_magic_t magic @ 0x00;
gltf_chunk_t chunks[while(!std::mem::eof())] @ $;

if (magic.magic != "glTF")
    std::error("This file might not be a glTF file, expected \"glTF\", got %s", magic.magic);
