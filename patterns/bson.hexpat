#pragma author WerWolv
#pragma description BSON (Binary JSON)

#pragma MIME application/bson

import std.mem;
import type.time;

enum Type : u8 {
    Double              = 0x01,
    String              = 0x02,
    EmbeddedDocument    = 0x03,
    Array               = 0x04,
    Binary              = 0x05,
    Undefined           = 0x06,
    ObjectId            = 0x07,
    Boolean             = 0x08,
    UTCDatetime         = 0x09,
    Null                = 0x0A,
    Regex               = 0x0B,
    DBPointer           = 0x0C,
    JavaScript          = 0x0D,
    Symbol              = 0x0E,
    JavaScriptWithScope = 0x0F,
    Int32               = 0x10,
    Timestamp           = 0x11,
    Int64               = 0x12,
    Decimal128          = 0x13,
    
    MinKey              = 0xFF, 
    MaxKey              = 0x7F
};

enum Subtype : u8 {
    GenericBinarySubtype   = 0x00,
    Function               = 0x01,
    BinaryOld              = 0x02,
    UUIDOld                = 0x03,
    UUID                   = 0x04,
    MD5                    = 0x05,
    EncryptedBSONValue     = 0x06,
    CompressedBSONColumn   = 0x07,
    UserDefined            = 0x80
};

struct Binary {
    s32 length;
    Subtype subtype;
    u8 data[length];
};

struct String {
    u32 length [[hidden]];
    char value[length];
} [[sealed, format("format_string")]];

struct CString {
    char value[];
} [[sealed, format("format_string")]];

fn format_string(auto string) {
    return string.value;
};

struct ObjectId {
    type::time32_t timestamp;
    u8 randomValue[5];
    u24 counter;
};

struct DBPointer {
    String name;
    ObjectId value;
};


using Document;

struct Element {
    Type type;
    
    CString name;
    
    if (type == Type::Double) {
        double value;
    } else if (type == Type::String) {
        String value;
    } else if (type == Type::EmbeddedDocument) {
        Document value;
    } else if (type == Type::Array) {
        Document value;
    } else if (type == Type::Binary) {
        Binary value;
    } else if (type == Type::Undefined) {
        /* undefined */
    } else if (type == Type::ObjectId) { 
        ObjectId value;
    } else if (type == Type::Boolean) { 
        bool value;
    } else if (type == Type::UTCDatetime) {
        type::time64_t value;
    } else if (type == Type::Null) {
        /* null */
    } else if (type == Type::Regex) {
        CString regexPattern;
        CString regexOptions;
    } else if (type == Type::DBPointer) {
        DBPointer value;
    } else if (type == Type::JavaScript) {
        String value;
    } else if (type == Type::Symbol) {
        String value;
    } else if (type == Type::JavaScriptWithScope) {
        String value;
    } else if (type == Type::Int32) {
        s32 value;
    } else if (type == Type::Timestamp) {
        u64 value;
    } else if (type == Type::Int64) {
        s64 value;
    } else if (type == Type::Decimal128) {
        u128 value;
    }
};

struct Document {
    s32 listLength;
    Element elements[while($ < ((addressof(this) + listLength) - 1))];
    padding[1];
};

Document documents[while(!std::mem::eof())] @ 0x00 [[inline]];
