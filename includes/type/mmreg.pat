import type.guid;

/*!
    Microsoft's mmreg.h
*/

namespace auto type {

    enum TypewFormatTag : u16 {
        WAVE_FORMAT_PCM                = 0x0001,               // Microsoft PCM Format
        WAVE_FORMAT_ADPCM              = 0x0002,               // Microsoft ADPCM Format
        WAVE_FORMAT_IEEE_FLOAT         = 0x0003,               // IEEE float
        WAVE_FORMAT_VSELP              = 0x0004,               // Compaq Computer's VSELP
        WAVE_FORMAT_IBM_CVSD           = 0x0005,               // IBM CVSD
        WAVE_FORMAT_ALAW               = 0x0006,               // ALAW
        WAVE_FORMAT_MULAW              = 0x0007,               // MULAW
        WAVE_FORMAT_DTS                = 0x0008,               // Digital Theater Systems DTS
        WAVE_FORMAT_DRM                = 0x0009,               // Microsoft Corporation
        WAVE_FORMAT_WMAVOICE9          = 0x000A,               // Microsoft Corporation
        WAVE_FORMAT_WMAVOICE10         = 0x000B,               // Microsoft Corporation
        WAVE_FORMAT_OKI_ADPCM          = 0x0010,               // OKI ADPCM
    //  WAVE_FORMAT_DVI_ADPCM          = 0x0011,               // Intel's DVI ADPCM
        WAVE_FORMAT_IMA_ADPCM          = 0x0011,               // Intel's DVI ADPCM
        WAVE_FORMAT_MEDIASPACE_ADPCM   = 0x0012,               // Videologic's MediaSpace ADPCM
        WAVE_FORMAT_SIERRA_ADPCM       = 0x0013,               // Sierra ADPCM
        WAVE_FORMAT_G723_ADPCM         = 0x0014,               // G.723 ADPCM
        WAVE_FORMAT_DIGISTD            = 0x0015,               // DSP Solution's DIGISTD
        WAVE_FORMAT_DIGIFIX            = 0x0016,               // DSP Solution's DIGIFIX
        WAVE_FORMAT_DIALOGIC_OKI_ADPCM = 0x0017,               // Dialogic Corporation
        WAVE_FORMAT_MEDIAVISION_ADPCM  = 0x0018,               // Media Vision ADPCM
        WAVE_FORMAT_YAMAHA_ADPCM       = 0x0020,               // Yamaha ADPCM
        WAVE_FORMAT_SONARC             = 0x0021,               // Speech Compression's Sonarc
        WAVE_FORMAT_TRUESPEECH         = 0x0022,               // DSP Group's True Speech
        WAVE_FORMAT_ECHOSC1            = 0x0023,               // Echo Speech's EchoSC1
        WAVE_FORMAT_AUDIOFILE_AF36     = 0x0024,               // Audiofile AF36
        WAVE_FORMAT_APTX               = 0x0025,               // APTX
        WAVE_FORMAT_AUDIOFILE_AF10     = 0x0026,               // AudioFile AF10
        WAVE_FORMAT_PROSODY_1612       = 0x0027,               // Prosody 1612
        WAVE_FORMAT_LRC                = 0x0028,               // LRC
        WAVE_FORMAT_DOLBY_AC2          = 0x0030,               // Dolby AC2
        WAVE_FORMAT_GSM610             = 0x0031,               // GSM610
        WAVE_FORMAT_MSNAUDIO           = 0x0032,               // MSNAudio
        WAVE_FORMAT_ANTEX_ADPCME       = 0x0033,               // Antex ADPCME
        WAVE_FORMAT_CONTROL_RES_VQLPC  = 0x0034,               // Control Res VQLPC
        WAVE_FORMAT_DIGIREAL           = 0x0035,               // Digireal
        WAVE_FORMAT_DIGIADPCM          = 0x0036,               // DigiADPCM
        WAVE_FORMAT_CONTROL_RES_CR10   = 0x0037,               // Control Res CR10
        WAVE_FORMAT_NMS_VBXADPCM       = 0x0038,               // NMS VBXADPCM
        WAVE_FORMAT_CS_IMAADPCM        = 0x0039,               // CS IMAADPCM
        WAVE_FORMAT_ECHOSC3            = 0x003A,               // EchoSC3
        WAVE_FORMAT_ROCKWELL_ADPCM     = 0x003B,               // Rockwell ADPCM
        WAVE_FORMAT_ROCKWELL_DIGITALK  = 0x003C,               // Rockwell Digit LK
        WAVE_FORMAT_XEBEC              = 0x003D,               // Xebec
        WAVE_FORMAT_G721_ADPCM         = 0x0040,               // Antex Electronics Corporation
        WAVE_FORMAT_G728_CELP          = 0x0041,               // G.728 CELP
        WAVE_FORMAT_MSG723             = 0x0042,               // MSG723
        WAVE_FORMAT_MPEG               = 0x0050,               // MPEG Layer 1, 2
        WAVE_FORMAT_RT24               = 0x0052,               // RT24
        WAVE_FORMAT_PAC                = 0x0053,               // PAC
        WAVE_FORMAT_MPEGLAYER3         = 0x0055,               // MPEG Layer 3
        WAVE_FORMAT_LUCENT_G723        = 0x0059,               // Lucent Technologies
        WAVE_FORMAT_CIRRUS             = 0x0060,               // Cirrus Logic
        WAVE_FORMAT_ESPCM              = 0x0061,               // ESS Technology
        WAVE_FORMAT_VOXWARE            = 0x0062,               // Voxware Inc.
        WAVE_FORMAT_CANOPUS_ATRAC      = 0x0063,               // Canopus, co., Ltd.
        WAVE_FORMAT_G726_ADPCM         = 0x0064,               // APICOM
        WAVE_FORMAT_G722_ADPCM         = 0x0065,               // APICOM
        WAVE_FORMAT_DSAT               = 0x0066,               // Microsoft Corporation
        WAVE_FORMAT_DSAT_DISPLAY       = 0x0067,               // Microsoft Corporation
        WAVE_FORMAT_VOXWARE_BYTE_ALIGNED = 0x0069,             // Voxware Inc.
        WAVE_FORMAT_VOXWARE_AC8        = 0x0070,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_AC10       = 0x0071,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_AC16       = 0x0072,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_AC20       = 0x0073,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_RT24       = 0x0074,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_RT29       = 0x0075,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_RT29HW     = 0x0076,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_VR12       = 0x0077,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_VR18       = 0x0078,               // Voxware Inc.
        WAVE_FORMAT_VOXWARE_TQ40       = 0x0079,               // Voxware Inc.
        WAVE_FORMAT_SOFTSOUND          = 0x0080,               // Softsound, Ltd.
        WAVE_FORMAT_VOXWARE_TQ60       = 0x0081,               // Voxware Inc.
        WAVE_FORMAT_MSRT24             = 0x0082,               // Microsoft Corporation
        WAVE_FORMAT_G729A              = 0x0083,               // AT&T Labs, Inc.
        WAVE_FORMAT_MVI_MVI2           = 0x0084,               // Motion Pixels
        WAVE_FORMAT_DF_G726            = 0x0085,               // DataFusion Systems (Pty) (Ltd)
        WAVE_FORMAT_DF_GSM610          = 0x0086,               // DataFusion Systems (Pty) (Ltd)
        WAVE_FORMAT_ISIAUDIO           = 0x0088,               // Iterated Systems, Inc.
        WAVE_FORMAT_ONLIVE             = 0x0089,               // OnLive! Technologies, Inc.
        WAVE_FORMAT_SBC24              = 0x0091,               // Siemens Business Communications Sys
        WAVE_FORMAT_DOLBY_AC3_SPDIF    = 0x0092,               // Sonic Foundry
        WAVE_FORMAT_MEDIASONIC_G723    = 0x0093,               // MediaSonic
        WAVE_FORMAT_PROSODY_8KBPS      = 0x0094,               // Aculab
        WAVE_FORMAT_ZYXEL_ADPCM        = 0x0097,               // ZyXEL Communications, Inc.
        WAVE_FORMAT_PHILIPS_LPCBB      = 0x0098,               // Philips Speech Processing
        WAVE_FORMAT_PACKED             = 0x0099,               // Studer Professional Audio AG
        WAVE_FORMAT_MALDEN_PHONYTALK   = 0x00A0,               // Malden Electronics Ltd.
        WAVE_FORMAT_RACAL_RECORDER_GSM = 0x00A1,               // Racal recorders
        WAVE_FORMAT_RACAL_RECORDER_G720_A = 0x00A2,            // Racal recorders
        WAVE_FORMAT_RACAL_RECORDER_G723_1 = 0x00A3,            // Racal recorders
        WAVE_FORMAT_RACAL_RECORDER_TETRA_ACELP = 0x00A4,       // Racal recorders
        WAVE_FORMAT_NEC_AAC            = 0x00B0,               // NEC Corp.
        WAVE_FORMAT_RAW_AAC1           = 0x00FF,               // For Raw AAC, with format block AudioSpecificConfig() (as defined by MPEG-4)
        WAVE_FORMAT_RHETOREX_ADPCM     = 0x0100,               // Rhetorex Inc.
        WAVE_FORMAT_IRAT               = 0x0101,               // BeCubed Software Inc.
        WAVE_FORMAT_VIVO_G723          = 0x0111,               // Vivo Software
        WAVE_FORMAT_VIVO_SIREN         = 0x0112,               // Vivo Software
        WAVE_FORMAT_PHILIPS_CELP       = 0x0120,               // Philips Speech Processing
        WAVE_FORMAT_PHILIPS_GRUNDIG    = 0x0121,               // Philips Speech Processing
        WAVE_FORMAT_DIGITAL_G723       = 0x0123,               // Digital Equipment Corporation
        WAVE_FORMAT_SANYO_LD_ADPCM     = 0x0125,               // Sanyo Electric Co., Ltd.
        WAVE_FORMAT_SIPROLAB_ACEPLNET  = 0x0130,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_SIPROLAB_ACELP4800 = 0x0131,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_SIPROLAB_ACELP8V3  = 0x0132,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_SIPROLAB_G729      = 0x0133,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_SIPROLAB_G729A     = 0x0134,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_SIPROLAB_KELVIN    = 0x0135,               // Sipro Lab Telecom Inc.
        WAVE_FORMAT_VOICEAGE_AMR       = 0x0136,               // VoiceAge Corp.
        WAVE_FORMAT_G726ADPCM          = 0x0140,               // Dictaphone Corporation
        WAVE_FORMAT_DICTAPHONE_CELP68  = 0x0141,               // Dictaphone Corporation
        WAVE_FORMAT_DICTAPHONE_CELP54  = 0x0142,               // Dictaphone Corporation
        WAVE_FORMAT_QUALCOMM_PUREVOICE = 0x0150,               // Qualcomm, Inc.
        WAVE_FORMAT_QUALCOMM_HALFRATE  = 0x0151,               // Qualcomm, Inc.
        WAVE_FORMAT_TUBGSM             = 0x0155,               // Ring Zero Systems, Inc.
        WAVE_FORMAT_MSAUDIO1           = 0x0160,               // Microsoft Corporation
        WAVE_FORMAT_WMAUDIO2           = 0x0161,               // Microsoft Corporation
        WAVE_FORMAT_WMAUDIO3           = 0x0162,               // Microsoft Corporation
        WAVE_FORMAT_WMAUDIO_LOSSLESS   = 0x0163,               // Microsoft Corporation
        WAVE_FORMAT_WMASPDIF           = 0x0164,               // Microsoft Corporation
        WAVE_FORMAT_UNISYS_NAP_ADPCM   = 0x0170,               // Unisys Corp.
        WAVE_FORMAT_UNISYS_NAP_ULAW    = 0x0171,               // Unisys Corp.
        WAVE_FORMAT_UNISYS_NAP_ALAW    = 0x0172,               // Unisys Corp.
        WAVE_FORMAT_UNISYS_NAP_16K     = 0x0173,               // Unisys Corp.
        WAVE_FORMAT_CREATIVE_ADPCM     = 0x0200,               // Creative Labs, Inc
        WAVE_FORMAT_CREATIVE_FASTSPEECH8 = 0x0202,             // Creative Labs, Inc
        WAVE_FORMAT_CREATIVE_FASTSPEECH10 = 0x0203,            // Creative Labs, Inc
        WAVE_FORMAT_UHER_ADPCM         = 0x0210,               // UHER informatic GmbH
        WAVE_FORMAT_QUARTERDECK        = 0x0220,               // Quarterdeck Corporation
        WAVE_FORMAT_ILINK_VC           = 0x0230,               // I-link Worldwide
        WAVE_FORMAT_RAW_SPORT          = 0x0240,               // Aureal Semiconductor
        WAVE_FORMAT_ESST_AC3           = 0x0241,               // ESS Technology, Inc.
        WAVE_FORMAT_IPI_HSX            = 0x0250,               // Interactive Products, Inc.
        WAVE_FORMAT_IPI_RPELP          = 0x0251,               // Interactive Products, Inc.
        WAVE_FORMAT_CS2                = 0x0260,               // Consistent Software
        WAVE_FORMAT_SONY_SCX           = 0x0270,               // Sony Corp.
        WAVE_FORMAT_FM_TOWNS_SND       = 0x0300,               // Fujitsu Corp.
        WAVE_FORMAT_BTV_DIGITAL        = 0x0400,               // Brooktree Corporation
        WAVE_FORMAT_QDESIGN_MUSIC      = 0x0450,               // QDesign Corporation
        WAVE_FORMAT_VME_VMPCM          = 0x0680,               // AT&T Labs, Inc.
        WAVE_FORMAT_TPC                = 0x0681,               // AT&T Labs, Inc.
        WAVE_FORMAT_OLIGSM             = 0x1000,               // Ing C. Olivetti & C., S.p.A.
        WAVE_FORMAT_OLIADPCM           = 0x1001,               // Ing C. Olivetti & C., S.p.A.
        WAVE_FORMAT_OLICELP            = 0x1002,               // Ing C. Olivetti & C., S.p.A.
        WAVE_FORMAT_OLISBC             = 0x1003,               // Ing C. Olivetti & C., S.p.A.
        WAVE_FORMAT_OLIOPR             = 0x1004,               // Ing C. Olivetti & C., S.p.A.
        WAVE_FORMAT_LH_CODEC           = 0x1100,               // Lernout & Hauspie
        WAVE_FORMAT_LH_CODEC_CELP      = 0x1101,               // Lernout & Hauspie
        WAVE_FORMAT_LH_CODEC_SBC8      = 0x1102,               // Lernout & Hauspie
        WAVE_FORMAT_LH_CODEC_SBC12     = 0x1103,               // Lernout & Hauspie
        WAVE_FORMAT_LH_CODEC_SBC16     = 0x1104,               // Lernout & Hauspie
        WAVE_FORMAT_NORRIS             = 0x1400,               // Norris Communications, Inc.
        WAVE_FORMAT_ISIAUDIO_2         = 0x1401,               // ISIAudio
        WAVE_FORMAT_SOUNDSPACE_MUSICOMPRESS = 0x1500,          // AT&T Labs, Inc.
        WAVE_FORMAT_MPEG_ADTS_AAC      = 0x1600,               // Microsoft Corporation
        WAVE_FORMAT_MPEG_RAW_AAC       = 0x1601,               // Microsoft Corporation
        WAVE_FORMAT_MPEG_LOAS          = 0x1602,               // Microsoft Corporation
        WAVE_FORMAT_NOKIA_MPEG_ADTS_AAC = 0x1608,              // Microsoft Corporation
        WAVE_FORMAT_NOKIA_MPEG_RAW_AAC = 0x1609,               // Microsoft Corporation
        WAVE_FORMAT_VODAFONE_MPEG_ADTS_AAC = 0x160A,           // Microsoft Corporation
        WAVE_FORMAT_VODAFONE_MPEG_RAW_AAC = 0x160B,            // Microsoft Corporation
        WAVE_FORMAT_MPEG_HEAAC         = 0x1610,               // Microsoft Corporation
        WAVE_FORMAT_VOXWARE_RT24_SPEECH = 0x181C,              // Voxware Inc.
        WAVE_FORMAT_SONICFOUNDRY_LOSSLESS = 0x1971,            // Sonic Foundry
        WAVE_FORMAT_INNINGS_TELECOM_ADPCM = 0x1979,            // Innings Telecom Inc.
        WAVE_FORMAT_LUCENT_SX8300P     = 0x1C07,               // Lucent Technologies
        WAVE_FORMAT_LUCENT_SX5363S     = 0x1C0C,               // Lucent Technologies
        WAVE_FORMAT_CUSEEME            = 0x1F03,               // CUSeeMe
        WAVE_FORMAT_NTCSOFT_ALF2CM_ACM = 0x1FC4,               // NTCSoft
        WAVE_FORMAT_DVM                = 0x2000,               // FAST Multimedia AG
        WAVE_FORMAT_DTS2               = 0x2001,               // FAST Multimedia AG
        WAVE_FORMAT_MAKEAVIS           = 0x3313,               // MakeAVIs
        WAVE_FORMAT_DIVIO_MPEG4_AAC    = 0x4143,               // Divio, Inc.
        WAVE_FORMAT_NOKIA_ADAPTIVE_MULTIRATE = 0x4201,         // Nokia
        WAVE_FORMAT_DIVIO_G726         = 0x4243,               // Divio, Inc.
        WAVE_FORMAT_LEAD_SPEECH        = 0x434C,               // LEAD Technologies
        WAVE_FORMAT_LEAD_VORBIS        = 0x564C,               // LEAD Technologies
        WAVE_FORMAT_WAVPACK_AUDIO      = 0x5756,               // xiph.org
        WAVE_FORMAT_OGGVORBIS_MODE_1   = 0x674F,               // Xiph.Org Foundation
        WAVE_FORMAT_OGGVORBIS_MODE_2   = 0x6750,               // Xiph.Org Foundation
        WAVE_FORMAT_OGGVORBIS_MODE_3   = 0x6751,               // Xiph.Org Foundation
        WAVE_FORMAT_OGGVORBIS_MODE_1_PLUS = 0x676F,            // Xiph.Org Foundation
        WAVE_FORMAT_OGGVORBIS_MODE_2_PLUS = 0x6770,            // Xiph.Org Foundation
        WAVE_FORMAT_OGGVORBIS_MODE_3_PLUS = 0x6771,            // Xiph.Org Foundation
        WAVE_FORMAT_3COM_NBX           = 0x7000,               // 3COM Corporation
        WAVE_FORMAT_OPUS               = 0x704F,               // Xiph.Org Foundation
        WAVE_FORMAT_FAAD_AAC           = 0x706D,               // Freeware Advanced Audio Coder
        WAVE_FORMAT_AMR_NB             = 0x7361,               // 3GPP
        WAVE_FORMAT_AMR_WB             = 0x7362,               // 3GPP
        WAVE_FORMAT_AMR_WP             = 0x7363,               // 3GPP
        WAVE_FORMAT_GSM_AMR_CBR        = 0x7A21,               // GSMA/3GPP
        WAVE_FORMAT_GSM_AMR_VBR_SID    = 0x7A22,               // GSMA/3GPP
        WAVE_FORMAT_COMVERSE_INFOSYS_G723_1 = 0xA100,          // Comverse Infosys
        WAVE_FORMAT_COMVERSE_INFOSYS_AVQSBC = 0xA101,          // Comverse Infosys
        WAVE_FORMAT_COMVERSE_INFOSYS_SBC = 0xA102,             // Comverse Infosys
        WAVE_FORMAT_SYMBOL_G729_A      = 0xA103,               // Symbol Technologies
        WAVE_FORMAT_VOICEAGE_AMR_WB    = 0xA104,               // VoiceAge Corp.
        WAVE_FORMAT_INGENIENT_G726     = 0xA105,               // Ingenient Technologies, Inc.
        WAVE_FORMAT_MPEG4_AAC          = 0xA106,               // ISO/MPEG-4
        WAVE_FORMAT_ENCORE_G726        = 0xA107,               // Encore Software
        WAVE_FORMAT_ZOLL_ASAO          = 0xA108,               // ZOLL Medical Corporation
        WAVE_FORMAT_SPEEX_VOICE        = 0xA109,               // xiph.org
        WAVE_FORMAT_VIANIX_MASC        = 0xA10A,               // Vianix LLC
        WAVE_FORMAT_WM9_SPECTRUM_ANALYZER = 0xA10B,            // Microsoft
        WAVE_FORMAT_WMF_SPECTRUM_ANAYZER = 0xA10C,             // Microsoft
        WAVE_FORMAT_GSM_610            = 0xA10D,               // Microsoft
        WAVE_FORMAT_GSM_620            = 0xA10E,               // Microsoft
        WAVE_FORMAT_GSM_660            = 0xA10F,               // Microsoft
        WAVE_FORMAT_GSM_690            = 0xA110,               // Microsoft
        WAVE_FORMAT_GSM_ADAPTIVE_MULTIRATE_WB = 0xA111,        // Microsoft
        WAVE_FORMAT_POLYCOM_G722       = 0xA112,               // Polycom
        WAVE_FORMAT_POLYCOM_G728       = 0xA113,               // Polycom
        WAVE_FORMAT_POLYCOM_G729_A     = 0xA114,               // Polycom
        WAVE_FORMAT_POLYCOM_SIREN      = 0xA115,               // Polycom
        WAVE_FORMAT_GLOBAL_IP_ILBC     = 0xA116,               // Global IP Sound
        WAVE_FORMAT_RADIOTIME_TIME_SHIFT_RADIO = 0xA117,       // RadioTime
        WAVE_FORMAT_NICE_ACA           = 0xA118,               // NICE Systems
        WAVE_FORMAT_NICE_ADPCM         = 0xA119,               // NICE Systems
        WAVE_FORMAT_VOCORD_G721        = 0xA11A,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G726        = 0xA11B,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G722_1      = 0xA11C,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G728        = 0xA11D,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G729        = 0xA11E,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G729_A      = 0xA11F,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_G723_1      = 0xA120,               // Vocord Telecom
        WAVE_FORMAT_VOCORD_LBC         = 0xA121,               // Vocord Telecom
        WAVE_FORMAT_NICE_G728          = 0xA122,               // NICE Systems
        WAVE_FORMAT_FRACE_TELECOM_G729 = 0xA123,               // France Telecom
        WAVE_FORMAT_CODIAN             = 0xA124,               // CODIAN
        WAVE_FORMAT_FLAC               = 0xF1AC,               // xiph.org
        WAVE_FORMAT_EXTENSIBLE         = 0xFFFE,               // Microsoft
        WAVE_FORMAT_DEVELOPMENT        = 0xFFFF                // Microsoft
    };

    struct WAVEFORMAT {
        TypewFormatTag wFormatTag;
        u16 wChannels;
        u32 dwSamplesPerSec [[comment("Sample rate")]];
        u32 dwAvgBytesPerSec [[comment("Average bytes per second")]];
        u16 wBlockAlign;
    } [[static]];

    struct WAVEFORMATEX {
        TypewFormatTag wFormatTag;
        u16 wChannels;
        u32 dwSamplesPerSec [[comment("Sample rate")]];
        u32 dwAvgBytesPerSec [[comment("Average bytes per second")]];
        u16 wBlockAlign;
        u16 wBitsPerSample;
        u16 cbSize;
    } [[static]];

    struct PCMWAVEFORMAT {
        WAVEFORMAT wf [[inline]];
        u16 wBitsPerSample;
    } [[static]];

    struct ADPCMOffest {
        u16 iCoef1;
        u16 iCoef2;
    } [[static]];

    struct ADPCMWAVEFORMAT {
        WAVEFORMATEX wfx [[inline]];
        u16 wSamplesPerBlock;
        u16 wNumCoef;
        ADPCMOffest aCoef[wNumCoef];
    };

    enum WaveFormatMPEGLayer3Flags : u32 {
        MPEGLAYER3_FLAG_PADDING_ISO,
        MPEGLAYER3_FLAG_PADDING_ON,
        MPEGLAYER3_FLAG_PADDING_OFF
    };

    enum WaveFormatMPEGLayer3IDs : u16 {
        MPEGLAYER3_ID_UNKNOWN,
        MPEGLAYER3_ID_MPEG,
        MPEGLAYER3_ID_CONSTANTFRAMESIZE
    };

    struct MPEGLAYER3WAVEFORMAT {
        WAVEFORMATEX wfx [[inline]];
        WaveFormatMPEGLayer3IDs id;
        WaveFormatMPEGLayer3Flags flags;
        u16 blockSize;
        u16 framesPerBlock;
        u16 codecDelay;
    } [[static]];

    bitfield WaveMPEGLayer {
        Layer1  : 1;
        Layer2  : 1;
        Layer3  : 1;
        padding : 13;
    };

    bitfield WaveMPEGMode {
        Stereo : 1;
        JointStereo : 1;
        DualChannel : 1;
        SingleChannel : 1;
        padding : 12;
    };

    bitfield WaveMPEGFlags {
        PrivateBit : 1;
        Copyright : 1;
        OriginalHome : 1;
        ProtectionBit : 1;
        IdMPEG1 : 1;
        padding : 11;
    };

    struct MPEG1WAVEFORMAT {
        WAVEFORMATEX wfx [[inline]];
        WaveMPEGLayer headLayersUsed;
        u32           headBitrate;
        WaveMPEGMode  headMode;
        u16           headModeExt;
        u16           headEmphasis;
        WaveMPEGFlags headFlags;
        u32           PTSLow;
        u32           PTSHigh;
    } [[static]];

    bitfield WlnkChannel {
        bool LeftMono : 1;
        bool Right : 1;
        bool Center : 1;
        bool LFE : 1;
        bool LeftSurround : 1;
        bool RightSurround : 1;
        bool LeftCenter : 1;
        bool RightCenter : 1;
        bool SurroundCenter : 1;
        bool SideLeft : 1;
        bool SideRight : 1;
        bool Top : 1;
        bool TopFL : 1;
        bool TopFC : 1;
        bool TopFR : 1;
        bool TopRL : 1;
        bool TopRC : 1;
        bool TopRR : 1;
        padding : 14;
    };

    namespace impl {
        union WAVEFORMATEXTENSIBLEwFIELD {
            u16 wValidBitsPerSample;
            u16 wSamplesPerBlock; // when wBitsPerSample == 0
            u16 wReserved;
        };
    }

    struct WAVEFORMATEXTENSIBLE {
        WAVEFORMATEX wfx [[inline]];
        impl::WAVEFORMATEXTENSIBLEwFIELD wField;
        WlnkChannel dwChannelMask;
        GUID subFormat;
    } [[static]];

    using WAVEFORMATIEEEFLOATEX = WAVEFORMATEXTENSIBLE;

    struct IMAADPCMWAVEFORMAT {
        WAVEFORMATEX wfx [[inline]];
        u16 wSamplesPerBlock;
    } [[static]];
}