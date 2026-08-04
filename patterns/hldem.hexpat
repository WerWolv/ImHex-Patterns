/*
* Simple GoldSRC demo pattern.
* Regions of data:
* * Demo header with all info
* * Actual demo data (simplified)
* * Directory of entries
*/
#pragma author den4iklovelinux
#pragma description GoldSRC DEM
#pragma magic [ 48 4C 44 45 4D 4F ] @ 0x00
#pragma endian little

struct header_t
{
    char MAGIC[8];
    s32 demproto;
    s32 netproto;
    char mapname[260];
    char dlldir[260];
    s32 crc;
    s32 diroffset;
};
header_t Header @ 0x00;

struct entry_t
{
    s32 type;
    char desc[64];
    s32 flags;
    s32 cdtrack;
    float pb_time;
    s32 pb_frames;
    s32 offset;
    s32 length;
};

struct demdir_t
{
    s32 numentries;
    entry_t entries[2];
};

demdir_t Dirs @ Header.diroffset;

struct Vector3D {
    float y;
    float x;
    float z;
};
struct Camera {
    Vector3D position;
    Vector3D orientation;
};

struct macro_data_0_1 {
    u32 pad1;
    Camera camprefs;
    u8 pad2[436];
    s32 length;
    u8 data[length];
};

struct macro_data_3 {
    char command[64];
};

struct macro_data_4 {
    u8 pad[32];
};

struct macro_data_6 {
    u8 pad[84];
};

struct macro_data_7 {
    u8 pad[8];
};

struct macro_data_8 {
    u32 pad;
    s32 length;
    u8 data[length + 16];
};

struct macro_data_9 {
    s32 length;
    u8 data[length];
};

struct frame_t
{
    u8 type;
    float time;
    u32 frame;
    
    if (type == 0 || type == 1) {
        macro_data_0_1 data;
    } else if (type == 3) {
        macro_data_3 data;
    } else if (type == 4) {
        macro_data_4 data;
    } else if (type == 6) {
        macro_data_6 data;
    } else if (type == 7) {
        macro_data_7 data;
    } else if (type == 8) {
        macro_data_8 data;
    } else if (type == 9) {
        macro_data_9 data;
    }
};

#pragma array_limit 393210
frame_t Frames1[while($ < Dirs.entries[0].offset + Dirs.entries[0].length)] @ Dirs.entries[0].offset;
frame_t Frames2[while($ < Dirs.entries[1].offset + Dirs.entries[1].length)] @ Dirs.entries[1].offset;
