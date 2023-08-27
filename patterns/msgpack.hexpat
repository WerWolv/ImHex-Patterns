#pragma description MessagePack binary serialization format

#pragma MIME application/x-msgpack

enum Type : u8 {
	PositiveFixInt		= 0x00 ... 0x7F,
	FixMap				= 0x80 ... 0x8F,
	FixArray			= 0x90 ... 0x9F,
	FixStr				= 0xA0 ... 0xBF,
	Nil					= 0xC0,
	Unused				= 0xC1,
	False				= 0xC2,
	True				= 0xC3,
	Bin8				= 0xC4,
	Bin16				= 0xC5,
	Bin32				= 0xC6,
	Ext8				= 0xC7,
	Ext16				= 0xC8,
	Ext32				= 0xC9,
	Float32				= 0xCA,
	Float64				= 0xCB,
	Uint8				= 0xCC,
	Uint16				= 0xCD,
	Uint32				= 0xCE,
	Uint64				= 0xCF,
	Int8				= 0xD0,
	Int16				= 0xD1,
	Int32				= 0xD2,
	Int64				= 0xD3,
	FixExt1				= 0xD4,
	FixExt2				= 0xD5,
	FixExt4				= 0xD6,
	FixExt8				= 0xD7,
	FixExt16			= 0xD8,
	Str8				= 0xD9,
	Str16				= 0xDA,
	Str32				= 0xDB,
	Array16				= 0xDC,
	Array32				= 0xDD,
	Map16				= 0xDE,
	Map32				= 0xDF,
	NegativeFixInt		= 0xE0 ... 0xFF
};

fn format_positive_fixint(u8 value) {
	return value & 0b0111'1111;
};

fn format_negative_fixint(u8 value) {
	return -(value & 0b0001'1111);
};

using MessagePack;

struct MapEntry {
	MessagePack key, value;
};

struct MessagePack {
	Type type;
	
	if (u8(type) <= 0x7F) {
		$ -= 1;
		u8 value [[format("format_positive_fixint")]];
	} else if (u8(type) >= Type::NegativeFixInt) {
		$ -= 1;
		u8 value [[format("format_negative_fixint")]];
	} else if (type == Type::Uint8)
		be u8 value;
	else if (type == Type::Uint16)
		be u16 value;
	else if (type == Type::Uint32)
		be u32 value;
	else if (type == Type::Uint64)
		be u64 value;
	else if (type == Type::Int8)
		be s8 value;
	else if (type == Type::Int16)
		be s16 value;
	else if (type == Type::Int32)
		be s32 value;
	else if (type == Type::Int64)
		be s64 value;
	else if (type == Type::Float32)
		be float value;
	else if (type == Type::Float64)
		be double value;
	else if ((u8(type) & 0b1110'0000) == Type::FixStr)
		char value[u8(type) & 0b0001'1111];
	else if (type == Type::Str8) {
		be u8 length;
		char value[length];
	} else if (type == Type::Str16) {
		be u16 length;
		char value[length];
	} else if (type == Type::Str32) {
		be u32 length;
		char value[length];
	} else if (type == Type::Bin8) {
		be u8 length;
		u8 value[length];
	} else if (type == Type::Bin16) {
		be u16 length;
		u8 value[length];
	} else if (type == Type::Bin32) {
		be u32 length;
		u8 value[length];
	} else if ((u8(type) & 0b1111'0000) == Type::FixArray)
		MessagePack value[u8(type) & 0b0000'1111];
	else if (type == Type::Array16) {
		be u16 length;
		MessagePack value[length];
	} else if (type == Type::Array32) {
		be u32 length;
		MessagePack value[length];
	} else if ((u8(type) & 0b1111'0000) == Type::FixMap)
		MapEntry value[u8(type) & 0b0000'1111];
	else if (type == Type::Map16) {
		be u16 length;
		MapEntry value[length];
	} else if (type == Type::Map32) {
		be u32 length;
		MapEntry value[length];
	} else if (type == Type::FixExt1) {
		s8 type;
		u8 data;
	} else if (type == Type::FixExt2) {
		s8 type;
		u16 data;
	} else if (type == Type::FixExt4) {
		s8 type;
		u32 data;
	} else if (type == Type::FixExt8) {
		s8 type;
		u64 data;
	} else if (type == Type::FixExt16) {
		s8 type;
		u128 data;
	} else if (type == Type::Ext8) {
		u8 length;
		s8 type;
		u8 data[length];
	} else if (type == Type::Ext16) {
		u16 length;
		s8 type;
		u8 data[length];
	} else if (type == Type::Ext32) {
		u32 length;
		s8 type;
		u8 data[length];
	}
		
		
};

MessagePack pack @ 0x00;