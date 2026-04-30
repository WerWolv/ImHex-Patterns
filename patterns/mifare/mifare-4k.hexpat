#pragma author Bananz0
#pragma description MIFARE Classic EV1 4K (MF1S70yyX/V1), ISO/IEC 14443-3 Type A
#pragma MIME application/x-mifare-classic
#pragma endian little

// References:
//   NXP MF1S70yyX/V1 Product Data Sheet, Rev. 3.2
//   NXP AN10833, MIFARE type identification procedure, Rev. 3.9
//
// Layout: sectors 0..31 × 4 blocks × 16 bytes (2048 bytes)
//       + sectors 32..39 × 16 blocks × 16 bytes (2048 bytes)
//       = 4096 bytes total, absolute blocks 0..255
// Sector trailer: last block of each sector (block 3 for small, block 15 for large)
// Load this file for 4K dumps (file size exactly 4096 bytes, SAK = 0x18 or 0x38)

import std.core;
import std.io;

// Sector Trailer
// Identical encoding for small and large sectors.
// Byte layout per MF1S70yyX/V1 Rev.3.2 §8.7.1, Figure 10:
//   acc0 (+6): ~C2_3 ~C2_2 ~C2_1 ~C2_0  ~C1_3 ~C1_2 ~C1_1 ~C1_0
//   acc1 (+7):  C1_3  C1_2  C1_1  C1_0  ~C3_3 ~C3_2 ~C3_1 ~C3_0
//   acc2 (+8):  C3_3  C3_2  C3_1  C3_0   C2_3  C2_2  C2_1  C2_0
// For large sectors, Cx_n indexes block groups, not individual blocks:
//   C1_0/C2_0/C3_0: blocks 0-4    C1_1/C2_1/C3_1: blocks 5-9
//   C1_2/C2_2/C3_2: blocks 10-14  C1_3/C2_3/C3_3: trailer (block 15)
//   (MF1S70yyX/V1 Rev.3.2 §8.7.1, Table 6)
// Delivery default: acc0=0xFF acc1=0x07 acc2=0x80 (MF1S70yyX/V1 §8.6.3)

struct SectorTrailer {
    u8 keyA[6];
    u8 acc0;
    u8 acc1;
    u8 acc2;
    u8 userData;
    u8 keyB[6];
};


// Manufacturer Block (absolute block 0, sector 0 only)
// 4-byte NUID layout (MF1S703yX, single cascade level):
//   Bytes 0-3: NUID
//   Byte  4:   BCC = NUID0^NUID1^NUID2^NUID3 (ISO/IEC 14443-3:2018 §6.5.3,
//              stored in block 0 by NXP hardware convention)
//   Byte  5:   SAK (0x18 = native 4K; MF1S70yyX/V1 Rev.3.2 §9.4, Table 12)
//   Bytes 6-7: ATQA, wire order LSByte-first (AN10833 Rev.3.9 §2.3 Note 2)
//              0x0002 = 4-byte NUID 4K  (MF1S703yX)
//              0x0042 = 7-byte UID 4K   (MF1S700yX)
//   Bytes 8-15: Manufacturer data
//              Byte 9 = load modulation status (MF1S70yyX/V1 Rev.3.2 §11, Fig.14)
//              0x20 = strong (default), 0x00 = normal
// Note: 7-byte UID variants (MF1S700yX) have no BCC in block 0; use bytes 0-6 for UID.
// This struct models 4-byte NUID only.

struct ManufacturerBlock {
    u8  uid[4];
    u8  bcc;
    u8  sak;
    u16 atqa;
    u8  manufacturerData[8];
};

// Data Block: 16 bytes (MF1S70yyX/V1 Rev.3.2 §8.6.2)
// Value block mode layout (MF1S70yyX/V1 Rev.3.2 §8.6.2.1, Figure 8):
//   Bytes 0-3:  Value (signed 32-bit LE), 4-7: ~Value, 8-11: Value
//   Bytes 12-15: Addr, ~Addr, Addr, ~Addr

struct DataBlock {
    u8 data[16];
};


// Sector 0: manufacturer block + 2 data blocks + trailer (64 bytes)
// (MF1S70yyX/V1 Rev.3.2 §8.6.2: "Sector 0 contains only two data blocks
// and the read-only manufacturer block")

struct Sector0 {
    ManufacturerBlock manufacturerBlock;
    DataBlock         block1;
    DataBlock         block2;
    SectorTrailer     trailer;
};

// Small Sector (sectors 1..31): 3 data blocks + trailer (64 bytes)

struct SmallSector {
    DataBlock     block0;
    DataBlock     block1;
    DataBlock     block2;
    SectorTrailer trailer;
};

// Large Sector (sectors 32..39): 15 data blocks + trailer (256 bytes)
// (MF1S70yyX/V1 Rev.3.2 §8.6: "8 sectors of 16 blocks")

struct LargeSector {
    DataBlock     block0;
    DataBlock     block1;
    DataBlock     block2;
    DataBlock     block3;
    DataBlock     block4;
    DataBlock     block5;
    DataBlock     block6;
    DataBlock     block7;
    DataBlock     block8;
    DataBlock     block9;
    DataBlock     block10;
    DataBlock     block11;
    DataBlock     block12;
    DataBlock     block13;
    DataBlock     block14;
    SectorTrailer trailer;
};

// MIFARE Classic 4K: sector0 + 31 small + 8 large = 4096 bytes
// 64 + 31×64 + 8×256 = 64 + 1984 + 2048 = 4096

struct MifareClassic4K {
    Sector0     sector0;
    SmallSector smallSectors[31];
    LargeSector largeSectors[8];
};

// Validation


fn validate_uid_bcc(ref MifareClassic4K card) {
    // BCC = XOR of all 4 UID bytes (ISO/IEC 14443-3:2018 §6.5.3)
    // Stored at block 0 byte 4 by NXP hardware convention.
    u8 computed = card.sector0.manufacturerBlock.uid[0] ^
                  card.sector0.manufacturerBlock.uid[1] ^
                  card.sector0.manufacturerBlock.uid[2] ^
                  card.sector0.manufacturerBlock.uid[3];
    if (computed == card.sector0.manufacturerBlock.bcc) {
        std::print("BCC OK: 0x{:02X}", computed);
    } else {
        std::warning(std::format("BCC FAIL: stored=0x{:02X} computed=0x{:02X}",
            card.sector0.manufacturerBlock.bcc, computed));
    }
};

fn validate_sak(ref MifareClassic4K card) {
    // MF1S70yyX/V1 Rev.3.2 §9.4, Table 12: SAK = 0x18
    // AN10833 Rev.3.9 Table 5: 0x38 = SmartMX emulation (0x18|0x20), not native silicon
    // AN10833 Rev.3.9 §3.1: bit 7 of SAK is a proprietary NXP bit (e.g., Originality Check
    // enabled variants) and must be masked out before type identification.
    u8 sak     = card.sector0.manufacturerBlock.sak;
    u8 sak_typ = sak & 0x7F;   // strip proprietary bit 7
    bool prop  = (sak & 0x80) != 0;
    if (sak_typ == 0x18) {
        std::print("SAK 0x{:02X}: MIFARE Classic 4K, native{}", sak,
            prop ? " (bit7 set: NXP proprietary/Originality Check variant)" : "");
    } else if (sak_typ == 0x38) {
        std::warning(std::format("SAK 0x{:02X}: SmartMX/multi-MIFARE emulation of Classic 4K (AN10833 Rev.3.9, Table 5 Examples 2/3){}",
            sak, prop ? " + bit7 set" : ""));
    } else {
        std::warning(std::format("SAK 0x{:02X} (masked: 0x{:02X}): unexpected for Classic 4K", sak, sak_typ));
    }
};

fn validate_access_bits(u8 idx, ref SectorTrailer t) {
    // Three nibble-pair complement invariants (MF1S70yyX/V1 Rev.3.2 §8.7.1):
    //   acc0[3:0] == ~acc1[7:4]   acc0[7:4] == ~acc2[3:0]   acc1[3:0] == ~acc2[7:4]
    u8 a0 = t.acc0; u8 a1 = t.acc1; u8 a2 = t.acc2;
    bool c1 = ((a0 & 0x0F) == ((~a1 >> 4) & 0x0F));
    bool c2 = (((a0 >> 4) & 0x0F) == (~a2 & 0x0F));
    bool c3 = ((a1 & 0x0F) == ((~a2 >> 4) & 0x0F));
    if (c1 && c2 && c3) {
        std::print("Sector {:02d}: Access bits OK  [{:02X} {:02X} {:02X}]", idx, a0, a1, a2);
    } else {
        std::warning(std::format("Sector {:02d}: Access bits FAIL [{:02X} {:02X} {:02X}] C1:{} C2:{} C3:{}",
            idx, a0, a1, a2, c1, c2, c3));
    }
};

// Entry point — unconditional file-scope placement for ImHex visualization

MifareClassic4K card @ 0x00;

validate_uid_bcc(card);
validate_sak(card);
validate_access_bits(0, card.sector0.trailer);
for (u8 i = 1, i <= 31, i += 1) {
    validate_access_bits(i, card.smallSectors[i - 1].trailer);
}
for (u8 j = 0, j < 8, j += 1) {
    validate_access_bits(j + 32, card.largeSectors[j].trailer);
}
