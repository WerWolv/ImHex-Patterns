#pragma author WerWolv
#pragma description Minecraft NBT format

#include <std/sys.pat>

#pragma endian big

enum Tag : u8 {
    End = 0,
    Byte = 1,
    Short = 2,
    Int = 3,
    Long = 4,
    Float = 5,
    Double = 6,
    ByteArray = 7,
    String = 8,
    List = 9,
    Compound = 10,
    IntArray = 11,
    LongArray = 12
};

using Element;

struct Value {
    if (parent.tag == Tag::Byte)
        s8 value;
    else if (parent.tag == Tag::Short)
        s16 value;
    else if (parent.tag == Tag::Int)
        s32 value;
    else if (parent.tag == Tag::Long)
        s64 value;
    else if (parent.tag == Tag::Float)
        float value;
    else if (parent.tag == Tag::Double)
        double value;
    else if (parent.tag == Tag::ByteArray) {
        s32 arrayLength;
        s8 value[arrayLength] [[sealed]];
    } else if (parent.tag == Tag::String) {
        u16 stringLength;
        char value[stringLength];
    } else if (parent.tag == Tag::List) {
        Tag tag;
        s32 listLength;
        Value values[listLength] [[static]];
    } else if (parent.tag == Tag::Compound) {       
        Element values[while(true)];
    } else if (parent.tag == Tag::IntArray){
        s32 arrayLength;
        s32 value[arrayLength] [[sealed]];
    } else if (parent.tag == Tag::LongArray) {
        s32 arrayLength;
        s64 value[arrayLength] [[sealed]];
    } else {
        std::error(std::format("Invalid tag {:02X}", TypeTag));
    }
} [[inline]];

struct Element {
    Tag tag;
    if (tag == Tag::End)
        break;
    else {

        u16 nameLength;
        char name[nameLength];
            
        Value value;
    }
};

struct NBT {
    Element element[while(true)] [[inline]];
};

NBT nbt @ 0x00;
