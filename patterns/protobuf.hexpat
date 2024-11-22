#pragma author WerWolv
#pragma description Google Protobuf wire encoding (.pb)

import std.core;
import std.io;
import std.mem;

import type.leb128;

struct ZigZag32 {
	u32 value;
} [[sealed, format("format_zigzag32")]];

fn format_zigzag32(ZigZag32 zigzag) {
	return s32((s32(zigzag.value) << 1) ^ (s32(zigzag.value) >> 31));
};

struct ZigZag64 {
	u64 value;
} [[sealed, format("format_zigzag64")]];

fn format_zigzag64(ZigZag64 zigzag) {
	return s64((s64(zigzag.value) << 1) ^ (s64(zigzag.value) >> 63));
};

enum WireType : u8 {
	Varint 			= 0,
	_64Bit 			= 1,
	LengthDelimited = 2,
	StartGroup 		= 3,
	EndGroup 		= 4,
	_32Bit 			= 5
};

WireType wire_type;
u32 tag;
u32 field_number;

struct Key {
    type::uLEB128 keyDec;
    field_number = u32(keyDec) >> 3;
    wire_type = u32(keyDec) & 7;
}[[sealed, format("format_key")]];

fn format_key(Key keyObject) {
    return std::format("{} with field number {}", wire_type, field_number);
};

union _64Bit {
	u64 fixed64;
	ZigZag64 sfixed64;
	double dbl;
};

union _32Bit {
	u32 fixed32;
	ZigZag32 sfixed32;
	float flt;
};

struct LengthDelimited {
	type::uLEB128 length;
	char data[length];
};


struct Entry {
    Key key;

	if (wire_type == WireType::Varint)
		type::uLEB128 value;
	else if (wire_type == WireType::_64Bit)
		_64Bit value;
	else if (wire_type == WireType::LengthDelimited)
		LengthDelimited value;
	else if (wire_type == WireType::_32Bit)
		_32Bit value;
};

Entry entries[while(!std::mem::eof())] @ 0x00;