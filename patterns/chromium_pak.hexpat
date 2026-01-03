#pragma author East_Arctica
#pragma description Chromium Pak File

import std.core;
import std.io;

struct IndexEntry {
    u16 id;
    u32 offset;
};

struct AliasEntry {
    u16 id;
    u16 index;
};

struct ResourceView {
    u32 i = std::core::array_index();

    u16 id     = parent.entries[i].id;
    u32 start  = parent.entries[i].offset;
    u32 end    = parent.entries[i + 1].offset;
    u32 length = (end >= start) ? (end - start) : 0;

    u8 data[length] @ start;
    
    // pak_util.py implies that this may also be gzip with a header of 0x1f 0x8b
    bool is_brotli = (length > 8 && data[0] == 0x1e && data[1] == 0x9b);
    if (is_brotli) {
        u8 magic[2] @ start;
        u48 decompressed_size @ start + 2;
        // TODO: If brotli decompression is added to ImHex, add it here.
    }
};

struct AliasResourceView {
    u32 i = std::core::array_index();
    
    u16 id = parent.aliases[i].id;
    u16 idx = parent.aliases[i].index;

    bool valid = (idx < parent.resource_count);
    u32 start  = valid ? parent.entries[idx].offset : 0;
    u32 end    = valid ? parent.entries[idx + 1].offset : 0;
    u32 length = (valid && end >= start) ? (end - start) : 0;

    u8 data[length] @ start;

};

struct Pak {
    u32 version;
    if (version == 4) {
        u32 resource_count;
        u8 encoding;

        IndexEntry entries[resource_count + 1];
        ResourceView resources[resource_count];
    } else if (version == 5) {
        u8 encoding;
        padding[3];
        u16 resource_count;
        u16 alias_count;

        IndexEntry entries[resource_count + 1];
        AliasEntry aliases[alias_count];
        ResourceView resources[resource_count];
        AliasResourceView alias_resources[alias_count];
    } else {
        std::error("Unsupported pak version");
    }
};

// Some pack files are stored gzipped and need to be gunzipped first
Pak pak @ 0x00;
