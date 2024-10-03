#pragma author WerWolv
#pragma description USB Flashing Format (.uf2)

import std.sys;
import std.mem;

#pragma MIME application/microformats+json
#pragma MIME application/microformats2+json
#pragma MIME application/mf2+json
#pragma MIME application/uf2+json

#pragma pattern_limit 100000

bitfield UF2_Flags {
	NotMainFlash : 1;
	padding : 11;
	FileContainer : 1;
	FamilyIDPresent : 1;
	MD5ChecksumPresent : 1;
	ExtensionTagsPresent : 1;
	padding : 16;
};

struct UF2_Hash {
	u32 startAddress;
	u32 size;
	u8 md5Checksum[16];
} [[static]];

struct UF2_TagType {
	u8 bytes[3];
} [[format("formatTagType")]];

enum UF2_TagTypeEnum : u32 {
	FirmwareFileVersion 	= 0x9FC7BC,
	DeviceDescription 		= 0x650D9D,
	TargetPageSize 			= 0x0BE9F7,
	SHA1Checksum 			= 0xB46DB0,
	DeviceTypeIdentifier 	= 0xC8A729
};

// reference: https://microsoft.github.io/uf2/utils/uf2families.json

enum UF2_FamilyID : u32 {
    ATMEGA32        = 0x16573617,
    SAML21          = 0x1851780a,
    NRF52           = 0x1b57745f,
    ESP32           = 0x1c5f21b0,
    STM32L1         = 0x1e1f432d,
    STM32L0         = 0x202e3a91,
    STM32WL         = 0x21460ff0,
    LPC55           = 0x2abc77ec,
    STM32G0         = 0x300f5633,
    GD32F350        = 0x31d228c6,
    STM32L5         = 0x04240bdf,
    STM32G4         = 0x4c71240a,
    MIMXRT10XX      = 0x4fb2d5bd,
    STM32F7         = 0x53b80f00,
    SAMD51          = 0x55114460,
    STM32F4         = 0x57755a57,
    FX2             = 0x5a18069b,
    STM32F2         = 0x5d1a0a2e,
    STM32F1         = 0x5ee21072,
    NRF52833        = 0x621e937a,
    STM32F0         = 0x647824b6,
    SAMD21          = 0x68ed2b88,
    STM32F3         = 0x6b846188,
    STM32F407       = 0x6d0922fa,
    STM32H7         = 0x6db66082,
    STM32WB         = 0x70d16653,
    KL32L2          = 0x7f83e793,
    STM32F407VG     = 0x8fb060fe,
    NRF52840        = 0xada52840,
    ESP32S2         = 0xbfdd4eee,
    ESP32S3         = 0xc47e5767,
    ESP32C3         = 0xd42ba06c,
    ESP32C2         = 0x2b88d29c,
    ESP32H2         = 0x332726f6,
    ESP32C6         = 0x540ddf62,
    ESP32P4         = 0x3d308e94,
    ESP32C5         = 0xf71c0343,
    ESP32C61        = 0x77d850c4,
    RP2040          = 0xe48bff56,
    RP2XXX_ABSOLUTE = 0xe48bff57,
    RP2XXX_DATA     = 0xe48bff58,
    RP2350_ARM_S    = 0xe48bff59,
    RP2350_RISCV    = 0xe48bff5a,
    RP2350_ARM_NS   = 0xe48bff5b,
    STM32L4         = 0x00ff6919,
    GD32VF103       = 0x9af03e33,
    CSK4            = 0x4f6ace52,
    CSK6            = 0x6e7348a8,
    M0SENSE         = 0x11de784a,
    MaixPlayU4      = 0x4b684d71,
    RZA1LU          = 0x9517422f,
    STM32F411xE     = 0x2dc309c5,
    NRF52832xxAA    = 0x72721d4e,
    NRF52832xxAB    = 0x6f752678,
    AT32F415        = 0xa0c97b8e,
    CH32V           = 0x699b62ec,
    RA4M1           = 0x7be8976d,
    RTL8710A        = 0x9fffd543,
    RTL8710B        = 0x22e0d6fc,
    RTL8720C        = 0xe08f7564,
    RTL8720D        = 0x3379CFE2,
    XR809           = 0x51e903a8,
    BK7231U         = 0x675a40b0,
    BK7251          = 0x6a82cc42,
    BK7231N         = 0x7b3ef230,
    BL602           = 0xde1270b7,
};

fn formatTagType(UF2_TagType type) {
	u32 value = (type.bytes[0] << 16) | (type.bytes[1] << 8) | (type.bytes[2]);

	if (value == UF2_TagTypeEnum::FirmwareFileVersion)
		return "Firmware File Version";
	else if (value == UF2_TagTypeEnum::DeviceDescription)
		return "Device Description";
	else if (value == UF2_TagTypeEnum::TargetPageSize)
		return "Target Page Size";
	else if (value == UF2_TagTypeEnum::SHA1Checksum)
		return "SHA1 Checksum";
	else if (value == UF2_TagTypeEnum::DeviceTypeIdentifier)
		return "Device Type Identifier";
	else
		return "Custom Type";
};

struct UF2_ExtensionTag {
	u8 size;
	UF2_TagType type;
	u8 data[size - 4];
	
	if (size == 0 && type.bytes[0] == 0x00 && type.bytes[1] == 0x00 && type.bytes[2] == 0x00)
		break;
};

struct UF2_Block {
    char magicStart0[4];
    u32 magicStart1;
    UF2_Flags flags;
    u32 targetAddr;
    u32 payloadSize;
    u32 blockNo;
    u32 numBlocks;
    
    if (flags.FamilyIDPresent)
    	UF2_FamilyID familyId;
    else
    	u32 fileSize;
    
    if (flags.MD5ChecksumPresent) {
    	u8 data[452];
    	UF2_Hash hash; 
    }
    else {
    	u8 data[476];
    }
    
    if (flags.ExtensionTagsPresent) {
		UF2_ExtensionTag extensionTags[0xFF];
    }
    
    u32 magicEnd;
    
    std::assert(magicStart0 == "UF2\n", "Invalid magicStart0 value!");
    std::assert(magicStart1 == 0x9E5D5157, "Invalid magicStart1 value!");
    std::assert(magicEnd == 0x0AB16F30, "Invalid magicEnd value!");
};

UF2_Block block[while(!std::mem::eof())] @ 0;
