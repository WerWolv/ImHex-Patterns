#pragma author WerWolv
#pragma description OGG Audio

#pragma MIME audio/ogg

import std.core;
import std.mem;

bitfield HeaderType {
	Continuation	: 1;
	BeginOfStream	: 1;
	EndOfStream		: 1;
};

struct SegmentData {
	u8 data[parent.segmentTable[std::core::array_index()]];
};

struct Ogg {
	char capturePattern[4];
	u8 version;
	HeaderType headerType;
	u64 granulePosition;
	u32 bitstreamSerialNumber;
	u32 pageSequenceNumber;
	u32 checksum;
	u8 pageSegments;
	u8 segmentTable[pageSegments];
	SegmentData data[pageSegments];
};

Ogg ogg[while(!std::mem::eof())] @ 0x00;