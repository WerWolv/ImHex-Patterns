#pragma description Tag Image File Format

#pragma MIME image/tiff

#pragma eval_depth 100

#include <std/io.pat>
#include <std/mem.pat>
#include <std/string.pat>
#include <std/core.pat>

#define BIG 1
#define LITTLE 2


u32 stripCount = 0;
s32 current_strip = 0;

fn get_next_strip_index(){
     if (current_strip <= stripCount) {
        current_strip = current_strip + 1;
        return current_strip - 1;
    } else {
        return stripCount+1;
    }
};

fn reset_counter_strip(){
    current_strip = 0;
    stripCount = 0;
};

fn start_counter_strip(u32 total){
    current_strip = 0;
    stripCount = total;
};

fn set_endian(str magic) {
    if (std::string::starts_with(magic, "II")) {
        std::core::set_endian(std::mem::Endian::Little);
    } else if (std::string::starts_with(magic, "MM")) {
        std::core::set_endian(std::mem::Endian::Big);
    } 
};

fn get_total_IFDs(u32 first_offset){
    u32 ifd_count = 0;
    u32 current_offset = first_offset;
    while (current_offset != 0) {
        u16 ifd_entries_count = std::mem::read_unsigned(current_offset, 2, std::core::get_endian());
        current_offset = std::mem::read_unsigned(current_offset + 2 + ifd_entries_count * 12, 4, std::core::get_endian());
        ifd_count = ifd_count + 1;
    }
    return ifd_count;
};

fn get_ifds_offsets(u32 first_offset) {
    u32 total_ifds = get_total_IFDs(first_offset);
    u32 index = 0;
    u32 current_offset = first_offset;
    u32 ifd_offsets[total_ifds];
    while (current_offset != 0) {
        ifd_offsets[index] = current_offset;
        u16 ifd_entries_count = std::mem::read_unsigned(current_offset, 2, std::core::get_endian());
        current_offset = std::mem::read_unsigned(current_offset + 2 + ifd_entries_count * 12, 4, std::core::get_endian());
        index = index + 1;
    }
    return ifd_offsets;
};
using TIFFFieldType;
using TIFFTag;
fn get_entry_value(u32 offset, TIFFTag Tag){
    u16 count = std::mem::read_unsigned(offset, 2, std::core::get_endian());
    u8 step = 12;
    offset = offset + 2;
    while (count != 0) {
        if (std::mem::read_unsigned(offset, 2, std::core::get_endian()) == Tag) {
            if (std::mem::read_unsigned(offset + 2, 2, std::core::get_endian()) == TIFFFieldType::SHORT) {
                return std::mem::read_unsigned(offset + 8, 2, std::core::get_endian());
            } else if (std::mem::read_unsigned(offset + 2, 2, std::core::get_endian()) == TIFFFieldType::LONG) {
                return std::mem::read_unsigned(offset + 8, 4, std::core::get_endian());
            }
        }
        count = count - 1;
        offset = offset + step;
    }
};


struct TIFFHeader {
    char Magic[2];
    set_endian(Magic);
    u16 Version;
    u32 Offset;
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
    DOUBLE = 12
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
    InterColorProfile = 0x8773
};


struct IFDEntry {
    TIFFTag Tag;
    TIFFFieldType Type;
    u32 Count;

    match (Type) {
        (TIFFFieldType::BYTE): {
             if (std::core::get_endian() == BIG){
                u8 Value;
                padding[3];
            } else {
                u32 Value;
            }
        }
        (TIFFFieldType::ASCII): { 
            u32 value_offset[[hidden]];
            char Value[Count] @ value_offset;
        }
        (TIFFFieldType::SHORT): {
            if (std::core::get_endian() == BIG){
                u16 Value;
                padding[2];
            } else {
                u32 Value;
            }
        }
        (TIFFFieldType::LONG): u32 Value;
        (TIFFFieldType::RATIONAL): {
            u32 value_offset[[hidden]];
            u32 Numerator @ value_offset;
            u32 Denominator @ value_offset + 4;
        }
        (TIFFFieldType::SBYTE): {
             if (std::core::get_endian() == BIG){
                s8 Value;
                padding[3];
            } else {
                s32 Value;
            }
        }
        (TIFFFieldType::UNDEFINED): {
            u32 value_offset[[hidden]];
            u8 Value[Count] @ value_offset;
        }
        (TIFFFieldType::SSHORT): {
             if (std::core::get_endian() == BIG){
                s16 Value;
                padding[2];
            } else {
                s32 Value;
            }
        }
        (TIFFFieldType::SLONG): s32 Value;
        (TIFFFieldType::SRATIONAL): {
            u32 value_offset[[hidden]];
            s32 Numerator @ value_offset;
            s32 Denominator @ value_offset + 4;
        }
        (TIFFFieldType::FLOAT): float Value;
        (TIFFFieldType::DOUBLE): {
            u32 value_offset[[hidden]];
            double Value @ value_offset;
        }
        (_): {
            padding[4];
            std::print("TIFFFieldType not supported");
        }
   
    }
} [[name(std::string::replace(std::core::formatted_value(Tag), "TIFFTag::", ""))]];


struct StripList {
    u16 entry_count [[hidden]];
    u32 ImageLength = get_entry_value(addressof(this), TIFFTag::ImageLength);
    u32 RowsPerStrip = get_entry_value(addressof(this), TIFFTag::RowsPerStrip);
    u32 StripByteCounts = get_entry_value(addressof(this), TIFFTag::StripByteCounts);
    u32 StripOffsets = get_entry_value(addressof(this), TIFFTag::StripOffsets);
    
    s32 next_strip_index = get_next_strip_index();  
    if ((ImageLength/RowsPerStrip) > 1) {
        u32 StripOffsetsArray[ImageLength/RowsPerStrip] @ StripOffsets [[hidden]];
        u32 StripByteCountsArray[ImageLength/RowsPerStrip] @ StripByteCounts [[hidden]];
        u8 Strip[StripByteCountsArray[next_strip_index]] @ StripOffsetsArray[next_strip_index];
    } else {
        u8 Strip[StripByteCounts] @ StripOffsets;
    }

    if (current_strip < stripCount)  {
        StripList strips @ addressof(this);
    } else {
        reset_counter_strip();
        break;
    }

}[[inline]];


struct IFD {
    u16 NumberDirectoryEntries;
    IFDEntry DirectoryEntry[NumberDirectoryEntries];
    u32 NextIFD;
    u32 ImageLength = get_entry_value(addressof(this), TIFFTag::ImageLength);
    u32 RowsPerStrip = get_entry_value(addressof(this), TIFFTag::RowsPerStrip);
    u32 StripByteCounts = get_entry_value(addressof(this), TIFFTag::StripByteCounts);
    u32 StripOffsets = get_entry_value(addressof(this), TIFFTag::StripOffsets);
    u32 StripOffsetsArray[ImageLength/RowsPerStrip] @ StripOffsets;
    u32 StripByteCountsArray[ImageLength/RowsPerStrip] @ StripByteCounts;
    start_counter_strip(ImageLength/RowsPerStrip);
    StripList ImageData[] @ addressof(this);
};

struct IFDS {
    IFD IFD;
    if (IFD.NextIFD > 0) {
        IFDS IFD_tmp  @ IFD.NextIFD;
    }else {
        break;
    }
}[[inline]];

struct TIFFFile {
    TIFFHeader Header;
    set_endian(Header.Magic);
    u32 total_ifds = get_total_IFDs(Header.Offset);
    IFDS IFDs[total_ifds] @ Header.Offset;
};


TIFFFile File @ 0x00;
