#pragma description ADTFDAT File

#pragma magic [ 49 46 48 44 ] @ 0x00
#pragma endian little

import std.io;
import std.mem;
import type.time;

enum FileVersion : u32 {
  with_history_end_offset = 0x00000301,
  v500 = 0x00000500
};

bitfield ChunkFlags {
  key : 1;
  info : 1;
  marker : 1;
  type : 1;
  trigger : 1;
  reserved: 11;
};

struct Extension
{
    char identifier[384];
    u16 stream_id;
    u8 reserved1[2];
    u32 user_id;
    u32 type_id;
    u32 version_id;
    u64 data_pos;
    u64 data_size;
    u8 reserved[96];
    u8 payload[data_size] @ data_pos;
};

struct ChunkHeader {
    u64 time_stamp [[format("format_timestamp_with_offset")]];;
    u32 ref_master_table_index;
    u32 offset_to_last;
    u32 size;
    u16 stream_id;
    ChunkFlags flags;
    u64 stream_index;
};

struct SampleInfo {
    u8 memory_layout_version;
    u32 size;
    u8 payload[size];
};

struct Sample {
    s64 timestamp [[format("format_timestamp")]];;
    s32 flags;
    u64 buffer_size;
    u8 payload[buffer_size];
    if (flags & 0x100) {
        SampleInfo sample_info;
    }
    if (flags & 0x200) {
        u32 substream_id;
    } else {
        u32 substream_id = 0 [[export]];
    }
};

struct Chunk {
    auto start_address = $;

    ChunkHeader header;

    if (header.size < 32 || start_address + header.size > std::mem::size()) {
        std::warning(std::format("Invalid header size {} in chunk {} at offset 0x{:X}, last valid chunk at 0x{:X}.", header.size, chunk_index, start_address, last_valid_chunk_offset));
        break;
    }

    last_valid_chunk_offset = start_address;

    u8 payload[header.size - 32];

    if (!skip_valid_chunks) {
        if (!header.flags.info && !header.flags.marker && !header.flags.type && !header.flags.trigger) {
            try {
                Sample sample @ addressof(payload);
            } catch {
                std::warning(std::format("Invalid sample payload at chunk {} at 0x{:X}", chunk_index, start_address));
            }
        }
    }

    chunk_index += 1;

    // Padding with 0xEE to the next chunk header
    std::mem::AlignTo<16>;

    if (skip_valid_chunks) {
        continue;
    }
};

struct Header {
    u32 file_id;
    u32 version_id;
    u32 flags;
    u32 extension_count;
    u64 extension_offset;
    u64 data_offset;
    u64 data_size;
    u64 chunk_count;
    u64 max_chunk_size;
    u64 duration;
    type::time64_t filetime;
    u8 header_byte_order;
    u64 time_offset [[format("format_timestamp")]];
    u8 patch_number;
    u64 first_chunk_offset;
    u64 continuous_offset;
    u64 ring_buffer_end_offset;
    u8 reserved[30];
    char description[1912];
};

struct IndexedFile {
    Header header;
    Extension extensions[header.extension_count] @ header.extension_offset;

    if (header.version_id >= FileVersion::with_history_end_offset &&
        header.continuous_offset != header.data_offset) {
        try {
            Chunk ring_front[while($ < header.continuous_offset)] @ header.first_chunk_offset;
            Chunk ring_back[while($ < header.ring_buffer_end_offset)] @ header.data_offset;
            Chunk continueous[header.chunk_count - chunk_index] @ header.continuous_offset;
        } catch {
            std::warning("Too many chunks. Performing check only.");
            skip_valid_chunks = true;
            chunk_index = 0;
            Chunk ring_front[while($ < header.continuous_offset)] @ header.first_chunk_offset;
            Chunk ring_back[while($ < header.ring_buffer_end_offset)] @ header.data_offset;
            Chunk continueous[while(chunk_index < header.chunk_count)] @ header.continuous_offset;
        }
    } else {
        try {
            Chunk chunks[header.chunk_count] @ header.data_offset;
        } catch {
            std::warning("Too many chunks. Performing check only.");
            skip_valid_chunks = true;
            chunk_index = 0;
            Chunk chunks[while(chunk_index < header.chunk_count)] @ header.data_offset;
        }
    }
};

fn format_timestamp(u64 data) {
    double seconds = 0;
    if (file.header.version_id < FileVersion::v500) {
        // microseconds
        seconds = data / double(1000000);
    } else {
        // nanoseconds
        seconds = data / double(1000000000);
    }

    std::time::Time time64 = std::time::to_utc(seconds);
    return std::time::format(time64);
};

fn format_timestamp_with_offset(u64 data) {
    return format_timestamp(data + file.header.time_offset);
};

bool skip_valid_chunks = false;
u64 last_valid_chunk_offset = 0;
u64 chunk_index = 0;
IndexedFile file @ 0x00;
