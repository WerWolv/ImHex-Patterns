#pragma MIME audio/wav

struct riffHeader{
	char ckID[4] [[comment("Container Signature"), name("RIFF Header Signature")]];
	u32 ckSize [[comment("Size of RIFF Header"), name("RIFF Chunk Size")]];
};

struct waveHeader{
	char format[4] [[name("WAVE Header Signature")]];
	char ckID[4] [[comment("Format Chunk")]];
	u32 ckSize [[comment("Chunk size")]];
	u16 wFormatTag;
	u16 wChannels;
	u32 dwSamplesPerSec [[comment("Sample Frequency")]];
	u32 dwAvgBytesPerSec [[comment("BPS - Used to estimate buffer size")]];
	u16 wBlockAlign;
};

struct pcmHeader{
	u16 wBitsPerSample;
};

struct wavHeader{
	riffHeader riff;
	waveHeader wave;
	pcmHeader pcm;
};

wavHeader header @0x00;
