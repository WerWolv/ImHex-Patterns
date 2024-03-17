#pragma author 5h4rrK
#pragma description ReFS-File-System

import type.types.win32;
import type.guid;

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
	BLOCK Signature;
	u32 unk;
	$ = $ + (0x8 + 0x10);
	u64 LCN1;
	u64 LCN2;
	u64 LCN3;
	u64 LCN4;
	u64 _Objid;
	u64 ObjId;

};

struct ATTRIBUTE {
	u64 LCN1;
	u64 LCN2;
	u64 LCN3;
	u64 LCN4;
	u32 Unk1;
	u32 Unk2;
	u64 checksum;
	BYTE ZeroPadding[56];
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
	META_HEADERS CheckPointMetaHeader;
	$ += (0x04);
	CheckPoint_REFS_Version ReFSVersion;
	u32 EntryOffset;
	u32 EntrySz;
	u64 blockno;
	$ += (0x28);
	u32 NumOfEntries;
	EntryArray AttributeEntries[NumOfEntries];
	$ += (0x08);
	u64 LCN1dup;
	u64 LCN2dup;
	u64 LCN3dup;
	u64 LCN4dup;
};


struct SUPERBLOCK {
	META_HEADERS SuperBlockMetaHeader;
	type::GUID GUID;
	$ = $ + (0x10 * 0x06);
	u64 primarychekpoint;
	u64 secondaychekpoint;
	u64 LCN1dup;
	u64 LCN2dup;
	u64 LCN3dup;
	u64 LCN4dup;
};

struct REFS_HEADER {
	BYTE jmpInstruction[3];
	FILESYSTEM FileSystem;
	BYTE UnKnown[5];
	char Identifier[4];
	u16 Length;
	u16 Cheksum;
	u64 TotalNoOfSectors;
	u32 BytesPerSec;
	u32 SectorPerCluster;
	ReFS_Version ReFSVersion;
	BYTE UnknownBuff[0x0e];
	u64 SerialNo;

};
struct REFS_FILE_SYSTEM {
	REFS_HEADER ReFSHeader @ 0x00;

	SUPERBLOCK SuperBlock @ (0x1e * 0x1000);

	CHECKPOINT PrimaryCheckPoint @(SuperBlock.primarychekpoint * 0x1000);
	keeptrack = 0;
	CHECKPOINT SecondaryCheckPoint @(SuperBlock.secondaychekpoint * 0x1000);
};

REFS_FILE_SYSTEM ReFSFileSystem @0x00;