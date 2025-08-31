#pragma description SDB File (Shim DataBase file)
#pragma author learn_more
#pragma magic [ 73 64 62 66 ] @ 0x08
#pragma endian little

import std.mem;
import std.io;
import std.string;
import type.base;

enum TagType : u8 {
    Null = 0x1,
    Byte = 0x2,
    Word = 0x3,
    DWord = 0x4,
    QWord = 0x5,
    StringRef = 0x6,
    List = 0x7,
    String = 0x8,
    Binary = 0x9,
};

bitfield TypeId {
    id : 12;
    type : 4;
};

fn get_tag(TypeId tag) {
    return std::format("{:x}{:03x}", tag.type, tag.id);
};

fn get_type(TypeId tag) {
    TagType tmp = tag.type;
    str name = std::format("{}", tmp);
    u32 len = std::string::length(name);
    return std::string::substr(name, 9, len-9);
};

struct Tag {
    TypeId tag[[format_read("get_tag")]];
    match (tag.type) {
        (TagType::Null) : {
            // All set
        }
        (TagType::Byte) : {
            u8 value;
            u8 pad[[hidden]];
        }
        (TagType::Word) : {
            u16 value;
        }
        (TagType::DWord) : {
            u32 value;
        }
        (TagType::QWord) : {
            u64 value;
        }
        (TagType::StringRef) : {
            u32 str_offset;
            char value @ str_offset;
        }
        (TagType::List) : {
            u32 size ;
            Tag tags[while($ < ((addressof(size) + size + 4) ))];
        }
        (TagType::String) : {
            u32 size;
            char16 value[size/2];
        }
        (TagType::Binary) : {
           u32 size;
           u8 value[size];
           if (size & 1 ) {
            u8 pad[[hidden]];
           }
        }
    }
}[[name(get_tag(tag)), comment(get_type(tag))]];

struct Header {
    u32 Major;
    u32 Minor;
    char Magic[4];
    Tag tags[while(!std::mem::eof())];
};

Header file @ 0x0;