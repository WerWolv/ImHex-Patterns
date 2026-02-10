#pragma author gmestanley
#pragma description NSFe file format

import std.string;

struct ChunkMetadata {
	u32 length;
	char ID[4];
} [[inline]];

struct TimeChunkData {
	u32 trackLengths[while($<addressof(parent.metadata)+6+parent.metadata.length)];
} [[inline]];

fn formatMetadataName(str string) {
    return "\"" + std::string::substr(string, 0, sizeof(string)-1) + "\"";
};

struct Name {
	char trackName[] [[format("formatMetadataName")]];
};

struct TlblChunkData {
	Name trackNames[while($<addressof(parent.metadata)+6+parent.metadata.length)];
} [[inline]];

struct AuthChunkData {
	char gameTitle[] [[format("formatMetadataName")]];
	char songwriting[] [[format("formatMetadataName")]];
	char copyright[] [[format("formatMetadataName")]];
	char ripper[] [[format("formatMetadataName")]];
} [[inline]];

struct TextChunkData {
	char text[parent.metadata.length];
} [[inline]];

struct Chunk {
	ChunkMetadata metadata;
	if (metadata.ID == "time") TimeChunkData timeChunkData;
	else if (metadata.ID == "text") TextChunkData textChunkData;
	else if (metadata.ID == "tlbl") TlblChunkData tlblChunkData;
	else if (metadata.ID == "auth") AuthChunkData authChunkData;
	else u8 data[metadata.length];
};

char signature[4] @ 0x00;
Chunk chunks[while($<std::mem::size())] @ 0x04;