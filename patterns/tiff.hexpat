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
fn format_read_big(Big<u32> v) {
    return std::format("{} (0x{:X})", v, v);
};
fn format_write_big(str v) {
    return std::string::parse_int(v, 0);
};
fn transform_big(Big<u32> v) {
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
    Copyright = 0x8298,
    ICCProfile = 0x8773
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
