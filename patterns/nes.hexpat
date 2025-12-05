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
} [[inline]];

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

u24 calculatedPRGROMSize = 16384 * ((0x0100 * ($[9] & 0x0F)) * ($[7] & 12 == 8) + header.prgROMSizeBy16KiBs);

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
u8 chrROM[8192 * ((0x0100 * ($[9] >> 4)) * ($[7] & 12 == 8) + header.chrROMSizeBy8KiBs)] @ addressof(prgROM) + 16384 * header.prgROMSizeBy16KiBs;

fn identifyMapper(u16 mapperValue, u8 submapperValue) {
    str mapper;
    str submapper;
    str designation;
    match (mapperValue) {
        (0): mapper = "NROM";
        (1): mapper = "MMC1B";
        (2): mapper = "UxROM";
        (3): mapper = "CNROM-32";
        (4): mapper = "MMC3";
        (5): mapper = "MMC5";
        (6): mapper = "Front Fareast Magic Card 1/2M RAM Cartridge";
        (7): mapper = "AxROM";
        (8): mapper = "Front Fareast Magic Card 1/2M RAM Cartridge (Initial latch-based banking mode 4)";
        (9): mapper = "MMC2";
        (10): mapper = "MMC4";
        (11): mapper = "Color Dreams";
        (12): mapper = "(See submapper)";
        (13): mapper = "CPROM";
        (14): mapper = "SL-1632";
        (15): mapper = "K-102xx";
        (16): mapper = "Bandai FCG boards";
        (17): mapper = "Front Fareast Super Magic Card RAM cartridge";
        (18): mapper = "SS88006 (Jaleco)";
        (19): mapper = "Namco 129/163";
        (20): mapper = "Famicom Disk System";
        (21): mapper = "VRC4a/VRC4c";
        (22): mapper = "VRC2a";
        (23): mapper = "VRC4e or VRC2b + VRC4f";
        (24): mapper = "VRC6a";
        (25): mapper = "VRC4d or VRC2c + VRC4b";
        (26): mapper = "VRC6b";
        (27): mapper = "World Hero";
        (28): mapper = "Action 53";
        (29): mapper = "RET-CUFROM";
        (30): mapper = "UNROM 512";
        (31): mapper = "NSF";
        (32): mapper = "G-101";
        (33): mapper = "TC0190";
        (34): mapper = "(See submapper)";
        (35): mapper = "J.Y. Company (8KiB WRAM)";
        (36): mapper = "01-22000-400";
        (37): mapper = "SMB+Tetris+NWC";
        (38): mapper = "Crime Busters";
        (39): mapper = "Study & Game 32-in-1";
        (40): mapper = "NTDEC 27xx";
        (41): mapper = "Caltron 6-in-1";
        (42): mapper = "FDS -> NES Hacks";
        (43): mapper = "TONY-I/YS-612";
        (44): mapper = "Super Big 7-in-1";
        (45): mapper = "GA23C";
        (46): mapper = "Rumble Station";
        (47): mapper = "Super Spike V'Ball + NWC";
        (48): mapper = "TC0690";
        (49): mapper = "Super HIK 4-in-1";
        (50): mapper = "761214";
        (51): mapper = "11-in-1 Ball Games";
        (52): mapper = "Realtec 8213";
        (53): mapper = "Supervision 16-in-1";
        (54): mapper = "Novel Diamond 9999999-in-1";
        (55): mapper = "QFJ";
        (56): mapper = "KS202";
        (57): mapper = "GK";
        (58): mapper = "WQ";
        (59): mapper = "T3H53";
        (60): mapper = "Reset-based NROM-128 4-in-1";
        (61): mapper = "(See submapper)";
        (62): mapper = "Super 700-in-1";
        (63): mapper = "(See submapper)";
        (64): mapper = "RAMBO-1";
        (65): mapper = "H3001";
        (66): mapper = "GxROM";
        (67): mapper = "Sunsoft-3";
        (68): mapper = "Sunsoft-4";
        (69): mapper = "Sunsoft FME-7/Sunsoft 5A/Sunsoft 5B";
        (70): mapper = "Family Trainer Mat";
        (71): mapper = "Camerica";
        (72): mapper = "JF-17";
        (73): mapper = "VRC3";
        (74): mapper = "860908C";
        (75): mapper = "VRC1";
        (76): mapper = "NAMCOT-3446";
        (77): mapper = "Napoleon Senki";
        (78): mapper = "74HC161/32";
        (79): mapper = "NINA-003/NINA-006";
        (80): mapper = "X1-005";
        (81): mapper = "N715021";
        (82): mapper = "X1-017";
    }
    if (mapperValue == 3) {
        match (submapperValue) {
            (0): submapper = "Bus conflict";
            (1): submapper = "No bus conflicts";
            (2): submapper = "AND-type bus conflicts";
        }
    }
    else if (mapperValue == 4) designation = "TxROM";
    else if (mapperValue == 12) {
        match (submapperValue) {
            (0): submapper = "SL-5020B (Gouder)";
            (1): submapper = "Front Fareast Magic Card 4M RAM Cartridge";
        }
    }
    else if (mapperValue == 16) {
        match (submapperValue) {
            (0): submapper = "FCG-1/2 or LZ93D50";
            (4): submapper = "FCG-1/2";
            (5): submapper = "LZ93D50";
        }
    }
    else if (mapperValue == 34) {
        match (submapperValue) {
            (0): submapper = "NINA-001/NINA-002";
            (1): submapper = "BNROM";
        }
    }
    else if (mapperValue == 40) {
        match (submapperValue) {
            (0): submapper = "NTDEC 2722";
            (1): submapper = "NTDEC 2752";
        }
    }
    else if (mapperValue == 61) {
        match (submapperValue) {
            (0): submapper = "NTDEC 0324";
            (1): submapper = "NTDEC BS-N032";
            (_): submapper = "GS-2017";
        }
    }
    else if (mapperValue == 63) {
        match (submapperValue) {
            (0): submapper = "TH2291-3";
            (1): submapper = "82AB";
        }
    }
    std::print("Mapper: " + mapper + "(" + std::string::to_string(mapperValue) + ")");
    if (submapper) std::print("Submapper: " + submapper + "(" + std::string::to_string(submapperValue) + ")");
    if (designation) std::print("Designation: " + designation);
};
identifyMapper(0x0100 * ($[8] & 0x0F) + 0x10 * ($[7] & 0x0F) + header.flags.lowerMapperNybble, $[8] >> 4);
