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

struct vec3_t {
    float y;
    float x;
    float z;
};
struct camprefs_t {
    vec3_t position;
    vec3_t orientation;
    vec3_t forward;
    vec3_t right;
    vec3_t up;
};

struct refparams_t
{
    float frametime;
    float time;
    s32 intermission;
    s32 paused;
    s32 spectator;
    s32 onground;
    s32 waterlevel;
    vec3_t velocity;
    vec3_t origin;
    vec3_t viewHeight;
    float idealPitch;
    vec3_t viewangles;
    s32 health;
    vec3_t xhairAngle;
    float viewsize;
    vec3_t punchAngle;
    s32 maxClients;
    s32 viewEntity;
    s32 playerCount;
    s32 maxEnts;
    s32 demoPlayback;
    s32 hardware;
    s32 smoothing;
    s32 ptr_cmd;
    s32 ptr_mvars;
    s32 viewport[4];
    s32 nextview;
    s32 onlyClientDraw;
};

struct usercmd_t
{
    s16 lerp_msec;
    u8 msec;
    u8 UNUSED1;
    vec3_t viewAngles;
    float fwdMove;
    float sideMove;
    float upMove;
    s8 lightLevel;
    u8 UNUSED2;
    u16 buttons;
    s8 impulse;
    s8 weaponSel;
    s16 UNUSED3;
    s32 impactIndex;
    vec3_t impactPos;
};

struct movevars_t
{
    float gravity;
    float stopSpeed;
    float maxSpeed;
    float specMaxSpeed;
    float accel;
    float airAccel;
    float waterAccel;
    float friction;
    float edgeFriction;
    float waterFrict;
    float entGravity;
    float bounce;
    float stepSize;
    float maxVel;
    float zMax;
    float waveHeight;
    s32 footsteps;
    char skyname[32];
    float rollAngle;
    float rollSpeed;
    vec3_t skyColor;
    vec3_t skyVec;
};

struct macro_data_0_1 {
    u32 pad1;
    camprefs_t camprefs;
    refparams_t params;
    usercmd_t usercmds;
    movevars_t movevars;
    u8 etcdata[44];
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

//#pragma array_limit 393210
frame_t Frames1[while($ < Dirs.entries[0].offset + Dirs.entries[0].length)] @ Dirs.entries[0].offset;
frame_t Frames2[while($ < Dirs.entries[1].offset + Dirs.entries[1].length)] @ Dirs.entries[1].offset;
