#pragma description End of Central Directory Header, Central Directory File Headers, Local File Header

#pragma MIME application/zip

#include <std/mem.pat>
#include <std/math.pat>

struct EndOfCentralDirectory {
    u32 headerSignature [[comment("EoCD magic"), name("EoCD PK\\5\\6")]];
    u16 diskNum [[comment("Number of this disk "), name("Disk Number")]];
    u16 diskStart [[comment("Disk where central directory starts "), name("Central Directory Disk Number")]];
    u16 CDRCount [[comment("Number of central directory records on this disk"), name("Central Directory Entries")]];
    u16 CentralDirectoryRecordCount [[comment("Total number of entries in the central directory"), name("Total Central Directory Entries")]];
    u32 CDSize [[comment("Size of central directory (bytes)"), name("Central Directory Size")]];
    u32 CDOffset [[comment("Offset of start of central directory, relative to start of archive"), name("Central Directory Offset")]];
    u16 commentLength [[color("00000000")]];
    char coment[commentLength] [[name("Comment")]];
};

fn find_eocd() {
    // If there is no zip comment, which is the common case,
    // the end-of-central-directory record will be 22 bytes long
    // at the end of the file; check if size-22 has the signature.
    if (std::mem::read_unsigned(std::mem::size()-22, 4, std::mem::Endian::Little) == 0x06054B50) {
        return std::mem::size()-22;
    } else {
        // If it's not there, then there's probably a zip comment;
        // search the last 64KB of the file for the signature.        
        u128 offset_search_from = std::math::max(0, std::mem::size()-65536-22);
        u128 prev_address;
        while(1){
            u128 current_address = std::mem::find_sequence_in_range(0, offset_search_from, std::mem::size(), 0x50,0x4B,0x05,0x06); 
            
            //Reached EOF and did not find valid eocd.
            if (current_address == 340282366920938463463374607431768211455){
                std::error("Could not find EOCD.");
            }
            
            //Potential eocd found. Create a eocd struct
            EndOfCentralDirectory EOCD @ current_address;
            
            //If central directory file header is valid, then we know the eocd offset is valid.
            if (std::mem::read_unsigned(EOCD.CDOffset, 4, std::mem::Endian::Little) == 0x2014B50){
                return current_address;
            }
            
            offset_search_from = current_address + 1;
            prev_address = current_address;
        }
    }
};

EndOfCentralDirectory fileInfo @ find_eocd() [[name("End of Central Directory Record")]];

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

struct LocalFileHeader {
    u32 headerSignature [[name("LCF PK\\3\\4")]];
    u16 version [[ comment("The minimum supported ZIP specification version needed to extract the file") ]];
    u16 purposeBitflag  [[ comment("General purpose bit flag") ]];
    CompressionMethod compressionMethod [[ comment("Compression method") ]];
    u16 lastModifyTime [[ comment("File last modification time") ]];
    u16 lastModifyDate [[ comment("File last modification date") ]];
    u32 crc32 [[ comment("CRC-32") ]];
    u32 compressedSize [[ comment("Compressed size") ]];
    u32 uncompressedSize [[ comment("Uncompressed size") ]];
    u16 fileNameLength [[ comment("File name length (n)") ]];
    u16 extraFieldLength [[ comment("Extra field length (m)") ]];
    char fileName[fileNameLength] [[ comment("File Name") ]];
    char extraField[extraFieldLength] [[ comment("Extra Field") ]];
    u8 data[compressedSize] [[name("File Data")]];
};

union File {
    u32 fileOffset [[comment("Offset of local file header, relative to the start of the first disk on which the file occurs.")]];
    LocalFileHeader *fileHeader : u32;
};

struct CentralDirectoryFileHeader {
    u32 headerSignature [[name("CDFH PK\\1\\2")]];
    u16 versionMade [[comment("Version file made by")]];
    u16 versionExtract [[comment("Minimum version needed to extract")]];
    u16 generalFlag [[comment("General purpose bit flag")]];
    CompressionMethod compressionMethod;
    u16 fileLastModifyTime [[comment("File last modification time")]];
    u16 fileLastModifyDate [[comment("File last modification date")]];
    u32 crc32 [[comment("CRC-32 of uncompressed data")]];
    u32 compressedSize;
    u32 uncompressedSize;
    u16 fileNameLength;
    u16 extraFieldLength;
    u16 fileCommentLength;
    u16 diskNumber [[comment("Disk number where file starts")]];
    u16 internalFileAttributes;
    u32 externalFileAttributes;
    File file;
    char fileName[fileNameLength];
    u8 extraField[extraFieldLength];
    char comment[fileCommentLength];
};

CentralDirectoryFileHeader centralDirHeaders[fileInfo.CDRCount] @ (fileInfo.CDOffset) [[name("Files")]];