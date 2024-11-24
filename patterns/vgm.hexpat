#pragma author applecuckoo
#pragma description VGM (Video Game Music) sound log

#pragma endian little

import type.magic;
import std.string;
import std.io;

u32 versionValue;
u32 gd3TagPos;
u32 chpClkBase;
u32 chpVolBase;

// note: the versionValue variable exists to help check which fields exist and which don't, otherwise the actual log data would show up as part of the header.

bitfield VGMVersion {
    bugfix : 4;
    minor : 4;
    major : 24;

    versionValue = major * 100 + minor * 10 + bugfix;

} [[format("format_VGMVersion")]];

fn format_VGMVersion(auto version) {
    return std::format("{}.{}{}", version.major, version.minor, version.bugfix);
};

bitfield SN76489Flags {
    frequency : 1;
    negateOutput : 1;
    GameGearStereo : 1;
    clockDiv : 1;
    XNORNoiseMode : 1;
    padding : 3;
};

bitfield AY8910Flags {
    legacyOutput : 1;
    singleOutput : 1;
    discreteOutput : 1;
    RAWOutput : 1;
    YMclockDivLow : 1;
    padding : 3;
};

bitfield OKIM6258Flags {
    clockDiv : 2;
    ADPCMsel : 1;
    outputBitDepth : 1;
    padding : 4;
};

bitfield K054539Flags {
    reverseStereo : 1;
    disableReverb : 1;
    KeyOnUpdate : 1;
    padding : 5;
};

enum AY8190Type : u8 {
    AY8910,
    AY8912,
    AY8913,
    AY8914,
    YM2149 = 0x10,
    YM3439,
    YMZ284,
    YMZ294,
};

enum C140Type : u8 {
    C140_NamcoSystem2,
    C140_NamcoSystem21,
    ASIC219_NamcoNA,
};

struct Gd3 {
    type::Magic<"Gd3 "> ident;
    VGMVersion version;
    u32 Gd3Length;
    std::string::NullString16 trackNameEng;
    std::string::NullString16 trackNameOriginal;
    std::string::NullString16 gameNameEng;
    std::string::NullString16 gameNameOriginal;
    std::string::NullString16 sysNameEng;
    std::string::NullString16 sysNameOriginal;
    std::string::NullString16 trackAuthorEnglish;
    std::string::NullString16 trackAuthorOriginal;
    std::string::NullString16 gameReleaseDate;
    std::string::NullString16 VGMConverter;
    std::string::NullString16 Notes;
};

struct baseHeader {
    type::Magic<"Vgm "> ident;
    u32 eofOffset;
    VGMVersion version;
    u32 SN76489_clk;
    u32 YM2413_clk;
    gd3TagPos = $;
    u32 Gd3Offset;
    u32 sampleCount;
    u32 loopOffset;
    u32 loopSamples;
};

struct Header : baseHeader {
    if (versionValue >= 101) {
        u32 rate;
    } if (versionValue >= 110) {
        u16 SN76489_feedback;
        u8 SN76489_shift_width;
    } if (versionValue >= 151) {
        SN76489Flags snflags;
    } else {
        padding[1];
    } if (versionValue >= 110) {
        u32 YM2612_clk;
        u32 YM2151_clk;
    } if (versionValue >= 150) {
        u32 VGMOffset;
    } if (versionValue >= 151) {
        u32 SegaPCM_clk;
        u32 SegaPCM_reg;
        u32 RF5C68_clk;
        u32 YM2203_clk;
        u32 YM2608_clk;
        u32 YM2610_clk;
        u32 YM3812_clk;
        u32 YM3526_clk;
        u32 Y8950_clk;
        u32 YMF262_clk;
        u32 YMF278B_clk;
        u32 YMF271_clk;
        u32 YMZ280B_clk;
        u32 RF5C164_clk;
        u32 PWM_clk;
        u32 AY8910_clk;
        AY8190Type AY8910_type;
        AY8910Flags AY8910_flags;
        u8 YM2203_flags;
        u8 YM2608_flags;
    } if (versionValue >= 160) {
        u8 volumeMod;
        padding[1];
        u8 loopBase;
    } else {
        padding[3];
    } if (versionValue >= 151) {
        u8 loopMod;
    } if (versionValue >= 161) {
        u32 DMG_clk;
        u32 APU_clk;
        u32 MultiPCM_clk;
        u32 uPD7759_clk;
        u32 OKIM6258_clk;
        OKIM6258Flags OKIM6258_flags;
        K054539Flags K054539_flags;
        C140Type C140_type;
        padding[1];
        u32 OKIM6295_clk;
        u32 K051649_clk;
        u32 K054539_clk;
        u32 HuC6280_clk;
        u32 C140_clk;
        u32 K053260_clk;
        u32 Pokey_clk;
        u32 QSound_clk;
    } if (versionValue >= 171) {
       u32 SCSP_clk;
    } else {
        padding[4];
    } if (versionValue >= 170) {
        u32 extraHeaderOffset;
    } if (versionValue >= 171) {
        u32 WonderSwan_clk;
        u32 VSU_clk;
        u32 SAA1099_clk;
        u32 ES5503_clk;
        u32 ES5005_clk;
        u8 ES5503_ch;
        u8 ES5505_ch;
        u8 C352_clockDiv;
        padding[1];
        u32 X1_010_clk;
        u32 C352_clk;
        u32 GA20_clk;
    } if (versionValue > 172) {
        u32 Mikey_clk;
    }
};

struct chpClkEntry {
    u8 chpID;
    u32 chpClk;
};

struct chpClkHeader {
    u8 entryCount;
    chpClkEntry entries[entryCount];
};

bitfield chpVolume {
    volume : 15;
    absoluteRelative : 1;
};

struct chpVolEntry {
    u8 chpID;
    u8 flags;
    chpVolume chpVol;
};

struct chpVolHeader {
    u8 entryCount;
    chpVolEntry entries[entryCount];
};

struct ExtraHeader {
    u32 headerSize;
    chpClkBase = $;
    u32 chpClkOffset;
    chpVolBase = $;
    u32 chpVolOffset;

    if (chpClkOffset > 0) {
        $ = chpClkBase + chpClkOffset;
        chpClkHeader chpClk;
    } if (chpVolOffset > 0) {
        $ = chpVolBase + chpVolOffset;
        chpVolHeader chpVol;
    }

};

struct VGM {
    Header header;
    if (versionValue >= 170) {
        if (header.extraHeaderOffset > 0) {
            ExtraHeader extraHeader;
        }
    }
    Gd3 tag @ (gd3TagPos + header.Gd3Offset);
};

VGM vgm @ 0x00;
