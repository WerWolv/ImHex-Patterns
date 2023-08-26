#include <std/core.pat>

#pragma MIME audio/midi
#pragma endian big

// Only supports format 0
// https://www.music.mcgill.ca/~ich/classes/mumt306/StandardMIDIfileformat.html

bool g_has_more_messages = true;
bool g_has_more_tracks = true;

fn signed14(s16 n) {
    // Converts to 14-bit in range 0..16383. Note that MIDI data bytes
    // have their first (most significant) bit clear (0), thus each byte
    // is in range 0..127
    n = ((n & 0x7f) << 7) | ((n >> 8) & 0x7f);
    if (n >= 0) {
        n -= 0x2000;
    }
    return n;
};

fn u32ify(u32 vlq) {
    // Converts from variable-length quantity to u32. These numbers are
    // represented 7 bits per byte, most significant bits first. All bytes
    // except the last have bit 7 set, and the last byte has bit 7 clear.
    // If the number is in range 0..127, it is thus represented exactly
    // as one byte.
    u32 n = vlq & 0x7f;
    if (vlq & 0x8000 == 0x8000) {
        n += ((vlq & 0x7f00) >> 8) * 0x80;
    }
    if (vlq & 0x800000 == 0x800000) {
        n += ((vlq & 0x7f0000) >> 8 * 2) * 0x80 * 0x80;
    }
    if (vlq & 0x80000000 == 0x80000000) {
        n += ((vlq & 0x7f000000) >> 8 * 3) * 0x80 * 0x80 * 0x80;
    }
    return n;
};

enum Status : u8 {
    NoteOff = 0x80 ... 0x8F,
    NoteOn = 0x90 ... 0x9F,
    PolyphonicAfterTouch = 0xA0 ... 0xAF,
    ControlChange = 0xB0 ... 0xBF,
    ProgramChange = 0xC0 ... 0xCF,
    ChannelAfterTouch = 0xD0 ... 0xDF,
    PitchWheel = 0xE0 ... 0xEF,
    SysEx = 0xF0,
    TimeCodeQtrFrame = 0xF1,
    SongPositionPointer = 0xF2,
    SongSelect = 0xF3,
    Undefined = 0xF4 ... 0xF5,
    TuneRequest = 0xF6,
    EndOfSysEx = 0xF7,
    TimingClock = 0xF8,
    Undefined = 0xF9,
    Start = 0xFA,
    Continue = 0xFB,
    Stop = 0xFC,
    Undefined = 0xFD,
    ActiveSensing = 0xFE,
    MetaEvent = 0xFF,
};

Status g_next_status;

enum MetaType : u8 {
    SequenceNumber = 0x00,
    Text = 0x01,
    CopyrightNotice = 0x02,
    TrackName = 0x03,
    InstrumentName = 0x04,
    Lyric = 0x05,
    Marker = 0x06,
    CuePoint = 0x07,
    ChannelPrefix = 0x20,
    EndOfTrack = 0x2F,
    SetTempo = 0x51,
    SMPTEOffset = 0x54,
    TimeSignature = 0x58,
    KeySignature = 0x59,
    SequencerSpecific = 0x7F
};

enum ControlChangeType : u8 {
    Bank_Select_MSB = 0,
    Modulation_Wheel_MSB = 1,
    Breath_Controller_MSB = 2,
    Undefined_MSB = 3,
    Foot_Pedal_MSB = 4,
    Portamento_Time_MSB = 5,
    Data_Entry_MSB = 6,
    Volume_MSB = 7,
    Balance_MSB = 8,
    Undefined_MSB = 9,
    Pan_MSB = 10,
    Expression_MSB = 11,
    Effect_Controller_1_MSB = 12,
    Effect_Controller_2_MSB = 13,
    Undefined_MSB = 14,
    Undefined_MSB = 15,
    General_Purpose_MSB = 16 ... 19,
    Undefined_MSB = 20 ... 31,
    Bank_Select_LSB = 32,
    Modulation_Wheel_LSB = 33,
    Breath_Controller_LSB = 34,
    Undefined_LSB = 35,
    Foot_Pedal_LSB = 36,
    Portamento_Time_LSB = 37,
    Data_Entry_LSB = 38,
    Volume_LSB = 39,
    Balance_LSB = 40,
    Undefined_LSB = 41,
    Pan_LSB = 42,
    Expression_LSB = 43,
    Effect_Controller_1_LSB = 44,
    Effect_Controller_2_LSB = 45,
    Undefined_LSB = 46,
    Undefined_LSB = 47,
    General_Purpose_LSB = 48 ... 51,
    Undefined_LSB = 52 ... 63,
    Damper_Pedal = 64,
    Portamento = 65,
    Sostenuto_Pedal = 66,
    Soft_Pedal = 67,
    Legato_FootSwitch = 68,
    Hold_2 = 69,
    Sound_Controller_1 = 70,
    Sound_Controller_2 = 71,
    Sound_Controller_3 = 72,
    Sound_Controller_4 = 73,
    Sound_Controller_6 = 75,
    Sound_Controller_7 = 76,
    Sound_Controller_8 = 77,
    Sound_Controller_9 = 78,
    Sound_Controller_10 = 79,
    General_Purpose_CC_Control = 80 ... 83,
    Portamento_CC_Control = 84,
    Undefined = 85 ... 87,
    High_Resolution_Velocity_Prefix = 88,
    Effect_2_Depth = 92,
    Effect_3_Depth = 93,
    Effect_4_Depth = 94,
    Effect_5_Depth = 95,
    Data_Increment = 96,
    Data_Decrement = 97,
    Non_Registered_Parameter_Number_LSB = 98,
    Non_Registered_Parameter_Number_MSB = 99,
    Registered_Parameter_Number_LSB = 100,
    Registered_Parameter_Number_MSB = 101,
    Undefined = 102 ... 119,
    All_Sound_Off = 120,
    Reset_All_Controllers = 121,
    Local_Switch = 122,
    All_Notes_Off = 123,
    Omni_Mode_Off = 124,
    Omni_Mode_On = 125,
    Mono_Mode = 126,
    Poly_Mode = 127,
};

enum HeaderFlag : u32 {
    MThd = 0x4D546864
};

enum TrackFlag : u32 {
    MTrk = 0x4D54726B
};

struct VariableLengthQuantity<auto name> {
    if (std::mem::read_unsigned($, 1) & 0x80 == 0x80) {
        if (std::mem::read_unsigned($ + 1, 1) & 0x80 == 0x80) {
            if (std::mem::read_unsigned($ + 2, 1) & 0x80 == 0x80) {
                u32 value [[format("u32ify"), name(name)]];
            } else {
                u24 value [[format("u32ify"), name(name)]];
            }
        } else {
            u16 value [[format("u32ify"), name(name)]];
        }
    } else {
        u8 value [[format("u32ify"), name(name)]];
    }
};

struct MessageData {
    match (u8(g_next_status) & 0xf0) {
        (Status::NoteOff | Status::NoteOn): {
            u8 note_number;
            u8 velocity;
        }
        (Status::PolyphonicAfterTouch): {
            u8 note_number;
            u8 amount;
        }
        (Status::ControlChange): {
            ControlChangeType cc_number;
            u8 value;
        }
        (Status::ProgramChange): {
            u8 program_number;
        }
        (Status::ChannelAfterTouch): {
            u8 amount;
        }
        (Status::PitchWheel): {
            s16 value [[format("signed14")]];
        }
    }
    match (g_next_status) {
        (Status::SysEx | Status::EndOfSysEx): {
            // "EndOfSysEx" can appear as the last data byte in a
            // system exclusive message, or as the starting byte in
            // multi-packet messages
            VariableLengthQuantity<"sysex_length"> sysex_length [[inline]];
            u8 sysex_data[sysex_length.value];
        }
        (Status::SongPositionPointer): {
            u8 lsb;
            u8 msb;
        }
        (Status::SongSelect): {
            u8 song_number;
        }
        (Status::MetaEvent): {
            MetaType meta_type;
            VariableLengthQuantity<"meta_length"> meta_length [[inline]];
            match (meta_type) {
                (MetaType::EndOfTrack): {
                    g_has_more_messages = false;
                    g_has_more_tracks = std::mem::read_unsigned($, 4) == le u32(TrackFlag::MTrk);
                }
                (MetaType::Text
                    | MetaType::CopyrightNotice
                    | MetaType::TrackName
                    | MetaType::InstrumentName
                    | MetaType::Lyric
                    | MetaType::Marker
                    | MetaType::CuePoint): {
                    char text[meta_length.value];
                }
                (MetaType::TimeSignature): {
                    u8 numerator;
                    u8 denominator;
                    u8 ticks_per_click;
                    u8 thirty_second_notes_per_crotchet;
                }
                (MetaType::KeySignature): {
                    u8 key;
                    u8 mode;
                }
                (MetaType::SetTempo): {
                    u24 micro_seconds_per_click; // default 1 million
                }
                (_): {
                    u8 meta_data[meta_length.value];
                }
            }
        }
    }
};

struct Message {
    VariableLengthQuantity<"delta"> delta [[inline]];

    // Status bytes of MIDI channel messages may be omitted if the
    // preceding event is a MIDI channel message with the same status
    if (std::mem::read_unsigned($, 1) > 0x7f) {
        Status status;
        g_next_status = status;
    }

    MessageData data [[inline]];
};

struct HeaderChunk {
    HeaderFlag flag;
    u32 length;
    u16 mode;
    u16 num_tracks;
    u16 ticks_per_quarter;
};

struct TrackChunk {
    TrackFlag flag;
    u32 length;
    g_has_more_messages = true;
    Message messages[while(g_has_more_messages)];
};

struct MidiFile {
    HeaderChunk header;
    TrackChunk tracks[while(g_has_more_tracks)];
};

MidiFile midi_file @ 0x00;
