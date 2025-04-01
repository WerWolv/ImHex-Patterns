#pragma author WerWolv
#pragma description Windows HtmlHelp Data (ITSF / CHM)
#pragma MIME application/vnd.ms-htmlhelp

import type.magic;
import type.size;
import type.guid;
import type.leb128;
import std.sys;

enum WindowsLanguageId : u32 {
    Arabic_SaudiArabia                          = 0x401,
    Arabic_Iraq                                 = 0x801,
    Arabic_Egypt                                = 0xc01,
    Arabic_Libya                                = 0x1001,
    Arabic_Algeria                              = 0x1401,
    Arabic_Morocco                              = 0x1801,
    Arabic_Tunisia                              = 0x1c01,
    Arabic_Oman                                 = 0x2001,
    Arabic_Yemen                                = 0x2401,
    Arabic_Syria                                = 0x2801,
    Arabic_Jordan                               = 0x2c01,
    Arabic_Lebanon                              = 0x3001,
    Arabic_Kuwait                               = 0x3401,
    Arabic_UAE                                  = 0x3801,
    Arabic_Bahrain                              = 0x3c01,
    Arabic_Qatar                                = 0x4001,
    Bulgarian                                   = 0x402,
    Catalan                                     = 0x403,
    Valencian                                   = 0x803,
    Chinese_Taiwan                              = 0x404,
    Chinese_PRC                                 = 0x804,
    Chinese_HongKongSAR                         = 0xc04,
    Chinese_Singapore                           = 0x1004,
    Chinese_MacaoSAR                            = 0x1404,
    Czech                                       = 0x405,
    Danish                                      = 0x406,
    German_Germany                              = 0x407,
    German_Switzerland                          = 0x807,
    German_Austria                              = 0xc07,
    German_Luxembourg                           = 0x1007,
    German_Liechtenstein                        = 0x1407,
    Greek                                       = 0x408,
    English_UnitedStates                        = 0x409,
    English_UnitedKingdom                       = 0x809,
    English_Australia                           = 0xc09,
    English_Canada                              = 0x1009,
    English_NewZealand                          = 0x1409,
    English_Ireland                             = 0x1809,
    English_SouthAfrica                         = 0x1c09,
    English_Jamaica                             = 0x2009,
    English_Caribbean                           = 0x2409,
    English_Belize                              = 0x2809,
    English_TrinidadandTobago                   = 0x2c09,
    English_Zimbabwe                            = 0x3009,
    English_Philippines                         = 0x3409,
    English_Indonesia                           = 0x3809,
    English_HongKongSAR                         = 0x3c09,
    English_India                               = 0x4009,
    English_Malaysia                            = 0x4409,
    English_Singapore                           = 0x4809,
    Spanish_SpainTraditionalSort                = 0x40a,
    Spanish_Mexico                              = 0x80a,
    Spanish_Spain                               = 0xc0a,
    Spanish_Guatemala                           = 0x100a,
    Spanish_CostaRica                           = 0x140a,
    Spanish_Panama                              = 0x180a,
    Spanish_DominicanRepublic                   = 0x1c0a,
    Spanish_Venezuela                           = 0x200a,
    Spanish_Colombia                            = 0x240a,
    Spanish_Peru                                = 0x280a,
    Spanish_Argentina                           = 0x2c0a,
    Spanish_Ecuador                             = 0x300a,
    Spanish_Chile                               = 0x340a,
    Spanish_Uruguay                             = 0x380a,
    Spanish_Paraguay                            = 0x3c0a,
    Spanish_Bolivia                             = 0x400a,
    Spanish_ElSalvador                          = 0x440a,
    Spanish_Honduras                            = 0x480a,
    Spanish_Nicaragua                           = 0x4c0a,
    Spanish_PuertoRico                          = 0x500a,
    Spanish_UnitedStates                        = 0x540a,
    Spanish_LatinAmerica                        = 0x580a,
    Finnish                                     = 0x40b,
    French_France                               = 0x40c,
    French_Belgium                              = 0x80c,
    French_Canada                               = 0xc0c,
    French_Switzerland                          = 0x100c,
    French_Luxembourg                           = 0x140c,
    French_Monaco                               = 0x180c,
    French_Caribbean                            = 0x1c0c,
    French_Reunion                              = 0x200c,
    French_CongoDRC                             = 0x240c,
    French_Senegal                              = 0x280c,
    French_Cameroon                             = 0x2c0c,
    French_CoteDIvoire                          = 0x300c,
    French_Mali                                 = 0x340c,
    French_Morocco                              = 0x380c,
    French_Haiti                                = 0x3c0c,
    Hebrew                                      = 0x40d,
    Hungarian                                   = 0x40e,
    Icelandic                                   = 0x40f,
    Italian_Italy                               = 0x410,
    Italian_Switzerland                         = 0x810,
    Japanese                                    = 0x411,
    Korean                                      = 0x412,
    Dutch_Netherlands                           = 0x413,
    Dutch_Belgium                               = 0x813,
    Norwegian_Bokmal                            = 0x414,
    Norwegian_Nynorsk                           = 0x814,
    Polish                                      = 0x415,
    Portuguese_Brazil                           = 0x416,
    Portuguese_Portugal                         = 0x816,
    Romansh                                     = 0x417,
    Romanian                                    = 0x418,
    Romanian_Moldova                            = 0x818,
    Russian                                     = 0x419,
    Russian_Moldova                             = 0x819,
    Croatian_Croatia                            = 0x41a,
    Serbian_LatinSerbiaandMontenegroFormer      = 0x81a,
    Serbian_CyrillicSerbiaAndMontenegroFormer   = 0xc1a,
    Croatian_BosniaAndHerzegovina               = 0x101a,
    Bosnian_Latin                               = 0x141a,
    Serbian_LatinBosniaAndHerzegovina           = 0x181a,
    Serbian_CyrillicBosniaAndHerzegovina        = 0x1c1a,
    Bosnian_Cyrillic                            = 0x201a,
    Serbian_LatinSerbia                         = 0x241a,
    Serbian_CyrillicSerbia                      = 0x281a,
    Serbian_LatinMontenegro                     = 0x2c1a,
    Serbian_CyrillicMontenegro                  = 0x301a,
    Slovak                                      = 0x41b,
    Albanian                                    = 0x41c,
    Swedish_Sweden                              = 0x41d,
    Swedish_Finland                             = 0x81d,
    Thai                                        = 0x41e,
    Turkish                                     = 0x41f,
    Urdu_Pakistan                               = 0x420,
    Urdu_India                                  = 0x820,
    Indonesian                                  = 0x421,
    Ukrainian                                   = 0x422,
    Belarusian                                  = 0x423,
    Slovenian                                   = 0x424,
    Estonian                                    = 0x425,
    Latvian                                     = 0x426,
    Lithuanian                                  = 0x427,
    Tajik                                       = 0x428,
    Persian                                     = 0x429,
    Vietnamese                                  = 0x42a,
    Armenian                                    = 0x42b,
    Azerbaijani_Latin                           = 0x42c,
    Azerbaijani_Cyrillic                        = 0x82c,
    Basque                                      = 0x42d,
    UpperSorbian                                = 0x42e,
    LowerSorbian                                = 0x82e,
    Macedonian                                  = 0x42f,
    Sesotho_SouthAfrica                         = 0x430,
    Xitsonga                                    = 0x431,
    Setswana_SouthAfrica                        = 0x432,
    Setswana_Botswana                           = 0x832,
    Venda                                       = 0x433,
    isiXhosa                                    = 0x434,
    isiZulu                                     = 0x435,
    Afrikaans                                   = 0x436,
    Georgian                                    = 0x437,
    Faroese                                     = 0x438,
    Hindi                                       = 0x439,
    Maltese                                     = 0x43a,
    NorthernSami_Norway                         = 0x43b,
    NorthernSami_Sweden                         = 0x83b,
    NorthernSami_Finland                        = 0xc3b,
    LuleSami_Norway                             = 0x103b,
    LuleSami_Sweden                             = 0x143b,
    SouthernSami_Norway                         = 0x183b,
    SouthernSami_Sweden                         = 0x1c3b,
    SkoltSami_Finland                           = 0x203b,
    InariSami_Finland                           = 0x243b,
    Irish                                       = 0x83c,
    Yiddish                                     = 0x43d,
    Malay_Malaysia                              = 0x43e,
    Malay_BruneiDarussalam                      = 0x83e,
    Kazakh                                      = 0x43f,
    Kyrgyz                                      = 0x440,
    Kiswahili                                   = 0x441,
    Turkmen                                     = 0x442,
    Uzbek_Latin                                 = 0x443,
    Uzbek_Cyrillic                              = 0x843,
    Tatar                                       = 0x444,
    Bangla_India                                = 0x445,
    Bangla_Bangladesh                           = 0x845,
    Punjabi_India                               = 0x446,
    Punjabi_Pakistan                            = 0x846,
    Gujarati                                    = 0x447,
    Odia                                        = 0x448,
    Tamil_India                                 = 0x449,
    Tamil_SriLanka                              = 0x849,
    Telugu                                      = 0x44a,
    Kannada                                     = 0x44b,
    Malayalam                                   = 0x44c,
    Assamese                                    = 0x44d,
    Marathi                                     = 0x44e,
    Sanskrit                                    = 0x44f,
    Mongolian_Cyrillic                          = 0x450,
    Mongolian_TraditionalMongolianPRC           = 0x850,
    Mongolian_TraditionalMongolianMongolia      = 0xc50,
    Tibetan_PRC                                 = 0x451,
    Welsh                                       = 0x452,
    Khmer                                       = 0x453,
    Lao                                         = 0x454,
    Burmese                                     = 0x455,
    Galician                                    = 0x456,
    Konkani                                     = 0x457,
    Manipuri                                    = 0x458,
    Sindhi_Devanagari                           = 0x459,
    Sindhi_Arabic                               = 0x859,
    Syriac                                      = 0x45a,
    Sinhala                                     = 0x45b,
    Cherokee_Cherokee                           = 0x45c,
    Inuktitut_Syllabics                         = 0x45d,
    Inuktitut_Latin                             = 0x85d,
    Amharic                                     = 0x45e,
    Tamazight_ArabicMorocco                     = 0x45f,
    Tamazight_LatinAlgeria                      = 0x85f,
    Tamazight_TifinaghMorocco                   = 0x105f,
    Kashmiri_Arabic                             = 0x460,
    Kashmiri                                    = 0x860,
    Nepali                                      = 0x461,
    Nepali_India                                = 0x861,
    Frisian                                     = 0x462,
    Pashto                                      = 0x463,
    Filipino                                    = 0x464,
    Divehi                                      = 0x465,
    Edo                                         = 0x466,
    Fulah_Nigeria                               = 0x467,
    Fulah_LatinSenegal                          = 0x867,
    Hausa                                       = 0x468,
    Ibibio_Nigeria                              = 0x469,
    Yoruba                                      = 0x46a,
    Quechua_Bolivia                             = 0x46b,
    Quechua_Ecuador                             = 0x86b,
    Quechua_Peru                                = 0xc6b,
    SesothoSaLeboa                              = 0x46c,
    Bashkir                                     = 0x46d,
    Luxembourgish                               = 0x46e,
    Greenlandic                                 = 0x46f,
    Igbo                                        = 0x470,
    Kanuri                                      = 0x471,
    Oromo                                       = 0x472,
    Tigrinya_Ethiopia                           = 0x473,
    Tigrinya_Eritrea                            = 0x873,
    Guarani                                     = 0x474,
    Hawaiian                                    = 0x475,
    Latin                                       = 0x476,
    Somali                                      = 0x477,
    Yi_PRC                                      = 0x478,
    Papiamentu                                  = 0x479,
    Mapudungun                                  = 0x47a,
    Mohawk                                      = 0x47c,
    Breton                                      = 0x47e,
    Uyghur_PRC                                  = 0x480,
    Maori                                       = 0x481,
    Occitan                                     = 0x482,
    Corsican                                    = 0x483,
    Alsatian                                    = 0x484,
    Sakha                                       = 0x485,
    Kiche                                       = 0x486,
    Kinyarwanda                                 = 0x487,
    Wolof                                       = 0x488,
    Dari                                        = 0x48c,
    ScottishGaelic_UnitedKingdom                = 0x491,
    CentralKurdish_Iraq                         = 0x492
};

struct DirectoryListingEntry {
    type::LEB128 nameLength;
    char name[nameLength];
    type::LEB128 contentSection;
    type::LEB128 offset;
    type::LEB128 length;
};

struct DirectoryIndexEntry {
    type::LEB128 nameLength;
    char name[nameLength];
    type::LEB128 directoryListingChunk;
};

struct ListingChunk {
    char magic[4];

    if (magic == "PMGL") {
        type::Size<u32> freeSpaceLength;
        u32;
        u32 prevChunkNumber, nextChunkNumber;

        u16 directoryListingEntryCount @ addressof(this) + parent.directoryChunkSize - 2;
        u16 offsets[(freeSpaceLength - 2) / 2] @ addressof(directoryListingEntryCount) - (freeSpaceLength - 2);

        DirectoryListingEntry directories[directoryListingEntryCount];

        $ = addressof(directoryListingEntryCount) + sizeof(directoryListingEntryCount);
    } else if (magic == "PMGI") {
        type::Size<u32> freeSpaceLength;

        u16 directoryIndexEntryCount @ addressof(this) + parent.directoryChunkSize - 2;
        u16 offsets[(freeSpaceLength - 2) / 2] @ addressof(directoryIndexEntryCount) - (freeSpaceLength - 2);

        DirectoryIndexEntry indexes[directoryIndexEntryCount];

        $ = addressof(directoryIndexEntryCount) + sizeof(directoryIndexEntryCount);
    } else {
        std::error("Invalid chunk magic!");
    }
};

struct HeaderSection {
    char magic[4];

    if (magic == "\xFE\x01\x00\x00") {
        u32;
        type::Size<u64> fileSize;
        u32;
        u32;
    } else if (magic == "ITSP") {
        u32 version;
        type::Size<u32> directoryHeaderLength1;
        u32;
        u32 directoryChunkSize;
        u32 quickRefSectionDensity;
        u32 indexTreeDepth;
        u32 rootIndexChunkNumber;
        u32 firstPMGLChunkNumber;
        u32 lastPMGLChunkNumber;
        u32;
        u32 directoryChunkCount;
        WindowsLanguageId languageId;
        type::GUID guid;
        type::Size<u32> directoryHeaderLength2;
        u32;
        u32;
        u32;

        ListingChunk chunk[directoryChunkCount];
    } else {
        std::error("Invalid header section magic!");
    }
};

struct HeaderSectionTableEntry {
    u64 offset;
    type::Size<u64> size;

    HeaderSection headerSection @ offset;
};

struct NameListEntry {
    type::Size<u16> nameLength;
    char16 name[nameLength];
    padding[2];
};

struct NameListFile {
    u16 fileLengthWords;
    u16 entriesInFile;

    NameListEntry nameList[entriesInFile];

    padding[0x2E];
};

struct SectionData {
    u32 fileLengthWords;
    type::Magic<"LZXC"> magic;
    u32 version;
    u32 lzxResetInterval;
    type::Size<u32> windowSize;
    type::Size<u32> cacheSize;
    u32;
};

struct Content {
    NameListFile nameListFile;
    SectionData sectionData;
};

struct CHM {
    type::Magic<"ITSF"> magic;
    u32 version;
    type::Size<u32> headerSize;
    u32;
    be u32 timeStamp;
    WindowsLanguageId languageId;
    type::GUID guids[2];

    HeaderSectionTableEntry headerSectionTable[2];

    Content *dataOffset : u64;
};

CHM chm @ 0x00;
