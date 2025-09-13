#pragma author Arthur Beck
#pragma description TI program
#pragma endian little

import type.magic;

struct Header {
    type::Magic<"**TI83F*\x1A\x0A"> signature;
    u8 mystery;
    char comment[42];
    le u16 remaining_length;
};

enum FileType: u8 {
    Program = 0x05,
    EditLockedProgram = 0x06,
    Group = 0x16,
    FlashApp = 0x24,
};

enum Archived: u8 {
    Unarchived = 0x00,
    Archived = 0x80,
};

enum ProgramType: u16 {
    UncompiledAsm = 0xBB6C,
    CompiledAsm = 0xBB6D,
    Basic = 0x0000 ... 0xFFFF,
};

struct Meta {
    u8 mystery1;
    u8 mystery2;
    le u16 body_plus_check_length;
    FileType file_type;
    char program_name[8];
    u8 version;
    Archived archived;
    le u16 body_plus_check_length2 [[name("body_plus_check_length")]];
    le u16 body_length;
    ProgramType prg_type [[no_unique_address]];
};

struct TI8xp {
    Header header;
    Meta meta;
    u8 body[meta.body_length - 2];
    u16 checksum;
};

TI8xp file @ 0x00;
