#pragma author Lautaro Martínez (PentaChess413)
#pragma description A pattern for FL Studio project files

#pragma MIME application/x-fruityloops
#pragma MIME application/x-flp
#pragma magic "FLhd" @ 0x00;

#pragma version 1.0 "First version for public release"
// Tested on an FL Studio 12.x file by stormstudios1 (once upon a time.flp)
/* For adding something (if you're a forgetful me or a community dev wanting to help):
FourCC codes are:
ILFL - Image-Line FL Studio, generic stuff
CHAN - CHANnel related stuff
MIXR - MIXeR
PATT - PATTern
ARNG - ARraNGement
PROJ - PROJect
PLUG - PLUG-in (generic)
Plugin FourCC are (keep in mind these structs can be used in other patterns for other DAWs and preset snapshots, like Ableton, Pro Tools or whatever you use):
ILFL - Image-Line FL Studio, Image-Line built-in plugin
LENN - LENNarDigital, only used for Sylenth1 so far

*/
// With thanks to: The DawVert project and demberto's PyFLP tool (last one's sadly abandoned)
// Bad news everybody! I can't get the VST flags to behave sanely so you're gonna have to place them patterns manually!
#pragma array_limit 10000000000000000

import std.mem;
import std.core;
import std.string;
import type.leb128;
import type.magic;

fn StripFLString(str value) {
    str result;
    u64 len = std::string::length(value);  
  
    for (u64 i = 0, i < len, i += 1) {  
        char c = std::string::at(value, i);  
        if (c != 0x00)  
            result += c;  
    }  
  
    return result;  
};

struct FLHeader {
    type::Magic<"FLhd"> magic;          // 'FLhd'
    u32 size;          // always been 6
    s16 format;         // Internal file format
    s16 num_channels;  // Number of channels in channel rack
    s16 ppq;           // Pulses per quarter
};

struct FLData {
    type::Magic<"FLdt"> magic;  // 'FLdt'
    u16 size;  // Total combined size of events
    u16 events;   // Event data
};

enum FLEventType : u8 {
    CHANEnabled,
    CHANNoteOn,
    ILFLMIDIChan = 4,
    PROJLoopActive = 9,
    PROJShowInfo,
    CHANRackSwing,
    ILFLDelayFlags = 16,
    ARNGTimeSigNum,
    ARNGTimeSigBeat,
    CHANPingPongLoop = 20,
    CHANType,
    CHANRoutedTo,
    PROJPanLaw,
    PROJLicense = 28,
    PLUGAPDC,
    PATTTruncatedNotes,
    CHANEEAutoMode,
    CHANLock,
    CHANNew = 64,
    PATTNew,
    PATTCurrent = 67,
    CHANFreqTilt = 69,
    CHANFXFlags,
    CHANCutoff,
    CHANPreamp = 74,
    CHANFadeOut,
    CHANFadeIn,
    PROJPitch = 80,
    CHANResonance = 83,
    CHANStereoDelay = 85,
    CHANPogo,
    CHANTimeShift = 89,
    PROJLoopEndBar,
    CHANSwing = 97,
    MIXRIndex,
    PLUGColor = 128,
    CHANRingMod = 131,
    CHANCutGroup,
    CHANWindowHeight,
    CHANDelayModXYTuple = 138,
    CHANReverb,
    CHANSampFlags = 143,
    CHANLayerFlags,
    CHANGroupNum,
    PROJCurGroup,
    MIXROutput,
    MIXRColor = 149,
    MIXRInput = 154,
    PLUGIcon,
    PROJTempo,
    ILFLUnk173 = 173,
    PROJTitle = 194,
    PROJComments,
    CHANSampPath,
    PROJCommentsRich = 198,
    PROJVersion,
    PROJLicensee,
    PLUGInternalName,
    PROJDataPath,
    PLUGName,
    MIXRName,
    PROJGenre = 206,
    PROJArtists,
    CHANDelay = 209,
    PLUGWrapper = 212,
    PLUGData,
    CHANParams = 215,
    CONTRecChan,
    CHANEnvelopeLFO = 218,
    CHANLevels,
    CHANPolyphony = 221,
    PATTControllers = 223, // CHANLegacyAutomation
    PATTNotes,
    MIXRParams,
    CONTMidiContEvents,
    CONTRemoteContEvents,
    CHANTracking,
    CHANLevelAdjusts,
    CONTRemoteContFormula,
    CHANGroupName,
    ARNGPlaylist = 233,
    CHANAutomation,
    MIXRInsertRouting,
    MIXRInsertFlags,
    PROJTimestamp,
    ARNGTrack,
    ARNGName
};

struct PATTController {
    u32 position;
    u8 unk1;
    u8 unk2;
    u8 channel;
    u8 flags;
    float value;
};

enum PATTNoteFlags : u16 {
    PATTNoteNormal = 0,
    PATTNoteSlide = 8,
};

struct PATTNote {
    u32 position;
    PATTNoteFlags flags;
    u16 rackChan;
    u32 length;
    u16 key;
    u16 group;
    u8 finePitch;
    u8 unk1;
    u8 release;
    u8 midiChan;
    u8 pan;
    u8 velocity;
    u8 modX;
    u8 modY;
};

struct CHANDelay {
    u32 feedback;
    s32 pan;
    s32 pitchShift;
    u32 echoes;
    u32 time;
};

struct CHANEnvelopeLFO {
    s32 flags;
    s32 envelopeEnabled;
    s32 envelopePreDelay;
    s32 envelopeAttack;
    s32 envelopeHold;
    s32 envelopeDecay;
    s32 envelopeSustain;
    s32 envelopeRelease;
    s32 envelopeAmount;
    u32 lfoPreDelay;
    u32 lfoAttack;
    s32 lfoAmount;
    u32 lfoSpeed;
    s32 lfoShape;
    s32 envelopeAttackTension;
    s32 envelopeDecayTension;
    s32 envelopeReleaseTension;
};

struct CHANLegacyAutomation {
    u32 pos;
    u32 paramId;
    s32 paramVal;
};

struct CHANLevelAdjusts {
    s32 pan;
    u32 volume;
    s32 unk1;
    u32 modX;
    u32 modY;
};

struct CHANLevels {
    s32 pan;
    u32 volume;
    s32 pitchShift;
    u32 filterModX;
    u32 filterModY;
    u32 filterType;
};

// This is completely braindead and shouldn't be done anywhere but here
struct CHANParams<auto size> {
    if (($ - addressof(this)) < size) u8 unk1[9];
    if (($ - addressof(this)) < size) u8 removeDC;
    if (($ - addressof(this)) < size) u8 delayFlags;
    if (($ - addressof(this)) < size) u8 mainPitch;
    if (($ - addressof(this)) < size) u8 unk2[28];
    if (($ - addressof(this)) < size) u32 arpDir;
    if (($ - addressof(this)) < size) u32 arpRange;
    if (($ - addressof(this)) < size) u32 arpChord;
    if (($ - addressof(this)) < size) u32 arpTime;
    if (($ - addressof(this)) < size) u32 arpGate;
    if (($ - addressof(this)) < size) u32 arpSlide;
    if (($ - addressof(this)) < size) u8 unk3;
    if (($ - addressof(this)) < size) u8 fullPortamento;
    if (($ - addressof(this)) < size) u8 addRoot;
    if (($ - addressof(this)) < size) u16 timeGate;
    if (($ - addressof(this)) < size) u8 unk4[2];
    if (($ - addressof(this)) < size) u32 keyRegion[2];
    if (($ - addressof(this)) < size) u8 unk5[4];
    if (($ - addressof(this)) < size) u8 fxNormalize;
    if (($ - addressof(this)) < size) u8 fxInverted;
    if (($ - addressof(this)) < size) u8 unk6;
    if (($ - addressof(this)) < size) u8 declickMode;
    if (($ - addressof(this)) < size) u32 crossfade;
    if (($ - addressof(this)) < size) u32 trim;
    if (($ - addressof(this)) < size) u32 arpRepeat;
    if (($ - addressof(this)) < size) u32 stretchTime;
    if (($ - addressof(this)) < size) s32 stretchPitch;
    if (($ - addressof(this)) < size) s32 stretchMul;
    if (($ - addressof(this)) < size) u8 unk7_0;  
    if (($ - addressof(this)) < size) u8 unk7_1;  
    if (($ - addressof(this)) < size) u8 unk7_2;  
    if (($ - addressof(this)) < size) u8 unk7_3;  
    if (($ - addressof(this)) < size) u8 unk7_4;  
    if (($ - addressof(this)) < size) u8 unk7_5;  
    if (($ - addressof(this)) < size) u8 unk7_6;  
    if (($ - addressof(this)) < size) u8 unk7_7;  
    if (($ - addressof(this)) < size) u8 unk7_8;  
    if (($ - addressof(this)) < size) u8 unk7_9;  
    if (($ - addressof(this)) < size) u8 unk7_10;  
    if (($ - addressof(this)) < size) u8 unk7_11;  
    if (($ - addressof(this)) < size) u8 unk7_12;  
    if (($ - addressof(this)) < size) u8 unk7_13;  
    if (($ - addressof(this)) < size) u8 unk7_14;  
    if (($ - addressof(this)) < size) u8 unk7_15;  
    if (($ - addressof(this)) < size) u8 unk7_16;  
    if (($ - addressof(this)) < size) u8 unk7_17;  
    if (($ - addressof(this)) < size) u8 unk7_18;  
    if (($ - addressof(this)) < size) u8 unk7_19;  
    if (($ - addressof(this)) < size) u8 unk7_20;  
    if (($ - addressof(this)) < size) u16 fxStart[2];
    if (($ - addressof(this)) < size) u8 unk8[4];
    if (($ - addressof(this)) < size) u16 fxLen[2];
    if (($ - addressof(this)) < size) u8 unk9[3];
    if (($ - addressof(this)) < size) u32 playStartOffset;
    if (($ - addressof(this)) < size) u8 unk10[3];
};


struct CHANPolyphony {
    u32 max;
    u32 slide;
    u8 flags;
};

struct CHANTrack {
    u32 middleValue;
    s32 pan;
    s32 modX;
    s32 modY;
};

struct PROJTimestamp {
    double createdTime;
    double spentTime;
};

struct CONTRemoteContEvent {
    u8 unk1[2];
    u8 unk2;
    u8 unk3;
    u16 paramData;
    s16 destData;
    u8 unk4[8];
    u8 unk5[4];
};

enum PLUGWrapperPage : u8 {
    Editor        = 0,
    Settings      = 1,
    Sample        = 3,
    Envelope      = 4,
    Miscellaneous = 5
};

bitfield PLUGFlags {  
    unsigned PLUGSendPBRange : 1;  
    unsigned PLUGFixedSizeBuffers : 1;  
    unsigned PLUGNotifyRender : 1;  
    unsigned PLUGProcessInactive : 1;  
    padding : 1;  // bit 4  
    unsigned PLUGDontSendRelVelo : 1;  
    unsigned PLUGDontNotifyChanges : 1;  
    padding : 4;  // bits 7-10  
    unsigned PLUGSendLoopPos : 1;  
    unsigned PLUGAllowThreaded : 1;  
    padding : 2;  // bits 13-14  
    unsigned PLUGKeepFocus : 1;  
    unsigned PLUGDontKeepCPUState : 1;  
    unsigned PLUGSendModX : 1;  
    unsigned PLUGLoadBridged : 1;  
    padding : 2;  // bits 19-20  
    unsigned PLUGExternalWindow : 1;  
    padding : 1;  // bit 22  
    unsigned PLUGUpdateWhenHidden : 1;  
    padding : 1;  // bit 24  
    unsigned PLUGDontResetOnTransport : 1;  
    unsigned PLUGDPIAwareBridged : 1;  
    padding : 1;  // bit 27  
    unsigned PLUGAcceptFileDrop : 1;  
    unsigned PLUGAllowSmartDisable : 1;  
    unsigned PLUGScaleEditor : 1;  
    unsigned PLUGDontUseTimeOffset : 1;  
};

bitfield PLUGFlags2 {
    PLUGProcessMaxSize : 1;
    PLUGUseMaxFromHost : 1;
    padding : 30;
};

bitfield PLUGWrapperFlags {
    PLUGVisible             : 1;  // bit 0
    PLUGDisabled            : 1;  // bit 1
    PLUGDetached            : 1;  // bit 2
    PLUGUnk1                : 1;  // bit 3
    PLUGGenerator           : 1;  // bit 4
    PLUGSmartDisable        : 1;  // bit 5
    PLUGThreadedProcessing  : 1;  // bit 6
    PLUGDemoMode            : 1;  // bit 7
    PLUGHideSettings        : 1;  // bit 8
    PLUGMinimized           : 1;  // bit 9
};

enum PLUGDataVSTEventID : u32 {
    MIDI = 1,
    Flags,
    /*IO = 30,
    Inputs,
    Outputs,*/
    PluginInfo = 50,
    FourCC,  
    GUID,
    State,
    Name,
    PluginPath,
    Vendor 
};

enum PLUGType : u32 {
    VST2FX,
    VST2Synth = 4,
    VST3FX = 7,
    VST3Synth,
    CLAPFX = 11,
    CLAPSynth
};

struct PLUGDataVSTMIDI {
    u32 chunkSize;
    u32 skip;
    s32 inp;
    s32 outp;
    u32 pbRange;
    u8 extra[chunkSize - 12];
};

struct PLUGDataVSTFlags {
    u32 chunkSize;
    u32 skip;
    u8 unk1[9];
    PLUGFlags flags;
    PLUGFlags2 flags2;
    u8 unk2[5];
    u8 fastIdle;
    u8 extra[chunkSize - 23];
};

struct PLUGDataVSTState {
    u32 chunkSize;
    u32 skip;
    u8 stateHeader[9];  
    u32 vstSize;
    u32 vstPad;
    u32 vstProgram;
    u8 vstData[chunkSize - 21];
};

struct PLUGDataVSTInfo {
    u32 chunkSize;
    u32 skip;
    PLUGType pluginType;
    u8 pad[chunkSize - 4];
};

u32 vstDataSize = 0;
struct PLUGDataVSTEvent {
    PLUGDataVSTEventID bytes;
    match (bytes) {
        (PLUGDataVSTEventID::MIDI): {
            PLUGDataVSTMIDI midi;
        }
        (PLUGDataVSTEventID::Flags): {
            PLUGDataVSTFlags flags;
        }
        (PLUGDataVSTEventID::GUID): u8 guid[16];
        (PLUGDataVSTEventID::State): {
            PLUGDataVSTState state;
        }
        (PLUGDataVSTEventID::FourCC | PLUGDataVSTEventID::PluginPath | PLUGDataVSTEventID::Name | PLUGDataVSTEventID::Vendor): {
            u32 chunkSize;
            u32 skip;
            char value[chunkSize];
        } 
        (PLUGDataVSTEventID::PluginInfo): PLUGDataVSTInfo info;
        (_): {
            u32 chunkSize;
            u32 skip;
            u8 pad[chunkSize];
        }
    }
    vstDataSize += sizeof(this);
};

struct PLUGDataVST<auto size> {
    u32 type;
    std::print("Struct size (FL): {}", size - 4);
    PLUGDataVSTEvent data[while(vstDataSize < (size - 4))];
};

struct PLUGWrapperEvent<auto extraLen> {
    u8 unk1[16];
    PLUGWrapperFlags flags;
    u8 unk2[2];
    PLUGWrapperPage page;
    u8 unk3[23];
    u32 width;
    u32 height;
    u8 extra[extraLen - sizeof(this)];
};

struct ARNGPlaylistEvent {  
    u32 position; // 4  
    u16 patternBase; // 6, Always 20480  
    u16 itemIndex; // 8  
    u32 length; // 12  
    u16 trackRvidx; // 14, Stored reversed i.e. Track 1 would be 499  
    u16 group; // 16  
    u8 u1[2]; // 18, Always (120, 0)  
    u16 itemFlags; // 20, Always (64, 0)  
    u8 u2[4]; // 24, Always (64, 100, 128, 128)  
    float startOffset; // 28  
    float endOffset; // 32  
    // u8 u3[28]; // 60, New in FL 21 - conditional field  
};

struct ARNGTrack<auto size> {
    if (($ - addressof(this)) < size) u32 iid;
    if (($ - addressof(this)) < size) u32 color;
    if (($ - addressof(this)) < size) u32 icon;
    if (($ - addressof(this)) < size) u8 enabled;
    if (($ - addressof(this)) < size) float height;
    if (($ - addressof(this)) < size) s32 lockedHeight;
    if (($ - addressof(this)) < size) u8 contentLock;
    if (($ - addressof(this)) < size) u32 motion;
    if (($ - addressof(this)) < size) u32 press;
    if (($ - addressof(this)) < size) u32 trigSync;
    if (($ - addressof(this)) < size) u32 queued;
    if (($ - addressof(this)) < size) u32 tolerant;
    if (($ - addressof(this)) < size) u32 posSync;
    if (($ - addressof(this)) < size) u8 grouped;
    if (($ - addressof(this)) < size) u8 flag;
    if (($ - addressof(this)) < size) u8 extra[size - sizeof(this)];
};

bitfield MIXRInsertFlags {  
    unsigned polarityReversed : 1;      // bit 0  
    unsigned swapLeftRight : 1;          // bit 1  
    unsigned enableEffects : 1;           // bit 2  
    unsigned enabled : 1;                // bit 3  
    unsigned disableThreadedProcessing : 1;  // bit 4  
    unsigned unk5 : 1;                     // bit 5  
    unsigned dockMiddle : 1;              // bit 6  
    unsigned dockRight : 1;               // bit 7 
};
 
bitfield MIXRInsertFlags_0 { 
    unsigned unk8 : 1;                    // bit 8  
    unsigned unk9 : 1;                    // bit 9  
    unsigned separatorShown : 1;        // bit 10  
    unsigned locked : 1;                // bit 11  
    unsigned solo : 1;                  // bit 12  
    unsigned unk13 : 1;                   // bit 13  
    unsigned unk14 : 1;                   // bit 14  
    unsigned audioTrack : 1;             // bit 15  
};

struct MIXRInsertParams<auto size> {
    if (($ - addressof(this)) < size) u32 unk1;
    if (($ - addressof(this)) < size) MIXRInsertFlags flags;
    if (($ - addressof(this)) < size) MIXRInsertFlags_0 flags2;
    if (($ - addressof(this)) < size) u16 pad;
    if (($ - addressof(this)) < size) u32 unk2;
};

struct MIXRParams {
  u32 unk1;
  u8 id;
  u8 unk2;
  u16 chanData;
  s32 msg;  
};

struct ILFLStereoShaper {
    u32 unk0;
    s32 rightToLeft;
    s32 leftToLeft;
    s32 rightToRight;
    s32 leftToRight;
    s32 delay;
    s32 dephase;
    s32 ioDiff;
    s32 prepost;
};

struct ILFLLimiter {
    u32 unk0;
    u32 gain;
    u32 sat;
    u32 limiterCeil;
    u32 limiterAtt;
    u32 limiterAttCurve;
    u32 limiterRel;
    u32 limiterRelCurve;
    u32 limiterSus;
    u32 compThreshold;
    u32 compKnee;
    u32 compRation;
    u32 compAtt;
    u32 compRel;
    u32 compAttCurve;
    u32 compSus;
    u32 noiseGain;
    u32 noiseThreshold;
    u32 noiseRelease;
    u32 sGain;
    u32 sSat;
    u32 sLimiterCeil;
    u32 sLimiterAtt;
    u32 sLimiterAttCurve;
    u32 sLimiterRel;
    u32 sLimiterRelCurve;
    u32 sLimiterSus;
    u32 sCompThreshold;
    u32 sCompKnee;
    u32 sCompRation;
    u32 sCompAtt;
    u32 sCompRel;
    u32 sCompAttCurve;
    u32 sCompSus;
    u32 sNoiseGain;
    u32 sNoiseThreshold;
    u32 sNoiseRelease;
    u8 visualScrollSpeed;
    u8 unk1[3];
    u8 mode;
    u8 unk2[3];
    u8 visualInputPeak;
    u8 visualOutputPeak;
    u8 visualAnalysis;
    u8 visualLvlMarker;
    u8 unk3[4];
    u8 sidechainNumber;
    u8 unk4[2];
    u8 limiterSafety;
};

struct ILFLParametricEQ2<auto length>
{
    u32 version;
    s32 gain[7];
    u32 freq[7];
    u32 width[7];
    u32 type[7];
    s32 order[7];
    s32 mainLvl;
    u8 extra[length - sizeof(this)];
};

enum LENNArpMode : float {
    Chord      = 0x00003F80,
    Down       = 0x3DE38E39,
    Down_Up    = 0x3EE38E39,
    Down_Up2   = 0x3F0E38E4,
    Ordered    = 0x3F471C72,
    Random     = 0x3F2AAAAB,
    Step       = 0x3F638E39,
    Up         = 0x00000000,
    Up_Down    = 0x3E638E39,
    Up_Down2   = 0x3EAAAAAB
};

enum LENNArpVelo : float {
    VEL_Key        = 0x00000000,
    VEL_Hold       = 0x3E800000,
    VEL_Step       = 0x3F000000,
    VEL_StepKey    = 0x3F400000,
    VEL_StepHold   = 0x3F800000
};

enum LENNChorusMode : float {
    Dual    = 0x3F800000,
    Single  = 0x00000000
};

enum LENNOnOff : float {
    On    = 0x3F800000,
    Off  = 0x00000000
};

enum LENNPortaMode : float {
    On    = 0x3F800000,
    Off  = 0x00000000
};

enum LENNDistortType : float {
    OverDrv        = 0x00000000,
    FoldBack       = 0x3E800000,
    Clip       = 0x3F000000,
    Decimate    = 0x3F400000,
    BitCrush   = 0x3F800000
};

enum LENNFilterAInput : float {
    FILTER_A      = 0x00000000,
    FILTER_A_B    = 0x3F000000,
    FILTER_A_None = 0x3F800000
};

enum LENNFilterBInput : float {
    FILTER_A      = 0x00000000,
    FILTER_A_B    = 0x3F000000,
    FILTER_A_None = 0x3F800000
};

enum LENNFilterType : float {
    Highpass= 0x3F800000,
    Bandpass= 0x3F2AAAAB,
    Lowpass = 0x3EAAAAAB,
    Bypass  = 0x00000000,
};

enum LENNLFOWave : float {
    LFO_HPulse    = 0x3F000000,
    LFO_Lorenz    = 0x3F4CCCCD,
    LFO_Pulse     = 0x3ECCCCCD,
    LFO_QPulse    = 0x3F19999A,
    LFO_Ramp      = 0x844445CC,
    LFO_Ramp2     = 0xCCCD3E4C,
    LFO_Random    = 0x3F800000,
    LFO_Saw       = 0x3DCCCCCD,
    LFO_Sine      = 0x00000000,
    LFO_SmpHold   = 0x3F666666,
    LFO_Triangle  = 0x3E99999A,
    LFO_TriSaw    = 0x3F333333
};

enum LENNVoices : float {
    LENNVoices_0       = 0x00000000,
    LENNVoices_1       = 0x3E000000,
    LENNVoices_2       = 0x3E800000,
    LENNVoices_3       = 0x3EC00000,
    LENNVoices_4       = 0x3F000000,
    LENNVoices_5       = 0x3F200000,
    LENNVoices_6       = 0x3F400000,
    LENNVoices_7       = 0x3F600000,
    LENNVoices_8       = 0x3F800000
};

enum LENNOscWave : float {
    OSC_HPulse   = 0x3F124925,
    OSC_Noise    = 0x3F800000,
    OSC_Pulse    = 0x3EDB6DB7,
    OSC_QPulse   = 0x3F36DB6E,
    OSC_Saw      = 0x3E124925, 
    OSC_Sine     = 0x00000000,
    OSC_Triangle = 0x3E924925,
    OSC_TriSaw   = 0x3F5B6DB7
};


enum LENNXMODSource : float {
    SOURCE_None     = 0x00000000,
    SOURCE_Velocity = 0x3DBA2E8C,
    SOURCE_ModWheel = 0x3E3A2E8C,
    SOURCE_KeyTrack = 0x3E8BA2E9,
    SOURCE_AmpEnv_A = 0x3EBA2E8C,
    SOURCE_AmpEnv_B = 0x3EE8BA2F,
    SOURCE_ModEnv_1 = 0x3F0BA2E9,
    SOURCE_ModEnv_2 = 0x3F22E8BA,
    SOURCE_LFO_1    = 0x3F3A2E8C,
    SOURCE_LFO_2    = 0x3F51745D,
    SOURCE_Aftertch = 0x3F68BA2F,
    SOURCE_StepVlty = 0x3F800000,
};

enum LENNYMODDest : float {
    None        = 0x00000000,

    // Oscillators
    Volume_A    = 0x3D000000,
    Volume_B    = 0x3D800000,
    VolumeAB    = 0x3DC00000,  
    Pitch_A     = 0x3E000000,
    Pitch_B     = 0x3E200000,
    Pitch_AB    = 0x3E400000,
    Phase_A     = 0x3E600000,
    Phase_B     = 0x3E800000,
    Phase_AB    = 0x3E900000,
    Pan_A       = 0x3EA00000,
    Pan_B       = 0x3EB00000,
    Pan_AB      = 0x3EC00000,

    // Filters
    Cutoff_A    = 0x3ED00000,
    Cutoff_B    = 0x3EE00000,
    CutoffAB    = 0x3EF00000,
    Reso_A      = 0x3F000000, 
    Reso_B      = 0x3F080000,
    Reso_AB     = 0x3F100000,

    // Misc
    PhsrFreq    = 0x3F180000,
    Mix_A       = 0x3F200000,
    Mix_B       = 0x3F280000,
    Mix_AB      = 0x3F300000,
    LFO1Rate    = 0x3F380000,
    LFO1Gain    = 0x3F400000,
    LFO2Rate    = 0x3F480000,
    LFO2Gain    = 0x3F500000,
    DistAmnt    = 0x3F580000
};

enum LENNYPartSelect : float {
    Part_A = 0x00000000,
    Part_B = 0x3F800000
};

struct LENNSylenth1Program
{
    float ampEnvAAttack;
    float ampEnvADecay;               // index 24:27 (value range 0 -> 10)
    float ampEnvARelease;             // index 28:31 (value range 0 -> 10)
    float ampEnvASustain;             // index 32:35 (value range 0 -> 10)
    float ampEnvBAttack;              // index 36:39 (value range 0 -> 10)
    float ampEnvBDecay;               // index 40:43 (value range 0 -> 10)
    float ampEnvBRelease;             // index 44:47 (value range 0 -> 10)
    float ampEnvBSustain;             // index 48:51 (value range 0 -> 10)
    float arpGate;                    // index 52:55 (value range 0 -> 100)
    LENNArpMode arpMode;
    float arpOctave;                  // index 60:63 (value range 1 -> 4)
    float arpTime;                    // index 64:67 (value range 1/1 -> 1/64)
    LENNArpVelo arpVelo;
    float arpWrap;                    // index 72:75 (value range 0 -> 16)
    float chorusDelay;                // index 76:79 (value range 1 -> 40)
    float chorusDepth;                // index 80:83 (value range 0 -> 100)
    float chorusDryWet;              // index 84:87 (value range 0 -> 100)
    float chorusFeedback;             // index 88:91 (value range 0 -> 100)
    LENNChorusMode chorusMode; 
    float chorusRate;                 // index 96:99 (value range 0,01 -> 27,5)
    float chorusWidth;                // index 100:103 (value range 0 -> 100)
    float compAttack;                 // index 104:107 (value range 0,1 -> 300)
    float compRatio;                  // index 108:111 (value range 1.00:1 -> 100.00:1)
    float compRelease;                // index 112:115 (value range 1 -> 500)
    float compThreshold;              // index 116:119 (value range -30 -> 0)
    float delayDryWet;               // index 120:123 (value range 0 -> 100)
    float delayFeedback;              // index 124:127 (value range 0 -> 100)
    float delayHighCut;               // index 128:131 (value range 82,5 -> 21120)
    float delayLowCut;                // index 132:135 (value range 3,23 -> 26483,12)
    LENNOnOff delayPingPong;
    float delaySmear;                 // index 140:143 (value range 0 -> 10)
    float delaySpread;                // index 144:147 (value range 0 -> 100)
    float delayTimeLeft;              // index 148:151 (value range 1/64 -> 1/2)
    float delayTimeRight;             // index 152:155 (value range 1/64 -> 1/2)
    float delayWidth;                 // index 156:159 (value range 0 -> 100)
    float distortAmount;              // index 160:163 (value range 0 -> 10)
    float distortDryWet;              // index 164:167 (value range 0 -> 100)
    LENNDistortType distortType;
    float eqBass;                     // index 172:175 (value range 0 -> 15)
    float eqBassFreq;                 // index 176:179 (value range 13,75 -> 880)
    float eqTreble;                   // index 180:183 (value range 0 -> 15)
    float eqTrebleFreq;               // index 184:187 (value range 440 -> 28160)
    float filterACutoff;              // index 188:191 (value range 1 -> 21341,28)
    float filterADrive;               // index 192:195 (value range 0 -> 10)
    LENNFilterAInput filterAInput;         // index 198:199 
    float filterAReso;                // index 200:203 (value range 0 -> 10)
    LENNFilterType filterAType;           // index 204:207 
    float filterADB;                  // index 210:211 (value range 12 -> 12)
    float filterBCutoff;              // index 212:215 (value range 1 -> 21341,28)
    float filterBDrive;               // index 216:219 (value range 0 -> 10)
    LENNFilterBInput filterBInput;         // index 222:223 
    float filterBReso;                // index 224:227 (value range 0 -> 10)
    LENNFilterType filterBType;           // index 228:231 
    float filterBDB;                  // index 234:235 (value range 12 -> 24)
    float filterCtlCutoff;            // index 236:239 (value range 1 -> 21341,28)
    float filterCtlKeyTrk;            // index 240:243 (value range 0 -> 10)
    float filterCtlReso;              // index 244:247 (value range 0 -> 10)
    LENNOnOff filterCtlWarmDrive;         // index 250:251 
    LENNOnOff lfo1Free;                   // index 254:255 
    float lfo1Gain;                   // index 256:259 (value range 0 -> 10)
    float lfo1Offset;                 // index 260:263 (value range -10 -> 10)
    float lfo1Rate;                   // index 264:267 (value range 8/1D -> 1/256T)
    LENNLFOWave lfo1Wave;                 // index 268:271 
    LENNOnOff lfo2Free;                   // index 274:275 
    float lfo2Gain;                   // index 276:279 (value range 0 -> 10)
    float lfo2Offset;                 // index 280:283 (value range -10 -> 10)
    float lfo2Rate;                   // index 284:287 (value range 8/1D -> 1/256T)
    LENNLFOWave lfo2Wave;                 // index 288:291 
    float mainVolume;                 // index 292:295 (value range 0 -> 10)
    float mixA;                       // index 296:299 (value range 0 -> 10)
    float mixB;                       // index 300:303 (value range 0 -> 10)
    float modEnv1Attack;              // index 304:307 (value range 0 -> 10)
    float modEnv1Decay;               // index 308:311 (value range 0 -> 10)
    float modEnv1Release;             // index 312:315 (value range 0 -> 10)
    float modEnv1Sustain;             // index 316:319 (value range 0 -> 10)
    float modEnv2Attack;              // index 320:323 (value range 0 -> 10)
    float modEnv2Decay;               // index 324:327 (value range 0 -> 10)
    float modEnv2Release;             // index 328:331 (value range 0 -> 10)
    float modEnv2Sustain;             // index 332:335 (value range 0 -> 10)
    float modWheel;                   // index 336:339 (value range 0 -> 10)
    LENNOnOff monoLegato;                 // index 342:343 
    float oscA1Detune;                // index 344:347 (value range 0 -> 10)
    float oscA1Fine;                  // index 348:351 (value range -1 -> 1)
    LENNOnOff oscA1Invert;                // index 354:355 
    float oscA1Note;                  // index 356:359 (value range -7 -> 7)
    float oscA1Octave;                // index 360:363 (value range -3 -> 3)
    float oscA1Pan;                   // index 364:367 (value range -10 -> 10)
    float oscA1Phase;                 // index 368:371 (value range 0 -> 360)
    LENNOnOff oscA1Retrig;                // index 374:375 
    float oscA1Stereo;                // index 376:379 (value range 0 -> 10)
    LENNVoices oscA1Voices;                // index 382:383 (value range 0 -> 8)
    float oscA1Volume;                // index 384:387 (value range 0 -> 10)
    LENNOscWave oscA1Wave;                // index 388:391 
    float oscA2Detune;                // index 392:395 (value range 0 -> 10)
    float oscA2Fine;                  // index 396:399 (value range -1 -> 1)
    LENNOnOff oscA2Invert;                // index 402:403 
    float oscA2Note;                  // index 404:407 (value range -7 -> 7)
    float oscA2Octave;                // index 408:411 (value range -3 -> 3)
    float oscA2Pan;                   // index 412:415 (value range -10 -> 10)
    float oscA2Phase;                 // index 416:419 (value range 0 -> 360)
    LENNOnOff oscA2Retrig;                // index 422:423 
    float oscA2Stereo;                // index 424:427 (value range 0 -> 10)
    LENNVoices oscA2Voices;                // index 430:431 (value range 0 -> 8)
    float oscA2Volume;                // index 432:435 (value range 0 -> 10)
    LENNOscWave oscA2Wave;                // index 436:439 
    float oscB1Detune;                // index 440:443 (value range 0 -> 10)
    float oscB1Fine;                  // index 444:447 (value range -1 -> 1)
    LENNOnOff oscB1Invert;                // index 450:451 
    float oscB1Note;                  // index 452:455 (value range -7 -> 7)
    float oscB1Octave;                // index 456:459 (value range -3 -> 3)
    float oscB1Pan;                   // index 460:463 (value range -10 -> 10)
    float oscB1Phase;                 // index 464:467 (value range 0 -> 360)
    LENNOnOff oscB1Retrig;                // index 470:471 
    float oscB1Stereo;                // index 472:475 (value range 0 -> 10)
    LENNVoices oscB1Voices;                // index 478:479 (value range 0 -> 8)
    float oscB1Volume;                // index 480:483 (value range 0 -> 10)
    LENNOscWave oscB1Wave;                // index 484:487 
    float oscB2Detune;                // index 488:491 (value range 0 -> 10)
    float oscB2Fine;                  // index 492:495 (value range -1 -> 1)
    LENNOnOff oscB2Invert;                // index 498:499 
    float oscB2Note;                  // index 500:503 (value range -7 -> 7)
    float oscB2Octave;                // index 504:507 (value range -3 -> 3)
    float oscB2Pan;                   // index 508:511 (value range -10 -> 10)
    float oscB2Phase;                 // index 512:515 (value range 0 -> 360)
    LENNOnOff oscB2Retrig;                // index 518:519 
    float oscB2Stereo;                // index 520:523 (value range 0 -> 10)
    LENNVoices oscB2Voices;                // index 526:527 (value range 0 -> 8)
    float oscB2Volume;                // index 528:531 (value range 0 -> 10)
    LENNOscWave oscB2Wave;                // index 532:535 
    float phaserCenterFreq;           // index 536:539 (value range 0 -> 10)
    float phaserDryWet;              // index 540:543 (value range 0 -> 100)
    float phaserFeedback;             // index 544:547 (value range 0 -> 100)
    float phaserLFOGain;              // index 548:551 (value range 0 -> 10)
    float phaserLFORate;              // index 552:555 (value range 8/1D -> 1/256T))
    float phaserLROffset;             // index 556:559 (value range -10 -> 10)
    float phaserSpread;               // index 560:563 (value range 0 -> 10)
    float phaserWidth;                // index 564:567 (value range 0 -> 100)
    float pitchBend;                  // index 568:571 (value range -10 -> 10)
    float pitchBendRange;             // index 572:575 (value range 1 -> 24)
    float polyphony;                  // index 578:579 (value range 0 -> 16)
    LENNPortaMode portaMode;              // index 582:583 
    float portaTime;                  // index 584:587 (value range 0 -> 10)
    float reverbDamp;                 // index 588:591 (value range 0 -> 10)
    float reverbDryWet;              // index 592:595 (value range 0 -> 100)
    float reverbPredelay;             // index 596:599 (value range 0 -> 200)
    float reverbSize;                 // index 600:603 (value range 0 -> 10)
    float reverbWidth;                // index 604:607 (value range 0 -> 100)
    LENNOnOff solo;                       // index 610:611 
    LENNOnOff sync;                       // index 614:615 
    LENNOnOff xArpHold01;                 // index 618:619 
    LENNOnOff xArpHold02;                 // index 622:623 
    LENNOnOff xArpHold03;                 // index 626:627 
    LENNOnOff xArpHold04;                 // index 630:631 
    LENNOnOff xArpHold05;                 // index 634:635 
    LENNOnOff xArpHold06;                 // index 638:639 
    LENNOnOff xArpHold07;                 // index 642:643 
    LENNOnOff xArpHold08;                 // index 646:647 
    LENNOnOff xArpHold09;                 // index 650:651 
    LENNOnOff xArpHold10;                 // index 654:655 
    LENNOnOff xArpHold11;                 // index 658:659 
    LENNOnOff xArpHold12;                 // index 662:663 
    LENNOnOff xArpHold13;                 // index 666:667 
    LENNOnOff xArpHold14;                 // index 670:671 
    LENNOnOff xArpHold15;                 // index 674:675 
    LENNOnOff xArpHold16;                 // index 678:679 
    float xArpTransp01;               // index 680:684 (value range -24 -> 24)
    float xArpTransp02;               // (value range -24 -> 24)
    float xArpTransp03;               // (value range -24 -> 24)
    float xArpTransp04;               // (value range -24 -> 24)
    float xArpTransp05;               // (value range -24 -> 24)
    float xArpTransp06;               // (value range -24 -> 24)
    float xArpTransp07;               // (value range -24 -> 24)
    float xArpTransp08;               // (value range -24 -> 14)
    float xArpTransp09;               // index 712:715 (value range -24 -> 24)
    float xArpTransp10;               // index 716:719 (value range -24 -> 24)
    float xArpTransp11;               // index 720:723 (value range -24 -> 24)
    float xArpTransp12;               // index 724:727 (value range -24 -> 24)
    float xArpTransp13;               // index 728:731 (value range -24 -> 24)
    float xArpTransp14;               // index 732:735 (value range -24 -> 24)
    float xArpTransp15;               // index 736:739 (value range -24 -> 24)
    float xArpTransp16;               // index 740:743 (value range -24 -> 14)
    float xArpVelo01;                 // (value range 0 -> 127)
    float xArpVelo02;                 // (value range 0 -> 127)
    float xArpVelo03;                 // (value range 0 -> 127)
    float xArpVelo04;                 // (value range 0 -> 127)
    float xArpVelo05;                 // (value range 0 -> 127)
    float xArpVelo06;                 // (value range 0 -> 127)
    float xArpVelo07;                 // (value range 0 -> 127)
    float xArpVelo08;                 // (value range 0 -> 127)
    float xArpVelo09;                 // index 776:779 (value range 0 -> 127)
    float xArpVelo10;                 // index 780:783 (value range 0 -> 127)
    float xArpVelo11;                 // index 784:787 (value range 0 -> 127)
    float xArpVelo12;                 // index 788:791 (value range 0 -> 127)
    float xArpVelo13;                 // index 792:795 (value range 0 -> 127)
    float xArpVelo14;                 // index 796:799 (value range 0 -> 127)
    float xArpVelo15;                 // index 800:803 (value range 0 -> 127)
    float xArpVelo16;                 // index 804:807 (value range 0 -> 127)
    float xModEnv1Dest1Am;            // index 808:811 (value range -10 -> 10)
    float xModEnv1Dest2Am;            // index 812:815 (value range -10 -> 10)
    float xModEnv2Dest1Am;            // index 816:819 (value range -10 -> 10)
    float xModEnv2Dest2Am;            // index 820:823 (value range -10 -> 10)
    float xModLFO1Dest1Am;            // index 824:827 (value range -10 -> 10)
    float xModLFO1Dest2Am;            // index 828:831 (value range -10 -> 10)
    float xModLFO2Dest1Am;            // index 832:835 (value range -10 -> 10)
    float xModLFO2Dest2Am;            // index 836:839 (value range -10 -> 10)
    float xModMisc1ADest1Am;          // index 840:843 (value range -10 -> 10)
    float xModMisc1ADest2Am;          // index 844:847 (value range -10 -> 10)
    LENNXMODSource xModMisc1ASource;      // index 848:851 
    float xModMisc1BDest1Am;          // index 852:855 (value range -10 -> 10)
    float xModMisc1BDest2Am;          // index 856:859 (value range -10 -> 10)
    LENNXMODSource xModMisc1BSource;      // index 860:863 
    float xModMisc2ADest1Am;          // index 864:867 (value range -10 -> 10)
    float xModMisc2ADest2Am;          // index 868:871 (value range -10 -> 10)
    LENNXMODSource xModMisc2ASource;      // index 872:875 
    float xModMisc2BDest1Am;          // index 876:879 (value range -10 -> 10)
    float xModMisc2BDest2Am;          // index 880:883 (value range -10 -> 10)
    LENNXMODSource xModMisc2BSource;      // index 884:887 
    LENNOnOff xSwArpOnOff;                // index 890:891 
    LENNOnOff xSwChorusOnOff;             // index 894:895 
    LENNOnOff xSwCompOnOff;               // index 898:899 
    LENNOnOff xSwDelayOnOff;              // index 902:903 
    LENNOnOff xSwDistOnOff;               // index 906:907 
    LENNOnOff xSwEQOnOff;                 // index 910:911 
    LENNOnOff xSwPhaserOnOff;             // index 914:915 
    LENNOnOff xSwReverbOnOff;             // index 918:919 
    LENNYMODDest yModEnv1Dest1;           // index 922:923 
    LENNYMODDest yModEnv1Dest2;           // index 926:927 
    LENNYMODDest yModEnv2Dest1;           // index 930:931 
    LENNYMODDest yModEnv2Dest2;           // index 934:935 
    LENNYMODDest yModLFO1Dest1;          // index 939:939 
    LENNYMODDest yModLFO1Dest2;          // index 942:943 
    LENNYMODDest yModLFO2Dest1;          // index 946:947 
    LENNYMODDest yModLFO2Dest2;          // index 950:951 
    LENNYMODDest yModMisc1ADest1;        // index 954:955 
    LENNYMODDest yModMisc1ADest2;        // index 958:959 
    LENNYMODDest yModMisc1BDest1;        // index 962:963 
    LENNYMODDest yModMisc1BDest2;        // index 966:967 
    LENNYMODDest yModMisc2ADest1;        // index 970:971 
    LENNYMODDest yModMisc2ADest2;        // index 974:975 
    LENNYMODDest yModMisc2BDest1;        // index 978:979 
    LENNYMODDest yModMisc2BDest2;        // index 982:983 
    LENNYPartSelect yPartSelect;         // index 986:987 
    char presetName[36];
};

struct LENNSylenth1
{
    type::Magic<"1lys"> magic;
    u32 version;
    u32 fxVersion;
    u32 numProg;
    u32 version2;
    LENNSylenth1Program programs[numProg];
};

str plugName;
struct FLEvent {
    FLEventType type;
    if (type < 64) {
        u8 value;
    } else if (type > 63 && type < 128) {
        u16 value;
    } else if (type > 127 && type < 192) {
        u32 value;
    } else {
        type::uLEB128 length;
        match (type) {
        (FLEventType::PATTNotes): 
            PATTNote value[length / sizeof(PATTNote)];
        (FLEventType::CHANDelay):
            CHANDelay value;
        (/*FLEventType::CHANLegacyAutomation*/FLEventType::PATTControllers ):
            /* CHANLegacyAutomation value[length / sizeof(CHANLegacyAutomation)]; */ PATTController value[length / sizeof(PATTController)];
        (FLEventType::CHANParams):
            CHANParams<length> value;
        (FLEventType::PROJTimestamp):
            PROJTimestamp value;
        (FLEventType::CHANEnvelopeLFO):
            CHANEnvelopeLFO value;
        (FLEventType::CHANLevelAdjusts):
            CHANLevelAdjusts value;
        (FLEventType::CHANLevels):
            CHANLevels value[length / sizeof(CHANLevels)];
        (FLEventType::CHANPolyphony):
            CHANPolyphony value;
        (FLEventType::CHANTracking):
            CHANTrack value[length / sizeof(CHANTrack)];
        (FLEventType::CONTRemoteContEvents):
            CONTRemoteContEvent value[length / sizeof(CONTRemoteContEvent)];
        (FLEventType::PLUGWrapper):
            PLUGWrapperEvent<length> value;
        (FLEventType::PLUGData): {
            char value[length];// PLUGDataVST<length> value;
            match (plugName) {
                ("Fruity Parametric EQ 2"): ILFLParametricEQ2<length> paramEq @ ($ - length);
                ("Fruity Limiter"): ILFLLimiter limiter @ ($ - length);
                ("Fruity Stereo Shaper"): ILFLStereoShaper stereoShaper @ ($ - length);
                ("Fruity Wrapper"): PLUGDataVST<length> plugin @ ($ - length);
            }
            }
        (FLEventType::ARNGPlaylist):
            ARNGPlaylistEvent value[length / sizeof(ARNGPlaylistEvent)];
        (FLEventType::ARNGTrack):
            ARNGTrack<length> value;
        (FLEventType::MIXRInsertFlags):
            MIXRInsertParams<length> value;
        (FLEventType::MIXRParams):
            MIXRParams value[length / sizeof(MIXRParams)];
        (FLEventType::PLUGInternalName): {
            char value[length] [[transform("StripFLString"), format("StripFLString")]];
            plugName = value;
        }
        (_):
            char value[length] [[transform("StripFLString"), format("StripFLString")]];
        }
    }
};

FLHeader header @ 0x0;
FLData data @ $;
FLEvent events[while($ < std::mem::size())] @ $;
