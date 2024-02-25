#pragma author gmestanley
#pragma description IPS (International Patching System) files

#pragma endian big

import std.mem;
import std.string;

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
	u24 truncatedSize[3+(std::mem::read_string(std::mem::size()-3, 3) != "EOF")>3];
};

IPS ips @ 0x00;
