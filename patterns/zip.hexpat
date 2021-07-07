#pragma MIME application/zip

struct EndOfCentralDirectory{
	u32 headerSignature [[color("00000000")]];
	u16 diskNum [[comment("Number of this disk "), name("Disk Number")]];
	u16 diskStart [[comment("Disk where central directory starts "), name("Central Directory Disk Number")]];
	u16 CDRCount [[comment("Number of central directory records on this disk"), name("Central Directory Entries")]];
	u16 CentralDirectoryRecordCount [[comment("Total number of entries in the central directory"), name("Total Central Directory Entries")]];
	u16 CDSize [[comment("Size of central directory (bytes)"), name("Central Directory Size")]];
	u32 CDOffset [[comment("Offset of start of central directory, relative to start of archive"), name("Central Directory Offset")]];
	u16 commentLength [[color("00000000")]];
	char coment[commentLength] [[name("Comment")]];
};

EndOfCentralDirectory fileInfo @ findSequence(0,0x50,0x4B,0x05,0x06) [[name("End of Central Directory Record")]];

struct CentralDirectoryEntry{
	
};

struct CentralDirectoryFileHeader{
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
	u16 diskNumber [[comment("Disk number where file starts ")]];
	u16 internalFileAttributes;
	u32 externalFileAttributes;
	u32 fileOffset [[comment("Relative offset of local file header. This is the number of bytes between the start of the first disk on which the file occurs, and the start of the local file header. This allows software reading the central directory to locate the position of the file inside the ZIP file.")]];
	char fileName[fileNameLength];
	u8 extraField[extraFieldLength];
	char comment[fileCommentLength];
};

CentralDirectoryFileHeader centralDirHeaders[readUnsigned(findSequence(0,0x50,0x4B,0x05,0x06)+10,2)] @ findSequence(0,0x50,0x4b,0x01,0x02) [[name("Files")]];
