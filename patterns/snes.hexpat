#pragma author gmestanley
#pragma description SNES ROM header
#pragma sources snes.nesdev.org/wiki/ROM_header CPU_vectors en.wikibooks.org/wiki/Super_NES_Programming/SNES_memory_map

import std.string;

u24 headerPosition = 0x7FC0;

fn calculateHeaderPosition() {    
    if (std::mem::size() > 0x20000 && std::mem::size() < 0x600000) headerPosition += 0x8000;
    else if (std::mem::size() >= 0x600000) headerPosition += 0x400000;
};
calculateHeaderPosition();

enum ChipsetSubtype : u8 {
    SPC7110,
    ST01x,
    ST018,
    CX4
};

struct ExpandedHeader {
    char makerID[2];
    char gameID[4];
    padding[6];
    u8 expansionFlashSize [[comment("1 << N")]];
    u8 expansionRAMSize [[comment("1 << N")]];
    u8 specialVersion;
    ChipsetSubtype chipsetSubtype;
};

struct ConditionalStruct {
    if ($[headerPosition+0x1A] == 0x33) ExpandedHeader expandedHeader @ headerPosition - 0x10;
    else if (!$[headerPosition+0x14]) ChipsetSubtype chipsetSubtype @ headerPosition - 1;
} [[inline]];

ConditionalStruct conditionalStruct @ $;

enum MappingMode : u8 {
    LoROM,
    HiROM,
    ExHiROM = 5
};

fn formatMappingMode(u8 value) {
    MappingMode enumValue = value;
    return enumValue;
};

bitfield ROMType {
    mappingMode : 4 [[format("formatMappingMode")]];
    speed : 1;
    unknown : 1;
};

enum CoprocessorType : u8 {
    DSP,
    GSU,
    OBC1,
    SA1,
    SDD1,
    SRTC,
    Other = 0x0E,
    Custom
};

fn formatExtraHardwareType(u8 value) {
    str valueMeaning = " (ROM";
    if (!value) valueMeaning += " only";
    else if (value) {
        if (value > 3) valueMeaning += " + coprocessor";
        if (value != 3 || value != 6) valueMeaning += " + RAM";
        if (value == 2 || value > 5) valueMeaning += " + battery";
    }
    return std::string::to_string(value) + valueMeaning + ")";
};

fn formatCoprocessorType(u8 value) {
    CoprocessorType enumValue = value;
    return enumValue;
};

bitfield ExtraHardware {
    extraHardwareType : 4 [[format("formatExtraHardwareType")]];
    coprocessorType : 4 [[format("formatCoprocessorType")]];
};

enum Country : u8 {
    NTSC = 1,
    PAL
};

struct Header {
    char title[21];
    ROMType romType;
    ExtraHardware extraHardware;
    u8 romSize [[comment("1 << N, rounded up")]];
    u8 ramSize [[comment("1 << N")]];
    Country country;
    u8 developerID;
    u8 romVersion;
    u16 checksumComplement;
    u16 checksum;
    padding[4];
    u16 vectors[6];
    padding[4];
    u16 emulationModeVectors[6];
};

Header header @ headerPosition;