#pragma MIME audio/midi

using Delta = u8;
using NoteValue = u8;
using Velocity = u8;
using EOF = u8;

// this is just for debugging midi file generation
// I'm testing a known good file against a bad one
// the file is hard coded in file format 0, and if
// you're expecting meta events anywhere add a specific
// call for those
// https://www.music.mcgill.ca/~ich/classes/mumt306/StandardMIDIfileformat.html

enum NoteEvent : u8 {
    NoteOn = 0x90,
    NoteOff = 0x80
};

enum MetaFlag : u16 {
    Footer = 0xFF2F,
    KeySigEvent = 0xFF59,
    TimeSigEvent = 0xFF58,
    TempoEvent = 0xFF51,
    TrackNameEvent = 0xFF03
};

enum HeaderFlag : u32 {
    MThd = 0x4D546864
};

enum TrackChunk : u32 {
    MTrk = 0x4D54726B
};

struct Note {
    Delta delta;
    NoteEvent ne;
    NoteValue note;
    Velocity vel;
};

struct HeaderChunk {
    HeaderFlag flag;
    u32 length;
    u16 mode;
    u16 num_tracks;
    u16 ticks_per_quarter;
    TrackChunk chunk;
    u32 track_length;
};

struct Footer {
	Delta d;
	MetaFlag m;
	EOF eof;
};

struct MidiFile {
    HeaderChunk header;
    // whatever meta flags can be in here
    Note notes[12]; //however many notes you're looking at
    Footer f;
};

MidiFile midi_file @ 0x00;
