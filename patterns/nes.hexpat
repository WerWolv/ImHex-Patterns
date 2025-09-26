#pragma author gmestanley
#pragma description Nintendo Entertainment System ROM (.nes)
#pragma MIME application/x-nes-rom

import std.string;

bitfield Flags {
    mirroringIsHorizontal : 1;
    ignoreMirroring : 1;
    batterybackedPRGRAM : 1;
    trainerOf512Bytes : 1;
    lowerMapperNybble : 4;
};

enum ConsoleType : u8 {
    Regular,
    VsSystem,
    PlayChoice10,
    ExtendedConsoleType
};

fn consoleType(u8 bits) {
    ConsoleType type = bits;
    return type;
};

fn nes2Format(u8 bits) {
    return std::string::to_string(bits == 2) + " (" + std::string::to_string(bits) + ")";
};

bitfield iNESFlags7 {
    consoleType : 2 [[format("consoleType")]];
    nes2Format : 2 [[format("nes2Format"), name("nes2.0Format")]];
    higherMapperNybble : 4;
};

bitfield iNESFlags9 {
    tvSystem : 1 [[comment("0 = NTSC, 1 = PAL")]];
    padding : 7;
};

fn formatDualTVSystem(u8 bits) {
    match (bits) {
    (0): return "NTSC";
    (2): return "PAL";
    (1 || 3): return "Dual Compatible";
    }
};

bitfield iNESFlags10 {
    dualTVSystem : 2 [[format("formatDualTVSystem")]];
    padding : 2;
    prgRAM : 1;
    busConflicts : 1;
};

bitfield MapperExtra {
    highestMapperNybble : 4;
    submapper : 4;
};

bitfield ROMSize {
    extraPRGROMSize : 4;
    extraCHRROMSize : 4;
};

bitfield PRGRAMSize {
    prgRAMShiftCount : 4;
    eepromShiftCount : 4 [[comment("EEPROM = Non-volatile PRG RAM")]];
};

bitfield CHRRAMSize {
    chrRAMSizeShiftCount : 4;
    chrNVRAMSizeShiftCount : 4;
};

enum TimingList : u8 {
    NTSC,
    PAL,
    MultiRegion,
    Dendy
};

fn Timing(u8 value) {
    TimingList type = value;
    return type;
};

bitfield Timing {   
    processorTiming : 2 [[format("Timing")]];
    padding : 6;
};

bitfield VsSystemType {
    vsPPUType : 4;
    vsHardwareType: 4;
};

enum ExtendedConsoleType : ConsoleType {
    DecimalModeFamiclone = 3,
    PlugThrough,
    VT01,
    VT02,
    VT03,
    VT09,
    VT32,
    VT3xx,
    UM6578,
    FamicomNetworkSystem
};

fn formatExtendedConsoleType(u8 nybble) {
    ExtendedConsoleType type = nybble;
    return type;
};

bitfield ExtendedConsoleTypeByte {
    type : 4 [[format("formatExtendedConsoleType")]];
    padding : 4;
};

bitfield MiscellaneousROMs {
    numberOfMiscellaneousROMs : 2;
    padding : 6;
};
    
bitfield DefaultExpansionDevice {
    defaultExpansionDevice : 6;
};

struct NES2Attributes {
    MapperExtra mapperExtra;
    ROMSize romSize;
    PRGRAMSize prgRAMSize;
    CHRRAMSize chrRAMSize;
    Timing timing;
    if (parent.inesFlags7.consoleType == ConsoleType::VsSystem) {
        VsSystemType vsSystemType;
    }
    else if (parent.inesFlags7.consoleType == ConsoleType::ExtendedConsoleType) {
        ExtendedConsoleTypeByte ExtendedConsoleTypeByte;
    }
    else {
        padding[1];
    }
    MiscellaneousROMs miscellaneousROMs;
    DefaultExpansionDevice defaultExpansionDevice;
};

fn renderEOF(str string) {
    return "\"NES<EOF>\"";
};

struct Header {
    char identifier[4] [[format("renderEOF")]];
    u8 prgROMSizeBy16KiBs;
    u8 chrROMSizeBy8KiBs;
    Flags flags;
    if ($[0x07] & 12 != 4) {
        iNESFlags7 inesFlags7;
        if (inesFlags7.nes2Format)
            NES2Attributes nes2Attributes;
        else if ($[0x07] & 12 == 0 && !std::mem::read_unsigned($, 4)) {
            u8 prgRAMSizeBy8KiBs;
            iNESFlags9 inesFlags9;
            iNESFlags10 inesFlags10;
        }
    }
};

Header header @ 0x00;

u8 trainer[512*header.flags.trainerOf512Bytes] @ 0x10;

enum CHRType : u8 {
    CHRROM,
    CHRRAM
};

fn chrType(u8 value) {
    CHRType enumValue = value;
    return enumValue;
};

fn chrSize(u8 value) {
    u24 actualSize;
    if (value == 4) actualSize = 262144;
    else actualSize = 8192 * header.chrROMSizeBy8KiBs;
    return std::string::to_string(value) + " (" + std::string::to_string(actualSize) + ")";
};

bitfield MemorySize {
    prgROMSizeBy16KiBs : 4;
    chrType : 1 [[format("chrType")]];
    chrSize : 3 [[format("chrSize")]];
};

enum ArrangementList : u8 {
    Horizontal,
    Vertical
};

fn arrangement(u8 value) {
    ArrangementList enumValue = value;
    return enumValue;
};

enum MapperList : u8 {
    NROM,
    CNROM,
    UNROM,
    GNROM,
    MMC
};

fn mapper(u8 value) {
    MapperList enumValue = value;
    return enumValue;
};

bitfield CartridgeType {
    nametableArrangement : 1 [[format("arrangement")]];
    mapper : 7 [[format("mapper")]];
};

enum EncodingType : u8 {
    None,
    ASCII,
    JIS
};

fn titleLength(u8 value) { return value+1; };

struct OfficialHeader {
    char title[16] [[hex::spec_name("Title Registration Area")]];
    u16 programChecksum;
    u16 characterChecksum;
    MemorySize memorySize [[hex::spec_name("Cartridge Memory Size")]];
    CartridgeType cartridgeType;
    EncodingType encodingType [[hex::spec_name("Registration Characters Type Distinction")]];
    u8 titleLength [[hex::spec_name("Registration Characters Count"), transform("titleLength")]];
    u8 licenseeID [[hex::spec_name("Maker Code")]];
    u8 complementaryChecksum [[hex::spec_name("Checksum for characterChecksum~makerID")]];
};

u24 calculatedPRGROMSize = 16384 * ((0x0100 * $[9] & 0x0F) * ($[7] & 12 == 8) + header.prgROMSizeBy16KiBs);

fn hasOfficialHeader() {
    u8 sum;
    for (u8 i = 0, i < 8, i += 1) {
        sum += $[(calculatedPRGROMSize - 14) + i];
    }
    return !sum;
};

struct PRGROM {
    u8 data[calculatedPRGROMSize - 26 * hasOfficialHeader() - 6];
    if (hasOfficialHeader())
        OfficialHeader officialHeader;
    u16 nmi;
    u16 resetVector [[comment("Entry Point")]];
    u16 externalIRQ;
};

PRGROM prgROM @ 0x10 + sizeof(trainer);
u8 chrROM[8192 * ((0x0100 * $[9] >> 4) * ($[7] & 12 == 8) + header.chrROMSizeBy8KiBs)] @ addressof(prgROM) + 16384 * header.prgROMSizeBy16KiBs;
