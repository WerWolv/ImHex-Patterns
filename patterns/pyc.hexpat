#pragma description Python bytecode
#pragma MIME application/x-bytecode.python

import type.time;
import std.mem;

#define FLAG_REF 0x80
#define TYPE_NULL               '0'
#define TYPE_NONE               'N'
#define TYPE_FALSE              'F'
#define TYPE_TRUE               'T'
#define TYPE_STOPITER           'S'
#define TYPE_ELLIPSIS           '.'
#define TYPE_INT                'i'
#define TYPE_INT64              'I'
#define TYPE_FLOAT              'f'
#define TYPE_BINARY_FLOAT       'g'
#define TYPE_COMPLEX            'x'
#define TYPE_BINARY_COMPLEX     'y'
#define TYPE_LONG               'l'
#define TYPE_STRING             's'
#define TYPE_INTERNED           't'
#define TYPE_REF                'r'
#define TYPE_STRINGREF          'R'
#define TYPE_TUPLE              '('
#define TYPE_LIST               '['
#define TYPE_DICT               '{'
#define TYPE_CODE               'c'
#define TYPE_UNICODE            'u'
#define TYPE_UNKNOWN            '?'
#define TYPE_SET                '<'
#define TYPE_FROZENSET          '>'
#define TYPE_ASCII              'a'
#define TYPE_ASCII_INTERNED     'A'
#define TYPE_SMALL_TUPLE        ')'
#define TYPE_SHORT_ASCII        'z'
#define TYPE_SHORT_ASCII_INTERNED 'Z'
#define MAX_REFS 2048

using MarshalObject;
u8 _major;
u8 _minor;

fn above(u8 major, u8 minor) {
    return _major >= major && _minor >= minor;
};

fn below(u8 major, u8 minor) {
    return _major <=major && _minor < minor;
};

fn between(u8 major, u8 minor, u8 otherMajor, u8 otherMinor) {
    return above(major, minor) && below(otherMajor, otherMinor);
};

struct NoneObject {};

struct MarshalString {
    if(parent.type == TYPE_SHORT_ASCII || parent.type == TYPE_SHORT_ASCII_INTERNED)
        u8 length;
    else
        u32 length;

    char data[length];
};

struct MarshalSequence {
    if(parent.type == TYPE_SMALL_TUPLE)
        u8 length;
    else
        u32 length;
    MarshalObject values[length];
};

struct MarshalCode {
    if(between(1, 3, 2, 3)) u16 numArgs;
    else if(above(2, 3)) u32 numArgs;

    if(above(3, 8)) u32 numPosOnlyArgs;

    if(_major >= 3) u32 numKwOnlyArgs;

    if(between(1, 3, 2, 3)) u16 numLocals;
    else if(between(2, 3, 3, 11)) u32 numLocals;

    if(between(1, 5, 2, 3)) u16 numStack;
    else if(above(2, 3)) u32 numStack;

    if(between(1, 3, 2, 3)) u16 flags;
    else if(above(2, 3)) u32 flags;

    MarshalObject code;
    MarshalObject constants;
    MarshalObject names;

    if(above(1, 3)) MarshalObject localNames;

    if(above(3, 11)) MarshalObject localKinds;

    if(between(2, 1, 3, 11)) {
        MarshalObject freeVars;
        MarshalObject cellVars;
    }

    MarshalObject fileName;
    MarshalObject name;

    if(above(3, 11)) MarshalObject qualifiedName;

    if(between(1, 5, 2, 3)) u16 firstLine;
    else if(above(2, 3)) u32 firstLine;

    if(above(1, 5)) MarshalObject lnTable;

    if(above(3, 11)) MarshalObject exceptionTable;
};

struct DictEntry {
    MarshalObject key;
    if(key.type == TYPE_NULL) break;
    MarshalObject value;
};

struct MarshalDict {
   DictEntry entries[while(true)];
};

struct LongInt {
    u32 len;
    u16 buffer[len];
};

struct LongFloat {
    u8 len;
    u8 buffer[len];
};

struct LongComplex {
    LongFloat real;
    LongFloat imag;
};

auto section = std::mem::create_section("ref-address");
u128 refs[MAX_REFS] @ 0x0 in section;
u32 refIndex;

fn refMember(u128 address) {
    refs[refIndex] = address;
    refIndex += 1;
};

fn getRef(u32 index) {
    return refs[index];
};

struct MarshalObject {
    u8 _type [[hidden]];
    u8 flag = _type & FLAG_REF;
    u8 type = _type & ~FLAG_REF;

    if(flag) {
        refMember($-1);
    }

    match(type) {
        (TYPE_NULL | TYPE_NONE | TYPE_STOPITER | TYPE_ELLIPSIS | TYPE_FALSE | TYPE_TRUE): continue;
        (TYPE_CODE): {
            MarshalCode code [[inline]];
        }
        (TYPE_STRING                |
         TYPE_UNICODE               |
         TYPE_ASCII                 |
         TYPE_ASCII_INTERNED        |
         TYPE_SHORT_ASCII           |
         TYPE_SHORT_ASCII_INTERNED): {
            MarshalString string [[inline]];
        }
        (TYPE_SMALL_TUPLE | TYPE_TUPLE | TYPE_LIST | TYPE_SET | TYPE_FROZENSET): {
            MarshalSequence sequence [[inline]];
        }
        (TYPE_DICT): {
            MarshalDict dict [[inline]];
        }
        (TYPE_INT): {
            u32 int;
        }
        (TYPE_INT64): {
            u64 long;
        }
        (TYPE_FLOAT): {
            LongFloat number;
        }
        (TYPE_BINARY_FLOAT): {
            double number;
        }
        (TYPE_COMPLEX): {
            LongComplex complex;
        }
        (TYPE_BINARY_COMPLEX): {
            double real;
            double imag;
        }
        (TYPE_LONG): {
            LongInt long;
        }
        (TYPE_REF): {
            u32 index;
            MarshalObject obj @ getRef(index);
        }
        (_): {
            std::print("Unknown marshal object type: {:c}", type);
        }
    }

} [[format("format_marshal")]];

fn format_marshal(ref auto obj) {
    match(obj.type) {
        (TYPE_NONE): return "None";
        (TYPE_STOPITER): return "StopIteration";
        (TYPE_ELLIPSIS): return "...";
        (TYPE_FALSE): return "False";
        (TYPE_TRUE): return "True";
        (TYPE_INT): return "int";
        (TYPE_INT64): return "int64";
        (TYPE_FLOAT): return "float";
        (TYPE_BINARY_FLOAT): return "float";
        (TYPE_COMPLEX): return "complex";
        (TYPE_BINARY_COMPLEX): return "complex";
        (TYPE_LONG): return "long";
        (TYPE_STRING): return "string";
        (TYPE_INTERNED): return "interned";
        (TYPE_REF): return "ref";
        (TYPE_TUPLE): return "tuple";
        (TYPE_LIST): return "list";
        (TYPE_DICT): return "dict";
        (TYPE_CODE): return "code";
        (TYPE_UNICODE): return "unicode";
        (TYPE_UNKNOWN): return "unknown";
        (TYPE_SET): return "set";
        (TYPE_FROZENSET): return "frozenset";
        (TYPE_ASCII): return "ascii";
        (TYPE_ASCII_INTERNED): return "ascii_interned";
        (TYPE_SHORT_ASCII): return "short_ascii";
        (TYPE_SHORT_ASCII_INTERNED): return "short_ascii_interned";
        (TYPE_SMALL_TUPLE): return "small_tuple";
    }
};

enum Magic : u32 {
    MAGIC_1_0 = 0x00999902,
    MAGIC_1_1 = 0x00999903, /* Also covers 1.2 */
    MAGIC_1_3 = 0x0A0D2E89,
    MAGIC_1_4 = 0x0A0D1704,
    MAGIC_1_5 = 0x0A0D4E99,
    MAGIC_1_6 = 0x0A0DC4FC,

    MAGIC_2_0 = 0x0A0DC687,
    MAGIC_2_1 = 0x0A0DEB2A,
    MAGIC_2_2 = 0x0A0DED2D,
    MAGIC_2_3 = 0x0A0DF23B,
    MAGIC_2_4 = 0x0A0DF26D,
    MAGIC_2_5 = 0x0A0DF2B3,
    MAGIC_2_6 = 0x0A0DF2D1,
    MAGIC_2_7 = 0x0A0DF303,

    MAGIC_3_0 = 0x0A0D0C3A,
    MAGIC_3_1 = 0x0A0D0C4E,
    MAGIC_3_2 = 0x0A0D0C6C,
    MAGIC_3_3 = 0x0A0D0C9E,
    MAGIC_3_4 = 0x0A0D0CEE,
    MAGIC_3_5 = 0x0A0D0D16,
    MAGIC_3_5_3 = 0x0A0D0D17,
    MAGIC_3_6 = 0x0A0D0D33,
    MAGIC_3_7 = 0x0A0D0D42,
    MAGIC_3_8 = 0x0A0D0D55,
    MAGIC_3_9 = 0x0A0D0D61,
    MAGIC_3_10 = 0x0A0D0D6F,
    MAGIC_3_11 = 0x0A0D0DA7,

    INVALID = 0,
};

fn getMajor(Magic magic) {
    match(magic) {
        (Magic::MAGIC_1_0 | Magic::MAGIC_1_1 | Magic::MAGIC_1_3 | Magic::MAGIC_1_4 | Magic::MAGIC_1_5 | Magic::MAGIC_1_6): return 1;
        (Magic::MAGIC_2_0 | Magic::MAGIC_2_1 | Magic::MAGIC_2_2 | Magic::MAGIC_2_3 | Magic::MAGIC_2_4 | Magic::MAGIC_2_5 | Magic::MAGIC_2_6 | Magic::MAGIC_2_7): return 2;
        (Magic::MAGIC_3_0 | Magic::MAGIC_3_1 | Magic::MAGIC_3_2 | Magic::MAGIC_3_3 | Magic::MAGIC_3_4 | Magic::MAGIC_3_5 | Magic::MAGIC_3_5_3 | Magic::MAGIC_3_6 | Magic::MAGIC_3_7 | Magic::MAGIC_3_8 | Magic::MAGIC_3_9 | Magic::MAGIC_3_10 | Magic::MAGIC_3_11): return 3;
        (Magic::INVALID): return 0;
    }
};

fn getMinor(Magic magic) {
    match(magic) {
        (Magic::MAGIC_1_0 | Magic::MAGIC_2_0 | Magic::MAGIC_3_0): return 0;
        (Magic::MAGIC_1_1 | Magic::MAGIC_2_1 | Magic::MAGIC_3_1): return 1;
        (Magic::MAGIC_1_3 | Magic::MAGIC_2_2 | Magic::MAGIC_3_2): return 2;
        (Magic::MAGIC_1_4 | Magic::MAGIC_2_3 | Magic::MAGIC_3_3): return 3;
        (Magic::MAGIC_1_5 | Magic::MAGIC_2_4 | Magic::MAGIC_3_4): return 4;
        (Magic::MAGIC_1_6 | Magic::MAGIC_2_5 | Magic::MAGIC_3_5 | Magic::MAGIC_3_5_3): return 5;
        (Magic::MAGIC_2_6 | Magic::MAGIC_3_6): return 6;
        (Magic::MAGIC_2_7 | Magic::MAGIC_3_7): return 7;
        (Magic::MAGIC_3_8): return 8;
        (Magic::MAGIC_3_9): return 9;
        (Magic::MAGIC_3_10): return 10;
        (Magic::MAGIC_3_11): return 11;
        (Magic::INVALID): return 0;
    }
};

struct PYCHeader {
    Magic magic;
    _major = getMajor(magic);
    _minor = getMinor(magic);
    u8 major = _major [[export]];
    u8 minor = _minor [[export]];

    if(above(3, 7)) {
        u32 flags;
    } else {
        u32 flags;
    }

    if(flags & 0x1) {
        u64 checksum;
    } else {
        type::time32_t timestamp;

        if(above(3, 3)) {
            u32 size;
        }
    }

    MarshalObject object;
};

PYCHeader header @ 0x0;