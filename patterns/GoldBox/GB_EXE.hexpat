#pragma author Draxinusom
#pragma description Gold Box Games - Executable
// Using the first record in the class table (Cleric in all) to auto identify target files
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00DDD9
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00C039
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00F2FC
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00B468
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00D58B
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00CF8E
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x067CC4
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x0067F5
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x00DDBF
#pragma magic [ 43 6C 65 72 69 63 ] @ 0x08903E
// Update this value if adding additional tables
#define DataTypeCount 49
import std.core;
import std.io;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the standard data tables embedded
 in the executable for all Gold Box games (D&D, no one cares about Buck Rogers)

 Supported Games:
 01 - Pool of Radiance v1.3 (START.EXE)
 02 - Curse of the Azure Bonds v1.3 (START.EXE)
 03 - Secret of the Silver Blades v1.3 (START.EXE)
 04 - Pools of Darkness v1.1 (GAME.EXE)
 05 - Champions of Krynn v1.2 (START.EXE)
 06 - Death Knights of Krynn v1.1 (START.EXE)
 07 - The Dark Queen of Krynn v1.1. (DQK.EXE)
 08 - Gateway to the Savage Frontier v1.2 (GAME.EXE)
 09 - Treasures of the Savage Frontier v1.0 (GAME.EXE)
 10 - Unlimited Adventures v1.2 (CKIT.EXE)

 To avoid making 10 separate patterns that would clutter the repo and also because
 I wanted to see if I could, they are all merged into this single pattern

 While most tables are found in each, not all are, and there is variability in record
 counts along with, obviously, none of the tables being located at the same offset

 To avoid making this a several thousands of lines long file by setting the values for each table's record
 count and offset for each game individually, two arrays are used with the RecordCount/Offset indexes paired

 This is then populated once the game executable is detected and used when setting the data placement
 Where a table does not exist, the record count is set to 0, this skips adding it when the pattern runs

 To add a new table, increase the DataTypeCount define at the top (currently 49) and add the count/offset
 to each game's array list in the same positions - probably easiest to just put them on the end
 If a game doesn't have that table, set the count to 0 and offset to whereever (I just used 0x00 for those)

 Note:
 This only supports the latest version of these games (GOG, WizWorks, and Steam (I assume but haven't checked that))
 as different versions will have different offsets for everything and I'm not about to track down every variant to get those

 Additionally, the executables for all but Dark Queen of Krynn and Unlimited Adventures must be decompressed first
 This can be done using the UNP utility which can be found at https://gbc.zorbus.net/unp411.zip (at least as of Jan 2026)
 That is a very old program so you must run it in DOSBOX, which you have to run the games in so I assume that's not a problem
 You can (and should if you want to modify things) replace the original executable with the decompressed version, it runs fine
**********/
u8 RecordCount[DataTypeCount];
u32 Offset[DataTypeCount];

// Set default DataType parameters
u8 GameID = 0;
u8 ClassAlignmentAllowed_Param = 8;
u8 ClassBaseSavePerLevel_Param = 12;
u8 ClassSpellAllowed_Param = 8;
u8 ClassTHAC0PerLevel_Param = 22;
u8 ClassXPPerLevel_Param = 12;
u8 RaceClassAge_Param = 7;
u8 RaceNameOffset = 0;
bool SPLCountIsTotal = false;
u8 TurnUndeadTypeLevel_Param = 0;
u8 String_Alignment_Param = 16;
u8 String_Class_Param = 26;
u8 String_CompassDirection_Param = 2;
u8 String_Diety_Param = 11;
u8 String_DiskMessage_Param = 29;
u8 String_Effect_Param = 37;
u8 String_Gender_Param = 6;
u8 String_IconModify_Param = 40;
u8 String_ItemNamePart_Param = 20;
u8 String_MenuCommand_Param = 40;
u8 String_Money_Param = 10;
u8 String_Race_Param = 9;
u8 String_Robe_Param = 6;
u8 String_SpellLevel_Param = 40;
u8 String_SpellName_Param = 40;
u8 String_Status_Param = 12;
u8 String_TempleSpell_Param = 40;

// Determine executable version and set overrides
u128 FileSize = std::mem::size();

// 01-Pool of Radiance (START.EXE)
if (FileSize == 70864) {
    GameID = 1;
    ClassBaseSavePerLevel_Param = 9;
    ClassTHAC0PerLevel_Param = 11;
    RaceNameOffset = 1;
    SPLCountIsTotal = true;
    TurnUndeadTypeLevel_Param = 1;
    u8 RecordCount_01[DataTypeCount] = {0x09, 0x11, 0x08, 0x00, 0x08, 0x00, 0x02, 0x05, 0xFF, 0x0B, 0x05, 0x07, 0x08, 0x00, 0x09, 0x38, 0x09, 0x0B, 0x11, 0x11, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00, 0x08, 0x08, 0x00, 0x08, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x09, 0x12, 0x13, 0x05, 0x0C, 0x0E, 0x43, 0x01, 0x0A, 0x00};
    u32 Offset_01[DataTypeCount] = {0x00DFF3, 0x00DDD8, 0x00F648, 0x000000, 0x00F6D2, 0x000000, 0x00E08C, 0x00D888, 0x00E15C, 0x00D6B9, 0x00D556, 0x00E09A, 0x00DFA3, 0x000000, 0x00DB42, 0x00F9B2, 0x00E0E7, 0x00D1BA, 0x011021, 0x011087, 0x000000, 0x011313, 0x010D8E, 0x00D956, 0x00D95E, 0x010D74, 0x011303, 0x000000, 0x000000, 0x010D1C, 0x010D7D, 0x000000, 0x011143, 0x010E53, 0x010FDB, 0x010F17, 0x010EC3, 0x010E1C, 0x010DE4, 0x010D9C, 0x011131, 0xDA12, 0x00DDC4, 0x00F91E, 0x00F910, 0x0102AA, 0x0106DA, 0x00D4F2, 0x000000};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_01[i];
        Offset[i] = Offset_01[i];
    }
}
// 02-Curse of the Azure Bonds (START.EXE)
else if (FileSize == 64384) {
    GameID = 2;
    ClassTHAC0PerLevel_Param = 13;
    RaceNameOffset = 1;
    TurnUndeadTypeLevel_Param = 1;

    u8 RecordCount_02[DataTypeCount] = {0x09, 0x12, 0x08, 0x00, 0x06, 0x00, 0x02, 0x05, 0xFF, 0x0C, 0x05, 0x07, 0x08, 0x00, 0x09, 0x64, 0x09, 0x0B, 0x11, 0x11, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00, 0x08, 0x08, 0x00, 0x08, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x0C, 0x17, 0x07, 0x05, 0x00, 0x00, 0x64, 0x01, 0x0A, 0x00};
    u32 Offset_02[DataTypeCount] = {0x00C26E, 0x00C038, 0x00D8C2, 0x000000, 0x00D94E, 0x000000, 0x00C307, 0x00BACC, 0x00C3D7, 0x00B8D3, 0x00B758, 0x00C315, 0x00C21E, 0x000000, 0x00BC20, 0x00DB68, 0x00C362, 0x00B466, 0x00F4F4, 0x00F55A, 0x000000, 0x00F943, 0x00F23B, 0x00BB9A, 0x00BBA2, 0x00F222, 0x00F933, 0x000000, 0x000000, 0x00F1BA, 0x00F22A, 0x000000, 0x00F61B, 0x00F318, 0x00F4AE, 0x00F3EA, 0x00F388, 0x00F2E1, 0x00F2A9, 0x00F249, 0x00F604, 0x00BBB0, 0x00C024, 0x000000, 0x000000, 0x00EB6C, 0x00F1AC, 0x00B6F4, 0x000000};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_02[i];
        Offset[i] = Offset_02[i];
    }
}
// 03-Secret of the Silver Blades (START.EXE)
else if (FileSize == 82208) {
    GameID = 3;
    ClassBaseSavePerLevel_Param = 18;
    ClassTHAC0PerLevel_Param = 19;
    RaceNameOffset = 1;
    String_Race_Param = 8;
    String_SpellLevel_Param = 3;
    String_SpellName_Param = 34;

    u8 RecordCount_03[DataTypeCount] = {0x09, 0x12, 0x08, 0x00, 0x05, 0x78, 0x02, 0x05, 0x7B, 0x0D, 0x04, 0x07, 0x08, 0x00, 0x09, 0x75, 0x09, 0x0B, 0x11, 0x11, 0x00, 0x07, 0x07, 0x07, 0x08, 0x07, 0x07, 0x00, 0x00, 0x07, 0x07, 0x00, 0x07, 0x06, 0x06, 0x06, 0x06, 0x0B, 0x06, 0x12, 0x17, 0x07, 0x05, 0x00, 0x00, 0x75, 0x01, 0x00, 0x00};
    u32 Offset_03[DataTypeCount] = {0x00F529, 0x00F2FB, 0x0100AA, 0x000000, 0x010156, 0x0109BD, 0x00F5C2, 0x00F052, 0x00F692, 0x00EE30, 0x00EB47, 0x00F5D0, 0x00F4E1, 0x000000, 0x00F155, 0x011C1E, 0x00F61D, 0x00E8BC, 0x0136B5, 0x01371B, 0x000000, 0x013D07, 0x013419, 0x00F120, 0x00F127, 0x013402, 0x013CF9, 0x000000, 0x000000, 0x01337C, 0x013409, 0x000000, 0x0137DC, 0x01351D, 0x013679, 0x0135D1, 0x01357D, 0x0134E6, 0x0134B6, 0x013426, 0x0137C5, 0xF19A, 0x00F2B0, 0x000000, 0x000000, 0x012C1D, 0x01336E, 0x000000, 0x000000};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_03[i];
        Offset[i] = Offset_03[i];
    }
}
// 04-Pools of Darkness (GAME.EXE)
else if (FileSize == 74736) {
    GameID = 4;
    ClassBaseSavePerLevel_Param = 21;
    SPLCountIsTotal = true;
    String_IconModify_Param = 45;
    String_Race_Param = 8;
    String_SpellName_Param = 34;

    u8 RecordCount_04[DataTypeCount] = {0x09, 0x12, 0x08, 0x00, 0x05, 0x7F, 0x02, 0x05, 0x7D, 0x0D, 0x02, 0x03, 0x08, 0x00, 0x0A, 0x7E, 0x09, 0x00, 0x11, 0x11, 0x00, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x00, 0x00, 0x07, 0x07, 0x00, 0x07, 0x06, 0x06, 0x06, 0x06, 0x0B, 0x06, 0x12, 0x17, 0x00, 0x00, 0x00, 0x00, 0x7E, 0x01, 0x0D, 0x07};
    u32 Offset_04[DataTypeCount] = {0x00B68C, 0x00B467, 0x00E3A6, 0x000000, 0x00E41A, 0x00E697, 0x00B725, 0x00D7CF, 0x00D964, 0x00B7C9, 0x00D54A, 0x00B733, 0x00B64D, 0x000000, 0x00B0BC, 0x00FA00, 0x00B754, 0x000000, 0x01169F, 0x011705, 0x000000, 0x01200F, 0x0113D9, 0x0113E0, 0x0113E7, 0x0113C2, 0x012001, 0x000000, 0x000000, 0x011328, 0x0113C9, 0x000000, 0x0117C6, 0x011507, 0x011663, 0x0115BB, 0x011567, 0x0114B4, 0x011484, 0x0113F4, 0x0117AF, 0x000000, 0x000000, 0x000000, 0x000000, 0x010B3A, 0x01131A, 0x00B016, 0x0114EB};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_04[i];
        Offset[i] = Offset_04[i];
    }
}
// 05-Champions of Krynn (START.EXE)
else if (FileSize == 68080) {
    GameID = 5;
    ClassAlignmentAllowed_Param = 1;
    ClassSpellAllowed_Param = 4;
    ClassTHAC0PerLevel_Param = 13;
    TurnUndeadTypeLevel_Param = 5;
    RaceClassAge_Param = 8;
    String_Race_Param = 15;

    u8 RecordCount_05[DataTypeCount] = {0x09, 0x12, 0x08, 0x08, 0x03, 0x00, 0x02, 0x05, 0x7B, 0x0D, 0x04, 0x07, 0x08, 0x04, 0x0A, 0x6B, 0x09, 0x0B, 0x11, 0x11, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x01, 0x00, 0x08, 0x08, 0x00, 0x0A, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x0C, 0x17, 0x07, 0x05, 0x00, 0x00, 0x6B, 0x01, 0x0C, 0x00};
    u32 Offset_05[DataTypeCount] = {0x00D7F0, 0x00D58A, 0x00E3EC, 0x00D889, 0x00E498, 0x000000, 0x00D905, 0x00D0D0, 0x00D9D5, 0x00CEA8, 0x00CB1E, 0x00D913, 0x00D770, 0x00D8E9, 0x00D22A, 0x00E6D0, 0x00D960, 0x00C7FC, 0x01020F, 0x010275, 0x000000, 0x01068B, 0x00FF33, 0x00D19E, 0x00D1A6, 0x00FF1A, 0x01067B, 0x01086B, 0x000000, 0x00FEB2, 0x00FF22, 0x000000, 0x01029D, 0x010010, 0x0101C9, 0x0100E9, 0x010080, 0x00FFD9, 0x00FFA1, 0x00FF41, 0x010286, 0x00D1BA, 0x00D576, 0x000000, 0x000000, 0x00F7F3, 0x00FEA4, 0x00CA82, 0x000000};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_05[i];
        Offset[i] = Offset_05[i];
    }
}
// 06-Death Knights of Krynn (START.EXE)
else if (FileSize == 84896) {
    GameID = 6;
    ClassAlignmentAllowed_Param = 1;
    ClassBaseSavePerLevel_Param = 18;
    ClassTHAC0PerLevel_Param = 19;
    RaceClassAge_Param = 8;
    String_Race_Param = 15;
    String_SpellLevel_Param = 10;

    u8 RecordCount_06[DataTypeCount] = {0x09, 0x12, 0x08, 0x08, 0x05, 0x79, 0x02, 0x05, 0x7D, 0x0D, 0x01, 0x07, 0x08, 0x04, 0x0D, 0x72, 0x09, 0x00, 0x11, 0x11, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x01, 0x00, 0x08, 0x08, 0x00, 0x0B, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x12, 0x17, 0x00, 0x00, 0x00, 0x00, 0x72, 0x01, 0x0D, 0x00};
    u32 Offset_06[DataTypeCount] = {0x00D1F3, 0x00CF8D, 0x010948, 0x00D28C, 0x010A32, 0x010C95, 0x00D308, 0x00FCC6, 0x00FEDF, 0x00D3D8, 0x00FAFF, 0x00D316, 0x00D173, 0x00D2EC, 0x00FE50, 0x011F2E, 0x00D363, 0x000000, 0x013C92, 0x013CF8, 0x000000, 0x0145F4, 0x013984, 0x00CD36, 0x00CD3E, 0x01396A, 0x0145E4, 0x0148C4, 0x000000, 0x0138D2, 0x013973, 0x000000, 0x013D20, 0x013A93, 0x013C4C, 0x013B6C, 0x013B03, 0x013A5C, 0x013A24, 0x013994, 0x013D09, 0x000000, 0x000000, 0x000000, 0x000000, 0x013170, 0x013890, 0x00CC90, 0x000000};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_06[i];
        Offset[i] = Offset_06[i];
    }
}
// 07-The Dark Queen of Krynn (DQK.EXE) - Does not need decompressed
else if (FileSize == 449664) {
    GameID = 7;
    ClassAlignmentAllowed_Param = 16;
    ClassBaseSavePerLevel_Param = 22;
    ClassSpellAllowed_Param = 9;
    ClassXPPerLevel_Param = 19;
    SPLCountIsTotal = true;
    String_Alignment_Param = 0;
    String_Class_Param = 0;
    String_CompassDirection_Param = 3;
    String_Diety_Param = 0;
    String_Effect_Param = 0;
    String_Gender_Param = 0;
    String_ItemNamePart_Param = 0;
    String_Money_Param = 0;
    String_Race_Param = 0;
    String_Robe_Param = 0;
    String_SpellName_Param = 0;
    String_Status_Param = 0;

    u8 RecordCount_07[DataTypeCount] = {0x09, 0x14, 0x08, 0x08, 0x00, 0x45, 0x02, 0x00, 0x8E, 0x00, 0x00, 0x03, 0x08, 0x03, 0x0A, 0x73, 0x0A, 0x00, 0x11, 0x11, 0x11, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x01, 0x08, 0x07, 0x07, 0x0B, 0x00, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x12, 0x17, 0x00, 0x00, 0x00, 0x00, 0x8D, 0x01, 0x0D, 0x0B};
    u32 Offset_07[DataTypeCount] = {0x067E17, 0x067CC4, 0x069B78, 0x067EFB, 0x000000, 0x06A35F, 0x067E8F, 0x000000, 0x068C8D, 0x000000, 0x000000, 0x067E9B, 0x067DC1, 0x067F3B, 0x06C54D, 0x066E3D, 0x067EAE, 0x000000, 0x063F1D, 0x063F83, 0x0640E8, 0x064DEC, 0x069E2A, 0x069E31, 0x069E38, 0x069E13, 0x064DDE, 0x0650EE, 0x0645B6, 0x069D79, 0x069E1A, 0x064272, 0x000000, 0x063CD8, 0x063ED7, 0x063E13, 0x063D48, 0x069F0D, 0x069ED5, 0x069E45, 0x064250, 0x000000, 0x000000, 0x000000, 0x000000, 0x06621F, 0x069D6B, 0x06948A, 0x063CAC};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_07[i];
        Offset[i] = Offset_07[i];
    }
}
// 08-Gateway to the Savage Frontier (GAME.EXE)
else if (FileSize == 42128) {
    GameID = 8;
    ClassTHAC0PerLevel_Param = 13;
    RaceNameOffset = 1;
    TurnUndeadTypeLevel_Param = 1;

    u8 RecordCount_08[DataTypeCount] = {0x09, 0x12, 0x08, 0x00, 0x07, 0x00, 0x02, 0x05, 0xFF, 0x0E, 0x05, 0x07, 0x08, 0x00, 0x09, 0x64, 0x09, 0x0B, 0x11, 0x11, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x00, 0x00, 0x08, 0x08, 0x00, 0x08, 0x07, 0x07, 0x07, 0x07, 0x0B, 0x07, 0x0C, 0x17, 0x08, 0x05, 0x00, 0x00, 0x64, 0x01, 0x0A, 0x07};
    u32 Offset_08[DataTypeCount] = {0x006A2A, 0x0067F4, 0x008084, 0x000000, 0x0080E6, 0x000000, 0x006AC4, 0x005F94, 0x006B96, 0x005D48, 0x0054E0, 0x006AD2, 0x0069DA, 0x000000, 0x0060F8, 0x00839A, 0x006B20, 0x0051E6, 0x009D44, 0x009DAA, 0x000000, 0x00A194, 0x009A6E, 0x006062, 0x00606A, 0x009A54, 0x00A184, 0x000000, 0x000000, 0x0099EC, 0x009A5C, 0x000000, 0x009E6C, 0x009B68, 0x009CFE, 0x009C3A, 0x009BD8, 0x009B14, 0x009ADC, 0x009A7C, 0x009E54, 0x006078, 0x0067E0, 0x000000, 0x000000, 0x00939E, 0x0099DE, 0x00547C, 0x009B4C};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_08[i];
        Offset[i] = Offset_08[i];
    }
}
// 09-Treasures of the Savage Frontier (GAME.EXE)
else if (FileSize == 81872) {
    GameID = 9;
    ClassBaseSavePerLevel_Param = 21;
    SPLCountIsTotal = true;
    String_IconModify_Param = 45;
    String_Race_Param = 8;
    String_SpellName_Param = 34;

    u8 RecordCount_09[DataTypeCount] = {0x09, 0x12, 0x08, 0x00, 0x00, 0x00, 0x02, 0x05, 0xB5, 0x0D, 0x01, 0x03, 0x08, 0x00, 0x0A, 0x7E, 0x09, 0x00, 0x11, 0x11, 0x00, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x00, 0x00, 0x07, 0x07, 0x00, 0x07, 0x06, 0x06, 0x06, 0x06, 0x0B, 0x06, 0x12, 0x17, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x01, 0x0D, 0x07};
    u32 Offset_09[DataTypeCount] = {0x00DFE4, 0x00DDBE, 0x01127A, 0x000000, 0x000000, 0x000000, 0x00E07E, 0x0101E0, 0x0103A0, 0x00E124, 0x00FF4C, 0x00E08C, 0x00DFA4, 0x000000, 0x00DB14, 0x011590, 0x00E0AE, 0x000000, 0x013246, 0x0132AC, 0x000000, 0x013BB8, 0x012F7C, 0x012F84, 0x012F8C, 0x012F62, 0x013BAA, 0x000000, 0x000000, 0x012EC8, 0x012F6A, 0x000000, 0x01336E, 0x0130AE, 0x01320A, 0x013162, 0x01310E, 0x01305A, 0x01302A, 0x012F9A, 0x013356, 0x000000, 0x000000, 0x000000, 0x000000, 0x0126CA, 0x012EBA, 0x00DA6E, 0x013092};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_09[i];
        Offset[i] = Offset_09[i];
    }
}
// 10-Unlimited Adventures (CKIT.EXE) - Does not need decompressed
else if (FileSize == 587843) {
    GameID = 10;
    ClassAlignmentAllowed_Param = 16;
    ClassBaseSavePerLevel_Param = 22;
    SPLCountIsTotal = true;
    String_Alignment_Param = 0;
    String_Class_Param = 0;
    String_CompassDirection_Param = 3;
    String_Effect_Param = 0;
    String_Gender_Param = 0;
    String_ItemNamePart_Param = 0;
    String_Money_Param = 0;
    String_Race_Param = 0;
    String_SpellName_Param = 0;
    String_Status_Param = 0;

    u8 RecordCount_10[DataTypeCount] = {0x09, 0x11, 0x08, 0x00, 0x00, 0x46, 0x02, 0x00, 0x75, 0x00, 0x00, 0x03, 0x07, 0x00, 0x0A, 0x73, 0x09, 0x00, 0x11, 0x11, 0x00, 0x06, 0x07, 0x07, 0x07, 0x07, 0x07, 0x01, 0x04, 0x07, 0x07, 0x07, 0x00, 0x06, 0x06, 0x06, 0x06, 0x0B, 0x06, 0x12, 0x17, 0x00, 0x00, 0x00, 0x00, 0x8A, 0x01, 0x0D, 0x07};
    u32 Offset_10[DataTypeCount] = {0x089133, 0x08C216, 0x08B012, 0x000000, 0x000000, 0x08B789, 0x0891AB, 0x000000, 0x089FF8, 0x000000, 0x000000, 0x0891B7, 0x089103, 0x000000, 0x08D6B5, 0x08829C, 0x0891CD, 0x000000, 0x086218, 0x08627E, 0x000000, 0x086976, 0x08B2C2, 0x08B2C9, 0x08B2D0, 0x08B2AB, 0x086968, 0x085F42, 0x086554, 0x08B211, 0x08B2B2, 0x086404, 0x000000, 0x086032, 0x0861DC, 0x086134, 0x086092, 0x08B39D, 0x08B36D, 0x08B2DD, 0x0863E6, 0x000000, 0x000000, 0x000000, 0x000000, 0x0876C0, 0x08B203, 0x08A6C8, 0x085F26};

    for (u8 i = 0, i < DataTypeCount, i = i + 1) {
        RecordCount[i] = RecordCount_10[i];
        Offset[i] = Offset_10[i];
    }
}
// Compressed Executable
else if (FileSize == 65231 || FileSize == 57789 || FileSize == 72097 || FileSize == 64203 || FileSize == 61607 || FileSize == 74299 || FileSize == 36603 || FileSize == 71971) {
    std::warning("Compressed executable found. Decompress using the UNP utility first.");
    std::warning("The UNP utility can be found at: https://gbc.zorbus.net/unp411.zip (as of 2026-01)");
    return;
}
// Unknown file
else {
    std::warning("This pattern is only intended to work with decompressed versions of the Gold Box D&D game executables.");
    return;
}

/*******************************
    Enumerations
*******************************/
// Alignment - 1-6/8-9
enum ALIGNMENT_A:u8 {
    LawfulGood = 0,
    LawfulNeutral = 1,
    LawfulEvil = 2,
    NeutralGood = 3,
    TrueNeutral = 4,
    NeutralEvil = 5,
    ChaoticGood = 6,
    ChaoticNeutral = 7,
    ChaoticEvil = 8
};

// Alignment - 7/10
enum ALIGNMENT_B:u16 {
    LawfulGood = 0,
    LawfulNeutral = 1,
    LawfulEvil = 2,
    NeutralGood = 3,
    TrueNeutral = 4,
    NeutralEvil = 5,
    ChaoticGood = 6,
    ChaoticNeutral = 7,
    ChaoticEvil = 8
};

// Class - 1-4/8-9
enum CLASS_A:u8 {
    Cleric = 0,
    Druid = 1,
    Fighter = 2,
    Paladin = 3,
    Ranger = 4,
    MagicUser = 5,
    Thief = 6,
    Monk = 7,
    Cleric_Fighter = 8,
    Cleric_Fighter_MagicUser = 9,
    Cleric_Ranger = 10,
    Cleric_MagicUser = 11,
    Cleric_Thief = 12,
    Fighter_MagicUser = 13,
    Fighter_Thief = 14,
    Fighter_MagicUser_Thief = 15,
    MagicUser_Thief = 16,
    Monster = 17
};

// Class - 5-6
enum CLASS_B:u8 {
    Cleric = 0,
    Druid = 1,
    Fighter = 2,
    Paladin = 3,
    Ranger = 4,
    MagicUser = 5,
    Thief = 6,
    Knight = 7,
    Cleric_Fighter = 8,
    Cleric_Fighter_MagicUser = 9,
    Cleric_Ranger = 10,
    Cleric_MagicUser = 11,
    Cleric_Thief = 12,
    Fighter_MagicUser = 13,
    Fighter_Thief = 14,
    Fighter_MagicUser_Thief = 15,
    MagicUser_Thief = 16,
    Monster = 17
};

// Class - 7/10
enum CLASS_C:u16 {
    Cleric = 0,
    Knight = 1,
    Fighter = 2,
    Paladin = 3,
    Ranger = 4,
    MagicUser = 5,
    Thief = 6,
    Monk = 7,
    Cleric_Fighter = 8,
    Cleric_Fighter_MagicUser = 9,
    Cleric_Ranger = 10,
    Cleric_MagicUser = 11,
    Cleric_Thief = 12,
    Fighter_MagicUser = 13,
    Fighter_Thief = 14,
    Fighter_MagicUser_Thief = 15,
    MagicUser_Thief = 16,
    Monster = 17
};

// Class Alignment Allowed - 5/6
bitfield CLASSALIGNARRAY{
    LawfulGood : 1;
    LawfulNeutral : 1;
    NeutralGood : 1;
    TrueNeutral : 1;
    ChaoticGood : 1;
    ChaoticEvil : 1;
    padding : 2;
};

// Item Class Restrictions - 1
bitfield CLASSRESTRICTION_A {
    MagicUser : 1;
    Cleric : 1;
    Thief : 1;
    Fighter : 1;
    Monk : 1;
    Druid : 1;
    Paladin : 1;
    Ranger : 1;
};

// Item Class Restrictions - 2/8
bitfield CLASSRESTRICTION_B {
    MagicUser : 1;
    Cleric : 1;
    Thief : 1;
    Fighter : 1;
    Druid : 1;
    Monk : 1;
    PaladinRanger : 1;
    padding : 1;
};

// Item Class Restrictions - 3-4/9-10
bitfield CLASSRESTRICTION_C {
    MagicUser : 1;
    Cleric : 1;
    Thief : 1;
    Fighter : 1;
    Knight : 1;
    Druid : 1;
    PaladinRanger : 1;
    padding : 1;
};

// Item Class Restrictions - 5-7
bitfield CLASSRESTRICTION_D {
    MagicUser : 1;
    Cleric : 1;
    Thief : 1;
    Fighter : 1;
    Knight : 1;
    Druid : 1;
    Paladin : 1;
    Ranger : 1;
};

// Spell - Class - 1
enum SPELLCLASS_A:u8 {
    Cleric = 0,
    MagicUser = 1,
    Item = 2
};

// Spell - Class - 2/4/8/9
enum SPELLCLASS_B:u8 {
    Cleric = 0,
    Druid = 1,
    MagicUser = 2,
    Item = 3
};

// Spell - Class - 3/5/6
enum SPELLCLASS_C:u8 {
    Cleric = 0,
    Druid = 1,
    Special = 2,
    MagicUser = 3,
    Item = 4
};

// Spell - Class - 7/10 - 255 is 7 only
enum SPELLCLASS_D:u16 {
    Cleric = 0,
    Druid = 1,
    MagicUser = 2,
    Special = 3,
    Item = 4,
    ClericEvil = 255
};

// Spell - Area_Camp - 1/2/5/8
enum AREACAMP_A:u8 {
    None = 0,
    Caster = 1,
    Target_1 = 2,
    Invalid = 3,
    All = 4
};

// Spell - Area_Camp - 3-4/6/9
enum AREACAMP_B:u8 {
    None = 0,
    Caster = 1,
    Target_1 = 2,
    All = 3
};

// Spell - Area_Camp - 7/10
enum AREACAMP_C:u16 {
    None = 0,
    Caster = 1,
    Target_1 = 2,
    All = 3
};

// Spell - Area_Combat
enum AREACOMBAT:u8 {
    Caster = 0,
    All = 3,
    Target_1 = 4,
    Target_Var = 5,
    Target_1_3 = 6,
    Target_1_4 = 7,
    LineCone = 8,
    Other = 9,
    Area_5x5 = 10,
    Area_7x7 = 11,
    TargetArea_3x3 = 14,
    TargetArea_3x3 = 31,
    Target_LVL = 240
};

// Spell - Type - 1-6/8-9
enum SPELLTYPE_A:u8 {
    Camp = 0,
    Combat = 1,
    Both = 2
};

// Spell - Type - 7/10
enum SPELLTYPE_B:u16 {
    Camp = 0,
    Combat = 1,
    Both = 2
};

// Spell - SAV_Action - 1-6/8-9
enum SAV_ACTION_A:u8 {
    None = 0,
    Negate = 1,
    Half = 2,
    Special = 3
};

// Spell - SAV_Action - 7/10
enum SAV_ACTION_B:u16 {
    None = 0,
    Negate = 1,
    Half = 2,
    Special = 3
};

// Spell - SAV_Type - 1-6/8-9
enum SAV_TYPE_A:u8 {
    SAV_1_PPD = 0,
    SAV_2_PP = 1,
    SAV_3_RSW = 2,
    SAV_4_BW = 3,
    SAV_5_S = 4
};

// Spell - SAV_Type - 7/10
enum SAV_TYPE_B:u16 {
    SAV_1_PPD = 0,
    SAV_2_PP = 1,
    SAV_3_RSW = 2,
    SAV_4_BW = 3,
    SAV_5_S = 4
};

/*******************************
    Functions
*******************************/
// Formatting function for AC/THAC0 (RW)
fn FormatACTHAC0 (u8 Input) {
    s8 Val = 60 - Input;
    return Val;
};

// Formatting function for SPLBASE.CastTime
fn FormatCastTime (u8 Input) {
    u8 TempVal = (Input / 3);
    str ReturnVal = TempVal == 0 ? "-" : std::format("{:.1f}", TempVal * 0.1);
    return ReturnVal;
};

// Formatting function for Turn Undead values - Write function didn't work right (at all), so need to directly edit the hex
fn FormatTurnUndead(u8 Input) {
    str TurnVal;
    if (Input == 0x63) {
        TurnVal = "-";  // Cannot turn
    }
    else if (Input == 0) {
        TurnVal = "D";  // Auto Destroy 1-12
    }
    else if (Input == 1) {
        TurnVal = "T";  // Auto Turn 1-12
    }
    else if (Input == 255) {
        TurnVal = "D*"; // Auto Destroy 7-12
    }
    else {
        TurnVal = std::string::to_string(Input);
    }

    return TurnVal;
};

// Formatting function for Class names in ClassXPPerLevel/ClassXPSpellPerLevel (5-7)
fn KrynnClassName(u8 Input) {
    if (Input == 0) {
        return "Cleric of Good";
    }
    else if (Input == 1) {
        return "Cleric of Neutrality";
    }
    else if (Input == 2) {
        return "Fighter";
    }
    else if (Input == 3) {
        return "Knight of the Crown";
    }
    else if (Input == 4) {
        return "Knight of the Sword";
    }
    else if (Input == 5) {
        return "Knight of the Rose";
    }
    else if (Input == 6) {
        return "Ranger";
    }
    else if (Input == 7) {
        return "White Robe Mage";
    }
    else if (Input == 8) {
        return "Red Robe Mage";
    }
    else if (Input == 9) {
        return "Thief";
    }
    else if (Input == 10) {
        return "Paladin";
    }
    else {
        return "Unknown";
    }
};

// Formatting function for Class names in CLASSSPELLPERLVL (7/10)
fn CasterClassName(u8 Input) {
    if (GameID == 7) {
        if (Input == 0) {
            return "Cleric of Good";
        }
        else if (Input == 1) {
            return "Cleric of Neutrality";
        }
        else if (Input == 2) {
            return "Knight of the Sword";
        }
        else if (Input == 3) {
            return "Knight of the Rose";
        }
        else if (Input == 4) {
            return "Ranger";
        }
        else if (Input == 5) {
            return "White Robe Mage";
        }
        else if (Input == 6) {
            return "Red Robe Mage";
        }
        else if (Input == 7) {
            return "Paladin";
        }
    }
    else if (GameID == 10) {
        if (Input == 0) {
            return "Cleric";
        }
        else if (Input == 1) {
            return "Paladin";
        }
        else if (Input == 2) {
            return "Ranger";
        }
        else if (Input == 3) {
            return "Magic-User";
        }
    }
    return "Unknown";
};

// Formatting function for Undead level/names in TurnUndeadTypeLevel
fn UndeadLevelName(u8 Input) {
    if (Input == 0) {
        return "01: Skeleton";
    }
    else if (Input == 1) {
        return "02: Zombie";
    }
    else if (Input == 2) {
        return "03: Ghoul";
    }
    else if (Input == 3) {
        return "04: Shadow";
    }
    else if (Input == 4) {
        return "05: Wight";
    }
    else if (Input == 5) {
        return "06: Ghast";
    }
    else if (Input == 6) {
        return "07: Wraith";
    }
    else if (Input == 7) {
        return "08: Mummy";
    }
    else if (Input == 8) {
        return "09: Spectre";
    }
    else if (Input == 9) {
        return "10: Vampire";
    }
    else if (Input == 10) {
        return "11: Ghost";
    }
    else if (Input == 11) {
        return "12: Lich";
    }
    else if (Input == 12) {
        return "13: Special";
    }
    else {
        return "Unknown";
    }
};

// Formatting function for ItemRandom.NamePart[1-3] - Used to blank 0s and avoid creating enumerations for each game (1-3/5/8)
fn GetItemName(u8 Input) {
    if (Input == 0) {
        return "";
    }
    return std::format("{}",  Input < std::core::member_count(String_ItemNamePart) ? String_ItemNamePart[Input -1].String : "Undefined");
};

// Formatiting function to display the spell name for the records in SpellBase
fn GetSpellName(u8 Input) {
    if (Input == 0) {
        return "-";
    }
    return std::format("{:03d}: {}", Input, Input < std::core::member_count(String_SpellName) ? String_SpellName[Input -1].String : "Undefined");
};

/*******************************
    String Structs
*******************************/
// Generic String struct
struct STRING<auto Size> {
// NULL terminated strings in 7/10
    if (Size == 0) {
        char String[] [[format("std::string::to_string")]];
    }
// Workaround for fixed length without Length value for compass strings in 7/10
    else if (Size == 3 && $ > 0x069B77) {
        char String[Size] [[format("std::string::to_string")]];
    }
// Standard PASCAL style strings in 1-6/8-9
    else {
        u8 Length [[hidden]];
        char String[Size] [[format("std::string::to_string")]];
    }
} [[inline]];

// String_MenuCommand
/***
    Main Menu (create char/load game/etc) has a trailing boolean value
    Need to double check, but guessing this is what controls hiding
    some options after you load a saved game - need to doublecheck
***/
struct MAINMENU {
    STRING<40> String;
    bool Unknown_29;
};

/*******************************
    Class Structs
*******************************/
// ClassAbilityMin - Generic name in case I find another dataset using this
struct BASEABILITY {
    u8 STR [[comment("Strength value")]];
    u8 INT [[comment("Intelligence value")]];
    u8 WIS [[comment("Wisdom value")]];
    u8 DEX [[comment("Dexterity value")]];
    u8 CON [[comment("Constitution value")]];
    u8 CHA [[comment("Charisma value")]];
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("Minimum class ability values")]];

// ClassAlignmentAllowed/ClassAlignmentAllowedDwarf (Dwarf is 7 only - used to force neutral for clerics)
struct CLASSALIGN<auto Size> {
// 5-6 uses bit array - this works here as you cannot pick evil alignments in the Krynn games
    if (Size == 1) {
        CLASSALIGNARRAY Alignment [[inline]];
    }
    else {
        u8 AlignmentCount [[comment("Number of alignments allowed\nModify this value to match if adding/removing alignments")]];
    // 1-4/8-9
        if (Size == 8) {
            ALIGNMENT_A Alignment[AlignmentCount] [[inline]];
            padding[9 - AlignmentCount];
        }
    // 7/10 - u16 values - 7 has junk data in the padding area for some
        else {
            ALIGNMENT_B Alignment[AlignmentCount] [[inline]];
            padding[20 - (AlignmentCount * 2)];
        }
    }
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("Available alignments for this class")]];

// Generic Class array
/***
    Generic single value per class array used for:
    ClassHDLevelMax
    ClassHDStartCount
    ClassHDType
    ClassTrainCode
***/
struct CLASSARRAY<Type> {
    Type Value [[name(std::format("{}", String_Class[std::core::array_index()].String))]];
} [[inline]];

// ClassMoneyBase
struct CLASSMONEYBASE {
    u8 DiceCount [[comment("Number of rolls to make")]];
    u8 DiceType [[comment("Dice type (d4/d6/d8/etc) rolled")]];
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("New character starting money per class")]];

// ClassItemAllowed
/***
    Bitmask value compared against ItemBase.ItemRestriction to control equippable/usable items by class
    Note:  The Ranger class is only set correctly in 5-7, it has the Paladin flag set instead in 1-4/8-10
    This ultimately doesn't matter as all items with the Paladin flag set also has the Ranger flag set
    I don't believe there's a difference in allowed weapons between those two classes (or with fighters)
    in 1e so, despite being set wrong, it still ends up working correctly
***/
struct CLASSRESTRICTION<auto GameID> {
// Minor variations in bit values/classes
    match (GameID) {
        (1): CLASSRESTRICTION_A ClassItemAllowed [[inline,comment("Item restriction class")]];
        (2|8): CLASSRESTRICTION_B ClassItemAllowed [[inline,comment("Item restriction class")]];
        (3|4|9|10): CLASSRESTRICTION_C ClassItemAllowed [[inline,comment("Item restriction class")]];
        (5|6|7): CLASSRESTRICTION_D ClassItemAllowed [[inline,comment("Item restriction class")]];
    }
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("Item restriction flags for this class")]];

/***********************
  ClassTHAC0PerLevel
***********************/
// Child struct of CLASSTHAC0PERLVL - Used to get format/name/comment attributes to work correctly
struct THAC0BASE {
    u8 THAC0Base [[format("FormatACTHAC0"),format_write("FormatACTHAC0"),name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment(std::format("Base THAC0 at level {:d}", std::core::array_index() +1))]];
} [[inline]];

// ClassTHAC0PerLevel
struct CLASSTHAC0PERLVL<auto Size> {
    THAC0BASE THAC0[Size] [[inline]];
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("Base THAC0 value per level")]];

/***********************
  ClassSpellAllowed
***********************/
// Child struct of SPELLALLOWED - Used to get format attribute to work correctly
struct SPELLNAME {
    u8 Spell [[format("GetSpellName")]];
} [[inline]];

// Child struct of CLASSSPELLALLOWED - Used to get the level groupings/names to work correctly
struct SPELLALLOWED {
    SPELLNAME SpellID[10] [[inline]];
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment(std::format("Level {:d} spells allowed", std::core::array_index() +1))]];

// ClassSpellAllowed - 5-7/10 - Note:  While data is there, this is unused in 10
struct CLASSSPELLALLOWED<auto Size> {
    SPELLALLOWED Cleric[Size] [[comment("Cleric class spells available to player Clerics")]];
    SPELLALLOWED White[Size] [[comment("Magic-User class spells available to player White Robe mages")]];
    SPELLALLOWED Red[Size] [[comment("Magic-User class spells available to player Red Robe mages")]];
} [[inline]];

/***********************
  ClassBaseSavePerLevel
***********************/
// Child struct of CLASSBASESAVE - Used to get level groupings/names to work correctly
struct SAVEPERLVL {
    u8 SAV1_PPD [[name("Paralyzation, Poison, or Death Magic")]];
    u8 SAV2_PP [[name("Petrification or Polymorph")]];
    u8 SAV3_RSW [[name("Rod, Staff, or Wand")]];
    u8 SAV4_BW [[name("Breath Weapon")]];
    u8 SAV5_SPL [[name("Spell")]];
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment(std::format("Class base saving throw values at level {:d}", std::core::array_index() +1))]];

// ClassBaseSavePerLevel
struct CLASSBASESAVE<auto Size> {
    SAVEPERLVL SavePerLevel[Size] [[inline]];
} [[name(std::format("{}", String_Class[std::core::array_index()].String)),comment("Class base saving throw per level")]];

/***********************
  ClassSpellPerLevel 7/10
  ClassXPPerLevel 7/10
  ClassXPSpellPerLevel 1-6/8-9

  Variation between 7/10 and other games as to how this is handled
  1-6/8-9 has merges XP/SpellCounts into a single class record
  7/10 has this split into 2 separate tables, with SpellCount only
  containing classes that has spells

  Both variants use the SPL_COUNT & CLASSSPELLPERLVLRANGER child structs
  so bundling this under the same heading
***********************/
// Child struct for most of these - Should probably rewrite this as a template array but this works
struct SPL_COUNT<auto Size> {
    u8 SPL_1 [[comment(std::format("{} number of level 1 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    if (Size > 1) {
        u8 SPL_2 [[comment(std::format("{} number of level 2 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 2) {
        u8 SPL_3 [[comment(std::format("{} number of level 3 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 3) {
        u8 SPL_4 [[comment(std::format("{} number of level 4 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 4) {
        u8 SPL_5 [[comment(std::format("{} number of level 5 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 5) {
        u8 SPL_6 [[comment(std::format("{} number of level 6 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
        u8 SPL_7 [[comment(std::format("{} number of level 7 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 7) {
        u8 SPL_8 [[comment(std::format("{} number of level 8 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
    if (Size > 8) {
        u8 SPL_9 [[comment(std::format("{} number of level 9 spells the character can memorize", SPLCountIsTotal ? "Total" : "Additional"))]];
    }
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment(std::format("Number of spells this class can memorize at level {:d}", std::core::array_index() +1))]];

// Child struct of CLASSXPPERLVL/CLASSXPSPELLPERLVL - Used to get name/comment attributes to work
struct XPPERLVL {
    s32 XP [[name(std::format("LVL_{:02d}", (GameID == 4 || GameID == 9) ? 1 + std::core::array_index() : std::core::array_index())),comment(std::format("Total XP required for level {:d}", (GameID == 4 || GameID == 9) ? 1 + std::core::array_index() : std::core::array_index()))]];
}  [[inline]];

// Child struct of CLASS*SPELL* structs - Used to handle Ranger's Druid/MagicUser split
struct CLASSSPELLPERLVLRANGER<auto DRCount, auto MUCount> {
    SPL_COUNT<DRCount> Druid [[name("Druid"),comment(std::format("Number of Druid spells this class can memorize at level {:d}", std::core::array_index() +1))]];
    SPL_COUNT<MUCount> MagicUser [[name("Magic-User"),comment(std::format("Number of Magic-User spells this class can memorize at level {:d}", std::core::array_index() +1))]];
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment(std::format("Number of spells this class can memorize at level {:d}", std::core::array_index() +1))]];

// ClassSpellPerLevel - 7/10
struct CLASSSPELLPERLVL {
    if ((GameID == 7 && std::core::array_index() == 4) || (GameID == 10 && std::core::array_index() == 2)) {
        CLASSSPELLPERLVLRANGER<4,5> SpellPerLVL[29] [[inline]];
    }
    else {
        SPL_COUNT<9> SpellPerLVL[29] [[inline]];
    }
} [[name(CasterClassName(std::core::array_index())),comment("Total number of spells this class can memorize per level")]];

// ClassXPPerLevel - 7/10
struct CLASSXPPERLVL<auto Size> {
    XPPERLVL XP[Size] [[inline]];
} [[name(std::format("{}", GameID == 7 ? KrynnClassName(std::core::array_index()) : String_Class[std::core::array_index()].String)),comment("Fixed XP required per level")]];

// Child struct of CLASSXPSPELLPERLVL - 1-3/5-6/8 - Used to handle offset from XP and inline the spell levels
struct CLASSXPSPELLLVL<auto GameID, auto ClassID> {
    s32 XP [[comment(std::format("XP required to advance to level {:d}", std::core::array_index() +2))]];
    match (GameID,ClassID) {
        (1,4):      CLASSSPELLPERLVLRANGER<2,1> SpellPerLVL @ $ + (4 * (8 -1)) - std::core::array_index() [[inline]];
        (2|8,4):    CLASSSPELLPERLVLRANGER<3,2> SpellPerLVL @ $ + (4 * (11 -1)) + std::core::array_index() [[inline]];
        (3,4):      CLASSSPELLPERLVLRANGER<3,4> SpellPerLVL @ $ + (4 * (17 - 1)) + (std::core::array_index() * 3) [[inline]];
        (5,6):      CLASSSPELLPERLVLRANGER<3,2> SpellPerLVL @ $ + (4 * (11 -1)) + std::core::array_index() [[inline]];
        (6,6):      CLASSSPELLPERLVLRANGER<4,4> SpellPerLVL @ $ + (4 * (17 - 1)) + (std::core::array_index() * 4) [[inline]];
        (1,0 ... 3|5 ... 10):      SPL_COUNT<3> SpellPerLVL @ $ + (4 * (8 -1)) - std::core::array_index() [[inline]];
        (2|8,0 ... 3|5 ... 10):    SPL_COUNT<5> SpellPerLVL @ $ + (4 * (11 -1)) + std::core::array_index() [[inline]];
        (3,0 ... 3|5 ... 10):        SPL_COUNT<7> SpellPerLVL @ $ + (4 * (17 - 1)) + (std::core::array_index() * 3) [[inline]];
        (5,0 ... 5|7 ... 10):    SPL_COUNT<5> SpellPerLVL @ $ + (4 * (11 -1)) + std::core::array_index() [[inline]];
        (6,0 ... 5|7 ... 10):        SPL_COUNT<8> SpellPerLVL @ $ + (4 * (17 - 1)) + (std::core::array_index() * 4) [[inline]];
    }
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1))]];

// ClassXPSpellPerLevel
struct CLASSXPSPELLPERLVL<auto GameID> {
    u8 ClassID = std::core::array_index();
    match (GameID) {
        (1): {
            CLASSXPSPELLLVL<GameID,ClassID> ClassXPSpellCount[8] [[inline]];
            padding[3 * 8];
        }
        (2|5|8): {
            CLASSXPSPELLLVL<GameID,ClassID> ClassXPSpellCount[11] [[inline]];
            padding[5 * 11];
        }
        (3): {
            CLASSXPSPELLLVL<GameID,ClassID> ClassXPSpellCount[17] [[inline]];
            padding[7 * 17];
        }
        (6): {
            CLASSXPSPELLLVL<GameID,ClassID> ClassXPSpellCount[17] [[inline]];
            padding[8 * 17];
        }
    // Can't link up XP/SpellCount due to XP only recording to 10 :(
        (4|9): {
            XPPERLVL XP[10];
            if (ClassID == 4) {
                CLASSSPELLPERLVLRANGER<4,5> SpellPerLVL[29];
            }
            else {
                SPL_COUNT<9> SpellPerLVL[29];
            }
        }
    }
} [[name(std::format("{}", (GameID == 5 || GameID == 6 || GameID == 7) ? KrynnClassName(std::core::array_index()) : String_Class[std::core::array_index()].String))]];

// ClassXPPerLevelFixed - This is the XP value used once the amount required to level up becomes fixed at level 10 - Note: Not a part of the section above
struct CLASSXPPERLVLFIXED {
    u32 XP [[name(std::format("{}", GameID == 7 ? KrynnClassName(std::core::array_index()) : String_Class[std::core::array_index()].String)),comment("Fixed XP required per level")]];
} [[inline]];

/*******************************
    Race Structs
*******************************/
// RaceAbilityLimit
struct RACEABILITYLIMIT {
    u8 STR_MIN_M [[comment("Minimum Strength for males")]];
    u8 STR_MIN_F [[comment("Minimum Strength for females")]];
    u8 STR_MAX_M [[comment("Maximum Strength for males")]];
    u8 STR_MAX_F [[comment("Maximum Strength for females")]];
    u8 STX_MAX_M [[comment("Maximum Extraordinary Strength for males")]];
    u8 STX_MAX_F [[comment("Maximum Extraordinary Strength for females")]];
    u8 INT_MIN [[comment("Minimum Intelligence")]];
    u8 INT_MAX [[comment("Maximum Intelligence")]];
    u8 WIS_MIN [[comment("Minimum Wisdom")]];
    u8 WIS_MAX [[comment("Maximum Wisdom")]];
    u8 DEX_MIN [[comment("Minimum Dexterity")]];
    u8 DEX_MAX [[comment("Maximum Wisdom")]];
    u8 CON_MIN [[comment("Minimum Constitution")]];
    u8 CON_MAX [[comment("Maximum Constitution")]];
    u8 CHA_MIN [[comment("Minimum Charisma")]];
    u8 CHA_MAX [[comment("Maximum Charisma")]];
} [[name(std::format("{}", String_Race[std::core::array_index() + RaceNameOffset].String))]];

// Child struct of RACECLASSAGE - Used to control class grouping names
struct RACECLASSAGEBASE {
    u8 AgeBase [[comment("Base age value")]];
    u8 Age256Mult [[comment("Value multiplied by 256 added to age")]];
    u8 DiceCount [[comment("Number of rolls to make for additional random age")]];
    u8 DiceType [[comment("Dice type (d4/d6/d8/etc) rolled for additional random age")]];
} [[name(std::format("{}", String_Class[std::core::array_index()].String))]];

// RaceClassAge
struct RACECLASSAGE<auto Size> {
    RACECLASSAGEBASE RaceClassAge[Size] [[inline,comment("Formula for calculating the age of a new character of this race")]];
} [[name(std::format("{}", String_Race[std::core::array_index() + RaceNameOffset].String))]];

// RaceAgeRange
struct RACEAGERANGE {
    u16 Young [[comment("Maximum age the character is considered 'young'")]];
    u16 Mature [[comment("Maximum age the character is considered 'mature'")]];
    u16 MiddleAge [[comment("Maximum age the character is considered 'middle aged'")]];
    u16 Old [[comment("Maximum age the character is considered 'old'")]];
    u16 Venerable [[comment("Maximum age the character is considered 'venerable' (expiration date)")]];
} [[name(std::format("{}", String_Race[std::core::array_index() + RaceNameOffset].String))]];

// RaceClassAllowed
struct RACECLASSALLOWED<auto GameID> {
    u8 ClassCount [[comment("Number of classes allowed\nModify this value to match if adding/removing classes")]];
// Variable number of allocated bytes per Race between games, could potentially simplify this with passed parameter but 7/10 would make messy so this works
    match (GameID) {
        (1): {
            CLASS_A Class[ClassCount] [[comment("Available classes for this race")]];
            padding[11 - ClassCount];
        }
        (2|3|4|8|9): {
            CLASS_A Class[ClassCount] [[comment("Available classes for this race")]];
            padding[13 - ClassCount];
        }
        (5|6): {
            CLASS_B Class[ClassCount] [[comment("Available classes for this race")]];
            padding[14 - ClassCount];
        }
    // 7/10 are u16 values
        (7): {
            CLASS_C Class[ClassCount] [[comment("Available classes for this race")]];
            padding[28 - (ClassCount * 2)];
        }
        (10): {
            CLASS_C Class[ClassCount] [[comment("Available classes for this race")]];
            padding[26 - (ClassCount * 2)];
        }
    }
} [[name(std::format("{}", String_Race[std::core::array_index() + RaceNameOffset].String))]];

/*******************************
    Thief Skill Structs
*******************************/
// ThiefSkillPerLevel
struct THIEFSKLPERLVL {
    u8 TH_1_PickPocket [[comment("Pick Pockets ability")]];
    u8 TH_2_OpenLock [[comment("Open Locks ability")]];
    u8 TH_3_FindRemoveTrap [[comment("Find/Remove Traps ability")]];
    u8 TH_4_MoveSilent [[comment("Move Silently ability")]];
    u8 TH_5_HideInShadow [[comment("Hide in Shadows ability")]];
    u8 TH_6_HearNoise [[comment("Hear Noise ability")]];
    u8 TH_7_ClimbWall [[comment("Climb Walls ability")]];
    u8 TH_8_ReadLanguage [[comment("Read Languages ability")]];
} [[name(std::format("LVL_{:02d}", std::core::array_index() +1)),comment("Base Thief skill ability per level")]];;

// ThiefSkillModifierDEX
struct THIEFSKLMODDEX {
    s8 TS1_PickPocket [[comment("Dexterity modifier for Pick Pockets ability")]];;
    s8 TS2_OpenLock [[comment("Dexterity modifier for Open Locks ability")]];
    s8 TS3_FindRemoveTrap [[comment("Dexterity modifier for Find/Remove Traps ability")]];
    s8 TS4_MoveSilent [[comment("Dexterity modifier for Move Silently ability")]];
    s8 TS5_HideInShadow [[comment("Dexterity modifier for Hide in Shadows ability")]];
} [[name(std::format("DEX_{:02d}", std::core::array_index() + 9)),comment("Dexterity modifier for Thief skills")]];

// ThiefSkillModifierRace
struct THIEFSKLMODRACE {
    s8 TH_1_PickPocket [[comment("Racial modifier for Pick Pockets ability")]];
    s8 TH_2_OpenLock [[comment("Racial modifier for Open Locks ability")]];
    s8 TH_3_FindRemoveTrap [[comment("Racial modifier for Find/Remove Traps ability")]];
    s8 TH_4_MoveSilent [[comment("Racial modifier for Move Silently ability")]];
    s8 TH_5_HideInShadow [[comment("Racial modifier for Hide in Shadows ability")]];
    s8 TH_6_HearNoise [[comment("Racial modifier for Hear Noise ability")]];
    s8 TH_7_ClimbWall [[comment("Racial modifier for Climb Walls ability")]];
    s8 TH_8_ReadLanguage [[comment("Racial modifier for Read Languages ability")]];
} [[name(std::format("{}", String_Race[(GameID == 1 || GameID == 2 || GameID == 3 || GameID == 8) ? std::core::array_index() +1 : std::core::array_index()].String)),comment("Racial modifier for Thief skills")]];


/*******************************
    Miscellaneous Structs
*******************************/
// CONModifierNonWarrior - Modifier for non-Warriors (i.e. not Fighter/Knight/Paladin/Ranger) - Not sure where warrior modifiers are stored
struct CONHPMODIFIER {
    s8 CONHPModifier [[name(std::format("CON_{:02d}", std::core::array_index() + 3)),comment("Constitution modifier to HP per level")]];
} [[inline]];

// ItemRandom - NonRandom Random items - 1-3/5/8 (suspect 8 is not or only partially used)
struct ITEMRANDOM {
    u16 NamePart3 [[format("GetItemName"),comment("Index of the string from the ItemName enumeration list for the third part of the item's name")]];
    u16 NamePart2 [[format("GetItemName"),comment("Index of the string from the ItemName enumeration list for the second part of the item's name")]];
    u16 NamePart1 [[format("GetItemName"),comment("Index of the string from the ItemName enumeration list for the first part of the item's name")]];
    u16 Weight [[comment("The item's weight in coins")]];
    u16 Value [[comment("The item's monetary/resell value")]];
    u16 Property3 [[comment("Variable usage depending on item type")]];
    u16 Property2 [[comment("Variable usage depending on item type")]];
    u16 Property1 [[comment("Variable usage depending on item type")]];
};

// SpellBase - Base spell data, sorta like the ITEM base data - Spell specifics like amount of damage/healing, damage type, etc are handled elsewhere
struct SPELLBASE<auto GameID> {
    match (GameID) {
        (1):        SPELLCLASS_A Class [[comment("Spell caster class")]];
        (2|4|8|9):  SPELLCLASS_B Class [[comment("Spell caster class")]];
        (3|5|6):    SPELLCLASS_C Class [[comment("Spell caster class")]];
        (7|10):     SPELLCLASS_D Class [[comment("Spell caster class")]];
    }
    u8 Level [[comment("The spell's level")]];
    s8 Range_Base [[comment("Base range (-1 is 'Touch')")]];
    u8 Range_Modifier [[comment("Caster level modifier added to Range_Base multiplied by 4")]];     // add formula
    u8 Duration_Base [[comment("Base duration (how long its effect lasts) in rounds")]];
    u8 Duration_Modifier [[comment("Caster level modifier added to Duration_Base multiplied by 4")]];   // add formula
    AREACOMBAT Area_Combat [[comment("Area or target type when cast in combat")]];
    match (GameID) {
        (1|2|5|8):  AREACAMP_A Area_Camp [[comment("Target when cast in camp")]];
        (3|4|6|9):  AREACAMP_B Area_Camp [[comment("Target when cast in camp")]];
        (7|10):     AREACAMP_C Area_Camp [[comment("Target when cast in camp")]];
    }
    match (GameID) {
        (1 ... 6|8|9): {
            SAV_ACTION_A SAV_Action [[comment("Result of a successful saving throw (negate/half damage/etc)")]];
            SAV_TYPE_A SAV_Type [[comment("Type of save to check against on the target for spells where saving throws are used")]];
            u8 EffectID [[comment("Index of the effect applied to the target (0 for none)")]];
            SPELLTYPE_A Type [[comment("Where/when the spell can be cast (camp/combat/both)")]];
            u8 CastTime [[format("FormatCastTime"),comment("Amount of time it takes to cast the spell in segments (tenths of a round)")]];
            u8 AI_Priority [[comment("Ranking value used by the AI to decide which spell it should cast")]];
            bool TargetEnemy [[comment("Indicate if this spell allows targeting enemy characters")]];
        }
        (7|10): {
            SAV_ACTION_B SAV_Action [[comment("Result of a successful saving throw (negate/half damage/etc)")]];
            SAV_TYPE_B SAV_Type [[comment("Type of save to check against on the target for spells where saving throws are used")]];
            u8 EffectID [[comment("Index of the effect applied to the target (0 for none)")]];
            SPELLTYPE_B Type [[comment("Where/when the spell can be cast (camp/combat/both)")]];
            u8 CastTime [[format("FormatCastTime"),comment("Amount of time it takes to cast the spell in segments (tenths of a round)")]];
            u8 AI_Priority [[comment("Ranking value used by the AI to decide which spell it should cast")]];
            u16 TargetEnemy [[comment("Indicate if this spell allows targeting enemy characters")]];
        }
    }
    u8 AI_MinTarget [[comment("Minimum number of targets that must be in the spell's area of effect for the AI to pick to cast")]];
} [[name(std::format("{:03d}: {}", std::core::array_index() +1, std::core::array_index() < std::core::member_count(String_SpellName) ? String_SpellName[std::core::array_index()].String : "Undefined"))]];

// TimeConversion
struct TIMECONV {
    u16 SegmentRound [[comment("Number of segments in a round")]];
    u16 RoundTurn [[comment("Number of rounds in a turn")]];
    u16 TurnHour [[comment("Number of turns in a hour")]];
    u16 HourDay [[comment("Number of hours in a day")]];
    u16 DayMonth [[comment("Number of days in a month")]];
    u16 MonthYear [[comment("Number of months in a year")]];
    u16 YearCentury [[comment("Number of years in a century")]];    // 256 (or -1) in 1/2/5/6/8
};

// TurnUndeadTypeLevel
struct TURNUNDEAD<auto Type> {
// 4/6-7/9-10 has a level 0 value
    if (Type == 0) {
        u8 LVL_00 [[format("FormatTurnUndead"),comment("Turn ability at level 0")]];
    }
    u8 LVL_01 [[format("FormatTurnUndead"),comment("Turn ability at level 1")]];
    u8 LVL_02 [[format("FormatTurnUndead"),comment("Turn ability at level 2")]];
    u8 LVL_03 [[format("FormatTurnUndead"),comment("Turn ability at level 3")]];
    u8 LVL_04 [[format("FormatTurnUndead"),comment("Turn ability at level 4")]];
    u8 LVL_05 [[format("FormatTurnUndead"),comment("Turn ability at level 5")]];
    u8 LVL_06 [[format("FormatTurnUndead"),comment("Turn ability at level 6")]];
    u8 LVL_07 [[format("FormatTurnUndead"),comment("Turn ability at level 7")]];
    u8 LVL_08 [[format("FormatTurnUndead"),comment("Turn ability at level 8")]];
// 5 specifies 9-13 instead of bundling them and doesn't have 14+
    if (Type == 5) {
        u8 LVL_09 [[format("FormatTurnUndead"),comment("Turn ability at level 9")]];
        u8 LVL_10 [[format("FormatTurnUndead"),comment("Turn ability at level 10")]];
        u8 LVL_11 [[format("FormatTurnUndead"),comment("Turn ability at level 11")]];
        u8 LVL_12 [[format("FormatTurnUndead"),comment("Turn ability at level 12")]];
        u8 LVL_13 [[format("FormatTurnUndead"),comment("Turn ability at level 13")]];
    }
// 1-4/6-10 bundles 9/13 and includes 14+
    else {
        u8 LVL_09_13 [[format("FormatTurnUndead"),comment("Turn ability at levels 9-13")]];
        u8 LVL_14Plus [[format("FormatTurnUndead"),comment("Turn ability at levels 14+")]];
    }
} [[name(UndeadLevelName(std::core::array_index())),comment("Cleric/Paladin turn ability by level for Undead of this level")]];


// String Tables - This is obviously incomplete but most aren't all that interesting or useful - I don't know why I added the disk messages :P
STRING<String_Alignment_Param> String_Alignment[RecordCount[0]] @ Offset[0];
STRING<String_Class_Param> String_Class[RecordCount[1]] @ Offset[1];
STRING<String_CompassDirection_Param> String_CompassDirection[RecordCount[2]] @ Offset[2];
STRING<String_Diety_Param> String_Diety[RecordCount[3]] @ Offset[3];
STRING<String_DiskMessage_Param> String_DiskMessage[RecordCount[4]] @ Offset[4];
STRING<String_Effect_Param> String_Effect[RecordCount[5]] @ Offset[5];
STRING<String_Gender_Param> String_Gender[RecordCount[6]] @ Offset[6];
STRING<String_IconModify_Param> String_IconModify[RecordCount[7]] @ Offset[7];
STRING<String_ItemNamePart_Param> String_ItemNamePart[RecordCount[8]] @ Offset[8];
MAINMENU String_MainMenu[RecordCount[9]] @ Offset[9];
STRING<String_MenuCommand_Param> String_MenuCommand[RecordCount[10]] @ Offset[10];
STRING<String_Money_Param> String_Money[RecordCount[11]] @ Offset[11];
STRING<String_Race_Param> String_Race[RecordCount[12]] @ Offset[12];
STRING<String_Robe_Param> String_Robe[RecordCount[13]] @ Offset[13];
STRING<String_SpellLevel_Param> String_SpellLevel[RecordCount[14]] @ Offset[14];
STRING<String_SpellName_Param> String_SpellName[RecordCount[15]] @ Offset[15];
STRING<String_Status_Param> String_Status[RecordCount[16]] @ Offset[16];
STRING<String_TempleSpell_Param> String_TempleSpell[RecordCount[17]] @ Offset[17];

// Class Tables
BASEABILITY ClassAbilityMin[RecordCount[18]] @ Offset[18];
CLASSALIGN<ClassAlignmentAllowed_Param> ClassAlignmentAllowed[RecordCount[19]] @ Offset[19];
CLASSALIGN<ClassAlignmentAllowed_Param> ClassAlignmentAllowedDwarf[RecordCount[20]] @ Offset[20];
CLASSBASESAVE<ClassBaseSavePerLevel_Param> ClassBaseSavePerLevel[RecordCount[21]] @ Offset[21];
CLASSARRAY<u8> ClassHDLevelMax[RecordCount[22]] @ Offset[22] [[comment("Maximum level for additional Hit Dice per class")]];
CLASSARRAY<u8> ClassHDStartCount[RecordCount[23]] @ Offset[23] [[comment("Starting number of Hit Dice rolled per class")]];
CLASSARRAY<u8>ClassHDType[RecordCount[24]] @ Offset[24] [[comment("Dice type (d4/d6/d8/etc) used for Hit Dice per class")]];
CLASSRESTRICTION<GameID> ClassItemAllowed[RecordCount[25]] @ Offset[25];
CLASSMONEYBASE ClassMoneyBase[RecordCount[26]] @ Offset[26];
CLASSSPELLALLOWED<ClassSpellAllowed_Param> ClassSpellAllowed[RecordCount[27]] @ Offset[27] [[comment(GameID == 10 ? "Unused" : "Available spells per magic class")]];
CLASSSPELLPERLVL ClassSpellPerLevel[RecordCount[28]] @ Offset[28];
CLASSTHAC0PERLVL<ClassTHAC0PerLevel_Param> ClassTHAC0PerLevel[RecordCount[29]] @ Offset[29];
CLASSARRAY<u8> ClassTrainCode[RecordCount[30]] @ Offset[30] [[comment("I honestly am not entirely sure how this works :)")]];
CLASSXPPERLVL<ClassXPPerLevel_Param> ClassXPPerLevel[RecordCount[31]] @ Offset[31];
CLASSXPPERLVLFIXED ClassXPPerLevelFixed[RecordCount[48]] @ Offset[48];
CLASSXPSPELLPERLVL<GameID> ClassXPSpellPerLevel[RecordCount[32]] @ Offset[32];

// Race Tables
RACEABILITYLIMIT RaceAbilityLimit[RecordCount[33]] @ Offset[33];
RACEAGERANGE RaceAgeRange[RecordCount[34]] @ Offset[34];
RACECLASSAGE<RaceClassAge_Param> RaceClassAge[RecordCount[35]] @ Offset[35];
RACECLASSALLOWED<GameID> RaceClassAllowed[RecordCount[36]] @ Offset[36];

// Thief Skill Tables
THIEFSKLMODDEX ThiefSkillModifierDEX[RecordCount[37]] @ Offset[37];
THIEFSKLMODRACE ThiefSkillModifierRace[RecordCount[38]] @ Offset[38];
THIEFSKLPERLVL ThiefSkillPerLevel[RecordCount[39]] @ Offset[39];

// Miscellaneous Tables
CONHPMODIFIER CONModifierNonWarrior[RecordCount[40]] @ Offset[40] [[comment("Constitution modifier to HP for non-Warrior type classes")]];
ITEMRANDOM ItemRandom[RecordCount[41]] @ Offset[41];
u32 MoneyConversion[RecordCount[42]] @ Offset[42];
u8 PortraitBody[RecordCount[43]] @ Offset[43];
u8 PortraitHead[RecordCount[44]] @ Offset[44];
SPELLBASE<GameID> SpellBase[RecordCount[45]] @ Offset[45];
TIMECONV TimeConversion @ Offset[46];
TURNUNDEAD<TurnUndeadTypeLevel_Param> TurnUndeadTypeLevel[RecordCount[47]] @ Offset[47];