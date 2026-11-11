#pragma endian little
#pragma description PUZ file format
#pragma magic [ 41 43 52 4F 53 53 26 44 4F 57 4E 00 ] @ 0x02

import std.string;

struct Header {
    u16 checksum;
    char magic[12];
    u16 cib_checksum;
    u32 low_checksum;
    u32 high_checksum;
    char version[4];
    padding[16];
    u8 width;
    u8 height;
    u16 clues;
    padding[4];
};

struct File {
    Header header;
    char solution[header.width * header.height];
    char state[header.width * header.height];
    std::string::NullString title;
    std::string::NullString author;
    std::string::NullString copyright;
    std::string::NullString clues[header.clues];
};

File file @ 0x00;
