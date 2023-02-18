#include <type/size.pat>
#include <std/io.pat>
#include <std/string.pat>

namespace format {
    
    fn rom_type(u8 romType) {
        u32 romSize = 32768 * (1 << romType);
        u16 romBanks = 2 * (1 << romType);
        if(romType == 0x52) {
            romSize = 1153434;
            romBanks = 72;
        } 
        if(romType == 0x53) {
            romSize = 1258291;
            romBanks = 80;
        } 
        return std::format("size: {}, banks: {}", type::impl::size_formatter(romSize), romBanks);
    };
    
    fn ram_type(u8 ramType) {
        u16 ramSize;
        u16 ramBanks;
        if(ramType == 2) {
            ramSize = 8192;
            ramBanks = 1;
        }
        if(ramType == 3) {
            ramSize = 32768;
            ramBanks = 4;
        }
        if(ramType == 4) {
            ramSize = 131072;
            ramBanks = 16;
        }
        if(ramType == 5) {
            ramSize = 65536;
            ramBanks = 8;
        }
        return std::format("size: {}, banks: {}", type::impl::size_formatter(ramSize), ramBanks);
    };
    
    fn rom_features(u8 type) {
        str result = "( ";
        match(type) {
            (0x00): result += "no_mbc ";
            (0x01): result += "mbc1 ";
            (0x02): result += "mbc1 | ram "; 
            (0x03): result += "mbc1 | ram | battery ";
            (0x05): result += "mbc2 "; 
            (0x06): result += "mbc2 | battery ";
            (0x08): result += "no_mbc | ram "; 
            (0x09): result += "no_mbc | ram | battery ";
            (0x0B): result += "mmm01 "; 
            (0x0C): result += "mmm01 | ram ";
            (0x0D): result += "mmm01 | ram | battery "; 
            (0x0F): result += "mbc3 | timer | battery ";
            (0x10): result += "mbc3 | timer | ram | battery "; 
            (0x11): result += "mbc3 ";
            (0x12): result += "mbc3 | ram "; 
            (0x13): result += "mbc3 | ram | battery ";
            (0x19): result += "mbc5 "; 
            (0x1A): result += "mbc5 | ram ";
            (0x1B): result += "mbc5 | ram | battery "; 
            (0x1C): result += "mbc5 | rumble ";
            (0x1D): result += "mbc5 | rumble | ram "; 
            (0x1E): result += "mbc5 | rumble | ram | battery ";
            (0x20): result += "mbc6 "; 
            (0x22): result += "mbc7 | sensor | rumble ";
            (0xFC): result += "camera "; 
            (0xFD): result += "tama5 ";
            (0xFE): result += "huc3 "; 
            (0xFF): result += "huc1 | ram | battery ";
        }
        return result + ")"; 
    };
    
    fn licensee_code(u8 code) {
        match(code) {
            (0x00): return "None";
            (0x01 | 0x31): return "Nintendo";
            (0x08 | 0x38): return "Capcom";
            (0x09): return "Hot-B";
            (0x0A | 0xE0): return "Jaleco";
            (0x0B): return "Coconuts Japan";
            (0x0C | 0x6E): return "Elite Systems";
            (0x13 | 0x69): return "EA (Electronic Arts)";
            (0x18): return "Hudsonsoft";
            (0x19): return "ITC Entertainment";
            (0x1A): return "Yanoman";
            (0x1D): return "Japan Clary";
            (0x1F | 0x4A | 0x61): return "Virgin Interactive";
            (0x24): return "PCM Complete";
            (0x25): return "San-X";
            (0x28): return "Kotobuki Systems";
            (0x29): return "Seta";
            (0x30 | 0x70): return "Infogrames";
            (0x32 | 0xA2 | 0xB2 | 0xC4): return "Bandai";
            (0x33): return "See new licensee";
            (0x34 | 0xA4): return "Konami";
            (0x35): return "HectorSoft";
            (0x39 | 0x9D): return "Banpresto";
            (0x3C): return ".Entertainment i";
            (0x3E): return "Gremlin";
            (0x41): return "Ubisoft";
            (0x42 | 0xEB): return "Atlus";
            (0x44 | 0x4D): return "Malibu";
            (0x46 | 0xCF): return "Angel";
            (0x47): return "Spectrum Holoby";
            (0x49): return "Irem";
            (0x50): return "Absolute";
            (0x51 | 0xB0): return "Acclaim";
            (0x52): return "Activision";
            (0x53): return "American Sammy";
            (0x54): return "GameTek";
            (0x55): return "Park Place";
            (0x56 | 0xDB | 0xFF): return "LJN";
            (0x57): return "Matchbox";
            (0x59): return "Milton Bradley";
            (0x5A): return "Mindscape";
            (0x5B): return "Romstar";
            (0x5C | 0xD6): return "Naxat Soft";
            (0x5D): return "Tradewest";
            (0x60): return "Titus";
            (0x67): return "Ocean Interactive";
            (0x6F): return "Electro Brain";
            (0x71): return "Interplay";
            (0x72 | 0xAA): return "Broderbund";
            (0x73): return "Sculptered Soft";
            (0x75): return "The Sales Curve";
            (0x78): return "t.hq";
            (0x79): return "Accolade";
            (0x7A): return "Triffix Entertainment";
            (0x7C): return "Microprose";
            (0x7F | 0xC2): return "Kemco";
            (0x80): return "Misawa Entertainment";
            (0x83): return "Lozc";
            (0x86 | 0xC4): return "Tokuma Shoten Intermedia";
            (0x8B): return "Bullet-Proof Software";
            (0x8C): return "Vic Tokai";
            (0x8E): return "Ape";
            (0x8F): return "I'Max";
            (0x91): return "Chunksoft Co.";
            (0x92): return "Video System";
            (0x93): return "Tsubaraya Productions Co.";
            (0x95): return "Varie Corporation";
            (0x96): return "Yonezawa/S’Pal";
            (0x97): return "Kaneko";
            (0x99): return "Arc";
            (0x9A): return "Nihon Bussan";
            (0x9B): return "Tecmo";
            (0x9C): return "Imagineer";
            (0x9F): return "Nova";
            (0xA1): return "Hori Electric";
            (0xA6): return "Kawada";
            (0xA7): return "Takara";
            (0xA9): return "Technos Japan";
            (0xAC): return "Toei Animation";
            (0xAD): return "Toho";
            (0xAF): return "Namco";
            (0xB1): return "ASCII or Nexsoft";
            (0xB4): return "Square Enix";
            (0xB6): return "HAL Laboratory";
            (0xB7): return "SNK";
            (0xB9 | 0xCE): return "Pony Canyon";
            (0xBA): return "Culture Brain";
            (0xBB): return "Sunsoft";
            (0xBD): return "Sony Imagesoft";
            (0xBF): return "Sammy";
            (0xC0 | 0xD0): return "Taito";
            (0xC3): return "Squaresoft";
            (0xC5): return "Data East";
            (0xC6): return "Tonkinhouse";
            (0xC8): return "Koei";
            (0xC9): return "UFL";
            (0xCA): return "Ultra";
            (0xCB): return "Vap";
            (0xCC): return "Use Corporation";
            (0xCD): return "Meldac"; 
            (0xD1): return "Sofel";
            (0xD2): return "Quest";
            (0xD3): return "Sigma Enterprises";
            (0xD4): return "ASK Kodansha Co.";
            (0xD7): return "Copya System";
            (0xDA): return "Tomy";
            (0xDD): return "NCS";
            (0xDE): return "Human";
            (0xDF): return "Altron";
            (0xE1): return "Towa Chiki";
            (0xE2): return "Yutaka";
            (0xE3): return "Varie";
            (0xE5): return "Epoch";
            (0xE7): return "Athena";
            (0xE8): return "Asmik";
            (0xE9): return "Natsume";
            (0xEA): return "King Records";
            (0xEE): return "IGS";
            (0xF0): return "A Wave";
            (0xF3): return "Extreme Entertainment";
        }
        return "Unknown Licensee";
    };
    
    fn new_licensee_code(str a) {        
        if(a[0] == 0 && a[1] == 0) return "See old licensee";
        match(a) {
            ("00"): return "None";
            ("01"): return "Nintendo R&D1";
            ("08"): return "Capcom";
            ("13"): return "Electronic Arts";
            ("18"): return "Hudson Soft";
            ("19"): return "b-ai";
            ("20"): return "kss";
            ("22"): return "pow";
            ("24"): return "PCM Complete";
            ("25"): return "san-x";
            ("28"): return "Kemco Japan";
            ("29"): return "seta";
            ("30"): return "Viacom";
            ("31"): return "Nintendo";
            ("32"): return "Bandai";
            ("33"): return "Ocean/Acclaim";
            ("34"): return "Konami";
            ("35"): return "Hector";
            ("37"): return "Taito";
            ("38"): return "Hudson";
            ("39"): return "Banpresto";
            ("41"): return "Ubi Soft";
            ("42"): return "Atlus";
            ("44"): return "Malibu";
            ("46"): return "angel";
            ("47"): return "Bullet-Proof";
            ("49"): return "irem";
            ("50"): return "Absolute";
            ("51"): return "Acclaim";
            ("52"): return "Activision";
            ("53"): return "American sammy";
            ("54"): return "Konami";
            ("55"): return "Hi tech entertainment";
            ("56"): return "LJN";
            ("57"): return "Matchbox";
            ("58"): return "Mattel";
            ("59"): return "Milton Bradley";
            ("60"): return "Titus";
            ("61"): return "Virgin";
            ("64"): return "LucasArts";
            ("67"): return "Ocean";
            ("69"): return "Electronic Arts";
            ("70"): return "Infogrames";
            ("71"): return "Interplay";
            ("72"): return "Broderbund";
            ("73"): return "sculptured";
            ("75"): return "sci";
            ("78"): return "THQ";
            ("79"): return "Accolade";
            ("80"): return "misawa";
            ("83"): return "lozc";
            ("86"): return "Tokuma Shoten Intermedia";
            ("87"): return "Tsukuda Original";
            ("91"): return "Chunksoft";
            ("92"): return "Video system";
            ("93"): return "Ocean/Acclaim";
            ("95"): return "Varie";
            ("96"): return "Yonezawa/s’pal";
            ("97"): return "Kaneko";
            ("99"): return "Pack in soft";
            ("A4"): return "Konami (Yu-Gi-Oh!)";
        }
        return "Unknown";
    };
}

bitfield pixel_packed {
    p1 : 1;
    p2 : 1;
    p3 : 1;
    p4 : 1;
    p5 : 1;
    p6 : 1;
    p7 : 1;
    p8 : 1;
};

enum CGB : u8 {
    NO_CGB = 0x00 ... 0x7F,
    BACKWARDS_COMPATIBLE = 0x80,
    CGB_ONLY = 0xC0
};

  
struct Logo {
    pixel_packed rawData[0x30];
};

struct JumpVectors {
    u8 rst1[8] [[comment("rst $1")]];
    u8 rst2[8] [[comment("rst $2")]];
    u8 rst3[8] [[comment("rst $3")]];
    u8 rst4[8] [[comment("rst $4")]];
    u8 rst5[8] [[comment("rst $5")]];;
    u8 rst6[8] [[comment("rst $6")]];
    u8 rst7[8] [[comment("rst $7")]];
    u8 rst8[8] [[comment("rst $8")]];
    u8 int1[8] [[comment("vblank")]];
    u8 int2[8] [[comment("lcd stat")]];
    u8 int3[8] [[comment("timer")]];
    u8 int4[8] [[comment("serial")]];
    u8 int5[8] [[comment("joypad")]];
};
    
struct Header {
    u32 jmpInstruction;
    Logo logo;
    char title[0xF];
    CGB cgb;
    char newLicenseeCode[2] [[format("format::new_licensee_code")]];
    bool sgbFlag;
    u8 type [[format("format::rom_features")]];
    u8 romType [[format("format::rom_type")]];
    u8 ramType [[format("format::ram_type")]];
    bool japanOnly;
    u8 licenseeCode [[format("format::licensee_code")]];
    u8 version;
    u8 checksum [[comment("Checksum for: $134-$14C")]];
    u16 gloalChecksum [[comment("Checksum for entire range")]];
};

struct Cartrige {
    JumpVectors jumpVectors [[comment("Instructions called on interupts or rst instructions")]];
    padding[0x100 - sizeof(JumpVectors)];
    Header header;
};


Cartrige cart @ 0x00;