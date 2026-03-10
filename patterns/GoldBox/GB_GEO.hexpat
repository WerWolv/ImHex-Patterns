#pragma author Draxinusom
#pragma description Gold Box Games - Map (GEO)
#include <GoldBox/GB_ENUM_IMG.cs>
import std.core;
import std.math;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the GEO files
 for all Gold Box games (D&D, no one cares about Buck Rogers)

 Supported Games:
 01 - Pool of Radiance (GEO[1-8].DAX)
 02 - Curse of the Azure Bonds (GEO[2-6].DAX)
 03 - Secret of the Silver Blades (GEO[1-3].DAX)
 04 - Pools of Darkness (GEO1.DAX)
 05 - Champions of Krynn (GEO[1-3].DAX)
 06 - Death Knights of Krynn (GEO[1-3].DAX)
 07 - The Dark Queen of Krynn (DISK3\GEO.GLB)
 08 - Gateway to the Savage Frontier (GEO[2-6].DAX)
 09 - Treasures of the Savage Frontier (GEO1.DAX)
 10 - Unlimited Adventures (<MODULE>\GEO###.DAT)

 All files, excluding 10, must be decompressed in order to view
 This means that in order to edit those you must recompress/recreate the DAX/GLB file afterwards

 Note:
 Files for 1-6/8-9 have an identical structure with only a small variant in the first two bytes in 4/6 and 9
 Files for 7 are largely the same as above but contains a small 8 byte header that allow variable sized maps (instead of 16x16 only)
 Additionally, door locks are handled by events in 7 and are not flagged on the doors directly as those bits are used for setting background

 Files for 10 are vastly different, containing not only the map, but also all events and strings for the map,
 making it essentially a combo of the ECL & GEO files used in other games and is the vast majority of the code in this
**********/
u8 GameID;  // GameID is auto detected

/*****
    Get GameID
    This doesn't need to be particularly precise, the primary difference is between
    1-6/8-9, 7, and 10 with a minor variation with 1-3/5/8, 4/6, and 9
****/
u128 FileSize = std::mem::size();
u16 FirstBytes @ 0x0000 [[hidden]];

match (FileSize,FirstBytes) {
  // Always 0000 in 9
    (1026,0):           GameID = 9;
  // Always filesize in 1-3/5/8 - Just picking 1 as it doesn't matter otherwise
    (1026,1024):        GameID = 1;
  // Variable in 4/6 - Just picking 4 as it doesn't matter otherwise
    (1026,!(0|1024)):   GameID = 4;
  // First bytes don't really matter for 10 as the size is static but we have them so why not check
    (12962,20294):      GameID = 10;
  // Completely variable in 7, however, no grid size combo can hit 1026 or 12962
    (_,_):              GameID = 7;
}

// Get map dimensions and type (10 specific) - always 16x16 or located in Header section in 7/10 but grabbing as global variables to make usage easier in other sections/functions
u8 Width;
u8 Height;
bool IsOverland = 0;

match (GameID) {
    (7): {
        u8 TempX @ 0x01;
        u8 TempY @ 0x00;
        Width = TempX;
        Height = TempY;
    }
    (10): {
        u8 TempX @ 0x001B;
        u8 TempY @ 0x001A;
        Width = TempX;
        Height = TempY;
    // There are various differences, mostly with images, depending on if module is a Dungeon or Overland type
        u48 OverlandCheck @ 0x0019;
        if (OverlandCheck == 0xFFFFFF260F6A) {
            IsOverland = 1;
        }
    }
    (_): {
        Width = 16;
        Height = 16;
    }
}

// Since 7 is variable, do a quick sanity check first - 4 bytes per cell + 8 byte header should equal FileSize
if (GameID == 7 && (((Width * Height) * 4) + 8) != FileSize) {
    std::warning("Unknown file. Exiting.");
    return;
}

/***********************
    Enumerations
***********************/
// Note: In order to keep this somewhat readable, Image enumerations are stored in GB_ENUM_IMG.cs

// Used in QuestStage events
enum ACCEPTON:u8 {
    Impossible = 0,
    Yes = 1,
    No = 2,
    YesOrNo = 3,
    Impossible_NoQuestion = 4,
    Automatic_NoQuestion = 5
};

// Used in event Chain controls
enum CHAINTYPE:u8 {
    Always = 0,
    IfEventHappens = 1,
    IfEventDoesNotHappen = 2
};

// Used in WhoTries events
enum CHECKABILITYSKILL:u8 {
    AlwaysSucceeds =  0,
    AlwaysFails =  1,
    Strength =  2,
    Intelligence =  3,
    Wisdom =  4,
    Dexterity =  5,
    Constitution =  6,
    Charisma =  7,
    Thief_PickPockets =  8,
    Thief_OpenLock =  9,
    Thief_FindRemoveTrap = 10,
    Thief_MoveSilently = 11,
    Thief_HideInShadows = 12,
    Thief_HearNoise = 13,
    Thief_ClimbWalls = 14,
    Thief_ReadLanguage = 15
};

// Used in EnterPassword/WhoPays/WhoTries events
enum CHECKACTION:u8 {
    DoNothing = 0,
    Chain = 1,
    Teleport = 2,
    BackupOneStep = 3
};

// Used in WhoPays events
enum CHECKMONEY:u8 {
    Impossible = 0,
    SufficientGems = 1,
    SufficientJewelry = 2,
    SufficientPlatinum = 3
};

// Used in WhoTries events
enum CHECKTYPE:u8 {
    CompareToDie = 0,
    MustHave = 1
};

// Used in event condition InParty_Class
enum CLASS:u8 {
    Cleric = 0,
    Fighter = 2,
    Paladin = 3,
    Ranger = 4,
    MagicUser = 5,
    Thief = 6
};

// Used in Combat/CombatPickOne events
enum COMBAT_SURPRISE:u8 {
    Neither = 0,
    Party = 1,
    Monster = 2
};

// Used in event conditions
enum CONDITIONTYPE:u8 {
    Always = 0,
    SpecialItem_True = 1,
    SpecialItem_False = 2,
    IsDayTime = 3,
    IsNightTime = 4,
    RandomPercentage = 5,
    Searching_True = 6,
    Searching_False = 7,
    FacingDirection = 8,
    Quest_Complete = 9,
    Quest_Failed = 10,
    Quest_InProgress = 11,
    DetectTrap_True = 12,
    DetectTrap_False = 13,
    SeeInvisible_True = 14,
    SeeInvisible_False = 15,
    InParty_Class = 16,
    InParty_Race = 17
};

// Used in Shop/SmallTown events
enum COSTFACTOR:u8 {
    Free = 0,
    Div_100 = 1,
    Div_50 = 2,
    Div_20 = 3,
    Div_10 = 4,
    Div_5 = 5,
    Div_4 = 6,
    Div_3 = 7,
    Div_2 = 8,
    Div_1_5 = 9,
    Normal = 10,
    Mult_1_5 = 11,
    Mult_2 = 12,
    Mult_3 = 13,
    Mult_4 = 14,
    Mult_5 = 15,
    Mult_10 = 16,
    Mult_20 = 17,
    Mult_50 = 18,
    Mult_100 = 19
};

// Used in TrainingHall events - Identical to COSTFACTOR except 7 & 9 are removed (probably because they don't divide clean)
// Actual costs listed in game (based on 1000 base) but ENUMs don't like values starting with numbers so leaving as this
enum COSTTRAIN:u8 {
    Free = 0,
    Div_100 = 1,
    Div_50 = 2,
    Div_20 = 3,
    Div_10 = 4,
    Div_5 = 5,
    Div_4 = 6,
    //Div_3 = 7,
    Div_2 = 8,
    //Div_1_5 = 9,
    Normal = 10,
    Mult_1_5 = 11,
    Mult_2 = 12,
    Mult_3 = 13,
    Mult_4 = 14,
    Mult_5 = 15,
    Mult_10 = 16,
    Mult_20 = 17,
    Mult_50 = 18,
    Mult_100 = 19
};

// Used in Header EntryPoint and EnterPassword/GuidedTour/Stairs/Teleporter/TransferModule/WhoPays/WhoTries events
enum DIRECTION:u8 {
    North = 0,
    East = 1,
    South = 2,
    West = 3
};

// Used in event condition FacingDirection - This is really a bitfield but drop down enumerates all combos like this so... whatever :P
// Note:  Also _should_ be used in Combat/CombatPickOne with the addition of an InFront = 0 value, however that usage is handled as a bit field due to the values being split across multiple bytes
enum DIRECTION_ALL:u8 {
    //InFront = 0,
    North =  1,
    East =  2,
    N_E =  3,
    South =  4,
    N_S =  5,
    E_S =  6,
    N_E_S =  7,
    West =  8,
    N_W =  9,
    E_W = 10,
    N_E_W = 11,
    S_W = 12,
    N_S_W = 13,
    E_S_W = 14,
    N_E_S_W = 15
};

// Used in AddNPC/Combat/CombatPickOne/Damage/Encounter/NPCSays/RemoveNPC/TextStatement events
enum DISTANCE:u8 {
    UpClose = 0,
    Nearby = 1,
    FarAway = 2
};

// Door type used by 1-6/8-9
enum DOORTYPE:u8 {
    None = 0,
    Unlocked = 1,
    Locked_IsPickable = 2,
    Locked_UnPickable = 3
};

// Used in Encounter events
enum ENCOUNTERACTION:u8 {
    DecreaseRange = 0,
    Combat_PartySuprisedIfSlow = 1,
    Combat_MonstersSuprisedIfFast = 2,
    Combat_NoSuprise = 3,
    TalkChain = 4,
    Escape_IfFastElseCombat = 5,
    NoEffect = 6
};

// Used in Encounter events - reduced list when range is 0
enum ENCOUNTERACTION_ZERO:u8 {
    Combat_PartySuprisedIfSlow = 1,
    Combat_MonstersSuprisedIfFast = 2,
    Combat_NoSuprise = 3,
    TalkChain = 4,
    Escape_IfFastElseCombat = 5
};

// Used in events
enum EVENTTYPE:u8 {
    None = 0,
    Combat = 1,
    TextStatement = 2,
    GiveTreasure = 3,
    Damage = 4,
    Stairs = 5,
    TrainingHall = 6,
    Tavern = 7,
    Shop = 8,
    Temple = 9,
    Question_Button = 10,
    TransferModule = 11,
    GuidedTour = 12,
    AddNPC = 13,
    NPCSays = 14,
    Encounter = 15,
    Utilities = 16,
    Sounds = 17,
    WhoTries = 18,
    WhoPays = 19,
    EnterPassword = 20,
    Question_List = 21,
    SmallTown = 22,
    Chain = 23,
    Vault = 24,
    CombatTreasure = 25,
    GainExperience = 26,
    PassTime = 27,
    Unknown_28 = 28,
    Camp = 29,
    Unknown_30 = 30,
    Unknown_31 = 31,
    RemoveNPC = 32,
    PickOneCombat = 33,
    Teleporter = 34,
    QuestStage = 35,
    Question_YesNo = 36,
    TavernTales = 37,
    SpecialItem = 38
};

// Used in events to indicate the image type - Could alternatively be viewed as a boolean IsPicture value
enum IMG_TYPE:u8 {
    Sprite = 0,
    Picture = 1
};

// Used in SpecialItem events
enum ITEM_GIVETAKE:u8 {
    GiveItemToParty = 0,
    TakeItemFromParty = 1
};

// Used in CombatTreasure/GiveTreasure events
enum ITEMLIST:u8 {
    NoItem = 0,
    x20_Arrows = 1,
    BattleAxe = 2,
    HandAxe = 3,
    CompositeShortBow = 4,
    CompositeLongBow = 5,
    LongBow = 6,
    ShortBow = 7,
    Club = 8,
    LightCrossbow = 9,
    Dagger = 10,
    x10_Darts = 11,
    Flail = 12,
    Halberd = 13,
    Hammer = 14,
    x5_Javelins = 15,
    Mace = 16,
    MorningStar = 17,
    MilitaryPick = 18,
    AwlPike = 19,
    x20_Bolts = 20,
    Scimitar = 21,
    Sling = 22,
    Spear = 23,
    QuarterStaff = 24,
    StaffSling = 25,
    BastardSword = 26,
    BroadSword = 27,
    LongSword = 28,
    ShortSword = 29,
    TwoHandedSword = 30,
    Trident = 31,
    Belt = 32,
    Boots = 33,
    Cloak = 34,
    Robe = 35,
    BandedMail = 36,
    ChainMail = 37,
    Helm = 38,
    LeatherArmor = 39,
    PlateMail = 40,
    RingMail = 41,
    ScaleMail = 42,
    Shield = 43,
    ElfinChain = 44,
    FineLongBow = 45,
    x2_BlessedBolts = 46,
    DartOfHornetsNest = 47,
    CloakOfDisplacement = 48,
    Mirror = 49,
    x10_Arrows_Plus1 = 50,
    BattleAxe_Plus1 = 51,
    CompositeShortBow_Plus1 = 52,
    CompositeLongBow_Plus1 = 53,
    LightCrossbow_Plus1 = 54,
    Dagger_Plus1 = 55,
    x10_Darts_Plus1 = 56,
    Flail_Plus1 = 57,
    Hammer_Plus1 = 58,
    x2_Javelins_Plus1 = 59,
    Mace_Plus1 = 60,
    x10_Bolts_Plus1 = 61,
    Scimitar_Plus1 = 62,
    Sling_Plus1 = 63,
    QuarterStaff_Plus1 = 64,
    StaffSling_Plus1 = 65,
    LongSword_Plus1 = 66,
    ShortSword_Plus1 = 67,
    TwoHandedSword_Plus1 = 68,
    Trident_Plus1 = 69,
    CloakOfProt_Plus1 = 70,
    BandedMail_Plus1 = 71,
    ChainMail_Plus1 = 72,
    Helm_Plus1 = 73,
    LeatherArmor_Plus1 = 74,
    PlateMail_Plus1 = 75,
    RingMail_Plus1 = 76,
    ScaleMail_Plus1 = 77,
    Shield_Plus1 = 78,
    ElfinChain_Plus1 = 79,
    x10_Arrows_Plus2 = 80,
    BattleAxe_Plus2 = 81,
    CompositeShortBow_Plus2 = 82,
    CompositeLongBow_Plus2 = 83,
    LightCrossbow_Plus2 = 84,
    Dagger_Plus2 = 85,
    x10_Darts_Plus2 = 86,
    Flail_Plus2 = 87,
    Hammer_Plus2 = 88,
    x2_Javelins_Plus2 = 89,
    Mace_Plus2 = 90,
    x10_Bolts_Plus2 = 91,
    Scimitar_Plus2 = 92,
    Sling_Plus2 = 93,
    QuarterStaff_Plus2 = 94,
    StaffSling_Plus2 = 95,
    LongSword_Plus2 = 96,
    ShortSword_Plus2 = 97,
    TwoHandedSword_Plus2 = 98,
    Trident_Plus2 = 99,
    CloakOfProt_Plus2 = 100,
    BandedMail_Plus2 = 101,
    ChainMail_Plus2 = 102,
    Helm_Plus2 = 103,
    LeatherArmor_Plus2 = 104,
    PlateMail_Plus2 = 105,
    RingMail_Plus2 = 106,
    ScaleMail_Plus2 = 107,
    Shield_Plus2 = 108,
    ElfinChain_Plus2 = 109,
    x10_Arrows_Plus3 = 110,
    BattleAxe_Plus3 = 111,
    CompositeShortBow_Plus3 = 112,
    CompositeLongBow_Plus3 = 113,
    LightCrossbow_Plus3 = 114,
    Dagger_Plus3 = 115,
    x10_Darts_Plus3 = 116,
    Flail_Plus3 = 117,
    Hammer_Plus3 = 118,
    x2_Javelins_Plus3 = 119,
    Mace_Plus3 = 120,
    x10_Bolts_Plus3 = 121,
    Scimitar_Plus3 = 122,
    Sling_Plus3 = 123,
    QuarterStaff_Plus3 = 124,
    StaffSling_Plus3 = 125,
    LongSword_Plus3 = 126,
    ShortSword_Plus3 = 127,
    TwoHandedSword_Plus3 = 128,
    Trident_Plus3 = 129,
    CloakOfProt_Plus3 = 130,
    BandedMail_Plus3 = 131,
    ChainMail_Plus3 = 132,
    Helm_Plus3 = 133,
    LeatherArmor_Plus3 = 134,
    PlateMail_Plus3 = 135,
    RingMail_Plus3 = 136,
    ScaleMail_Plus3 = 137,
    Shield_Plus3 = 138,
    ElfinChain_Plus3 = 139,
    x10_Arrows_Plus4 = 140,
    BattleAxe_Plus4 = 141,
    CompositeShortBow_Plus4 = 142,
    CompositeLongBow_Plus4 = 143,
    LightCrossbow_Plus4 = 144,
    Dagger_Plus4 = 145,
    x10_Darts_Plus4 = 146,
    Flail_Plus4 = 147,
    Hammer_Plus4 = 148,
    x2_Javelins_Plus4 = 149,
    Mace_Plus4 = 150,
    x10_Bolts_Plus4 = 151,
    Scimitar_Plus4 = 152,
    Sling_Plus4 = 153,
    QuarterStaff_Plus4 = 154,
    StaffSling_Plus4 = 155,
    LongSword_Plus4 = 156,
    ShortSword_Plus4 = 157,
    TwoHandedSword_Plus4 = 158,
    Trident_Plus4 = 159,
    CloakOfProt_Plus4 = 160,
    BandedMail_Plus4 = 161,
    ChainMail_Plus4 = 162,
    Helm_Plus4 = 163,
    LeatherArmor_Plus4 = 164,
    PlateMail_Plus4 = 165,
    RingMail_Plus4 = 166,
    ScaleMail_Plus4 = 167,
    Shield_Plus4 = 168,
    ElfinChain_Plus4 = 169,
    x10_Arrows_Plus5 = 170,
    BattleAxe_Plus5 = 171,
    CompositeShortBow_Plus5 = 172,
    CompositeLongBow_Plus5 = 173,
    LightCrossbow_Plus5 = 174,
    Dagger_Plus5 = 175,
    x10_Darts_Plus5 = 176,
    Flail_Plus5 = 177,
    Hammer_Plus5 = 178,
    x2_Javelins_Plus5 = 179,
    Mace_Plus5 = 180,
    x10_Bolts_Plus5 = 181,
    Scimitar_Plus5 = 182,
    Sling_Plus5 = 183,
    QuarterStaff_Plus5 = 184,
    StaffSling_Plus5 = 185,
    LongSword_Plus5 = 186,
    ShortSword_Plus5 = 187,
    TwoHandedSword_Plus5 = 188,
    Trident_Plus5 = 189,
    CloakOfProt_Plus5 = 190,
    BandedMail_Plus5 = 191,
    ChainMail_Plus5 = 192,
    Helm_Plus5 = 193,
    LeatherArmor_Plus5 = 194,
    PlateMail_Plus5 = 195,
    RingMail_Plus5 = 196,
    ScaleMail_Plus5 = 197,
    Shield_Plus5 = 198,
    ElfinChain_Plus5 = 199,
    SilverShield_Plus3 = 200,
    SilverShield_Plus4 = 201,
    BeltOfProt_Plus3 = 202,
    BootsOfSpeed = 203,
    GirdleOfGiantStrength = 204,
    PeriaptOfHealth = 205,
    JavelinOfLightning = 206,
    StoneOfGoodLuck = 207,
    NecklaceOfMissiles = 208,
    EyesOfCharming = 209,
    BracersAC6 = 210,
    BracersAC4 = 211,
    BracersAC2 = 212,
    LongSwordVsGiants = 213,
    VorpalLongSword = 214,
    DrowLongSword_Plus1 = 215,
    DrowLongSword_Plus3 = 216,
    DrowLongSword_Plus4 = 217,
    DrowChain_Plus1 = 218,
    DrowChain_Plus3 = 219,
    DrowChain_Plus4 = 220,
    FineLongBow_Plus2 = 221,
    LightCrossbowCursed_Minus3 = 222,
    Ring = 223,
    RingOfVulnerability = 224,
    RingOfProt_Plus1 = 225,
    RingOfProt_Plus2 = 226,
    RingOfProt_Plus3 = 227,
    RingOfProt_Plus4 = 228,
    RingOfProt_Plus5 = 229,
    RingOfColdResistance = 230,
    RingOfElectricImmunity = 231,
    RingOfFireResistance = 232,
    GauntletsOfOgrePower = 233,
    RingOfInvisibility = 234,
    RingOfBlinking = 235,
    RingOfWizardry = 236,
    RingOfProtFromEvil = 237,
    WandOfIceStorm = 238,
    WandOfFireballs = 239,
    WandOfLightning = 240,
    WandOfMagicMissiles = 241,
    WandOfParalyzation = 242,
    PotionOfSpeed = 243,
    PotionOfHealing = 244,
    PotionExtraHealing = 245,
    PotionOfInvisibility = 246,
    PotionOfGiantStrength = 247,
    ElixirOfYouth = 248,
    ScrollOfProtDragonBreath = 249,
    ClericScroll3Spells = 250,
    ClericScroll3Spells = 251,
    MageScroll3Spells = 252,
    MageScroll3Spells = 253,
    MageScroll3Spells = 254,
    MageScroll3Spells = 255
};

// Used in event condition SpecialItem_[False|True]/Quest_[Complete|Failed|InProgress] and Utilities/QuestStage/SpecialItem events
enum KEYITEMQUEST:u8 {
    Key_1 = 0,
    Key_2 = 1,
    Key_3 = 2,
    Key_4 = 3,
    Key_5 = 4,
    Key_6 = 5,
    Key_7 = 6,
    Key_8 = 7,
    Item_01 = 8,
    Item_02 = 9,
    Item_03 = 10,
    Item_04 = 11,
    Item_05 = 12,
    Item_06 = 13,
    Item_07 = 14,
    Item_08 = 15,
    Item_09 = 16,
    Item_10 = 17,
    Item_11 = 18,
    Item_12 = 19,
    Quest_01 = 20,
    Quest_02 = 21,
    Quest_03 = 22,
    Quest_04 = 23,
    Quest_05 = 24,
    Quest_06 = 25,
    Quest_07 = 26,
    Quest_08 = 27,
    Quest_09 = 28,
    Quest_10 = 29,
    Quest_11 = 30,
    Quest_12 = 31,
    Quest_13 = 32,
    Quest_14 = 33,
    Quest_15 = 34,
    Quest_16 = 35,
    Quest_17 = 36,
    Quest_18 = 37,
    Quest_19 = 38,
    Quest_20 = 39,
    Quest_21 = 40,
    Quest_22 = 41,
    Quest_23 = 42,
    Quest_24 = 43,
    Quest_25 = 44,
    Quest_26 = 45,
    Quest_27 = 46,
    Quest_28 = 47,
    Quest_29 = 48,
    Quest_30 = 49,
    Quest_31 = 50,
    Quest_32 = 51,
    Quest_33 = 52,
    Quest_34 = 53,
    Quest_35 = 54,
    Quest_36 = 55,
    Quest_37 = 56,
    Quest_38 = 57,
    Quest_39 = 58,
    Quest_40 = 59,
    Quest_41 = 60,
    Quest_42 = 61,
    Quest_43 = 62
};

// Map wall obstruction types - Dungeon modules only
enum MAP_OBSTRUCTION_IN:u8 {
    Open =  0,
    Secret =  1,
    Locked =  2,
    LockedSecret =  3,
    WizardLocked =  4,
    WizardLockedSecret =  5,
    LockedKey_1 =  6,
    LockedKey_2 =  7,
    LockedKey_3 =  8,
    LockedKey_4 =  9,
    LockedKey_5 = 10,
    LockedKey_6 = 11,
    LockedKey_7 = 12,
    LockedKey_8 = 13,
    Blocked = 14,
    FalseDoor = 15
};

// Map wall obstruction types - Overland modules only
enum MAP_OBSTRUCTION_OUT:u8 {
    Passable =  0,
    Impassable = 15
};

// Used in Stairs/TransferModule/Teleporter events
// Note:  Other than current module, names are stored in another file so cannot display those
enum MODULE:u8 {
    Overland_01 = 1,
    Overland_02 = 2,
    Overland_03 = 3,
    Overland_04 = 4,
    Dungeon_01 = 5,
    Dungeon_02 = 6,
    Dungeon_03 = 7,
    Dungeon_04 = 8,
    Dungeon_05 = 9,
    Dungeon_06 = 10,
    Dungeon_07 = 11,
    Dungeon_08 = 12,
    Dungeon_09 = 13,
    Dungeon_10 = 14,
    Dungeon_11 = 15,
    Dungeon_12 = 16,
    Dungeon_13 = 17,
    Dungeon_14 = 18,
    Dungeon_15 = 19,
    Dungeon_16 = 20,
    Dungeon_17 = 21,
    Dungeon_18 = 22,
    Dungeon_19 = 23,
    Dungeon_20 = 24,
    Dungeon_21 = 25,
    Dungeon_22 = 26,
    Dungeon_23 = 27,
    Dungeon_24 = 28,
    Dungeon_25 = 29,
    Dungeon_26 = 30,
    Dungeon_27 = 31,
    Dungeon_28 = 32,
    Dungeon_29 = 33,
    Dungeon_30 = 34,
    Dungeon_31 = 35,
    Dungeon_32 = 36,
    Dungeon_33 = 37,
    Dungeon_34 = 38,
    Dungeon_35 = 39,
    Dungeon_36 = 40
};

// Used in Header SummonedMonster and Combat/CombatPickOne events
enum MONSTERLIST:u8 {
    None = 0,
    Kobold = 1,
    Goblin = 2,
    Orc = 3,
    Hobgoblin = 4,
    OrcChieftain = 5,
    HobgoblinLdr = 6,
    Gnoll = 7,
    Ogre = 8,
    Troll = 9,
    HillGiant = 10,
    FireGiant = 11,
    FrostGiant = 12,
    CloudGiant = 13,
    StormGiant = 14,
    GiantRat = 15,
    CarrionCrawler = 16,
    EnormousSpider = 17,
    Skeleton = 18,
    Zombie = 19,
    Ghoul = 20,
    Ghast = 21,
    Wight = 22,
    Wraith = 23,
    Mummy = 24,
    Spectre = 25,
    Vampire = 26,
    Lich = 27,
    LizardMan = 28,
    LizardManKing = 29,
    Minotaur = 30,
    DisplacerBeast = 31,
    BoringBeetle = 32,
    Griffon = 33,
    Hydra = 34,
    Wyvern = 35,
    BlackDragon = 36,
    BlueDragon = 37,
    GreenDragon = 38,
    RedDragon = 39,
    WhiteDragon = 40,
    Dracolich = 41,
    Basilisk = 42,
    Gorgon = 43,
    Cockatrice = 44,
    Beholder = 45,
    OgreMage = 46,
    Bulette = 47,
    ShamblingMound = 48,
    Margoyle = 49,
    Dracolisk = 50,
    Mobat = 51,
    BlackPudding = 52,
    Otyugh = 53,
    NeoOtyugh = 54,
    Salamander = 55,
    Efreeti = 56,
    EarthElemental = 57,
    FireElemental = 58,
    UmberHulk = 59,
    Ettin = 60,
    OwlBear = 61,
    Bugbear = 62,
    Medusa = 63,
    GiantSpider = 64,
    PhaseSpider = 65,
    PoisonousSnake = 66,
    HellHound = 67,
    GiantCrocodile = 68,
    Drider = 69,
    IronGolem = 70,
    Rakshasa = 71,
    PurpleWorm = 72,
    DrowChampion = 73,
    DrowPriest = 74,
    DrowSorceress = 75,
    DrowPriestess = 76,
    Warrior = 77,
    Conjurer = 78,
    Acolyte = 79,
    Goon = 80,
    Archer = 81,
    Theurgist = 82,
    Priest = 83,
    Thug = 84,
    EvilChampion = 85,
    Magician = 86,
    DarkCleric = 87,
    Rogue = 88,
    DarkKnight = 89,
    Necromancer = 90,
    HighPriest = 91,
    Thief = 92,
    DarkWarlord = 93,
    Wizard = 94,
    Archpriest = 95,
    MasterThief = 96,
    DarkOverlord = 97,
    MasterWizard = 98,
    DarkDisciple = 99,
    HighThief = 100,
    VampireLord = 101,
    Vampiress = 102,
    Dazmilar = 103,
    OgreShaman = 104,
    SirDutiocs = 105,
    Vidruand = 106,
    HillGntShaman = 107,
    VampirePriest = 108,
    DrowAmazon = 109,
    RakshasaRukh = 110,
    RoadGuard = 111,
    Kallithrea = 112,
    Yemandra = 113,
    Krondasz = 114,
    Arderiel = 115,
    Tornilee = 116,
    Alias = 117,
    Dragonbait = 118,
    Nacacia = 119,
    Priam = 120,
    Vala = 121,
    Silk = 122,
    CaptainDaenor = 123,
    Grunschka = 124,
    Storm = 125,
    Shal = 126,
    Raizel = 127
};

// Used in [Add|Remove]NPC/NPCSays events
enum NPCLIST:u8 {
    None = 0,
    Kallithrea = 112,
    Yemandra = 113,
    Krondasz = 114,
    Arderiel = 115,
    Tornilee = 116,
    Alias = 117,
    Dragonbait = 118,
    Nacacia = 119,
    Priam = 120,
    Vala = 121,
    Silk = 122,
    CaptainDaenor = 123,
    Grunschka = 124,
    Storm = 125,
    Shal = 126,
    Raizel = 127
};

// Used in event condition InParty_Race
enum RACE:u8 {
    Elf = 0,
    HalfElf = 1,
    Dwarf = 2,
    Gnome = 3,
    Halfling = 4,
    Human = 5
};

// Used in Damage events
enum SAVETHROW:u8 {
    None = 0,
    HalfDamage = 1,
    NoDamage = 2,
    HitsBasedOnTHAC0 = 3
};

// Used in Damage events
enum SAVETYPE:u8 {
    Poison = 0,
    Petrification = 1,
    Wand = 2,
    Breath = 3,
    Spell = 4
};

// Used in Shop/SmallTown events
enum SHOPITEMTYPE:u8 {
    Plus0_Weapons_A = 0,
    Plus0_Weapons_B = 1,
    Plus0_Armor = 2,
    Plus1_Weapons = 3,
    Plus2_Weapons = 4,
    Plus3_Weapons = 5,
    Plus4_Weapons = 6,
    Plus5_Weapons = 7,
    Plus1_2_Armor = 8,
    Plus3_4_Armor = 9,
    Special_A = 10,
    Special_B = 11,
    Rings = 12,
    Wands = 13,
    Potions = 14,
    Scrolls = 15
};

// Used in Tavern events
enum SHOWTALE:u8 {
    InOrder = 0,
    AtRandom = 1
};

// Used in GainExperience/NPCSays/Sounds/TextStatement events
enum SOUNDLIST:u8 {
    NoSound = 0,
    Cast = 3,
    Blast = 4,
    Sorcery = 5,
    Death = 6,
    Missile = 7,
    Hit = 8,
    Lightning = 9,
    Swish = 10,
    Footstep = 11,
    Fireball = 12,
    Bowstring = 13,
    Sploosh = 14,
    Crackle = 15,
    Overture = 32,
    Treasure = 33,
    Foes = 34,
    Battle = 35,
    Mystery = 36,
    UhOh = 37,
    EvilMarch = 38,
    Victory = 39
};

// Used in GuidedTour events
enum STEPDIRECTION:u8 {
    Pause = 0,
    Left = 1,
    Right = 2,
    Forward = 3
};

// Used in Damage events
enum TARGET_DAMAGE:u8 {
    EntireParty = 0,
    ActiveCharacter = 1,
    OnePartyMemberAtRandom = 2,
    PercentChanceOnEach = 3
};

// Used in GainExperience events
enum TARGET_XP:u8 {
    EntireParty = 0,
    ActiveCharacter = 1
};

// Used in Stairs/Teleporter/TransferModule events
enum TRANSFERPLACE:u8 {
    Directly = 0,
    EntryPoint = 1
};

// Used in TransferModule events
enum TRANSFERTYPE:u8 {
    AttemptsToEnterTheCell = 0,
    IsInTheCell = 1
};

// Used in Combat/CombatPickOne events
enum TURNUNDEADMODIFIER:u8 {
    None = 0,
    Harder_2 = 1,
    Difficult_10 = 2,
    Impossible_100 = 3
};

// Used in Utilities events
enum UTIL_MATH:u8 {
    NoOperation = 0,
    StoredIn = 1,
    AddedTo = 2,
    SubtractedFrom = 3
};

// Used in Utilities events
enum UTIL_MULTI:u8 {
    None = 0,
    AllItemsPresent = 1,
    AnyOneOrMorePresent = 2
};

// Used in Stairs/Teleporter/TransferModule events
enum YESNO:u8 {
    Yes = 0,
    No = 1
};

/***********************
    Functions
***********************/
// Decompresses the compressed strings in String section
fn DecompressString (auto CompressedString) {
    str ReturnString = "";
    u8 InputChar = 0;

  // Iterate through characters - With the way it splits characters across bytes and is also NULL terminated, better to just iterate until end found and break
    for (u8 Position = 1, 0 == 0, Position = Position + 1) {
        u8 CurrentPos = Position % 4;
    // Break if iterated past compressed data or on last byte and on character that is split with the next byte (2/3)
        if (InputChar >= sizeof(CompressedString) || (InputChar == (sizeof(CompressedString) - 1) && ((CurrentPos == 2 )|| (CurrentPos == 3)))) {
            break;
        }

    // Get current character
        char CurrentChar;
        match (CurrentPos) {
        // Char 4 - 00000000 00000000 00111111
            (0):    {
                CurrentChar = (CompressedString[InputChar] & 0x3F);
                InputChar += 1;
            }
        // Char 1 - 11111100 00000000 00000000
            (1): {
                CurrentChar = ((CompressedString[InputChar] >> 2) & 0x3F);
            }
        // Char 2 - 00000011 11110000 00000000
            (2):    {
                CurrentChar = ((CompressedString[InputChar] & 0x03) << 4) | ((CompressedString[InputChar + 1] & 0xF0) >> 4);
                InputChar += 1;
            }
        // Char 3 - 00000000 00001111 11000000
            (3):    {
                CurrentChar = ((CompressedString[InputChar] & 0x0F) << 2) | ((CompressedString[InputChar + 1] & 0xC0)>> 6);
                InputChar += 1;
            }
        }

    /***
        Break if NULL
        This is actually a bug, the +64 shift for values less than 32 means this _should_ be for the @ symbol and,
        since it allows you to use that character and there are data lengths, it really shouldn't check for a NULL
        terminator here... but it does and actually breaks worse as it start the next string immediately after which
        throws everything off - since this _is_ using the datalengths, that behavior isn't replicated, just the early break
    ***/
        if (CurrentChar == 0) {
            break;
        }

    // Append character to string
        ReturnString = ReturnString + str(CurrentChar < 32 ? CurrentChar + 64 : CurrentChar);
    }

    return ReturnString;
};

// Formatting function for AC/THAC0 (RW)
fn FormatACTHAC0 (u8 Input) {
    s8 Val = 60 - Input;
    return Val;
};

// Cell zone values are zero based, should display as 1
fn FormatCellZone (u8 Input) {
    return Input + 1;
};

// Format function to return a clean Floor/Ceiling value in Map cells
fn FormatGrid (u8 Input) {
    IMG_10_FLOORCEILING ImageFloorCeiling @ 0x0020 + Input;

    return std::format("{:d}: {}",Input,std::string::replace(std::string::to_string(ImageFloorCeiling), "IMG_10_FLOORCEILING::", ""));
};

// Format function to return a clean Wall value in Map cells
fn FormatWall (u8 Input) {
  // Break early if no wall
    if (Input == 0) {
        return "00: None";
    }

    str ImageTemp;

    match (GameID) {
        (7): {
          // Get which of the 3 Wall slots the wall is for
            IMG_07_WALL ImageWall @ 0x0002 + ((Input -1) / 5);
          // Strip enum crap off
            ImageTemp = std::string::replace(std::string::to_string(ImageWall), "IMG_07_WALL::", "");
        }
        (10): {
          // Get which of the 3 Wall slots the wall is for
            IMG_10_WALL ImageWall @ 0x001C + ((Input -1) / 5);
          // Strip enum crap off
            ImageTemp = std::string::replace(std::string::to_string(ImageWall), "IMG_10_WALL::", "");
        }
        (_): {
            ImageTemp = std::format("Wall Set {:d}", ((Input -1) / 5) + 1);
        }
    }

  // Append image ID from slot and return
    return std::format("{:02d}: {} - {}",Input,ImageTemp,((Input -1) % 5) + 1);
};

// Make Percent values live up to their name
fn FormatPercent (u8 Input) {
    return std::string::to_string(Input) + "%";
};

// Returns a coordinate style value for the specified cell based on the module's size
fn GetCoordinates(u16 Input, u8 Width) {
    u8 X = Input % Width;
    u8 Y = Input / Width;

    return std::format("{:02d}x{:02d}", X, Y);
};

// Returns the direction for use in Map cell Wall/Obstruction names
fn GetDirection (u8 Input) {
    match (Input) {
        (0):    return "North";
        (1):    return "East";
        (2):    return "South";
        (3):    return "West";
    }
};

// Checks if specified cell is an Entry Point and return formatted string for the cell's name in the Map section
fn GetEntryPoint (u8 CellID) {
    str EntryPoint = "";
    for (u8 EntryPointID = 0, EntryPointID < 8, EntryPointID = EntryPointID + 1) {
        if(CellID == EntryPointCoordinates[EntryPointID].CellID) {
            EntryPoint = std::format(" - Entry Point {:d}", EntryPointID + 1);
            return EntryPoint;
        }
    }
    return EntryPoint;
};

// Returns the index in the EventHierarchy section for the event - Used in GetEventPath & GetEventNameLong
fn GetEventHierarchyID (u8 EventID) {
    for (u8 CurrentEvent = 0, CurrentEvent < CurrentHierarchy, CurrentEvent = CurrentEvent + 1) {
        if (EventID == EVHierarchy[CurrentEvent].EventID) {
            return CurrentEvent;
        }
    }

  // Return invalid value if not found
    return 255;
};

// Make Event names fancy
fn GetEventNameLong (u8 EventID, u8 EventTypeID) {
    u8 HierarchyID = GetEventHierarchyID(EventID);
    str EventName = std::format("{:03d}: ", EventID);

  // Break early on invalid event
    if (EventTypeID == 0) {
        EventName += "Invalid Event (Unused)";
        return EventName;
    }

    EventName += GetEventTypeName(EventTypeID);

  // All events _should_ have a parent and roll up to either a map, rest, or step event
    if (HierarchyID == 255) {
        EventName += " Event @ Unknown";
    }
    else {
        match (EVHierarchy[HierarchyID].ParentTypeID, EVHierarchy[HierarchyID].AltID) {
            (0,_):   EventName += " Event @ Unknown";
        // All Types - Alt 1 - Normal Chain
            (1 ... 27|32 ... 38,1): EventName += std::format(" - {:03d} Normal Chain Event", EVHierarchy[HierarchyID].ParentID);
        // Tavern - Alt 2 - Fight
            (7,2):                  EventName += std::format(" - {:03d} Tavern Fight Event", EVHierarchy[HierarchyID].ParentID);
        // Tavern - Alt 3 - Drinks
            (7,3):                  EventName += std::format(" - {:03d} Drunk Enough Event", EVHierarchy[HierarchyID].ParentID);
        // Temple - Alt 2 - Donation
            (9,2):                  EventName += std::format(" - {:03d} Made Donation Event", EVHierarchy[HierarchyID].ParentID);
        // Question_Button - Alt 2 - Label
            (10,2):                 EventName += std::format(" - {:03d} Button One", EVHierarchy[HierarchyID].ParentID);
        // Question_Button - Alt 3 - Label
            (10,3):                 EventName += std::format(" - {:03d} Button Two", EVHierarchy[HierarchyID].ParentID);
        // Question_Button - Alt 4 - Label
            (10,4):                 EventName += std::format(" - {:03d} Button Three", EVHierarchy[HierarchyID].ParentID);
        // Question_Button - Alt 5 - Label
            (10,5):                 EventName += std::format(" - {:03d} Button Four", EVHierarchy[HierarchyID].ParentID);
        // Question_Button - Alt 6 - Label
            (10,6):                 EventName += std::format(" - {:03d} Button Five", EVHierarchy[HierarchyID].ParentID);
        // Encounter - Alt 3 - Talk
            (15,3):                 EventName += std::format(" - {:03d} Talk Event", EVHierarchy[HierarchyID].ParentID);
        // Encounter - Alt 4 - Escape
            (15,4):                 EventName += std::format(" - {:03d} Separate Event", EVHierarchy[HierarchyID].ParentID);
        // WhoTries - Alt 2 - Success
            (18,2):                 EventName += std::format(" - {:03d} Made It Event", EVHierarchy[HierarchyID].ParentID);
        // WhoTries/Pays & EnterPassword - Alt 3 - Failure
            (18|19|20,3):           EventName += std::format(" - {:03d} Failed Event", EVHierarchy[HierarchyID].ParentID);
        // WhoPays - Alt 2 - Success
            (19,2):                 EventName += std::format(" - {:03d} Paid Event", EVHierarchy[HierarchyID].ParentID);
        // EnterPassword - Alt 2 - Success
            (20,2):                 EventName += std::format(" - {:03d} Got Password Event", EVHierarchy[HierarchyID].ParentID);
        // Question_List - Alt 2 - Answer
            (21,2):                 EventName += std::format(" - {:03d} Choice One", EVHierarchy[HierarchyID].ParentID);
        // Question_List - Alt 3 - Answer
            (21,3):                 EventName += std::format(" - {:03d} Choice Two", EVHierarchy[HierarchyID].ParentID);
        // Question_List - Alt 4 - Answer
            (21,4):                 EventName += std::format(" - {:03d} Choice Three", EVHierarchy[HierarchyID].ParentID);
        // Question_List - Alt 5 - Answer
            (21,5):                 EventName += std::format(" - {:03d} Choice Four", EVHierarchy[HierarchyID].ParentID);
        // Question_List - Alt 6 - Answer
            (21,6):                 EventName += std::format(" - {:03d} Choice Five", EVHierarchy[HierarchyID].ParentID);
        // Encounter - Alt 2 - Combat
            (21,2):                 EventName += std::format(" - {:03d} Combat Event", EVHierarchy[HierarchyID].ParentID);
        // Chain - Alt 2 - Event
            (23,2):                 EventName += std::format(" - {:03d} Branch", EVHierarchy[HierarchyID].ParentID);
        // QuestStage - Alt 2 - Accept
            (35,2):                 EventName += std::format(" - {:03d} Accept Event", EVHierarchy[HierarchyID].ParentID);
        // QuestStage - Alt 3 - Reject
            (35,3):                 EventName += std::format(" - {:03d} Reject Event", EVHierarchy[HierarchyID].ParentID);
        // Question_YesNo - Alt 2 - Yes
            (36,2):                 EventName += std::format(" - {:03d} \"Yes\" Event", EVHierarchy[HierarchyID].ParentID);
        // Question_YesNo - Alt 3 - No
            (36,3):                 EventName += std::format(" - {:03d} \"No\" Event", EVHierarchy[HierarchyID].ParentID);
        // Rest Events
            (101,0):                EventName += std::format(" - Zone {:d} Rest Event", EVHierarchy[HierarchyID].ZoneID);
        // Step Events
            (102,0):                EventName += std::format(" - Step Event {:d}", EVHierarchy[HierarchyID].ZoneID);
        // Map Events
            (103,0):                EventName += std::format(" - Map Event @ {}", GetCoordinates(EVHierarchy[HierarchyID].CellID, Width));
        // Invalid - _Shouldn't_ hit this
            (_,_):    EventName += " Invalid";
        }
    }
    return EventName;
};

// Returns short version of the specified event's name
fn GetEventNameShort (u8 EventID) {
    if (EventID == 0) {
        return "000: No Event";
    }
    u8 EventTypeID @ 0x0ECA + ((EventID -1) * 20);
    return std::format("{:03d}: {}", EventID, GetEventTypeName(EventTypeID));
};

// Builds a hierarchical path from the initial trigger event to the specified event - i.e. /StartEvent/SecondEvent/CurrentEvent
fn GetEventPath (u8 EventID) {
    str EventPath = "";
    u8 ID = EventID;

  // This should always return much early but setting 100 loop threshold to force break in case of self-referencing/circular loop
    for (u8 Iterate = 0, Iterate < 100, Iterate = Iterate + 1) {
        u8 HierarchyID = GetEventHierarchyID(ID);
        u8 ParentID = EVHierarchy[HierarchyID].ParentID;
        u8 AltID = EVHierarchy[HierarchyID].AltID;
        if (ParentID == 0) {
            return EventPath;
        }
        else {
            EventPath = std::format("/{:03d}.{:d}{}",ParentID,AltID,EventPath);
            ID = ParentID;
        }
    }
};

// Returns clean EventType name used in GetEventNameLong/Short
fn GetEventTypeName (u8 EventTypeID) {
    match (EventTypeID) {
         (0):   return "Unknown";
         (1):   return "Combat";
         (2):   return "Text Statement";
         (3):   return "Give Treasure";
         (4):   return "Damage";
         (5):   return "Stairs";
         (6):   return "Training Hall";
         (7):   return "Tavern";
         (8):   return "Shop";
         (9):   return "Temple";
        (10):   return "Question-Button";
        (11):   return "Transfer Module";
        (12):   return "Guided Tour";
        (13):   return "Add NPC";
        (14):   return "NPC Says";
        (15):   return "Encounter";
        (16):   return "Utilities";
        (17):   return "Sounds";
        (18):   return "Who Tries";
        (19):   return "Who Pays";
        (20):   return "Enter Password";
        (21):   return "Question-List";
        (22):   return "Small Town";
        (23):   return "Chain";
        (24):   return "Vault";
        (25):   return "Combat Treasure";
        (26):   return "Gain Experience";
        (27):   return "Pass Time";
        (28):   return "Unknown_28";
        (29):   return "Camp";
        (30):   return "Unknown_30";
        (31):   return "Unknown_31";
        (32):   return "Remove NPC";
        (33):   return "Pick One Combat";
        (34):   return "Teleporter";
        (35):   return "Quest Stage";
        (36):   return "Question-Yes/No";
        (37):   return "Tavern Tales";
        (38):   return "Special Item";
         (_):   return "Invalid";
    }
};

// Returns the decompressed strings in Header & Event sections (referenced String value returns the compressed string so need to decompress again)
// Note: DecompressString located in GB_UTIL_UA.cs
fn GetString(u16 StringID) {
    str String;
  // Exit early if no string is set - Not sure if a blank value would be better here?
    if (StringID == 0) {
        String = "Not set";
        return String;
    }

  // Decompress string and return
    String = DecompressString(Strings[0].StringList[StringID -1].String);
    return String;
};

// Helper function to more easily add hierarchy records to EventHierarchy
fn SetEventHierarchy (u8 EventID, u8 ZoneID, u16 CellID, u8 ParentID, u8 ParentTypeID, u8 AltID) {
    EVHierarchy[CurrentHierarchy].EventID = EventID;
    EVHierarchy[CurrentHierarchy].ZoneID = ZoneID;
    EVHierarchy[CurrentHierarchy].CellID = CellID;
    EVHierarchy[CurrentHierarchy].ParentID = ParentID + (ZoneID + CellID > 0 ? 0 : 1);
    EVHierarchy[CurrentHierarchy].ParentTypeID = ParentTypeID;
    EVHierarchy[CurrentHierarchy].AltID = AltID;
    CurrentHierarchy += 1;
    if (LastEventID < EventID) {
        LastEventID = EventID;
    }
};

// Returns clean name for Shop Item Types
fn ShopTypeName (u8 ShopItemTypeID) {
    match (ShopItemTypeID) {
         (0):   return "+0 Weapons A";
         (1):   return "+0 Weapons B";
         (2):   return "+0 Armor";
         (3):   return "+1 Weapons";
         (4):   return "+2 Weapons";
         (5):   return "+3 Weapons";
         (6):   return "+4 Weapons";
         (7):   return "+5 Weapons";
         (8):   return "+1,+2 Armor";
         (9):   return "+3,+4 Armor";
        (10):   return "Special A";
        (11):   return "Special B";
        (12):   return "Rings";
        (13):   return "Wands";
        (14):   return "Potions";
        (15):   return "Scrolls";
         (_):   return "None";
    }
};

// Cell zone values are zero based, translate 1 based display value for write
fn WriteCellZone (u8 Input) {
  // Try to prevent invalid values
    u8 ZoneID = (Input == 0||Input > 8) ? 0 : Input - 1;
    return ZoneID;
};

/***********************
    Pre-UA GEO file
    Standard GEO file type prior to 10
***********************/

// Wall image IDs used for each cardinal direction - 0 when no wall
bitfield WALL_NE {
    WallID_East : 4 [[name("East Wall"),format("FormatWall"),comment(std::format("Wall image used\n0: None\n1-5: Wall Set 1\n6-10: Wall Set 2\n11-15: Wall Set 3{}", GameID != 7 ? "\nWall sets used are specified in ECL file and cannot be display here" : ""))]];
    WallID_North : 4 [[name("North Wall"),format("FormatWall"),comment(std::format("Wall image used\n0: None\n1-5: Wall Set 1\n6-10: Wall Set 2\n11-15: Wall Set 3{}", GameID != 7 ? "\nWall sets used are specified in ECL file and cannot be display here" : ""))]];
};

bitfield WALL_SW {
    WallID_West : 4 [[name("West Wall"),format("FormatWall"),comment(std::format("Wall image used\n0: None\n1-5: Wall Set 1\n6-10: Wall Set 2\n11-15: Wall Set 3{}", GameID != 7 ? "\nWall sets used are specified in ECL file and cannot be display here" : ""))]];
    WallID_South : 4 [[name("South Wall"),format("FormatWall"),comment(std::format("Wall image used\n0: None\n1-5: Wall Set 1\n6-10: Wall Set 2\n11-15: Wall Set 3{}", GameID != 7 ? "\nWall sets used are specified in ECL file and cannot be display here" : ""))]];
};

// Door info for each cardinal direction
bitfield DOOR {
    match (GameID) {
      // Door section used by 7
      // Note: Door locks in 7 are handled by events - i.e. a door is flagged as being there and an event prevents passage until unlocked
        (7): {
            bool Door_North : 1 [[name("North Door"),comment("Boolean flag indicating if a door exists on this wall\nLocks are handled by events")]];
            padding : 1;
            bool Door_East : 1 [[name("East Door"),comment("Boolean flag indicating if a door exists on this wall\nLocks are handled by events")]];
            padding : 1;
            bool Door_South : 1 [[name("South Door"),comment("Boolean flag indicating if a door exists on this wall\nLocks are handled by events")]];
            padding : 1;
            bool Door_West : 1 [[name("West Door"),comment("Boolean flag indicating if a door exists on this wall\nLocks are handled by events")]];
            padding : 1;
        }
      // Door section 1-6/8-9
        (_): {
            DOORTYPE Door_North : 2 [[name("North Door"),comment("Controls if a door exists on this wall and its lock status")]];
            DOORTYPE Door_East : 2 [[name("East Door"),comment("Controls if a door exists on this wall and its lock status")]];
            DOORTYPE Door_South : 2 [[name("South Door"),comment("Controls if a door exists on this wall and its lock status")]];
            DOORTYPE Door_West : 2 [[name("West Door"),comment("Controls if a door exists on this wall and its lock status")]];
        }
    }
} [[inline]];

// 7 background controls are embedded in the "door" section - split out with a union to make more readable
bitfield BACKGROUND {
    padding : 1;
    bool UseBackground2 : 1 [[name("Background 2"),comment("Use Background 2 when indoors\nUnused if outdoors\nSetting both this and Background 3 true results in black background")]];
    padding : 1;
    bool UseBackground3 : 1 [[name("Background 3"),comment("Use Background 3 when indoors\nUnused if outdoors\nSetting both this and Background 2 true results in black background")]];
    padding : 4;
} [[inline]];

union DOORBACKGROUND {
    DOOR Door;
    BACKGROUND Background;
};

bitfield EVENT {
    EventID : 7 [[name("Event ID"),comment("Event triggered when player enters cell")]];
    bool IsInterior : 1 [[name("Indoors"),comment(std::format("Boolean flag indicating if the current cell is considered indoors or outdoors\nSets floor/ceiling and combat tiles used{}", GameID == 7 ? "\nWhen false (Outdoors), Background 3 is used\nIndoor background can be overridden by\nBackground 2/3 flags" : ""))]];
};

// Cell data is split into 4 blocks, with each cell having 1 byte in each block - bytes in order, starting at 0x0 (top-left)
struct CELL_A {
  // Block 1
    WALL_NE NorthEast [[inline]];
  // Block 2
    WALL_SW SouthWest @ ($ + (Width * Height) - 1) [[inline]];
  // Block 3
    EVENT Event @ ($ + (Width * Height * 2) - 1) [[inline]];
  // Block 4
    match (GameID) {
        (7):    DOORBACKGROUND Door @ ($ + (Width * Height * 3) - 1) [[inline]];
        (_):    DOOR Door @ ($ + (Width * Height * 3) - 1) [[inline]];
    }
} [[name(std::format("{:03d}: {}{}", std::core::array_index(), GetCoordinates(std::core::array_index(), Width), Event.EventID > 0 ? std::format(" - Event {:d}", Event.EventID) : ""))]];

struct GEO {
  // Slight variation between 1-3/5/8, 4/6, and 9 in first 2 bytes
    match (GameID) {
        (1): {
            u16 FileSize [[tree_hidden,name("File Size"),comment("File data size\nAlways 1024")]];
            CELL_A Map[Width * Height] [[inline]];
        }
        (4|9): {
            u8 Unknown_00 [[comment(std::format("{}", GameID == 4 ? "Unknown usage" : "Always 00"))]];
            u8 Unknown_01 [[comment(std::format("{}", GameID == 4 ? "Unknown usage" : "Always 00"))]];
            CELL_A Map[Width * Height] [[inline]];
        }
      // 7 has 8 byte header section
        (7): {
            u8 Height [[comment("Map\'s Y dimension size")]];
            u8 Width [[comment("Map\'s X dimension size")]];
            IMG_07_WALL WallSetID1 [[name("Wall Set 1")]];
            IMG_07_WALL WallSetID2 [[name("Wall Set 2")]];
            IMG_07_WALL WallSetID3 [[name("Wall Set 3")]];
            IMG_07_FLOORCEILING BackgroundID1 [[name("Background 1"),comment("Default background used in indoor cells")]];
            IMG_07_FLOORCEILING BackgroundID2 [[name("Background 2"),comment("Secondary indoor background\nBackground 2 flag must be set to use")]];
            IMG_07_FLOORCEILING BackgroundID3 [[name("Background 3"),comment("Background used in outdoor cells\nBackground 3 flag can force indoor use")]];
            CELL_A Map[Width * Height];
        }
    }
} [[inline]];

GEO GeoData[GameID < 10 ? 1 : 0] @ 0x00 [[inline]];

/***********************
    UA Strings (STRG) section
    Contains all defined strings (other than Module/Zone names) for the module

    This is actually the last section in the file but is pulled first so strings
    are available to display in other sections
***********************/
u16 Offset_String = GameID == 10 ? 0x169A : 0x0000;
u16 Offset_StringSize = 0x16A8;
u16 Offset_StringData = 0x1838;

struct STRING {
    u8 StringSize [[tree_hidden,name("Compressed Size"),comment("Size of compressed string\nCompression reduces stored size by 0-25%")]];    // Hidden for readability
    if (StringSize > 0) {
        char String[StringSize] @ Offset_StringData + std::math::accumulate(Offset_StringSize, Offset_StringSize + std::core::array_index(), 1) [[name(std::format("{:03d}", std::core::array_index() + 1)),format("DecompressString")]];
    }
} [[inline]];

struct STRG {
// FourCC & Size values hidden for readability
    char FOURCC[4] [[tree_hidden]];
    be u32 SectionSize [[tree_hidden]];
    u16 DataSize_Max [[tree_hidden,name("Data Size Max"),comment("Maximum size of compressed data")]];
    s16 Unknown_0B [[tree_hidden,comment("Unknown usage\nAppears to always be -1")]];
    u16 DataSize_Used [[tree_hidden,name("Data Size Used"),comment("Currently used compressed data size")]];
    STRING StringList[400] [[inline,name("String List"),comment("All defined strings for this module")]];
} [[inline]];

STRG Strings[GameID == 10 ? 1 : 0] @ Offset_String;

/***********************
    UA Header (HDR ) section
    Contains general module details, primarily set in Global Info
***********************/
u32 Offset_Header = 0x0010;

bitfield ZONE {
    Zone1 : 1 [[name("Zone 1")]];
    Zone2 : 1 [[name("Zone 2")]];
    Zone3 : 1 [[name("Zone 3")]];
    Zone4 : 1 [[name("Zone 4")]];
    Zone5 : 1 [[name("Zone 5")]];
    Zone6 : 1 [[name("Zone 6")]];
    Zone7 : 1 [[name("Zone 7")]];
    Zone8 : 1 [[name("Zone 8")]];
};

bitfield RESTEVENT {
    Minutes : 16;
    EventID : 8 [[format("GetEventNameShort")]];
    Chance : 7 [[format("FormatPercent")]];
    bool NoRest : 1 [[name("Can\'t rest")]];
} [[name(std::format("Zone {:d}", std::core::array_index() + 1))]];

struct STEPEVENT {
    u16 StepCount [[name("On Step")]];
    u8 Event [[format("GetEventNameShort")]];
    ZONE Zones;
} [[name(std::format("Step Event {:d}", std::core::array_index() + 1))]];

bitfield ENTRYPOINT_DIR {
    padding : 1;
    DIRECTION Direction : 2;
    padding : 5;
} [[inline]];

struct ENTRYPOINT {
    u8 Y;
    u8 X;
    ENTRYPOINT_DIR EntryDir;
    padding[1];
} [[name(std::format("Entry Point {:d}", std::core::array_index() + 1))]];

struct ART_WALLSLOT {
    IMG_10_WALL WallSlot [[name(std::format("Slot {:d}{}", std::core::array_index() + 1, IsOverland ? " (Unused)" : ""))]];
} [[inline]];

struct ART_COMBAT_DUNGEON {
    IMG_COMBAT_IN CombatArt_Indoor [[name(std::format("Indoor{}", IsOverland ? " (Unused)" : ""))]];
    IMG_COMBAT_OUT CombatArt_Outdoor [[name(std::format("Outdoor{}", IsOverland ? " (Unused)" : ""))]];
};

struct ART_COMBAT_OVERLAND {
    IMG_COMBAT_OUT CombatArt_Overland [[name(std::format("Zone {:d}{}", std::core::array_index() + 1, IsOverland ? "" : " (Unused)"))]];
} [[inline]];

struct BACKGROUNDSLOT {
    match (IsOverland) {
        (0):    IMG_10_FLOORCEILING BackgroundSlot1 [[name("Slot 1")]];
        (1):    IMG_PIC_MAP BackgroundSlot1 [[name("Slot 1")]];
    }
    IMG_10_FLOORCEILING BackgroundSlot2 [[name(std::format("Slot 2{}", IsOverland ? " (Unused)" : ""))]];
    IMG_10_FLOORCEILING BackgroundSlot3 [[name(std::format("Slot 3{}", IsOverland ? " (Unused)" : ""))]];
    IMG_10_FLOORCEILING BackgroundSlot4 [[name(std::format("Slot 4{}", IsOverland ? " (Unused)" : ""))]];
};

struct HDR_ZONE_NAME {
    char ZoneName[16] [[name(std::format("Zone {:d}", std::core::array_index() + 1)),format("std::string::to_string")]];
} [[inline]];

struct HDR_ZONE_MESSAGE {
    be u16 Overland_Zone_Message [[name(std::format("Zone {:d}{}", std::core::array_index() + 1, IsOverland ? "" : " (Unused)")),format("GetString")]];
} [[inline]];

struct HDR {
    char FOURCC[4] [[tree_hidden]];
    be u32 SectionSize [[tree_hidden]];
    u8 Unknown_00;
    u8 Unknown_01;
    u8 Height;
    u8 Width;
    ART_WALLSLOT WallSlot[3] [[name(std::format("Wall Art{}", IsOverland ? " (Unused)" : ""))]];
    bool AllowAreaView [[name(std::format("Allow Area View{}", IsOverland ? " (Unused)" : ""))]];
    BACKGROUNDSLOT FloorAndCeiling [[name(std::format("{}", IsOverland ? "Map Art" : "Floor & Ceiling Art"))]];
    ART_COMBAT_DUNGEON CombatArt [[name(std::format("Dungeon Combat Art{}", IsOverland ? " (Unused)" : ""))]];
    ENTRYPOINT EntryPoint[8] [[name("Entry Points")]];;
    RESTEVENT RestEvent[8] [[name("Rest Events")]];
    STEPEVENT StepEvent[8] [[name("Step Events")]];
    char TemplateName[8] [[name("Template Name"),format("std::string::to_string")]];
    char ModuleName[16] [[name("Module Name"),format("std::string::to_string")]];
    HDR_ZONE_NAME ZoneName[8] [[name("Zone Names")]];
    MONSTERLIST SummonedMonster [[name("Summoned Monster")]];
    u8 TurnUndeadModifier [[name("Undead Are More Difficult To Turn By")]];
    ART_COMBAT_OVERLAND CombatArt_Overland[8] [[name(std::format("Overland Combat Art{}", IsOverland ? "" : " (Unused)"))]];
    HDR_ZONE_MESSAGE ZoneMessage[8] [[name(std::format("Zone Messages{}", IsOverland ? "" : " (Unused)"))]];
    IMG_PIC_SMALL CampPicture [[name("Camp Picture")]];
    IMG_PIC_SMALL TreasurePicture [[name("Treasure Picture")]];
} [[inline]];

HDR Header[GameID == 10 ? 1 : 0] @ Offset_Header;

/***********************
    Map (MAP ) section
    Contains data for each cell in the map, starting at the top left corner

    Note:  Padded to max map size allowed - 576 cells (or a 24x24 square map)
***********************/
u32 Offset_EntryPoint = 0x0026;
u32 Offset_Map = 0x013A;

// This is a hidden struct to make looking up EntryPoints for Cell names in the Map easier
struct ENTRYPOINTCOORD {
    u8 Y [[hidden]];
    u8 X [[hidden]];
    u16 CellID = (Y * Width) + X;
    padding[2];
};

bitfield WALL_IN {
    WallID : 4 [[name("Wall Image ID"),format("FormatWall"),comment("ID of the wall image used\n0: None\n1-5: Slot1\n6-10: Slot 2\n11-15: Slot 3")]];
    MAP_OBSTRUCTION_IN Obstruction : 4 [[comment("Controls what type of obstruction exists (if any) in that direction from the current cell")]];
} [[name(std::format("{} Wall", GetDirection(std::core::array_index())))]];

bitfield WALL_OUT {
    padding : 4;
    MAP_OBSTRUCTION_OUT Obstruction : 4 [[name(std::format("{}", GetDirection(std::core::array_index()))),comment("Controls if player can travel that direction from current cell")]];
} [[inline]];

bitfield GRID {
    match (IsOverland) {
        (0):    BackdropID : 2 [[name("Floor & Ceiling Slot"),format("FormatGrid"),comment("Slot number for the cell\'s floor/ceiling background")]];
        (1):    padding : 2;
    }
    ZoneID : 6 [[name("Zone"),format_read("FormatCellZone"),format_write("WriteCellZone"),comment("Cell\'s assigned zone")]];
};

struct CELL {
    match (IsOverland) {
        (0):    WALL_IN Wall[4] [[inline]];
        (1):    WALL_OUT Wall[4] [[inline]];
    }
    u8 EventID [[name("Event"),format("GetEventNameShort"),comment("Event triggered on entering the cell")]];
    GRID Grid [[inline]];
} [[name(std::format("{:03d}: {}{}{}", std::core::array_index(), GetCoordinates(std::core::array_index(), Width), GetEntryPoint(std::core::array_index()), EventID > 0 ? " - " + GetEventNameShort(EventID) : ""))]];;

struct MAP {
    char FOURCC[4] [[tree_hidden]];
    be u32 SectionSize [[tree_hidden]];
    CELL Cell[Width * Height] [[inline]];
} [[inline]];

ENTRYPOINTCOORD EntryPointCoordinates[GameID == 10 ? 8 : 0] @ Offset_EntryPoint [[hidden]];
MAP Map[GameID == 10 ? 1 : 0] @ Offset_Map;

/***********************
    UA Event Hierarchy section
    This is a "helper" section added to assist with tracing event chain paths
***********************/
u32 EventOffset = 0x0ECA;

std::mem::Section EV_HIERARCHY = std::mem::create_section("Event Hierarchy");
// 100 Events max but oversizing this to 150 _just in case_
std::mem::set_section_size(EV_HIERARCHY,  1050);

struct EVENTHIERARCHY {
    u8 EventID [[name("Event ID")]];
    u8 ZoneID [[name("Rest Zone/Step Event")]];
    u16 CellID [[name("Map Cell ID")]];
    u8 ParentID [[name("Parent Event ID")]];
    u8 ParentTypeID [[name("Parent Type ID"),comment("The Event\'s parent event type\nNote: Map/Rest/Step events do not have a type and an ID was arbitrarily (made up) for them")]];
    u8 AltID [[name("Alternate Chain Number")]];   // Is set but not currently used
} [[comment("This section is not a real data section in the file\nIt exists to help build the event\'s path and chain type")]];

EVENTHIERARCHY EVHierarchy[150] @ 0x00 in EV_HIERARCHY;

u8 CurrentHierarchy = 0;
u8 LastEventID = 0; // Using this to track the actual number of events to limit lookup ranges in other functions - updated in SetEventHierarchy

// Build Hierarchy
// First add Zone events
u32 ZoneOffset = 0x0048;
u8 ZoneCount = GameID == 10 ? 8 : 0;

// Iterate through each Zone Rest/Step event
for (u8 ZoneID = 0, ZoneID < ZoneCount, ZoneID = ZoneID + 1) {
  // Get both Rest/Step EventIDs
    u8 RestEventID @ ZoneOffset;
    u8 StepEventID @ ZoneOffset + 32;
  // Add to EventHierarchy if set
    if (RestEventID > 0) {
        SetEventHierarchy(RestEventID,ZoneID + 1,0,0,101,0);
    }
    if (StepEventID > 0) {
        SetEventHierarchy(StepEventID,ZoneID + 1,0,0,102,0);
    }

  // Increment to next Zone
    ZoneOffset += 4;
};

// Next add cell events
u32 CellOffset = 0x0146;
u16 CellCount = (GameID == 10 ? Width * Height : 0);

// Iterate through each used cell in the map - Quicker/easier to just hit directly versus reading from Map struct
for (u16 CellID = 0, CellID < CellCount, CellID = CellID + 1) {
     u8 CellEventID @ CellOffset;
     if (CellEventID > 0) {
        SetEventHierarchy(CellEventID,0,CellID,0,103,0);
     }

     CellOffset += 6;
};

// Iterate through all events and get their chained/alt events (if any)
u8 EventCount = GameID == 10 ? 100 : 0;

for (u8 EventID = 0, EventID < 100, EventID = EventID + 1) {
  // Get the EventTypeID - needed so know if valid and/or has more than just standard direct chained event
    u8 EventTypeID @ EventOffset;
  // Check if this is actually an event - UA appears to leave remnants of removed events and just sets the EventTypeID to 0
    if (EventTypeID > 0) {
        u8 ChainID @ EventOffset + 3;

    // Get direct chains
        if (ChainID > 0) {
            SetEventHierarchy(ChainID,0,0,EventID,4,1);
        }

    // Get child events
     // Tavern - Fight/Drunk Events
        if (EventTypeID == 7) {
            u8 FightID @ EventOffset + 18;
            u8 DrunkID @ EventOffset + 19;
            if (FightID > 0) {
                SetEventHierarchy(FightID,0,0,EventID,EventTypeID,2);
            }
            if (DrunkID > 0) {
                SetEventHierarchy(DrunkID,0,0,EventID,EventTypeID,3);
            }
        }
    // Temple - Donation Event
        else if (EventTypeID == 9) {
            u8 DonationID @ EventOffset + 12;
            if (DonationID > 0) {
                SetEventHierarchy(DonationID,0,0,EventID,EventTypeID,2);
            }
        }
    // Question_Button/List - Events 1-5
        else if (EventTypeID == 10 || EventTypeID == 21) {
          // Didn't seem to want to work right here with an array
            u8 EventID1 @ EventOffset + 10;
            u8 EventID2 @ EventOffset + 11;
            u8 EventID3 @ EventOffset + 12;
            u8 EventID4 @ EventOffset + 13;
            u8 EventID5 @ EventOffset + 14;
            if (EventID1 > 0) {
                SetEventHierarchy(EventID1,0,0,EventID,EventTypeID,2);
            }
            if (EventID2 > 0) {
                SetEventHierarchy(EventID2,0,0,EventID,EventTypeID,3);
            }
            if (EventID3 > 0) {
                SetEventHierarchy(EventID3,0,0,EventID,EventTypeID,4);
            }
            if (EventID4 > 0) {
                SetEventHierarchy(EventID4,0,0,EventID,EventTypeID,5);
            }
            if (EventID5 > 0) {
                SetEventHierarchy(EventID5,0,0,EventID,EventTypeID,6);
            }
        }
    // Encounter - Combat/Talk/Escape Events
        else if (EventTypeID == 15) {
            u8 CombatID @ EventOffset + 17;
            u8 TalkID @ EventOffset + 18;
            u8 EscapeID @ EventOffset + 19;
            if (CombatID > 0) {
                SetEventHierarchy(CombatID,0,0,EventID,EventTypeID,2);
            }
            if (TalkID > 0) {
                SetEventHierarchy(TalkID,0,0,EventID,EventTypeID,3);
            }
            if (EscapeID > 0) {
                SetEventHierarchy(EscapeID,0,0,EventID,EventTypeID,4);
            }
        }
    // WhoTries/Pays & EnterPassword - Failure/Success Events
        else if (EventTypeID > 17 && EventTypeID < 21) {
            u8 FailureID @ EventOffset + 15;
            u8 SuccessID @ EventOffset + 16;
            if (FailureID > 0) {
                SetEventHierarchy(FailureID,0,0,EventID,EventTypeID,3);
            }
            if (SuccessID > 0) {
                SetEventHierarchy(SuccessID,0,0,EventID,EventTypeID,2);
            }
        }
    // Chain - Event0
        else if (EventTypeID == 23) {
            u8 EventID0 @ EventOffset + 8;
            if (EventID0 > 0) {
                SetEventHierarchy(EventID0,0,0,EventID,EventTypeID,2);
            }
        }
    // QuestStage - Accept/Reject Events
        else if (EventTypeID == 35) {
            u8 AcceptID @ EventOffset + 10;
            u8 RejectID @ EventOffset + 11;
            if (AcceptID > 0) {
                SetEventHierarchy(AcceptID,0,0,EventID,EventTypeID,2);
            }
            if (RejectID > 0) {
                SetEventHierarchy(RejectID,0,0,EventID,EventTypeID,3);
            }
        }
    // Question_YesNo - Yes/No Events
        else if (EventTypeID == 36) {
            u8 YesID @ EventOffset + 8;
            u8 NoID @ EventOffset + 9;
            if (YesID > 0) {
                SetEventHierarchy(YesID,0,0,EventID,EventTypeID,2);
            }
            if (NoID > 0) {
                SetEventHierarchy(NoID,0,0,EventID,EventTypeID,3);
            }
        }
    }

  // Iterate to next event
    EventOffset += 20;
};

// Can't really create this right in an IF block so just letting it create and purging it after if not 10
if (GameID != 10) {
    std::mem::delete_section(EV_HIERARCHY);
};

/***********************
    UA Events (ENCR) section
    Contains all events for this module
***********************/
u32 Offset_Event = GameID == 10 ? 0x0ECA : 0x0000;

// TrainHall/SmallTown events - Used to flag which classes can train
bitfield CLASSARRAY {
    bool MagicUser : 1 [[name("Magic-User")]];
    bool Cleric : 1;
    bool Thief : 1;
    bool Fighter : 1;
    bool Paladin : 1;
    bool Ranger : 1;
    padding : 2;
};

// GuidedTour events - Only one step listed so can handle as array
bitfield STEP<auto StepCount> {
    STEPDIRECTION Step : 2 [[name(std::format("Step {}{}", std::core::array_index() + 1, std::core::array_index() < StepCount ? "" : " (Unused)"))]];
} [[inline]];

// GuidedTour events struct
struct TOURSTEP<auto StepCount> {
    STEP<StepCount> TourStep[24] [[inline]];
};

// Shop/SmallTown events - Used in union with SHOPITEMLIST
bitfield SHOPTYPE {
    padding : 4;
    SHOPITEMTYPE TypeOfItems : 4 [[name("Type of Items")]];
};

// Shop/SmallTown events - Used in union with SHOPTYPE
/***
    Ordering _is_ in order but, due to how bytes/bits are read, looks wrong
    To help clarify the layout:
    --------Byte 3---------    --------Byte 2---------   ---------Byte 1---------
    07|06|05|04|03|02|01|00 || 07|06|05|04|03|02|01|00 || 07|06|05|04|03|02|01|00
     ShopType# |20|19|18|17 || 16|15|14|13|12|11|10|09 || 08|07|06|05|04|03|02|01
***/
bitfield SHOPITEMLIST<auto ShopItemTypeID> {
    match (ShopItemTypeID) {
    // +0 Weapons A
        (0|255): {
            MorningStar : 1 [[name("Morning Star")]];
            MilitaryPick : 1 [[name("Military Pick")]];
            AwlPike : 1 [[name("Awl Pike")]];
            x20_Bolts : 1 [[name("20 Bolts")]];
            padding : 4;
            LightCrossbow : 1 [[name("Light Crossbow")]];
            Dagger : 1 [[name("Dagger")]];
            x10_Darts : 1 [[name("10 Darts")]];
            Flail : 1 [[name("Flail")]];
            Halberd : 1 [[name("Halberd")]];
            Hammer : 1 [[name("Hammer")]];
            x5_Javelins : 1 [[name("5 Javelins")]];
            Mace : 1 [[name("Mace")]];
            x20_Arrows : 1 [[name("20 Arrows")]];
            BattleAxe : 1 [[name("Battle Axe")]];
            HandAxe : 1 [[name("Hand Axe")]];
            CompositeShortBow : 1 [[name("Composite Short Bow")]];
            CompositeLongBow : 1 [[name("Composite Long Bow")]];
            LongBow : 1 [[name("Long Bow")]];
            ShortBow : 1 [[name("Short Bow")]];
            Club : 1 [[name("Club")]];
        }
    // +0 Weapons B
        (1): {
            padding : 8;
            ShortSword : 1 [[name("Short Sword")]];
            TwoHandedSword : 1 [[name("Two-Handed Sword")]];
            Trident : 1 [[name("Trident")]];
            padding : 5;
            Scimitar : 1 [[name("Scimitar")]];
            Sling : 1 [[name("Sling")]];
            Spear : 1 [[name("Spear")]];
            QuarterStaff : 1 [[name("Quarter Staff")]];
            StaffSling : 1 [[name("Staff Sling")]];
            BastardSword : 1 [[name("Bastard Sword")]];
            BroadSword : 1 [[name("Broad Sword")]];
            LongSword : 1 [[name("Long Sword")]];
        }
    // +0 Armor
        (2): {
            padding : 8;
            PlateMail : 1 [[name("Plate Mail")]];
            RingMail : 1 [[name("Ring Mail")]];
            ScaleMail : 1 [[name("Scale Mail")]];
            Shield : 1 [[name("Shield")]];
            ElfinChain : 1 [[name("Elfin Chain")]];
            Mirror : 1 [[name("Mirror")]];
            padding : 2;
            Belt : 1 [[name("Belt")]];
            Boots : 1 [[name("Boots")]];
            Cloak : 1 [[name("Cloak")]];
            Robe : 1 [[name("Robe")]];
            BandedMail : 1 [[name("Banded Mail")]];
            ChainMail : 1 [[name("Chain Mail")]];
            Helm : 1 [[name("Helm")]];
            LeatherArmor : 1 [[name("Leather Armor")]];
        }
    // +1 Weapons
        (3): {
            LongSword_Plus1 : 1 [[name("Long Sword +1")]];
            ShortSword_Plus1 : 1 [[name("Short Sword +1")]];
            TwoHandedSword_Plus1 : 1 [[name("Two-Handed Sword +1")]];
            Trident_Plus1 : 1 [[name("Trident +1")]];
            padding : 4;
            Hammer_Plus1 : 1 [[name("Hammer +1")]];
            x2_Javelins_Plus1 : 1 [[name("2 Javelins +1")]];
            Mace_Plus1 : 1 [[name("Mace +1")]];
            x10_Bolts_Plus1 : 1 [[name("10 Bolts +1")]];
            Scimitar_Plus1 : 1 [[name("Scimitar +1")]];
            Sling_Plus1 : 1 [[name("Sling +1")]];
            QuarterStaff_Plus1 : 1 [[name("Quarter Staff +1")]];
            StaffSling_Plus1 : 1 [[name("Staff Sling +1")]];
            x10_Arrows_Plus1 : 1 [[name("10 Arrows +1")]];
            BattleAxe_Plus1 : 1 [[name("Battle Axe +1")]];
            CompositeShortBow_Plus1 : 1 [[name("Composite Short Bow +1")]];
            CompositeLongBow_Plus1 : 1 [[name("Composite Long Bow +1")]];
            LightCrossbow_Plus1 : 1 [[name("Light Crossbow +1")]];
            Dagger_Plus1 : 1 [[name("Dagger +1")]];
            x10_Darts_Plus1 : 1 [[name("10 Darts +1")]];
            Flail_Plus1 : 1 [[name("Flail +1")]];
        }
    // +2 Weapons
        (4): {
            LongSword_Plus2 : 1 [[name("Long Sword +2")]];
            ShortSword_Plus2 : 1 [[name("Short Sword +2")]];
            TwoHandedSword_Plus2 : 1 [[name("Two-Handed Sword +2")]];
            Trident_Plus2 : 1 [[name("Trident +2")]];
            padding : 4;
            Hammer_Plus2 : 1 [[name("Hammer +2")]];
            x2_Javelins_Plus2 : 1 [[name("2 Javelins +2")]];
            Mace_Plus2 : 1 [[name("Mace +2")]];
            x10_Bolts_Plus2 : 1 [[name("10 Bolts +2")]];
            Scimitar_Plus2 : 1 [[name("Scimitar +2")]];
            Sling_Plus2 : 1 [[name("Sling +2")]];
            QuarterStaff_Plus2 : 1 [[name("Quarter Staff +2")]];
            StaffSling_Plus2 : 1 [[name("Staff Sling +2")]];
            x10_Arrows_Plus2 : 1 [[name("10 Arrows +2")]];
            BattleAxe_Plus2 : 1 [[name("Battle Axe +2")]];
            CompositeShortBow_Plus2 : 1 [[name("Composite Short Bow +2")]];
            CompositeLongBow_Plus2 : 1 [[name("Composite Long Bow +2")]];
            LightCrossbow_Plus2 : 1 [[name("Light Crossbow +2")]];
            Dagger_Plus2 : 1 [[name("Dagger +2")]];
            x10_Darts_Plus2 : 1 [[name("10 Darts +2")]];
            Flail_Plus2 : 1 [[name("Flail +2")]];
        }
    // +3 Weapons
        (5): {
            LongSword_Plus3 : 1 [[name("Long Sword +3")]];
            ShortSword_Plus3 : 1 [[name("Short Sword +3")]];
            TwoHandedSword_Plus3 : 1 [[name("Two-Handed Sword +3")]];
            Trident_Plus3 : 1 [[name("Trident +3")]];
            padding : 4;
            Hammer_Plus3 : 1 [[name("Hammer +3")]];
            x2_Javelins_Plus3 : 1 [[name("2 Javelins +3")]];
            Mace_Plus3 : 1 [[name("Mace +3")]];
            x10_Bolts_Plus3 : 1 [[name("10 Bolts +3")]];
            Scimitar_Plus3 : 1 [[name("Scimitar +3")]];
            Sling_Plus3 : 1 [[name("Sling +3")]];
            QuarterStaff_Plus3 : 1 [[name("Quarter Staff +3")]];
            StaffSling_Plus3 : 1 [[name("Staff Sling +3")]];
            x10_Arrows_Plus3 : 1 [[name("10 Arrows +3")]];
            BattleAxe_Plus3 : 1 [[name("Battle Axe +3")]];
            CompositeShortBow_Plus3 : 1 [[name("Composite Short Bow +3")]];
            CompositeLongBow_Plus3 : 1 [[name("Composite Long Bow +3")]];
            LightCrossbow_Plus3 : 1 [[name("Light Crossbow +3")]];
            Dagger_Plus3 : 1 [[name("Dagger +3")]];
            x10_Darts_Plus3 : 1 [[name("10 Darts +3")]];
            Flail_Plus3 : 1 [[name("Flail +3")]];
        }
    // +4 Weapons
        (6): {
            LongSword_Plus4 : 1 [[name("Long Sword +4")]];
            ShortSword_Plus4 : 1 [[name("Short Sword +4")]];
            TwoHandedSword_Plus4 : 1 [[name("Two-Handed Sword +4")]];
            Trident_Plus4 : 1 [[name("Trident +4")]];
            padding : 4;
            Hammer_Plus4 : 1 [[name("Hammer +4")]];
            x2_Javelins_Plus4 : 1 [[name("2 Javelins +4")]];
            Mace_Plus4 : 1 [[name("Mace +4")]];
            x10_Bolts_Plus4 : 1 [[name("10 Bolts +4")]];
            Scimitar_Plus4 : 1 [[name("Scimitar +4")]];
            Sling_Plus4 : 1 [[name("Sling +4")]];
            QuarterStaff_Plus4 : 1 [[name("Quarter Staff +4")]];
            StaffSling_Plus4 : 1 [[name("Staff Sling +4")]];
            x10_Arrows_Plus4 : 1 [[name("10 Arrows +4")]];
            BattleAxe_Plus4 : 1 [[name("Battle Axe +4")]];
            CompositeShortBow_Plus4 : 1 [[name("Composite Short Bow +4")]];
            CompositeLongBow_Plus4 : 1 [[name("Composite Long Bow +4")]];
            LightCrossbow_Plus4 : 1 [[name("Light Crossbow +4")]];
            Dagger_Plus4 : 1 [[name("Dagger +4")]];
            x10_Darts_Plus4 : 1 [[name("10 Darts +4")]];
            Flail_Plus4 : 1 [[name("Flail +4")]];
        }
    // +5 Weapons
        (7): {
            LongSword_Plus5 : 1 [[name("Long Sword +5")]];
            ShortSword_Plus5 : 1 [[name("Short Sword +5")]];
            TwoHandedSword_Plus5 : 1 [[name("Two-Handed Sword +5")]];
            Trident_Plus5 : 1 [[name("Trident +5")]];
            padding : 5;
            Hammer_Plus5 : 1 [[name("Hammer +5")]];
            x2_Javelins_Plus5 : 1 [[name("2 Javelins +5")]];
            Mace_Plus5 : 1 [[name("Mace +5")]];
            x10_Bolts_Plus5 : 1 [[name("10 Bolts +5")]];
            Scimitar_Plus5 : 1 [[name("Scimitar +5")]];
            Sling_Plus5 : 1 [[name("Sling +5")]];
            QuarterStaff_Plus5 : 1 [[name("Quarter Staff +5")]];
            StaffSling_Plus5 : 1 [[name("Staff Sling +5")]];
            x10_Arrows_Plus5 : 1 [[name("10 Arrows +5")]];
            BattleAxe_Plus5 : 1 [[name("Battle Axe +5")]];
            CompositeShortBow_Plus5 : 1 [[name("Composite Short Bow +5")]];
            CompositeLongBow_Plus5 : 1 [[name("Composite Long Bow +5")]];
            LightCrossbow_Plus5 : 1 [[name("Light Crossbow +5")]];
            Dagger_Plus5 : 1 [[name("Dagger +5")]];
            x10_Darts_Plus5 : 1 [[name("10 Darts +5")]];
            Flail_Plus5 : 1 [[name("Flail +5")]];
        }
    // +1,+2 Armor
        (8): {
            RingMail_Plus2 : 1 [[name("Ring Mail +2")]];
            ScaleMail_Plus2 : 1 [[name("Scale Mail +2")]];
            Shield_Plus2 : 1 [[name("Shield +2")]];
            ElfinChain_Plus2 : 1 [[name("Elfin Chain +2")]];
            padding : 4;
            Shield_Plus1 : 1 [[name("Shield +1")]];
            ElfinChain_Plus1 : 1 [[name("Elfin Chain +1")]];
            CloakOfProt_Plus2 : 1 [[name("Cloak of Prot +2")]];
            BandedMail_Plus2 : 1 [[name("Banded Mail +2")]];
            ChainMail_Plus2 : 1 [[name("Chain Mail +2")]];
            Helm_Plus2 : 1 [[name("Helm +2")]];
            LeatherArmor_Plus2 : 1 [[name("Leather Armor +2")]];
            PlateMail_Plus2 : 1 [[name("Plate Mail +2")]];
            CloakOfProt_Plus1 : 1 [[name("Cloak of Prot +1")]];
            BandedMail_Plus1 : 1 [[name("Banded Mail +1")]];
            ChainMail_Plus1 : 1 [[name("Chain Mail +1")]];
            Helm_Plus1 : 1 [[name("Helm +1")]];
            LeatherArmor_Plus1 : 1 [[name("Leather Armor +1")]];
            PlateMail_Plus1 : 1 [[name("Plate Mail +1")]];
            RingMail_Plus1 : 1 [[name("Ring Mail +1")]];
            ScaleMail_Plus1 : 1 [[name("Scale Mail +1")]];
        }
    // +3,+4 Armor
        (9): {
            RingMail_Plus4 : 1 [[name("Ring Mail +4")]];
            ScaleMail_Plus4 : 1 [[name("Scale Mail +4")]];
            Shield_Plus4 : 1 [[name("Shield +4")]];
            ElfinChain_Plus4 : 1 [[name("Elfin Chain +4")]];
            padding : 4;
            Shield_Plus3 : 1 [[name("Shield +3")]];
            ElfinChain_Plus3 : 1 [[name("Elfin Chain +3")]];
            CloakOfProt_Plus4 : 1 [[name("Cloak of Prot +4")]];
            BandedMail_Plus4 : 1 [[name("Banded Mail +4")]];
            ChainMail_Plus4 : 1 [[name("Chain Mail +4")]];
            Helm_Plus4 : 1 [[name("Helm +4")]];
            LeatherArmor_Plus4 : 1 [[name("Leather Armor +4")]];
            PlateMail_Plus4 : 1 [[name("Plate Mail +4")]];
            CloakOfProt_Plus3 : 1 [[name("Cloak of Prot +3")]];
            BandedMail_Plus3 : 1 [[name("Banded Mail +3")]];
            ChainMail_Plus3 : 1 [[name("Chain Mail +3")]];
            Helm_Plus3 : 1 [[name("Helm +3")]];
            LeatherArmor_Plus3 : 1 [[name("Leather Armor +3")]];
            PlateMail_Plus3 : 1 [[name("Plate Mail +3")]];
            RingMail_Plus3 : 1 [[name("Ring Mail +3")]];
            ScaleMail_Plus3 : 1 [[name("Scale Mail +3")]];
        }
    // Special A
        (10): {
            BeltOfProt_Plus3 : 1 [[name("Belt of Prot +3")]];
            BootsOfSpeed : 1 [[name("Boots of Speed")]];
            GirdleOfGiantStrength : 1 [[name("Girdle of Giant Strength")]];
            PeriaptOfHealth : 1 [[name("Periapt of Health")]];
            padding : 4;
            Shield_Plus5 : 1 [[name("Shield +5")]];
            ElfinChain_Plus5 : 1 [[name("Elfin Chain +5")]];
            FineLongBow : 1 [[name("Fine Long Bow")]];
            x2_BlessedBolts : 1 [[name("2 Blessed Bolts")]];
            DartOfHornetsNest : 1 [[name("Dart of Hornet\'s Nest")]];
            CloakOfDisplacement : 1 [[name("Cloak of Displacement")]];
            SilverShield_Plus3 : 1 [[name("Silver Shield +3")]];
            SilverShield_Plus4 : 1 [[name("Silver Shield +4")]];
            CloakOfProt_Plus5 : 1 [[name("Cloak of Prot +5")]];
            BandedMail_Plus5 : 1 [[name("Banded Mail +5")]];
            ChainMail_Plus5 : 1 [[name("Chain Mail +5")]];
            Helm_Plus5 : 1 [[name("Helm +5")]];
            LeatherArmor_Plus5 : 1 [[name("Leather Armor +5")]];
            PlateMail_Plus5 : 1 [[name("Plate Mail +5")]];
            RingMail_Plus5 : 1 [[name("Ring Mail +5")]];
            ScaleMail_Plus5 : 1 [[name("Scale Mail +5")]];
        }
    // Special B
        (11): {
            GauntletsOfOgrePower : 1 [[name("Gauntlets of Ogre Power")]];
            LightCrossbowCursed_Minus3 : 1 [[name("Light Crossbow Cursed -3")]];
            padding : 6;
            VorpalLongSword : 1 [[name("Vorpal Long Sword")]];
            DrowLongSword_Plus1 : 1 [[name("Drow Long Sword +1")]];
            DrowLongSword_Plus3 : 1 [[name("Drow Long Sword +3")]];
            DrowLongSword_Plus4 : 1 [[name("Drow Long Sword +4")]];
            DrowChain_Plus1 : 1 [[name("Drow Chain +1")]];
            DrowChain_Plus3 : 1 [[name("Drow Chain +3")]];
            DrowChain_Plus4 : 1 [[name("Drow Chain +4")]];
            FineLongBow_Plus2 : 1 [[name("Fine Long Bow +2")]];
            JavelinOfLightning : 1 [[name("Javelin of Lightning")]];
            StoneOfGoodLuck : 1 [[name("Stone of Good Luck")]];
            NecklaceOfMissiles : 1 [[name("Necklace of Missiles")]];
            EyesOfCharming : 1 [[name("Eyes of Charming")]];
            BracersAC6 : 1 [[name("Bracers AC 6")]];
            BracersAC4 : 1 [[name("Bracers AC 4")]];
            BracersAC2 : 1 [[name("Bracers AC 2")]];
            LongSwordVsGiants : 1 [[name("Long Sword vs Giants")]];
        }
    // Rings
        (12): {
            padding : 8;
            RingOfFireResistance : 1 [[name("Ring of Fire Resistance")]];
            RingOfInvisibility : 1 [[name("Ring of Invisibility")]];
            RingOfBlinking : 1 [[name("Ring of Blinking")]];
            RingOfWizardry : 1 [[name("Ring of Wizardry")]];
            RingOfProtFromEvil : 1 [[name("Ring of Prot from Evil")]];
            padding : 3;
            Ring : 1 [[name("Ring")]];
            RingOfProt_Plus1 : 1 [[name("Ring of Prot +1")]];
            RingOfProt_Plus2 : 1 [[name("Ring of Prot +2")]];
            RingOfProt_Plus3 : 1 [[name("Ring of Prot +3")]];
            RingOfProt_Plus4 : 1 [[name("Ring of Prot +4")]];
            RingOfProt_Plus5 : 1 [[name("Ring of Prot +5")]];
            RingOfColdResistance : 1 [[name("Ring of Cold Resistance")]];
            RingOfElectricImmunity : 1 [[name("Ring of Electric Immunity")]];
        }
    // Wands
        (13): {
            padding : 16;
            WandOfIceStorm : 1 [[name("Wand of Ice Storm")]];
            WandOfFireballs : 1 [[name("Wand of Fireballs")]];
            WandOfLightning : 1 [[name("Wand of Lightning")]];
            WandOfMagicMissiles : 1 [[name("Wand of Magic Missiles")]];
            WandOfParalyzation : 1 [[name("Wand of Paralyzation")]];
            padding : 3;
        }
    // Potions
        (14): {
            padding : 16;
            PotionOfSpeed : 1 [[name("Potion of Speed")]];
            PotionOfHealing : 1 [[name("Potion of Healing")]];
            PotionExtraHealing : 1 [[name("Potion Extra Healing")]];
            PotionOfInvisibility : 1 [[name("Potion of Invisibility")]];
            PotionOfGiantStrength : 1 [[name("Potion of Giant Strength")]];
            ElixirOfYouth : 1 [[name("Elixir of Youth")]];
            padding : 2;
        }
    // Scrolls
        (15): {
            padding : 16;
            ScrollOfProtDragonBreath : 1 [[name("Scroll of Prot Dragon Breath")]];
            ClericScroll3Spells : 1 [[name("Cleric Scroll 3 Spells")]];
            ClericScroll3Spells : 1 [[name("Cleric Scroll 3 Spells")]];
            MageScroll3Spells : 1 [[name("Mage Scroll 3 Spells")]];
            MageScroll3Spells : 1 [[name("Mage Scroll 3 Spells")]];
            MageScroll3Spells : 1 [[name("Mage Scroll 3 Spells")]];
            MageScroll3Spells : 1 [[name("Mage Scroll 3 Spells")]];
            padding : 1;
        }
    }
};

// Shop/SmallTown events - Didn't want the ShopType to show up in the middle of the list of items so handled this way
union SHOP {
    u24 ShopTypeID @ $ [[hidden]];
    SHOPTYPE ShopType [[inline]];
    SHOPITEMLIST<ShopTypeID == 0 ? 255 : ((ShopTypeID & 0x0000F0) >> 4)> ItemsOffered [[name("Items Offered")]];
} [[name(std::format("Type {:d}: {}", std::core::array_index() + 1, ShopTypeName(ShopTypeID == 0 ? 255 : ((ShopTypeID & 0x0000F0) >> 4))))]];

// General event control
bitfield EVENTCONTROL {
    bool DoOnce : 1 [[name("Do Event Only Once")]];
    CHAINTYPE ChainControl : 2 [[name("Chain Control")]];
    CONDITIONTYPE ConditionType : 5 [[name("Event Happens If")]];
} [[inline]];

// General bitfield used for most event types
bitfield EVENT_BYTE_07<auto EventTypeID> {
    match (EventTypeID) {
    // Combat/PickOneCombat
        (1|33): {
            Morale : 7 [[name("Monster Morale")]];
        }
    // TextStatement/NPCSays
        (02|14): {
            DISTANCE Distance : 2;
            bool Text1_Highlight : 1 [[name("Text 1: Highlight")]];
            bool Text2_Highlight : 1 [[name("Text 2: Highlight")]];
            bool Text3_Highlight : 1 [[name("Text 3: Highlight")]];
            bool Text4_Highlight : 1 [[name("Text 4: Highlight")]];
            bool Text5_Highlight : 1 [[name("Text 5: Highlight")]];
        }
    // GiveTreasure/CombatTreasure
        (3|25): {
            padding : 7;
            bool IsIdentified : 1 [[name("Items are Identified")]];
        }
    // Damage
        (4): {
            padding : 2;
            TARGET_DAMAGE DamageTarget : 2 [[name("Attack is on")]];
            SAVETHROW SaveThrow : 2 [[name("Save for")]];
            padding : 1;
        }
    // Stairs/Teleporter
        (5|34): {
            padding : 2;
            DIRECTION Direction : 2;
            padding : 1;
            bool AskYesNo : 1 [[name("Ask \"Yes/No\" Question?")]];
            YESNO TransferOn : 1 [[name("Transfer On")]];
        }
    // TrainingHall/Shop/Vault/Camp
        (6|8|24|29): {
            padding : 2;
            bool BackupOneStep : 1 [[name("Back Up One Step When Leaving?")]];
            padding : 4;
        }
    // Tavern
        (7): {
            padding : 2;
            bool BackupOneStep : 1 [[name("Back Up One Step When Leaving?")]];
            SHOWTALE ShowTale : 1 [[name("Show Tavern Tales")]];
            bool AllowFights : 1 [[name("Allow Fights")]];
            bool AllowDrinks : 1 [[name("Allow Drinks")]];
            padding : 1;
        }
    // Temple
        (9): {
            padding : 2;
            bool BackupOneStep : 1 [[name("Back Up One Step When Leaving?")]];
            bool AllowDonation : 1 [[name("Allow Donations")]];
            Unknown_04 : 1;
            padding : 2;
        }
    // Question_Button/List
        (10|21): {
            padding : 2;
            bool Event1_ReturnToQuestion : 1 [[name("Event 1: Return to Question")]];
            bool Event2_ReturnToQuestion : 1 [[name("Event 2: Return to Question")]];
            bool Event3_ReturnToQuestion : 1 [[name("Event 3: Return to Question")]];
            bool Event4_ReturnToQuestion : 1 [[name("Event 4: Return to Question")]];
            bool Event5_ReturnToQuestion : 1 [[name("Event 5: Return to Question")]];
        }
    // TransferModule
        (11): {
            padding : 2;
            DIRECTION Direction : 2;
            TRANSFERTYPE TransferInCell : 1 [[name("Transfer the Party when")]];
            bool AskYesNo : 1 [[name("Ask \"Yes/No\" Question?")]];
            YESNO TransferOn : 1 [[name("Transfer On")]];
        }
    // GuidedTour
        (12): {
            padding : 2;
            DIRECTION Direction : 2 [[name("Facing")]];
            bool UseStartLocation : 1 [[name("Use Starting Location")]];
            bool ExecuteEventAtDestination : 1 [[name("Execute Event at Destination")]];
            padding : 2;
        }
    // AddNPC/Encounter/RemoveNPC
        (13|15|32): {
            DISTANCE Distance : 2 [[name(std::format("{}", EventTypeID == 15 ? "Monster Starts" : "Distance"))]];
            padding : 5;
        }
    // Utilities/Sounds (16|17) handled separately
    // WhoTries
        (18): {
            padding : 2;
            CHECKABILITYSKILL CheckAbilitySkill : 4 [[name("Check Ability/Skill")]];
            CHECKTYPE CheckType : 1 [[name(std::format("Check Type{}", (CheckAbilitySkill == CHECKABILITYSKILL::AlwaysSucceeds || CheckAbilitySkill == CHECKABILITYSKILL::AlwaysFails) ? " (Unused)" : ""))]];
        }
    // WhoPays
        (19): {
            padding : 2;
            CHECKMONEY MoneyType : 2 [[name("Needed for Success")]];
            padding : 3;
        }
    // EnterPassword
        (20): {
            padding : 7;
        }
    // SmallTown
        (22): {
            bool Temple : 1 [[comment("A Temple is available")]];
            bool TrainingHall : 1 [[name("Training Hall"),comment("A Training Hall is available")]];
            bool Shop : 1 [[comment("A Shop is available")]];
            bool Inn : 1 [[comment("An Inn is available")]];
            bool Tavern : 1 [[comment("A Tavern is available")]];
            bool Vault : 1 [[comment("A Vault is available")]];
            padding : 1;
        }
    // GainExperience
        (26): {
            padding : 2;
            TARGET_XP XPTarget : 1 [[name("Receives XP")]];
            padding : 4;
        }
    // QuestStage
        (35): {
            padding : 2;
            bool FailsUponRejection : 1 [[name("Quest Fails Upon Rejection")]];
            ACCEPTON AcceptOn : 3 [[name("Accept On")]];
            bool CompletedOnAcceptance : 1 [[name("Quest Completed Upon Acceptance")]];
        }
    // Question_YesNo
        (36): {
            padding : 2;
            bool YesEvent_Repeat : 1 [[name("After \"Yes\" Chain Repeat Question"),comment("This setting is mutually exclusive with \"Back Up One Step\"\nIf both are false the After Chain action is \"Nothing\"")]];
            bool NoEvent_Repeat : 1  [[name("After \"No\" Chain Repeat Question"),comment("This setting is mutually exclusive with \"Back Up One Step\"\nIf both are false the After Chain action is \"Nothing\"")]];
            bool NoEvent_BackupOne : 1 [[name("After \"No\" Chain Back Up One Step"),comment("This setting is mutually exclusive with \"Repeat Question\"\nIf both are false the After Chain action is \"Nothing\"")]];
            bool YesEvent_BackupOne : 1 [[name("After \"Yes\" Chain Back Up One Step"),comment("This setting is mutually exclusive with \"Repeat Question\"\nIf both are false the After Chain action is \"Nothing\"")]];
            padding : 1;
        }
    // SpecialItem
        (38): {
            padding : 2;
            ITEM_GIVETAKE Action : 1;
            padding : 4;
        }
    }
  // Used on all except listed so handled separate so don't have to repeat long comment for everything
    if (!(EventTypeID == 3 || EventTypeID == 25|| EventTypeID == 12 || EventTypeID == 16 || EventTypeID == 17)) {
        IMG_TYPE ImageType : 1 [[name("Image Type"),comment("Indicates if the displayed image is a Sprite or Picture\nThis is auto set based on the selected image and likely shouldn\'t be modified\nNote: \"No Art\" defaults to Picture")]];
    }
} [[inline]];

// Combat/PickOneCombat event monster details - bytes 8 -19
bitfield EVENT_01_33<auto EventTypeID> {
    MonsterCount : 5 [[name(std::format("Monster {:d} Count", std::core::array_index() + 1))]];
    match(std::core::array_index()) {
        (0): {
            bool IsOutdoors : 1 [[name("Outdoors")]];
            COMBAT_SURPRISE Surprised : 2;
        }
        (1): {
            bool IsFriendly4 : 1 [[name(std::format("Monster 4 is Friendly{}", EventTypeID == 33 ? " (Unused)" : ""))]];
            bool IsFriendly5 : 1 [[name(std::format("Monster 5 is Friendly{}", EventTypeID == 33 ? " (Unused)" : ""))]];
            bool IsFriendly6 : 1 [[name(std::format("Monster 6 is Friendly{}", EventTypeID == 33 ? " (Unused)" : ""))]];
        }
        (2): {
            bool AutoApproach : 1 [[name("Auto Approach")]];
            bool PartyNeverDies : 1 [[name("Party Never Dies")]];
            bool NoTreasureFromMonsters : 1 [[name("No Treasure from Monsters")]];
        }
        (3): {
            DISTANCE Distance : 2;
            bool MagicDoesntWork : 1 [[name("Magic Doesn\'t Work")]];
        }
        (4): {
            bool North : 1 [[name("Monsters are North of Party"),comment("This value is part of an enumeration list in the UI not easily replicated here\nCombination of this and other directional flag are used to set all directions monsters are placed\n\"In Front\" when all values are false")]];
            bool East : 1 [[name("Monsters are East of Party"),comment("This value is part of an enumeration list in the UI not easily replicated here\nCombination of this and other directional flag are used to set all directions monsters are placed\n\"In Front\" when all values are false")]];
            bool South : 1 [[name("Monsters are South of Party"),comment("This value is part of an enumeration list in the UI not easily replicated here\nCombination of this and other directional flag are used to set all directions monsters are placed\n\"In Front\" when all values are false")]];
        }
        (5): {
            bool West : 1 [[name("Monsters are West of Party"),comment("This value is part of an enumeration list in the UI not easily replicated here\nCombination of this and other directional flag are used to set all directions monsters are placed\n\"In Front\" when all values are false")]];
            TURNUNDEADMODIFIER TurnUndeadModifier : 2 [[name("Additional Difficulty in Turning Undead")]];
        }
    }
    MONSTERLIST MonsterType : 8 [[name(std::format("Monster {:d} Type", std::core::array_index() + 1))]];
} [[inline]];

// Sounds event struct - Used so can handle as array instead of listing 10 times
struct EVENT_SOUND {
    SOUNDLIST Sound [[name(std::format("Sound {:d}", std::core::array_index() + 1))]];
} [[inline]];

// TextStatement/NPCSays event byte 4
bitfield EVENT_02_14_BYTE_04<auto EventTypeID> {
    bool Text1_MustPressReturn : 1 [[name("Text 1: Must Press Return")]];
    bool Text2_MustPressReturn : 1 [[name("Text 2: Must Press Return")]];
    bool Text3_MustPressReturn : 1 [[name("Text 3: Must Press Return")]];
    bool Text4_MustPressReturn : 1 [[name("Text 4: Must Press Return")]];
    bool Text5_MustPressReturn : 1 [[name("Text 5: Must Press Return")]];
    if (EventTypeID == 2) {
        bool BackupOneStep : 1 [[name("Back Up One Step When Done")]];
    }
} [[inline]];

// Stairs/TransferModule/Teleporter event byte 12
bitfield EVENT_05_11_34_BYTE_0C<auto EventTypeID> {
    TRANSFERPLACE PlaceAt : 1 [[name("Place at")]];
    padding : 1;
    bool ExecuteEventAtDestination : 1 [[name("Execute Event at Destination")]];
    if (EventTypeID == 11) {
        bool DestroyDrowEquipment : 1 [[name("Destroy Drow Equipment")]];
    }
} [[inline]];

// Damage event byte 13
bitfield EVENT_04_BYTE_0D {
    SaveBonus : 4 [[name("Add to Saving Throw")]];
    SAVETYPE SaveType : 4 [[name("Saving Throw Type")]];
    padding : 5;
    DISTANCE Distance : 2;
} [[inline]];

// Temple event byte 4 - Done this way to force 0-7 values
bitfield EVENT_09_BYTE_04 {
    MaxSpellLevel : 3 [[name("Highest Spell Level Offered")]];
    padding : 5;
} [[inline]];

// Question_Button/List events byte 15
bitfield EVENT_10_21_BYTE_0F {
    bool Event1_BackupOneStep : 1 [[name("Event 1: Backup One Step")]];
    bool Event2_BackupOneStep : 1 [[name("Event 2: Backup One Step")]];
    bool Event3_BackupOneStep : 1 [[name("Event 3: Backup One Step")]];
    bool Event4_BackupOneStep : 1 [[name("Event 4: Backup One Step")]];
    bool Event5_BackupOneStep : 1 [[name("Event 5: Backup One Step")]];
} [[inline]];

// Encounter event bytes 9-14
bitfield EVENT_15_BYTE_09 {
    ENCOUNTERACTION Approach_Action : 3 [[name("Approach button will")]];
    bool Approach_Allowed : 1 [[name("Approach button is present")]];
    bool Approach_NotClose : 1 [[name("Approach not allowed when up close")]];
    padding : 3;
    ENCOUNTERACTION Retreat_Action : 3 [[name("Retreat button will")]];
    bool Retreat_Allowed : 1 [[name("Retreat button is present")]];
    padding : 4;
    ENCOUNTERACTION Fight_Action : 3 [[name("Fight button will")]];
    bool Fight_Allowed : 1 [[name("Fight button is present")]];
    bool Fight_OnlyClose : 1 [[name("Fight only allowed when up close")]];
    padding : 3;
    ENCOUNTERACTION Wait_Action : 3 [[name("Wait button will")]];
    bool Wait_Allowed : 1 [[name("Wait button is present")]];
    padding : 4;
    ENCOUNTERACTION Talk_Action : 3 [[name("Talk button will")]];
    bool Talk_Allowed : 1 [[name("Talk button is present")]];
    bool Talk_OnlyClose : 1 [[name("Talk only allowed when up close")]];
    padding : 3;
    ENCOUNTERACTION_ZERO RangeZero_Action : 3 [[name("If range goes to zero")]];
    padding : 5;
} [[inline]];

// Utilities event byte 4
bitfield EVENT_16_BYTE_04 {
    UTIL_MATH Math_Operation : 2 [[name("Math Operation")]];
    UTIL_MULTI Multi_Operation : 2 [[name("Multi-Item Check Operation")]];
    bool ExitPlayNow : 1 [[name("Exit Play Now")]];
    padding : 3;
} [[inline]];

// WhoTries/Pays/EnterPassword events byte 10
bitfield EVENT_18_19_20_BYTE_0A {
    CHECKACTION Failure_Action : 2 [[name("Failure Action")]];
    CHECKACTION Success_Action : 2 [[name("Success Action")]];;
    DIRECTION Direction : 2 [[name("Facing")]];
    bool ExecuteEventAtDestination : 1 [[name("Execute Event at Destination")]];
    padding : 1;
} [[inline]];

// SmallTown event byte 9
bitfield EVENT_22_BYTE_09 {
    COSTFACTOR Shop_CostFactor : 5 [[name("Shop Cost Factor")]];
    MaxSpellLevel : 3 [[name("Highest Temple Spell Level")]];
} [[inline]];

// Invalid struct - Used to show the invalid events as highlighted in Hex Editor so don't appear to be missed
struct EVENT_INVALID {
    u8 Invalid [[name(std::format("Invalid_{:02X}", std::core::array_index() + 4))]];
} [[inline]];

// Event struct
struct ENCR {
    u8 EventTypeID @ $ [[hidden]];
    str Path = std::format("{}", EventTypeID == 0 ? "N/A" : GetEventPath(std::core::array_index() + 1)) [[export,comment("Event chain path from originating event (Map/Rest/Step)")]];
    EVENTTYPE EventType [[name("Event Type")]];
    EVENTCONTROL Control;
    match (Control.ConditionType) {
        (CONDITIONTYPE::FacingDirection):   DIRECTION_ALL Direction [[name("Facing"),comment("Party must be facing this direction for event to trigger")]];
        (CONDITIONTYPE::InParty_Class):     CLASS Class [[comment("At least one party member must be this class for event to trigger")]];
        (CONDITIONTYPE::InParty_Race):      RACE Race [[comment("At least one party member must be this race for event to trigger")]];
        (CONDITIONTYPE::RandomPercentage):  u8 PercentChance [[name("Percent Chance"),format("FormatPercent"),comment("Odds of random event triggering\n1-99%")]];
        (CONDITIONTYPE::SpecialItem_True):  KEYITEMQUEST ItemQuest [[name("Item/Quest"),comment("Special Item or Key the party must have for event to trigger")]];
        (CONDITIONTYPE::SpecialItem_False): KEYITEMQUEST ItemQuest [[name("Item/Quest"),comment("Special Item or Key the party must not have for event to trigger")]];
        (CONDITIONTYPE::Quest_Complete):    KEYITEMQUEST ItemQuest [[name("Item/Quest"),comment("Quest the party must have completed for event to trigger")]];
        (CONDITIONTYPE::Quest_Failed):      KEYITEMQUEST ItemQuest [[name("Item/Quest"),comment("Quest the party must have completed for event to trigger")]];
        (CONDITIONTYPE::Quest_InProgress):  KEYITEMQUEST ItemQuest [[name("Item/Quest"),comment("Quest the party must have started for event to trigger")]];
        (_):                                u8 Condition [[name("Condition (Unused)")]];
    }
    u8 ChainEventID [[name("Chain Event"),format("GetEventNameShort"),comment("Normal chain event to execute after or instead of this event")]];
    match (EventTypeID) {
    // Combat/PickOneCombat
        (1|33): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            EVENT_01_33<EventTypeID> Monster[6] [[inline]];
        }
    // TextStatement/NPCSays
        (2|14): {
            EVENT_02_14_BYTE_04<EventTypeID> Byte04;
            match (EventTypeID) {
                 (2):   padding[1];
                (14):   NPCLIST NPC;
            }
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u16 Text1_String [[sealed,name("Text 1"),format("GetString")]];
            u16 Text2_String [[sealed,name("Text 2"),format("GetString")]];
            u16 Text3_String [[sealed,name("Text 3"),format("GetString")]];
            u16 Text4_String [[sealed,name("Text 4"),format("GetString")]];
            u16 Text5_String [[sealed,name("Text 5"),format("GetString")]];
            SOUNDLIST Hear [[name("Player Hears")]];
            padding[1];
        }
    // GiveTreasure/CombatTreasure
        (3|25): {
            u16 MNY_Platinum [[name("Platinum")]];
            padding[1];
            EVENT_BYTE_07<EventTypeID> Byte07;
            u16 MNY_Gem [[name("Gems")]];
            u16 MNY_Jewelry [[name("Jewelry")]];
            ITEMLIST Item1 [[name("Item 1")]];
            ITEMLIST Item2 [[name("Item 2")]];
            ITEMLIST Item3 [[name("Item 3")]];
            ITEMLIST Item4 [[name("Item 4")]];
            ITEMLIST Item5 [[name("Item 5")]];
            ITEMLIST Item6 [[name("Item 6")]];
            ITEMLIST Item7 [[name("Item 7")]];
            ITEMLIST Item8 [[name("Item 8")]];
        }
    // Damage
        (4): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u8 ATK_Count [[name("Number of Complete Attacks")]];
            u8 ATK_Rolls [[name("Number of Dice per Attack")]];
            u8 ATK_Dice [[name("Number of Sides per Dice")]];
            u8 ATK_Modifier [[name("Additional Damage per Attack")]];
            u8 ATK_THAC0 [[name("THAC0 of Attack"),format("FormatACTHAC0")]];
            EVENT_04_BYTE_0D Byte0D;
            padding[1];
            u8 PercentChanceOnEach [[name("Percent Chance on Each"),format("FormatPercent")]];
            padding[3];
        }
    // Stairs/TransferModule/Teleporter
        (5|11|34): {
            u16 PlayerAsk [[sealed,name("Player Asked"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u8 Row [[comment(std::format("Y coordinate in {} module to {} the party to when \"Place at\" set to \"Directly\"", EventTypeID == 11 ? "target" : "current", EventTypeID == 11 ? "transfer" : "move"))]];
            u8 Column [[comment(std::format("X coordinate in {} module to {} the party to when \"Place at\" set to \"Directly\"", EventTypeID == 11 ? "target" : "current", EventTypeID == 11 ? "transfer" : "move"))]];
            u16 PlayerReads [[sealed,name(std::format("Player Reads When {}", EventTypeID == 5 ? "Enters Stairwell" : EventTypeID == 11 ? "Transfers" : "Teleports")),format("GetString")]];
            EVENT_05_11_34_BYTE_0C<EventTypeID> Byte0C;
            match (EventTypeID) {
                (5|34): {
                    u8 EntryPointID [[name("Entry Point"),comment("Entry point in current module to move party to when \"Place at\" set to \"Entry Point\"")]];
                    padding[1];
                }
                (11): {
                    u8 EntryPointID [[name("Entry Point"),comment("Entry point in target module to transfer party to when \"Place at\" set to \"Entry Point\"")]];
                    MODULE ModuleID [[name("Destination Module")]];
                }
            }
            padding[5];
        }
    // TrainingHall
        (6): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_SMALLSPRITE PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            CLASSARRAY CanTrain [[name("Which Classes May Train")]];
            COSTTRAIN CostFactor [[name("Cost")]];
            padding[10];
        }
    // Tavern
        (7): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u16 TavernTale1 [[sealed,name("Tavern Tale 1"),format("GetString")]];
            u16 TavernTale2 [[sealed,name("Tavern Tale 2"),format("GetString")]];
            u16 TavernTale3 [[sealed,name("Tavern Tale 3"),format("GetString")]];
            u16 TavernTale4 [[sealed,name("Tavern Tale 4"),format("GetString")]];
            u16 DrinkList [[sealed,name("Drink Names"),format("GetString"),comment("List is delimited by \"^\"\nDrink strength towards \"Drunk Enough\" event:\nDrink 1: 0\nDrink 2: 6\nDrink 3: 10\nDrink 4: 15\nDrink 5: 30")]];
            u8 FightEventID [[name("Fight Event"),format("GetEventNameShort")]];
            u8 DrunkEventID [[name("Drunk Event"),format("GetEventNameShort"),comment("Triggered on combined drink point total of 60\nSee \"Drink Names\" comment for details")]];
        }
    // Shop
        (8): {
            padding[1];
            COSTFACTOR CostFactor [[name("Cost Factor")]];
            IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
            EVENT_BYTE_07<EventTypeID> Byte07;
            SHOP ShopType[4] [[inline]];
        }
    // Temple
        (9): {
            EVENT_09_BYTE_04 MaxSpellLevel;
            padding[1];
            IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
            EVENT_BYTE_07<EventTypeID> Byte07;
            u32 Donation_Platinum [[name("Donation Required")]];
            u8 Donation_Event [[name("Donation Event"),format("GetEventNameShort")]];
            u16 PlayerReads_Enter [[sealed,name("Player Reads On Enter"),format("GetString")]];
            u16 PlayerReads_WhileIn [[sealed,name("Player Reads While In"),format("GetString")]];
            padding[3];
        }
    // Question_Button/List
        (10|21): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u16 AnswerList [[sealed,name(std::format("{}", EventTypeID == 10 ? "Button Label" : "Answer List")),format("GetString"),comment("List is delimited by \"^\"")]];
            u8 Event1 [[name("Event 1"),format("GetEventNameShort")]];
            u8 Event2 [[name("Event 2"),format("GetEventNameShort")]];
            u8 Event3 [[name("Event 3"),format("GetEventNameShort")]];
            u8 Event4 [[name("Event 4"),format("GetEventNameShort")]];
            u8 Event5 [[name("Event 5"),format("GetEventNameShort")]];
            EVENT_10_21_BYTE_0F BackupOneStep;
            padding[4];
        }
    // GuidedTour
        (12): {
            u8 Start_Row [[name("Starting Row")]];
            u8 Start_Column [[name("Starting Column")]];
            u8 StepCount [[name("Number of Steps")]];
            EVENT_BYTE_07<EventTypeID> Byte07;
            TOURSTEP<StepCount> TourSteps [[inline]];
            u8 Text1_DisplayBeforeStep [[name("Text 1: Display Before Step")]];
            u8 Text2_DisplayBeforeStep [[name("Text 2: Display Before Step")]];
            u16 Text1_String [[sealed,name("Text 1"),format("GetString")]];
            u16 Text2_String [[sealed,name("Text 2"),format("GetString")]];
        }
    // Add/RemoveNPC
        (13|32): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            NPCLIST NPC [[name(std::format("{} NPC", EventTypeID == 13 ? "Add" : "Remove"))]];
            match (EventTypeID) {
                (13):   u8 MaxHP_Percent [[name("% of Max Hit Points"),format("FormatPercent")]];
                (32):   padding[1];
            }
            padding[10];
        }
    // Encounter
        (15): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u8 MON_Speed [[name("Monster Speed")]];
            EVENT_15_BYTE_09 EncounterAction;
            padding[1];
            padding[1];
            u8 Event_Combat [[name("Combat Event"),format("GetEventNameShort")]];
            u8 Event_Talk [[name("Talk Event"),format("GetEventNameShort")]];
            u8 Event_Escape [[name("Escape Event"),format("GetEventNameShort")]];
        }
    // Utilities
        (16): {
            EVENT_16_BYTE_04 Byte04;
            KEYITEMQUEST Math_QuestItem [[name(std::format("Math Quest/Item{}", Byte04.Math_Operation == UTIL_MATH::NoOperation ? " (Unused)" : ""))]];
            u8 Math_Value [[name(std::format("Math Value{}", Byte04.Math_Operation == UTIL_MATH::NoOperation ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check1 [[name(std::format("Multi-Item Check 1{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check2 [[name(std::format("Multi-Item Check 2{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check3 [[name(std::format("Multi-Item Check 3{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check4 [[name(std::format("Multi-Item Check 4{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check5 [[name(std::format("Multi-Item Check 5{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_Check6 [[name(std::format("Multi-Item Check 6{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            KEYITEMQUEST Multi_StoreIn [[name(std::format("Multi-Item Check Result{}", Byte04.Multi_Operation == UTIL_MULTI::None ? " (Unused)" : ""))]];
            padding[6];
        }
    // Sounds
        (17): {
            EVENT_SOUND Sound[10] [[inline]];
            padding[6];
        }
    // WhoTries/Pays/EnterPassword
        (18|19|20): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (EventTypeID,IsOverland) {
                (18|19,0):  IMG_PIC_SMALLSPRITE PlayerSees [[name("Player Sees")]];
                (18|19,1):  IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
                (20,0):     IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (21,1):     IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
          // Flag "always" checks for WhoTries once to make the rest a little cleaner
            match (EventTypeID) {
                (18):   bool IsAlways = (Byte07.CheckAbilitySkill == CHECKABILITYSKILL::AlwaysSucceeds || Byte07.CheckAbilitySkill == CHECKABILITYSKILL::AlwaysFails);
                (_):    bool IsAlways = false;
            }
            match (EventTypeID) {
                (18): {
                    u8 CheckValue [[name(std::format("Check Value{}", IsAlways ? " (Unused)" : ""))]];
                    u8 NumberOfTries [[name(std::format("Number of Tries{}", IsAlways ? " (Unused)" : ""))]];
                }
                (19): {
                    u16 MNY_Value [[name("Amount Must Pay")]];
                }
                (20): {
                    u16 Password [[sealed,name("Password"),format("GetString")]];
                }
            }
            EVENT_18_19_20_BYTE_0A Byte10;
            u16 Failure_PlayerReads [[sealed,name("Failure Text"),format("GetString")]];
            u16 Success_PlayerReads [[sealed,name("Success Text"),format("GetString")]];
            u8 Failure_Event [[name("Failure Event"),format("GetEventNameShort")]];
            u8 Success_Event [[name("Success Event"),format("GetEventNameShort")]];
            u8 Column;
            u8 Row;
            match (EventTypeID) {
                (18):   u8 STR_Percent [[name(std::format("% Strength{}", IsAlways ? " (Unused)" : "")),format("FormatPercent")]];
                (19):   padding[1];
                (20):   u8 NumberOfTries [[name("Number of Tries")]];
            }
        }
    // SmallTown
        (22): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            CLASSARRAY CanTrain [[name("Classes May Train"),comment("Classes allowed to train at this Training Hall\nNote: Training Hall must be selected as available")]];
            EVENT_22_BYTE_09 Byte09;
            u16 TavernTale [[sealed,name("Tavern Tale"),format("GetString")]];
            COSTFACTOR TrainingHallTemple_CostModifier [[name("Training Hall & Temple Cost Factor")]];
            padding[1];
            SHOP ShopType[2] [[name("Shop Items"),comment("Items types available in the Shop\nNote: Shop must be selected as available")]];
        }
    // Chain
        (23): {
            padding[4];
            u8 ChainTo_Event [[name("Chain To"),format("GetEventNameShort")]];
            padding[11];
        }
    // Vault/Camp
        (24|29): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland,EventTypeID) {
                (0,24): IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
                (0,29): IMG_PIC_SMALLSPRITE PlayerSees [[name("Player Sees")]];
                (1,_):  IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            padding[12];
        }
    // GainExperience
        (26): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            IMG_PIC_SMALL PlayerSees [[name("Player Sees")]];
            EVENT_BYTE_07<EventTypeID> Byte07;
            u32 ExperiencePoints [[name("Experience Points")]];
            SOUNDLIST PlayerHears [[name("Player Hears")]];
            padding[7];
        }
    // PassTime
        (27): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            padding[2];
            u8 Days;
            u8 Hours;
            u8 Minutes;
            padding[9];
        }
    // Unused types
        (28|30|31): padding[16];
    // QuestStage
        (35): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            KEYITEMQUEST Quest;
            u8 Stage;
            u8 Accept_Event [[name("Accept Event"),format("GetEventNameShort")]];
            u8 Reject_Event [[name("Reject Event"),format("GetEventNameShort")]];
            padding[8];
        }
    // Question_YesNo
        (36): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            u8 Yes_Event [[name("\"Yes\" Event"),format("GetEventNameShort")]];
            u8 No_Event [[name("\"No\" Event"),format("GetEventNameShort")]];
            u16 Yes_String [[name("\"Yes\" Text"),sealed,format("GetString")]];
            u16 No_String [[name("\"No\" Text"),sealed,format("GetString")]];
            padding[6];
        }
    // TavernTales
        (37): {
            padding[4];
            u16 Tale1 [[sealed,name("Tale 1"),format("GetString")]];
            u16 Tale2 [[sealed,name("Tale 2"),format("GetString")]];
            u16 Tale3 [[sealed,name("Tale 3"),format("GetString")]];
            u16 Tale4 [[sealed,name("Tale 4"),format("GetString")]];
            u16 Tale5 [[sealed,name("Tale 5"),format("GetString")]];
            u16 Tale6 [[sealed,name("Tale 6"),format("GetString")]];
        }
    // SpecialItem
        (38): {
            u16 PlayerReads [[sealed,name("Player Reads"),format("GetString")]];
            match (IsOverland) {
                (0):    IMG_PIC_ALL PlayerSees [[name("Player Sees")]];
                (1):    IMG_PIC_NOSPRITE PlayerSees [[name("Player Sees")]];
            }
            EVENT_BYTE_07<EventTypeID> Byte07;
            KEYITEMQUEST Item;
            padding[11];
        }
        (_):    EVENT_INVALID Invalid[16] [[inline]];
    }
} [[name(GetEventNameLong(std::core::array_index() + 1, EventTypeID))]];

ENCR Event[GameID == 10 ? LastEventID : 0] @ Offset_Event;