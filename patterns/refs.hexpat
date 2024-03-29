#pragma author 5h4rrK // https://www.github.com/5h4rrK
#pragma organization temabi0s // (https://bi0s.in)
#pragma description ReFS-File-System 

#pragma array_limit 10000

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

struct SELF_DESCRIPTOR{
	u32 start = $;
	u64 LCN1[[name("FirstLCN")]];
	u64 LCN2[[name("SecondLCN")]];
	u64 LCN3[[name("ThirdLCN")]];
	u64 LCN4[[name("FourthLCN")]];
	$ = $+2;
	u8 checksumtype[[name("ChecksumType")]];
	u8 checksumoffset[[name("ChecksumOffset")]];
	u16 checksumlen[[name("CheckSumLength")]];
	$ = $+2;
	if(checksumtype == 2){
	u64 chksum[[comment("Crc64"),name("CRC64-CheckSum") ]];}
	else if(checksumtype == 1){
		u32 chksum[[comment("Crc32"),name("CRC32-CheckSum") ]];
	}
	u32 rem = this.parent.lenselfdescriptor  - ($ - start);
	BYTE buff[rem];
};

struct META_HEADERS {
	BLOCK Signature[[comment("Block Signature"), name("BlockSignature")]];
	u32 unk[[comment("Fixed Value 0x02"), name("Unknown")]];
	u32 zero[[name("AlwaysZero")]];
	u32 volsig[[name("VolumeSignature")]];
	u128 blockNo[[comment("Most Recent Block"), name("PageRecency")]];
	u64 LCN1[[comment("MetaPage 1st LogicalClusterNumber"), name("FirstLCN")]];
	u64 LCN2[[comment("MetaPage 2nd LogicalClusterNumber"), name("SecondLCN")]];
	u64 LCN3[[comment("MetaPage 3rd LogicalClusterNumber"), name("ThirdLCN")]];
	u64 LCN4[[comment("MetaPage 4th LogicalClusterNumber"), name("FourthLCN")]];
	u64 tableidlo[[name("TableIdentifierHigh")]];
	u64 tableidhi[[name("TableIdentifierLow")]];

};

struct OFFSET_ENTRIES{
	u16 offset[[name("Offset")]];
	u16 unk[[name("Ignore")]];
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

enum NodeType : BYTE {
	InnerNode = 0x01,
	RootNode = 0x02,
	StreamNode = 0x03,
};

struct INDEX_HEADER {
	u32 size[[name("DataStartOffset")]];
	u32 dataendoff[[name("DataAreaEndOffset")]];
	u32 freebuff[[name("FreeBuff")]];
	BYTE height[[name("Height")]];
	NodeType ntype[[name("NodeType")]];
	u16 unused1[[name("UnUsed")]];
	u32 keyindxoff[[name("KeyIndexOffset")]];
	u32 keycount[[name("KeysCount")]];
	u64 unused2[[name("UnUsed")]];
	u32 end[[name("KeyIndexEnd")]];
	u32 align[[name("Alignment")]];
	$ = this.parent.start_pos + 0x50 + this.parent.rootsize + keyindxoff;	
	OFFSET_ENTRIES entries[keycount][[name("KeyEntries")]];

};

enum Flags : u16 {
	RightMost = 0x02,
	DeletedEntry = 0x04,
	StreamIndexEntry = 0x40,
};

struct INDEX_ENTRY_STRUCTURE {
	u32 start_pos = $;
	u32 indxentlen[[name("IndxEntryLen")]];
	u16 keyoff[[name("KeyOffset")]];
	u16 keylen[[name("KeyLen")]];
	Flags flag[[name("Flags")]];
	u16 valoff[[name("ValOffset")]];
	u16 vallen[[name("ValLen")]];
	$ = start_pos + keyoff;
	char key[keylen][[name("Key")]];
	$ = start_pos + valoff;
	char value[vallen][[name("Value")]];
	$ = start_pos + indxentlen;
};

struct ROOT_NODE{
	u32 start_pos = $;
	META_HEADERS pagehdr[[name("PageHeader")]];
	u32 rootsize[[name("RootSize")]];
	u16 fixed[[name("Fixed(0x28)")]];
	u16 unk1[[name("Unknown")]];
	u16 unk2[[name("Unknown")]];
	u16 unk3[[name("Unknown")]];
	u16 schema[[name("TableSchema")]];
	u16 unk4[[name("Unknown")]];
	u16 schemadup[[name("TableSchema")]];
	u16 unk5[[name("Unknown")]];
	u16 unk6[[name("Unknown")]];
	u16 unk7[[name("Unknown")]];
	u64 noofextends[[name("ExtendCount")]];
	u64 noofrows[[name("RowsCount")]];
	char comps[rootsize - ($ - start_pos) + 0x50][[name("Components")]];
	$ = (start_pos + 0x50 + rootsize);
	INDEX_HEADER indxhdr[[name("IndexHeader")]];
	// $ = start_pos + 0x50 + rootsize + indxhdr.keyindxoff;	
	$ = (start_pos + 0x50 + rootsize + indxhdr.size);
	INDEX_ENTRY_STRUCTURE indxentrystruct[indxhdr.keycount][[name("IndexEntry")]];
};

u32 keeptrack = 0;

struct GLOBALROOTNODE {
	u32 GlobalElemEntryOff;
	u32 prev = $;
	$ = (0x1000 * ($ / 0x1000));
	$ = $ + GlobalElemEntryOff;
	keeptrack += 1;
	if (keeptrack == 1) {
		ATTRIBUTE ObjectIDTable;
	}
	else if (keeptrack == 2) {
		ATTRIBUTE MediumAllocatorTable;
	}
	else if (keeptrack == 3) {
		ATTRIBUTE ContainerAllocatorTable;
	}
	else if (keeptrack == 4) {
		ATTRIBUTE SchemaTable;
	}
	else if (keeptrack == 5) {
		ATTRIBUTE ParentChildTable[[comment("Parent Child Table")]];
	}
	else if (keeptrack == 6) {
		ATTRIBUTE ObjectIDDup;
	}
	else if (keeptrack == 7) {
		ATTRIBUTE BlockCountTable;
	}
	else if (keeptrack == 8) {
		ATTRIBUTE ContainerTable;
		u32 prev_pos = $;
		ROOT_NODE node1 @ (ContainerTable.LCN1 * clustersz)[[name("ContainerNode")]];
		$ = prev_pos;
	}
	else if (keeptrack == 9) {
		ATTRIBUTE ContainerTableDup;
		u32 prev_pos = $;
		ROOT_NODE node1 @ (ContainerTableDup.LCN1 * clustersz)[[name("ContainerDupNode")]];
		$ = prev_pos;
	}
	else if (keeptrack == 10) {
		ATTRIBUTE SchemaTableDup;
	}
	else if (keeptrack == 11) {
		ATTRIBUTE ContainerIndexTable;
	}
	else if (keeptrack == 12) {
		ATTRIBUTE IntegrityStateTable;
	}
	else if (keeptrack == 13) {
		ATTRIBUTE SmallAllocatorTable;
		u32 prev_pos = $;
		ROOT_NODE node1 @ (SmallAllocatorTable.LCN1 * clustersz)[[name("SmallAllocatorNode")]];
		$ = prev_pos;
	}
	$ = prev;
};

struct CHECKPOINT {
	META_HEADERS CheckPointMetaHeader[[name("FSPageMetaHeader")]];
	$ += (0x04);
	CheckPoint_REFS_Version ReFSVersion;
	u32 offsetselfdescriptor[[comment("Self Descriptor Offset")]];
	u32 lenselfdescriptor[[comment("Self Descriptor Size"),name("SelfDescriptorSz")]];
	u64 blockno[[comment("Most Recent CheckPoint") , name("BlockNumber")]];
	u32 prev_pos = $;
	$ = ($ / clustersz) *clustersz  + offsetselfdescriptor; 
	SELF_DESCRIPTOR selfdes[[name("SelfDescriptor")]];
	$ = prev_pos;
	$ += (0x28);
	u32 NumOfEntries;
	GLOBALROOTNODE GlobalRootNodes[NumOfEntries];
	$ += (0x08);
};

struct SUPERBLOCK {
	META_HEADERS SuperBlockMetaHeader[[name("FSPageMetaHeader")]];
	type::GUID GUID;
	$ = $ + (0x10 * 0x01);
	u32 checkpointOffset[[name("CheckPointOffset")]];
	u32 noofcheckpoint[[name("NoOfCheckPointEntry")]];
	u32 offsetselfdescriptor[[name("SelfDescriptorOffset")]];
	u32 lenselfdescriptor[[name("SelfDescriptorLength")]];
	$ = $ + (0x10 * 0x04);
	u64 primarychekpoint[[name("PrimaryCheckPoint")]];
	u64 secondaychekpoint[[name("SecondaryCheckPoint")]];
	SELF_DESCRIPTOR selfdes[[name("SelfDescriptor")]];
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
	u64 BytesPerContainer[[name("BytesPerContainer")]];

};

struct REFS_FILE_SYSTEM {
	u64 checkVal = std::mem::read_unsigned($+3, 8);
	$ = 0;
	if(checkVal == FILESYSTEM::ReFS){
		VOLUME_BOOT_RECORD vbr @ 0x00[[name("VolumeBootRecord")]];
		SUPERBLOCK SuperBlock1 @ (0x1e * 0x1000)[[name("SuperBlock1")]];
		u32 cluster_size = vbr.BytesPerSec * vbr.SectorPerCluster;

		CHECKPOINT PrimaryCheckPoint @(SuperBlock1.primarychekpoint * cluster_size)[[name("PrimaryCheckPoint1")]];
		keeptrack = 0;
		CHECKPOINT SecondaryCheckPoint @(SuperBlock1.secondaychekpoint * cluster_size)[[name("SecondaryCheckPoint1")]];

		SUPERBLOCK SuperBlock2 @(((vbr.TotalNoOfSectors / vbr.SectorPerCluster) - 3) * cluster_size)[[name("SuperBlock2")]];
		keeptrack = 0;
		CHECKPOINT PrimaryCheckPoint2 @(SuperBlock2.primarychekpoint * cluster_size)[[name("PrimaryCheckPoint2")]];
		keeptrack = 0;
		CHECKPOINT SecondaryCheckPoint2 @(SuperBlock2.secondaychekpoint * cluster_size)[[name("SecondaryCheckPoint2")]];

		SUPERBLOCK SuperBlock3 @(((vbr.TotalNoOfSectors / vbr.SectorPerCluster) - 2) * cluster_size)[[name("SuperBlock3")]];
		keeptrack = 0;
		CHECKPOINT PrimaryCheckPoint3 @(SuperBlock3.primarychekpoint * cluster_size)[[name("PrimaryCheckPoint3")]];
		keeptrack = 0;
		CHECKPOINT SecondaryCheckPoint3 @(SuperBlock3.secondaychekpoint * cluster_size)[[name("SecondaryCheckPoint3")]];
	}
	else{
		exit(0);
	}
};
u32 clustersz = std::mem::read_unsigned($ + 0x20, $+4) * std::mem::read_unsigned($ + 0x24, $+4);
REFS_FILE_SYSTEM ReFSFileSystem @0x00;
