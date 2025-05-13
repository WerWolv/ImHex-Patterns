#pragma description ZIP compression archive

#pragma MIME application/zip

import std.mem;
import std.math;
import std.core;
import type.time;


using CentralDirectoryFileHeader;


struct EOCD64Locator {
    u32 headerSignature [[comment("EoCD magic"), name("EoCD PK\\6\\7")]];
    u32 cdrDisk [[comment("Disk number containing the end of central directory record"), name("CDR Disk")]];
    u64 eocdOffset [[comment("Offset of end of central directory record"), name("End of Central Directory Record Offset")]];
    u32 totalDisks [[comment("Total number of disks"), name("Total Disks")]];
};

struct EndOfCentralDirectory {
    u32 magic;

    if (magic == 0x06064b50) {
        u64 eocdSize [[comment("Size of fixed fields + size of variable data - 12"), name("EOCD Size")]];
        u16 madeByVersion [[comment("The version of zip this was authored by"), name("Made By Version")]];
        u16 versionNeeded [[comment("The minimum supported ZIP version needed to extract the file"), name("Version Needed")]];
        u32 diskNum [[comment("number of this disk"), name("Disk Number")]];
        u32 diskStart [[comment("Disk where central directory starts "), name("Central Directory Disk Number")]];
        u64 CDRCount [[comment("Number of central directory records on this disk"), name("Central Directory Entries")]];
        u64 CentralDirectoryRecordCount [[comment("Total number of entries in the central directory"), name("Total Central Directory Entries")]];
        u64 CDSize [[comment("Size of central directory (bytes)"), name("Central Directory Size")]];
        u64 CDOffset [[comment("Offset of start of central directory, relative to start of archive"), name("Central Directory Offset")]];
        char extra[eocdSize - 44] [[comment("zip64 extensible data sector"), name("Extra Data")]];
        EOCD64Locator locator [[name("EOCD Locator")]];
        char eocd32[20] [[name("EOCD32")]];
        u16 commentLength [[color("00000000")]];
        char coment[commentLength] [[name("Comment")]];
        CentralDirectoryFileHeader centralDirHeaders[CDRCount] @ (CDOffset) [[name("Files")]];
    } else if (magic == 0x06054B50) {
        u16 diskNum [[comment("Number of this disk "), name("Disk Number")]];
        u16 diskStart [[comment("Disk where central directory starts "), name("Central Directory Disk Number")]];
        u16 CDRCount [[comment("Number of central directory records on this disk"), name("Central Directory Entries")]];
        u16 CentralDirectoryRecordCount [[comment("Total number of entries in the central directory"), name("Total Central Directory Entries")]];
        u32 CDSize [[comment("Size of central directory (bytes)"), name("Central Directory Size")]];
        u32 CDOffset [[comment("Offset of start of central directory, relative to start of archive"), name("Central Directory Offset")]];
        u16 commentLength [[color("00000000")]];
        char coment[commentLength] [[name("Comment")]];
        if (CDOffset != 0xFFFFFFFF && CentralDirectoryRecordCount != 0xFFFF) {
            CentralDirectoryFileHeader centralDirHeaders[CDRCount] @ (CDOffset) [[name("Files")]];
        }
    } else {
      std::error("Invalid EOCD magic!");
    }
};

namespace extra {

    bitfield UTFlags {
          bool modification_time_set : 1;
          bool access_time_set : 1;
          bool creation_time_set : 1;
          reserved: 5;  //reserved for additional timestamps; not set
    };

    struct X000A_NTFS {
        u32 reserved;
        u16 tag;
        u16 TSize;
        //Timestamps are in FILETIME format. Converted to Unix for easier handling.
        type::FILETIME ModTime;
        type::FILETIME AcTime;
        type::FILETIME CrTime;
    };

    struct X7875_NewUnix {
        u16 tag;
        u16 TSize;
        u8 version;
        u8 UIDSize;
        u8 UID[UIDSize];
        u8 GIDSize;
        u8 GID[GIDSize];
    };

    struct X5855_InfoZipUnix {
        u32 AcTime;
        u32 ModTime;
        if (parent.TSize > 8){
            u16 UID;
        }
        if (parent.TSize > 10){
            u16 GID;
        }
    };

    struct ZIP64_SizeInfo {
        u64 uncompressedSize;
        u64 compressedSize;
        if (parent.TSize > 16){
            u64 localHeaderOffset;;
        }
        if (parent.TSize > 24){
            u32 diskStartNumber;
        }
    };

    struct ExtraField {
        u16 tag;
        u16 TSize;

        if (tag == 0x0001) {
            extra::ZIP64_SizeInfo ZIP64_SizeInfo;
        } else if (tag == 0x5455) {
            // 0x5455 needs parsed with TSize in context to prevent overshoot from mismatched TSize/flags set
            UTFlags Flags;
            u64 extraEndFromFlags = $ + 4*(Flags.modification_time_set + Flags.access_time_set + Flags.creation_time_set);
            u64 extraEndFromTSize = $ + TSize - 1;
            u64 extraEnd = std::math::min(extraEndFromFlags, extraEndFromTSize);

            if ( ($ < extraEnd) && Flags.modification_time_set) {
                type::time32_t ModTime;
            }

            if ( ($ < extraEnd) && Flags.access_time_set) {
                type::time32_t AcTime;
            }

            if ( ($ < extraEnd) && Flags.creation_time_set) {
                type::time32_t CrTime;
            }
        } else if (tag == 0x000a) {
            extra::X000A_NTFS x000A_NTFS;
        } else if (tag == 0x7875) {
            extra::X7875_NewUnix x7875_NewUnix;
        } else if (tag == 0x5855) {
            extra::X5855_InfoZipUnix x5855_InfoZipUnix;
        } else {
            std::print("Unsupported tag 0x{:02X}", tag);
            padding[TSize];
        }
    };
    
    fn has_extra_field(u32 extraEnd) {
        if ($ + 4 > extraEnd) return false;
        u16 tag = std::mem::read_unsigned($, 2, std::mem::Endian::Little);
        u16 len = std::mem::read_unsigned($ + 2, 2, std::mem::Endian::Little);
        return !(tag == 0 || len == 0) && $ + 4 + len <= extraEnd;
    };
}

fn find_eocd() {
    u128 offset_search_from = std::math::max(0, std::mem::size()-65536);
    u128 prev_address;
    while(1){
        s128 current_address = std::mem::find_sequence_in_range(0, offset_search_from, std::mem::size(), 0x50,0x4B,0x05,0x06);

        //Reached EOF and did not find valid eocd.
        if (current_address == -1) {
            std::error("Could not find EOCD.");
        }

        //Potential eocd found. Create a eocd struct
        EndOfCentralDirectory EOCD32 @ current_address;

        if (EOCD32.CDOffset == 0xFFFFFFFF || EOCD32.CentralDirectoryRecordCount == 0xFFFF) {
            // this is a zip64 file
            if (std::mem::read_unsigned(current_address - 20, 4, std::mem::Endian::Little) == 0x07064B50){
                EOCD64Locator locator @ current_address - 20;
                EndOfCentralDirectory EOCD64 @ locator.eocdOffset;
                //If central directory file header is valid, then we know the eocd offset is valid.
                if (std::mem::read_unsigned(EOCD64.CDOffset, 4, std::mem::Endian::Little) == 0x2014B50){
                    return locator.eocdOffset;
                }
            }
        } else {
            //If central directory file header is valid, then we know the eocd offset is valid.
            if (std::mem::read_unsigned(EOCD32.CDOffset, 4, std::mem::Endian::Little) == 0x2014B50){
                return current_address;
            }
        }

        offset_search_from = current_address + 1;
        prev_address = current_address;
    }
};


enum CompressionMethod : u16 {
  None = 0,              // The file is stored (no compression)
  Shrunk = 1,            // The file is Shrunk
  Factor1 = 2,           // The file is Reduced with compression factor 1
  Factor2 = 3,           // The file is Reduced with compression factor 2
  Factor3 = 4,           // The file is Reduced with compression factor 3
  Factor4 = 5,           // The file is Reduced with compression factor 4
  Implode = 6,           // The file is Imploded
  // ? =  7,             // Reserved for Tokenizing compression algorithm
  Deflate  = 8,          // The file is Deflated
  Deflate64 = 9,         // Enhanced Deflating using Deflate64(tm)
  PKWARE = 10,           // PKWARE Data Compression Library Imploding (old IBM TERSE)
  // ? =11,              // Reserved by PKWARE
  BZIP2 = 12,            // File is compressed using BZIP2 algorithm
  // ? = 13,             // Reserved by PKWARE
  LZMA = 14,             // LZMA
  // ? = 15,             // Reserved by PKWARE
  CMPSC = 16,            // IBM z/OS CMPSC Compression
  // ? = 17,             // Reserved by PKWARE
  IBMTERSE = 18,         // File is compressed using IBM TERSE (new)
  LZ77 = 19,             // IBM LZ77 z Architecture
  _ZSTD = 20,            // deprecated (use method 93 for zstd)
  ZSTD = 93,             // Zstandard (zstd) Compression
  MP3 = 94,              // MP3 Compression
  XZ = 95,               // XZ Compression
  JPEG = 96,             // JPEG variant
  WavPack = 97,          // WavPack compressed data
  PPMd = 98,             // PPMd version I, Rev 1
  AE_x = 99,             // AE-x encryption marker (see APPENDIX E)
};

bitfield GeneralPurposeBitFlags {
    encrypted : 1;
    compressionOptions : 2;
    crcAndSizesInCDAndDataDescriptor : 1;
    enhancedDeflating : 1;
    patchedData : 1;
    strongEncryption : 1;
    unused : 4;
    filenameAndCommentAreUtf8 : 1;
    reservedPKWARE_0 : 1;
    centralDirectoryEncrypted : 1;
    reservedPKWARE_1 : 2;
};


struct LocalFileHeader {
    u32 headerSignature [[name("LCF PK\\3\\4")]];
    u16 version [[ comment("The minimum supported ZIP specification version needed to extract the file") ]];
    GeneralPurposeBitFlags generalPurposeBitFlags  [[ comment("General purpose bit flag") ]];
    CompressionMethod compressionMethod [[ comment("Compression method") ]];
    type::DOSTime lastModifyTime [[ comment("File last modification time") ]];
    type::DOSDate lastModifyDate [[ comment("File last modification date") ]];
    u32 crc32 [[ comment("CRC-32") ]];
    u32 compressedSize [[ comment("Compressed size") ]];
    u32 uncompressedSize [[ comment("Uncompressed size") ]];
    u16 fileNameLength [[ comment("File name length (n)") ]];
    u16 extraFieldLength [[ comment("Extra field length (m)") ]];
    char fileName[fileNameLength] [[ comment("File Name") ]];
    u64 extraEnd = $ + extraFieldLength;
    extra::ExtraField extraFields[while (extra::has_extra_field(extraEnd))] [[comment("Extra Fields")]];
    padding[extraEnd - $];
    u8 data[get_file_data_size(compressionMethod, compressedSize, uncompressedSize, extraFields)] [[name("File Data")]];
};

fn get_file_data_size(CompressionMethod compressionMethod, u32 compressedSize, u32 uncompressedSize, ref extra::ExtraField extraFields) {
    u32 size = 0;
    if (compressionMethod == CompressionMethod::None) {
        size = uncompressedSize;
    } else {
        size = compressedSize;
    }

    if (size != 0xFFFFFFFF) {
        return size;
    }
    
    u32 extraSize = std::core::member_count(extraFields);
    for (u32 i = 0, i < extraSize, i += 1) {
        if (extraFields[i].tag == 0x0001) {
            if (compressionMethod == CompressionMethod::None) {
                return extraFields[i].ZIP64_SizeInfo.uncompressedSize;
            } else {
                return extraFields[i].ZIP64_SizeInfo.compressedSize;
            }
        }
    }
    return 0;
};

struct CentralDirectoryFileHeader {
    u32 headerSignature [[name("CDFH PK\\1\\2")]];
    u16 versionMade [[comment("Version file made by")]];
    u16 versionExtract [[comment("Minimum version needed to extract")]];
    GeneralPurposeBitFlags generalPurposeBitFlags [[comment("General purpose bit flag")]];
    CompressionMethod compressionMethod;
    type::DOSTime fileLastModifyTime [[comment("File last modification time")]];
    type::DOSDate fileLastModifyDate [[comment("File last modification date")]];
    u32 crc32 [[comment("CRC-32 of uncompressed data")]];
    u32 compressedSize;
    u32 uncompressedSize;
    u16 fileNameLength;
    u16 extraFieldLength;
    u16 fileCommentLength;
    u16 diskNumber [[comment("Disk number where file starts")]];
    u16 internalFileAttributes;
    u32 externalFileAttributes;
    u32 localHeaderOffset;
    char fileName[fileNameLength];
    u64 extraEnd = $ + extraFieldLength;
    extra::ExtraField extraFields[while (extra::has_extra_field(extraEnd))] [[comment("Extra Fields")]];
    padding[extraEnd - $];
    char comment[fileCommentLength] @ extraEnd;
    LocalFileHeader localFileHeader @ get_local_header_offset(localHeaderOffset, extraFields) [[name("Local File Header")]];
};

fn get_local_header_offset(u32 localHeaderOffset, ref extra::ExtraField extraFields) {
    u32 size = 0;
    if (localHeaderOffset != 0xFFFFFFFF) {
        return localHeaderOffset;
    }

    u32 extraSize = std::core::member_count(extraFields);
    for (u32 i = 0, i < extraSize, i += 1) {
        if (extraFields[i].tag == 0x0001) {
            return extraFields[i].ZIP64_SizeInfo.localHeaderOffset;
        }
    }

    std::error("No valid local header offset found!");
};


EndOfCentralDirectory fileInfo @ find_eocd() [[name("End of Central Directory Record")]];
