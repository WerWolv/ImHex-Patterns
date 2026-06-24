#pragma author DexrnZacAttack
#pragma description APE audio metadata
#pragma magic [ 41 50 45 54 41 47 45 58 ] @ 0x00
#pragma version 1.0.1

import std.core;
import std.sys;

namespace APE {
    enum ItemType : u8 {
        UTF8 = 0,
        BINARY = 1,
        EXTERNAL = 2,
        RESERVED = 3
    };

    bitfield ItemFlags {
        RW : 1;
        Type : 2;
        Reserved : 25;
        IsHeader : 1;
        HasNoFooter : 1;
        HasHeader : 1;
    };
 
    struct TagItem {
         u32 len;
         ItemFlags flags;
         char key[];
         
         if (flags.Type == ItemType::UTF8)
            char value[len];
         else
            u8 value[len];
    };

    struct Block {
        char signature[8];
        if (signature != "APETAGEX")
            std::error("Signature does not match \"APETAGEX\"");
        
        u32 version;
        u32 tagSize;
        u32 itemCount;
        ItemFlags globalFlags;
        u64 reserved;
    };
    
    struct File {
        Block header;
        TagItem items[header.itemCount];
        
        Block footer;
    };
}

#ifndef APE_USE_LIB
    APE::File ape @ 0x00;
#endif
