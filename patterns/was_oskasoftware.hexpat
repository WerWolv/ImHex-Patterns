#pragma author DmitriLeon2000
#pragma description Oska Software DeskMates WAS/WA3 (WAVE/MP3 Set)
#pragma endian little

import type.size;

struct Sound {
    char name[];
    u32 length;
    u8 data[length];
};

struct Header {
    type::Size<u32> size;
    u32 count;
    u32 pointers[count * 2];
};

struct WAS {
    Header header;
    Sound sounds[header.count];
};

WAS was @ 0x00;