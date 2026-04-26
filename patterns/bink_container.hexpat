// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.


#pragma endian little
#pragma magic [42 49 4B] @ 0x00
#pragma MIME video/vnd.radgamettools.bink

#pragma author Xavier "XJDHDR" du Hecquet de Rauville
#pragma description Bink Video Container - RAD Game Tools


// GLOBALS
u32 CurrentFrame = 0;


// ENUMS
enum WidthHeightScaling : u8
{
    NoScaling             = 0,
    HeightDoubled         = 1,
    HeightInterlaced      = 2,
    WidthDoubled          = 3,
    WidthHeightDoubled    = 4,
    WidthHeightInterlaced = 5,
};

enum AudioAlgorithm : bool
{
    DCT = 0,
    FFT = 1,
};


// BITFIELDS
bitfield VideoFlags
{
                        Unknown1 : 16;
                  bool  Greyscale : 1;
                        Unknown2 : 2;
                  bool  HasAlphaPLane : 1;
                        Unknown3 : 7;
    WidthHeightScaling  Scaling : 4;
};

bitfield AudioPropertyFlags
{
                        Unknown1 : 11;
        AudioAlgorithm  Algorithm : 1;
                  bool  IsStereo : 1;
                  bool  HasAlphaPLane : 1;
                        Unknown2 : 2;
};

fn maskFirstBit(u32 originalValue) {
    return (originalValue & 0xFFFFFFFE);
};

bitfield FrameAddressData {
    bool    IsKeyframe: 1 [[no_unique_address]];
            FrameAddress: 32 [[transform("maskFirstBit")]];
};


// STRUCTS
struct AudioChannelData
{
    u16 Unknown;
    u16 NotAuthoritativeAudioChannelQty;
};

struct AudioChannelProperties
{
                   u16 SampleRate;
    AudioPropertyFlags NotAuthoritativeAudioChannelQty;
};

struct BinkHeader
{
    char                    MagicNumber[3];
    char                    BinkVersion;
    u32                     SizeOfRemainingBytes;
    u32                     NumberOfFrames;
    u32                     LargestFrameSize;
    u32                     NumberOfFramesAgain;
    u32                     VideoFrameWidth;
    u32                     VideoFrameHeight;
    u32                     VideoFPSDividend;
    u32                     VideoFPSDivisor;
    VideoFlags              VideoFlags;
    u32                     AudioTrackQty;
    AudioChannelData        AudioChannelData[AudioTrackQty];
    AudioChannelProperties  AudioChannelProperties[AudioTrackQty];
    u32                     AudioTrackIDs[AudioTrackQty];
};

struct BinkAudioTrack
{
    u32 LengthOfRemainingTrackData;
    
    if (LengthOfRemainingTrackData > 0)
    {
        u32 SamplesQty;
        u8 AudioPacket[LengthOfRemainingTrackData - 4];
    }
};

fn calculateVideoPacketSize(BinkHeader header, ref FrameAddressData frameAddresses, ref BinkAudioTrack audioTracks)
{
    u32 thisFrameTotalSize = frameAddresses[CurrentFrame + 1].FrameAddress - frameAddresses[CurrentFrame].FrameAddress;

    u32 sizeOfAllAudioTracks = 0;
    for (u8 i = 0, i < header.AudioTrackQty, i += 1)
    {
        sizeOfAllAudioTracks += audioTracks[i].LengthOfRemainingTrackData + 4;
    }
  
    u32 videoPacketSize = thisFrameTotalSize - sizeOfAllAudioTracks;
    return videoPacketSize;
};

struct BinkFrame
{
    BinkAudioTrack AudioTracks[parent.Header.AudioTrackQty];
                u8 VideoPacket[calculateVideoPacketSize(parent.Header, parent.FrameAddresses, AudioTracks)];
                
    CurrentFrame += 1;
    $ = parent.FrameAddresses[CurrentFrame].FrameAddress;
};

struct BinkFile
{
          BinkHeader Header;
    FrameAddressData FrameAddresses[Header.NumberOfFrames + 1];
           
     $ = FrameAddresses[0].FrameAddress;
           
           BinkFrame Frames[Header.NumberOfFrames];
};


// ENTRYPOINT
BinkFile binkFile @ 0x0;
