#pragma MIME application/x-dosexec
#pragma MIME application/x-msdownload
#pragma bitfield_order right_to_left
#pragma pattern_limit 0x400000

#include <std/string.pat>
#include <std/mem.pat>

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
	u16 reservedWords[4];
	u16 oemIdentifier;
	u16 oemInformation;
	u16 otherReservedWords[10];
	u32 coffHeaderPointer;
};

u16 dosMessageOffset;
fn isntdosmessage(char c) {
	return c == 0x0D || c == '$';
};

fn finddosmessage() {
	for (u8 i = 0, $+i < std::mem::read_unsigned(0x3C, 4), i = i + 1) {
		if (std::mem::read_unsigned($+i, 1) == 0xBA) {
			dosMessageOffset = std::mem::read_unsigned($+i+1, 2);
			break;
		}
	}
};

struct DOSStub {
	finddosmessage();
	if (dosMessageOffset > 0) {
		u8 code[while($ != addressof(this) + dosMessageOffset)];
		char message[while(!isntdosmessage(std::mem::read_unsigned($, 1)))];
		char data[while(std::mem::read_string($-1, 1) != "$")];
	} else {
		u8 code[while(std::mem::read_unsigned($, 6) != 0x00)] @ dosHeader.headerSizeInParagraphs * 16;
	}
};

struct PEHeader {
	DOSHeader dosHeader;
	DOSStub dosStub @ dosHeader.headerSizeInParagraphs * 16;
};

PEHeader peHeader @ 0x00;

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
	localSymbolsStripped : 1;
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
	padding : 5;
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
};

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
	containsComments : 1;
	padding : 1;
	remove : 1;
	containsCOMDATData : 1;
	padding : 2;
	globalPointerRelocation : 1;
	purgeable : 1;
	is16Bit : 1;
	locked : 1;
	preloaded : 1;
	dataAlignment : 4 [[format("formatAlignmentBits")]];
	extendedRelocations : 1;
	discardable : 1;
	notCacheable : 1;
	notPageable : 1;
	shared : 1;
	executed : 1;
	read : 1;
	writtenTo : 1;
};

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

SectionHeader sectionsTable[coffHeader.numberOfSections] @ addressof(coffHeader.characteristics)+2 + coffHeader.sizeOfOptionalHeader;

// Declarations of sections and units used by them
u16 currentSectionIndex;
fn updateSectionIndex() {
	currentSectionIndex = currentSectionIndex + 1;
};

fn virtualDataDifference() {
	return sectionsTable[currentSectionIndex].virtualAddress - sectionsTable[currentSectionIndex].ptrRawData;
};

fn formatNullTerminatedString(str string) {
	return "\"" + std::string::substr(string, 0, std::string::length(string)-4) + "\"";
};

// Exception Section
bitfield ExceptionSectionBits {
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
		u8 prologLength;
		ExceptionSectionBits miscellaneousBits;
	} else if (coffHeader.machine == MachineType::AMD64 || coffHeader.machine == MachineType::IA64) {
		u32 beginRVA;
		u32 endRVA;
		u32	unwindInformationRVA;
	}
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

struct ExportName {
	char name[] [[format("formatNullTerminatedString")]];
};

struct ExportAddress {
	if (std::mem::read_unsigned($, 4) > sectionsTable[currentSectionIndex].sizeOfRawData && std::mem::read_unsigned($, 4) < sectionsTable[currentSectionIndex].ptrRawData) {
		u32 exportRVA;
	}
	else {
		u32 forwarderRVA;
	}
};

struct ExportNamePointer {
	u32 exportNameRVA;
	ExportName exportName @ exportNameRVA - virtualDataDifference();
};

struct ExportsSection {
	ExportDirectoryTable exportDirectoryTable;
	ExportAddress exportAddressTable[exportDirectoryTable.addressTableEntries] @ exportDirectoryTable.exportAddressTableRVA - virtualDataDifference();
	ExportNamePointer exportNamePointerTable[exportDirectoryTable.numberOfNamePointers] @ exportDirectoryTable.namePointerRVA - virtualDataDifference();
	u16 exportOrdinalTable[exportDirectoryTable.numberOfNamePointers] @ exportDirectoryTable.ordinalTableRVA - virtualDataDifference();
	char dllName[] @ exportDirectoryTable.nameRVA - virtualDataDifference() [[format("formatNullTerminatedString")]];
};

// Imports + Readonly Data Section
fn architecture() {
	return std::mem::read_unsigned(addressof(coffHeader.optionalHeader.magic), 2) / 0x41;
};

bitfield OrdinalFlagByte {
	flag : 1;
	padding : 7;
} [[left_to_right]];

struct NameTableEntry {
	u16 hint;
	char name[] [[format("formatNullTerminatedString")]];
	if ($ % 2 == 1) { u8 pad; }
};

struct AddressTableEntry {
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

struct LookupTableEntry : AddressTableEntry {
	if (!ordinalFlagByte.flag && std::mem::read_unsigned($, architecture()) > 0) {
   		NameTableEntry name @ nameTableRVA - virtualDataDifference();
	}
};

struct DirectoryTable {
	u32 lookupTableRVA;
	u32 timeDateStamp;
	u32 forwarderChain;
	u32 dllNameRVA;
	u32 addressTableRVA;
} [[static]];

u16 importsIndex;

struct ImportsStructure {
	LookupTableEntry lookupTable[while(std::mem::read_unsigned($, architecture()) != 0)] @ parent.directoryTables[importsIndex].lookupTableRVA - virtualDataDifference();
	AddressTableEntry addressTable[while(std::mem::read_unsigned($, architecture()) != 0)] @ parent.directoryTables[importsIndex].addressTableRVA - virtualDataDifference();	
	char dllName[] @ parent.directoryTables[importsIndex].dllNameRVA - virtualDataDifference() [[format("formatNullTerminatedString")]];
	importsIndex = importsIndex + 1;
} [[inline]];

struct ImportsSection {
	DirectoryTable directoryTables[while(std::mem::read_unsigned($, 16) != 0x00)];
	DirectoryTable nullDirectoryTable;
	ImportsStructure importsStructures[sizeof(directoryTables) / sizeof(directoryTables[0])];
};

struct ReadonlyDataSection {
	if (coffHeader.optionalHeader.numberOfRVAsAndSizes >= 0xC) {
		$ += coffHeader.optionalHeader.directories[0xC].size;
	}
	u8 readonlyDataStart[while($ < coffHeader.optionalHeader.directories[1].virtualAddress - virtualDataDifference())];
	ImportsSection importsSection;
};

// Resource Section
using ResourceDirectory;

struct ResourceString {
	u16 length;
	char16 string[length];
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

struct Bitmap {
	BitmapHeader bmh;

	if ((bmh.bitmapBitCount != 24) && (bmh.bitmapBitCount != 32)) {
		if (bmh.bitmapClrUsed > 0) {
			Colors rgbq[bmh.bitmapClrUsed];
		}
		else {
			Colors rgbq[1 << bmh.bitmapBitCount];
		}
	}
};

// * Dialog Resource
struct DialogTemplate {
	u32 style;
	u32 extendedStyles;
	u16 numberOfItems;
	u16 x;
	u16 y;
	u16 width;
	u16 height;
};

struct DialogItemTemplate {
	u32 style;
	u32 extendedStyles;
	u16 x;
	u16 y;
	u16 width;
	u16 height;
	u16 id;
};

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

struct DialogItem {
	u16 alignment;
	DialogItemTemplate template;
	VariableLengthStructure itemClass;
	VariableLengthStructure itemTitle;
	u16 itemCreationData;
	if (itemCreationData > 0) {
		u8 itemData[itemCreationData];
	}
};

struct Dialog {
	DialogTemplate dialogTemplate;
	u16 dialogMenu;
	VariableLengthStructure dialogClass;
	VariableLengthStructure dialogTitle;
	u16 dialogFontSize;
	char16 dialogFontTypeface[while(std::mem::read_unsigned($, 2) != 0)];
	u16 terminatingNull;
	DialogItem items[while($ < (parent.dataRVA - virtualDataDifference()) + parent.size)];
};

// * String Resource
struct StringTableResource {
	ResourceString strings[while(std::mem::read_unsigned($, 2) != 0x00)];
	u16 nullPadding[while($ < (parent.dataRVA - virtualDataDifference()) + parent.size)];
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
} [[inline]];

struct StringInfo {
	VersionEntryHeader stringInfoHeader;
	if (stringInfoHeader.valueLength > 0) {
		NullTerminatedString16 string;
		u8 nullPadding[while(std::mem::read_unsigned($, 1) == 0)];
	}
};

struct VersionEntry {
	VersionEntryHeader header;
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

struct XML {
	u8 bom[while(std::mem::read_unsigned($, 1) != '<')];
	TrueChar contents[parent.size - sizeof(bom)] [[inline]];
};

// * The rest of the section
enum ResourceID : u32 {
	Cursor = 0x01,
	Bitmap,
	Icon,
	Menu,
	Dialog,
	String,
	StringData = 0x0A,
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

	if (resourceIDType == ResourceID::Bitmap || (resourceIDType == ResourceID::Icon && std::mem::read_string((dataRVA-virtualDataDifference())+1, 3) != "PNG")) {
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
		XML manifest @ dataRVA - virtualDataDifference();
	}
	else {
		u8 resource[size] @ dataRVA - virtualDataDifference();
	}
};

struct IdDirectoryEntry {
	if ($ > (coffHeader.optionalHeader.directories[2].virtualAddress - virtualDataDifference()) + 0x10 + 8*(std::mem::read_unsigned(coffHeader.optionalHeader.directories[2].virtualAddress - virtualDataDifference() + 12, 2) + std::mem::read_unsigned(coffHeader.optionalHeader.directories[2].virtualAddress - virtualDataDifference() + 14, 2))) {
		u32 id;
	}
	else {
		ResourceID id;
		resourceIDType = id;
	}
	u32 offsetToData;

	if (offsetToData >= 0x80000000) {
		ResourceDirectory directory @ (coffHeader.optionalHeader.directories[2].virtualAddress - virtualDataDifference()) + (offsetToData - 0x80000000);
	}
	else {
		DataEntry dataEntry @ (coffHeader.optionalHeader.directories[2].virtualAddress - virtualDataDifference()) + offsetToData;
	}
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

struct ResourceSection {
	ResourceDirectory rootDirectory;
};

// Relocations Section
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

fn formatMIPSType(u8 value) {
	MIPSBaseRelocationType mipsTypeBits = value;
	return mipsTypeBits;
};

fn formatARMType(u8 value) {
	ARMBaseRelocationType armTypeBits = value;
	return armTypeBits;
};

fn formatRISCVType(u8 value) {
	RISCVBaseRelocationType riscvTypeBits = value;
	return riscvTypeBits;
};

fn formatTHUMBType(u8 value) {
	THUMBBaseRelocationType thumbTypeBits = value;
	return thumbTypeBits;
};

fn formatLoongarchType(u8 value) {
	LoongarchBaseRelocationType loongarchTypeBits = value;
	return loongarchTypeBits;
};

fn formatGenericType(u8 value) {
	BaseRelocationType genericTypeBits = value;
	return genericTypeBits;
};

bitfield MIPSBaseRelocationWord {
	type : 4 [[format("formatMIPSType")]];
	offset : 12;
};

bitfield ARMBaseRelocationWord {
	type : 4 [[format("formatARMType")]];
	offset : 12;
};

bitfield RISCVBaseRelocationWord {
	type : 4 [[format("formatRISCVType")]];
	offset : 12;
};

bitfield THUMBBaseRelocationWord {
	type : 4 [[format("formatTHUMBType")]];
	offset : 12;
};

bitfield LoongarchBaseRelocationWord {
	type : 4 [[format("formatLoongarchType")]];
	offset : 12;
};

bitfield GenericBaseRelocationWord {
	type : 4 [[format("formatGenericType")]];
	offset : 12;
};

struct BaseRelocationBlock {
	u32 pageRVA;
	u32 blockSize;
	if (coffHeader.machine == MachineType::MIPS16 || coffHeader.machine == MachineType::MIPSFPU || coffHeader.machine == MachineType::MIPSFPU16) {
		MIPSBaseRelocationWord word;
	}
	else if (coffHeader.machine == MachineType::ARM || coffHeader.machine == MachineType::ARM64 || coffHeader.machine == MachineType::ARMNT) {
		ARMBaseRelocationWord word;
	}
	else if (coffHeader.machine == MachineType::RISCV32 || coffHeader.machine == MachineType::RISCV64 || coffHeader.machine == MachineType::RISCV128) {
		RISCVBaseRelocationWord word;
	}
	else if (coffHeader.machine == MachineType::THUMB) {
		THUMBBaseRelocationWord word;
	}
	else if (coffHeader.machine == MachineType::LOONGARCH32 || coffHeader.machine == MachineType::LOONGARCH64) {
		LoongarchBaseRelocationWord word;
	}
	else {
		GenericBaseRelocationWord word;
	}
};

struct BaseRelocationTable {
	BaseRelocationBlock baseRelocationBlocks[while($ < (coffHeader.optionalHeader.directories[5].virtualAddress - virtualDataDifference()) + coffHeader.optionalHeader.directories[5].size)];
};

// Debug Section
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
	u32 majorVersion;
	u32 minorVersion;
	DebugType type;
	u32 sizeOfData;
	u32 virtualAddressOfRawData;
	u32 pointerOfRawData;
};

struct DebugSection {
	DebugDirectory directory;
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

// CRT Section
struct CRTSection {
	u64 addresses[while($ < sectionsTable[currentSectionIndex].ptrRawData + sectionsTable[currentSectionIndex].sizeOfRawData)];
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

fn importsPrint(str value) {
	std::print("Check for .idata section " + value);
};

fn separateImportsSection() { 
	bool returnedValue;
	if (coffHeader.optionalHeader.directories[1].size > 0) {
		for (u16 i = 0, i < coffHeader.numberOfSections, i = i + 1) {
			if (std::string::starts_with(sectionsTable[i].name, ".idata")) {
				importsPrint("successful. It is section " + std::string::to_string(i) + ", so the read-only data section won't have an imports section in it");
				returnedValue = true;
				break;
			}
		}
	}
	if (!returnedValue) {
		importsPrint("failed! This means there is no separate imports section");
	}
	return returnedValue;
};

struct Section {
	if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".pdata")) {		// Exception section
		FunctionTableEntry functionTableEntries[while($ < (coffHeader.optionalHeader.directories[3].virtualAddress - virtualDataDifference()) + coffHeader.optionalHeader.directories[3].size)] [[name("exceptionSection")]];
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".edata")) {	// Exports section
		ExportsSection exportsSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".idata")) {	// Imports section
		ImportsSection importsSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".rdata")) {	// Read-only data section
		if (separateImportsSection()) {
			u8 readonlyDataSection[sectionsTable[currentSectionIndex].sizeOfRawData]; 
		}
		else {
			ReadonlyDataSection readOnlyDataSection;	
		}
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".rsrc")) {	// Resource section
		ResourceSection resourceSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".reloc")) {	// Base relocations section
		BaseRelocationTable relocationsSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".debug") ||
			 std::string::starts_with(sectionsTable[currentSectionIndex].name, ".build")) {	// Debug section
		DebugSection debugSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".tls")) {	// Thread-local storage section
		TLSSection tlsSection;
	}
	else if (std::string::starts_with(sectionsTable[currentSectionIndex].name, ".CRT")) {	// CRT section
		CRTSection crtSection;
	}
	else {
		u8 freeformSection[sectionsTable[currentSectionIndex].sizeOfRawData];				// Freeform data section
	}

	// Other things
	LineNumber lineNumbers[sectionsTable[currentSectionIndex].numberOfLineNumbers] @ sectionsTable[currentSectionIndex].ptrLineNumbers;

	// Next section
	if (currentSectionIndex < coffHeader.numberOfSections-1) {			// If it's not the last section (to avoid problems this code would have with it)
		updateSectionIndex();											// Make the current section index the next section's index
		if (sectionsTable[currentSectionIndex].sizeOfRawData > 0) {		// If the next section isn't empty
			$ = sectionsTable[currentSectionIndex].ptrRawData;			// Put the current offset at the start of it to account for any bytes left
		}
	}
} [[inline]];

fn btoi(bool value) {
	if (value) {
		return 1;
	}
	else {
		return 0;
	}
};

bool nonemptySections;
u16 firstNonemptySection;
fn findFirstNonemptySection() {
	for (u16 i = 0, i < coffHeader.numberOfSections, i = i + 1) {
		if (sectionsTable[i].sizeOfRawData > 0) {
			nonemptySections = true;
			firstNonemptySection = i;
			break;
		}
	}
};
findFirstNonemptySection();
Section sections[btoi(nonemptySections) * coffHeader.numberOfSections] @ sectionsTable[firstNonemptySection].ptrRawData;

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
	VC6SP5 = 0x16 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002Linker = 0x19 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002CCompiler = 0x1C ^ richHeaderEnd[0].mask.maskArray[1],
	VC2002CPPCompiler = 0x1D ^ richHeaderEnd[0].mask.maskArray[1],
	VC2003SDKIMP = 0x5D ^ richHeaderEnd[0].mask.maskArray[1],
	VC2003CPPCompiler = 0x60 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2008SDKIMP = 0x93 ^ richHeaderEnd[0].mask.maskArray[1],
	Linker12 = 0x9D ^ richHeaderEnd[0].mask.maskArray[1],
	MASM10 = 0x9E ^ richHeaderEnd[0].mask.maskArray[1],
	VC2010CCompiler = 0xAA ^ richHeaderEnd[0].mask.maskArray[1],
	VC2010CPPCompiler = 0xAB ^ richHeaderEnd[0].mask.maskArray[1],
	VC2015CVTRES = 0xFF ^ richHeaderEnd[0].mask.maskArray[1],
	VC2015Linker = 0x101 ... 0x102 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2015Assembler = 0x103 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2015CCompiler = 0x104 ^ richHeaderEnd[0].mask.maskArray[1],
	VC2015CPPCompiler = 0x105 ^ richHeaderEnd[0].mask.maskArray[1]
};

union RichHeaderMask {
	u32 maskVariable;
	u16 maskArray[2];
};

struct RichHeaderEnd {
	char signature[4];
	RichHeaderMask mask;
} [[inline]];

bool checkForRichHeader in;
u16 richHeaderEndPosition;
fn initializeRichHeader() {
	if (checkForRichHeader) {
		for	(u16 richEndCursor = sizeof(peHeader), richEndCursor < addressof(coffHeader), richEndCursor = richEndCursor + 1) {
			if (std::mem::read_string(richEndCursor, 4) == "Rich") {
				richHeaderEndPosition = richEndCursor;
				break;
			}
		}
	}
};
initializeRichHeader();

RichHeaderEnd richHeaderEnd[checkForRichHeader] @ richHeaderEndPosition;

fn formatSignature(auto value) {
	return "\"DanS\" ";
};
fn formatHexadecimally(auto value) {
	return std::string::to_string(value) + " (" + std::format("0x{:X}", value) + ")";
};
fn unmaskBuild(u16 value) {
	return formatHexadecimally(value ^ richHeaderEnd[0].mask.maskArray[0]);
};
fn unmask(u32 value) {
	return formatHexadecimally(value ^ richHeaderEnd[0].mask.maskVariable);
};

using NullPadding = u32 [[format("unmask")]];

struct Product {
	u16 buildNumber [[format("unmaskBuild")]];
	ProductType productID;
	u32 objectCount [[format("unmask")]];
};

struct RichHeaderCorpus {
	char maskedSignature[4] [[format("formatSignature")]];
	NullPadding nullPadding[3];
	Product products[while($ != richHeaderEndPosition)];
} [[inline]];

u8 richHeaderCorpusPosition;
fn setupRichHeader() {
	if (checkForRichHeader) {
		//0x20 is the size of a Rich Header with one product
		for (u16 richCorpusCursor = richHeaderEndPosition - 0x20, richCorpusCursor > sizeof(peHeader), richCorpusCursor = richCorpusCursor - 0x01) {
			if (str(std::mem::read_unsigned(richCorpusCursor, 4) ^ richHeaderEnd[0].mask.maskVariable) == "DanS") {
				richHeaderCorpusPosition = richCorpusCursor;		
				break;
			}
		}
	}
};
setupRichHeader();

RichHeaderCorpus richHeaderCorpus[checkForRichHeader] @ richHeaderCorpusPosition;

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

bool checkForDebugInformation in;

Symbol symbolTable[btoi(checkForDebugInformation) * coffHeader.numberOfSymbols] @ coffHeader.pointerToSymbolTable;

struct StringTableString {
	char string[] [[format("formatNullTerminatedString")]];
} [[inline]];

struct StringTable {
	u32 size;
	StringTableString strings[while($ < addressof(this) + size)];
} [[inline]];

StringTable stringTable[checkForDebugInformation] @ addressof(symbolTable) + sizeof(symbolTable);
