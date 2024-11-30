#pragma author WerWolv
#pragma description Xilinx FPGA Bitstream

import std.mem;
import std.io;

struct Flags {
	be u16 length;
	u8 value[length];
};

struct TLV {
	char tag[parent.keySize];
	be u16 length;
	char value[length];
};

struct Command {
	be u32 value;
} [[static, sealed, format("format_command")]];

fn format_command(Command command) {
	u32 x = command.value;

	if (x == 0x20000000) return "NOP";
	if (x == 0xAA995566) return "SYNC";
	if (x == 0x000000BB) return "Bus Width Sync";
	if (x == 0x11220044) return "Bus Width Detect";
	if (x == 0x30002001) return "Write to FAR";
	if (x == 0x28006000) return "Write to FDRO";
	if (x == 0x30000001) return "Write to CRC";
	if (x == 0x30018001) return "Write to IDCODE";
	if (x == 0x30004000) return "Write to FDRI";
	if (x == 0x30008001) return "Write to CMD";

	if ((x & 0xF0000000) == 0x30000000)
		return std::format("Write to Register {}", (x & 0x0003E000) >> 13);

	return std::format("0x{:08X}", x);
};

struct Commands {
	char tag[parent.keySize];
	be u32 length;
	Command commands[length / 4];
};

struct Header {
	Flags flags;
	be u16 keySize;
	TLV tlv[4];
	Commands data;
};

Header header @ 0x00;