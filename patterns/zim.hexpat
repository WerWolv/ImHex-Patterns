#pragma endian little
#pragma description ZIM file format
#pragma magic [ 5A 49 4D 04 ] @ 0x00

u32 maxEntries in;

import std.string;
import std.mem;
import std.math;
import std.core;

struct Header {
    char signature[4];
    u16 majorVersion;
    u16 minorVersion;
    u128 uid;
    u32 entryCount, clusterCount;
    u64 pathPtrPos, titlePtrPos, clusterPtrPos, mimeListPos;
    u32 mainPage;
    u32 layoutPage;
    u64 checksumPos;
};


Header header @ 0x00;
std::string::NullString mimeTypes[while(std::mem::read_unsigned($, 1) != 0x00)] @ header.mimeListPos;

fn mimename(u16 index) {
    if(index == 0xFFFF) {
        return "redirect";
    } else {
        return mimeTypes[index];
    }
};

enum CompressionType : u8 {
    None = 0x01,
    LZMA2 = 0x04,
    zstd = 0x05
};

bitfield ClusterInfo {
    CompressionType compression: 4;
    offsetSize: 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

struct Cluster {
    ClusterInfo info;
} [[inline]];

struct ClusterPointer {
    Cluster *cluster: u64;
} [[inline]];

struct Entry {
    u16 mimetype [[format("mimename")]];
    u8 parameterlen [[hidden]];
    char namespacee;
    u32 revision;
    if (mimetype == 0xFFFF) {
        u32 redirectIndex;
    } else {
        u32 clusterNumber;
        ClusterPointer cluster @ (header.clusterPtrPos + clusterNumber * 8);
        u32 blobNumber;
    }

    std::string::NullString path;
    std::string::NullString title;
    padding[parameterlen];
} [[inline]];

struct EntryPointer {
    Entry *entry : u64;
} [[inline]];

EntryPointer pathPointerList[std::math::min(header.entryCount, maxEntries == 0 ? 1500 : maxEntries)] @ header.pathPtrPos;
u32 titlePointerList[header.entryCount] @ header.titlePtrPos;

