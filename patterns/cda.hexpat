#pragma description Compact Disc Audio track

struct Header {
u32 RIFF;
s32 size;
u32 CDDA;
u32 fmt;
u32 lenghtofthechunck;
u16 versionofcdformat;
u16 numberofrange;
u32 identifier;
};


struct DataInfo {

u32 range;
u32 duration;
u8 rangepositionframes;
u8 rangepositionseconds;
u8 rangepositionminutes;
u8 nullbyte;
u8 durationtrackframes;
u8 durationtrackseconds;
u8 durationtrackminutes;
u8 nullbytee;
};


Header header @ 0;
DataInfo data @ 0x1C;
