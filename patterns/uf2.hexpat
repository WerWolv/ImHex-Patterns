#pragma author WerWolv
#pragma description USB Flashing Format

#include <std/sys.pat>
#include <std/mem.pat>

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
    	u32 familyId;
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
