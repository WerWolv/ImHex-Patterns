#pragma author DexrnZacAttack
#pragma description Pattern for Minecraft LCE Save Files (after decompression)
#pragma version 1.2.0
#pragma disclaimer This pattern is not affiliated with Mojang Studios nor Microsoft. Minecraft is a trademark of Mojang Studios and Microsoft.
#pragma endian big
/*
 * ^ switch this to little for Switch, PS4, or Xbox One
 * so you'll probs have to switch all of the be to le
*/

// NOTE: This pattern was only tested on Nightly@974c4ba, things may break/not work on older versions.

#include <std/string.pat>
import std.string;
#pragma pattern_limit 1000000

// ================================================
// NBT LIBRARY BY WerWolv
// Can't import it normally due to the "NBT nbt @ 0x00;"
// ================================================
import std.sys;

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


fn to_string(auto x) {
    return std::format("{}", x);
};

fn contains(str string, str part) {
    s32 string_len = std::string::length(string);
    s32 part_len = std::string::length(part);

    for (s32 i = 0, i <= (string_len - part_len), i += 1) {
        if (std::string::substr(string, i, part_len) == part)
            return true;
    }

    return false;
};

// ================================================
// END NBT LIBRARY
// ================================================

// UNUSED FOR NOW
struct MCRIndex {
    u24 cOffset;
    u8 cLength;
};

struct MCRTimestamps {
    u32 timestamp;
};

struct MCRStruct {
    MCRIndex mcrIndex[0x1000];
    MCRTimestamps mcrTimestamps[0x1000];
};
// END UNUSED

struct LCEIndex {
    char16 filename[0x40] [[name("File Name")]]; // name of the file.
    u32 filesize [[name("File Size")]]; // how big the file is
    u32 offset [[name("File Offset")]]; // where the file is located
    u64 timestamp [[name("File Timestamp (unconfirmed)")]]; // file last modified date, may be incorrect as not much is known about these bytes iirc
    if (contains(to_string(filename), ".dat")) {
        NBT nbt @ this.offset [[name("(NBT) " + std::string::to_string(filename)), comment("NBT Data for file \"" + std::string::to_string(filename) + "\"")]]; // NBT
        // u8 nbt[this.filesize] @ this.offset [[name("(Unparsed NBT) " + std::string::to_string(filename)), comment("NBT Data for file \"" + std::string::to_string(filename) + "\"")]]; // NBT
        // ^ Uncomment this and comment the line above to disable NBT parsing.
    } else {
        u8 file[filesize] @ offset [[name(this.filename),comment(this.filename),attribute_name(this.filename)]]; // files in the index
        // ^ THIS SHOULD SHOW THE NAME ON HOVER... YET IT DOESN'T.
    }
};

struct LCEHeader {
    u32 offset [[name("Index Offset")]]; // where the index is located
    u32 count [[name("Index File Count")]]; // amount of files in the index
};

struct LCESave {
    LCEHeader header [[name("Header")]];
    LCEIndex index[header.count] @ header.offset [[name("File Index")]]; // the index
};

LCESave Save @ 0x00;
