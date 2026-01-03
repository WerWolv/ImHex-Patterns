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

    u16 id = parent.entries[i].id;
    u32 start = parent.entries[i].offset;
    u32 end = parent.entries[i + 1].offset;
    u32 length = (end >= start) ? (end - start) : 0;

    u8 data[length] @ start;
    // Brotli compression header
    if (start > 2 && data[0] == 0x1e && data[1] == 0x9b) {
        // TODO: If brotli decompression is added to ImHex, add it here.
    }
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
    } else {
        std::error("Unsupported pak version");
    }
};

Pak pak @ 0x00;
