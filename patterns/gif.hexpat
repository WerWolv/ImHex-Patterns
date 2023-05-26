#pragma MIME image/gif

// Extension Labels
#define LABEL_GC 0xF9
#define LABEL_COMMENT 0xFE
#define LABEL_APPLICATION 0xFF
#define LABEL_PLAINTEXT 0x01

// Indentifier Magics
#define IMAGE_SEPERATOR_MAGIC 0x2C
#define EXTENSION_INTRODUCER_MAGIC 0x21
#define GIF_TRAILER_MAGIC 0x3B

#include <std/io.pat>
#include <std/core.pat>
#include <std/mem.pat>
#include <std/string.pat>
#include <std/math.pat>

#include <type/magic.pat>

bitfield GCT_Flags {
    size : 3 [[comment("physical size = 2^(flags.size + 1)")]];
    sort : 1 [[comment("Indicates if the table is sorted by importance")]];
    colorRes : 3 [[comment("Indicates the richness of the original pallet")]];
    enabled : 1;
};
    
bitfield ImageDescriptorFlags {
    lctSize: 3;
    reserved: 2;
    lctSort: 1;
    interlaceFlag: 1;
    lctEnable: 1;
};
    
bitfield GCE_Flags {
    transparent : 1;
    userInput : 1;
    disposalMode : 3 [[format("format::dispose_enum")]];
    reserved : 3;
};

struct Color {
  u8 red;
  u8 green;
  u8 blue;
} [[color(std::format("{:02X}{:02X}{:02X}", red, green, blue))]];

struct _SubBlocks {
    u8 data_size;
    u8 data[data_size];
};

struct DataSubBlocks {
    _SubBlocks subBlocks[while(std::mem::read_unsigned($, 1) != 0)];
};

struct Header {
    type::Magic<"GIF"> magic;
    char version[3];
};

struct LogicalScreenDescriptor {
    u16 width;
    u16 height;
    GCT_Flags gctFlags;
    u8 bgColorIndex;
    u8 pixelAscpet;
    if (gctFlags.enabled) {
        Color gct[std::math::pow(2, gctFlags.size + 1)];
    }
};

struct ImageDescriptor {
    u16 imageLeftPosition;
    u16 imageTopPosition;
    u16 imageWidth;
    u16 imageHeight;
    ImageDescriptorFlags flags;
    if(flags.lctEnable) {
        Color lct[std::math::pow(2, flags.lctSize + 1)];
    }
    u8 lzwMinCode [[comment("This byte determines the initial number of bits used for LZW codes in the image data")]];
    DataSubBlocks lzwCompressedData [[comment("Data is pallet indecies either into current LDC or GCT and is compressed using LZW")]];
};

struct CommentExtension {
    DataSubBlocks commentData;
};

struct ApplicationExtension {
    u8 blockSize;
    char identifier[8];
    char authenticationCode[3];
    DataSubBlocks applicationData;
};

struct PlainTextExtension {
    u8 blockSize;
    u16 textGridLeftPos;
    u16 textGridTopPos;
    u16 textGridWidth;
    u16 textGridHeight;
    u8 charCellWidth;
    u8 charCellHeight;
    u8 textForegroundColorIndex;
    u8 textBackgroundColorIndex;
    DataSubBlocks plainTextData;
    
};

struct GraphicControlExtension {
    u8 blockSize;
    std::assert_warn(blockSize == 4, "Unexpected GCE block size");
    GCE_Flags flags;
    u16 delay [[format("format::delay")]];
    u8 transparentColorIndex;
};

struct Extension {
    u8 label [[format("format::extension_name")]];
    if(label == LABEL_GC) GraphicControlExtension gce [[inline]];
    if(label == LABEL_COMMENT) CommentExtension c [[inline]];
    if(label == LABEL_APPLICATION) ApplicationExtension a [[inline]];
    if(label == LABEL_PLAINTEXT) PlainTextExtension p [[inline]];
};

struct Block {
    u8 identifier [[format("format::identifier_name")]];
    if(identifier == IMAGE_SEPERATOR_MAGIC) ImageDescriptor i [[inline]];
    if(identifier == EXTENSION_INTRODUCER_MAGIC) Extension e [[inline]];
    if(identifier == GIF_TRAILER_MAGIC) break;
    u8 blockTerminator;
} [[format("format::block_name")]];

namespace format {
    fn dispose_enum(u8 value) {
        if(value == 0x00) return "Do nothing";
        if(value == 0x01) return "Do not remove pixels";
        if(value == 0x02) return "Restore background pixels";
        if(value == 0x03) return "Restore previous pixels"; 
    };
    
    fn extension_name(u8 label) {
        if(label == LABEL_GC) return "Graphical Control Extension";
        if(label == LABEL_COMMENT) return "Comment Extension";
        if(label == LABEL_APPLICATION) return "Application Extension";
        if(label == LABEL_PLAINTEXT) return "Plaintext Extension";
        return "Unknown Extension";
    };

    fn block_name(ref Block b) {
        if(b.identifier == IMAGE_SEPERATOR_MAGIC) return "Image Descriptor";
        if(b.identifier == EXTENSION_INTRODUCER_MAGIC) return "Extension";
        if(b.identifier == GIF_TRAILER_MAGIC) return "Trailer";
        return "Unknown Block Type";
    };

    fn identifier_name(u8 identifier) {
        if(identifier == IMAGE_SEPERATOR_MAGIC) return "Image Separator";
        if(identifier == EXTENSION_INTRODUCER_MAGIC) return "Extension Introducer";
        if(identifier == GIF_TRAILER_MAGIC) return "GIF Trailer";
        return "Unknown Identifier";
    };

    fn delay(u16 delay) {
        if(delay == -1) return "forever";
        else if(delay < 2) return "100ms";
        else return std::string::to_string(delay * 10) + "ms";
        return "notime";
    };
}

struct Gif {
    Header header;
    std::assert_warn(header.version == "89a" || header.version == "87a", "Unsupported format version");
    LogicalScreenDescriptor logicalScreenDescriptor;
    Block blocks[while(!std::mem::eof())];
};

Gif gif @ 0x00;