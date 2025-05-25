#pragma description Quake 3 Engine demo

#pragma array_limit 2147483647
#pragma pattern_limit 2147483647

#define FINAL_DEMO_MESSAGE_NUMBER -1
#define FINAL_DEMO_MESSAGE_LENGTH -1
import type.magic;

struct Message {
    le s32 messageNum;
    le s32 len;
    if(len != FINAL_DEMO_MESSAGE_LENGTH || messageNum != FINAL_DEMO_MESSAGE_NUMBER) u8 data[len];
};

struct Q3Demo {
    Message messages[while(!std::mem::eof())];
};


Q3Demo q3demo @ 0x00;