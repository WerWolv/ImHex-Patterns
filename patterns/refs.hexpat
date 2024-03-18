#pragma author 5h4rrK
#pragma description ReFS-File-System

import type.types.win32;
import type.guid;
import std.mem;

enum FILESYSTEM : u64 {
	ReFS = 0x53466552
};

struct ReFS_Version {
	u8 Major;
	u8 Minor;
};

struct CheckPoint_REFS_Version {
	u16 Major;
	u16 Minor;
};

enum BLOCK : u32 {
	SuperBlock = 0x42505553,
	CheckPoint = 0x504b4843,
	MSBPlus = 0x2b42534d
};

struct META_HEADERS {
	BLOCK Signature[[comment("Block Signature"), name("BlockSignature")]];
	u32 unk[[comment("Fixed Value 0x02"), name("Unknown")]];
	$ = $ + (0x8 + 0x10);
	u64 LCN1[[comment("MetaPage 1st LogicalClusterNumber"), name("FirstLCN")]];
	u64 LCN2[[comment("MetaPage 2nd LogicalClusterNumber"), name("SecondLCN")]];
	u64 LCN3[[comment("MetaPage 3rd LogicalClusterNumber"), name("ThirdLCN")]];
	u64 LCN4[[comment("MetaPage 4th LogicalClusterNumber"), name("FourthLCN")]];
	u64 _Objid;
	u64 ObjId;

};

struct ATTRIBUTE {
	u64 LCN1[[name("FirstLCN")]];
	u64 LCN2[[name("SecondLCN")]];
	u64 LCN3[[name("ThirdLCN")]];
	u64 LCN4[[name("FourthLCN")]];
	u32 Unk1[[comment("UnknownField"), name("Unknown1")]];
	u32 Unk2[[comment("UnknownField"), name("Unknown2")]];
	u64 checksum[[name("CheckSum")]];
	BYTE ZeroPadding[56][[name("Padding")]];
};

u32 keeptrack = 0;

struct EntryArray {
	u32 AttrOffsetEntry;
	u32 prev = $;
	$ = (0x1000 * ($ / 0x1000));
	$ = $ + AttrOffsetEntry;
	keeptrack += 1;
	if (keeptrack == 1) {
		ATTRIBUTE ObjectTable;
	}
	else if (keeptrack == 2) {
		ATTRIBUTE UNKNOWN1;
	}
	else if (keeptrack == 3) {
		ATTRIBUTE UNKNOWN2;
	}
	else if (keeptrack == 4) {
		ATTRIBUTE AttributeList;
	}
	else if (keeptrack == 5) {
		ATTRIBUTE DirectoryTree;
	}
	else if (keeptrack == 6) {
		ATTRIBUTE UNKNOWN3;
	}
	else if (keeptrack == 7) {
		ATTRIBUTE UNKNOWN4;
	}
	else if (keeptrack == 8) {
		ATTRIBUTE ContainerTable;
	}
	else if (keeptrack == 9) {
		ATTRIBUTE ContainerTableDup;
	}
	else if (keeptrack == 10) {
		ATTRIBUTE UNKNOWN5;
	}
	else if (keeptrack == 11) {
		ATTRIBUTE AllocatorLarge;
	}
	else if (keeptrack == 12) {
		ATTRIBUTE UNKNOWN6;
	}
	else if (keeptrack == 13) {
		ATTRIBUTE UNKNOWN7;
	}
	$ = prev;
};

struct CHECKPOINT {
	META_HEADERS CheckPointMetaHeader[[name("FSPageMetaHeader")]];
	$ += (0x04);
	CheckPoint_REFS_Version ReFSVersion;
	u32 EntryOffset;
	u32 EntrySz[[name("EntrySize")]];
	u64 blockno[[name("BlockNumber")]];
	$ += (0x28);
	u32 NumOfEntries;
	EntryArray AttributeEntries[NumOfEntries];
	$ += (0x08);
	u64 LCN1dup[[comment("Duplicate LCN of MetaPage of this block"), name("DupFirstLCN")]];
	u64 LCN2dup[[comment("Duplicate LCN of MetaPage of this block"), name("DupSecondLCN")]];
	u64 LCN3dup[[comment("Duplicate LCN of MetaPage of this block"), name("DupThirdLCN")]];
	u64 LCN4dup[[comment("Duplicate LCN of MetaPage of this block"), name("DupFourthLCN")]];;
};

struct SUPERBLOCK {
	META_HEADERS SuperBlockMetaHeader[[name("FSPageMetaHeader")]];
	type::GUID GUID;
	$ = $ + (0x10 * 0x06);
	u64 primarychekpoint[[name("PrimaryCheckPoint")]];
	u64 secondaychekpoint[[name("SecondaryCheckPoint")]];
	u64 LCN1dup[[name("DupFirstLCN")]];
	u64 LCN2dup[[name("DupSecondtLCN")]];
	u64 LCN3dup[[name("DupThirdLCN")]];
	u64 LCN4dup[[name("DupFourthLCN")]];
};

struct VOLUME_BOOT_RECORD {
	BYTE jmpInstruction[3] [[comment("Jump Instruction"), name("JumpInstruction")]];;
	FILESYSTEM FileSystem[[comment("FileSystemName"), name("FileSystem")]];
	BYTE UnKnown[5];
	char Identifier[4][[comment("File System Recognition Structure, allows OS to recognise the structure"), name("FSRSIdentifier")]];
	u16 Length[[comment("Size of VBR"), name("Length") ]];
	u16 Checksum[[comment("Computed FileSystem Information Checksum"), name("CheckSum")]];
	u64 TotalNoOfSectors;
	u32 BytesPerSec[[comment("Bytes Per Sector"), name("BytesPerSector")]];
	u32 SectorPerCluster[[comment("Sector Per Cluster"), name("SectorPerCluster")]];
	ReFS_Version ReFSVersion;
	BYTE UnknownBuff[0x0e][[name("Unknown")]];
	u64 SerialNo[[name("SerialNumber")]];

};
struct REFS_FILE_SYSTEM {
	u64 checkVal = std::mem::read_unsigned($+3, 8);
	$ = 0;
	if(checkVal == FILESYSTEM::ReFS){
		VOLUME_BOOT_RECORD vbr @ 0x00[[name("VolumeBootRecord")]];
		SUPERBLOCK SuperBlock @ (0x1e * 0x1000);

		CHECKPOINT PrimaryCheckPoint @(SuperBlock.primarychekpoint * 0x1000);
		keeptrack = 0;
		CHECKPOINT SecondaryCheckPoint @(SuperBlock.secondaychekpoint * 0x1000);
	}
	else{
		break;
	}
};

REFS_FILE_SYSTEM ReFSFileSystem @0x00;
