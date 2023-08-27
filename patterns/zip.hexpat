#pragma description End of Central Directory Header, Central Directory File Headers

#pragma MIME application/zip

#include <std/mem.pat>
#include <std/math.pat>

struct EndOfCentralDirectory {
    u32 headerSignature [[color("00000000")]];
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
        // This is not entirely reliable, since the signature could
        // randomly appear in compressed data before the actual EOCD,
        // but it should be good enough...
        u128 last64k = std::math::max(0, std::mem::size()-65536-22);
        return std::mem::find_sequence_in_range(0, last64k, std::mem::size(), 0x50,0x4B,0x05,0x06);
    }
};

EndOfCentralDirectory fileInfo @ find_eocd() [[name("End of Central Directory Record")]];

struct CentralDirectoryFileHeader {
    u32 headerSignature [[color("00000000")]];
    u16 versionMade [[comment("Version file made by")]];
    u16 versionExtract [[comment("Minimum version needed to extract")]];
    u16 generalFlag [[comment("General purpose bit flag"), color("00000000")]];
    u16 compressionMethod;
    u16 fileLastModifyTime [[comment("File last modification time")]];
    u16 fileLastModifyDate [[comment("File last modification date")]];
    u32 crc32 [[comment("CRC-32 of uncompressed data"), color("00000000")]];
    u32 compressedSize;
    u32 uncompressedSize;
    u16 fileNameLength [[color("00000000")]];
    u16 extraFieldLength [[color("00000000")]];
    u16 fileCommentLength [[color("00000000")]];
    u16 diskNumber [[comment("Disk number where file starts")]];
    u16 internalFileAttributes;
    u32 externalFileAttributes;
    u32 fileOffset [[comment("Offset of local file header, relative to the start of the first disk on which the file occurs.")]];
    char fileName[fileNameLength];
    u8 extraField[extraFieldLength];
    char comment[fileCommentLength];
};

CentralDirectoryFileHeader centralDirHeaders[fileInfo.CDRCount] @ (fileInfo.CDOffset) [[name("Files")]];
