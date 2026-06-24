#pragma author Draxinusom
#pragma description Gold Box Games - Item Base
import std.core;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the base item
 files for all Gold Box games (D&D, no one cares about Buck Rogers)

 Supported Games:
 01 - Pool of Radiance (ITEMS)
 02 - Curse of the Azure Bonds (ITEMS)
 03 - Secret of the Silver Blades (ITEMS)
 04 - Pools of Darkness (ITEMS)
 05 - Champions of Krynn (ITEMS)
 06 - Death Knights of Krynn (ITEMS)
 07 - The Dark Queen of Krynn (DISK1\ITEMS.DAT)
 08 - Gateway to the Savage Frontier (ITEMS.1)
 09 - Treasures of the Savage Frontier (ITEMS)
 10 - Unlimited Adventures (DISK1\ITEMS.DAT)

 The GameID variable below must be set for to the number in the list above for
 the source game, with the exception of 8 which can be auto detected by file size
*********/
u8 GameID = 0;

// Get file size
u32 FileSize = std::mem::size();
// Some games have an unknown 2 byte prefix that needs skipped - Possibly just a file type identifier
u32 Offset = (FileSize == 2048 ? 0x00 : 0x02);
// Bracers handle AC like armor but doesn't have a specific type across all games so need to know which record to ensure is handled correctly
u8 BracerID = (GameID == 1 || GameID == 2 || GameID == 8) ? 77 : 50;

// Check file is (at least likely) the base ITEM file
if (FileSize != 2048 && FileSize != 2050 && FileSize != 3074) {
    std::warning("Unknown file. Exiting.");
    return;
}

// Check GameID is set
if (GameID == 0) {
  // Can auto set 8
    if (FileSize == 3074) {
        GameID = 8;
        std::print("Gateway to the Savage Frontier detected. GameID set to 8.");
    }
    else {
        std::warning("Please set the GameID variable to the source game's number.");
        return;
    }
}

// Ensure GameID is in range
if (GameID > 10) {
    std::warning("Invalid GameID. Aborting.");
    return;
}

// Abort if GameID doesn't match file size
if (((GameID == 1 || GameID == 2 || GameID == 3 || GameID == 5 || GameID == 6) && FileSize != 2050) || ((GameID == 4 || GameID == 7 || GameID == 9 || GameID == 10) && FileSize != 2048) || (GameID == 8 && FileSize != 3074)) {
    std::warning("Invalid file for specified game. Aborting.");
    return;
}

/*******************************
    Enumerations
*******************************/
// Damage Type - 1-3/5-8
enum ITEMDAMAGETYPE_A:u8 {
    Slashing = 0,
    Piercing = 1,
    Bludgeoning = 128
};

// Damage Type - 4/9-10
enum ITEMDAMAGETYPE_B:u8 {
    Unknown = 0,
    PiercingSlashing = 1,
    Bludgeoning = 128
};

// Item Restriction
bitfield CLASSRESTRICTION {
    MagicUser : 1 [[name("Magic-User")]];
    Cleric : 1;
    Thief : 1;
    Fighter : 1;
    match (GameID) {
        (1|2|8): {
            Druid : 1 [[name("Druid*"),comment("Unused")]];
            Monk : 1 [[name("Monk*"),comment("Unused")]];
        }
        (5|6|7): {
            Knight : 1 [[name("Knight")]];
            Druid : 1 [[name("Druid*"),comment("Unused")]];
        }
        (_): {
            Knight : 1 [[name("Knight*"),comment("Unused")]];
            Druid : 1 [[name("Druid*"),comment("Unused")]];
        }
    }
    match (GameID) {
        (1): {
            PaladinRanger : 1 [[name("Paladin/Ranger*"),comment("Unused")]];
            padding : 1;
        }
        (5|6|7): {
            Paladin : 1;
            Ranger : 1;
        }
        (_): {
            Paladin : 1 [[comment("Ranger class characters refer to this value")]];
            Ranger : 1 [[name("Ranger**"),comment("Ranger class characters have Paladin flag set\nUnused")]];
        }
    }
};

/***
    Item Type - Also referred to as "Slot"
    This _does_ vary between games, though just by some types above 10/Other being unused in some games
    As they aren't set anywhere, there's not much point in making multiple ENUMs that skip them

    This appears to have been defined once in 1 and then reused for every game afterwards
***/
enum ITEMTYPE:u8 {
    Weapon = 0,
    Shield =  1,
    Armor =  2,
    Hands =  3,
    Head =  4,
    BeltNeck =  5,
    Robe =  6,
    Cloak =  7,
    Boots =  8,
    Ring =  9,
    Other = 10,
    MUScroll = 11,
    CLScroll = 12,
    LeatherHolySymbol = 74,
    BrassKey = 75,
    Bracers = 77,
    Wand = 78,
    PotionOfGiantStrength = 80,
    Unknown_81 = 81,
    EfreetiBottle = 82,
    Unknown_83 = 83,
    Pass = 91
};

// Weapon Flag
bitfield WEAPONFLAGARRAY{
    LaunchArrow : 1 [[comment("Requires an equipped arrow to use")]];
    IsRanged : 1 [[comment("Indicates this is a ranged weapon\nWhen set and LaunchArrow/Bolt & IsThrown are not, it does not require any ammo (slings)")]];
    STR_Bonus : 1 [[comment("Add strength bonus to attack")]];
    IsMultiFire : 1 [[comment("Can fire multiple missles in one attack\nUses RateOfFire to determine the number")]];
    IsThrown : 1 [[comment("Indicates the weapon can be thrown\nDepending on weapon can be used in both melee and thrown")]];
    padding : 2;
    LaunchBolt : 1 [[comment("Requires an equipped bolt/quarrel to use")]];
};

/*******************************
    Functions
*******************************/

// AC - Formats Armor/Bracers AC for display
fn ACArmorRead(u8 Input) {
    return 10 - (60 - (Input & 127));
// This can be more easily read as: Input - 178
// However, I believe the above is how it's actually handled in game
};

// AC - Formats non-Armor/Bracers AC for display
fn ACOtherRead(u8 Input) {
    if (Input == 0) {
        return "-";
    }
    else {
        return Input & 0x7F;
    }
};

// AC - Formats Armor/Bracers AC from user input
fn ACArmorWrite(u8 Input) {
    return 178 + Input;
};

// AC - Formats non-Armor/Bracers AC from user input
fn ACOtherWrite(u8 Input) {
    if (Input == 255) {
        return 0;
    }
    else {
        return 128 + Input;
    }
};

/***
    Display Name
    This is not an actual enumeration type but an attempt to assign generic names to
    all base item records from the item records using it so it's a bit easier to read

    Where the name is "Unused", the record is composed of all 00s and unused
    * in the name signifies there are no usages of that record for this game
      and the type was deduced (guessed) by comparing to other games
    ** in the name signifies an issue with that record in that game
***/
fn GetDisplayName(u16 ID) {
    match (ID) {
    // 01 - Pool of Radiance
           (0): return "Invalid*";
           (1): return "Battle Axe";
           (2): return "Hand Axe";
           (3): return "Bardiche";
           (4): return "Bec de Corbin";
           (5): return "Bill-Guisarme";
           (6): return "Bo Stick";
           (7): return "Club";
           (8): return "Dagger";
           (9): return "Dart";
          (10): return "Fauchard";
          (11): return "Fauchard-Fork";
          (12): return "Flail";
          (13): return "Military Fork";
          (14): return "Glaive";
          (15): return "Glaive-Guisarme";
          (16): return "Guisarme";
          (17): return "Guisarme-Voulge";
          (18): return "Halberd";
          (19): return "Lucern Hammer";
          (20): return "Hammer";
          (21): return "Javelin";
          (22): return "Jo Stick";
          (23): return "Mace";
          (24): return "Morning Star";
          (25): return "Partisan";
          (26): return "Military Pick";
          (27): return "Awl Pike";
          (28): return "Bolt";
          (29): return "Ranseur";
          (30): return "Scimitar";
          (31): return "Spear";
          (32): return "Spetum";
          (33): return "Quarter Staff";
          (34): return "Bastard Sword";
          (35): return "Broad Sword";
          (36): return "Long Sword";
          (37): return "Short Sword";
          (38): return "Two-Handed Sword";
          (39): return "Trident";
          (40): return "Voulge";
          (41): return "Composite Long Bow";
          (42): return "Composite Short Bow";
          (43): return "Long Bow";
          (44): return "Short Bow";
          (45): return "Fine Composite Long Bow";
          (46): return "Light Crossbow";
          (47): return "Sling";
          (48): return "Unused";
          (49): return "Unused";
          (50): return "Leather Armor";
          (51): return "Padded Armor";
          (52): return "Studded Leather Armor";
          (53): return "Ring Mail";
          (54): return "Scale Mail";
          (55): return "Chain Mail";
          (56): return "Splint Mail";
          (57): return "Banded Mail";
          (58): return "Plate Mail";
          (59): return "Shield";
          (60): return "Scroll of Protection*";
          (61): return "Magic-User Scroll";
          (62): return "Cleric Scroll";
          (63): return "Gauntlets";
          (64): return "Helm*";
          (65): return "Belt*";
          (66): return "Robe*";
          (67): return "Cloak";
          (68): return "Boots";
          (69): return "Ring";
          (70): return "Potions/Misc";
          (71): return "Potions/Misc";
          (72): return "Misc";
          (73): return "Arrow";
          (74): return "Leather Holy Symbol";
          (75): return "Brass Key";
          (76): return "Cursed Necklace";
          (77): return "Bracers";
          (78): return "Wand";
          (79): return "Wand";
          (80): return "Unknown Item*";
          (81): return "Unknown Item*";
          (82): return "Efreeti Bottle";
          (83): return "Unknown Item";
          (84): return "Potion of Giant Strength";
          (85): return "Holy Water Vial";
          (86): return "Flask of Oil";
          (87): return "Boulder";
          (88): return "Unknown Thrown*";
          (89): return "Unknown Melee*";
          (90): return "Ring of Feather Falling";
          (91): return "Pass";
          (92): return "Cloak of Displacement";
          (93): return "Ring of Protection";
          (94): return "Unknown Fine Bow";
          (95): return "Unknown Fine Bow";
          (96): return "Unknown Fine Bow";
          (97): return "Unused";
          (98): return "Unused";
          (99): return "Unused";
         (100): return "Unused";
         (101): return "Unused";
         (102): return "Unused";
         (103): return "Unused";
         (104): return "Unused";
         (105): return "Unused";
         (106): return "Unused";
         (107): return "Unused";
         (108): return "Unused";
         (109): return "Unused";
         (110): return "Unused";
         (111): return "Unused";
         (112): return "Unused";
         (113): return "Unused";
         (114): return "Unused";
         (115): return "Unused";
         (116): return "Unused";
         (117): return "Unused";
         (118): return "Unused";
         (119): return "Unused";
         (120): return "Unused";
         (121): return "Unused";
         (122): return "Unused";
         (123): return "Unused";
         (124): return "Unused";
         (125): return "Unused";
         (126): return "Unused";
         (127): return "Invalid*";
     // 02 - Curse of the Azure Bonds
         (128): return "Invalid*";
         (129): return "Battle Axe";
         (130): return "Hand Axe";
         (131): return "Bardiche";
         (132): return "Bec de Corbin";
         (133): return "Bill-Guisarme";
         (134): return "Bo Stick";
         (135): return "Club";
         (136): return "Dagger";
         (137): return "Dart";
         (138): return "Fauchard";
         (139): return "Fauchard-Fork";
         (140): return "Flail";
         (141): return "Military Fork";
         (142): return "Glaive";
         (143): return "Glaive-Guisarme";
         (144): return "Guisarme";
         (145): return "Guisarme-Voulge";
         (146): return "Halberd";
         (147): return "Lucern Hammer";
         (148): return "Hammer";
         (149): return "Javelin";
         (150): return "Jo Stick";
         (151): return "Mace";
         (152): return "Morning Star";
         (153): return "Partisan";
         (154): return "Military Pick";
         (155): return "Awl Pike";
         (156): return "Bolt";
         (157): return "Ranseur";
         (158): return "Scimitar";
         (159): return "Spear";
         (160): return "Spetum";
         (161): return "Quarter Staff";
         (162): return "Bastard Sword";
         (163): return "Broad Sword";
         (164): return "Long Sword";
         (165): return "Short Sword";
         (166): return "Two-Handed Sword";
         (167): return "Trident";
         (168): return "Voulge";
         (169): return "Composite Long Bow";
         (170): return "Composite Short Bow";
         (171): return "Long Bow";
         (172): return "Short Bow";
         (173): return "Fine Composite Long Bow*";
         (174): return "Light Crossbow";
         (175): return "Sling";
         (176): return "Unused";
         (177): return "Unused";
         (178): return "Leather Armor";
         (179): return "Padded Armor";
         (180): return "Studded Leather Armor";
         (181): return "Ring Mail";
         (182): return "Scale Mail";
         (183): return "Chain Mail";
         (184): return "Splint Mail";
         (185): return "Banded Mail";
         (186): return "Plate Mail";
         (187): return "Shield";
         (188): return "Scroll of Protection";
         (189): return "Magic-User Scroll";
         (190): return "Cleric Scroll";
         (191): return "Gauntlets";
         (192): return "Helm";
         (193): return "Belt";
         (194): return "Robe";
         (195): return "Cloak*";
         (196): return "Boots*";
         (197): return "Ring";
         (198): return "Potions/Misc";
         (199): return "Potions/Misc";
         (200): return "Misc*";
         (201): return "Arrow";
         (202): return "Leather Holy Symbol*";
         (203): return "Brass Key*";
         (204): return "Cursed Necklace*";
         (205): return "Bracers";
         (206): return "Wand";
         (207): return "Wand";
         (208): return "Unknown Item*";
         (209): return "Unknown Item*";
         (210): return "Efreeti Bottle*";
         (211): return "Unknown Item";
         (212): return "Potion of Giant Strength";
         (213): return "Holy Water Vial*";
         (214): return "Flask of Oil";
         (215): return "Boulder*";
         (216): return "Unknown Thrown*";
         (217): return "Unknown Melee*";
         (218): return "Ring of Feather Falling*";
         (219): return "Pass*";
         (220): return "Cloak of Displacement";
         (221): return "Ring of Protection";
         (222): return "Drow Mace";
         (223): return "Elfin Chain Mail";
         (224): return "Drow Chain Mail";
         (225): return "Drow Long Sword";
         (226): return "Spine";
         (227): return "Ring of Wizardry";
         (228): return "Dart of Hornet's Nest";
         (229): return "Staff Sling";
         (230): return "Unused";
         (231): return "Unused";
         (232): return "Unused";
         (233): return "Unused";
         (234): return "Unused";
         (235): return "Unused";
         (236): return "Unused";
         (237): return "Unused";
         (238): return "Unused";
         (239): return "Unused";
         (240): return "Unused";
         (241): return "Unused";
         (242): return "Unused";
         (243): return "Unused";
         (244): return "Unused";
         (245): return "Unused";
         (246): return "Unused";
         (247): return "Unused";
         (248): return "Unused";
         (249): return "Unused";
         (250): return "Unused";
         (251): return "Unused";
         (252): return "Unused";
         (253): return "Unused";
         (254): return "Unused";
         (255): return "Invalid*";
     // 03 - Secret of the Silver Blades
         (256): return "Invalid*";
         (257): return "Battle Axe";
         (258): return "Hand Axe";
         (259): return "Club*";
         (260): return "Dagger";
         (261): return "Dart";
         (262): return "Hammer";
         (263): return "Javelin";
         (264): return "Mace";
         (265): return "Morning Star";
         (266): return "Military Pick*";
         (267): return "Awl Pike*";
         (268): return "Bolt";
         (269): return "Scimitar";
         (270): return "Spear*";
         (271): return "Quarter Staff";
         (272): return "Bastard Sword*";
         (273): return "Broad Sword";
         (274): return "Long Sword";
         (275): return "Short Sword";
         (276): return "Two-Handed Sword";
         (277): return "Trident";
         (278): return "Composite Long Bow";
         (279): return "Composite Short Bow*";
         (280): return "Long Bow";
         (281): return "Short Bow";
         (282): return "Fine Long Bow";
         (283): return "Light Crossbow";
         (284): return "Sling";
         (285): return "Staff Sling";
         (286): return "Arrow";
         (287): return "Leather Armor";
         (288): return "Ring Mail*";
         (289): return "Scale Mail";
         (290): return "Chain Mail";
         (291): return "Banded Mail";
         (292): return "Plate Mail";
         (293): return "Shield";
         (294): return "Scroll of Protection";
         (295): return "Magic-User Scroll";
         (296): return "Cleric Scroll";
         (297): return "Helm*";
         (298): return "Belt";
         (299): return "Robe*";
         (300): return "Cloak*";
         (301): return "Boots";
         (302): return "Ring";
         (303): return "Potions/Misc";
         (304): return "Mirror";
         (305): return "Misc*";
         (306): return "Bracers";
         (307): return "Wand";
         (308): return "Wand";
         (309): return "Potion of Giant Strength";
         (310): return "Cute Yellow Canary";
         (311): return "Boulder";
         (312): return "Boulder";
         (313): return "Boulder";
         (314): return "Cloak of Displacement";
         (315): return "Ring of Protection";
         (316): return "Mace of Disruption*";
         (317): return "Elfin Chain*";
         (318): return "Drow Chain Mail*";
         (319): return "Drow Long Sword*";
         (320): return "Spine*";
         (321): return "Ring of Wizardry";
         (322): return "Dart of Hornet's Nest";
         (323): return "Hoopak*";
         (324): return "Solamnic Plate*";
         (325): return "Footman's Dragonlance*";
         (326): return "Flail";
         (327): return "Halberd";
         (328): return "Gauntlets";
         (329): return "Bundle of Scrolls";
         (330): return "Leather Holy Symbol*";
         (331): return "Brass Key*";
         (332): return "Belt*";
         (333): return "Bracers*";
         (334): return "Wand*";
         (335): return "Wand*";
         (336): return "Unknown Item*";
         (337): return "Unknown Item*";
         (338): return "Efreeti Bottle*";
         (339): return "Unknown Item";
         (340): return "Potion of Giant Strength*";
         (341): return "Holy Water Vial*";
         (342): return "Flask of Oil*";
         (343): return "Boulder*";
         (344): return "Unknown Thrown*";
         (345): return "Unknown Melee*";
         (346): return "Ring of Feather Falling*";
         (347): return "Pass*";
         (348): return "Cloak of Displacement*";
         (349): return "Ring of Protection*";
         (350): return "Drow Mace*";
         (351): return "Elfin Chain Mail*";
         (352): return "Drow Chain Mail*";
         (353): return "Drow Long Sword*";
         (354): return "Spine*";
         (355): return "Ring of Wizardry*";
         (356): return "Dart of Hornet's Nest*";
         (357): return "Staff Sling*";
         (358): return "Unused";
         (359): return "Unused";
         (360): return "Unused";
         (361): return "Unused";
         (362): return "Unused";
         (363): return "Unused";
         (364): return "Unused";
         (365): return "Unused";
         (366): return "Unused";
         (367): return "Unused";
         (368): return "Unused";
         (369): return "Unused";
         (370): return "Unused";
         (371): return "Unused";
         (372): return "Unused";
         (373): return "Unused";
         (374): return "Unused";
         (375): return "Unused";
         (376): return "Unused";
         (377): return "Unused";
         (378): return "Unused";
         (379): return "Unused";
         (380): return "Unused";
         (381): return "Unused";
         (382): return "Unused";
         (383): return "Invalid*";
     // 04 - Pools of Darkness
         (384): return "Unused";
         (385): return "Battle Axe";
         (386): return "Hand Axe";
         (387): return "Club";
         (388): return "Dagger";
         (389): return "Dart";
         (390): return "Hammer";
         (391): return "Javelin";
         (392): return "Mace";
         (393): return "Morning Star";
         (394): return "Military Pick";
         (395): return "Awl Pike";
         (396): return "Bolt";
         (397): return "Scimitar";
         (398): return "Spear";
         (399): return "Quarter Staff";
         (400): return "Bastard Sword";
         (401): return "Broad Sword";
         (402): return "Long Sword";
         (403): return "Short Sword";
         (404): return "Two-Handed Sword";
         (405): return "Trident";
         (406): return "Composite Long Bow";
         (407): return "Composite Short Bow";
         (408): return "Long Bow";
         (409): return "Short Bow";
         (410): return "Fine Long Bow";
         (411): return "Light Crossbow";
         (412): return "Sling";
         (413): return "Staff Sling";
         (414): return "Arrow";
         (415): return "Leather Armor";
         (416): return "Ring Mail";
         (417): return "Scale Mail";
         (418): return "Chain Mail";
         (419): return "Banded Mail";
         (420): return "Plate Mail";
         (421): return "Shield";
         (422): return "Scroll of Protection";
         (423): return "Magic-User Scroll";
         (424): return "Cleric Scroll";
         (425): return "Helm";
         (426): return "Belt";
         (427): return "Robe";
         (428): return "Cloak";
         (429): return "Boots";
         (430): return "Ring";
         (431): return "Potions/Misc";
         (432): return "Mirror";
         (433): return "Misc*";
         (434): return "Bracers";
         (435): return "Wand";
         (436): return "Wand*";
         (437): return "Potion of Giant Strength";
         (438): return "Unknown Item*";
         (439): return "Holy Water Vial*";
         (440): return "Flask of Oil*";
         (441): return "Boulder*";
         (442): return "Cloak of Displacement";
         (443): return "Ring of Protection";
         (444): return "Mace of Disruption*";
         (445): return "Elfin Chain";
         (446): return "Drow Chain Mail";
         (447): return "Drow Long Sword";
         (448): return "Spine*";
         (449): return "Ring of Wizardry";
         (450): return "Dart of Hornet's Nest";
         (451): return "Hoopak*";
         (452): return "Solamnic Plate*";
         (453): return "Footman's Dragonlance*";
         (454): return "Flail";
         (455): return "Halberd**";
         (456): return "Gauntlets";
         (457): return "Vorpal Long Sword";
         (458): return "Blessed Bolt";
         (459): return "Cloak of Protection";
         (460): return "Brass Key*";
         (461): return "Belt*";
         (462): return "Bracers*";
         (463): return "Wand*";
         (464): return "Wand*";
         (465): return "Unknown Item*";
         (466): return "Unknown Item*";
         (467): return "Efreeti Bottle*";
         (468): return "Unknown Item";
         (469): return "Potion of Giant Strength*";
         (470): return "Holy Water Vial*";
         (471): return "Flask of Oil*";
         (472): return "Boulder*";
         (473): return "Unknown Thrown*";
         (474): return "Unknown Melee*";
         (475): return "Ring of Feather Falling*";
         (476): return "Pass*";
         (477): return "Cloak of Displacement*";
         (478): return "Ring of Protection*";
         (479): return "Drow Mace*";
         (480): return "Elfin Chain Mail*";
         (481): return "Drow Chain Mail*";
         (482): return "Drow Long Sword*";
         (483): return "Spine*";
         (484): return "Ring of Wizardry*";
         (485): return "Dart of Hornet's Nest*";
         (486): return "Staff Sling*";
         (487): return "Unused";
         (488): return "Unused";
         (489): return "Unused";
         (490): return "Unused";
         (491): return "Unused";
         (492): return "Unused";
         (493): return "Unused";
         (494): return "Unused";
         (495): return "Unused";
         (496): return "Unused";
         (497): return "Unused";
         (498): return "Unused";
         (499): return "Unused";
         (500): return "Unused";
         (501): return "Unused";
         (502): return "Unused";
         (503): return "Unused";
         (504): return "Unused";
         (505): return "Unused";
         (506): return "Unused";
         (507): return "Unused";
         (508): return "Unused";
         (509): return "Unused";
         (510): return "Unused";
         (511): return "Unused";
     // 05 - Champions of Krynn
         (512): return "Invalid*";
         (513): return "Battle Axe";
         (514): return "Hand Axe*";
         (515): return "Club*";
         (516): return "Dagger";
         (517): return "Dart";
         (518): return "Hammer*";
         (519): return "Javelin*";
         (520): return "Mace";
         (521): return "Morning Star*";
         (522): return "Military Pick*";
         (523): return "Awl Pike*";
         (524): return "Bolt*";
         (525): return "Scimitar*";
         (526): return "Spear*";
         (527): return "Quarter Staff";
         (528): return "Bastard Sword*";
         (529): return "Broad Sword";
         (530): return "Long Sword";
         (531): return "Short Sword";
         (532): return "Two-Handed Sword";
         (533): return "Trident*";
         (534): return "Composite Long Bow";
         (535): return "Composite Short Bow*";
         (536): return "Long Bow*";
         (537): return "Short Bow";
         (538): return "Fine Long Bow*";
         (539): return "Light Crossbow*";
         (540): return "Sling";
         (541): return "Staff Sling";
         (542): return "Arrow";
         (543): return "Leather Armor";
         (544): return "Ring Mail";
         (545): return "Scale Mail";
         (546): return "Chain Mail";
         (547): return "Banded Mail";
         (548): return "Plate Mail";
         (549): return "Shield";
         (550): return "Scroll of Protection";
         (551): return "Magic-User Scroll";
         (552): return "Cleric Scroll";
         (553): return "Helm*";
         (554): return "Belt";
         (555): return "Robe*";
         (556): return "Cloak*";
         (557): return "Boots*";
         (558): return "Ring*";
         (559): return "Potions/Misc";
         (560): return "Mirror*";
         (561): return "Misc*";
         (562): return "Bracers";
         (563): return "Wand";
         (564): return "Wand";
         (565): return "Potion of Giant Strength*";
         (566): return "Holy Water Vial*";
         (567): return "Flask of Oil*";
         (568): return "Boulder*";
         (569): return "Unknown Thrown";
         (570): return "Cloak of Displacement";
         (571): return "Ring of Protection";
         (572): return "Mace of Disruption";
         (573): return "Elfin Chain*";
         (574): return "Drow Chain Mail*";
         (575): return "Drow Long Sword**";
         (576): return "Spine*";
         (577): return "Ring of Wizardry*";
         (578): return "Dart of Hornet's Nest*";
         (579): return "Hoopak";
         (580): return "Solamnic Plate";
         (581): return "Footman's Dragonlance";
         (582): return "Flail";
         (583): return "Halberd*";
         (584): return "Gauntlets";
         (585): return "Unused";
         (586): return "Leather Holy Symbol*";
         (587): return "Brass Key*";
         (588): return "Belt*";
         (589): return "Bracers*";
         (590): return "Wand*";
         (591): return "Wand*";
         (592): return "Unknown Item*";
         (593): return "Unknown Item*";
         (594): return "Efreeti Bottle*";
         (595): return "Unknown Item*";
         (596): return "Potion of Giant Strength*";
         (597): return "Holy Water Vial*";
         (598): return "Flask of Oil*";
         (599): return "Boulder*";
         (600): return "Unknown Thrown*";
         (601): return "Unknown Melee*";
         (602): return "Ring of Feather Falling*";
         (603): return "Pass*";
         (604): return "Cloak of Displacement*";
         (605): return "Ring of Protection*";
         (606): return "Drow Mace*";
         (607): return "Elfin Chain Mail*";
         (608): return "Drow Chain Mail*";
         (609): return "Drow Long Sword*";
         (610): return "Spine*";
         (611): return "Ring of Wizardry*";
         (612): return "Dart of Hornet's Nest*";
         (613): return "Staff Sling*";
         (614): return "Unused";
         (615): return "Unused";
         (616): return "Unused";
         (617): return "Unused";
         (618): return "Unused";
         (619): return "Unused";
         (620): return "Unused";
         (621): return "Unused";
         (622): return "Unused";
         (623): return "Unused";
         (624): return "Unused";
         (625): return "Unused";
         (626): return "Unused";
         (627): return "Unused";
         (628): return "Unused";
         (629): return "Unused";
         (630): return "Unused";
         (631): return "Unused";
         (632): return "Unused";
         (633): return "Unused";
         (634): return "Unused";
         (635): return "Unused";
         (636): return "Unused";
         (637): return "Unused";
         (638): return "Unused";
         (639): return "Invalid*";
     // 06 - Death Knights of Krynn
         (640): return "Invalid*";
         (641): return "Battle Axe";
         (642): return "Hand Axe*";
         (643): return "Club*";
         (644): return "Dagger";
         (645): return "Dart";
         (646): return "Hammer*";
         (647): return "Javelin*";
         (648): return "Mace";
         (649): return "Morning Star*";
         (650): return "Military Pick*";
         (651): return "Awl Pike*";
         (652): return "Bolt*";
         (653): return "Scimitar";
         (654): return "Spear*";
         (655): return "Quarter Staff";
         (656): return "Bastard Sword*";
         (657): return "Broad Sword*";
         (658): return "Long Sword";
         (659): return "Short Sword";
         (660): return "Two-Handed Sword";
         (661): return "Trident*";
         (662): return "Composite Long Bow";
         (663): return "Composite Short Bow*";
         (664): return "Long Bow";
         (665): return "Short Bow";
         (666): return "Fine Long Bow*";
         (667): return "Light Crossbow*";
         (668): return "Sling";
         (669): return "Staff Sling";
         (670): return "Arrow";
         (671): return "Leather Armor";
         (672): return "Ring Mail*";
         (673): return "Scale Mail*";
         (674): return "Chain Mail";
         (675): return "Banded Mail";
         (676): return "Plate Mail";
         (677): return "Shield";
         (678): return "Scroll of Protection";
         (679): return "Magic-User Scroll";
         (680): return "Cleric Scroll";
         (681): return "Helm*";
         (682): return "Belt*";
         (683): return "Robe*";
         (684): return "Cloak*";
         (685): return "Boots";
         (686): return "Ring*";
         (687): return "Potions/Misc";
         (688): return "Mirror*";
         (689): return "Misc*";
         (690): return "Bracers";
         (691): return "Wand";
         (692): return "Wand";
         (693): return "Potion of Giant Strength*";
         (694): return "Holy Water Vial*";
         (695): return "Flask of Oil*";
         (696): return "Boulder*";
         (697): return "Unknown Thrown";
         (698): return "Cloak of Displacement";
         (699): return "Ring of Protection";
         (700): return "Mace of Disruption*";
         (701): return "Elfin Chain*";
         (702): return "Drow Chain Mail*";
         (703): return "Drow Long Sword*";
         (704): return "Spine*";
         (705): return "Ring of Wizardry*";
         (706): return "Dart of Hornet's Nest";
         (707): return "Hoopak";
         (708): return "Solamnic Plate";
         (709): return "Footman's Dragonlance";
         (710): return "Flail";
         (711): return "Halberd*";
         (712): return "Gauntlets";
         (713): return "Unused";
         (714): return "Leather Holy Symbol*";
         (715): return "Brass Key*";
         (716): return "Belt*";
         (717): return "Bracers*";
         (718): return "Wand*";
         (719): return "Wand*";
         (720): return "Unknown Item*";
         (721): return "Unknown Item*";
         (722): return "Efreeti Bottle*";
         (723): return "Unknown Item";
         (724): return "Potion of Giant Strength*";
         (725): return "Holy Water Vial*";
         (726): return "Flask of Oil*";
         (727): return "Boulder*";
         (728): return "Unknown Thrown*";
         (729): return "Unknown Melee*";
         (730): return "Ring of Feather Falling*";
         (731): return "Pass*";
         (732): return "Cloak of Displacement*";
         (733): return "Ring of Protection*";
         (734): return "Drow Mace*";
         (735): return "Elfin Chain Mail*";
         (736): return "Drow Chain Mail*";
         (737): return "Drow Long Sword*";
         (738): return "Spine*";
         (739): return "Ring of Wizardry*";
         (740): return "Dart of Hornet's Nest*";
         (741): return "Staff Sling*";
         (742): return "Unused";
         (743): return "Unused";
         (744): return "Unused";
         (745): return "Unused";
         (746): return "Unused";
         (747): return "Unused";
         (748): return "Unused";
         (749): return "Unused";
         (750): return "Unused";
         (751): return "Unused";
         (752): return "Unused";
         (753): return "Unused";
         (754): return "Unused";
         (755): return "Unused";
         (756): return "Unused";
         (757): return "Unused";
         (758): return "Unused";
         (759): return "Unused";
         (760): return "Unused";
         (761): return "Unused";
         (762): return "Unused";
         (763): return "Unused";
         (764): return "Unused";
         (765): return "Unused";
         (766): return "Unused";
         (767): return "Invalid*";
     // 07 - The Dark Queen of Krynn
         (768): return "Unused";
         (769): return "Battle Axe";
         (770): return "Hand Axe";
         (771): return "Club";
         (772): return "Dagger";
         (773): return "Dart";
         (774): return "Hammer";
         (775): return "Javelin";
         (776): return "Mace";
         (777): return "Morning Star";
         (778): return "Military Pick";
         (779): return "Awl Pike";
         (780): return "Bolt";
         (781): return "Scimitar";
         (782): return "Spear";
         (783): return "Quarter Staff";
         (784): return "Bastard Sword";
         (785): return "Broad Sword";
         (786): return "Long Sword";
         (787): return "Short Sword";
         (788): return "Two-Handed Sword";
         (789): return "Trident";
         (790): return "Composite Long Bow";
         (791): return "Composite Short Bow";
         (792): return "Long Bow";
         (793): return "Short Bow";
         (794): return "Fine Long Bow";
         (795): return "Light Crossbow";
         (796): return "Sling";
         (797): return "Staff Sling";
         (798): return "Arrow";
         (799): return "Leather Armor";
         (800): return "Ring Mail";
         (801): return "Scale Mail";
         (802): return "Chain Mail";
         (803): return "Banded Mail";
         (804): return "Plate Mail";
         (805): return "Shield";
         (806): return "Scroll of Protection";
         (807): return "Magic-User Scroll";
         (808): return "Cleric Scroll";
         (809): return "Helm";
         (810): return "Belt";
         (811): return "Robe";
         (812): return "Cloak";
         (813): return "Boots";
         (814): return "Ring";
         (815): return "Potions/Misc";
         (816): return "Mirror";
         (817): return "Misc*";
         (818): return "Bracers";
         (819): return "Wand";
         (820): return "Wand*";
         (821): return "Potion of Giant Strength";
         (822): return "Unknown Item*";
         (823): return "Holy Water Vial*";
         (824): return "Flask of Oil*";
         (825): return "Boulder*";
         (826): return "Cloak of Displacement";
         (827): return "Ring of Protection";
         (828): return "Mace of Disruption*";
         (829): return "Elfin Chain";
         (830): return "Drow Chain Mail*";
         (831): return "Drow Long Sword*";
         (832): return "Spine*";
         (833): return "Ring of Wizardry";
         (834): return "Dart of Hornet's Nest";
         (835): return "Hoopak";
         (836): return "Solamnic Plate";
         (837): return "Footman's Dragonlance";
         (838): return "Flail";
         (839): return "Halberd**";
         (840): return "Gauntlets";
         (841): return "Bundle of Scrolls*";
         (842): return "Blessed Bolt*";
         (843): return "Cloak of Protection";
         (844): return "Brass Key*";
         (845): return "Belt*";
         (846): return "Bracers*";
         (847): return "Wand*";
         (848): return "Wand*";
         (849): return "Unknown Item*";
         (850): return "Unknown Item*";
         (851): return "Efreeti Bottle*";
         (852): return "Unknown Item*";
         (853): return "Potion of Giant Strength*";
         (854): return "Holy Water Vial*";
         (855): return "Flask of Oil*";
         (856): return "Boulder*";
         (857): return "Unknown Thrown*";
         (858): return "Unknown Melee*";
         (859): return "Ring of Feather Falling*";
         (860): return "Pass*";
         (861): return "Cloak of Displacement*";
         (862): return "Ring of Protection*";
         (863): return "Drow Mace*";
         (864): return "Elfin Chain Mail*";
         (865): return "Drow Chain Mail*";
         (866): return "Drow Long Sword*";
         (867): return "Spine*";
         (868): return "Ring of Wizardry*";
         (869): return "Dart of Hornet's Nest*";
         (870): return "Staff Sling*";
         (871): return "Staff of Striking";
         (872): return "Foethumper**";
         (873): return "Vorpal Long Sword";
         (874): return "Unused";
         (875): return "Unused";
         (876): return "Unused";
         (877): return "Unused";
         (878): return "Unused";
         (879): return "Unused";
         (880): return "Unused";
         (881): return "Unused";
         (882): return "Unused";
         (883): return "Unused";
         (884): return "Unused";
         (885): return "Unused";
         (886): return "Unused";
         (887): return "Unused";
         (888): return "Unused";
         (889): return "Unused";
         (890): return "Unused";
         (891): return "Unused";
         (892): return "Unused";
         (893): return "Unused";
         (894): return "Unused";
         (895): return "Unused";
     // 08 - Gateway to the Savage Frontier
         (896): return "Invalid*";
         (897): return "Battle Axe";
         (898): return "Hand Axe";
         (899): return "Bardiche";
         (900): return "Bec de Corbin";
         (901): return "Bill-Guisarme";
         (902): return "Bo Stick";
         (903): return "Club";
         (904): return "Dagger";
         (905): return "Dart";
         (906): return "Fauchard";
         (907): return "Fauchard-Fork";
         (908): return "Flail";
         (909): return "Military Fork";
         (910): return "Glaive";
         (911): return "Glaive-Guisarme";
         (912): return "Guisarme";
         (913): return "Guisarme-Voulge";
         (914): return "Halberd";
         (915): return "Lucern Hammer";
         (916): return "Hammer";
         (917): return "Javelin";
         (918): return "Jo Stick";
         (919): return "Mace";
         (920): return "Morning Star";
         (921): return "Partisan";
         (922): return "Military Pick";
         (923): return "Awl Pike";
         (924): return "Bolt";
         (925): return "Ranseur";
         (926): return "Scimitar";
         (927): return "Spear";
         (928): return "Spetum";
         (929): return "Quarter Staff";
         (930): return "Bastard Sword";
         (931): return "Broad Sword";
         (932): return "Long Sword";
         (933): return "Short Sword";
         (934): return "Two-Handed Sword";
         (935): return "Trident";
         (936): return "Voulge";
         (937): return "Composite Long Bow";
         (938): return "Composite Short Bow";
         (939): return "Long Bow";
         (940): return "Short Bow";
         (941): return "Fine Composite Long Bow*";
         (942): return "Light Crossbow";
         (943): return "Sling";
         (944): return "Unused";
         (945): return "Unused";
         (946): return "Leather Armor";
         (947): return "Padded Armor";
         (948): return "Studded Leather Armor";
         (949): return "Ring Mail";
         (950): return "Scale Mail";
         (951): return "Chain Mail";
         (952): return "Splint Mail";
         (953): return "Banded Mail";
         (954): return "Plate Mail";
         (955): return "Shield";
         (956): return "Scroll of Protection*";
         (957): return "Magic-User Scroll";
         (958): return "Cleric Scroll";
         (959): return "Gauntlets";
         (960): return "Helm";
         (961): return "Belt*";
         (962): return "Robe*";
         (963): return "Cloak";
         (964): return "Boots*";
         (965): return "Ring";
         (966): return "Potions/Misc";
         (967): return "Potions/Misc*";
         (968): return "Misc*";
         (969): return "Arrow";
         (970): return "Leather Holy Symbol*";
         (971): return "Brass Key*";
         (972): return "Cursed Necklace*";
         (973): return "Bracers";
         (974): return "Wand*";
         (975): return "Wand";
         (976): return "Unknown Item*";
         (977): return "Unknown Item*";
         (978): return "Efreeti Bottle*";
         (979): return "Unknown Item*";
         (980): return "Potion of Giant Strength*";
         (981): return "Holy Water Vial";
         (982): return "Flask of Oil";
         (983): return "Boulder";
         (984): return "Unknown Thrown*";
         (985): return "Huge Boulder";
         (986): return "Ring of Feather Falling*";
         (987): return "Pass*";
         (988): return "Cloak of Displacement";
         (989): return "Ring of Protection";
         (990): return "Drow Mace*";
         (991): return "Elfin Chain Mail*";
         (992): return "Drow Chain Mail*";
         (993): return "Drow Long Sword*";
         (994): return "Spine";
         (995): return "Ring of Wizardry*";
         (996): return "Dart of Hornet's Nest";
         (997): return "Staff Sling";
         (998): return "Unused";
         (999): return "Unused";
        (1000): return "Unused";
        (1001): return "Unused";
        (1002): return "Unused";
        (1003): return "Unused";
        (1004): return "Unused";
        (1005): return "Unused";
        (1006): return "Unused";
        (1007): return "Unused";
        (1008): return "Unused";
        (1009): return "Unused";
        (1010): return "Unused";
        (1011): return "Unused";
        (1012): return "Unused";
        (1013): return "Unused";
        (1014): return "Unused";
        (1015): return "Unused";
        (1016): return "Unused";
        (1017): return "Unused";
        (1018): return "Unused";
        (1019): return "Unused";
        (1020): return "Unused";
        (1021): return "Unused";
        (1022): return "Unused";
        (1023): return "Invalid*";
    // 09 - Treasures of the Savage Frontier
        (1024): return "Unused";
        (1025): return "Battle Axe";
        (1026): return "Hand Axe";
        (1027): return "Club";
        (1028): return "Dagger";
        (1029): return "Dart";
        (1030): return "Hammer";
        (1031): return "Javelin";
        (1032): return "Mace";
        (1033): return "Morning Star";
        (1034): return "Military Pick";
        (1035): return "Awl Pike";
        (1036): return "Bolt";
        (1037): return "Scimitar";
        (1038): return "Spear";
        (1039): return "Quarter Staff";
        (1040): return "Bastard Sword";
        (1041): return "Broad Sword";
        (1042): return "Long Sword";
        (1043): return "Short Sword";
        (1044): return "Two-Handed Sword";
        (1045): return "Trident";
        (1046): return "Composite Long Bow";
        (1047): return "Composite Short Bow";
        (1048): return "Long Bow";
        (1049): return "Short Bow";
        (1050): return "Fine Long Bow";
        (1051): return "Light Crossbow";
        (1052): return "Sling";
        (1053): return "Staff Sling";
        (1054): return "Arrow";
        (1055): return "Leather Armor";
        (1056): return "Ring Mail";
        (1057): return "Scale Mail";
        (1058): return "Chain Mail";
        (1059): return "Banded Mail";
        (1060): return "Plate Mail";
        (1061): return "Shield";
        (1062): return "Scroll of Protection";
        (1063): return "Magic-User Scroll";
        (1064): return "Cleric Scroll";
        (1065): return "Helm";
        (1066): return "Belt";
        (1067): return "Robe";
        (1068): return "Cloak";
        (1069): return "Boots";
        (1070): return "Ring";
        (1071): return "Potions/Misc";
        (1072): return "Mirror";
        (1073): return "Misc*";
        (1074): return "Bracers";
        (1075): return "Wand";
        (1076): return "Wand";
        (1077): return "Potion of Giant Strength";
        (1078): return "Unknown Item*";
        (1079): return "Holy Water Vial*";
        (1080): return "Flask of Oil*";
        (1081): return "Boulder*";
        (1082): return "Cloak of Displacement";
        (1083): return "Ring of Protection";
        (1084): return "Mace of Disruption*";
        (1085): return "Elfin Chain";
        (1086): return "Drow Chain Mail";
        (1087): return "Drow Long Sword";
        (1088): return "Spine*";
        (1089): return "Ring of Wizardry";
        (1090): return "Dart of Hornet's Nest";
        (1091): return "Hoopak*";
        (1092): return "Solamnic Plate*";
        (1093): return "Footman's Dragonlance*";
        (1094): return "Flail";
        (1095): return "Halberd";
        (1096): return "Gauntlets**";
        (1097): return "Vorpal Long Sword";
        (1098): return "Blessed Bolt";
        (1099): return "Cloak of Protection";
        (1100): return "Brass Key*";
        (1101): return "Belt of Protection";
        (1102): return "Bracers*";
        (1103): return "Wand*";
        (1104): return "Wand*";
        (1105): return "Unknown Item*";
        (1106): return "Unknown Item*";
        (1107): return "Efreeti Bottle*";
        (1108): return "Unknown Item*";
        (1109): return "Potion of Giant Strength*";
        (1110): return "Holy Water Vial*";
        (1111): return "Flask of Oil";
        (1112): return "Boulder*";
        (1113): return "Unknown Thrown*";
        (1114): return "Unknown Melee*";
        (1115): return "Ring of Feather Falling*";
        (1116): return "Staff of Striking";
        (1117): return "Cloak of Displacement*";
        (1118): return "Ring of Protection*";
        (1119): return "Drow Mace*";
        (1120): return "Elfin Chain Mail*";
        (1121): return "Drow Chain Mail*";
        (1122): return "Drow Long Sword*";
        (1123): return "Spine*";
        (1124): return "Ring of Wizardry*";
        (1125): return "Dart of Hornet's Nest*";
        (1126): return "Staff Sling*";
        (1127): return "Unused";
        (1128): return "Unused";
        (1129): return "Unused";
        (1130): return "Unused";
        (1131): return "Unused";
        (1132): return "Unused";
        (1133): return "Unused";
        (1134): return "Unused";
        (1135): return "Unused";
        (1136): return "Unused";
        (1137): return "Unused";
        (1138): return "Unused";
        (1139): return "Unused";
        (1140): return "Unused";
        (1141): return "Unused";
        (1142): return "Unused";
        (1143): return "Unused";
        (1144): return "Unused";
        (1145): return "Unused";
        (1146): return "Unused";
        (1147): return "Unused";
        (1148): return "Unused";
        (1149): return "Unused";
        (1150): return "Unused";
        (1151): return "Unused";
    // 10 - Unlimited Adventures
        (1152): return "Unused";
        (1153): return "Battle Axe";
        (1154): return "Hand Axe";
        (1155): return "Club";
        (1156): return "Dagger";
        (1157): return "Dart";
        (1158): return "Hammer";
        (1159): return "Javelin";
        (1160): return "Mace";
        (1161): return "Morning Star";
        (1162): return "Military Pick";
        (1163): return "Awl Pike";
        (1164): return "Bolt";
        (1165): return "Scimitar";
        (1166): return "Spear";
        (1167): return "Quarter Staff";
        (1168): return "Bastard Sword";
        (1169): return "Broad Sword";
        (1170): return "Long Sword";
        (1171): return "Short Sword";
        (1172): return "Two-Handed Sword";
        (1173): return "Trident";
        (1174): return "Composite Long Bow";
        (1175): return "Composite Short Bow";
        (1176): return "Long Bow";
        (1177): return "Short Bow";
        (1178): return "Fine Long Bow";
        (1179): return "Light Crossbow";
        (1180): return "Sling";
        (1181): return "Staff Sling";
        (1182): return "Arrow";
        (1183): return "Leather Armor";
        (1184): return "Ring Mail";
        (1185): return "Scale Mail";
        (1186): return "Chain Mail";
        (1187): return "Banded Mail";
        (1188): return "Plate Mail";
        (1189): return "Shield";
        (1190): return "Scroll of Protection";
        (1191): return "Magic-User Scroll";
        (1192): return "Cleric Scroll";
        (1193): return "Helm";
        (1194): return "Belt";
        (1195): return "Robe";
        (1196): return "Cloak";
        (1197): return "Boots";
        (1198): return "Ring";
        (1199): return "Potions/Misc";
        (1200): return "Mirror";
        (1201): return "Misc*";
        (1202): return "Bracers";
        (1203): return "Wand";
        (1204): return "Wand*";
        (1205): return "Potion of Giant Strength";
        (1206): return "Unknown Item*";
        (1207): return "Holy Water Vial*";
        (1208): return "Flask of Oil*";
        (1209): return "Boulder*";
        (1210): return "Cloak of Displacement";
        (1211): return "Ring of Protection";
        (1212): return "Mace of Disruption*";
        (1213): return "Elfin Chain";
        (1214): return "Drow Chain Mail";
        (1215): return "Drow Long Sword";
        (1216): return "Spine*";
        (1217): return "Ring of Wizardry";
        (1218): return "Dart of Hornet's Nest";
        (1219): return "Hoopak*";
        (1220): return "Solamnic Plate*";
        (1221): return "Footman's Dragonlance*";
        (1222): return "Flail";
        (1223): return "Halberd";
        (1224): return "Gauntlets";
        (1225): return "Bundle of Scrolls*";
        (1226): return "Blessed Bolt";
        (1227): return "Cloak of Protection";
        (1228): return "Brass Key*";
        (1229): return "Belt*";
        (1230): return "Bracers*";
        (1231): return "Wand*";
        (1232): return "Wand*";
        (1233): return "Unknown Item*";
        (1234): return "Unknown Item*";
        (1235): return "Efreeti Bottle*";
        (1236): return "Unknown Item*";
        (1237): return "Potion of Giant Strength*";
        (1238): return "Holy Water Vial*";
        (1239): return "Flask of Oil*";
        (1240): return "Boulder*";
        (1241): return "Unknown Thrown*";
        (1242): return "Unknown Melee*";
        (1243): return "Ring of Feather Falling*";
        (1244): return "Pass*";
        (1245): return "Cloak of Displacement*";
        (1246): return "Ring of Protection*";
        (1247): return "Drow Mace*";
        (1248): return "Elfin Chain Mail*";
        (1249): return "Drow Chain Mail*";
        (1250): return "Drow Long Sword*";
        (1251): return "Spine*";
        (1252): return "Ring of Wizardry*";
        (1253): return "Dart of Hornet's Nest*";
        (1254): return "Staff Sling*";
        (1255): return "Unused";
        (1256): return "Unused";
        (1257): return "Vorpal Long Sword";
        (1258): return "Unused";
        (1259): return "Unused";
        (1260): return "Unused";
        (1261): return "Unused";
        (1262): return "Unused";
        (1263): return "Unused";
        (1264): return "Unused";
        (1265): return "Unused";
        (1266): return "Unused";
        (1267): return "Unused";
        (1268): return "Unused";
        (1269): return "Unused";
        (1270): return "Unused";
        (1271): return "Unused";
        (1272): return "Unused";
        (1273): return "Unused";
        (1274): return "Unused";
        (1275): return "Unused";
        (1276): return "Unused";
        (1277): return "Unused";
        (1278): return "Unused";
        (1279): return "Unused";
    // Error
        (_):    return "Unknown";
    }
};

/*******************************
    Structs
*******************************/
// Base Item struct
struct ITEMBASE {
    ITEMTYPE ItemType [[comment("Base item type (i.e. weapon/shield/armor/etc)\nReferred to as \"slot\" by GBC")]];
  // Helper variable for AC formulas
    bool IsArmor = (ItemType == 0x02 || BracerID == std::core::array_index()) ? true : false;
    u8 Hands [[comment("Number of hands required to equip")]];
    u8 DvL_Dice_Count [[comment("Number of dice to roll when attacking \"large\" enemies")]];
    u8 DvL_Dice_Type [[comment("Type of dice rolled when attacking \"large\" enemies (i.e. d4, d6, etc)")]];
    s8 DvL_Bonus [[comment("Base bonus damage to add to the rolled result when attacking \"large\" enemies\nStacks with item bonuses")]];
    u8 RateOfFire [[comment("Number of missiles that can be launched/thrown in a round multiplied by 2")]];
    u8 AC [[format_read(std::format("{}", IsArmor ? "ACArmorRead" : "ACOtherRead")),format_write(std::format("{}", IsArmor ? "ACArmorWrite" : "ACOtherWrite")),comment("Armor Class\nEnter 255 to set AC to \"-\" (None) for non-armor/defensive items")]];
    match (GameID) {
        (4|9|10): ITEMDAMAGETYPE_B DamageType [[comment("Type of damage caused by the weapon\nUsed to determine if target is resistant to the attack")]];
        (_):      ITEMDAMAGETYPE_A DamageType [[comment("Type of damage caused by the weapon\nUsed to determine if target is resistant to the attack")]];
    }
    u8 Unknown_08 [[comment("Unknown usage")]]; // Noted as a being an IsMelee type flag in 10 but its usage doesn't align and appears to me to be a leftover value from 1
    u8 DvS_Dice_Count [[comment("Number of dice to roll when attacking \"small\" enemies")]];
    u8 DvS_Dice_Type [[comment("Type of dice rolled when attacking \"small\" enemies (i.e. d4, d6, etc)")]];
    s8 DvS_Bonus [[comment("Base bonus damage to add to the rolled result when attacking \"small\" enemies\nStacks with item bonuses")]];
    u8 Range [[comment("Max distance from players for ranged attacks plus 1")]];
    CLASSRESTRICTION ItemRestriction [[comment("Bit array indicating which classes can equip/use the item")]];
    WEAPONFLAGARRAY WeaponFlag [[comment("Bit array containing weapon specific settings\nPrimarily for ranged weapons")]];    // WeaponFlagArray
    u8 Unknown_0F [[comment(std::format("{}", GameID == 8 ? "Unknown usage" : "Always 00"))]];
// Gateway (8) has two additional u32 values at the end of each record - usage unknown
    if (GameID == 8) {
        u32 Unknown_10 [[comment("Unknown usage")]];
        u32 Unknown_14 [[comment("Unknown usage")]];
    }
} [[name(std::format("{:03d}: {}", std::core::array_index(), GetDisplayName(std::core::array_index() + ((GameID -1) * 128))))]];

// Base Items
ITEMBASE ItemList[128] @ Offset;