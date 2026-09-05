#pragma description Hotline/AppWarrior "AWRZ" flat resource file (*.dat)
#pragma magic [ 41 57 52 5a 00 01 ] @ 0x00
#pragma endian big
#pragma encoding mac

import std.core;
import type.size;
import type.magic;

struct Header {
    type::Magic<"AWRZ"> magic;
    u16  version;
    padding[18];
    type::Size32  mapSize;
    type::Size32  dataSize;
};

struct String {
    u16 size;
    char data[size];
} [[sealed, format("format_string")]];
fn format_string(ref auto s) {
    return s.data;
};

// A '%_nm' entry: a name string keyed by the resource ID it names, with
// its `id` field always aligned to a 4-byte boundary (relative to the start
// of the '%_nm' resource's own data) - see the RESOURCE NAMES FORMAT comment
// in URez.cp. Alignment padding lands *before* id, not after data.
struct NameEntry {
    padding[while(($ - parent.startAddr) % 4 != 0)];
    u32 id;
    u16 size;
    char data[size];
} [[name(data), format("format_name_entry")]];

fn format_name_entry(ref NameEntry e) {
    return std::format("{} = \"{}\"", e.id, type::escape_bytes(e.data));
};

struct NameTable {
    u128 startAddr = $;
    u32 count;
    NameEntry names[count];

    // The item's dataSize itself is rounded up to a 4-byte boundary, so the
    // last entry can leave a few trailing unused bytes - consume them so the
    // struct's size still matches the containing ItemEntry.dataSize exactly.
    padding[while(($ - startAddr) % 4 != 0)];
};

// One resource item's raw payload. dataOffset in the owning ItemEntry is
// already an absolute file offset, so a plain pointer resolves it directly.
struct ItemData {
    if (parent.parent.type == "%_nm") {
        NameTable bytes;
    } else {
        u8 bytes[parent.dataSize];
    }
};

struct ItemEntry {
    char id[4] [[hidden]];
    u32 attrib;
    type::Size32 dataSize;
    //ItemData *data : u32 [[inline]];
    u32 dataPtr [[hidden]];
    ItemData data @ dataPtr [[inline]];

} [[name(id), format("format_item_entry")]];

fn format_item_entry(ref ItemEntry item) {
    return item.data.bytes;
};

struct TypeEntry {
    char type[4] [[hidden]];     // 4-char type code (e.g. "PICT", "cicn", "%_nm")
    u32 itemCount [[hidden]];
    ItemEntry items[itemCount] [[inline]];
} [[name(type), format("format_type_entry")]];

fn format_type_entry(ref TypeEntry t) {
    return std::format("'{}' [{}]", t.type, t.itemCount);
};

struct ResourceMap {
    u32 checkOffset [[hidden]];
    std::assert(checkOffset + 4 == $, "");
    u32 typeCount [[hidden]];
    TypeEntry types[typeCount] [[inline]];
};

struct HL_DatFile {
    Header header;
    u8 resourceData[header.dataSize] [[hidden]];
    ResourceMap map;
};

HL_DatFile file @ 0x00 [[inline]];