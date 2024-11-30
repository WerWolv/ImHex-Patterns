#pragma author WerWolv
#pragma description DOOM WAD Archive

import type.magic;
import type.size;

enum WADType : char {
    Internal = 'I',
    Patch = 'P'
};

struct FileLump {
    u32 filePos;
    type::Size<u32> size;
    char name[8];

    u8 data[size] @ filePos [[sealed]];
};

struct WAD {
    WADType type;
    type::Magic<"WAD"> identification;
    u32 numLumps;
    FileLump *infoTable[numLumps] : u32;
};

WAD wad @ 0x00;