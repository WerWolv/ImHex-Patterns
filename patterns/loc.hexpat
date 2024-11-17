#pragma author DexrnZacAttack
#pragma description Minecraft LCE LOC file

#pragma endian big
#pragma array_limit 739845729834
#pragma pattern_limit 34893726894

import std.string;

struct Keys {
    bool useUniqueIDs;
    u32 count;
    u32 key[count];
};

struct LangIds {
    u16 len;
    char id[len];
    u32 unk;
} [[name(id)]];

struct LocString {
    u16 keySize;
    char key[keySize];
} [[name(std::string::to_string(key))]];

struct Language {
    u32 read;
    if (read > 0)
        u8 unk;
    u16 len;
    char id[len];
    u32 count;
    LocString strings[count];
} [[name(id)]];

struct Loc {
    u32 version;
    u32 count;
    if (version == 2)
        Keys keys;
    LangIds ids[count];
    Language language[count];
};

Loc loc @ 0x00;
