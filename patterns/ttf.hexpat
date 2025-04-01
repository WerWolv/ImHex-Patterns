#pragma author Shimogawa (aka Rebuild)
#pragma description TrueType/OpenType font
#pragma endian big
#pragma MIME font/ttf
#pragma MIME font/otf

#pragma pattern_limit 1000000

import std.mem;
import std.string;
import std.time;
import std.io;
import type.magic;

struct TableDirectory {
    char tag[4];
    u32 checkSum;
    u32 offset;
    u32 length;
};

fn format_fixed32(auto fp32) {
    return fp32.integer + fp32.fraction / 65536.0;
};

fn format_f2dot14(auto f) {
    return f.integer + f.fraction / 16384.0;
};

using FWord = s16;
using UFWord = u16;

struct FixedPoint32 {
    u16 integer;
    u16 fraction;
} [[format("format_fixed32")]];

bitfield F2Dot14 {
    integer : 2;
    fraction : 14;
} [[format("format_f2dot14")]];

fn format_longdatetime(auto t) {
    return std::time::format(std::time::to_utc(u32(t.time - 2082844800)));
};

struct LongDatetime {
    s64 time;
} [[format("format_longdatetime")]];


u64 currentOffset;
u64 currentLength;
u64 glyfStart;
bool hasPostScriptOutlines = false;
u16 numHMetrics;
u16 gNumGlyphs;
s16 indexToLocFormat;

// begin avar

struct AxisValueMap {
    F2Dot14 fromCoord;
    F2Dot14 toCoord;
};

struct ShortFracSegment {
    u16 positionMapCount;
    AxisValueMap axisValueMaps[positionMapCount];
};

struct AvarTable {
    FixedPoint32 version;
    s32 axisCount;
    ShortFracSegment segments[axisCount];
};

// end avar

// begin cmap

u64 startOfCmapTable = 0;

struct BaseCmapSubtable {
    u64 start = $;
    u16 format;
};

struct CmapSubtable0 : BaseCmapSubtable {
    u16 length;
    u16 language;
    u8 glyphIndexArr[256];
};

struct CmapSubtable2 : BaseCmapSubtable {
    u16 length;
    u16 language;
    u16 subHeaderKeys[256];
    u8 data[length - 516];
};

struct CmapSubtable4 : BaseCmapSubtable {
    u16 length;
    u64 end = start + length;
    u16 language;
    u16 segCountX2;
    u16 segCount = segCountX2 / 2;
    u16 searchRange;
    u16 entrySelector;
    u16 rangeShift;
    u16 endCode[segCount];
    u16 reserved;
    u16 startCode[segCount];
    s16 idDelta[segCount];
    u16 idRangeOffset[segCount];
    u16 glyphIdArr[(end - $) / sizeof(u16)];
};

struct CmapSubtable6 : BaseCmapSubtable {
    u16 length;
    u16 language;
    u16 firstCode;
    u16 entryCount;
    u16 glyphIdArr[entryCount];
};

struct SequentialMapGroup {
    u32 startCharCode;
    u32 endCharCode;
    u32 startGlyphId;
};

struct CmapSubtable8 : BaseCmapSubtable {
    u16 reserved;
    u32 length;
    u32 language;
    u8 is32[8192];
    u32 numGroups;
    SequentialMapGroup groups[numGroups];
};

struct CmapSubtable10 : BaseCmapSubtable {
    u16 reserved;
    u32 length;
    u64 end = start + length;
    u32 language;
    u32 startCharCode;
    u32 numChars;
    u16 glyphIdArr[(end - $) / sizeof(u16)];
};

struct CmapSubtable12 : BaseCmapSubtable {
    u16 reserved;
    u32 length;
    u32 language;
    u32 numGroups;
    SequentialMapGroup groups[numGroups];
};

struct CmapSubtable {
    u16 format = std::mem::read_unsigned($, 2, std::mem::Endian::Big);

    match (format) {
        (0): CmapSubtable0 table [[inline]];
        (2): CmapSubtable2 table [[inline]];
        (4): CmapSubtable4 table [[inline]];
        (6): CmapSubtable6 table [[inline]];
        (8): CmapSubtable8 table [[inline]];
        (10): CmapSubtable10 table [[inline]];
        (12): CmapSubtable12 table [[inline]];
        (_): BaseCmapSubtable table [[inline]];
    }
} [[name(std::format("Subtable Format {}", format))]];

enum CmapPlatform : u16 {
    Unicode = 0,
    Macintosh = 1,
    ISO = 2,
    Microsoft = 3,
    Custom = 4,
};

struct EncodingRecord {
    CmapPlatform platformId;
    u16 encodingId;
    u32 offset;

    CmapSubtable subtable @ startOfCmapTable + offset;
};

struct CmapTable {
    startOfCmapTable = $;
    u16 version;
    u16 numSubtables;
    EncodingRecord encodingRecords[numSubtables];
};

// end cmap

// begin cvt

struct CvtTable {
    u64 size = currentLength / sizeof(FWord);
    FWord controlValues[size];
};

// end cvt

// begin gasp

bitfield RangeGaspBehavior {
    padding : 12;
    symmetricSmoothing : 1;
    symmetricGridfit : 1;
    doGray : 1;
    gridFit : 1;
};

struct GaspRange {
    u16 rangeMaxPPEM;
    RangeGaspBehavior rangeGaspBehavior;
};

struct GaspTable {
    u16 version;
    u16 numRanges;
    GaspRange gaspRanges[numRanges];
};

// end gasp

// begin glyf

struct GlyphTableHeader {
    u64 startOffset = $;
    s16 numContours;
    FWord xMin;
    FWord yMin;
    FWord xMax;
    FWord yMax;
};

bitfield OutlineFlag {
    padding : 2;
    ySameOrPositive : 1;
    xSameOrPositive : 1;
    repeat : 1;
    yShort : 1;
    xShort : 1;
    onCurve : 1;
};

u32 pIdx = 0;
u32 curGlyfSize;

struct SimpleGlyphFlag {
    pIdx += 1;
    OutlineFlag flag;
    if (flag.repeat) {
        pIdx += 1;
        u8 repeatTimes;
    }
};

struct SimpleGlyphTable : GlyphTableHeader {
    u16 endPtsOfContours[numContours];
    u32 numPoints = numContours == 0 ? 0 : endPtsOfContours[numContours - 1];
    u16 instructionLength;
    u8 instructions[instructionLength];
    pIdx = 0;
    SimpleGlyphFlag flags[while(pIdx < numPoints)] [[single_color]];
    u8 data[startOffset + curGlyfSize - $];
};

bitfield CompositeGlyphFlag {
    padding : 3;
    unscaledComponentOffset : 1;
    scaledComponentOffset : 1;
    overlapCompound : 1;
    useMyMetrics : 1;
    weHaveInstructions : 1;
    weHaveA2x2 : 1;
    weHaveAnXAndYScale : 1;
    moreComponents : 1;
    padding : 1;
    weHaveAScale : 1;
    roundXYToGrid : 1;
    argsAreXYValues : 1;
    arg1And2AreWords : 1;
};

bool componentGlyphHasMoreComponents;
bool componentGlyphHasInstruction;

struct ComponentGlyphRecord {
    CompositeGlyphFlag flags;
    u16 glyphIndex;
    if (flags.arg1And2AreWords) {
        FWord arg1;
        FWord arg2;
    } else {
        u8 arg1;
        u8 arg2;
    }
    if (flags.weHaveAScale) {
        F2Dot14 scale;
    } else if (flags.weHaveAnXAndYScale) {
        F2Dot14 xScale;
        F2Dot14 yScale;
    } else if (flags.weHaveA2x2) {
        F2Dot14 xScale;
        F2Dot14 scale01;
        F2Dot14 scale10;
        F2Dot14 yScale;
    }
    componentGlyphHasMoreComponents = flags.moreComponents;
    componentGlyphHasInstruction = flags.weHaveInstructions;
};

struct CompositeGlyphTable : GlyphTableHeader {
    componentGlyphHasMoreComponents = true;
    componentGlyphHasInstruction = false;
    ComponentGlyphRecord records[while (componentGlyphHasMoreComponents)];
    if (componentGlyphHasInstruction) {
        u16 instructionLength;
        u8 instructions[instructionLength];
    }
};

struct GlyfTable {
    s16 type = std::mem::read_signed($, 2, std::mem::Endian::Big);

    if (type >= 0) {
        SimpleGlyphTable table [[inline]];
    } else {
        CompositeGlyphTable table [[inline]];
    }
} [[name(std::format("glyf ({})", table.numContours < 0 ? "Composite" : "Simple"))]];

// end glyf

// begin hdmx

struct DeviceRecord {
    u8 pixelSize;
    u8 maxWidth;
    u8 widths[gNumGlyphs];
};

struct HdmxTable {
    u16 version;
    u16 numRecords;
    u32 sizeDeviceRecord;
    DeviceRecord records[numRecords];
};

// end hdmx

// begin head

bitfield HeadFlag {
    padding : 1;
    lastResort : 1;
    clearTypeOptimized : 1;
    converted : 1;
    lossless : 1;
    indicStyleRearr : 1;
    RTLGlyph : 1;
    AATFont : 1;
    linguisticRender : 1;
    padding : 1;
    verticalLayout : 1;
    instrMayAlterAW : 1;
    integerScaling : 1;
    differentPointSize : 1;
    xLBlackBitIsLSB : 1;
    yZeroIsBaseline : 1;
};

bitfield MacStyle {
    padding : 9;
    extended : 1;
    condensed : 1;
    shadow : 1;
    outline : 1;
    underline : 1;
    italic : 1;
    bold : 1;
};

struct HeadTable {
    FixedPoint32 version;
    FixedPoint32 fontRevision;
    u32 checksumAdjustment;
    type::Magic<"\x5f\x0f\x3c\xf5"> magicNumber;
    HeadFlag flags;
    u16 unitsPerEm;
    LongDatetime created;
    LongDatetime modified;
    FWord xMin;
    FWord yMin;
    FWord xMax;
    FWord yMax;
    MacStyle macStyle;
    u16 lowestRecPPEM;
    s16 fontDirectionHint;
    s16 indexToLocFormat;
    s16 glyphDataFormat;
};

// end head

// begin hhea

struct HheaTable {
    FixedPoint32 version;
    FWord ascent;
    FWord descent;
    FWord lineGap;
    UFWord advanceWidthMax;
    FWord minLeftSideBearing;
    FWord minRightSideBearing;
    FWord xMaxExtent;
    s16 caretSlopeRise;
    s16 caretSlopeRun;
    s16 caretOffset;
    s16 reserved[4];
    s16 metricDataFormat;
    u16 numberOfHMetrics;
    numHMetrics = numberOfHMetrics;
};

// end hhea

// begin hmtx

struct LongHorMetric {
    UFWord advanceWidth;
    FWord lsb;
};

struct HmtxTable {
    LongHorMetric hMetrics[numHMetrics];
    FWord leftSideBearings[gNumGlyphs - numHMetrics];
};

// end hmtx

// begin loca

// loca contains offsets for glyf tables, so
// we put glyf arrays here also.

struct GlyfWithOffset<auto longOffset> {
    if (longOffset) {
        u32 offset;
        u32 realOffset = offset;
        u32 nextOff = std::mem::read_unsigned($, 4, std::mem::Endian::Big);
    } else {
        u16 offset;
        u32 realOffset = u32(offset) * 2;
        u32 nextOff = u32(std::mem::read_unsigned($, 2, std::mem::Endian::Big)) * 2;
    }
    curGlyfSize = nextOff - realOffset;
    if (curGlyfSize != 0) {
        GlyfTable glyf @ glyfStart + realOffset;
    }
};

struct LocaTable {
    if (indexToLocFormat == 1) {
        //u32 offsets[gNumGlyphs + 1];
        GlyfWithOffset<true> glyfs[gNumGlyphs];
    } else {
        // u16 offsets[gNumGlyphs + 1];
        GlyfWithOffset<false> glyfs[gNumGlyphs];
    }
};

// end loca

// begin maxp

struct MaxpTable {
    FixedPoint32 version;
    u16 numGlyphs;
    gNumGlyphs = numGlyphs;
    if (!hasPostScriptOutlines) {
        u16 maxPoints;
        u16 maxContours;
        u16 maxComponentPoints;
        u16 maxComponentContours;
        u16 maxZones;
        u16 maxTwilightPoints;
        u16 maxStorage;
        u16 maxFunctionDefs;
        u16 maxInstructionDefs;
        u16 maxStackElements;
        u16 maxSizeOfElements;
        u16 maxComponentDepth;
    }
};

// end maxp

// begin name

u64 curStorageOffset;

struct NameRecord {
    u16 platformId;
    u16 encodingId;
    u16 languageId;
    u16 nameId;
    u16 length;
    u16 stringOffset;
    char16 string[length / 2] @ curStorageOffset + stringOffset;
};

struct LangTagRecord {
    u16 length;
    u16 langTagOffset;
    char16 langTag[length / 2] @ curStorageOffset + langTagOffset;
};

struct NameTableV0 {
    u64 startOfNameTable = $;
    u16 version;
    u16 count;
    u16 storageOffset;
    curStorageOffset = startOfNameTable + storageOffset;
    NameRecord nameRecords[count];
};

struct NameTableV1 : NameTableV0 {
    u16 langTagCount;
    LangTagRecord langTagRecords[langTagCount];
};

struct NameTable {
    u16 version = std::mem::read_unsigned($, 2, std::mem::Endian::Big);

    match (version) {
        (0): NameTableV0 table [[inline]];
        (_): NameTableV1 table [[inline]];
    }
};

// end name

// begin OS/2

struct OS2TableV0 {
    u16 version;
    FWord xAvgCharWidth;
    u16 usWeightClass;
    u16 usWidthClass;
    u16 fsType;
    FWord ySubscriptXSize;
    FWord ySubscriptYSize;
    FWord SubscriptXOffset;
    FWord SubscriptYOffset;
    FWord ySuperscriptXSize;
    FWord ySuperscriptYSize;
    FWord SuperscriptXOffset;
    FWord SuperscriptYOffset;
    FWord yStrikeoutSize;
    FWord yStrikeoutPosition;
    s16 sFamilyClass;
    u8 panose[10];
    u32 ulUnicodeRange[4];
    u8 achVendID[4];
    u16 fsSelection;
    u16 usFirstCharIndex;
    u16 usLastCharIndex;
    FWord sTypoAscender;
    FWord sTypoDescender;
    FWord sTypoLineGap;
    UFWord usWinAscent;
    UFWord usWinDescent;
};

struct OS2TableV1 : OS2TableV0 {
    u32 ulCodePageRange[2];
};

struct OS2TableV4 : OS2TableV1 {
    FWord sxHeight;
    FWord sCapHeight;
    u16 usDefaultChar;
    u16 usBreakChar;
    u16 usMaxContent;
};

struct OS2TableV5 : OS2TableV4 {
    u16 usLowerOpticalPointSize;
    u16 usUpperOpticalPointSize;
};

struct OS2Table {
    u16 version = std::mem::read_unsigned($, 2, std::mem::Endian::Big);

    match (version) {
        (0): OS2TableV0 table [[inline]];
        (1): OS2TableV1 table [[inline]];
        (2 | 3 | 4): OS2TableV4 table [[inline]];
        (_): OS2TableV5 table [[inline]];
    }
};

// end OS/2

// begin post

struct PostTableV1 {
    u64 startOfTable = $;
    FixedPoint32 version;
    FixedPoint32 italicAngle;
    FWord underlinePosition;
    FWord underlineThickness;
    u32 isFixedPitch;
    u32 minMemType42;
    u32 maxMemType42;
    u32 minMemType1;
    u32 maxMemType1;
};

struct PostTableV2 : PostTableV1 {
    u16 numGlyphs;
    u16 glyphNameIndex[numGlyphs];
    std::string::SizedString<u8> stringData[while ($ < startOfTable + currentLength)];
};

struct PostTable {
    u16 major = std::mem::read_unsigned($, 2, std::mem::Endian::Big);
    u16 minor = std::mem::read_unsigned($ + 2, 2, std::mem::Endian::Big);

    match (major, minor) {
        (2, 0): PostTableV2 table [[inline]];
        (_, _): PostTableV1 table [[inline]];
    }
};

// end post

struct HiddenForPreprocessing {
    u64 defStart = $;
    TableDirectory td;
    $ = td.offset;
    currentOffset = td.offset;
    currentLength = td.length;
    match (td.tag) {
        ("CFF "): {
            hasPostScriptOutlines = true;
        }
        ("maxp"): MaxpTable table;
        ("head"): {
            HeadTable table;
            indexToLocFormat = table.indexToLocFormat;
        }
        ("glyf"): {
            glyfStart = $;
        }
    }
    $ = defStart + sizeof(TableDirectory);
} [[hidden]];

struct Table {
    u64 defStart = $;
    TableDirectory td [[inline]];
    $ = td.offset;
    currentOffset = td.offset;
    currentLength = td.length;
    match (td.tag) {
        ("avar"): AvarTable table;
        ("bhed"): HeadTable table;
        ("cmap"): CmapTable table;
        ("cvt "): CvtTable table;
        ("gasp"): GaspTable table;
        // ("glyf"): GlyfTable table;
        // glyf will be contained in loca.
        ("glyf"): {}
        ("hdmx"): HdmxTable table;
        ("head"): HeadTable table;
        ("hhea"): HheaTable table;
        ("hmtx"): HmtxTable table;
        ("loca"): LocaTable table;
        ("maxp"): MaxpTable table;
        ("name"): NameTable table;
        ("OS/2"): OS2Table table;
        ("post"): PostTable table;
        (_): u8 data[td.length];
    }
    $ = defStart + sizeof(TableDirectory);
} [[name(std::format("Table({})", td.tag))]];


struct TTF {
    u32 scalarType;
    u16 numTables;
    u16 searchRange;
    u16 entrySelector;
    u16 rangeShift;

    HiddenForPreprocessing hidden[numTables] @ $ [[hidden]];

    Table tables[numTables];
};

TTF ttf @ 0x0;
