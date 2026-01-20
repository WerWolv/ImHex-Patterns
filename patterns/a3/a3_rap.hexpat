#pragma author MrClock
#pragma description Arma 3 binary configuration format

#pragma endian little

#pragma MIME application/x.a3-rap

fn get_data_description() {
    return "The RAP format is the binarized/\"rapified\" version of configuration files for Arma 3. Plain text configuration, material definition, scenario description and other files using the configuration syntax are rapified during the PBO packing process. The game can work with the plain text versions (they are actually rapified during boot), but properly converting them into the binary format ahead of time makes the booting easier.";
};

import std.mem;
import std.string;
import std.core;
import std.io;

using asciiz = std::string::NullString [[format("formatAsciiz")]];

/*
Item counts are stored in 7-bit encoded integers. In each byte the top bit signals
if the next byte belongs to the number as well.
*/
struct CompressedUint {
    u8 extras[while(std::mem::read_unsigned($, 1) & 0x80)];
    u8 last;
} [[sealed,transform("transformCompressedUint"),format("formatCompressedUint")]];

enum MemberType: u8 {
    CLASS = 0,
    LITERAL = 1,
    ARRAY = 2,
    EXTERNAL = 3,
    DELETE = 4,
    ARRAY_EXTENSION = 5
};

enum ValueType: u8 {
    STRING = 0,
    FLOAT = 1,
    INTEGER = 2,
    ARRAY = 3,
    VARIABLE = 4
};

using Array;

struct ArrayItem {
    ValueType type;
    match (type) {
        (ValueType::STRING): asciiz value;
        (ValueType::FLOAT): float value;
        (ValueType::INTEGER): s32 value;
        (ValueType::ARRAY): Array value;
        (ValueType::VARIABLE): asciiz value;
    }
} [[format("formatArrayItem")]];

struct Array {
    CompressedUint count_items;
    ArrayItem items[count_items];
} [[format("formatArray")]];

using ClassBody;

struct Member {
    MemberType type;

    match(type) {
        (MemberType::CLASS): {
            asciiz name;
            ClassBody *body : u32;
        }
        (MemberType::LITERAL): {
            ValueType subtype;
            asciiz name;
            match (subtype) {
                (ValueType::STRING): asciiz value;
                (ValueType::FLOAT): float value;
                (ValueType::INTEGER): s32 value;
                (_): std::error(std::format("Unexpected subtype for literal: {}", subtype));
            }
        }
        (MemberType::ARRAY | MemberType::ARRAY_EXTENSION): {
            asciiz name;
            Array value;
        }
        (MemberType::EXTERNAL): {
            asciiz name;
        }
        (MemberType::DELETE): {
            asciiz name;
        }
    }
} [[format("formatMember")]];

using Enums;

struct ClassBody {
    asciiz parent_name;
    CompressedUint count_members;

    Member members[count_members];
    u8 *pointer : u32 [[comment("In the root body this points to the enum list.\nIn all others it points to the next body on the same level.")]];
};

struct EnumItem {
    asciiz name;
    s32 value;
} [[format("formatEnumItem")]];

struct Enums {
    u32 count_items;
    EnumItem items[count_items];
};

struct RAP {
    char signature[4];
    u32;
    u32;
    Enums *enums : u32;
    ClassBody root;
};

fn formatAsciiz(ref asciiz value) {
    return std::format("\"{0:s}\"", value);
};

fn transformCompressedUint(ref CompressedUint value) {
    u64 result = 0;
    for (u8 i = 0, i < sizeof(value.extras), i += 1) {
        result += (value.extras[i] & 0x7F) << (7*i);
    }

    result += value.last << (sizeof(value.extras) * 7);

    return result;
};

fn formatCompressedUint(ref CompressedUint value) {
    return value;
};

fn formatArrayItem(ref ArrayItem value) {
    return value.value;
};

fn formatArray(ref Array value) {
    return "{...}";
};

fn formatMember(ref Member item) {
    match (item.type) {
        (MemberType::CLASS): return std::format("class {0:s} {{...}};", item.name);
        (MemberType::LITERAL): return std::format("{0:s} = {1};", item.name, item.value);
        (MemberType::ARRAY): return std::format("{0:s}[] = {{...}};", item.name);
        (MemberType::EXTERNAL): return std::format("class {0:s};", item.name);
        (MemberType::DELETE): return std::format("del {0:s};", item.name);
    }
};

fn formatEnumItem(ref EnumItem value) {
    return std::format("{0:s} = {1}", item.name, item.value);
};

RAP file @ 0x0000;
