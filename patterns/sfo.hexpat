#pragma author Li
#pragma description PlayStation SFO
#pragma magic [00 50 53 46] @ 0x00

import type.magic;

enum SfoType : u8 {
    PSF_TYPE_BIN = 0,
    PSF_TYPE_STR = 2,
    PSF_TYPE_VAL = 4
};

struct SfoHeader {
    type::Magic<"\0PSF"> magic;
    u32 verison;
    u32 keyTableOffset;
    u32 valueTableOffset;
    u32 count;
};

SfoHeader sfoHeader @ 0x00;

struct SfoEntries {
    u16 nameOffset;
    u8 align;
    SfoType type;
    u32 size;
    u32 totalSize;
    u32 dataOffset;
    
    char name[] @ sfoHeader.keyTableOffset + nameOffset;
 
    u8 valueBuffer[totalSize] @ sfoHeader.valueTableOffset + dataOffset;
    
    if(type == SfoType::PSF_TYPE_BIN) {
        u8 value[size] @ sfoHeader.valueTableOffset + dataOffset;    
    }
    else if(type == SfoType::PSF_TYPE_STR) {
        char value[size] @ sfoHeader.valueTableOffset + dataOffset;
    }
    else if(type == SfoType::PSF_TYPE_VAL) {
        u32 value @ sfoHeader.valueTableOffset + dataOffset;    
    }
};

SfoEntries sfoEntries[sfoHeader.count] @ sizeof(sfoHeader);
