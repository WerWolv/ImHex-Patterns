#include <std/mem.pat>
#include <std/string.pat>

#pragma endian big

u8 eofOffset = 3;

struct Hunk {
	u24 offset;
	u16 length;
	if (length == 0) {
		u16 runCount;
		u8 payload;
	}
	else {
		u8 payload[length];
	}
};

struct IPS {
	char signature[5];
	if (std::mem::read_string(std::mem::size()-3, 3) != "EOF") {
		eofOffset += 3;
	}
	Hunk hunks[while($ < std::mem::size()-eofOffset)];
	char eof[3];
	u24 truncatedSize[eofOffset>3];
};

IPS ips @ 0x00;