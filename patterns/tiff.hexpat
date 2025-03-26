#pragma description Tag Image File Format (TIFF)

#pragma MIME image/tiff

#pragma eval_depth 100

import std.io;
import std.mem;
import std.string;
import std.core;

char Magic[2] @ 0 [[hidden]];
match (Magic) {
    ("II"): std::core::set_endian(std::mem::Endian::Little);
    ("MM"): std::core::set_endian(std::mem::Endian::Big);
    (_): std::error(std::format("Unrecognized magic number: {}", Magic));
}

u16 Version @ 2 [[hidden]];
u32 ValueOffsetSize;
match (Version) {
    (42): ValueOffsetSize = 4;
    (43): ValueOffsetSize = 8;
    (_): std::error(std::format("Unrecognized version: {}", Version));
}
struct Big<T> {
    match (Version) {
        (42): T V;
        (43): u64 V;
        (_): std::error(std::format("Unrecognized version: {}", Version));
    }
} [[sealed, format_read("format_read_big"), format_write("format_write_big"), transform("transform_big")]];
fn format_read_big(auto v) {
    return std::format("{} (0x{:X})", v, v);
};
fn format_write_big(str v) {
    return std::string::parse_int(v, 0);
};
fn transform_big(auto v) {
    return v.V;
};

struct TIFFHeader {
    char Magic[2];
    u16 Version;
    if (Version > 42) {
        u16 OffsetSize;
        padding[2];
    }
    Big<u32> Offset;
};

enum TIFFFieldType : u16 {
    BYTE = 1,
    ASCII = 2,
    SHORT = 3,
    LONG = 4,
    RATIONAL = 5,
    SBYTE = 6,
    UNDEFINED = 7,
    SSHORT = 8,
    SLONG = 9,
    SRATIONAL = 10,
    FLOAT = 11,
    DOUBLE = 12,
    LONG8 = 16,
    SLONG8 = 17,
};

struct TIFFRational<T> {
    T Numerator;
    T Denominator;
} [[format_read("format_read_rational")]];

fn format_read_rational(auto r) {
    return std::format("{}/{}", r.Numerator, r.Denominator);
};

enum TIFFTag : u16 {
    NewSubfileType = 0x00FE,
    SubfileType = 0x00FF,
    ImageWidth = 0x0100,
    ImageLength = 0x0101,
    BitsPerSample = 0x0102,
    Compression = 0x0103,
    PhotometricInterpretation = 0x0106,
    Threshholding = 0x0107,
    CellWidth = 0x0108,
    CellLength = 0x0109,
    FillOrder = 0x010A,
    DocumentName = 0x010D,
    ImageDescription = 0x010E,
    Make = 0x010F,
    Model = 0x0110,
    StripOffsets = 0x0111,
    Orientation = 0x0112,
    SamplesPerPixel = 0x0115,
    RowsPerStrip = 0x0116,
    StripByteCounts = 0x0117,
    MinSampleValue = 0x0118,
    MaxSampleValue = 0x0119,
    XResolution = 0x011A,
    YResolution = 0x011B,
    PlanarConfiguration = 0x011C,
    PageName = 0x011D,
    XPosition = 0x011E,
    YPosition = 0x011F,
    FreeOffsets = 0x0120,
    FreeByteCounts = 0x0121,
    GrayResponseUnit = 0x0122,
    GrayResponseCurve = 0x0123,
    T4Options = 0x0124,
    T6Options = 0x0125,
    ResolutionUnit = 0x0128,
    PageNumber = 0x0129,
    TransferFunction = 0x012D,
    Software = 0x0131,
    DateTime = 0x0132,
    Artist = 0x013B,
    HostComputer = 0x013C,
    Predictor = 0x013D,
    WhitePoint = 0x013E,
    PrimaryChromaticities = 0x013F,
    ColorMap = 0x0140,
    HalftoneHints = 0x0141,
    TileWidth = 0x0142,
    TileLength = 0x0143,
    TileOffsets = 0x0144,
    TileByteCounts = 0x0145,
    InkSet = 0x014C,
    InkNames = 0x014D,
    NumberOfInks = 0x014E,
    DotRange = 0x0150,
    TargetPrinter = 0x0151,
    ExtraSamples = 0x0152,
    SampleFormat = 0x0153,
    SMinSampleValue = 0x0154,
    SMaxSampleValue = 0x0155,
    TransferRange = 0x0156,
    JPEGTables = 0x015B,
    JPEGProc = 0x0200,
    JPEGInterchangeFormat = 0x0201,
    JPEGInterchangeFormatLngth = 0x0202,
    JPEGRestartInterval = 0x0203,
    JPEGLosslessPredictors = 0x0205,
    JPEGPointTransforms = 0x0206,
    JPEGQTables = 0x0207,
    JPEGDCTables = 0x0208,
    JPEGACTables = 0x0209,
    YCbCrCoefficients = 0x0211,
    YCbCrSubSampling = 0x0212,
    YCbCrPositioning = 0x0213,
    ReferenceBlackWhite = 0x0214,
    StripRowCounts = 0x022F,              // 559
    XMP = 0x02BC,                         // 700
    ImageRating = 0x4746,                 // 18246
    ImageRatingPercent = 0x4749,          // 18249
    ImageID = 0x800D,                     // 32781
    WangAnnotation = 0x80A4,              // 32932
    CFARepeatPatternDim = 0x828D,         // 33421
    CFAPattern = 0x828E,                  // 33422
    BatteryLevel = 0x828F,                // 33423
    Copyright = 0x8298,
    ExposureTime = 0x829A,                // 33434
    FNumber = 0x829D,                     // 33437
    MDFileTag = 0x82A5,                   // 33445
    MDScalePixel = 0x82A6,                // 33446
    MDColorTable = 0x82A7,                // 33447
    MDLabName = 0x82A8,                   // 33448
    MDSampleInfo = 0x82A9,                // 33449
    MDPrepDate = 0x82AA,                  // 33450
    MDPrepTime = 0x82AB,                  // 33451
    MDFileUnits = 0x82AC,                 // 33452
    ModelPixelScaleTag = 0x830E,          // 33550
    IPTCNAA = 0x83BB,                     // 33723
    INGRPacketDataTag = 0x847E,           // 33918
    INGRFlagRegisters = 0x847F,           // 33919
    IrasBTransformationMatrix = 0x8480,   // 33920
    ModelTiepointTag = 0x8482,            // 33922
    Site = 0x84E0,                        // 34016
    ColorSequence = 0x84E1,               // 34017
    IT8Header = 0x84E2,                   // 34018
    RasterPadding = 0x84E3,               // 34019
    BitsPerRunLength = 0x84E4,            // 34020
    BitsPerExtendedRunLength = 0x84E5,    // 34021
    ColorTable = 0x84E6,                  // 34022
    ImageColorIndicator = 0x84E7,         // 34023
    BackgroundColorIndicator = 0x84E8,    // 34024
    ImageColorValue = 0x84E9,             // 34025
    BackgroundColorValue = 0x84EA,        // 34026
    PixelIntensityRange = 0x84EB,         // 34027
    TransparencyIndicator = 0x84EC,       // 34028
    ColorCharacterization = 0x84ED,       // 34029
    HCUsage = 0x84EE,                     // 34030
    TrapIndicator = 0x84EF,               // 34031
    CMYKEquivalent = 0x84F0,              // 34032
    Reserved1 = 0x84F1,                   // 34033
    Reserved2 = 0x84F2,                   // 34034
    Reserved3 = 0x84F3,                   // 34035
    ModelTransformationTag = 0x85D8,      // 34264
    Photoshop = 0x8649,                   // 34377
    ExifIFD = 0x8769,                     // 34665
    ICCProfile = 0x8773,
    ImageLayer = 0x87AC,                  // 34732
    GeoKeyDirectoryTag = 0x87AF,          // 34735
    GeoDoubleParamsTag = 0x87B0,          // 34736
    GeoAsciiParamsTag = 0x87B1,           // 34737
    ExposureProgram = 0x8822,             // 34850
    SpectralSensitivity = 0x8824,         // 34852
    GPSInfo = 0x8825,                     // 34853
    ISOSpeedRatings = 0x8827,             // 34855
    OECF = 0x8828,                        // 34856
    Interlace = 0x8829,                   // 34857
    TimeZoneOffset = 0x882A,              // 34858
    SelfTimeMode = 0x882B,                // 34859
    SensitivityType = 0x8830,             // 34864
    StandardOutputSensitivity = 0x8831,   // 34865
    RecommendedExposureIndex = 0x8832,    // 34866
    ISOSpeed = 0x8833,                    // 34867
    ISOSpeedLatitudeyyy = 0x8834,         // 34868
    ISOSpeedLatitudezzz = 0x8835,         // 34869
    HylaFAXFaxRecvParams = 0x885C,        // 34908
    HylaFAXFaxSubAddress = 0x885D,        // 34909
    HylaFAXFaxRecvTime = 0x885E,          // 34910
    ExifVersion = 0x9000,                 // 36864
    DateTimeOriginal = 0x9003,            // 36867
    DateTimeDigitized = 0x9004,           // 36868
    ComponentsConfiguration = 0x9101,     // 37121
    CompressedBitsPerPixel = 0x9102,      // 37122
    ShutterSpeedValue = 0x9201,           // 37377
    ApertureValue = 0x9202,               // 37378
    BrightnessValue = 0x9203,             // 37379
    ExposureBiasValue = 0x9204,           // 37380
    MaxApertureValue = 0x9205,            // 37381
    SubjectDistance = 0x9206,             // 37382
    MeteringMode = 0x9207,                // 37383
    LightSource = 0x9208,                 // 37384
    Flash = 0x9209,                       // 37385
    FocalLength = 0x920A,                 // 37386
    FlashEnergy = 0x920B,                 // 37387
    SpatialFrequencyResponse = 0x920C,    // 37388
    Noise = 0x920D,                       // 37389
    FocalPlaneXResolution = 0x920E,       // 37390
    FocalPlaneYResolution = 0x920F,       // 37391
    FocalPlaneResolutionUnit = 0x9210,    // 37392
    ImageNumber = 0x9211,                 // 37393
    SecurityClassification = 0x9212,      // 37394
    ImageHistory = 0x9213,                // 37395
    SubjectLocation = 0x9214,             // 37396
    ExposureIndex = 0x9215,               // 37397
    TIFFEPStandardID = 0x9216,            // 37398
    SensingMethod = 0x9217,               // 37399
    MakerNote = 0x927C,                   // 37500
    UserComment = 0x9286,                 // 37510
    SubsecTime = 0x9290,                  // 37520
    SubsecTimeOriginal = 0x9291,          // 37521
    SubsecTimeDigitized = 0x9292,         // 37522
    ImageSourceData = 0x935C,             // 37724
    XPTitle = 0x9C9B,                     // 40091
    XPComment = 0x9C9C,                   // 40092
    XPAuthor = 0x9C9D,                    // 40093
    XPKeywords = 0x9C9E,                  // 40094
    XPSubject = 0x9C9F,                   // 40095
    FlashpixVersion = 0xA000,             // 40960
    ColorSpace = 0xA001,                  // 40961
    PixelXDimension = 0xA002,             // 40962
    PixelYDimension = 0xA003,             // 40963
    RelatedSoundFile = 0xA004,            // 40964
    InteroperabilityIFD = 0xA005,         // 40965
    FlashEnergyExif = 0xA20B,             // 41483
    SpatialFrequencyResponseExif = 0xA20C,// 41484
    FocalPlaneXResolutionExif = 0xA20E,   // 41486
    FocalPlaneYResolutionExif = 0xA20F,   // 41487
    FocalPlaneResolutionUnitExif = 0xA210,// 41488
    SubjectLocationExif = 0xA214,         // 41492
    ExposureIndexExif = 0xA215,           // 41493
    SensingMethodExif = 0xA217,           // 41495
    FileSource = 0xA300,                  // 41728
    SceneType = 0xA301,                   // 41729
    CFAPatternExif = 0xA302,              // 41730
    CustomRendered = 0xA401,              // 41985
    ExposureMode = 0xA402,                // 41986
    WhiteBalance = 0xA403,                // 41987
    
    // Adobe DNG and cDNG Extensions (0xC6, 0xc7)
    DNGVersion = 0xC612,                  // 50706
    DNGBackwardVersion = 0xC613,          // 50707
    UniqueCameraModel = 0xC614,           // 50708
    LocalizedCameraModel = 0xC615,        // 50709
    CFALayout = 0xC617,                   // 50711
    LinearizationTable = 0xC618,          // 50712
    BlackLevelRepeatDim = 0xC619,         // 50713
    BlackLevel = 0xC61A,                  // 50714
    BlackLevelDeltaH = 0xC61B,            // 50715
    BlackLevelDeltaV = 0xC61C,            // 50716
    WhiteLevel = 0xC61D,                  // 50717
    DefaultScale = 0xC61E,                // 50718
    DefaultCropOrigin = 0xC61F,           // 50719
    DefaultCropSize = 0xC620,             // 50720
    ColorMatrix1 = 0xC621,                // 50721
    ColorMatrix2 = 0xC622,                // 50722
    CameraCalibration1 = 0xC623,          // 50723
    CameraCalibration2 = 0xC624,          // 50724
    ReductionMatrix1 = 0xC625,            // 50725
    ReductionMatrix2 = 0xC626,            // 50726
    AnalogBalance = 0xC627,               // 50727
    AsShotNeutral = 0xC628,               // 50728
    AsShotWhiteXY = 0xC629,               // 50729
    BaselineExposure = 0xC62A,            // 50730
    BaselineNoise = 0xC62B,               // 50731
    BaselineSharpness = 0xC62C,           // 50732
    BayerGreenSplit = 0xC62D,             // 50733
    LinearResponseLimit = 0xC62E,         // 50734
    CameraSerialNumber = 0xC62F,          // 50735
    LensInfo = 0xC630,                    // 50736
    ChromaBlurRadius = 0xC631,            // 50737
    AntiAliasStrength = 0xC632,           // 50738
    ShadowScale = 0xC633,                 // 50739
    DNGPrivateData = 0xC634,              // 50740
    MakerNoteSafety = 0xC635,             // 50741
    CalibrationIlluminant1 = 0xC65A,      // 50778
    CalibrationIlluminant2 = 0xC65B,      // 50779
    BestQualityScale = 0xC65C,            // 50780
    RawDataUniqueID = 0xC65D,             // 50781
    OriginalRawFileName = 0xC68B,         // 50827
    OriginalRawFileData = 0xC68C,         // 50828
    ActiveArea = 0xC68D,                  // 50829
    MaskedAreas = 0xC68E,                 // 50830
    AsShotICCProfile = 0xC68F,            // 50831
    AsShotPreProfileMatrix = 0xC690,      // 50832
    CurrentICCProfile = 0xC691,           // 50833
    CurrentPreProfileMatrix = 0xC692,     // 50834
    ColorimetricReference = 0xC6BF,       // 50879
    CameraCalibrationSignature = 0xC6F3,  // 50931
    ProfileCalibrationSignature = 0xC6F4, // 50932
    ExtraCameraProfiles = 0xC6F6,         // 50934
    AsShotProfileName = 0xC6F8,           // 50936
    NoiseReductionApplied = 0xC6F9,       // 50937
    ProfileName = 0xC6FA,                 // 50938
    ProfileHueSatMapDims = 0xC6FB,        // 50939
    ProfileHueSatMapData1 = 0xC6FC,       // 50940
    ProfileHueSatMapData2 = 0xC6FD,       // 50941
    ProfileToneCurve = 0xC6FE,            // 50942
    ProfileEmbedPolicy = 0xC6FF,          // 50943
    ProfileCopyright = 0xC700,            // 50944
    ForwardMatrix1 = 0xC714,              // 50964
    ForwardMatrix2 = 0xC715,              // 50965
    PreviewApplicationName = 0xC716,      // 50966
    PreviewApplicationVersion = 0xC717,   // 50967
    PreviewSettingsName = 0xC718,         // 50968
    PreviewSettingsDigest = 0xC719,       // 50969
    PreviewColorSpace = 0xC71A,           // 50970
    PreviewDateTime = 0xC71B,             // 50971
    RawImageDigest = 0xC71C,              // 50972
    OriginalRawFileDigest = 0xC71D,       // 50973
    SubTileBlockSize = 0xC71E,            // 50974
    RowInterleaveFactor = 0xC71F,         // 50975
    ProfileLookTableDims = 0xC725,        // 50981
    ProfileLookTableData = 0xC726,        // 50982
    OpcodeList1 = 0xC740,                 // 51008
    OpcodeList2 = 0xC741,                 // 51009
    OpcodeList3 = 0xC74E,                 // 51022
    NoiseProfile = 0xC761,                // 51041
    TimeCodes = 0xC763,                   // 51043
    FrameRate = 0xc764,                   // 51044
    TStop = 0xc772,                       // 51058
    OriginalDefaultFinalSize = 0xC791,    // 51089
    OriginalBestQualityFinalSize = 0xC792,// 51090
    OriginalDefaultCropSize = 0xC793,     // 51091
    ProfileHueSatMapEncoding = 0xC7A3,    // 51107
    ProfileLookTableEncoding = 0xC7A4,    // 51108
    BaselineExposureOffset = 0xC7A5,      // 51109
    DefaultBlackRender = 0xC7A6,          // 51110
    NewRawImageDigest = 0xC7A7,           // 51111
    RawToPreviewGain = 0xC7A8,            // 51112
    DefaultUserCrop = 0xC7B5,             // 51125
    DepthFormat = 0xC7E9,                 // 51177
    DepthNear = 0xC7EA,                   // 51178
    DepthFar = 0xC7EB,                    // 51179
    DepthUnits = 0xC7EC,                  // 51180
    DepthMeasureType = 0xC7ED,            // 51181
    EnhanceParams = 0xC7EE                // 51182
};

struct ValueArray<T, auto Count> {
    if (Count > 1) {
        T Values[Count];
    } else {
        T Values[Count] [[hidden, no_unique_address]];
        T Value;
    }
} [[inline]];

struct ValueOffset<T, auto Count> {
    u64 Size = sizeof(T) * Count;
    if (Size <= ValueOffsetSize) {
        ValueArray<T, Count> ValueArray;
        padding[ValueOffsetSize - Size];
    } else {
        Big<u32> Offset;
        ValueArray<T, Count> ValueArray @ Offset;
    }
} [[inline]];

struct IFDEntry {
    TIFFTag Tag;
    TIFFFieldType Type;
    Big<u32> Count;

    match (Type) {
        (TIFFFieldType::BYTE): ValueOffset<u8, Count> ValueOffset;
        (TIFFFieldType::ASCII): ValueOffset<char, Count> ValueOffset;
        (TIFFFieldType::SHORT): ValueOffset<u16, Count> ValueOffset;
        (TIFFFieldType::LONG): ValueOffset<u32, Count> ValueOffset;
        (TIFFFieldType::RATIONAL): ValueOffset<TIFFRational<u32>, Count> ValueOffset;
        (TIFFFieldType::SBYTE): ValueOffset<s8, Count> ValueOffset;
        (TIFFFieldType::UNDEFINED): ValueOffset<u8, Count> ValueOffset;
        (TIFFFieldType::SSHORT): ValueOffset<s16, Count> ValueOffset;
        (TIFFFieldType::SLONG): ValueOffset<s32, Count> ValueOffset;
        (TIFFFieldType::SRATIONAL): ValueOffset<TIFFRational<s32>, Count> ValueOffset;
        (TIFFFieldType::FLOAT): ValueOffset<float, Count> ValueOffset;
        (TIFFFieldType::DOUBLE): ValueOffset<double, Count> ValueOffset;
        (TIFFFieldType::LONG8): ValueOffset<u64, Count> ValueOffset;
        (TIFFFieldType::SLONG8): ValueOffset<s64, Count> ValueOffset;
        (_): {
            padding[ValueOffsetSize];
            std::print(std::format("TIFFFieldType {} not supported", u16(Type)));
        }
    }
} [[name(std::string::replace(std::core::formatted_value(Tag), "TIFFTag::", ""))]];

fn get_field(ref auto entries, TIFFTag tag) {
    for (u64 i = 0, i < std::core::member_count(entries), i = i + 1) {
        if (entries[i].Tag == tag) {
            return i;
        }
    }
    std::error(std::format("Tag {} not found in directory", tag));
};

struct ImageData<auto Desc> {
    u64 Index = std::core::array_index();
    u64 Offset = parent.DirectoryEntry[parent.OffsetField].ValueOffset.ValueArray.Values[Index];
    u64 ByteCount = parent.DirectoryEntry[parent.ByteCountField].ValueOffset.ValueArray.Values[Index];
    std::mem::Bytes<ByteCount> ImageData @ Offset [[name(std::format("{} {}", Desc, Index))]];
} [[inline]];

u64 currentIFD = 0;
struct IFD {
    u64 Number = currentIFD;
    Big<u16> NumberDirectoryEntries;
    IFDEntry DirectoryEntry[NumberDirectoryEntries];
    Big<u32> NextIFD;

    try {
        u64 OffsetField = get_field(DirectoryEntry, TIFFTag::StripOffsets);
        u64 ByteCountField = get_field(DirectoryEntry, TIFFTag::StripByteCounts);
        u64 Count = std::core::member_count(DirectoryEntry[OffsetField].ValueOffset.ValueArray.Values);
        ImageData<"Strip"> Strips[Count];
    } catch {}

    try {
        u64 OffsetField = get_field(DirectoryEntry, TIFFTag::TileOffsets);
        u64 ByteCountField = get_field(DirectoryEntry, TIFFTag::TileByteCounts);
        u64 Count = std::core::member_count(DirectoryEntry[OffsetField].ValueOffset.ValueArray.Values);
        ImageData<"Tile"> Tiles[Count];
    } catch {}
} [[name(std::format("IFD {}", Number))]];

struct IFDS {
    IFD IFD;
    if (IFD.NextIFD > 0) {
        currentIFD += 1;
        IFDS IFD_tmp @ IFD.NextIFD;
    }
} [[inline]];

struct TIFFFile {
    TIFFHeader Header;
    IFDS @ Header.Offset;
};

TIFFFile File @ 0x00;
