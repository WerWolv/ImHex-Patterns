#pragma author gmestanley
#pragma description .nes file format

import std.mem;
import std.string;

bitfield iNES07Flags {
	mirroringIsVertical : 1;
	batterybackedPRGRAM : 1;
	trainerOf512Bytes : 1;
	ignoreMirroring : 1;
	mapperLowerNybble : 4;
	vsUnisystem : 1;
	playchoice10 : 1;
	nes2Format : 2 [[name("nes2.0Format")]];
	mapperHigherNybble : 4;
} [[name("iNES0.7Flags")]];

bitfield Flags9 {
	isPAL : 1;
	padding : 7;
};

bitfield Flags10 {
	tvSystem : 2;
	padding : 2;
	prgRAM : 1;
	busConflicts : 1;
	padding : 2;
};

struct iNESFlags {
	iNES07Flags ines07Flags [[name("ines0.7Flags")]];
	if (!ines07Flags.nes2Format) {
		u8 prgRAM8KBMultiplier;
		Flags9 flags9;
		Flags10 flags10;
		restLength = 5;
	}
	else {
		restLength = 9;
	}
};

u8 restLength;

struct Header {
	char identifier[4];
	u8 prgROM16KBMultiplier;
	u8 chrROM8KBMultiplier;
	iNESFlags inesFlags;
	char rest[restLength];
};

Header header @ 0x00;

enum EncodingType : u8 {
	ASCII = 1
};

struct OfficialHeader {
	char title[16] [[hex::spec_name("Title Registration Area")]];
	u16 programChecksum;
	u16 characterChecksum;
	u8 memorySize [[hex::spec_name("Cartridge Memory Size")]];
	u8 cartridgeType;
	EncodingType encodingType [[hex::spec_name("Registration Character Type Distinction")]];
	u8 titleLength [[hex::spec_name("Registration Characters Count")]];
	u8 makerID [[hex::spec_name("Maker Code")]];
	u8 complementaryChecksum;
};

union OfficialHeaderUnion {
	u8 miscellaneousData[26];
	OfficialHeader officialHeader;
};

struct PRGROM {
	u8 data[16384*header.prgROM16KBMultiplier-32];
	OfficialHeaderUnion officialHeaderUnion;
	u16 nmi;
	u16 entryPoint;
	u16 externalIRQ;
};

PRGROM prgROM @ sizeof(header);
u8 chrROM[8192*header.chrROM8KBMultiplier] @ sizeof(header)+sizeof(prgROM);