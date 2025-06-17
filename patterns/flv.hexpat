#pragma author ZN123 version 1.0
#pragma description flv Archive
#pragma MIME video/x-flv
#pragma magic [46 4C 56] @ 0x00

// zn123@sina.com
// https://veovera.org/docs/enhanced/enhanced-rtmp-v2#flv-file-format-overview

import std.io;
import type.base;
import std.mem;
import std.math;
import std.string;
#pragma endian big
#pragma pattern_limit 2000000

enum TypeB:u24{
    flvSignature = 0x564C46,  // Defining flv signature
};
#define FLV_HEADER_FLAG_HASVIDEO  1
#define FLV_HEADER_FLAG_HASAUDIO  4
struct FLVHeader {
    char signature[3]  [[color("FF0000")] ];
    u8 version [[color("00FF00")]];
    u8 stream_info [[color("0000FF")]]; //si->missing_streams = flags & (FLV_HEADER_FLAG_HASVIDEO | FLV_HEADER_FLAG_HASAUDIO);
	if (stream_info & FLV_HEADER_FLAG_HASVIDEO)
		std::print("HAS VIDEO");
	if (stream_info & FLV_HEADER_FLAG_HASAUDIO)
		std::print("HAS AUDIO");
    u32 head_size [[color("FFFF00")]];
	u32 previous_tag_size [[comment("away 0")]];
};
enum FLV_TAG_TYPE : u8 {
  FLV_TAG_TYPE_AUDIO = 8,
  FLV_TAG_TYPE_VIDEO = 9,
  FLV_TAG_TYPE_META = 18
};
#define FLV_AUDIO_CODECID_MASK 0xf0
#define FLV_VIDEO_CODECID_MASK    0x0f
#define FLV_VIDEO_FRAMETYPE_MASK  0x70
#define FLV_VIDEO_FRAMETYPE_OFFSET   4
//  type = (avio_r8(s->pb) & 0x1F);
//  dts  = avio_rb24(s->pb);
//  dts |= (unsigned)avio_r8(s->pb) << 24;
struct BaseTag{
	// if (std::mem::eof()) break;
	u8	TagType;
	u24 offset  [[comment("offset+11 = taglen")]];
	u24 Timestamp;
	u8  TimestampExtended;
	u24 StreamID [[comment("away 0")]];
	// std::print("TagType= {}",TagType & 0x1F );
	// std::print("offset= {}",offset + 11);
	// std::print("dts={},{}, {}",Timestamp,TimestampExtended,Timestamp + (TimestampExtended<<3));
};
enum AMFDataType:u8 {
    AMF_DATA_TYPE_NUMBER      = 0x00,
    AMF_DATA_TYPE_BOOL        = 0x01,
    AMF_DATA_TYPE_STRING      = 0x02,
    AMF_DATA_TYPE_OBJECT      = 0x03,
    AMF_DATA_TYPE_NULL        = 0x05,
    AMF_DATA_TYPE_UNDEFINED   = 0x06,
    AMF_DATA_TYPE_REFERENCE   = 0x07,
    AMF_DATA_TYPE_MIXEDARRAY  = 0x08,
    AMF_DATA_TYPE_OBJECT_END  = 0x09,
    AMF_DATA_TYPE_ARRAY       = 0x0a,
    AMF_DATA_TYPE_DATE        = 0x0b,
    AMF_DATA_TYPE_LONG_STRING = 0x0c,
    AMF_DATA_TYPE_UNSUPPORTED = 0x0d,
};

#define TYPE_ONTEXTDATA 1
#define TYPE_ONCAPTION 2
#define TYPE_ONCAPTIONINFO 3
#define TYPE_UNKNOWN 9

fn flv_read_metabody(auto offset){
	u8 flags =  std::mem::read_unsigned($ , 1, std::mem::Endian::Big);
	u64 startOffset = $;
	u64 endOffset = $ + offset;
	std::print("metabody {},{}",startOffset,endOffset);
	if (flags != AMFDataType::AMF_DATA_TYPE_STRING){ 
		return TYPE_UNKNOWN; 
	}
	
	u16 len = std::mem::read_unsigned($+1 , 2, std::mem::Endian::Big);
	if (len > endOffset) return 0;
	str name = std::mem::read_string($+3,len);
	std::print("AMF_DATA_TYPE_STRING {} {}",len,name);

	if (std::string::contains(name, "onMetaData")) {
        std::print("onMetaData");
    } else if (std::string::contains(name, "onTextData")) {
		std::print("onTextData");
    } else if (std::string::contains(name, "onCaption")) {
		std::print("onCaption");
    } else if (std::string::contains(name, "onCaptionInfo")) {
		std::print("onCaptionInfo");
    } else if (std::string::contains(name, "onTextData")) {
		std::print("onTextData");
    } else {
        std::error("Invalid DataEntryBox");
    }
	return flags;
};
/***
//#define FLV_AUDIO_CODECID_OFFSET  4
enum FLV_CODECID:u8{
    FLV_CODECID_PCM                  = 0,
    FLV_CODECID_ADPCM                = 1 ,
    FLV_CODECID_MP3                  = 2 ,
    FLV_CODECID_PCM_LE               = 3 ,
    FLV_CODECID_NELLYMOSER_16KHZ_MONO = 4 ,
    FLV_CODECID_NELLYMOSER_8KHZ_MONO = 5 ,
    FLV_CODECID_NELLYMOSER           = 6 ,
    FLV_CODECID_PCM_ALAW             = 7 ,
    FLV_CODECID_PCM_MULAW            = 8 ,
    FLV_CODECID_OPUS                 = 9 ,//china//1001
    FLV_CODECID_AAC                  = 10,//1010
    FLV_CODECID_SPEEX                = 11,//11<< FLV_AUDIO_CODECID_OFFSET,1011
};
***/
bitfield FLVTagAudio_flags {
    audio_codecid  	: 4;
    sample_rate     : 2; //3:44100 2:22k 1:11 0:5.5 [AAC away 3]
    channels   		: 1 [[format("format_channels")]]; //0 mono ,1 stereo [AAC away 1]
	bits_per_coded_sample   	: 1; //0 8bit,1 16bit 
} [[inline]];

fn format_channels(u8 value) {
    return value;
};
struct FLVTagAudio{
	FLVTagAudio_flags flags;
	u8 data[parent.offset-1] [[sealed]];
};
/***
enum FrameType:u8{
    FLV_FRAME_KEY            = 1 , ///< key frame (for AVC, a seekable frame) 001
    FLV_FRAME_INTER          = 2 , ///< inter frame (for AVC, a non-seekable frame) 010
    FLV_FRAME_DISP_INTER     = 3 , ///< disposable inter frame (H.263 only) 011
    FLV_FRAME_GENERATED_KEY  = 4 , ///< generated key frame (reserved for server use only) 100
    FLV_FRAME_VIDEO_INFO_CMD = 5 , ///< video info/command frame 101
};
enum {
    FLV_CODECID_H263    = 2,
    FLV_CODECID_SCREEN  = 3,
    FLV_CODECID_VP6     = 4,
    FLV_CODECID_VP6A    = 5,
    FLV_CODECID_SCREEN2 = 6,
    FLV_CODECID_H264    = 7,
    FLV_CODECID_REALH263= 8,
    FLV_CODECID_MPEG4   = 9,
	FLV_CODECID_HEVC    = 12, //china
    FLV_CODECID_AV1     = 13, //china
    FLV_CODECID_VP8     = 14, //china
    FLV_CODECID_VP9     = 15, //china
};
enum {
    PacketTypeSequenceStart         = 0,
    PacketTypeCodedFrames           = 1,
    PacketTypeSequenceEnd           = 2,
    PacketTypeCodedFramesX          = 3,
    PacketTypeMetadata              = 4,
    PacketTypeMPEG2TSSequenceStart  = 5,
};
***/
bitfield FLVTagVideo_flags {
	enhanced_flv	: 1;
    FrameType  		: 3;
    video_codecid   : 4; 
} [[inline]];
bitfield FLVTagVideoEXT_flags {
	enhanced_flv	: 1;
    FrameType  		: 3;
    PacketType   : 4;
} [[inline]];

struct FLVTagVideo{
	FLVTagVideo_flags flags;
	u8 PacketType;
	u8 data[parent.offset-1-1] [[sealed]];
};
struct FLVTagVideoExt{
	FLVTagVideoEXT_flags flags;
	char video_codecid[4];
	u8 data[parent.offset-1-4] [[sealed]];
};

struct FLVTag: BaseTag{
	try {
		u8 type =(TagType & 0x1F);
		if (type == FLV_TAG_TYPE::FLV_TAG_TYPE_META){
			std::print("___FLV_TAG_TYPE::FLV_TAG_TYPE_META");
			// flv_read_metabody(offset);
			u8  data[offset] [[sealed]];
		}else if (type == FLV_TAG_TYPE::FLV_TAG_TYPE_VIDEO){
			u8 ext = std::mem::read_unsigned($ , 1, std::mem::Endian::Big);
			ext = (ext &  0x80) >> 7;
			if (ext == 1){
				FLVTagVideoExt tagVideoExt;
			}else{
				FLVTagVideo tagVideo;
			}
		}else if (type == FLV_TAG_TYPE::FLV_TAG_TYPE_AUDIO){	
			//u8  data[offset] [[sealed]];
			FLVTagAudio tagAudio;
		}else{
			std::print("___FLV_TAG_TYPE::UNKOWN");		
			u8  data[offset] [[sealed]];
		}
		u32 previous_tag_size;
	} catch {
        std::warning("Invalid sample payload at chunk");
		break;
	}
} [[name(std::format("FLVTag({})", TagType))]];


FLVHeader flvheader @ 00;
FLVTag flvtag[while(!std::mem::eof())] @ $ ;
