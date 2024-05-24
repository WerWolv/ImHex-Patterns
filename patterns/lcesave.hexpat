#pragma author DexrnZacAttack
#pragma description Minecraft LCE Save Format Pattern
#pragma version 1.0.0
#pragma disclaimer This pattern is not affiliated with Mojang Studios nor Microsoft. Minecraft is a trademark of Mojang Studios and Microsoft.

#pragma endian big
// ^ switch this to little for Switch, PS4, or Xbox One

struct LCESaveHeader {
    u32 offset; // where the index is located
    u32 count; // amount of files in the index
};

struct LCEIndex {
    char filename[0x80]; // name of the file.
    u32 filesize; // how big the file is
    u32 offset; // where the file is located
    u64 timestamp; // file last modified date
};

LCESaveHeader header @ 0x00;
LCEIndex index[header.count] @ header.offset;
