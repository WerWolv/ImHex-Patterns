#pragma description Apple Disk Image Trailer (DMG)

#pragma endian big

#include <type/magic.pat>
#include <type/size.pat>
#include <type/guid.pat>
#include <std/mem.pat>

// Parse DMG Structure per http://newosxbook.com/DMG.html
//
// UDIFResourceFile starts at size(file) - 512
struct UDIFResourceFile {
    type::Magic<"koly"> Signature;  // Magic ('koly')
    u32 Version;                    // Current version is 4
    type::Size<u32> HeaderSize;     // sizeof(this), always 512
    u32 Flags;
    u64 RunningDataForkOffset;      // 
    u64 DataForkOffset;             // Data fork offset (usually 0, beginning of file)
    type::Size<u64> DataForkLength; // Size of data fork (usually up to the XMLOffset, below)
    u64 RsrcForkOffset;             // Resource fork offset, if any
    type::Size<u64> RsrcForkLength; // Resource fork length, if any
    u32 SegmentNumber;              // Usually 1, may be 0
    u32 SegmentCount;               // Usually 1, may be 0
    type::GUID SegmentID;           // 128-bit GUID identifier of segment (if SegmentNumber !=0)
    

    u32 DataChecksumType;               // Data fork 
    type::Size<u32> DataChecksumSize;   // Checksum Information
    u32 DataChecksum[DataChecksumSize]; // Up to 128-bytes (32 x 4) of checksum

    u64 XMLOffset;              // Offset of property list in DMG, from beginning
    type::Size<u64> XMLLength;  // Length of property list
    u8  Reserved1[120];         // 120 reserved bytes - zeroed

    u32 ChecksumType;               // Master
    type::Size<u32> ChecksumSize;   // Checksum information
    u32 Checksum[ChecksumSize];     // Up to 128-bytes (32 x 4) of checksum

    u32 ImageVariant;          // Commonly 1
    u64 SectorCount;           // Size of DMG when expanded, in sectors

    u32 reserved2;             // 0
    u32 reserved3;             // 0 
    u32 reserved4;             // 0
};


UDIFResourceFile trailer @ std::mem::size() - 512;

char metadata_plist[trailer.XMLLength] @ trailer.XMLOffset;
