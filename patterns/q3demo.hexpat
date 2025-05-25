#pragma description Quake 3 Engine demo

#define FINAL_DEMO_MESSAGE_LENGTH -1

import type.magic;

struct Message {
    s32 messageNum;
    s32 len;
    if(len != FINAL_DEMO_MESSAGE_LENGTH) u8 data[len];
};

struct Q3Demo {
    Message messages[while(!std::mem::eof())];
};


Q3Demo q3demo @ 0x00;