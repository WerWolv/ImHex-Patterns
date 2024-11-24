#pragma description Microsoft DOS NE executable

import std.mem;

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
    u8 overlayInformation[0x20];
    u32 neHeaderPointer;
};

u16 dosMessageOffset;
u16 pointedCodeOffset;

fn finddosmessage() {
	for (u8 i = 0, $+i < std::mem::read_unsigned(0x3C, 4), i = i + 1) {
		if (std::mem::read_unsigned($+i, 1) == 0xBA) { // MOV instruction
			dosMessageOffset = std::mem::read_unsigned($+i+1, 2);
			break;
		}
	}
};

fn findpointingcode() {
	for (u8 i = 0, $+i < std::mem::read_unsigned(0x3C, 4), i = i + 1) {
		if (std::mem::read_unsigned($+i, 1) == 0xE8) { // CALL instruction
			pointedCodeOffset = std::mem::read_unsigned($+i+1, 2);
			return true;
		}
	}
	return false;
};

fn isdosdata(char c) {
	return c == 0x0D || c == '$';
};

struct DOSStub {
	if (findpointingcode()) {
    	u8 pointingCode[3];
    	u8 code[while(std::mem::read_unsigned($, 1) != 0x00)] @ addressof(this) + pointedCodeOffset + 3;
		char message[while(!isdosdata(std::mem::read_unsigned($, 1)))];
		char data[while(std::mem::read_string($-1, 1) != "$")];
    }
    else {
		finddosmessage();
		if (dosMessageOffset > 0) {
			u8 code[while($ != addressof(this) + dosMessageOffset)];
			char message[while(!isdosdata(std::mem::read_unsigned($, 1)))];
    		char data[while(std::mem::read_string($-1, 1) != "$")];
    	}
    	else {
    		char code[while(std::mem::read_unsigned($, 1) != 0x00)];
    	}
    }
};

struct FileHeader {
	DOSHeader dosHeader;
	DOSStub dosStub @ dosHeader.headerSizeInParagraphs * 16;
};

FileHeader fileHeader @ 0x00;

enum DGroupType : u8 {
	NoAutoData,
	SingleData,
	MultipleData,
	Null
};

fn formatDGroupType(u8 value) {
	DGroupType dgroup = value;

	return dgroup;
};

enum AppType : u8 {
	None,
	Fullscreen,
	WinPMCompatible,
	UsesWinPM
};

fn formatAppType(u8 value) {
	AppType app = value;

	return app;
};

bitfield ProgramFlags {
	dGroupType : 2 [[format("formatDGroupType")]];
	globalInitialization : 1;
	protectedModeOnly : 1;
	instructions86 : 1;
	instructions286 : 1;
	instructions386 : 1;
	instructionsX87 : 1;
};

bitfield ApplicationFlags {
	applicationType : 2 [[format("formatAppType")]];
	padding : 1;
	os2Application : 1;
	reserved : 1;
	imageError : 1;
	nonConforming : 1;
	dll : 1;
};

enum OSType : u8 {
	Unknown = 0x00,
	OS2 = 0x01,
	Win16 = 0x02,
	DOS4 = 0x03,
	Win32 = 0x04,
	BorlandOSServices = 0x05,
	PharlapDOSExtenderOS2 = 0x81,
	PharlapDOSExtenderWindows = 0x82
};

bitfield OS2EXEFlags {
	longFilename : 1;
	protectedMode : 1;
	proportionalFonts : 1;
	gangloadArea : 1;
};

struct NEHeader {
    char signature[2];
    u8 majorLinkerVersion;
    u8 minorLinkerVersion;
    u16 entryTableOffset;
    u16 entryTableLength;
    u32 fileCRC;
    ProgramFlags programFlags;
    ApplicationFlags appFlags;
    u16 autoDataSegmentIndex;
    u16 initHeapSize;
    u16 initStackSize;
    u32 entryPoint;
    u32 initialStackPointer;
    u16 segmentCount;
    u16 moduleReferenceCount;
    u16 nonResidentNamesTableSize;
    u16 segmentTableOffset;
    u16 resourceTableOffset;
    u16 residentNamesTableOffset;
    u16 moduleReferenceTableOffset;
    u16 importedNamesTableOffset;
    u8 *nonResidentNamesTablePointer[nonResidentNamesTableSize] : u32;
    u16 moveableEntryCount;
    u16 fileAlignmentSizeShiftCount;
    u16 resourceCount;
    OSType targetOS;
    OS2EXEFlags os2ExeFlags;
    u16 thunksReturnOffset;
    u16 segmentReferenceThunksOffset;
    u16 minimumCodeSwapAreaSize;
    u8 expectedMinorWindowsVersion;
    u8 expectedMajorWindowsVersion;
};

NEHeader neHeader @ fileHeader.dosHeader.neHeaderPointer;

bitfield SegmentTableFlags {
	dataSegment : 1;
	typeMask : 2;
	padding : 1;
	moveable : 1;
	padding : 1;
	preloaded : 1;
	padding : 1;
	containsRelocationInfo : 1;
	padding : 1;
	discardPriority : 4;
};

struct SegmentTable {
	u16 segmentDataPointer;
	u16 segmentLength;
	SegmentTableFlags segmentTableFlags;
	u16 minimumAllocationSize;
};

SegmentTable segmentTable[neHeader.segmentCount] @ addressof(neHeader) + neHeader.segmentTableOffset;

bitfield BlockFlags {
	padding : 4;
	moveable : 1;
	shared : 1;
	preload : 1;
	padding : 9;
};

struct ResourceTypeInformationBlock {
	u8 *resourcePointer : u16;
	u16 resourceLength;
	BlockFlags flags;
	u16 resourceID;
	u32 reserved;
};

struct ResourceRecord {
	u16 typeID;
	u16 numberOfResources;
	u32 reserved;
	ResourceTypeInformationBlock blocks[numberOfResources];
};

struct ResourceTable {
	u16 alignmentShiftCount;
	ResourceRecord records[neHeader.resourceTableEntryCount];
	u8 stringLength;
	char string[stringLength];
};

ResourceTable resourceTable[neHeader.resourceCount] @ addressof(neHeader) + neHeader.resourceTableOffset;

struct ResidentName {
	u8 stringLength;
	char string[stringLength];
	u16 ordinalNumber;
};

ResidentName residentNameTable[while($+1 < addressof(neHeader) + neHeader.moduleReferenceTableOffset)] @ addressof(neHeader) + neHeader.residentNamesTableOffset;

struct ModuleReference {
	u16 moduleNameOffset;
};

ModuleReference moduleReferenceTable[neHeader.moduleReferenceCount] @ addressof(neHeader) + neHeader.moduleReferenceTableOffset;

struct ImportedNameTable {
	u8 stringLength;
	char string[stringLength];
};

ImportedNameTable importedNameTable[while($ < addressof(neHeader) + neHeader.entryTableOffset)] @ addressof(neHeader) + neHeader.importedNamesTableOffset;

enum EntryDataType : u8 {
	Unused,
	Fixed = 0x01 ... 0xFE,
	Moveable
};

struct EntryTable {
	u8 entryCount;
	EntryDataType segmentIndicator;
};

EntryTable entryTable[neHeader.entryTableLength/2] @ addressof(neHeader) + neHeader.entryTableOffset;
