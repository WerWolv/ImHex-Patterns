#pragma author WerWolv
#pragma description PE header, COFF header, Standard COFF fields and Windows Specific fields

#pragma MIME application/x-dosexec
#pragma MIME application/x-msdownload

#include <std/string.pat>
#include <std/mem.pat>

// Rich Header
bool checkForRichHeader in;
u16 richHeaderEndPosition;
fn initializeRichHeader() {
	if (checkForRichHeader) {
		for	(u16 richEndCursor = std::mem::read_unsigned(0x08, 2)*16, richEndCursor < std::mem::read_unsigned(0x3C, 2), richEndCursor = richEndCursor + 1) {
			if (std::mem::read_string(richEndCursor, 4) == "Rich") {
				richHeaderEndPosition = richEndCursor;
				break;
			}
		}
	}
};
initializeRichHeader();

fn formatHexadecimally(auto value) {
	return std::string::to_string(value) + " (" + std::format("0x{:X}", value) + ")";
};
fn unmaskBuild(u16 value) {
	return formatHexadecimally(value ^ std::mem::read_unsigned(richHeaderEndPosition+4, 2));
};
fn unmask(u32 value) {
	return formatHexadecimally(value ^ std::mem::read_unsigned(richHeaderEndPosition+4, 4));
};

enum ProductType : u16 {
	Unmarked = 0x00 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	Imports = 0x01 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	STDLIBDLL = 0x04 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS6CVTRes = 0x06 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS6CCompiler = 0x0A ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS6CPPCompiler = 0x0B ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	OldNames = 0x0C ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	MASM613 = 0x0E ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2003Assembler = 0x0F ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VC6SP5 = 0x16 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2002Linker = 0x19 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2002CCompiler = 0x1C ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2002CPPCompiler = 0x1D ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2003SDKIMP = 0x5D ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2003CPPCompiler = 0x60 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2005CCompiler = 0x6D ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2005CPPCompiler = 0x6E ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2005Linker = 0x7B ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2008Linker = 0x93 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	Linker12 = 0x9D ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	MASM10 = 0x9E ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2010CCompiler = 0xAA ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2010CPPCompiler = 0xAB ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2015CVTRes = 0xFF ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2015Linker = 0x101 ... 0x102 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2015Assembler = 0x103 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2015CCompiler = 0x104 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2),
	VS2015CPPCompiler = 0x105 ^ std::mem::read_unsigned(richHeaderEndPosition+6, 2)
};

struct Product {
	u16 buildNumber [[format("unmaskBuild")]];
	ProductType productID;
	u32 objectCount [[format("unmask")]];
};

using NullPadding = u32 [[format("unmask")]];
fn formatSignature(auto value) {
	return "\"DanS\" ";
};

struct RichHeader {
	char maskedSignature[4] [[format("formatSignature")]];
	NullPadding nullPadding[3];
	Product products[while($ < richHeaderEndPosition)];
	char signature[4];
	u32 mask;
} [[inline]];

u8 richHeaderCorpusPosition;
fn setupRichHeader() {
	if (checkForRichHeader) {
		//0x20 is the size of a Rich Header with one product
		for (u16 richCorpusCursor = richHeaderEndPosition - 0x20, richCorpusCursor > std::mem::read_unsigned(0x08, 2)*16, richCorpusCursor = richCorpusCursor - 0x01) {
			if (str(std::mem::read_unsigned(richCorpusCursor, 4) ^ std::mem::read_unsigned(richHeaderEndPosition+4, 4)) == "DanS") {
				richHeaderCorpusPosition = richCorpusCursor;
				break;
			}
		}
	}
};
setupRichHeader();

RichHeader richHeader[checkForRichHeader] @ richHeaderCorpusPosition;

// PE headers
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
	u16 stubChecksum;
	u16 initialRelativeIPValue;
	u16 initialCSValue;
	u16 relocationsTablePointer;
	u16 overlayNumber;
	u16 reservedWords[4];
	u16 oemIdentifier;
	u16 oemInformation;
	u16 otherReservedWords[10];
	u32 coffHeaderPointer;
};

u16 dosMessageOffset;
bool foundDOSMessage;
fn finddosmessage() {
	for (u8 i = 0, $+i < std::mem::read_unsigned(0x3C, 4), i = i + 1) {
		if (foundDOSMessage && std::mem::read_unsigned($+i, 1) == 0xBA) { // Message offset instruction
			dosMessageOffset = std::mem::read_unsigned($+i+1, 2);
			break;
		}
		else if (std::mem::read_unsigned($+i, 4) == 0x21CD09B4) { // Output message instructions
			foundDOSMessage = true;
			i = 0;
		}
	}
};

fn isntdosmessage(char c) {
	return c == 0x0D || c == 0x0A || c == '$';
};

struct DOSStub {
	finddosmessage();
	if (dosMessageOffset > 0) {
		u8 code[while($ != addressof(this) + dosMessageOffset)];
		char message[while(!isntdosmessage(std::mem::read_unsigned($, 1)))];
		if (richHeaderEndPosition>0) {
			char data[while($ < richHeaderCorpusPosition)];
		}
		else {
			char data[while($ < std::mem::read_unsigned(0x3C, 4))];
		}
	} else {
		u8 dosStub[while(std::mem::read_unsigned($, 5) > 0x00)] [[inline]];
	}
};

struct PEHeader {
	if (std::mem::size() > std::mem::read_unsigned(0x08, 2) > 0) {
		DOSHeader dosHeader;
		DOSStub dosStub;
	}
	else {
		DOSHeader dosHeader [[inline]];
	}
};

PEHeader peHeader @ 0x00;

enum MachineType : u16 {
	Unknown = 0x00,
	AlphaAXPOld = 0x183,
	AlphaAXP = 0x184,
	AlphaAXP64Bit = 0x284,
	AM33 = 0x1D3,
	AMD64 = 0x8664,
	ARM = 0x1C0,
	ARM64 = 0xAA64,
	ARMNT = 0x1C4,
	CLRPureMSIL = 0xC0EE,
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
	MOTOROLA68000 = 0x268,
	POWERPC = 0x1F0,
	POWERPCFP = 0x1F1,
	POWERPC64 = 0x1F2,
	R3000 = 0x162,
	R4000 = 0x166,
	R10000 = 0x168,
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
	ROM = 0x107,
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
	symbolsStripped : 1;
	aggressivelyTrimWorkingSet : 1;
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
};

bitfield DLLCharacteristics {
	callWhenLoaded : 1;
	callWhenThreadTerminates : 1;
	callWhenThreadStarts : 1;
	callWhenExiting : 1;
	padding : 1;
	highEntropyVA : 1;
	dynamicBase : 1;
	forceIntegrity : 1;
	nxCompatible : 1;
	noIsolation : 1;
	noSEH : 1;
	doNotBind : 1;
	appContainer : 1;
	isWDMDriver : 1;
	supportsControlFlowGuard : 1;
	terminalServerAware : 1;
};

struct DataDirectory {
	u32 rva;
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
	u32 virtualSectionAlignment;
	u32 rawSectionAlignment;
	u16 majorOperatingSystemVersion;
	u16 minorOperatingSystemVersion;
	u16 majorImageVersion;
	u16 minorImageVersion;
	u16 majorSubsystemVersion;
	u16 minorSubsystemVersion;
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

COFFHeader coffHeader @ peHeader.dosHeader.coffHeaderPointer;

enum AlignmentType : u8 {
	None,
	BoundaryOf1Byte,
	BoundaryOf2Bytes,
	BoundaryOf4Bytes,
	BoundaryOf8Bytes,
	BoundaryOf16Bytes,
	BoundaryOf32Bytes,
	BoundaryOf64Bytes,
	BoundaryOf128Bytes,
	BoundaryOf256Bytes,
	BoundaryOf512Bytes,
	BoundaryOf1024Bytes,
	BoundaryOf2048Bytes,
	BoundaryOf4096Bytes,
	BoundaryOf8192Bytes,
};

fn formatAlignmentBits(u8 value) {
	AlignmentType enumValue = value;

	return enumValue;
};

bitfield SectionFlags {
	padding : 3;
	doNotPad : 1;
	padding : 1;
	containsCode : 1;
	containsInitializedData : 1;
	containsUninitializedData : 1;
	linkOther : 1;
	linkHasInformation : 1;
	padding : 1;
	linkRemove : 1;
	linkHasCOMDAT : 1;
	padding : 1;
	resetSpeculativeExceptions : 1;
	globalPointerRelocations : 1;
	purgeable : 1;
	is16Bit : 1;
	locked : 1;
	preloaded : 1;
	dataAlignment : 4;
	linkExtendedRelocations : 1;
	discardable : 1;
	notCached : 1;
	notPageable : 1;
	shared : 1;
	executed : 1;
	read : 1;
	writtenOn : 1;
};

fn formatSectionName(str string) {
	u8 actualStringLength;
	for (u8 i = 0, i < 8, i = i + 1) {
		if (std::mem::read_unsigned($+i, 1) > 0) {
			actualStringLength = actualStringLength + 1;
		}
		else {
			break;
		}
	}
	return "\"" + std::string::substr(string, 0, actualStringLength) + "\"";
};

struct SectionHeader {
	char name[8] [[format("formatSectionName")]];
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

SectionHeader sectionsTable[coffHeader.numberOfSections] @ addressof(coffHeader.characteristics)+2 + coffHeader.sizeOfOptionalHeader;

// Sections
u16 currentSectionIndex;

// Exception Section
bitfield FunctionBitfield {
	prologLength : 8;
	functionLength : 22;
	instructions32Bit : 1;
	exceptionHandler : 1;
};

struct FunctionTableEntry {
	if (coffHeader.machine == MachineType::MIPSFPU) {
		u32 beginVA;
		u32 endVA;
		u32 exceptionHandlerPointer;
		u32 handlerDataPointer;
		u32 prologEndVA;
	} else if (coffHeader.machine == MachineType::ARM || coffHeader.machine == MachineType::ARM64 || coffHeader.machine == MachineType::ARMNT || coffHeader.machine == MachineType::POWERPC || coffHeader.machine == MachineType::POWERPCFP || coffHeader.machine == MachineType::SH3 || coffHeader.machine == MachineType::SH4) {
		u32 beginVA;
		FunctionBitfield miscellaneousBits;
	} else if (coffHeader.machine == MachineType::AMD64 || coffHeader.machine == MachineType::IA64) {
		u32 beginRVA;
		u32 endRVA;
		u32	unwindInformationRVA;
	}
};

struct ExceptionTable {
	FunctionTableEntry functionTableEntries[while($ < (coffHeader.optionalHeader.directories[3].rva - virtualDataDifference()) + coffHeader.optionalHeader.directories[3].size)] [[inline]];
};

// Exports Table
struct ExportDirectoryTable {
	u32 flags [[name("exportFlags")]];
	u32 timeDateStamp [[name("exportTimeDateStamp")]];
	u16 majorVersion;
	u16 minorVersion;
	u32 imageNameRVA;
	u32 ordinalBase [[name("exportOrdinalBase")]];
	u32 addressesAmount [[name("exportAddressesAmount")]];
	u32 namePointersAmount [[name("exportNamePointersAmount")]];
	u32 addressTableRVA [[name("exportAddressTableRVA")]];
	u32 namePointerTableRVA [[name("exportNamePointerTableRVA")]];
	u32 ordinalTableRVA [[name("exportOrdinalTableRVA")]];
};

struct ExportAddress {
	if (sectionsTable[currentSectionIndex].ptrRawData > std::mem::read_unsigned($, 4) > sectionsTable[currentSectionIndex].sizeOfRawData) {
		u32 exportRVA;
	}
	else {
		u32 forwarderRVA;
	}
};

fn formatNullTerminatedString(str string) {
	return "\"" + std::string::substr(string, 0, std::string::length(string)-1) + "\"";
};

struct ExportName {
	char exportName[] [[format("formatNullTerminatedString")]];
};

fn virtualDataDifference() {
	return sectionsTable[currentSectionIndex].virtualAddress - sectionsTable[currentSectionIndex].ptrRawData;
};

struct ExportNamePointer {
	u32 exportNameRVA;
	ExportName name @ exportNameRVA - virtualDataDifference();
};

struct ExportsTable {
	ExportDirectoryTable exportDirectoryTable;
	$ += $ - (exportDirectoryTable.addressTableRVA - virtualDataDifference());
	ExportAddress exportAddressTable[exportDirectoryTable.addressesAmount];
	$ += $ - (exportDirectoryTable.namePointerTableRVA - virtualDataDifference());
	ExportNamePointer exportNamePointerTable[exportDirectoryTable.namePointersAmount];
	$ += $ - (exportDirectoryTable.ordinalTableRVA - virtualDataDifference());
	u16 exportOrdinalTable[exportDirectoryTable.namePointersAmount];
	$ += $ - (exportDirectoryTable.imageNameRVA - virtualDataDifference());
	char imageName[] [[format("formatNullTerminatedString")]];
};

// Imports Table
fn architecture() {
	return std::mem::read_unsigned(addressof(coffHeader.optionalHeader.magic), 2) / 0x41;
};

bitfield OrdinalFlagByte {
	padding : 7;
	flag : 1;
};

struct ImportsName {
	u16 hint;
	char name[] [[format("formatNullTerminatedString")]];
	if ($ % 2 == 1) { u8 pad; }
};

struct ImportsAddress {
	OrdinalFlagByte ordinalFlagByte @ $+(architecture()-1);
	if (ordinalFlagByte.flag) {
		u16 ordinalNumber;
		u8 nullPadding[architecture()-2];
	} else {
		u32 nameTableRVA;
		if (coffHeader.optionalHeader.magic == PEFormat::PE32Plus) {
			u8 nullPadding[4];
		}
	}
};

struct ImportsLookup : ImportsAddress {
	if (!ordinalFlagByte.flag && std::mem::read_unsigned($-architecture(), architecture()) > 0) {
   		ImportsName name @ nameTableRVA - virtualDataDifference();
	}
};

struct ImportsDirectory {
	u32 lookupTableRVA;
	u32 timeDateStamp;
	u32 forwarderChain;
	u32 dllNameRVA;
	u32 addressTableRVA;
} [[static]];

struct RedirectingImportsDirectory : ImportsDirectory {
	ImportsLookup lookupTable[while(std::mem::read_unsigned($, architecture()) != 0)] @ lookupTableRVA - virtualDataDifference();
	ImportsLookup nullLookup @ addressof(lookupTable) + sizeof(lookupTable);

	char dllName[] @ dllNameRVA - virtualDataDifference() [[format("formatNullTerminatedString")]];

	ImportsAddress addressTable[while(std::mem::read_unsigned($, architecture()) != 0)] @ addressTableRVA - virtualDataDifference();
	ImportsAddress nullAddress @ addressof(addressTable) + sizeof(addressTable);
};

struct ImportsTable {
	RedirectingImportsDirectory importsDirectoryTable[while(std::mem::read_unsigned($, 16) != 0x00)];
	ImportsDirectory nullImportsDirectory;
};

// Global Resource Table units
using ResourceDirectory;

struct ResourceString {
	u16 length;
	char16 string[length];
};

// * Bitmap Resource
struct BitmapHeader {
	u32 bitmapSize;
	u32 bitmapWidth;
	u32 bitmapHeight;
	u16 bitmapPlanes;
	u16 bitmapBitCount;
	u32 bitmapCompression;
	u32 bitmapImageSize;
	u32 bitmapXPelsPerMeter;
	u32 bitmapYPelsPerMeter;
	u32 bitmapClrUsed;
	u32 bitmapClrImportant;
};

struct Colors {
	u8 blue [[color("1F77B4")]];
	u8 green [[color("2CA02C")]];
	u8 red [[color("D62728")]];
	u8 reserved [[color("828282")]];
};

bitfield MonoPixel {
	pixelBits : parent.parent.bmh.bitmapBitCount*8;
};

bitfield LowerBitcountPixel {
	leftPixel : parent.parent.bmh.bitmapBitCount;
	rightPixel : parent.parent.bmh.bitmapBitCount;
};

bitfield HigherBitcountPixel {
	pixel : parent.parent.bmh.bitmapBitCount;
};

struct LineData {
	if (parent.bmh.bitmapBitCount == 8) {
		HigherBitcountPixel pixels[parent.bmh.bitmapWidth];
	}
	else if (parent.bmh.bitmapBitCount == 4) {
		LowerBitcountPixel pixels[parent.bmh.bitmapWidth/2];
	}
	else if (parent.bmh.bitmapBitCount == 1) {
		MonoPixel pixels[parent.bmh.bitmapWidth];
	}
};

u32 actualBitmapHeight;
u32 bitMaskSize;

struct Bitmap {
	BitmapHeader bmh;
	bitMaskSize = bitMaskSize - sizeof(bmh);

	if ((bmh.bitmapBitCount != 24) && (bmh.bitmapBitCount != 32)) {
		if (bmh.bitmapClrUsed > 0) {
			Colors rgbq[bmh.bitmapClrUsed];
		}
		else {
			Colors rgbq[1 << bmh.bitmapBitCount];
		}
		bitMaskSize = bitMaskSize - sizeof(rgbq);
	}

	if (bmh.bitmapImageSize > 0) {
		u8 lineData[bmh.bitmapImageSize];
	}
	else {
		actualBitmapHeight = bmh.bitmapHeight;
		if (bmh.bitmapBitCount == 4) {
			actualBitmapHeight = actualBitmapHeight / 2;
		}

		LineData lineData[actualBitmapHeight];
	}
	bitMaskSize = bitMaskSize - sizeof(lineData);

	u8 bitMask[bitMaskSize];
};

// * Cursor Resource
struct Cursor {
	u16 reserved;
	u16 type;
	if (type == 0) {
	   bitMaskSize = parent.size;
	   Bitmap bitmap [[inline]];
	}
};

// * Dialog Resource
struct NullTerminatedString16 {
	char16 string[while(std::mem::read_unsigned($, 2) != 0)];
	char16 terminatingNull;
} [[inline]];

enum AtomType : u16 {
	Button = 0x80,
	Edit,
	Static,
	ListBox,
	ScrollBar,
	ComboBox
};

struct VLSElement {
	if (std::mem::read_unsigned($, 2) == 0xFFFF) {
		u16 atomDefiner;
	}
	else {
		AtomType atom;
	}
};

struct VariableLengthStructure {
	if (std::mem::read_unsigned($, 2) == 0xFFFF) {
		VLSElement vlsElement[2];
	}
	else {
		NullTerminatedString16 string;
	}
};

struct DialogTemplate {
	if (parent.parent.parent.id == 0x409) {
		u16 version;
		u16 signature;
		u32 helpContextIdentifier;
		u32 extendedStyles;
		u32 style;
	}
	else {
		u32 style;
		u32 extendedStyles;
	}
	u16 numberOfItems;
	u16 x;
	u16 y;
	u16 width;
	u16 height;
	if (parent.parent.parent.id == 0x409) {
		VariableLengthStructure dialogMenu;
		VariableLengthStructure dialogClass;
		NullTerminatedString16 dialogTitle;
		u16 dialogFontSize;
		u16 weight;
	   	bool italic;
		u8 charset;
		char16 dialogFontTypeface[while(std::mem::read_unsigned($, 2) != 0)];
		u16 terminatingNull;
	}
};

struct DialogItemTitle {
	VariableLengthStructure vls;
	NullTerminatedString16 title;
};

struct DialogItemTemplate {
	if (parent.parent.parent.parent.id == 0x409) {
		u32 helpContextIdentifier;
		u32 extendedStyles;
		u32 style;
	}
	else {
		u32 style;
		u32 extendedStyles;
	}
	u16 x;
	u16 y;
	u16 width;
	u16 height;
	u16 controlID;
	if (parent.parent.parent.parent.id == 0x409) {
		VariableLengthStructure windowClass;
		DialogItemTitle dialogItemTitle;
		u16 extraCount;
		u8 itemCreationData[extraCount];
	}
};

struct DialogItem {
	DialogItemTemplate template [[inline]];
};

struct Dialog {
	DialogTemplate dialogTemplate;
	DialogItem items[dialogTemplate.numberOfItems];
};

// * String Resource
struct StringTableResource {
	ResourceString strings[while($ < (parent.dataRVA - virtualDataDifference()) + parent.size)];
};

// * GroupCursor Resource
struct GroupCursor {
	u16 assorteddata;
	u16 colors;
	u16 otherassorteddata;
	u16 pixels;
	u16 assorteddataarray[5];
	u16 ordinalName;
};

// * GroupIcon Resource
struct GroupIconHeader {
	u16 reserved;
	u16 type;
	u16 count;
};

struct GroupIconEntry {
	u8 width;
	u8 height;
	u8 colorCount;
	u8 reserved;
	u16 planes;
	u16 bitCount;
	u32 bytesInResource;
	u16 id;
};

struct GroupIcon {
	GroupIconHeader header;
	GroupIconEntry entries[header.count];
};

// * Version Resource
struct VersionEntryHeader {
	u16 length;
	u16 valueLength;
	u16 type;
	char16 key[while(std::mem::read_unsigned($, 2) != 0)];
	u16 terminatingNull;
	u8 nullPadding[while(std::mem::read_unsigned($, 1) == 0 && $ < addressof(terminatingNull)+5)];
};

struct StringInfo {
	VersionEntryHeader stringInfoHeader;
	if (stringInfoHeader.valueLength > 0) {
		NullTerminatedString16 string;
		u8 nullPadding[while(std::mem::read_unsigned($, 1) == 0)];
	}
};

struct VersionEntry {
	VersionEntryHeader header [[inline]];
	if (std::string::starts_with(std::string::to_string(header.key), "VS_VERSION_INFO")) {
		u32 signature;
		u16 structVersion[2];
		u16 fileVersion[4];
		u16 productVersion[4];
		u32 fileFlagsMask[2];
		u32 fileFlags;
		u32 fileOS;
		u32 fileType;
		u32 fileSubType;
		u32 fileTimestamp;
	}
	else if (std::string::starts_with(std::string::to_string(header.key), "StringFileInfo")) {
		VersionEntryHeader stringTable;
		StringInfo strings[while($ < addressof(stringTable) + stringTable.length)];
	}
	else if (std::string::starts_with(std::string::to_string(header.key), "VarFileInfo")) {
		VersionEntryHeader var;
		u16 translation[var.valueLength / 2];
	}
	else {
		u8 value[header.valueLength*2];
		u8 nullPadding[while(std::mem::read_unsigned($, 1) == 0)];
	}
};

// * Resources Using TrueChar
fn displayTrueChar(u8 value) {
	if (value < 0x10) {
		if (value == 0x00) {
			return "'␀' (" + std::format("0x0{:X}", value) + ")";
		}
		else {
			return "'" + char(value) + "' (" + std::format("0x0{:X}", value) + ")";
		}
	}
	else {
		return "'" + char(value) + "' (" + std::format("0x{:X}", value) + ")";
	}
};

using TrueChar = u8 [[format("displayTrueChar")]];

struct Manifest {
	u8 bom[while(std::mem::read_unsigned($, 1) != '<')];
	TrueChar xml[parent.size - sizeof(bom)] [[inline]];
};

// Resource Table
enum ResourceID : u32 {
	Cursor = 0x01,
	Bitmap,
	Icon,
	Menu,
	Dialog,
	String,
	Accelerator = 0x09,
	StringData,
	GroupCursor = 0x0C,
	GroupIcon = 0x0E,
	Version = 0x10,
	Manifest = 0x18
};

ResourceID resourceIDType;

struct DataEntry {
	u32 dataRVA;
	u32 size;
	u32 codepage;
	u32 reserved;

	if (resourceIDType == ResourceID::Cursor) {
		Cursor cursor @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::Bitmap || (resourceIDType == ResourceID::Icon && std::mem::read_string((dataRVA - virtualDataDifference())+1, 3) != "PNG")) {
		bitMaskSize = size;
		Bitmap bitmap @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::Dialog) {
		Dialog dialog @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::String) {
		StringTableResource stringTableResource @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::StringData) {
		TrueChar stringData[size] @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::GroupCursor) {
		GroupCursor groupCursor @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::GroupIcon) {
		GroupIcon groupIcon @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::Version) {
		VersionEntry version[while($ < (dataRVA - virtualDataDifference()) + size)] @ dataRVA - virtualDataDifference();
	}
	else if (resourceIDType == ResourceID::Manifest) {
		Manifest manifest @ dataRVA - virtualDataDifference();
	}
	else {
		u8 resource[size] @ dataRVA - virtualDataDifference();
	}
};

struct IdDirectoryEntry {
	if ($ > (coffHeader.optionalHeader.directories[2].rva - virtualDataDifference()) + 0x10 + 8*(std::mem::read_unsigned(coffHeader.optionalHeader.directories[2].rva - virtualDataDifference() + 12, 2) + std::mem::read_unsigned(coffHeader.optionalHeader.directories[2].rva - virtualDataDifference() + 14, 2))) {
		u32 id;
	}
	else {
		ResourceID id;
		resourceIDType = std::mem::read_unsigned(addressof(id), 4);
	}
	u32 offsetToData;

	if (offsetToData >= 0x80000000) {
		ResourceDirectory directory @ (coffHeader.optionalHeader.directories[2].rva - virtualDataDifference()) + (offsetToData - 0x80000000);
	}
	else {
		DataEntry dataEntry @ (coffHeader.optionalHeader.directories[2].rva - virtualDataDifference()) + offsetToData;
	}
};

struct NameDirectoryEntry {
	if (std::mem::read_unsigned($+3, 1) == 0x80) {
		u32 relativeOffsetToName;
		ResourceString name @ sectionsTable[currentSectionIndex].ptrRawData + (relativeOffsetToName - 0x80000000);
	}
	else {
		char name[4];
	}
	u32 relativeOffsetToData;
	ResourceDirectory directory @ sectionsTable[currentSectionIndex].ptrRawData + (relativeOffsetToData - 0x80000000);
};

struct ResourceDirectoryTable {
	u32 characteristics;
	u32 timeDateStamp;
	u16 majorVersion;
	u16 minorVersion;
	u16 nameEntriesAmount;
	u16 idEntriesAmount;
};

struct ResourceDirectory {
	ResourceDirectoryTable resourceDirectoryTable;
	NameDirectoryEntry nameEntries[resourceDirectoryTable.nameEntriesAmount];
	IdDirectoryEntry idEntries[resourceDirectoryTable.idEntriesAmount];
};

struct ResourceTable {
	ResourceDirectory rootDirectory;
};

// Base Relocations Table
enum BaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	Reserved = 6,
	DIR64 = 10
};

enum MIPSBaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	MIPSJMPAddress,
	Reserved,
	MIPSJMPAddress16 = 9,
	DIR64
};

enum ARMBaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	ARMMOV32,
	Reserved,
	DIR64 = 10
};

enum RISCVBaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	RISCVHigh20,
	Reserved,
	RISCVLow12I,
	RISCVLow12S,
	DIR64 = 10
};

enum THUMBBaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	ARMMOV32,
	Reserved,
	ThumbMOV32,
	DIR64 = 10
};

enum LoongarchBaseRelocationType : u8 {
	Absolute,
	High,
	Low,
	HighLow,
	HighAdjacent,
	Reserved = 6,
	MarkLA = 8,
	DIR64 = 10
};

fn formatBaseRelocationType(u8 value) {
	if (coffHeader.machine == MachineType::MIPS16 || coffHeader.machine == MachineType::MIPSFPU || coffHeader.machine == MachineType::MIPSFPU16 || coffHeader.machine == MachineType::R3000 || coffHeader.machine == MachineType::R4000 || coffHeader.machine == MachineType::R10000) {
		MIPSBaseRelocationType mipsTypeBits = value;
		return mipsTypeBits;
	}
	else if (coffHeader.machine == MachineType::ARM || coffHeader.machine == MachineType::ARM64 || coffHeader.machine == MachineType::ARMNT) {
		ARMBaseRelocationType armTypeBits = value;
		return armTypeBits;
	}
	else if (coffHeader.machine == MachineType::RISCV32 || coffHeader.machine == MachineType::RISCV64 || coffHeader.machine == MachineType::RISCV128) {
		RISCVBaseRelocationType riscvTypeBits = value;
		return riscvTypeBits;
	}
	else if (coffHeader.machine == MachineType::THUMB) {
		THUMBBaseRelocationType thumbTypeBits = value;
		return thumbTypeBits;
	}
	else if (coffHeader.machine == MachineType::LOONGARCH32 || coffHeader.machine == MachineType::LOONGARCH64) {
		LoongarchBaseRelocationType loongarchTypeBits = value;
		return loongarchTypeBits;
	}
	else {
		BaseRelocationType genericTypeBits = value;
		return genericTypeBits;
	}
};

bitfield BaseRelocationWord {
	offset : 12;
	type : 4 [[format("formatBaseRelocationType")]];
};

struct BaseRelocationBlock {
	u32 pageRVA;
	u32 blockSize;
	BaseRelocationWord word;
};

struct BaseRelocationTable {
	BaseRelocationBlock baseRelocationBlocks[while($ < addressof(this) + coffHeader.optionalHeader.directories[5].size)];
};

// Debug Table
enum DebugType : u32 {
	Unknown,
	COFF,
	Codeview,
	FPO,
	Misc,
	Exception,
	Fixup,
	OmapToSRC,
	OmapFromSRC,
	Borland,
	Reserved10,
	CLSID,
	REPRO = 16,
	ExtendedDLLCharacteristics = 20
};

struct DebugDirectory {
	u32 characteristics;
	u32 timeDateStamp;
	u16 majorVersion;
	u16 minorVersion;
	DebugType type;
	u32 sizeOfData;
	u32 virtualAddressOfRawData;
	u32 pointerOfRawData;
};

struct DebugData {
	DebugDirectory directory;
};

// TLS Table
struct TLSTable {
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

// CRT Section
struct CRTSection {
	u64 virtualAddresses[while($ < sectionsTable[currentSectionIndex].ptrRawData + sectionsTable[currentSectionIndex].sizeOfRawData)];
};

// General Section things
struct LineNumber {
	u32 lineNumber @ $ + 4;
	if (lineNumber > 0x00) {
		u32 virtualAddress;
	} else {
		u32 symbolTableIndex;
	}
	$ += 4;
};

bool doesDataDirectoryExist[coffHeader.optionalHeader.numberOfRVAsAndSizes];

fn checkForDataDirectory() {
	for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i = i + 1) {
		if (coffHeader.optionalHeader.directories[i].rva - virtualDataDifference() < sectionsTable[currentSectionIndex].ptrRawData+sectionsTable[currentSectionIndex].sizeOfRawData && coffHeader.optionalHeader.directories[i].rva - virtualDataDifference() >= $) {
			doesDataDirectoryExist[i] = true;
		}
	}
};

fn checkForZeroDataDirectories() {
	for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i = i + 1) {
		if (doesDataDirectoryExist[i]) {
			return false;
		}
	}
	return true;
};

fn zerooutBoolArray() {
	for (u32 i = 0, i < coffHeader.optionalHeader.numberOfRVAsAndSizes, i = i + 1) {
		doesDataDirectoryExist[i] = false;
	}
};

fn updateSectionIndex() {
	currentSectionIndex = currentSectionIndex + 1;
};

struct Section {
	checkForDataDirectory();
	if (checkForZeroDataDirectories()) {
		if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".CRT")) {	// CRT section
			CRTSection crtSection;
		}
		else {
			u8 freeformSection[sectionsTable[currentSectionIndex].sizeOfRawData];				// Freeform data section
		}
	}
	else {
		if (doesDataDirectoryExist[0]) {
			ExportsTable exportTable @ coffHeader.optionalHeader.directories[0].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[1]) {
			ImportsTable importTable @ coffHeader.optionalHeader.directories[1].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[2]) {
			ResourceTable resourceTable @ coffHeader.optionalHeader.directories[2].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[3]) {
			ExceptionTable exceptionTable @ coffHeader.optionalHeader.directories[3].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[5]) {
			BaseRelocationTable baseRelocationTable @ coffHeader.optionalHeader.directories[5].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[6]) {
			DebugData debugTable @ coffHeader.optionalHeader.directories[6].rva - virtualDataDifference();
		}
		if (doesDataDirectoryExist[9]) {
			TLSTable tlsTable @ coffHeader.optionalHeader.directories[9].rva - virtualDataDifference();
		}
	}
	zerooutBoolArray();

	// Other things
	LineNumber lineNumbers[sectionsTable[currentSectionIndex].numberOfLineNumbers] @ sectionsTable[currentSectionIndex].ptrLineNumbers;

	// Next section
	if (currentSectionIndex < coffHeader.numberOfSections-1) {			// If it's not the last section (to avoid problems this code would have with it)
		updateSectionIndex();											// Make the current section index the next section's index
		if (sectionsTable[currentSectionIndex].sizeOfRawData > 0) {		// If the next section isn't empty
			$ = sectionsTable[currentSectionIndex].ptrRawData;			// Put the current offset at the start of it to account for any bytes left
		}
	}
};

Section sections[coffHeader.numberOfSections] @ coffHeader.optionalHeader.sizeOfHeaders;

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

struct SymbolType {
	SymbolTypeMSB msb;
	SymbolTypeLSB lsb;
};

struct Symbol {
	if (std::mem::read_unsigned($, 4) == 0) {
		SymbolNameAddress nameAddress;
	}
	else {
		char shortName[8];
	}
	u32 value;
	SectionNumberType sectionNumber;
	SymbolType type;
	StorageClassType storageClass;
	u8 numberOfAuxSymbols;
};

bool checkForSymbols in;

fn btoi(bool value) {
	if (value) {
		return 1;
	}
	else {
		return 0;
	}
};

Symbol symbolTable[btoi(checkForSymbols) * coffHeader.numberOfSymbols] @ coffHeader.pointerToSymbolTable;

struct SymbolString {
	char string[] [[format("formatNullTerminatedString")]];
} [[inline]];

struct StringTable {
	u32 size;
	SymbolString strings[while($ < addressof(this) + size)];
} [[inline]];

StringTable stringTable[checkForSymbols] @ addressof(symbolTable) + sizeof(symbolTable);
