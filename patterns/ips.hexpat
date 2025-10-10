#pragma author gmestanley
#pragma description IPS (International Patching System)
#pragma magic [ 50 41 54 43 48 ] @ 0x00

#pragma endian big

import std.mem;

struct Hunk {
	u24 offset;
	u16 length;
	if (!length) {
		u16 runCount;
		u8 payload;
	}
	else {
		u8 payload[length];
	}
};

struct IPS {
	char signature[5];
	Hunk hunks[while($ < std::mem::size() - (3 + 3 * (std::mem::read_string(std::mem::size()-3, 3) != "EOF")))];
	char eof[3];
	u24 truncatedSize[3+(std::mem::read_string(std::mem::size()-3, 3) != "EOF")];
};

IPS ips @ 0x00;
