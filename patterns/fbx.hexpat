#pragma description Kaydara FBX Binary

// Based on Blenders implementation of FBX import/export

#pragma endian little

#ifdef __IMHEX__
    import hex.dec;
#endif

import std.mem;
import std.string;
import std.sys;
import type.magic;

struct Array<E> {
    u32 arrayLength;
    u32 encoding;
    u32 compressedLength;
    
    std::assert(encoding < 2, "Invalid array encoding!");
    
    if (encoding == 0) {
        // Uncompressed
        E contents[arrayLength];
    } else {
        // Compressed (zlib)
        u128 pos = $;
        u8 compressedContents[compressedLength];

        #ifdef __IMHEX__
            std::mem::Section contentsSection = std::mem::create_section(std::format("contentsSection @ {:#x}", pos));
            hex::dec::zlib_decompress(compressedContents, contentsSection, 15);
            E contents[] @ 0x00 in contentsSection;
        #endif
    }
};

enum PropertyTypeCode : char {
    BYTE = 'Z',
    SHORT = 'Y',
    BOOL = 'B',
    CHAR = 'C',
    INT = 'I',
    FLOAT = 'F',
    DOUBLE = 'D',
    LONG = 'L',
    BINARY = 'R',
    STRING = 'S',
    ARRAY_BOOL = 'b',
    ARRAY_UBYTE = 'c',
    ARRAY_INT = 'i',
    ARRAY_LONG = 'l',
    ARRAY_FLOAT = 'f',
    ARRAY_DOUBLE = 'd'
};

struct PropertyRecord {
    PropertyTypeCode typeCode;
    
    match (typeCode) {
        (PropertyTypeCode::BYTE): s8 data;
        (PropertyTypeCode::SHORT): s16 data;
        (PropertyTypeCode::BOOL): bool data;
        (PropertyTypeCode::CHAR): char data;
        (PropertyTypeCode::INT): s32 data;
        (PropertyTypeCode::FLOAT): float data;
        (PropertyTypeCode::DOUBLE): double data;
        (PropertyTypeCode::LONG): s64 data;
        (PropertyTypeCode::BINARY): {
            u32 dataLength;
            u8 data[dataLength];
        }
        (PropertyTypeCode::STRING): {
            u32 stringLength;
            char string[stringLength];
        }
        (PropertyTypeCode::ARRAY_BOOL): Array<bool> data;
        (PropertyTypeCode::ARRAY_UBYTE): Array<u8> data;
        (PropertyTypeCode::ARRAY_INT): Array<s32> data;
        (PropertyTypeCode::ARRAY_LONG): Array<s64> data;
        (PropertyTypeCode::ARRAY_FLOAT): Array<float> data;
        (PropertyTypeCode::ARRAY_DOUBLE): Array<double> data;
        (_): std::error("Invalid property type code!");
    }
};

struct NodeRecord32 {
    u32 endOffset;
    u32 numProperties;
    u32 propertyListLen;
    u8 nameLen;
    
    // Detect sentinel record which marks the end of a list of node records
    if (endOffset == 0 
        && numProperties == 0 
        && propertyListLen == 0 
        && nameLen == 0) {
        break;
    }
    
    char name[nameLen];
    auto posBeforePropertyRecords = $;
    auto posAfterPropertyRecords = posBeforePropertyRecords + propertyListLen;
    PropertyRecord propertyRecords[numProperties];
    std::assert($ == posAfterPropertyRecords, std::format("Invalid size of propertyRecords @ {:#x} !", posBeforePropertyRecords));
    NodeRecord32 nestedList[while($ < endOffset)];
    std::assert($ == endOffset, std::format("Invalid size of nestedList @ {:#x} !", posAfterPropertyRecords));
};

struct NodeRecord64 {
    u64 endOffset;
    u64 numProperties;
    u64 propertyListLen;
    u8 nameLen;
    
    // Detect sentinel record which marks the end of a list of node records
    if (endOffset == 0 
        && numProperties == 0 
        && propertyListLen == 0 
        && nameLen == 0) {
        break;
    }
    
    char name[nameLen];
    auto posBeforePropertyRecords = $;
    auto posAfterPropertyRecords = posBeforePropertyRecords + propertyListLen;
    PropertyRecord propertyRecords[numProperties];
    std::assert($ == posAfterPropertyRecords, std::format("Invalid size of propertyRecords @ {:#x} !", posBeforePropertyRecords));
    NodeRecord64 nestedList[while($ < endOffset)];
    std::assert($ == endOffset, std::format("Invalid size of nestedList @ {:#x} !", posAfterPropertyRecords));
};

fn assertZero (auto array, u128 size, auto message) {
    bool nonzeroPadding = false;
    
    for (u8 i = 0, i < size, i = i + 1) {
        if (array[i] != 0) {
            nonzeroPadding = true;
        }
    }
    
    std::assert_warn(!nonzeroPadding, message);
};

struct Footer{
    type::Magic<"\xFA\xBC\xAB\x09\xD0\xC8\xD4\x66\xB1\x76\xFB\x83\x1C\xF7\x26\x7E"> footerId;
    char zeroes[4];
    assertZero(zeroes, 4, "Found non-zero values in footer after footerId!");
    u128 ofs = $;
    u8 alignmentPaddingSize = ((ofs + 15) & ~15) - ofs;
    
    if (alignmentPaddingSize == 0) {
        alignmentPaddingSize = 16;
    }
    
    char alignmentPadding[alignmentPaddingSize];
    assertZero(alignmentPadding, alignmentPaddingSize, "Found non-zero bytes in alignmentPadding!");
    u32 version;
    char staticPadding[120];
    assertZero(staticPadding, 120, "Found non-zero bytes in staticPadding!");
    type::Magic<"\xF8\x5A\x8C\x6A\xDE\xF5\xD9\x7E\xEC\xE9\x0C\xE3\x75\x8F\x29\x0B"> footerMagic;
};


struct Header {
    type::Magic<"Kaydara FBX Binary  \x00\x1A\x00"> magic;
    u32 version;
};

struct FBX {
    Header header;
    
    if  (header.version < 7500) {
        NodeRecord32 rootRecords[while(true)];
    } else {
        NodeRecord64 rootRecords[while(true)];
    }
    
    Footer footer;
    std::assert_warn(header.version == footer.version, "Version numbers in header and footer do not match!");
};

FBX fbx @ 0x00;
