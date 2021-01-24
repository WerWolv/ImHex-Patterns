#pragma MIME application/x-dosexec

enum MachineType : u16 {
	Unknown = 0x00,
	AM33 = 0x1D3,
	AMD64 = 0x8664,
	ARM = 0x1C0,
	ARM64 = 0xAA64,
	ARMNT = 0x1C4,
	EBC = 0xEBC,
	I386 = 0x14C,
	IA64 = 0x200,
	M32R = 0x9041,
	MIPS16 = 0x266,
	MIPSFPU = 0x366,
	MIPSFPU16 = 0x466,
	POWERPC = 0x1F0,
	POWERPCFP = 0x1F1,
	R4000 = 0x166,
	RISCV32 = 0x5032,
	RISCV64 = 0x5064,
	RISCV128 = 0x5128,
	SH3 = 0x1A2,
	SH3DSP = 0x1A3,
	SH4 = 0x1A6,
	SH5 = 0x1A8,
	THUMB = 0x1C2,
	WCEMIPSV2 = 0x169
};

bitfield Characteristics {
	stripped : 1;
	executableImage : 1;
	lineNumsStripped : 1;
	localSymsStripped : 1;
	aggressiveWsTrim : 1;
	largeAddressAware : 1;
	reserved : 1;
	bytesReversedLo : 1;
	is32BitMachine : 1;
	debugStripped : 1;
	removableRunFromSwap : 1;
	netRunFromSwap : 1;
	system : 1;
	dll : 1;
	upSystemOnly : 1;
	bytesReversedHi : 1;
};

struct DataDirectory {
	u32 virtualAddress;
	u32 size;
};

struct OptionalHeader32 {
	u16 magic;
	u8 majorLinkerVersion;
	u8 minorLinkerVersion;
	u32 sizeOfCode;
	u32 sizeOfInitializedData;
	u32 sizeOfUninitializedData;
	u32 addressOfEntryPoint;
	u32 baseOfCode;
	u32 baseOfData;
	u32 imageBase;
	u32 sectionAlignment;
	u32 fileAlignment;
	u16 majorOperatingSystemVersion;
	u16 minorOperatingSystemVersion;
	u16 majorImageVersion;
	u16 minorImageVersion;
	u16 majorSubsystemVersion;
	u16 minorSubSystemVersion;
	u32 win32VersionValue;
	u32 sizeOfImage;
	u32 sizeOfHeaders;
	u32 checksum;
	u16 subsystem;
	u16 dllCharacteristics;
	u32 sizeOfStackReserve;
	u32 sizeOfStackCommit;
	u32 sizeOfHeapReserve;
	u32 sizeOfHeapCommit;
	u32 loaderFlags;
	u32 numberOfRvaAndSizes;
	DataDirectory directories[numberOfRvaAndSizes];
};

struct OptionalHeader64 {
	u16 magic;
	u8 majorLinkerVersion;
	u8 minorLinkerVersion;
	u32 sizeOfCode;
	u32 sizeOfInitializedData;
	u32 sizeOfUninitializedData;
	u32 addressOfEntryPoint;
	u32 baseOfCode;
	u64 imageBase;
	u32 sectionAlignment;
	u32 fileAlignment;
	u16 majorOperatingSystemVersion;
	u16 minorOperatingSystemVersion;
	u16 majorImageVersion;
	u16 minorImageVersion;
	u16 majorSubsystemVersion;
	u16 minorSubSystemVersion;
	u32 win32VersionValue;
	u32 sizeOfImage;
	u32 sizeOfHeaders;
	u32 checksum;
	u16 subsystem;
	u16 dllCharacteristics;
	u64 sizeOfStackReserve;
	u64 sizeOfStackCommit;
	u64 sizeOfHeapReserve;
	u64 sizeOfHeapCommit;
	u32 loaderFlags;
	u32 numberOfRvaAndSizes;
	DataDirectory directories[numberOfRvaAndSizes];
};

struct COFFHeader {
	u32 signature;
	MachineType machine;
	u16 numberOfSections;
	u32 timeDateStamp;
	u32 pointerToSymbolTable;
	u32 numberOfSymbolTable;
	u16 sizeOfOptionalHeader;
	Characteristics characteristics;
	
	if (machine == MachineType::AMD64) {
		OptionalHeader64 optionalHeader;
	} else {
		OptionalHeader32 optionalHeader;
	}
};

struct DOSHeader {
	u16 signature;
	u8 header[0x3A];
	COFFHeader *coffHeaderPointer : u32;
};

struct DOSStub {
	u8 code[14];
	s8 message[0x27];
	u8 data[11];
};

union SectionMisc {
	u32 physicalAddress;
	u32 virtualSize;
};

struct Section {
	char name[8];
	SectionMisc misc;
	u32 virtualAddress;
	u32 sizeOfRawData;
	u32 ptrRawData;
	u32 ptrRelocations;
	u32 ptrLineNumbers;
	u16 numberOfRelactions;
	u16 numberOfLineNumbers;
	u32 characteristics;
};

struct PEHeader {
	DOSHeader dosHeader;
	DOSStub dosStub;
};

PEHeader peHeader @ 0x00;

Section sectionsTable[peHeader.dosHeader.coffHeaderPointer.numberOfSections]
@ nextAfter("peHeader.dosHeader.coffHeaderPointer");
