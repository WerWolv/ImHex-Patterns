#pragma description SUP Bluray Subtitle

#pragma magic [ 50 47 ] @ 0x00
#pragma endian big

import std.mem;

enum SegmentType : u8{
    PaletteDefinitionSegment=0x14,
    ObjectDefinitionSegment=0x15,
    PresentationCompositionSegment=0x16,
    WindowDefinitionSegment=0x17,
    END=0x80
};



enum CompositionState : u8 {
    Normal=0x00,
    AcquisitionPoint=0x40,
    EpochStart=0x80
};
enum PaletteUpdateFlag : u8 {
    False=0x00,
    True=0x80
};
enum ObjectCroppedFlag : u8{
    True=0x40,
    False=0x00
};
struct CompositionObject{
    u16 objectID;
    u8 windowID;
    ObjectCroppedFlag objectCroppedFlag;
    u16 objectHorizontalPosition;
    u16 objectVerticalPosition;
    if (objectCroppedFlag == ObjectCroppedFlag::True){
        u16 objectCroppingHorizontalPosition;
        u16 objectCroppingVerticalPosition;
        u16 objectCroppingWidth;
        u16 objectCroppingHeight;
    }
};
struct PresentationCompositionSegment{
    u16 width;
    u16 height;
    u8 framerate;
    u16 compositionNumber;
    CompositionState compositionState;
    PaletteUpdateFlag paletteUpdateFlag;
    u8 paletteID;
    u8 numberOfCompositionObjects;
    CompositionObject compositionObject[numberOfCompositionObjects];
};


struct WindowDefinitionSegment{
    u8 numberOfWindows;
    u8 windowID;
    u16 windowHorizontalPosition;
    u16 windowVerticalPosition;
    u16 windowWidth;
    u16 windowHeight;
};

fn paletteCount(){
    u64 len = (parent.parent.header.segmentSize-7)/5+1;
    return len;
};
struct PaletteEntry{
    u8 paletteEntryID;
    u8 luminance;
    u8 colorDifferenceRed [[color("FF0000")]];
    u8 colorDifferenceBlue [[color("0000FF")]];
    u8 Transparency;
};
struct PaletteDefinitionSegment{
    u8 paletteID;
    u8 paletteVersionNumber;
    PaletteEntry paletteEntry[paletteCount()];
};


enum LastInSequenceFlag : u8{
    LastInSequence=0x40,
    FirstInSequence=0x80,
    FirstAndLastsInSequence=0xC0
};
struct ObjectDefinitionSegment{
    u16 objectID;
    u8 objectVersionNumber;
    LastInSequenceFlag lastInSequenceFlag;
    u24 objectDataLength;
    //u16 width;
    //u16 height;
    u8 objectData[objectDataLength];
};


struct PGSHeader{
    char magicNumber[2];
    u32 presentationTimeStamp;
    u32 decodingTimeStamp;
    SegmentType segmentType;
    u16 segmentSize;
};

struct PGSSegment{
    PGSHeader header;
    match(header.segmentType){
        (0x14): PaletteDefinitionSegment paletteDefinitionSegment;
        (0x15): ObjectDefinitionSegment objectDefinitionSegment;
        (0x16): PresentationCompositionSegment presentationCompositionSegment;
        (0x17): WindowDefinitionSegment windowDefinitionSegment;
    }
};


PGSSegment pgsSegment[while(!std::mem::eof())] @ 0;