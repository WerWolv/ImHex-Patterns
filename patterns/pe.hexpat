#pragma MIME application/x-msdownload
#pragma MIME application/x-dosexec

#pragma pattern_limit 100000
#pragma array_limit 10000

#include <std/mem.pat>
#include <std/string.pat>
#include <std/ctype.pat>
#include <std/io.pat>

enum MachineType : u16 {
	Unknown = 0x00,
	AM33 = 0x1D3,
	AMD64 = 0x8664,
	ARM = 0x1C0,
	ARM64 = 0xAA64,
	ARMNT = 0x1C4,
	DECAlphaAXP = 0x183,
	EBC = 0xEBC,
	I386 = 0x14C,
	I860 = 0x14D,
	IA64 = 0x200,
	LOONGARCH32 = 0x6232,
	LOONGARCH64 = 0x6264,
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

enum PEFormat : u16 {
	PE32 = 0x10B,
	PE32Plus = 0x20B
};

enum SubsystemType : u16 {
	Unknown = 0x00,
	Native = 0x01,
	WindowsGUI = 0x02,
	WindowsCUI = 0x03,
	OS2CUI = 0x05,
	POSIXCUI = 0x07,
	Windows9xNative = 0x08,
	WindowsCEGUI = 0x09,
	EFIApplication = 0x0A,
	EFIBootServiceDriver = 0x0B,
	EFIRuntimeDriver = 0x0C,
	EFIROM = 0x0D,
	Xbox = 0x0E,
	WindowsBootApplication = 0x10
};

bitfield Characteristics {
	relocationsStripped : 1;
	executableImage : 1;
	lineNumbersStripped : 1;
	localSymbolsStripped : 1;
	aggressiveWsTrim : 1;
	largeAddressAware : 1;
	padding : 1;
	bytesReversedLo : 1;
	is32BitMachine : 1;
	debugInfoStripped : 1;
	removableRunFromSwap : 1;
	netRunFromSwap : 1;
	system : 1;
	dll : 1;
	uniprocessorMachineOnly : 1;
	bytesReversedHi : 1;
} [[right_to_left]];

bitfield DLLCharacteristics {
	padding : 4;
	padding : 1;
	highEntropyVA : 1;
	dynamicBase : 1;
	forceIntegrity : 1;
	nxCompatible : 1;
	noIsolation : 1;
	noSEH : 1;
	doNotBind : 1;
	appContainer : 1;
	wdmDriver : 1;
	cfGuard : 1;
	terminalServerAware : 1;
} [[right_to_left]];

bitfield SectionFlags {
	padding : 3;
	doNotPad : 1;
	padding : 1;
	containsCode : 1;
	containsInitializedData : 1;
	containsUninitializedData : 1;
	linkOther : 1;
	comments : 1;
	padding : 1;
	remove : 1;
	comdat : 1;
	padding : 2;
	globalPointerRelocation : 1;
	purgeable : 1;
	is16Bit : 1;
	locked : 1;
	preloaded : 1;
	dataAlignment : 4;
	extendedRelocations : 1;
	discardable : 1;
	notCacheable : 1;
	notPageable : 1;
	shared : 1;
	executed : 1;
	read : 1;
	writtenTo : 1;
} [[right_to_left]];

struct DataDirectory {
	u32 virtualAddress;
	u32 size;
};

struct OptionalHeader {
	PEFormat magic;
	u8 majorLinkerVersion;
	u8 minorLinkerVersion;
	u32 sizeOfCode;
	u32 sizeOfInitializedData;
	u32 sizeOfUninitializedData;
	u32 addressOfEntryPoint;
	u32 baseOfCode;
	if (magic == PEFormat::PE32) {
		u32 baseOfData;
		u32 imageBase;
	}
	else if (magic == PEFormat::PE32Plus) {
		u64 imageBase;
	}
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
	SubsystemType subsystem;
	DLLCharacteristics dllCharacteristics;
	if (magic == PEFormat::PE32) {
		u32 sizeOfStackReserve;
		u32 sizeOfStackCommit;
		u32 sizeOfHeapReserve;
		u32 sizeOfHeapCommit;
	}
	else if (magic == PEFormat::PE32Plus) {
		u64 sizeOfStackReserve;
		u64 sizeOfStackCommit;
		u64 sizeOfHeapReserve;
		u64 sizeOfHeapCommit;
	}
	u32 loaderFlags;
	u32 numberOfRVAsAndSizes;
	DataDirectory directories[numberOfRVAsAndSizes];
};

struct COFFHeader { 
	char signature[4];
	MachineType machine;
	u16 numberOfSections;
	u32 timeDateStamp;
	u32 pointerToSymbolTable;
	u32 numberOfSymbols;
	u16 sizeOfOptionalHeader;
	Characteristics characteristics;

	if (sizeOfOptionalHeader > 0x00) {
		OptionalHeader optionalHeader;
	}
};

struct DOSHeader {
	char signature[2];
	u16 lastPageSize;
	u16 numberOfPages;
	u16 relocations;
	u16 headerSizeInParagraphs;
	u16 minimumAllocatedParagraphs;
	u16 maximumAllocatedParagraphs;
	u16 initialSSValue;
	u16 initialRelativeSPValue;
	u16 checksum;
	u16 initialRelativeIPValue;
	u16 initialCSValue;
	u16 relocationsTablePointer;
	u16 overlayNumber;
	padding[4 * 2];
	u16 oemIdentifier;
	u16 oemInformation;
	padding[10 * 2];
	u32 coffHeaderPointer;
};

fn isdosmessage(char c) {
	return std::ctype::isalnum(c) || c == '.' || c == ' ';
};

struct DOSStub {
	u8 code[while(std::mem::read_string($, 4) != "This")];
	char message[while(isdosmessage(std::mem::read_unsigned($, 1)))];
	char data[while(std::mem::read_unsigned($, 1) != 0x00)];
};

struct PEHeader {
	DOSHeader dosHeader;
	if (dosHeader.headerSizeInParagraphs * 16 < std::mem::size()) {
		DOSStub dosStub @ dosHeader.headerSizeInParagraphs * 16;
	}
};

PEHeader peHeader @ 0x00;

COFFHeader coffHeader @ peHeader.dosHeader.coffHeaderPointer;

struct SectionHeader {
	char name[8];
	if (coffHeader.characteristics.executableImage) {
		u32 virtualSize;
	} else {
		u32 physicalAddress;
	}
	u32 virtualAddress;
	u32 sizeOfRawData;
	u32 ptrRawData;
	u32 ptrRelocations;
	u32 ptrLineNumbers;
	u16 numberOfRelocations;
	u16 numberOfLineNumbers;
	SectionFlags characteristics;
};

SectionHeader sectionTable[coffHeader.numberOfSections] @ (addressof(coffHeader.characteristics) + 2) + coffHeader.sizeOfOptionalHeader;

u16 currentSectionIndex;
fn updateSectionIndex() {
	currentSectionIndex = currentSectionIndex + 1;
};

struct NullTerminatedString {
	char string[while(std::mem::read_unsigned($, 1) != 0x00)];
	padding[1];
} [[inline]];

// Declarations of sections and variables used by it
// Imports + Readonly Data Section
struct DirectoryTable {
	u32 lookupTableRVA;
	u32 timeDateStamp;
	u32 forwarderChain;
	u32 dllNameRVA;
	u32 addressTableRVA;
};

struct ImportsSection {
	DirectoryTable directoryTables[while(std::mem::read_unsigned($, 16) != 0x00)];
	DirectoryTable nullDirectoryTable;
};

struct ReadonlyDataSection {
	u8 readonlyDataStart[while($ < coffHeader.optionalHeader.directories[1].virtualAddress - (sectionTable[currentSectionIndex].virtualAddress - sectionTable[currentSectionIndex].ptrRawData))];
	ImportsSection importsSection;
	u8 readonlyDataEnd[while($ < sectionTable[currentSectionIndex+1].ptrRawData)];
};

// Resource Section
struct ResourceDirectoryTable {
	u32 characteristics;
	u32 timeDateStamp;
	u16 majorVersion;
	u16 minorVersion;
	u16 nameEntriesAmount;
	u16 idEntriesAmount;
};

enum ResourceID : u32 {
	Bitmap = 0x02,
	Icon = 0x03,
	Menu = 0x04,
	Dialog = 0x05,
	String = 0x06,
	GroupIcon = 0x0D,
	Version = 0x10,
	Manifest = 0x18
};

struct IdDirectoryEntry {
	ResourceID id;
	u32 relativeOffsetToData;
};

struct ResourceDirectory {
	ResourceDirectoryTable resourceDirectoryTable;
	IdDirectoryEntry idEntries[resourceDirectoryTable.idEntriesAmount];
};

struct ResourceSection {
	ResourceDirectory rootDirectory;	
};

// Exports Section
struct ExportDirectoryTable {
	u32 exportFlags;
	u32 timeDateStamp;
	u16 majorVersion;
	u16 minorVersion;
	u32 nameRVA;
	u32 ordinalBase;
	u32 addressTableEntries;
	u32 numberOfNamePointers;
	u32 exportAddressTableRVA;
	u32 namePointerRVA;
	u32 ordinalTableRVA;
};

struct ExportAddress {
	if (std::mem::read_unsigned($, 4) > sectionTable[currentSectionIndex].sizeOfRawData && std::mem::read_unsigned($, 4) < sectionTable[currentSectionIndex].ptrRawData) {
		u32 exportRVA;
	}
	else {
		u32 forwarderRVA;
	}
};

struct ExportsSection {
	ExportDirectoryTable exportDirectoryTable;
	ExportAddress exportAddressTable[exportDirectoryTable.addressTableEntries];
	u32 exportNamePointerTable[exportDirectoryTable.numberOfNamePointers];
};

// Exception Section
bitfield ExceptionSectionBits {
	functionLength : 22;
	instructions32Bit : 1; 
	exceptionHandler : 1;
} [[right_to_left]];

struct FunctionTableEntry {
	if (coffHeader.machine == MachineType::MIPSFPU) {
		u32 beginVA;
		u32 endVA;
		u32 exceptionHandlerPointer;
		u32 handlerDataPointer;
		u32 prologEndVA;
	} else if (coffHeader.machine == MachineType::ARM || MachineType::ARM64 || MachineType::ARMNT || MachineType::POWERPC || MachineType::POWERPCFP || MachineType::SH3 || MachineType::SH4) {
		u32 beginVA;
		u8 prologLength;
		ExceptionSectionBits miscellaneousBits;
	} else if (coffHeader.machine == MachineType::AMD64 || MachineType::IA64) {
		u32 beginRVA;
		u32 endRVA;
		u32	unwindInformationRVA;
	}
};

struct ExceptionSection {
	FunctionTableEntry functionTableEntries[while($ < sectionTable[currentSectionIndex].ptrRawData + sectionTable[currentSectionIndex].sizeOfRawData)];	
};

// TLS Section
struct TLSSection {
	if (coffHeader.optionalHeader.magic == PEFormat::PE32) {
		u32 rawDataStartVA;
		u32 rawDataEndVA;
		u32 indexAddress;
		u32 callbacksAddress;
	}
	else if (coffHeader.optionalHeader.magic == PEFormat::PE32Plus) {
		u64 rawDataStartVA;
		u64 rawDataEndVA;
		u64 indexAddress;
		u64 callbacksAddress;
	}
	u32 zeroFillSize;
	u32 characteristics;
};

// Relocations Section
bitfield RelocationWord {
	type : 4;
	offset : 12;
};

struct BaseRelocationBlock {
	u32 pageRVA;
	u32 blockSize;
	RelocationWord word;
};

struct BaseRelocationTable {
	BaseRelocationBlock baseRelocationBlocks[while(std::mem::read_unsigned($, 8) != 0x00)];
};

// General Section things
enum I386Relocations : u16 {
	Absolute = 0x00,
	Dir16 = 0x01,
	Rel16 = 0x02,
	Dir32 = 0x06
};

struct Relocation {
	u32 virtualAddress;
	u32 symbolTableIndex;
	if (coffHeader.machine == MachineType::I386) {
		I386Relocations type;
	}
	else {
		u16 type;
	}
};

struct LineNumber {
	u32 lineNumber @ $ + 4;
	if (lineNumber > 0x00) {
		u32 virtualAddress @ $ - 8;
	} else {
		u32 symbolTableIndex @ $ - 8;
	}
	$ += 8;
};

fn importsSectionExists() { 
	bool returnedValue = false;
	std::print("Checking which section is .idata for read-only data section");
	for (u16 i = 0, i < coffHeader.numberOfSections, i = i + 1) {
		std::print("Checking section " + std::string::to_string(i));
		if (sectionTable[i].name == ".idata") {
		 	std::print("Check successful. Section " + std::string::to_string(i) + " is .idata, so the read-only data section won't have an imports section in it");
			returnedValue = true;
			break;
		}
	}
	if (!returnedValue) {
		std::print("Check failed! This means there is no separate imports section");
	}
	return returnedValue;
};

struct Section {
	if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".pdata")) {	 // Exception section
		ExceptionSection exceptionSection;
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".rdata")) {// Read-only data section
		if (importsSectionExists() || coffHeader.optionalHeader.directories[1].size == 0) {
			u8 readonlyDataSection[sectionTable[currentSectionIndex].sizeOfRawData]; 
		}
		else {
			ReadonlyDataSection readonlyDataSection;
		}
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".idata")) {// Imports section
		ImportsSection importsSection;
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".edata")) {// Exports section
		ExportsSection exportsSection;
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".rsrc")) { // Resource section
		ResourceSection resourceSection;
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".tls")) {  // Thread-local storage section
		TLSSection tlsSection;
	}
	else if (std::string::starts_with(sectionTable[currentSectionIndex].name, ".reloc")) {// Thread-local storage section
		BaseRelocationTable relocationsSection;
	}
	else {
		u8 freeformSection[sectionTable[currentSectionIndex].sizeOfRawData];			  // Freeform data section
	}
	
	// Additional things
	//Relocation relocations[sectionTable[currentSectionIndex].numberOfRelocations] @ sectionTable[currentSectionIndex].ptrRelocations;
	LineNumber lineNumbers[sectionTable[currentSectionIndex].numberOfLineNumbers] @ sectionTable[currentSectionIndex].ptrLineNumbers;
	
	// Next section
	if (currentSectionIndex < coffHeader.numberOfSections-1) {		// If it's not the last section (to avoid problems this code would have with it)
		updateSectionIndex();										// Make the current section index the next section's index
		if (sectionTable[currentSectionIndex].sizeOfRawData > 0) {	// If the size of this section is bigger than 0
			$ = sectionTable[currentSectionIndex].ptrRawData;		// Put the current offset at the start of the next section 
		}
	}
} [[inline]];

Section sections[coffHeader.numberOfSections] @ sectionTable[0].ptrRawData;

// Symbol & String Tables
enum SectionNumberType : s16 {
	Undefined = 0,
	Absolute = -1,
	Debug = -2
};

enum SymbolTypeMSB : u8 {
	Null = 0x00,
	Pointer = 0x10,
	Function = 0x20,
	Array = 0x30
};

enum SymbolTypeLSB : u8 {
	Null = 0x00,
	Void = 0x01,
	Char = 0x02,
	Short = 0x03,
	Integer = 0x04,
	Long = 0x05,
	Float = 0x06,
	Double = 0x07,
	Struct = 0x08,
	Union = 0x09,
	Enum = 0x0A,
	MemberOfEnum = 0x0B,
	Byte = 0x0C,
	Word = 0x0D,
	UInt = 0x0E,
	DWord = 0x0F
};

enum StorageClassType : s8 {
	EndOfFunction = -1,
	Null = 0,
	Automatic = 1,
	External = 2,
	Static = 3,
	Register = 4,
	DefinedExternally = 5,
	Label = 6,
	UndefinedLabel = 7,
	MemberOfStruct = 8,
	Argument = 9,
	StructTag = 10,
	MemberOfUnion = 11,
	UnionTag = 12,
	TypeDefinition = 13,
	UndefinedStatic = 14,
	EnumTag = 15,
	MemberOfEnum = 16,
	RegisterParameter = 17,
	Bitfield = 18,
	Block = 100,
	BlockFunction = 101,
	EndOfStruct = 102,
	File = 103,
	Section = 104,
	WeakExternal = 105,
	CLRToken = 107
};

struct SymbolNameAddress {
	u32 zeroes;
	u32 offset;
};

struct SymbolName {
	if (std::mem::read_unsigned($, 4) == 0) {
		SymbolNameAddress nameAddress;
	}
	else {
		char shortName[8];
	}
};

struct SymbolType {
	SymbolTypeMSB msb;
	SymbolTypeLSB lsb;
};

struct Symbol {
	SymbolName name;
	u32 value;
	SectionNumberType sectionNumber;
	SymbolType type;
	StorageClassType storageClass;
	u8 numberOfAuxSymbols;
};

Symbol symbolTable[coffHeader.numberOfSymbols] @ coffHeader.pointerToSymbolTable;

struct StringTable {
	u32 size;
	NullTerminatedString strings[while($ < addressof(this) + size)];
} [[inline]];

StringTable stringTable[coffHeader.numberOfSymbols > 0] @ addressof(symbolTable) + sizeof(symbolTable);

// Rich Header
enum ProductType : u16 {
	Unmarked = 0x00 ^ richHeaderEnd[0].mask.maskArray[1],
	Imports = 0x01 ^ richHeaderEnd[0].mask.maskArray[1],
	STDLIBDLL = 0x04 ^ richHeaderEnd[0].mask.maskArray[1],
	VC6CVTRes = 0x06 ^ richHeaderEnd[0].mask.maskArray[1],
	VC6CCompiler = 0x0A ^ richHeaderEnd[0].mask.maskArray[1],
	VC6CPPCompiler = 0x0B ^ richHeaderEnd[0].mask.maskArray[1],
	OldNames = 0x0C ^ richHeaderEnd[0].mask.maskArray[1],
	MASM613 = 0x0E ^ richHeaderEnd[0].mask.maskArray[1],
	VC2003Assembler = 0x0F ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002Linker = 0x19 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002CCompiler = 0x1C ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002CPPCompiler = 0x1D ^ richHeaderEnd[0].mask.maskArray[1],
	VC2003SDKIMP = 0x5D ^ richHeaderEnd[0].mask.maskArray[1],
	VC2003CPPCompiler = 0x60 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2008SDKIMP = 0x93 ^ richHeaderEnd[0].mask.maskArray[1],
	Linker12 = 0x9D ^ richHeaderEnd[0].mask.maskArray[1],
	MASM10 = 0x9E ^ richHeaderEnd[0].mask.maskArray[1],
	VC2010CCompiler = 0xAA ^ richHeaderEnd[0].mask.maskArray[1],
	VC2010CPPCompiler = 0xAB ^ richHeaderEnd[0].mask.maskArray[1]
};

union RichHeaderMask {
	u32 maskVariable;
	u16 maskArray[2];
};

struct RichHeaderEnd {
	char signature[4];
	RichHeaderMask mask;
} [[inline]];

u8 richHeaderAmount;
u8 richHeaderEndPosition;
u8 richHeaderCorpusPosition;
fn initializeRichHeader() {
	$ = sizeof(peHeader);
	while ($ < peHeader.dosHeader.coffHeaderPointer) {
		if (std::mem::read_string($, 4) == "Rich") {
			richHeaderAmount = 1;
			richHeaderEndPosition = $;
			break;
		}
		$ += 1;
	}
};
initializeRichHeader();

RichHeaderEnd richHeaderEnd[richHeaderAmount] @ richHeaderEndPosition;

struct Product {
	u16 buildNumber;
	ProductType productID;
	u32 objectCount;
};

struct RichHeaderCorpus {
	char maskedSignature[4];
	u32 nullPadding[3];
	Product products[while($ != richHeaderEndPosition)];
} [[inline]];

fn setupRichHeader() {
	if (richHeaderAmount > 0) {
		//0x20 is the size of a Rich Header with one product
		for (u8 richCursor = $ - 0x20, richCursor > sizeof(peHeader), richCursor = richCursor - 0x01) {
			if (str(std::mem::read_unsigned(richCursor, 4) ^ richHeaderEnd[0].mask.maskVariable) == "DanS") {
				richHeaderCorpusPosition = richCursor;		
				break;
			}
		}
	}
};
setupRichHeader();

RichHeaderCorpus richHeaderCorpus[richHeaderAmount] @ richHeaderCorpusPosition;
