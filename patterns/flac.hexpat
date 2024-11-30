#pragma author WerWolv
#pragma description Free Lossless Audio Codec, FLAC Audio Format

import std.sys;
import std.core;
import std.io;

#pragma endian big

using BitfieldOrder = std::core::BitfieldOrder;

u32 sampleSize;
u32 bitsPerSample;

// METADATA

enum BLOCK_TYPE : u8 {
	STREAMINFO = 0,
	PADDING = 1,
	APPLICATION = 2,
	SEEKTABLE = 3,
	VORBIS_COMMENT = 4,
	CUESHEET = 5,
	PICTURE = 6,

	INVALID = 127
};

bitfield METADATA_BLOCK_HEADER {
	lastMetadataBlock 	: 1;
	blockType 			: 7;
	length				: 24;
};

bitfield STREAMINFO_FLAGS {
	sampleRate 			: 20;
	numChannels 		: 3 [[format("format_channels")]];
	bitsPerSample 		: 5;
	numSamplesInStream	: 36;
} [[inline]];

fn format_channels(u8 value) {
	return value + 1;
};

struct METADATA_BLOCK_STREAMINFO {
	u16 minBlockSize, maxBlockSize;
	u24 minFrameSize, maxFrameSize;
	STREAMINFO_FLAGS flags;
	u128 md5Signature;

	bitsPerSample = flags.bitsPerSample;
};

struct METADATA_BLOCK_PADDING {
	padding[parent.header.length];
};

struct METADATA_BLOCK_APPLICATION {
	char applicationID[4];
	u8 applicationData[parent.header.length - sizeof(applicationID)];
};

struct SEEKPOINT {
	u64 sampleNumber;
	u64 byteOffset;
	u16 numSamples;
};

struct METADATA_BLOCK_SEEKTABLE {
	SEEKPOINT seekPoints[parent.header.length / 18];
};

struct VORBIS_USER_COMMENT {
	le u32 length;
	char comment[length];
};

struct METADATA_BLOCK_VORBIS_COMMENT {
	le u32 vendorLength;
	u8 vendor[vendorLength];

	le u32 userCommentListLength;
	VORBIS_USER_COMMENT userCommentList[userCommentListLength];
};

bitfield TRACK_FLAGS {
	audioTrack 	: 1;
	preEmphasis : 1;
} [[inline,bitfield_order(BitfieldOrder::LeastToMostSignificant, 8)]];

struct CUESHEET_TRACK_INDEX {
	u64 sampleOffset;
	u8 indexPointNumber;
	padding[3];
};

struct CUESHEET_TRACK {
	u64 trackOffset;
	u8 trackNumber;
	char trackISRC[12];
	TRACK_FLAGS flags;
	padding[13];
	u8 numTrackIndexPoints;
	CUESHEET_TRACK_INDEX indexes[numTrackIndexPoints];
};

struct METADATA_BLOCK_CUESHEET {
	char mediaCatalogNumber[128];
	u64 numLeadInSamples;
	bool isCD;
	padding[258];
	u8 numTracks;
	CUESHEET_TRACK tracks[numTracks];
};

enum PICTURE_TYPE : u32 {
	Other 				= 0,
	FileIcon 			= 1,
	OtherFileIcon 		= 2,
	CoverFront			= 3,
	CoverBack			= 4,
	LeafletPage			= 5,
	Media				= 6,
	LeadArtist			= 7,
	Artist				= 8,
	Conductor			= 9,
	Band				= 10,
	Composer			= 11,
	Lyricist			= 12,
	RecordingLocation	= 13,
	DuringRecording		= 14,
	DuringPerformance	= 15,
	MovieScreenCapture	= 16,
	ABrightColoredFish	= 17,
	Illustration		= 18,
	BandLogoType		= 19,
	PublisherLogoType	= 20
};

struct METADATA_BLOCK_PICTURE {
	PICTURE_TYPE pictureType;
	u32 mimeTypeLength;
	char mimeType[mimeTypeLength];
	u32 descriptionLength;
	char description[descriptionLength];
	u32 width, height;
	u32 colorDepth;
	u32 colorCount;
	u32 pictureDataLength;
	u8 pictureData[pictureDataLength];
};



// FRAME DATA
// TODO: THIS IS INCOMPLETE / NOT WORKING CURRENTLY

bitfield FRAME_HEADER_FLAGS {
	syncCode			: 14;
	padding				: 1;
	blockingStrategy	: 1;
	blockSize			: 4;
	sampleRate			: 4;
	channelAssignment	: 4;
	sampleSize			: 3;
} [[inline,bitfield_order(BitfieldOrder::LeastToMostSignificant, 32)]];

struct FRAME_HEADER {
	FRAME_HEADER_FLAGS flags;

	sampleSize = flags.sampleSize;

	if (flags.blockingStrategy)
		char16 sampleNumber[7];
	else
		char16 frameNumber[6];

	if (flags.blockSize == 0b0110)
		u8 blockSize;
	else if (flags.blockSize == 0b0111)
		u16 blockSize;

	if (flags.sampleRate == 0b1100)
		u8 sampleRate;
	else if (flags.sampleRate == 0b1101 || flags.sampleRate == 0b1110)
		u16 sampleRate;

	u8 crc8;
};

struct FRAME_FOOTER {
	u16 crc16;
};

bitfield SUBFRAME_HEADER {
	padding	: 1;
	type	: 6;
	wastedBits : 1;
};

fn getBitsPerSample() {
	if (sampleSize == 0b000)
		return bitsPerSample;
	else if (sampleSize == 0b001)
		return 8;
	else if (sampleSize == 0b010)
		return 12;
	else if (sampleSize == 0b100)
		return 16;
	else if (sampleSize == 0b101)
		return 20;
	else if (sampleSize == 0b110)
		return 24;
    else
		std::error(std::format("Invalid sample size {}.", sampleSize));
};

bitfield SUBFRAME_CONSTANT {
	value : getBitsPerSample();
};

bitfield SUBFRAME_VERBATIM {
	value : getBitsPerSample() * parent.parent.header.flags.blockSize;
};

bitfield SUBFRAME_FIXED_VALUE {
	value : getBitsPerSample() * (parent.parent.header.type & 0b111);
	codingMethod : 2;
} [[inline]];

bitfield RESIDUAL_CODING_METHOD_PARTITIONED_RICE {
	partitionOrder : 4;
	riceParameter : 4;
	if (riceParameter == 0b1111)
		bitsPerSample : 5;
};

bitfield RESIDUAL_CODING_METHOD_PARTITIONED_RICE2 {
	partitionOrder : 4;
	riceParameter  : 5;
	if (riceParameter == 0b11111)
		bitsPerSample : 5;
};

struct RESIDUAL {
	if (parent.value.codingMethod == 0b00)
		RESIDUAL_CODING_METHOD_PARTITIONED_RICE rice;
	else if (parent.value.codingMethod == 0b01)
		RESIDUAL_CODING_METHOD_PARTITIONED_RICE2 rice;


	if ((parent.parent.header.type & 0b111) == 0b000)
		u8 samples[(getBitsPerSample() * (parent.parent.parent.header.flags.blockSize - (parent.parent.header.type & 0b111))) / 8];
	else if (std::core::array_index() != 0)
		u8 samples[(getBitsPerSample() * (parent.parent.parent.header.flags.blockSize / (1 << rice.partitionOrder))) / 8];
	else
		u8 samples[(getBitsPerSample() * ((parent.parent.parent.header.flags.blockSize / (1 << rice.partitionOrder)) - (parent.parent.header.type & 0b111))) / 8];
};

struct SUBFRAME_FIXED {
	SUBFRAME_FIXED_VALUE value;
	RESIDUAL residual;
};

bitfield SUBFRAME_LPC_VALUE {
	warmUpSamples : getBitsPerSample() * ((parent.header.type & 0b011111) + 1);
	quantizedLinearPredictorCoefficient : 4;
	quantizedLinearPredictorCoefficientShift : 5;
	predictorCoefficients : quantizedLinearPredictorCoefficient * ((parent.header.type & 0b011111) + 1);
} [[inline]];

struct SUBFRAME_LPC {
	SUBFRAME_LPC_VALUE value;
	RESIDUAL residual;
};


struct SUBFRAME {
	SUBFRAME_HEADER header;

	if (header.type == 0b00000)
		SUBFRAME_CONSTANT constant;
	else if (header.type == 0b000001)
		SUBFRAME_VERBATIM verbatim;
	else if ((header.type >> 3) == 0b001 && (header.type & 0b111) <= 4)
		SUBFRAME_FIXED fixed;
	else if (header.type == 0b100000)
		SUBFRAME_LPC lpc;
};

struct FRAME {
	FRAME_HEADER header;
	SUBFRAME subframes[parent.metadata[0].data.flags.numChannels + 1];
	FRAME_FOOTER footer;
};


struct METADATA_BLOCK {
	METADATA_BLOCK_HEADER header;
	if (header.lastMetadataBlock)
		break;

	if (header.blockType == BLOCK_TYPE::STREAMINFO)
		METADATA_BLOCK_STREAMINFO data;
	else if (header.blockType == BLOCK_TYPE::PADDING)
		METADATA_BLOCK_PADDING data;
	else if (header.blockType == BLOCK_TYPE::APPLICATION)
		METADATA_BLOCK_APPLICATION data;
	else if (header.blockType == BLOCK_TYPE::SEEKTABLE)
	     METADATA_BLOCK_SEEKTABLE data;
	else if (header.blockType == BLOCK_TYPE::VORBIS_COMMENT)
		METADATA_BLOCK_VORBIS_COMMENT data;
	else if (header.blockType == BLOCK_TYPE::CUESHEET)
		METADATA_BLOCK_CUESHEET data;
	else if (header.blockType == BLOCK_TYPE::PICTURE)
		METADATA_BLOCK_PICTURE data;
	else
		std::error("Invalid metadata block type!");
};

struct STREAM {
	char magic[4];
	METADATA_BLOCK metadata[while(true)];
	//FRAME frames[while(!std::mem::eof())];
};

STREAM stream @ 0x00;
