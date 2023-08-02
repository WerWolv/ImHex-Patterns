#pragma endian big

#include <std/mem.pat>
#include <std/sys.pat>

// Ubiquiti Firmware related structs

/*
 * Block types of a default firmware file file:
 *  - UBNT := header
 *  - PART := partition
 *  - EXEC := additional data block
 *  - END. := default end block
 *  - ENDS := signed end block using RSA 2048 bit
 */
#define TYPE_UBNT       "UBNT"
#define TYPE_PART       "PART"
#define TYPE_EXEC       "EXEC"
#define TYPE_END        "END."
#define TYPE_SIGNED_END "ENDS"

namespace ubnt {
    struct UBNT {
        char version[256];
        u32 crc32;
    };

    struct PART {
        char name[16];
        u8 reserved[16];
        u32 id; // maybe, not documented but incrementing
        u32 baseAddress;
        u32 unknown; // always zero
        s32 dataSize;
        u8 data[this.dataSize + 8];
    };

    struct EXEC {
        char name[16];
        u8 reserved[28];
        u32 size;
        u32 size2;
        u32 crc32;
        u8 data[this.size];
    };

    struct END {
        u32 crc32;
    };

    struct ENDS {
        u8 data[256];
    };
}


struct Block {
    char type[4];

    if (type == TYPE_UBNT) {
        ubnt::UBNT header;
    }
    else if (type == TYPE_PART) {
        ubnt::PART partition;
    }
    else if (type == TYPE_EXEC) {
        ubnt::EXEC data;
    }
    else if (type == TYPE_END) {
        ubnt::END end;
    }
    else if (type == TYPE_SIGNED_END) {
        ubnt::ENDS end;
    }

    // REVISIT: change the type to u32
    u8 pad[4];
};

// Greedy parsing of Block structs
Block blocks[while(!std::mem::eof())] @ 0x00;

std::assert(blocks[0].type == TYPE_UBNT,
    "File is not a valid Ubiquiti firmare file!");

std::print("Version: {}", blocks[0].header.version);