#pragma author sakharov-me

#pragma description Tektronix waveform file
#pragma endian little
#pragma magic [ 0F 0F 3A 57 46 4D 23 30 30 ] @ 0x00

//based on https://download.tek.com/manual/077022005Web_1.pdf

import type.base;
import std.mem;
import std.math;

enum Endian_t : u16 {
    PPC = 0xF0F0, // big endian (TODO)
    Intel = 0x0F0F, //little endian
};

struct WaveformStaticFileInformation {
    Endian_t ByteOrderVerification;
    char VersionNumber[8];
    u8 NumberOfDigitsInByteCount;
    s32 NumberOfBytesToTheEndOfFile;
    u8 NumberOfBytesPerPoint;
    s32 ByteOffsetToBeginningOfCurveBuffer;
    s32 HorizontalZoomScaleFactor; //Not for use.
    float HorizontalZoomPosition; //Not for use.
    double VerticalZoomScaleFactor; //Not for use.
    float VerticalZoomPosition; //Not for use.
    char WaveformLabel[32];
    u32 N;
    u16 SizeOfTheWaveformHeader;
};

enum WaveformSetType_t : s32 {
    SingleWaveformSet = 0,
    FastFrameSet = 1,
};

enum DataType_t: s32 {
    WFMDATA_SCALAR_MEAS = 0,
    WFMDATA_SCALAR_CONST = 1,
    WFMDATA_VECTOR = 2,
    WFMDATA_INVALID = 3,
    WFMDATA_WFMDB = 4,
    WFMDATA_DIGITAL = 5,
};

enum PixMapDisplayFormat_t: s32 {
    DSY_FORMAT_INVALID = 0,
    DSY_FORMAT_YT = 1,
    DSY_FORMAT_XY = 2,
    DSY_FORMAT_XYZ = 3,
};

enum SummaryFrameType_t: u16 {
    SUMMARY_FRAME_OFF = 0,
    SUMMARY_FRAME_AVERAGE = 1,
    SUMMARY_FRAME_ENVELOPE = 2,
};

struct ReferenceFileData {
    WaveformSetType_t SetType;
    u32 WfmCnt;
    u64 AcquisitionCounter; //Not for use.
    u64 TransactionCounter; //Not for use.
    s32 SlotID; //Not for use.
    s32 IsStaticFlag; //Not for use.
    u32 WfmUpdateSpecificationCount;
    u32 ImpDimRefCount;
    u32 ExpDimRefCount;
    DataType_t DataType;
    u64 GenPurposeCounter; //Not for use.
    u32 AccumulatedWaveformCount; //Not for use.
    u32 TargetAccumulationCount; //Not for use.
    u32 CurveRefCount;
    u32 NumberOfRequestedFastFrames;
    u32 NumberOfAcquiredFastFrames;
    if (std::mem::read_unsigned(0x09, 1) >= 0x32) {
        SummaryFrameType_t SummaryFrameType;
    }
    PixMapDisplayFormat_t PixMapDisplayFormat;
    u64 PixMapMaxValue;
};

enum Format_t : s32 {
    EXPLICIT_INT16 = 0,
    EXPLICIT_INT32 = 1,
    EXPLICIT_UINT32 = 2,
    EXPLICIT_UINT64 = 3,
    EXPLICIT_FP32 = 4,
    EXPLICIT_FP64 = 5,
    EXPLICIT_UINT8 = 6, //EXPLICIT_INVALID_FORMAT = 6 for v2 and v1
    EXPLICIT_INT8 = 7,
    EXPLICIT_INVALID_FORMAT = 8
};

enum StorageType_t : s32 {
    EXPLICIT_SAMPLE = 0,
    EXPLICIT_MIN_MAX = 1,
    EXPLICIT_VERT_HIST = 2,
    EXPLICIT_HOR_HIST = 3,
    EXPLICIT_ROW_ORDER = 4,
    EXPLICIT_COLUMN_ORDER = 5,
    EXPLICIT_INVALID_STORAGE = 6,
};

struct ExplicitDimensionDescriptionInfo {
    double DimScale;
    double DimOffset;
    u32 DimSize;
    char Units[20];
    double DimExtentMin;
    double DimExtentMax;
    double DimResolution;
    double DimRefPoint;
    Format_t Format;
    StorageType_t StorageType;
    u32 NValue;
    u32 OverRange;
    u32 UnderRange;
    s32 HighRange;
    u32 LowRange;
};

struct ImplictDimensionDescriptionInfo {
    double DimScale;
    double DimOffset;
    u32 DimSize;
    char Units[20];
    double DimExtentMin;
    double DimExtentMax;
    double DimResolution;
    double DimRefPoint;
    u32 Spacing;
};

struct UserView {
    double UserScale;
    char UserUnits[20];
    double UserOffset;
    if(std::mem::read_unsigned(0x09, 1) >= 0x33) {
        double PointDensity;
    } else {
        u32 PointDensity;
    }
    double HRef;
    double TrigDelay;
};

struct ExplicitDimension {
    ExplicitDimensionDescriptionInfo ExplicitDimensionDescriptionInfo;
    UserView UserView;
};

struct ImplictDimension {
    ImplictDimensionDescriptionInfo ImplictDimensionDescriptionInfo;
    UserView UserView;
};

enum Sweep_t: s32 {
    SWEEP_ROLL = 0,
    SWEEP_SAMPLE = 1,
    SWEEP_ET = 2,
    SWEEP_INVALID = 3
};

enum TypeOfBase_t: s32 {
    BASE_TIME = 0,
    BASE_SPECTRAL_MAG = 1,
    BASE_SPECTRAL_PHASE = 2,
    BASE_INVALID = 3
};

struct TimeBase {
    u32 RealPointSpacing;
    Sweep_t Sweep;
    TypeOfBase_t TypeOfBase;
};

struct WfmUpdateSpec {
    u32 RealPointOffset;
    double TTOffset;
    double FracSec;
    u32 GmtSec;
};

enum WfmCurveflag: u8 {
    YES = 0,
    NO = 1,
    MAYBE = 2,
};

bitfield StateFlags_t {
    WfmCurveflag flagOver : 2;
    WfmCurveflag flagUnder : 2;
    WfmCurveflag flagValid : 2;
    WfmCurveflag flagNulls : 2;
    padding: 24;
};

enum TypeOfCheckSum_t: s32 {
    NO_CHECKSUM = 0,
    CTYPE_CRC16 = 1,
    CTYPE_SUM16 = 2,
    CTYPE_CRC32 = 3,
    CTYPE_SUM32 = 4
};

struct WfmCurveObject {
    StateFlags_t StateFlags;
    TypeOfCheckSum_t TypeOfCheckSum;
    u16 CheckSum;
    u32 PrechargeStartOffset;
    u32 DataStartOffset;
    u32 PostchargeStartOffset;
    u32 PostchargeStopOffset;
    u32 EndOfCurveBufferOffset;
};

struct WaveformHeader {
    ReferenceFileData ReferenceFileData;
    ExplicitDimension ExplicitDimension1;
    ExplicitDimension ExplicitDimension2;
    ImplictDimension ImplictDimension1;
    ImplictDimension ImplictDimension2;
    TimeBase Info1;
    TimeBase Info2;
    WfmUpdateSpec WfmUpdateSpec;
    WfmCurveObject WfmCurveObject;
};

struct SubCurve<Type, auto WfmCurveObject> {
    auto pe_lb = WfmCurveObject.DataStartOffset - WfmCurveObject.PrechargeStartOffset;
    auto dt_lb = WfmCurveObject.PostchargeStartOffset - WfmCurveObject.DataStartOffset;
    auto ps_lb = WfmCurveObject.PostchargeStopOffset - WfmCurveObject.PostchargeStartOffset;
    
    Type Precharge[pe_lb / sizeof(Type)];
    Type Data[dt_lb / sizeof(Type)];
    Type Postcharge[ps_lb / sizeof(Type)];
} [[inline]];

struct Curve<auto TypeCode, auto WfmCurveObject> {
    if(TypeCode == Format_t::EXPLICIT_INT16)  { SubCurve <s16,    WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_INT32)  { SubCurve <s32,    WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_UINT32) { SubCurve <u32,    WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_UINT64) { SubCurve <u64,    WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_FP32)   { SubCurve <float,  WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_FP64)   { SubCurve <double, WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_UINT8)  { SubCurve <u8,     WfmCurveObject>; }
    if(TypeCode == Format_t::EXPLICIT_INT8)   { SubCurve <s8,     WfmCurveObject>; }
};

fn format_checksum(u32 val) {
    u64 checksum_calculated = std::math::accumulate(0, $, 1);
    if (val == checksum_calculated) {
        return std::format("0x{:08X} (OK)", val);
    } else {
        return std::format("0x{:08X} (INVALID, expected 0x{:08X})", val, checksum_calculated);
    }
};

struct TekmetaEntry {
    u32 key_name_len;
    char key_name[key_name_len];
    u8 value_type;
    if (value_type == 1) { u32 value_len; u8 value[value_len]; }
    else if (value_type == 2) { u32 value; }
    else if (value_type == 3) { double value; }
    else { u8 value[0]; /* undefined type, alarm */ }
}[[format("format_tekmeta_entry")]];

fn format_tekmeta_entry(TekmetaEntry val) {
    return std::format("{} = {}", val.key_name, val.value);
};

struct Tekmeta {
    char magik[8];
    u32 records_count;
    TekmetaEntry records[records_count];
};

struct Mark {
    double Start;
    double Focus;
    double ZoomFactor;
    double End;
    char Label[33];
};

struct Marks {
    char MarkInformationStart[8];
    s32 NumberOfBytesToTheEndOfTheMarkInformation;
    s32 MarkVersionNumber;
    s32 NumberOfMmarks;
    Mark mark[NumberOfMmarks];
    u64 checksum;
    u64 checksum2;
};

struct Wfm {
    WaveformStaticFileInformation StaticFileInformation;
    WaveformHeader Header;
    
    //FastFrame frames (TODO: check validity, never seen them)
    WfmUpdateSpec WfmUpdateSpecObject[StaticFileInformation.N];
    WfmCurveObject WfmCurveSpecObject[StaticFileInformation.N];
    
    //describe single guaranteed curve
    Curve <Header.ExplicitDimension1.ExplicitDimensionDescriptionInfo.Format, Header.WfmCurveObject> Curve;
    
    //todo: mark all the rest curves if present
    
    u64 checksum  [[format("format_checksum")]];
        
    //TODO: before or after tekmeta?
    if(std::mem::read_string($, 8) == "MARKS") {
        Marks Marks;
    }
    
    if(std::mem::read_string($, 8) == "tekmeta!") {
        Tekmeta Tekmeta;
    }
} [[inline]];

Wfm wfm @0;
