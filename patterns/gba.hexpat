#pragma author GekySan
#pragma description Game Boy Advance ROM Header

#pragma MIME application/x-gameboy-advance-rom
#pragma MIME application/x-agb-rom
#pragma MIME application/x-gba-rom

import std.string;
import std.mem;
import std.sys;

// In gb.hexpat
namespace format {
    fn licensee_code(str code) {
        match(code) {
            ("00"): return "None";
            ("01" | "31"): return "Nintendo";
            ("08" | "38"): return "Capcom";
            ("09"): return "Hot-B";
            ("0A" | "E0"): return "Jaleco";
            ("0B"): return "Coconuts Japan";
            ("0C" | "6E"): return "Elite Systems";
            ("13" | "69"): return "EA (Electronic Arts)";
            ("18"): return "Hudsonsoft";
            ("19"): return "ITC Entertainment";
            ("1A"): return "Yanoman";
            ("1D"): return "Japan Clary";
            ("1F" | "4A" | "61"): return "Virgin Interactive";
            ("24"): return "PCM Complete";
            ("25"): return "San-X";
            ("28"): return "Kotobuki Systems";
            ("29"): return "Seta";
            ("30" | "70"): return "Infogrames";
            ("32" | "A2" | "B2" | "C4"): return "Bandai";
            ("33"): return "See new licensee code";
            ("34" | "A4"): return "Konami";
            ("35"): return "HectorSoft";
            ("39" | "9D"): return "Banpresto";
            ("3C"): return ".Entertainment i";
            ("3E"): return "Gremlin";
            ("41"): return "Ubisoft";
            ("42" | "EB"): return "Atlus";
            ("44" | "4D"): return "Malibu";
            ("46" | "CF"): return "Angel";
            ("47"): return "Spectrum Holoby";
            ("49"): return "Irem";
            ("4F"): return "U.S. Gold";
            ("50"): return "Absolute";
            ("51" | "B0"): return "Acclaim";
            ("52"): return "Activision";
            ("53"): return "American Sammy";
            ("54"): return "GameTek";
            ("55"): return "Park Place";
            ("56" | "DB" | "FF"): return "LJN";
            ("57"): return "Matchbox";
            ("59"): return "Milton Bradley";
            ("5A"): return "Mindscape";
            ("5B"): return "Romstar";
            ("5C" | "D6"): return "Naxat Soft";
            ("5D"): return "Tradewest";
            ("60"): return "Titus";
            ("67"): return "Ocean Interactive";
            ("6F"): return "Electro Brain";
            ("71"): return "Interplay";
            ("72" | "AA"): return "Broderbund";
            ("73"): return "Sculptered Soft";
            ("75"): return "The Sales Curve";
            ("78"): return "t.hq";
            ("79"): return "Accolade";
            ("7A"): return "Triffix Entertainment";
            ("7C"): return "Microprose";
            ("7F" | "C2"): return "Kemco";
            ("80"): return "Misawa Entertainment";
            ("83"): return "Lozc";
            ("86" | "C4"): return "Tokuma Shoten Intermedia";
            ("8B"): return "Bullet-Proof Software";
            ("8C"): return "Vic Tokai";
            ("8E"): return "Ape";
            ("8F"): return "I'Max";
            ("91"): return "Chunksoft Co.";
            ("92"): return "Video System";
            ("93"): return "Tsubaraya Productions Co.";
            ("95"): return "Varie Corporation";
            ("96"): return "Yonezawa/S’Pal";
            ("97"): return "Kaneko";
            ("99"): return "Arc";
            ("9A"): return "Nihon Bussan";
            ("9B"): return "Tecmo";
            ("9C"): return "Imagineer";
            ("9F"): return "Nova";
            ("A1"): return "Hori Electric";
            ("A6"): return "Kawada";
            ("A7"): return "Takara";
            ("A9"): return "Technos Japan";
            ("AC"): return "Toei Animation";
            ("AD"): return "Toho";
            ("AF"): return "Namco";
            ("B1"): return "ASCII or Nexsoft";
            ("B4"): return "Square Enix";
            ("B6"): return "HAL Laboratory";
            ("B7"): return "SNK";
            ("B9" | "CE"): return "Pony Canyon";
            ("BA"): return "Culture Brain";
            ("BB"): return "Sunsoft";
            ("BD"): return "Sony Imagesoft";
            ("BF"): return "Sammy";
            ("C0" | "D0"): return "Taito";
            ("C3"): return "Squaresoft";
            ("C5"): return "Data East";
            ("C6"): return "Tonkinhouse";
            ("C8"): return "Koei";
            ("C9"): return "UFL";
            ("CA"): return "Ultra";
            ("CB"): return "Vap";
            ("CC"): return "Use Corporation";
            ("CD"): return "Meldac";
            ("D1"): return "Sofel";
            ("D2"): return "Quest";
            ("D3"): return "Sigma Enterprises";
            ("D4"): return "ASK Kodansha Co.";
            ("D7"): return "Copya System";
            ("DA"): return "Tomy";
            ("DD"): return "NCS";
            ("DE"): return "Human";
            ("DF"): return "Altron";
            ("E1"): return "Towa Chiki";
            ("E2"): return "Yutaka";
            ("E3"): return "Varie";
            ("E5"): return "Epoch";
            ("E7"): return "Athena";
            ("E8"): return "Asmik";
            ("E9"): return "Natsume";
            ("EA"): return "King Records";
            ("EC"): return "Epic/Sony Records";
            ("EE"): return "IGS";
            ("F0"): return "A Wave";
            ("F3"): return "Extreme Entertainment";
        }
        return "Unknown Licensee";
    };
}

fn calcChecksum() {
    u8 sum = 0;
    u8 offset = 0xA0;

    while (offset <= 0xBC) {
        sum += std::mem::read_unsigned(offset, 1);
        offset += 1;
    }

    return ((-((0x19 + sum) & 0xFF)) & 0xFF) == std::mem::read_unsigned(0xBD, 1);
};

struct GBAHeader {
    u8 entryPoint[4]       [[comment("ARM entry point code, typically a 'B rom_start' instruction")]];
    u8 nintendoLogo[156]   [[comment("Nintendo logo")]];
    char gameTitle[12]     [[comment("Game title, uppercase ASCII, max 12 characters")]];
    char gameCode[4]       [[comment("Game code, uppercase ASCII, 4 characters")]];
    char makerCode[2]      [[format("format::licensee_code"), comment("Maker code, uppercase ASCII, 2 characters")]];
    u8 fixedValue          [[comment("Fixed value, must be 0x96")]];
    u8 unitCode            [[comment("Main unit code, identifies required hardware (00h for GBA)")]];
    u8 deviceType          [[comment("Device type, usually 00h. Bit 7 relates to DACS/debug features")]];
    u8 reserved1[7]        [[comment("Reserved area, must be zero-filled")]];
    u8 softwareVersion     [[comment("Software version number, usually 00h")]];
    u8 complementCheck     [[comment("Header checksum, required for validation")]];
    u8 reserved2[2]        [[comment("Reserved area, must be zero-filled")]];
};


if (!calcChecksum()) {
    std::error("Checksum validation failed: Calculated value does not match the expected checksum in the header.");
}

GBAHeader gbaHeader @ 0x0000;
