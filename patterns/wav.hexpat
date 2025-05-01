#pragma description RIFF/WAVE/PCM (.wav)

#pragma MIME audio/x-wav
#pragma MIME audio/wav

import std.core;
import std.mem;
import type.mmreg;

struct RiffHeader {
  char ckID[4] [[comment("Container Signature"), name("RIFF Header Signature")]];
  u32  ckSize [[comment("Size of RIFF Header"), name("RIFF Chunk Size")]];
  char format[4] [[comment("RIFF format"), name("WAVE Header Signature")]];
};

struct WaveChunk {
  char chunkId[4];
  u32  chunkSize;
};

struct WaveFact {
  u32 uncompressedSize;
};

enum SampleLookupType : u32 {
  TYPE_LOOP_FORWARD,
  TYPE_LOOP_ALTERNATE,
  TYPE_LOOP_BACKWARD,
};

struct SampleLookup {
  u32              id;
  SampleLookupType type;
  u32              start;
  u32              end;
  u32              fraction;
  u32              playCount;
};

struct WaveSample {
  u32 manufacturer;
  u32 product;
  u32 samplePeriod;
  u32 MIDIUnityNote;
  u32 MIDIPitchFraction;
  u32 SMPTEFormat;
  u32 SMPTEOffset;
  u32 numSampleLoops;
  u32 sampleLoopsSize;

  SampleLookup lookups[numSampleLoops];
};

struct WaveCuePoint {
  u32  indentifier;
  u32  position;
  char chunkID[4];
  u32  chunkStart;
  u32  blockStart;
  u32  sampleOffset;
};

struct WaveCue {
  u32          numCuePoints;
  WaveCuePoint cuePoints[numCuePoints];
};

struct WaveLabel {
  u32  id;
  char text[];
  padding[sizeof(text) % 2];
};

using WaveNote = WaveLabel;

struct WaveListItem : WaveChunk {
  if (chunkId == "labl") {
    WaveLabel label;
  } else if (chunkId == "note") {
    WaveNote note;
  } else {
    padding[(chunkSize + 1) >> 1 << 1];
  }
};

u64 listEnd;

struct WaveList {
  char type[4];

  WaveListItem item[while ($ < listEnd)];
};

u32 paddedChunkSize;

struct WavData {
  WaveChunk chunk;
  paddedChunkSize = (chunk.chunkSize + 1) >> 1 << 1;

  if (chunk.chunkId == "fmt ") {
    u128 start = $;
    type::TypewFormatTag wfmt = std::mem::read_unsigned($, 2, std::core::get_endian());

    if (wfmt == WaveFormatType::PCM) {
      type::PCMWAVEFORMAT waveformat;
    } else if (fmt.formatTag == WaveFormatType::MS_ADPCM) {
      type::ADPCMWAVEFORMAT waveformat;
    } else if (fmt.formatTag == WaveFormatType::MPEG) {
      type::MPEG1WAVEFORMAT waveformat;
    } else if (fmt.formatTag == WaveFormatType::MPEGLAYER3) {
      type::MPEGLAYER3WAVEFORMAT waveformat;
    } else if (fmt.formatTag == WaveFormatType::IEEEFloatingPoint) {
      type::WAVEFORMATIEEEFLOATEX waveformat;
    } else {
      type::WAVEFORMAT waveformat_unknown;
    }
    padding[paddedChunkSize - ($ - start)];
  } else if (chunk.chunkId == "data") {
    padding[paddedChunkSize];
  } else if (chunk.chunkId == "fact") {
    WaveFact fact;
    padding[paddedChunkSize - sizeof(fact)];
  } else if (chunk.chunkId == "smpl") {
    WaveSample smpl;
    padding[paddedChunkSize - sizeof(smpl)];
  } else if (chunk.chunkId == "cue ") {
    WaveCue cue;
    padding[paddedChunkSize - sizeof(cue)];
  } else if (chunk.chunkId == "LIST") {
    listEnd = $ + chunk.chunkSize;
    WaveList list;
    padding[paddedChunkSize % 1];
  } else {
    padding[paddedChunkSize];
  }
};

RiffHeader header @0x00;
WavData    data[while (!std::mem::eof())] @ $;
