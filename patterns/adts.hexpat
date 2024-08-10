#pragma author zhoubo
#pragma description AAC ADTSn (Audio Data Transport Stream) Audio
#pragma magic [ FF F? ] @ 0x00
#pragma pattern_limit 0xFFFFFF

// History
// 0.4  2024-02-12 zhoubo: Porting from 010 Editor Templates.
// 0.3  2024-02-09 zhoubo: use BitfieldDisablePadding(Unpadded Bitfields) for odd header bytes(7,9 bytes) color, and remove FSeek.
// 0.2  2024-02-05 zhoubo: fix some comment & color.
// 0.1  2022-06-13 zhoubo: Init release. only ADTS, not support ADIF,LATM.

// More information available at:
//  1. https://wiki.multimedia.cx/index.php?title=ADTS
//  2. https://en.wikipedia.org/wiki/Advanced_Audio_Coding
//  3. https://en.wikipedia.org/wiki/AAC
//  4. https://juejin.cn/post/7032170229732442148

#pragma endian big

#include <std/sys.pat>
#include <std/core.pat>

fn GetMPEGVersionComment(auto MPEG_Version)
{
    str comment = "";
    match (MPEG_Version)
    {
    (0):          comment = "MPEG-4";
    (1):          comment = "MPEG-2";
    }
    return comment;
};

fn GetProtectionAbsentComment(auto Protection_absence)
{
    str comment = "";
    match (Protection_absence)
    {
    (0):          comment = "ADTS has 9 bytes with CRC";
    (1):          comment = "ADTS has 7 bytes without CRC";
    }
    return comment;
};

fn GetProfileComment(auto Profile)
{
    str comment = "";
    match (Profile)
    {
    (0x00):       comment = "AAC Main";
    (0x01):       comment = "AAC LC (Low Complexity)";
    (0x10):       comment = "AAC SSR (Scalable Sample Rate)";
    (0x11):       comment = "AAC LTP (Long Term Prediction)";
    }
    return comment;
};

fn GetSamplingFrequencyIndexComment(auto Sampling_frequency_index)
{
    str comment = "";
    match (Sampling_frequency_index)
    {
    (0x0):        comment = "96000Hz";
    (0x1):        comment = "88200Hz";
    (0x2):        comment = "64000Hz";
    (0x3):        comment = "48000Hz";
    (0x4):        comment = "44100Hz";
    (0x5):        comment = "32000Hz";
    (0x6):        comment = "24000Hz";
    (0x7):        comment = "22050Hz";
    (0x8):        comment = "16000Hz";
    (0x9):        comment = "12000Hz";
    (0xa):        comment = "11025Hz";
    (0xb):        comment = "8000Hz";
    (0xc):        comment = "7350Hz";
    (0xd):        comment = "Reserved";
    (0xe):        comment = "Reserved";
    (0xf):        comment = "FORBIDDEN (malformed)";
    }
    return comment;
};

fn GetChannelConfigurationComment(auto Channel_configuration)
{
    str comment = "";
    match (Channel_configuration)
    {
    (0):          comment = "Defined in AOT Specifc Config";
    (1):          comment = "1 channel: front-center";
    (2):          comment = "2 channels: front-left, front-right";
    (3):          comment = "3 channels: front-center, front-left, front-right";
    (4):          comment = "4 channels: front-center, front-left, front-right, back-center";
    (5):          comment = "5 channels: front-center, front-left, front-right, back-left, back-right";
    (6):          comment = "6 channels: front-center, front-left, front-right, back-left, back-right, LFE-channel";
    (7):          comment = "8 channels: front-center, front-left, front-right, side-left, side-right, back-left, back-right, LFE-channel";
    }
    return comment;
};

fn GetBufferFullnessComment(auto ADTS_buffer_fullness)
{
    str comment = "";
    match (ADTS_buffer_fullness)
    {
    (0x7FF):      comment = "VBR (most software ignore this field)";
    (_):          comment = "rate..?? (most software ignore this field)";
    }
    return comment;
};

fn GetRawDataBlockComment(auto Number_of_AAC_frames_minus_1)
{
    str comment = "";
    match (Number_of_AAC_frames_minus_1)
    {
    (0x0):        comment = "has 1 AAC data block";
    (_):          comment = "data block number + 1";
    }
    return comment;
};


//-----------------------------------
// Define structures used in AAC files
//
// [1.adts_fixed_header information]
// Syncword:                     12bits, sync header, always 0xFFF。
// MPEG_Version:                 1bit,   0 means MPGE-4, 1 means MPGE-2
// Layer:                        2bits,  alwayas ”00”
// Protection_absence:           1bit,   0 means ADTS Header 9 bytes; 1 means ADTS Header 7 bytes
// Profile:                      2bit,   AAC level : Main,LC,SSR,LTP
// Sampling_frequency_index:     4bits,  Sampling Frequencies
// Private_bit:                  1bit
// Channel_configuration:        3bits,  channel number...
// Originality:                  1bit
// Home:                         1bit
//
// [2.adts_variable_header information]
// Copyright_id_bit:             1bit
// Copyright_id_start:           1bit
// AAC_frame_length:             13bits, AAC frame length : ADTS Header(7 or 9 bytes) + sizeof(AAC Frame)
// ADTS_buffer_fullness:         11bits, 0x7FF means VBR
// Number_of_AAC_frames_minus_1: 2bits,  ADTS Frame numbers : Number_of_AAC_frames_minus_1 + 1
//
// [3.CRC information]
// CRC16:                        16bits, when Protection_absence=0

bitfield ADTS_HEADER
{
    // ADTS_FIXED_HEADER
    Syncword : 12                     [[color("00FF00"), comment("always 0xFFF")]];
    MPEG_Version : 1                  [[color("00FF00"), comment(GetMPEGVersionComment(this))]];
    Layer : 2                         [[color("00FF00"), comment("always 0")]];
    Protection_absence : 1            [[color("00FF00"), comment(GetProtectionAbsentComment(this))]];

    Profile : 2                       [[color("0000FF"), comment(GetProfileComment(this))]];
    Sampling_frequency_index : 4      [[color("0000FF"), comment(GetSamplingFrequencyIndexComment(this))]];
    Private_bit : 1                   [[color("0000FF")]];
    Channel_configuration : 3         [[color("0000FF"), comment(GetChannelConfigurationComment(this))]];
    Originality : 1                   [[color("0000FF")]];
    Home : 1                          [[color("0000FF")]];

    // ADTS_VARIABLE_HEADER
    Copyright_id_bit : 1              [[color("0000FF")]];
    Copyright_id_start : 1            [[color("0000FF")]];
    AAC_frame_length : 13             [[color("0000FF")]];
    ADTS_buffer_fullness : 11         [[color("0000FF"), comment(GetBufferFullnessComment(this))]];
    Number_of_AAC_frames_minus_1 : 2  [[color("0000FF"), comment(GetRawDataBlockComment(this))]];

    // ADTS_CRC_HEADER
    if (0 == Protection_absence) // Header with CRC
    {
        u16 CRC16                     [[color("FFFF00")]];
    }
    else // Header without CRC
    {
    }
};


struct ADTS_FRAME
{
    ADTS_HEADER Header;

    if (0 == Header.Protection_absence) // Header with CRC 2 bytes
    {
        u8 Data[Header.AAC_frame_length - 9]   [[color("000000")]];
    }
    else // Header without CRC
    {
        u8 Data[Header.AAC_frame_length - 7]   [[color("000000")]];
    }
};

//---------------------------------------------

ADTS_FRAME adtsFrame[while(!std::mem::eof())] @ 0x00;
