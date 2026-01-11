#pragma author gmestanley
#pragma description Sega Genesis/MegaDrive header
#pragma source plutiedev.com/rom-header wiki.neogeodev.org/index.php?title=68k_vector_table

#pragma endian big

import std.string;

struct M68000Vectors {
	u32 stackPointerReset;
	u32 programCounterReset [[comment("Entry Point")]];
	u32 busError;
	u32 addressError;
	u32 illegalInstruction;
	u32 divisionByZero;
	u32 chkInstruction;
	u32 trapVInstruction;
	u32 privilegeViolation;
	u32 trace;
	u32 lineAInstruction;
	u32 lineFInstruction;
	padding[12];
	u32 uninitializedInterruptVector;
	padding[32];
	u32 spuriousInterrupt;
	u32 interruptAutovectors[7];
	u32 traps[16];
};

M68000Vectors vectors @ 0x00;

struct Info {
	char softwareType[2];
	char space;
	char serialNumber[8];
	char dash;
	char revision[2];
};

enum DeviceType : char {
	NotFilled = ' ',
	Button3Controller = 'J',
	Button6Controller = '6',
	MasterSystemController = '0',
	AnalogJoystick = 'A',
	Multitap = '4',
	Lightgun = 'G',
	Activator = 'L',
	Mouse = 'M',
	Trackball = 'B',
	Mouse = 'T',
	Trackball = 'V',
	Keyboard = 'K',
	RS232 = 'R',
	Printer = 'P',
	CDROM = 'C',
	FloppyDrive = 'F',
	Download = 'D'
};

bitfield RAMType {
	addresses : 1;
	padding : 3;
	bits : 2;
	saves : 1;
	sig : 1;
};

enum MemoryType : char {
	RAM = ' ',
	EEPROM = '@'
};

struct ExtraMemory {
	char signature[2];
	RAMType ramType;
	MemoryType memoryType;
	u32 startAddress;
	u32 endAddress;
};

fn renderMicrophoneType(str value) {
	match(value) {
		("00"): value = "NoMicJapanOnly";
		("10"): value = "MicJapanOnly";
		("20"): value = "NoMicOverseasOnly";
		("30"): value = "MicOverseasOnly";
		("40"): value = "NoMic";
		("50"): value = "Mic";
		("60"): value = "NoMicJapan";
		("70"): value = "NoMicOverseas";
	}
};

struct ModemSupport {
	char signature[2];
	char publisher[4];
	char gameNumber[2];
	char comma;
	char version;
	char microphone[2] [[format("renderMicrophoneType")]];
};

enum RegionType : char {
	None = ' ',
	Japan = 'J',
	Americas = 'U',
	Europe = 'E'
};

fn formatTerminatedString(str string) {
	u8 index;
	while (index < std::string::length(string)) {
		if (std::mem::read_string($+index, 2) == "  ")
			break;
		index += 1;
	}
	return "\"" + std::string::substr(string, 0, index) + "\"";
};

struct Header {
	char systemType[16] [[format("formatTerminatedString")]];
	char copyright[16] [[format("formatTerminatedString")]];
	char domesticTitle[48] [[format("formatTerminatedString")]];
	char overseasTitle[48] [[format("formatTerminatedString")]];
	Info info;
	u16 checksum;
	DeviceType deviceType[16];
	u32 romAddressRange[2];
	u32 ramAddressRange[2];
	if ($[$] == 'R') ExtraMemory extraMemory; else padding[12];
	if ($[$] == 'M') ModemSupport modemSupport; else padding[12];
	padding[40];
	RegionType regions[3];
};

Header header @ 0x100;