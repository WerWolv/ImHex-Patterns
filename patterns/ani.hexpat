#pragma description Windows animated cursor
#pragma MIME application/x-navi-animation
#pragma endian little

import std.io;
import std.mem;

bitfield HeaderFlags {
    icon : 1;
    sequence : 1;
    padding: 30;
};

struct anih {
    u32 struct_size;
    u32 stored_frames;
    u32 animation_steps;
    u32 w;
    u32 h;
    u32 bits;
    u32 planes;
    u32 default_jiffies;
    HeaderFlags flags;
};

struct rate {
    u32 jiffies[parent.size / 4];
};

struct seq {
    u32 index[parent.size / 4];
};

struct RiffChunk {
    char signature[4];
    u32 size;
    if (signature == "RIFF" || signature == "LIST") {
        char type[4];

        // Compatible with error size defined in ani files
        u32 remain = sizeof($) - addressof(type);
        u32 marked = size > remain ? remain : size;

        RiffChunk chunks[while($ - addressof(type) < marked)];
    } else if (signature[0] == 'I' && parent.type == "INFO") {
        char info[size];
    } else if (signature == "anih") {
        anih anih [[inline]];
    } else if (signature == "rate") {
        rate rate [[inline]];
    } else if (signature == "seq ") {
        seq seq [[inline]];
    } else {
        std::mem::Bytes<size> data;
    }
    padding[size % 2];
} [[format_read("read_chunk")]];

fn read_chunk(RiffChunk chunk) {
    if (chunk.signature == "RIFF" || chunk.signature == "LIST") {
        return std::format("{}<{}> ({})", chunk.signature, chunk.type, chunk.size);
    } else {
        str ret = std::format("{} ({})", chunk.signature, chunk.size);
        try {
            ret += std::format(" \"{}\"", chunk.info);
        } catch {}
        return ret;
    }
};

RiffChunk riff @ 0;
