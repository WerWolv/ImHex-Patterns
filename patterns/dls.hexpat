#pragma description Downloadable Sounds (DLS)
#pragma pattern_limit 4294967295

// DLS does not have its MIME type?
#pragma MIME application/x-riff

import std.mem;
import std.core;
import type.guid;
import type.mmreg;

enum ChunkID : u32 {
    RIFF = 0x46464952,
    LIST = 0x5453494C,

    INFO = 0x4F464E49, // only as LIST type
    IARL = 0x4C524149, // Archival Location
    IART = 0x54524149, // Artist
    ICMS = 0x534D4349, // Commissioned
    ICMT = 0x544D4349, // Comments
    ICOP = 0x504F4349, // Copyright
    ICRD = 0x44524349, // Creation Date
    IENG = 0x474E4549, // Engineer
    IGNR = 0x524E4749, // Genre
    IKEY = 0x59454B49, // Keywords
    IMED = 0x44454D49, // Medium
    INAM = 0x4D414E49, // Name
    IPRD = 0x44525049, // Product
    ISBJ = 0x4A425349, // Subject
    ISFT = 0x54464E49, // Software
    ISRC = 0x43525349, // Source
    ISRF = 0x46525349, // Source Form
    ITCH = 0x48435449, // Technician

    DLS  = 0x20534C44, // only as identifier
    colh = 0x686C6F63,
    dlid = 0x64696C64,
    insh = 0x68736E69,
    rgnh = 0x686E6772,
    art1 = 0x31747261,
    art2 = 0x32747261,
    wlnk = 0x6B6E6C77,
    wsmp = 0x706D7377,
    ptbl = 0x6C627470,
    vers = 0x73726576,
    fmt  = 0x20746D66,
    data = 0x61746164,
    cdl  = 0x206C6463,

    cue  = 0x20657563,
    labl = 0x6C62616C,
    note = 0x65746F6E,
    fact = 0x74636166,

    // LIST types
    wvpl = 0x6C707677,
    wave = 0x65766177,
    lins = 0x736E696C,
    ins  = 0x20736E69,
    lrgn = 0x6E67726C,
    rgn  = 0x206E6772,
    rgn2 = 0x326E6772,
    lart = 0x7472616C,
    lar2 = 0x3272616C,

    adtl = 0x6C746461,
};

enum ConnSource : u16 {
    // Generic Sources
    None = 0x0000,
    LFO = 0x0001,
    KeyOnVelocity = 0x0002,
    KeyNumber = 0x0003,
    EG1 = 0x0004, // Envelope Generator 1
    EG2 = 0x0005, // Envelope Generator 2
    PitchWheel = 0x0006,
    PolyPressure = 0x0007,
    ChannelPressure = 0x0008,
    VibratoLFO = 0x0009,

    // MIDI Sources
    CC1 = 0x0081, // Modulation Wheel
    CC7 = 0x0087, // Channel Volume
    CC10 = 0x008a, // Pan
    CC11 = 0x008b, // Expression
    CC91 = 0x00db, // Reverb Send
    CC93 = 0x00dd, // Chorus Send

    // Registered Parameter Numbers
    RPN0 = 0x0100, // Pitch Bend Sensitivity
    RPN1 = 0x0101, // Fine Tune
    RPN2 = 0x0102  // Coarse Tune
};

enum ConnDestination : u16 {
    // Generic Destinations
    None = 0x0000,
    Attenuation = 0x0001,
    Reserved = 0x0002,
    Pitch = 0x0003,
    Pan = 0x0004,
    KeyNumber = 0x0005,

    // Channel Output Destinations
    Left = 0x0010,
    Right = 0x0011,
    Center = 0x0012,
    LFE = 0x0013,
    LeftRear = 0x0014,
    RightRear = 0x0015,
    Chorus = 0x0080,
    Reverb = 0x0081,

    // LFO Destinations
    LFOFrequency = 0x0104,
    LFOStartDelay = 0x0105,

    // EG1 Destinations
    EG1AttackTime = 0x0206,
    EG1DecayTime = 0x0207,
    EG1Reserved = 0x0208,
    EG1ReleaseTime = 0x0209,
    EG1SustainLevel = 0x020a,
    EG1DelayTime = 0x020b,
    EG1HoldTime = 0x020c,
    EG1ShutdownTime = 0x020d,

    // EG2 Destinations
    EG2AttackTime = 0x030a,
    EG2DecayTime = 0x030b,
    EG2Reserved = 0x030c,
    EG2ReleaseTime = 0x030d,
    EG2SustainLevel = 0x030e,
    EG2DelayTime = 0x030f,
    EG2HoldTime = 0x0310,

    // Filter Destinations
    FilterCutoff = 0x0500,
    FilterQ = 0x0501
};

enum ConnTransformv1 : u16 {
    None = 0x0000,
    Concave = 0x0001,
    Convex = 0x0002,
    Switch = 0x0003
};

bitfield ConnTransformv2 {
    ConnTransformv1 outTransform : 4;
    ConnTransformv1 ctrlTransform : 4;
    bool ctrlBipolar : 1;
    bool ctrlInvert : 1;
    ConnTransformv1 srcTransform : 4;
    bool srcBipolar : 1;
    bool srcInvert : 1;
};

fn _u128guid(auto name, u32 timelow, u16 timemid, u16 timehighver, u8 clockseqrev, u8 clockseqlow, u8 node0, u8 node1, u8 node2, u8 node3, u8 node4, u8 node5) {
    type::GUID result;
    result.time_low = timelow;
    result.time_mid = timemid;
    result.time_high_and_version = timehighver;
    result.clock_seq_high_and_reserved = clockseqrev;
    result.clock_seq_low = clockseqlow;
    result.node[0] = node0;
    result.node[1] = node1;
    result.node[2] = node2;
    result.node[3] = node3;
    result.node[4] = node4;
    result.node[5] = node5;
    return be u128(result);
};

struct ChunkHeader {
    ChunkID chunkID;
    u32 size;
} [[static]];

bitfield MIDIBank {
    unsigned bankLSB : 7;
    padding : 1;
    unsigned bankMSB : 7;
    padding : 16;
    bool drum : 1;
};

bitfield MIDIInstrument {
    unsigned instrument : 7;
    padding : 25;
};

struct MIDILocale {
    MIDIBank ulBank;
    MIDIInstrument ulInstrument;
} [[static]];

struct RgnRange {
    u16 usLow;
    u16 usHigh;
} [[static]];

bitfield RgnhOptions {
    SelfNonExclusive : 1;
    padding : 15;
};

struct ConnectionBlockv1 {
    ConnSource usSource;
    ConnSource usControl;
    ConnDestination usDestination;
    ConnTransformv1 usTransform;
    s32 lScale;
} [[static]];

struct ConnectionBlockv2 {
    ConnSource usSource;
    ConnSource usControl;
    ConnDestination usDestination;
    ConnTransformv2 usTransform;
    s32 lScale;
} [[static]];

bitfield WlnkOptions {
    bool PhaseMaster : 1;
    bool Multichannel : 1;
    padding : 14;
};

using WlnkChannel = type::WlnkChannel; // provided by type.mmreg

bitfield WsmpOptions {
    NoTruncation : 1;
    NoCompression : 1;
    padding : 30;
};

enum LoopType : u32 {
    Forward = 0,
    Release = 1  // Loop and Release
};

struct WavesampleLoop {
    u32 cbSize;
    LoopType ulLoopType;
    u32 ulLoopStart;
    u32 ulLoopLength;
    // padding[cbSize-($-addressof(cbSize))];
} [[static]];

using TypewFormatTag = type::TypewFormatTag; // provided by type.mmreg

struct WAVEFORMAT {
    type::TypewFormatTag wfmt = std::mem::read_unsigned($, 2, std::core::get_endian());
    
    if (wfmt == TypewFormatTag::WAVE_FORMAT_PCM) {
        type::PCMWAVEFORMAT fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_ALAW || wfmt == TypewFormatTag::WAVE_FORMAT_MULAW) {
        type::WAVEFORMAT fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_EXTENSIBLE || wfmt == TypewFormatTag::WAVE_FORMAT_IEEE_FLOAT) {
        type::WAVEFORMATEXTENSIBLE fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_ADPCM) {
        type::ADPCMWAVEFORMAT fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_IMA_ADPCM) {
        type::IMAADPCMWAVEFORMAT fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_MPEG) {
        type::MPEG1WAVEFORMAT fmt;
    } else if (wfmt == TypewFormatTag::WAVE_FORMAT_MPEGLAYER3) {
        type::MPEGLAYER3WAVEFORMAT fmt;
    } else {
        type::WAVEFORMAT fmt;
        std::warning(std::format("Unsupported wFormatTag: 0x{:X}", u16(wfmt)));
    }
};

enum CdlOpcode : u16 {
    And = 0x0001,
    Or = 0x0002,
    Xor = 0x0003,
    Add = 0x0004,
    Subtract = 0x0005,
    Multiply = 0x0006,
    Divide = 0x0007,
    LogicalAnd = 0x0008,
    LogicalOr = 0x0009,
    LessThan = 0x000A,
    LessEqual = 0x000B,
    GreaterThan = 0x000C,
    GreaterEqual = 0x000D,
    Equal = 0x000E,
    Not = 0x000F,
    Const = 0x0010,
    Query = 0x0011,
    QuerySupported = 0x0012
};

enum CdlDLSID : u128 {
    GMInHardware = "DLSID_GMInHardware"_u128guid(0x178f2f24, 0xc364, 0x11d1, 0xa7, 0x60, 0x00, 0x00, 0xf8, 0x75, 0xac, 0x12),
    GSInHardware = "DLSID_GSInHardware"_u128guid(0x178f2f25, 0xc364, 0x11d1, 0xa7, 0x60, 0x00, 0x00, 0xf8, 0x75, 0xac, 0x12),
    XGInHardware = "DLSID_XGInHardware"_u128guid(0x178f2f26, 0xc364, 0x11d1, 0xa7, 0x60, 0x00, 0x00, 0xf8, 0x75, 0xac, 0x12),
    SupportsDLS1 = "DLSID_SupportsDLS1"_u128guid(0x178f2f27, 0xc364, 0x11d1, 0xa7, 0x60, 0x00, 0x00, 0xf8, 0x75, 0xac, 0x12),
    SupportsDLS2 = "DLSID_SupportsDLS2"_u128guid(0xf14599e5, 0x4689, 0x11d2, 0xaf, 0xa6, 0x0, 0xaa, 0x0, 0x24, 0xd8, 0xb6),
    SampleMemorySize = "DLSID_SampleMemorySize"_u128guid(0x178f2f28, 0xc364, 0x11d1, 0xa7, 0x60, 0x00, 0x00, 0xf8, 0x75, 0xac, 0x12),
    ManufacturersID = "DLSID_ManufacturersID"_u128guid(0xb03e1181, 0x8095, 0x11d2, 0xa1, 0xef, 0x0, 0x60, 0x8, 0x33, 0xdb, 0xd8),
    ProductID = "DLSID_ProductID"_u128guid(0xb03e1182, 0x8095, 0x11d2, 0xa1, 0xef, 0x0, 0x60, 0x8, 0x33, 0xdb, 0xd8),
    SamplePlaybackRate = "DLSID_SamplePlaybackRate"_u128guid(0x2a91f713, 0xa4bf, 0x11d2, 0xbb, 0xdf, 0x0, 0x60, 0x8, 0x33, 0xdb, 0xd8)
};

struct CdlOperation {
    CdlOpcode opcode;
    if (opcode == CdlOpcode::Const) {
        u32 constant;
    } else if (opcode == CdlOpcode::Query || opcode == CdlOpcode::QuerySupported) {
        CdlDLSID query;
    }
};

// "cue " just happened to exist in Samsung's DLSs
struct WaveCuePoint {
    u32 indentifier;
    u32 position;
    ChunkID chunkID;
    u32 chunkStart;
    u32 blockStart;
    u32 sampleOffset;
} [[static]];

using Chunk;

struct Chunk {
    ChunkHeader header;
    u64 endaddr = addressof(header)+sizeof(header)+header.size; // past-the-end address
    if (header.chunkID == ChunkID::RIFF) {
        ChunkID riffType;
        Chunk chunks[while(endaddr-$ > 1)];
    } else if (header.chunkID == ChunkID::LIST) {
        ChunkID listType;
        if (!std::core::is_valid_enum(listType)) {
            char fmt[4] @ addressof(listType) [[hidden]];
            std::warning(std::format("Unknown LIST type: 0x{:X} \"{}\"", u32(listType), fmt));
        }
        Chunk data[while(endaddr-$ > 1)];
    } else if (u32(header.chunkID) & 0xFF == 0x49) { // begin with I
        char zstr[];
    } else if (header.chunkID == ChunkID::colh) {
        u32 cInstruments;
    } else if (header.chunkID == ChunkID::dlid) {
        type::GUID dlsid;
    } else if (header.chunkID == ChunkID::insh) {
        u32 cRegions;
        MIDILocale locale;
    } else if (header.chunkID == ChunkID::rgnh) {
        RgnRange rangeKey;
        RgnRange rangeVelocity;
        RgnhOptions fusOptions;
        u16 usKeyGroup;
    } else if (header.chunkID == ChunkID::art1) {
        u32 cbSize;
        u32 cConnectionBlocks;
        padding[cbSize-($-addressof(cbSize))];
        ConnectionBlockv1 connectionBlocks[cConnectionBlocks];
    } else if (header.chunkID == ChunkID::art2) {
        u32 cbSize;
        u32 cConnectionBlocks;
        padding[cbSize-($-addressof(cbSize))];
        ConnectionBlockv2 connectionBlocks[cConnectionBlocks];
    } else if (header.chunkID == ChunkID::wlnk) {
        WlnkOptions fusOptions;
        u16 usPhaseGroup;
        WlnkChannel ulChannel;
        u32 ulTableIndex;
    } else if (header.chunkID == ChunkID::wsmp) {
        u32 cbSize;
        u16 usUnityNote;
        s16 sFineTune;
        s32 lAttenuation;
        WsmpOptions fulOptions;
        u32 cSampleLoops;
        padding[cbSize-($-addressof(cbSize))];
        WavesampleLoop sampleLoops[cSampleLoops];
    } else if (header.chunkID == ChunkID::ptbl) {
        u32 cbSize;
        u32 cCues;
        padding[cbSize-($-addressof(cbSize))];
        u32 poolcues[cCues];
    } else if (header.chunkID == ChunkID::vers) {
        u32 dwVersionMS;
        u32 dwVersionLS;
    } else if (header.chunkID == ChunkID::fmt) {
        WAVEFORMAT format;
    } else if (header.chunkID == ChunkID::data) {
        u8 data[header.size];
    } else if (header.chunkID == ChunkID::cdl) {
        CdlOperation operations[while(endaddr-$ > 1)];
    } else if (header.chunkID == ChunkID::cue) {
        u32 nCuePoints;
        WaveCuePoint cuePoints[nCuePoints];
    } else if (header.chunkID == ChunkID::labl || header.chunkID == ChunkID::note) {
        u32 cuepointID;
        char zstr[];
    } else if (header.chunkID == ChunkID::fact) {
        u32 dwSamples;
    } else {
        char fmt[4] @ addressof(header.chunkID) [[hidden]];
        std::warning(std::format("Unknown chunk ID: 0x{:X} \"{}\"", u32(header.chunkID), fmt));
    }
    try {
        padding[header.size-($-(addressof(header)+sizeof(header)))];
    } catch {
        std::warning(std::format("Failed to place chunk: computed size {} bigger than actual {}", $-(addressof(header)+sizeof(header)), header.size));
        std::error("Failed to place chunk");
    }
    if ($ % 2 != 0) {
        padding[1];
    }
};

Chunk riff @ 0x00;