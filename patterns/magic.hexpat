import type.magic;
import type.guid;

#pragma magic [ 1C 04 1E F1 ] @ 0x00
#pragma filename *.mgc
#pragma MIME application/x-file

#pragma author WerWolv
#pragma description file / libmagic Magic Database

struct Header {
    type::Magic<"\x1C\x04\x1E\xF1"> magic;
    u32 version;
    u32 numRecordsSet0, numRecordsSet1;
    padding[416];
};

struct StringRange {
    u32 range;
    u32 flags;
} [[static]];

union MaskRange {
    u64 numMask;
    StringRange string;
};

union ValueType {
    s8          sb;
    s16         sh;
    s32         sl;
    s64         sq;
    u8          b;
    u16         h;
    u32         l;
    u64         q;
    u8          hs[2];
    u8          hl[4];
    u8          hq[8];
    char        s[128];
    u8          us[128];
    type::GUID  guid;
    float       f;
    double      d;
} [[static]];

bitfield MagicFlags {
    bool indir          : 1;
    bool off_add        : 1;
    bool indir_off_add  : 1;
    bool is_unsigned    : 1;
    bool no_space       : 1;
    bool bin_test       : 1;
    bool text_test      : 1;
    bool off_negative   : 1;
    bool off_positive   : 1;
    padding             : 7;
};

enum Type : u8 {
    INVALID = 0,
    BYTE = 1,
    SHORT = 2,
    DEFAULT = 3,
    LONG = 4,
    STRING = 5,
    DATE = 6,
    BESHORT = 7,
    BELONG = 8,
    BEDATE = 9,
    LESHORT = 10,
    LELONG = 11,
    LEDATE = 12,
    PSTRING = 13,
    LDATE = 14,
    BELDATE = 15,
    LELDATE = 16,
    REGEX = 17,
    BESTRING16 = 18,
    LESTRING16 = 19,
    SEARCH = 20,
    MEDATE = 21,
    MELDATE = 22,
    MELONG = 23,
    QUAD = 24,
    LEQUAD = 25,
    BEQUAD = 26,
    QDATE = 27,
    LEQDATE = 28,
    BEQDATE = 29,
    QLDATE = 30,
    LEQLDATE = 31,
    BEQLDATE = 32,
    FLOAT = 33,
    BEFLOAT = 34,
    LEFLOAT = 35,
    DOUBLE = 36,
    BEDOUBLE = 37,
    LEDOUBLE = 38,
    BEID3 = 39,
    LEID3 = 40,
    INDIRECT = 41,
    QWDATE = 42,
    LEQWDATE = 43,
    BEQWDATE = 44,
    NAME = 45,
    USE = 46,
    CLEAR = 47,
    DER = 48,
    GUID = 49,
    LEGUID = 50,
    BEGUID = 51,
    OFFSET = 52,
    BEVARINT = 53,
    LEVARINT = 54,
    MSDOSDATE = 55,
    LEMSDOSDATE = 56,
    BEMSDOSDATE = 57,
    MSDOSTIME = 58,
    LEMSDOSTIME = 59,
    BEMSDOSTIME = 60,
    OCTAL = 61
};

enum Op : u8 {
    OPAND = 0,
    OPOR = 1,
    OPXOR = 2,
    OPADD = 3,
    OPMINUS = 4,
    OPMULTIPLY = 5,
    OPDIVIDE = 6,
    OPMODULO = 7,
    UNUSED_1 = 0x08,
    UNUSED_2 = 0x10,
    OPSIGNED = 0x20,
    OPINVERSE = 0x40,
    OPINDIRECT = 0x80,
};

enum Cond : u8 {
    NONE = 0,
    IF = 1,
    ELIF = 2,
    ELSE = 3
};

enum FactorOp : u8 {
    PLUS = '+',
    MINUS = '-',
    TIMES = '*',
    DIV = '/',
    NONE = 0x00
}; 

struct Magic {
    MagicFlags flag;
    u8 cont_level;
    u8 factor;
    u8 reln;
    u8 vallen;
    Type type;
    Type inType;
    Op inOp;
    Op maskOp;
    Cond cond;
    FactorOp factorOp;
    u32 offset;
    u32 inOffset;
    u32 lineNumber;
    MaskRange maskRange;
    ValueType value;
    
    char desc[64];
    char mimeType[80];
    char apple[8];
    char ext[120];
} [[static]];

struct MagicDatabase {
    Header header;
    Magic matchingRules[header.numRecordsSet0];
    Magic namedRules[header.numRecordsSet1];
};

MagicDatabase magicDatabase @ 0x00;