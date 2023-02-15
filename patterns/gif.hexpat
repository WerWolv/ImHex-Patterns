#define LABEL_GC 0xF9
#define LABEL_COMMENT 0xFE
#define LABEL_APPLICATION 0xFF
#define LABEL_PLAINTEXT 0x01
#define LABEL_APPLICATION_NETSCAPE "NETSCAPE"
#define CODE_FRAME 0x2C
#define CODE_EXTENSION 0x21
#define CODE_TRAILER 0x3B
#define MAX_BLOCKS 4096
#define GCT_ACCESS parent.parent.parent.parent.header.gct

#include <std/io.pat>
#include <std/core.pat>
#include <std/mem.pat>
#include <std/string.pat>

#pragma MIME image/gif

bitfield GCT_Flags {
    size : 3 [[comment("physical size = 2^(flags.size + 1)")]];
    sort : 1 [[comment("Indicates if the table is sorted by importance")]];
    colorRes : 3 [[comment("Indicates the richness of the original pallet")]];
    enabled : 1;
};
    
bitfield LCT_Flags {
    size : 3 [[comment("physical size = 2^(flags.size + 1)")]];
    padding : 2;
    sort : 1 [[comment("Indicates if the table is sorted by importance")]];
    interlace : 1;
    enable : 1;
};
    
bitfield GC_Flags {
    transparent : 1;
    userInput : 1;
    disposalMode : 3 [[format("format::dispose_enum")]];
    reserved : 3;
};

struct color {
  u8 r, g, b;
} [[color(std::format("{:02X}{:02X}{:02X}", r, g, b))]];

struct subblock {
    u8 size;
    if(size == 0) break;
    u8 data[size];
};

struct block {
   subblock blocks[MAX_BLOCKS];
};

fn exp2(auto n) {
    return 1 << n;
};

struct Header {
    char magic[3];
    char version[3];
    u16 width;
    u16 height;
    GCT_Flags gctFlags;
    u8 bgColorIndex;
    u8 pixelAscpet;
    if (gctFlags.enabled) {
        color gct[(exp2(gctFlags.size + 1))];
        color bgColor = gct[bgColorIndex];
    }
};    

struct frame {
    u16 x;
    u16 y;
    u16 width;
    u16 height;
    LCT_Flags lctFlags;
    if(lctFlags.enable) {
        color lct[(exp2(lctFlags.size + 1))];
    }
    u8 lzwMinCode [[comment("This byte determines the initial number of bits used for LZW codes in the image data")]];
    block lzwCompressedData [[comment("Data is pallet indecies either into current LDC or GCT and is compressed using LZW")]]; 
};

struct comment {
    block data [[hidden]];
    char comment[] @ addressof(data.blocks) + 1; // TODO : need to find a better way of doing this
};

struct application {
    u8 blockSize [[hidden]];
    char identifier[8] [[comment("Only known are: NETSCAPE")]];
    char version[3] [[comment("Only known for NETSCAPE: '2.0'")]];
    block b [[hidden]];
    if(identifier == LABEL_APPLICATION_NETSCAPE) {
        u16 loopcount @ addressof(b.blocks[0].data) + 1 [[comment("0, = Forever")]];
    }
};

struct plaintext {
    u8 blockSize [[hidden]];
    u16 gridLeftPos;
    u16 gridTopPos;
    u16 gridWidth;
    u16 gridHeight;
    u8 cellWidth;
    u8 cellHeight;
    u8 textForegroundColorIndex [[hidden]];
    u8 textBackgroundColorIndex [[hidden]];
    color textForegroundColor @ addressof(GCT_ACCESS[textForegroundColorIndex]);
    color textBackgroundColor @ addressof(GCT_ACCESS[textBackgroundColorIndex]);
    block data [[hidden]];
    char text[] @ addressof(data.blocks) + 1;
    //char text[data.blocks[std::core::array_index()].size] @ addressof(data.blocks[std::core::array_index()].data);
};

struct graphical_control {
    u8 blockSize [[hidden]];
    GC_Flags flags;
    u16 delay [[format("format::delay")]];
    u8 transparentColorIndex;
    block b [[hidden]];
};

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

    fn content_name(ref frame f) {
        if(f.code == CODE_FRAME) return "Frame";
        if(f.code == CODE_EXTENSION) return "Extension";
        if(f.code == CODE_TRAILER) return "End";
        return "Unknown Content";
    };

    fn delay(u16 delay) {
        if(delay == -1) return "forever";
        else if(delay < 2) return "100ms";
        else return std::string::to_string(delay * 10) + "ms";
        return "notime";
    };
}

struct extension {
   u8 label [[format("format::extension_name")]];
   if(label == LABEL_GC) graphical_control gc [[inline]];
   if(label == LABEL_COMMENT) comment c [[inline]];
   if(label == LABEL_APPLICATION) application a [[inline]];
   if(label == LABEL_PLAINTEXT) plaintext [[inline]];
};

struct content {
    u8 code [[hidden]];
    if(code == CODE_FRAME) frame f [[inline]];
    if(code == CODE_EXTENSION) extension e [[inline]];
    if(code == CODE_TRAILER) break;
} [[format("format::content_name")]];

struct Data {
   content contents[while(!std::mem::eof())] [[inline]];
};

struct Gif {
    Header header;
    Data data;
};

Gif gif @ 0x00;