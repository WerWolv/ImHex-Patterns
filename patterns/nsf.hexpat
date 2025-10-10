#pragma author gmestanley
#pragma description NES Sound Format file

#include <./nsfmetadata.hexpat>

bitfield NSF2Flags {
    padding : 4;
    irq : 1;
    nonReturningInitNotUsed : 1;
    playSubroutineNotUsed : 1;
    playbackNSFeChunk : 1;
};

bitfield Region {
    isPAL : 1;
    palNTSCDual : 1;
};

enum ExtraSoundChipSupport : u8 {
    None,
    VRC6,
    VRC7,
    FDS = 4,
    MMC5 = 8,
    Namco163 = 16,
    Sunsoft5B = 32,
    VTxx = 64
};

fn formatName(str string) {
    for (u8 nameIndex = 0, nameIndex < 32, nameIndex += 1) {
        if (!$[$+nameIndex] || nameIndex == 31)
            return "\"" + std::string::substr(string, 0, nameIndex) + "\"";
    }
};

fn renderEOF(str value) {
    return "\"NESM<EOF>\"";
};

struct Header {
    char signature[5] [[format("renderEOF")]];
    u8 version;
    u8 songAmount;
    u8 startingSong;
    u16 dataLoadAddress;
    u16 dataInitAddress;
    u16 dataPlayAddress;
    char gameName[32] [[format("formatName")]];
    char songwriting[32] [[format("formatName")]];
    char copyrightHolder[32] [[format("formatName")]];
    u16 ntscPlaySpeed;
    u8 bankswitchInitValues[8];
    u16 palPlaySpeed;
    Region region;
    ExtraSoundChipSupport extraSoundChipSupport;
    NSF2Flags nsf2flags;
    u24 dataLength;
};

Header header @ 0x00;

struct Chunks {
    if (header.dataLength)
    Chunk chunks[while($<std::mem::size())];
};

Chunks metadata @ 0x80+header.dataLength;
