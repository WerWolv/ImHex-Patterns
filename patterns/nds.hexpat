#pragma author GekySan
#pragma description DS Cartridge Header

#pragma MIME application/x-nintendo-ds-rom

// History
//      - 0.1  2025-03-17 GekySan: Initial release. Includes only the header structure.
//
// More information available at:
//      - https://problemkaputt.de/gbatek-ds-cartridge-header.htm

enum NDSRegion : u8 {
    Normal                              = 0x00,
    China                               = 0x80,
    Korea                               = 0x40
};

struct NDSHeader {
    u8 gameTitle[12]                    [[comment("Game Title  (Uppercase ASCII, padded with 00h)")]];
    u8 gameCode[4]                      [[comment("Gamecode    (Uppercase ASCII, NTR-<code>)        (0=homebrew)")]];
    u8 makerCode[2]                     [[comment("Makercode   (Uppercase ASCII, eg. '01'=Nintendo) (0=homebrew)")]];
    u8 unitCode                         [[comment("Unitcode    (00h=NDS, 02h=NDS+DSi, 03h=DSi) (bit1=DSi)")]];
    u8 encryptionSeedSelect             [[comment("Encryption Seed Select (00..07h, usually 00h)")]];
    u8 deviceCapacity                   [[comment("Device capacity (Chipsize = 128KB SHL nn) (eg. 7 = 16MB)")]];
    u8 reserved1[7]                     [[comment("Reserved (zero filled)")]];
    u8 reserved2                        [[comment("Reserved (zero) (except used on DSi)")]];
    NDSRegion region                    [[comment("NDS Region (00h=Normal, 80h=China, 40h=Korea) (other on DSi)")]];
    u8 romVersion                       [[comment("ROM Version (usually 00h)")]];
    u8 autoStart                        [[comment("Autostart (Bit2: Skip 'Press Button' after Health and Safety)")]];
    u8 arm9RomOffset[4]                 [[comment("ARM9 rom_offset (4000h and up, align 1000h)")]];
    u8 arm9EntryAddress[4]              [[comment("ARM9 entry_address (2000000h..23BFE00h)")]];
    u8 arm9RamAddress[4]                [[comment("ARM9 ram_address (2000000h..23BFE00h)")]];
    u8 arm9Size[4]                      [[comment("ARM9 size (max 3BFE00h)")]];
    u8 arm7RomOffset[4]                 [[comment("ARM7 rom_offset (8000h and up)")]];
    u8 arm7EntryAddress[4]              [[comment("ARM7 entry_address (2000000h..23BFE00h, or 37F8000h..3807E00h)")]];
    u8 arm7RamAddress[4]                [[comment("ARM7 ram_address (2000000h..23BFE00h, or 37F8000h..3807E00h)")]];
    u8 arm7Size[4]                      [[comment("ARM7 size (max 3BFE00h, or FE00h)")]];
    u8 fntOffset[4]                     [[comment("File Name Table (FNT) offset")]];
    u8 fntSize[4]                       [[comment("File Name Table (FNT) size")]];
    u8 fatOffset[4]                     [[comment("File Allocation Table (FAT) offset")]];
    u8 fatSize[4]                       [[comment("File Allocation Table (FAT) size")]];
    u8 arm9OverlayOffset[4]             [[comment("File ARM9 overlay_offset")]];
    u8 arm9OverlaySize[4]               [[comment("File ARM9 overlay_size")]];
    u8 arm7OverlayOffset[4]             [[comment("File ARM7 overlay_offset")]];
    u8 arm7OverlaySize[4]               [[comment("File ARM7 overlay_size")]];
    u8 portSetting1[4]                  [[comment("Port 40001A4h setting for normal commands")]];
    u8 portSetting2[4]                  [[comment("Port 40001A4h setting for KEY1 commands")]];
    u8 iconTitleOffset[4]               [[comment("Icon/Title offset (0=None) (8000h and up)")]];
    u8 secureAreaChecksum[2]            [[comment("Secure Area Checksum, CRC-16 of [020h]..00007FFFh")]];
    u8 secureAreaDelay[2]               [[comment("Secure Area Delay (in 131kHz units)")]];
    u8 arm9AutoLoadListRamAddress[4]    [[comment("ARM9 Auto Load List Hook RAM Address")]];
    u8 arm7AutoLoadListRamAddress[4]    [[comment("ARM7 Auto Load List Hook RAM Address")]];
    u8 secureAreaDisable[8]             [[comment("Secure Area Disable (by encrypted 'NmMdOnly')")]];
    u8 totalUsedRomSize[4]              [[comment("Total Used ROM size (remaining/unused bytes usually FFh-padded)")]];
    u8 romHeaderSize[4]                 [[comment("ROM Header Size (4000h)")]];
    u8 unknown[4]                       [[comment("Unknown, some rom_offset, or zero? (DSi: slightly different)")]];
    u8 reserved3[8]                     [[comment("Reserved (zero filled; except, [88h..93h] used on DSi)")]];
    u8 nandEndOfRomArea[2]              [[comment("NAND end of ROM area (in 20000h-byte units)")]];
    u8 nandStartOfRWArea[2]             [[comment("NAND start of RW area (usually both same address)")]];
    u8 reserved4[0x18]                  [[comment("Reserved (zero filled)")]];
    u8 reserved5[0x10]                  [[comment("Reserved (zero filled; or 'DoNotZeroFillMem'=unlaunch fastboot)")]];
    u8 nintendoLogo[0x9C]               [[comment("Nintendo Logo (compressed bitmap, same as in GBA Headers)")]];
    u8 nintendoLogoChecksum[2]          [[comment("Nintendo Logo Checksum, CRC-16 of [0C0h-15Bh], fixed CF56h")]];
    u8 headerChecksum[2]                [[comment("Header Checksum, CRC-16 of [000h-15Dh]")]];
    u8 debugRomOffset[4]                [[comment("Debug rom_offset (0=none) (8000h and up)")]];
    u8 debugSize[4]                     [[comment("Debug size (0=none) (max 3BFE00h)")]];
    u8 debugRamAddress[4]               [[comment("Debug ram_address (0=none) (2400000h..27BFE00h)")]];
    u8 reserved6[4]                     [[comment("Reserved (zero filled) (transferred, and stored, but not used)")]];
    u8 reserved7[0x90]                  [[comment("Reserved (zero filled) (transferred, but not stored in RAM)")]];
    u8 reserved8[0xE00]                 [[comment("Reserved (zero filled) (usually not transferred)")]];
};

NDSHeader NDSHeader @ 0x0000;
