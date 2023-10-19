#pragma author DmitriLeon2000
#pragma description Oska Software DeskMates WAS (WAVE Set) File
#pragma endian little

struct Sound {
    char name[];
    u32 length;
    s16 data[length / 2];
};

struct Header {
    u32 size;
    u32 count;
    u32 pointers[count * 2];
};

struct WAS {
    Header header;
    Sound sounds[header.count];
};

WAS was @ 0x00;