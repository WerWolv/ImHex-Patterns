#pragma author dvob
#pragma description GNU Machine Object (MO) files containing translations for gettext

// https://www.gnu.org/software/gettext/manual/html_node/MO-Files.html

import std.core;
import std.io;

struct strPtr {
    u32 length;
    u32 offset;
    char string[length] @ offset;
};

struct file {
    be u32 magic;
    if ( magic == 0x950412de )
        std::core::set_endian(std::mem::Endian::Big);
    else if ( magic == 0xde120495)
        std::core::set_endian(std::mem::Endian::Little);
    else
        std::error("Invalid MO Magic!");

    u16 majorVersion;
    u16 minorVersion;
    u32 count;
    u32 msgIdOffset;
    u32 msgStrOffset;
    u32 hashSize;
    u32 hashOffset;

    u32 hashTable[hashSize] @ hashOffset;
    strPtr msgIDTable[count] @ msgIdOffset;
    strPtr msgStrTable[count] @ msgStrOffset;
};

file moFile @ 0x0;
