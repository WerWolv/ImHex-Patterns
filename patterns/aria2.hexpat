#pragma author itsmeow
#pragma description aria2 Control File

#pragma endian big

/*
Format sourced from:
https://aria2.github.io/manual/en/html/technical-notes.html#control-file-aria2-format

Version 0 files are not supported by default
However parsing one is as simple as changing to #pragma endian ittle
and resolving any errors resulting from that by adding be prefixes to struct fields.
*/

struct AriaInFlight {
    u32 index;
    u32 length;
    u32 bitfield_piece_length;
    u8 bitfield_p[bitfield_piece_length];
};

struct AriaHeader {
    u16 version;
    u32 extension;
    u32 infohash_length;
    u8 infohash[infohash_length];
    u32 piece_length;
    u64 total_length;
    u64 upload_length;
    u32 bitfield_length;
    u8 bitfield_d[bitfield_length];
    u32 inflight_count;
    AriaInFlight inflights[inflight_count];
};

AriaHeader aria_header @ 0x00;