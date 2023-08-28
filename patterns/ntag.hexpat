#pragma author WerWolv
#pragma description NTAG213/NTAG215/NTAG216, NFC Forum Type 2 Tag compliant IC

#include <std/core.pat>

using BitfieldOrder = std::core::BitfieldOrder;

bitfield AccessCapability {
	Read : 4;
	Write : 4;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

struct CapabilityContainer {
	u8 magic;
	u8 version;
	u8 memorySize;
	be AccessCapability accessCapability;
};

bitfield NDEFFlags {
	MB	: 1;
	ME	: 1;
	CF	: 1;
	SR	: 1;
	IL	: 1;
	TNF	: 3;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

enum TNFType : u8 {
	Empty 					= 0x00,
	NFCForumWellKnownType 	= 0x01,
	MediaType				= 0x02,
	AbsoluteURI				= 0x03,
	NFCForumExternalType 	= 0x04,
	Unknown 				= 0x05,
	Unchanged 				= 0x06,
	Reserved 				= 0x07
};

struct NDEF {
	NDEFFlags flags;
	u8 typeLength;
	
	if (flags.SR)
		u8 payloadLength;
	else
		u32 payloadLength;
		
	if (flags.IL)
		u8 idLength;
		
	char type[typeLength];
	
	if (flags.IL)
		u8 id[idLength];
	
	u8 payload[payloadLength];
		
	if (flags.ME)
		break;
};

struct LockControl {
	u8 dynamicLockByteOffset;
	u8 numBits;
	u8 pageControlInfo;
};

struct MemoryControl {
	u8 reservedBytesOffset;
	u8 numBytes;
	u8 pageSize;
};

struct Length {
	u8 byte [[hidden, no_unique_address]];
	if (byte == 0xFF)
		u24 length;
	else
		u8 length;
} [[sealed, transform("transform_length"), format("transform_length")]];

fn transform_length(ref auto length) {
	return length.length;
};

enum Tag : u8 {
	NULL 			= 0x00,
	LockControl 	= 0x01,
	MemoryControl 	= 0x02,
	NDEFMessage 	= 0x03,
	Proprietary 	= 0xFD,
	TerminatorTLV 	= 0xFE
};

struct TLV {
	Tag tag;
	if (tag == Tag::TerminatorTLV) {
		break;
	} else if (tag == Tag::NULL) {
		// Empty
	} else {
		Length length;
		
		if (length > 0) {
			if (tag == Tag::LockControl) {
				LockControl lockControl;
			} else if (tag == Tag::MemoryControl) {
				LockControl lockControl;
			} else if (tag == Tag::NDEFMessage) {
				NDEF ndef[while(true)];
			} else {
				u8 value[length];
			}
		}
	}
};

struct ManufacturerData {
	u8 serial1[3];
	u8 checkByte0;
	u8 serial2[4];
	u8 checkByte1;
	u8 internal;
	u16 lockBytes;
};

struct DynamicLockBytes {
	u8 bytes[3];
	padding[1];
};

bitfield MIRROR {
	MIRROR_CONF	: 2;
	MIRROR_BYTE	: 2;
	padding     : 1;
	STRG_MOD_EN	: 1;
	padding     : 2;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

bitfield ACCESS {
	PROT				: 1;
	CFGLCK				: 1;
	padding             : 1;
	NFC_CNT_EN			: 1;
	NFC_CNT_PWD_PROT	: 1;
	AUTHLIM				: 3;
};

struct Config {
	MIRROR MIRROR;
	u8 MIRROR_PAGE;
	u8 AUTH0;
	ACCESS ACCESS;
	u32 PWD;
	u16 PACK;
};

struct NTAG {
	ManufacturerData manufacturerData;
	CapabilityContainer cc;
	TLV tlv[while(true)];
	padding[addressof(tlv) + cc.memorySize * 8 - sizeof(tlv)];
	DynamicLockBytes dynamicLockBytes;
	Config config;
};

NTAG ntag @ 0x00;
