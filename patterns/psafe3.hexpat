// Password Safe V3
// Only a small part of the file is unencrypted.

#pragma endian little
#pragma description Password Safe V3

import std.mem;
import std.sys;

struct Prologue {
    u8 SALT[32];
    u32 ITER;
    u8 HPP[32] [[name("H(P')")]];
    u8 B1[16];
    u8 B2[16];
    u8 B3[16];
    u8 B4[16];
    u8 IV[16];
};

struct EOF {
    u8 HMAC[32];
};

char magic[4] @ 0x00;
std::assert(magic == "PWS3", "Invalid file: bad tag!");
char marker[16] @ std::mem::size() - 48;
std::assert(marker == "PWS3-EOFPWS3-EOF", "Invalid file: bad end marker!");

Prologue prologue @ 0x04;
u8 HMAC[32] @ std::mem::size() - 32;

EOF eof @ std::mem::size() - 48;