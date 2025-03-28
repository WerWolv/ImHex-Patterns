#pragma author WerWolv and Glenn Hartmann
#pragma description Google Protobuf wire encoding (.pb)

#pragma MIME application/protobuf
#pragma MIME application/vnd.google.protobuf

#pragma endian little

import std.core;
import std.io;
import std.mem;
import std.string;
import std.sys;

import type.leb128;

// Attempting to recursively parse submessages is a guess-and-check process
// since it's inherently impossible to tell for sure what type a
// LengthDelimited field is. This could be imprecise and could be slow for
// large or ambiguous files, so we give the user an option to disable it.
bool disable_recursive_submessage_parsing in;

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
    Varint          = 0,
    _64Bit          = 1,
    LengthDelimited = 2,
    StartGroup      = 3,
    EndGroup        = 4,
    _32Bit          = 5
};

struct Key {
    type::uLEB128 keyDec;
    u32 field_number = u32(keyDec) >> 3;
    WireType wire_type = u32(keyDec) & 7;
}[[sealed, format("format_key")]];

fn format_key(Key keyObject) {
    return std::format("{} with field number {}", keyObject.wire_type, keyObject.field_number);
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

using Field;

struct Message<auto Size> {
    Field fields[while(!std::mem::reached(addressof(this) + Size))];
};

struct Utf8String<auto Length> {
    char data[Length];
} [[sealed, format("std::string::impl::format_string"), transform("std::string::impl::format_string")]];

union _LengthDelimitedData<auto Length> {
    u8 bytes[Length];
    Utf8String<Length> utf8;

    if (!disable_recursive_submessage_parsing) {
        try {
            // Attempt to parse binary data as an embedded Message. This is
            // expected to fail often, as the proto format uses LengthDelimited
            // for several different data types.
            Message<Length> msg;
            std::assert(sizeof(msg) == Length, "Attempted parse of Message consumed wrong number of bytes.");
        }
    }
};

struct LengthDelimited {
    type::uLEB128 length;

    std::assert($ + length <= std::mem::size(), "Attempting to parse _LengthDelimitedData would exceed file length.");
    _LengthDelimitedData<length> data;
};

union _LEB128 {
    type::uLEB128 uLEB128;
    type::sLEB128 sLEB128; // NOTE: the signed version doesn't seem to be working properly
};

struct Field {
    Key key;

    match (key.wire_type) {
        (WireType::Varint): _LEB128 value;
        (WireType::_64Bit): _64Bit value;
        (WireType::LengthDelimited): LengthDelimited value;
        (WireType::_32Bit): _32Bit value;
        (WireType::StartGroup | WireType::EndGroup): std::unimplemented();
        (_): std::error("Unknown WireType.");
    }
};

Message<std::mem::size()> msg @ 0x00;
std::assert(std::mem::eof(), "Parsing did not consume whole file.");
