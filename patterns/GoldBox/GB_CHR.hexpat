#pragma author Draxinusom
#pragma description Gold Box Games - Character
#include <GoldBox/GB_ENUM.cs>
#include <GoldBox/GB_STRUCT.cs>
#include <GoldBox/GB_STRUCT_ITM.cs>
#include <GoldBox/GB_UTIL.cs>
#include <GoldBox/GB_UTIL_ITM.cs>
import std.core;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the character/monster
 record files for all Gold Box games (D&D, no one cares about Buck Rogers)

 Supported Games:
 01 - Pool of Radiance (CHRDAT[A-J]#.SAV / <NAME>.CHA / MON[1-8]CHA.DAX)
 02 - Curse of the Azure Bonds (CHRDAT[A-J]#.SAV / <NAME>.GUY / MON[1-6]CHA.DAX)
 03 - Secret of the Silver Blades (CHRDAT[A-J]#.SAV / <NAME>.WHO / MON1CHA.DAX)
 04 - Pools of Darkness (CHRDAT[A-J]#.SAV / <NAME>.PC / MON1CHA.DAX)
 05 - Champions of Krynn (CHRDAT[A-J]#.SAV / <NAME>.WHO / MON[1-3]CHA.DAX)
 06 - Death Knights of Krynn (CHRDAT[A-J]#.GAM / <NAME>.PC / MON1CHA.DAX)
 07 - The Dark Queen of Krynn (SAVGAM[A-J].QSV / <NAME>.QCH / DISK1\MONCHA.GLB)
 08 - Gateway to the Savage Frontier (CHRDAT[A-J]#.SAV / <NAME>.GUY / MON[2-6]CHA.DAX)
 09 - Treasures of the Savage Frontier (CHRDAT[A-J]#.SAV / <NAME>.PC / MON1CHA.DAX)
 10 - Unlimited Adventures (SAVGAM[A-J].CSV / <NAME>.CCH / DISK1\MONST.GLB / MONST###.DAT)

 Monster files (i.e. MON1CHA.DAX) must be decompressed first in order to view the records
 This means that in order to edit those you must recompress/recreate the DAX file afterwards

 Note:
 An attempt is made to identify/validate the source game; however, some games have identical
 file sizes and the 7/10 files are variable length with multiple possible overlaps so make
 sure the GameID is set correctly below if it returns an error or the data looks wrong

 The GameID variable below must be set for to the number in the list above for the source game
*********/
u8 GameID = 0;

u32 FileSize = std::mem::size();
u8 CHARCount = 1;
u32 Offset = 0x00;

// Attempt to auto identify file
if (GameID == 0) {
// 01
    if (FileSize == 285) {
        GameID = 1;
        std::print("Pool of Radiance file detected. GameID set to 1.");
    }
    else if (FileSize == 439) {
        GameID = 3;
        std::print("Secret of the Silver Blades file detected. GameID set to 3.");
    }
    else if (FileSize == 409) {
        GameID = 5;
        std::print("Champions of Krynn file detected. GameID set to 5.");
    }
    else if (FileSize == 216) {
        GameID = 6;
        std::print("Death Knights of Krynn file detected. GameID set to 6.");
    }
    else if (FileSize == 7965) {
        GameID = 7;
        std::print("The Dark Queen of Krynn file detected. GameID set to 7.");
    }
    else if (FileSize == 10285) {
        GameID = 10;
        std::print("Unlimited Adventures file detected. GameID set to 10.");
    }
//  2/8 & 4/9 have same file sizes and 7/10 are variable length so cannot be auto set - Note: 10 MON files are fixed at 450 but can conflict with 7 CHR records (414 + 4xSFX + 0xITM)
    else if (FileSize == 422 || (FileSize >= 398 && FileSize <= 886)) {
        std::warning("Please set the GameID variable to the source game's number.");
        return;
    }
    else {
        std::warning("File is not a Gold Box character record file. Aborting.");
        return;
    }

}

// Ensure GameID is in range
if (GameID > 10) {
    std::warning("Invalid GameID. Aborting.");
    return;
}

/***********************
    7/10 variables
***********************/
// 7/10 - Item variables
u8 RecordSize = GameID == 7 ? 17 : 18;
u8 ItemCount = 16; // Hardcoding ItemCount to keep numbering same across characters (and it's easier :P)
bool HasBundle = true;

// 7/10 - FileType
bool IsSAV = false;
bool IsMON = false;

// Validate file
if ((GameID == 1 && FileSize != 285) || ((GameID == 2 || GameID == 8) && FileSize != 422) || (GameID == 3 && FileSize != 439) || ((GameID == 4 || GameID == 9) && FileSize != 510) || (GameID == 5 && FileSize != 409) || (GameID == 6 && FileSize != 216)) {
    std::warning("Invalid file for specified game. Aborting.");
    return;
}
else if (GameID == 7) {
// Abort if out of range (not going to bother with full validation as it's a combo of sizes with 414 + 20x9 SFX records + 16x17 ITM records)
    if (FileSize != 7965 && !(FileSize >= 414 && FileSize <= 866)) {
        std::warning("Invalid file for specified game. Aborting.");
        return;
    }
// Probe file to determine if save or standalone character/monster record
    u8 MoraleCheck @ 0x009B;    // This value is always 0 on player records and populated on all monster records (NPC party members have a value but those are in saves and file size check takes care of that)
    IsSAV = std::mem::size() == 7965 ? true : false;
    IsMON = (!IsSAV && MoraleCheck > 0) ? true : false;
}
else if (GameID == 10) {
// Abort if out of range (not going to bother with full validation as it's a combo of sizes with 398 + 20x10 SFX records + 16x18 ITM records)
    if (FileSize != 10285 && !(FileSize >= 398 && FileSize <= 886)) {
        std::warning("Invalid file for specified game. Aborting.");
        return;
    }
    IsSAV = std::mem::size() == 10285 ? true : false;
    IsMON = FileSize == 450 ? true : false; // No possible combo of SFX/ITM records equals 450 for standalone player character records (CCH)
}

// Set number of characters in file and offset for saves
if (IsSAV) {
    u8 SaveCharCount @ 0x040D;
    CHARCount = SaveCharCount;
    Offset = 0x040F;
}

/*******************************
    Structs
    Additional included from:
    GoldBox/GB_STRUCT.cs
    GoldBox/GB_STRUCT_ITM.cs
*******************************/
// 10 - Monster Item record - CHAR_MON.Item (CHR specific so not part of Item patterns)
struct ITM_MON10 {
    u8 ItemID [[comment("Item ID in ITEM.DAT (0 = No item)")]];
    u8 Quantity @ $ + 15 [[comment("How many of that item the monster is carrying")]];
} [[name(std::format("{:02d}: Item", std::core::array_index()))]];

/***********************
    SFX 7/10 only
***********************/
// 7 - Base Effect record - SFX_CHR/CHAR_MON.SFX_Effect - temp - move to common struct once SFX pattern complete
struct SFX_BASE {
    u8 EffectID [[comment("ID of the effect")]];
    u16 TimeRemaining [[comment("Number of rounds remaining on the effect (0 for permanent)")]];
    u8 Modifier [[comment("Variable usage, depending on effect")]];
    u8 IsItemEffect [[comment("Indicates if effect is due to an equipped item")]];;
} [[name(std::format("{:02d}: SFX_Effect", std::core::array_index()))]];

// 7 - Character Effect record - CHAR_CHR.SFX_Effect - has pointer to the next effect record - always 0 on last record - temp
struct SFX_CHR07 : SFX_BASE{
    u32 ADDR_NextEffect [[comment("Pointer to next effect record")]];
};

// 10 - Monster Effect record
struct SFX_MON10 {
    u8 EffectID [[name(std::format("{:02d}: EffectID", std::core::array_index()))]];
} [[inline]];

// 10 - Character Effect record - CHAR_CHR.SFX_Effect - 10 - temp - move to common struct once SFX pattern complete
struct SFX_CHR10 {
    u8 EffectID [[comment("ID of the effect")]];
    u8 Unknown_01 [[comment("Unknown")]];
    u16 TimeRemaining [[comment("Number of rounds remaining on the effect (0 for permanent)")]];
    u8 Modifier [[comment("Variable usage, depending on effect")]];
    bool IsItemEffect [[comment("Indicates if effect is due to an equipped item")]];
    u32 ADDR_NextEffect [[comment("Pointer to next effect record")]];
} [[name(std::format("{:02d}: SFX_Effect", std::core::array_index()))]];

/***********************
    Character flags
***********************/
// 1 - Character flags - N/A

// 2 - Character flags
bitfield FLAGARRAY02 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
};

// 3 - Character flags
bitfield FLAGARRAY03 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar type)")]];
    Type_Mammal : 1 [[comment("Mammal type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Giant : 1 [[comment("Giant type")]];
    Unknown_09 : 1 [[comment("Unknown Flag")]];
    Unknown_10 : 1 [[comment("Unknown Flag")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
};

// 4 - Character flags
bitfield FLAGARRAY04 {
    Vulnerable_Dispel : 1 [[ncomment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Unknown_01 : 1 [[comment("Unknown Flag")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Giant : 1 [[comment("Giant type")]];
    Vulnerable_CharmHold : 1 [[comment("Vulnerable to Charm/Hold")]];
    Type_Reptile : 1 [[comment("Reptile type")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
    Immune_Poison : 1 [[comment("Immune to Poison")]];
    Immune_Decapitation : 1 [[comment("Immune to Decapitation\n(Vorpal Sword)")]];
    Immune_Confusion : 1 [[comment("Immune to Confusion")]];
};

// 5 - Character flags
bitfield FLAGARRAY05 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Type_Undead : 1 [[comment("Undead type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Type_Reptile : 1 [[comment("Reptile type")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Dragon : 1 [[comment("Dragon type")]];
    Bonus_ToHit_Gnome : 1 [[comment("Gnomes Have +1 Bonus To Hit")]];
};

// 6 - Character flags
bitfield FLAGARRAY06 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Unknown_01 : 1 [[comment("Unknown Flag")]];
    Unknown_02 : 1 [[comment("Unknown Flag")]];
    Unknown_03 : 1 [[comment("Unknown Flag")]];
    Unknown_04 : 1 [[comment("Unknown Flag")]];
    Type_Reptile : 1 [[comment("Reptile type")]];
    Unknown_06 : 1 [[comment("Unknown Flag")]];
    Unknown_07 : 1 [[comment("Unknown Flag")]];
    Type_Dragon : 1 [[comment("Dragon type")]];
    Unknown_09 : 1 [[comment("Unknown Flag")]];
    Unknown_10 : 1 [[comment("Unknown Flag")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
};

// 7 - Character flags
bitfield FLAGARRAY07 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Type_Mammal : 1 [[comment("Mammal type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Type_Undead : 1 [[comment("Undead type")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Giant : 1 [[comment("Giant type")]];
    Vulnerable_CharmHold : 1 [[comment("Vulnerable to Charm/Hold")]];
    Type_Reptile : 1 [[comment("Reptile type")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
    Immune_Poison : 1 [[comment("Immune to Poison")]];
    Immune_Decapitation : 1 [[comment("Immune to Decapitation")]];
    Immune_Confusion : 1 [[comment("Immune to Confusion")]];
    Type_Dragon : 1 [[comment("Dragon type")]];
};

// 8 - Character flags
bitfield FLAGARRAY08 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Type_Mammal : 1 [[comment("Mammal type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
};

// 9 - Character flags
bitfield FLAGARRAY09 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Type_Mammal : 1 [[comment("Mammal type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Giant : 1 [[comment("Giant type")]];
    Vulnerable_CharmHold : 1 [[comment("Vulnerable to Charm/Hold")]];
    Unknown_10 : 1 [[comment("Unknown Flag")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
    Immune_Poison : 1 [[comment("Immune to Poison")]];
    Immune_Decapitation : 1 [[comment("Immune to Decapitation")]];
    Immune_Confusion : 1 [[comment("Immune to Confusion")]];
};

// 10 - Character flags
bitfield FLAGARRAY10 {
    Vulnerable_Dispel : 1 [[comment("Vulnerable to Dispel Evil (Extraplanar)")]];
    Type_Mammal : 1 [[comment("Mammal type")]];
    Penalty_ToHit_Dwarf : 1 [[comment("-4 Penalty To Hit vs Dwarves")]];
    Bonus_Damage_Ranger : 1 [[comment("Takes +1 Additional Damage Per Level from Rangers)")]];
    Type_Snake : 1 [[comment("Snake type")]];
    Penalty_ToHit_Gnome : 1 [[comment("-4 Penalty To Hit vs Gnomes")]];
    Type_Animal : 1 [[comment("Animal type")]];
    Bonus_ToHit_Dwarf : 1 [[comment("Dwarves Have +1 Bonus To Hit")]];
    Type_Giant : 1 [[comment("Giant type")]];
    Vulnerable_CharmHold : 1 [[comment("Vulnerable to Charm/Hold")]];
    Bonus_ToHit_Gnome : 1 [[comment("Gnomes Have +1 Bonus To Hit")]];
    Immune_DeathMagic : 1 [[comment("Immune to Death Magic")]];
    Immune_Poison : 1 [[comment("Immune to Poison")]];
    Immune_Decapitation : 1 [[comment("Immune to Decapitation")]];
    Immune_Confusion : 1 [[comment("Immune to Confusion")]];
};

/***********************
    Character record
***********************/
// 1 - Player/Monster character record
struct CHAR01 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    SPL_NAME01 MemorizedSpell[21] [[comment("Spells currently memorized (available to cast) by the character")]];
    u8 Unknown_02C [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_A Race [[comment("Index of the character's race")]];
    CLASS_A Class [[comment("Index of the character's current class")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    SPL_KNOWN01 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    s8 LVL_Drained [[comment("Number of levels drained from character")]];
    s8 HP_Drained [[comment("Amount to subtract from HP_Max on drained characters")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Unknown_083 [[comment("Unknown")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    u8 TreasureShare [[comment("Combo value for the amount of treasure the NPC will take")]];
    u8 Unknown_086 [[comment("Always 00")]];
    u8 Unknown_087 [[comment("Always 00")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    GENDER_A Gender [[comment("Character's gender")]];
    MON_TYPE MON_Type [[comment("Character/creature type")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in a MON#CHA file for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    SPL_COUNT<3> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<3> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 XP_Award_Bonus [[comment("Additional XP awarded per HP of the character")]];
    u8 POR_Head [[comment("The character's head portrait image in HEAD3.DAX - Index to table in EXE for player characters")]];
    u8 POR_Body [[comment("The character's body portrait image in BODY3.DAX - Index to table in EXE for player characters")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    STATUS_A Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 2/8 - Player/Monster character record
struct CHAR0208 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    SPL_MEMORIZED SPL_Memorized[84] [[comment("Spells currently memorized by the character")]];
    u8 Unknown_072 [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_A Race [[comment("Index of the character's race")]];
    CLASS_A Class [[comment("Index of the character's current class")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    if (GameID == 2) {
        SPL_KNOWN02 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    }
    else {
        SPL_KNOWN08 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    }
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("Highest unmodified level of previous class for dual class characters")]];
    s8 LVL_Drained [[comment("Number of levels drained from character")]];
    s8 HP_Drained [[comment("Amount to subtract from HP_Max on drained characters")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Unknown_0F6 [[comment("Unknown")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    u8 TreasureShare [[comment("Combo value for the amount of treasure the NPC will take")]];
    u8 Unknown_0F9 [[comment("Always 00")]];
    u8 Unknown_0FA [[comment("Always 00")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    GENDER_A Gender [[comment("Character's gender")]];
    MON_TYPE MON_Type [[comment("Character/creature type")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in a MON#CHA file for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    SPL_COUNT<5> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<5> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize")]];
    SPL_COUNT<5> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 XP_Award_Bonus [[comment("Additional XP awarded per HP of the character")]];
    u8 POR_Head [[comment("Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 POR_Body [[comment("Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    if (GameID == 2) {
        FLAGARRAY02 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    }
    else {
        FLAGARRAY08 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    }
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    bool CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u8 Unknown_192 [[comment(std::format("{}", GameID == 2 ? "Always 00" : "Unknown"))]];
    u8 Unknown_193 [[comment("Always 00")]];
    u8 Unknown_194 [[comment("Always 00")]];
    STATUS_A Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 3 - Player/Monster character record
struct CHAR03 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    SPL_MEMORIZED SPL_Memorized[75] [[comment("Spells currently memorized by the character")]];
    u8 Unknown_069 [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_B Race [[comment("Index of the character's race")]];
    CLASS_A Class [[comment("Index of the character's current class")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    SPL_KNOWN03 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("Highest unmodified level of previous class for dual class characters")]];
    s8 LVL_Drained [[comment("Number of levels drained from character")]];
    s8 HP_Drained [[comment("Amount to subtract from HP_Max on drained characters")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    bool IsModified [[comment("Indicates if the character was 'modified' after creation")]];
    u8 Unknown_101 [[comment("Always 00")]];
    u8 Unknown_102 [[comment("Always 00")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    GENDER_A Gender [[comment("Character's gender")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in a MON#CHA file for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    SPL_COUNT<7> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<7> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize")]];
    SPL_COUNT<7> SPL_Count_SP [[comment("Total number of Special spells the character can memorize (Unused)")]];
    SPL_COUNT<7> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 XP_Award_Bonus [[comment("Additional XP awarded per HP of the character")]];
    u8 POR_Head [[comment("Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 POR_Body [[comment("Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    FLAGARRAY03 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    u8 Unknown_15F [[comment("Always 00")]];
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    STATUS_B Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 4/9 - Player/Monster character record
struct CHAR0409 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    SPL_MEMORIZED SPL_Memorized[141] [[comment("Spells currently memorized by the character")]];
    u8 Unknown_0AB [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_C Race [[comment("Index of the character's race")]];
    CLASS_A Class [[comment("Index of the character's current class")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    if (GameID == 4) {
        SPL_KNOWN04 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    }
    else {
        SPL_KNOWN09 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    }
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("Highest unmodified level of previous class for dual class characters")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    bool IsModified [[comment("Indicates if the character was 'modified' after creation")]];
    u8 Unknown_149 [[comment(std::format("{}", GameID == 4 ? "Unknown" : "Always 00"))]];
    u8 Unknown_14A [[comment("Always 00")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    CLASSLEVEL LVL_PreDrain [[comment("Level without adjustments (draining) applied")]];
    GENDER_A Gender [[comment("Character's gender")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    u8 MON_Index [[comment("Index to the original record in a MON1CHA file for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points with draining (if any) applied")]];
    u32 XP_PreDrain [[comment("Character's experience points without adjustments (draining) applied")]];
    u8 HP_PreDrain [[comment("Character's HP_Max before draining was applied")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    SPL_COUNT<9> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    if (GameID == 4) {
        FLAGARRAY04 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    }
    else {
        FLAGARRAY09 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    }
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    bool CanTrain [[comment("Indicates if the character has enough XP to train")]];
    STATUS_B Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 5 - Player/Monster character record
struct CHAR05 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    SPL_MEMORIZED SPL_Memorized[58] [[comment("Spells currently memorized by the character")]];
    u8 Unknown_058 [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_D Race [[comment("Index of the character's race")]];
    CLASS_B Class [[comment("Index of the character's current class")]];
    KNIGHTORDER KN_Order [[comment("Index of the character's knight order")]];
    DIETY CL_Diety [[comment("Index of the character's diety")]];
    ROBE MU_Robe [[comment("Index of the character's magic order/robe")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    SPL_KNOWN05 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("*Highest unmodified level of previous class for dual class characters (Unused)")]];
    s8 LVL_Drained [[comment("Number of levels drained from character")]];
    s8 HP_Drained [[comment("Amount to subtract from HP_Max on drained characters")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    bool IsModified [[comment("Indicates if the character was 'modified' after creation")]];
    u8 Unknown_0E9 [[comment("Always 00")]];
    u8 Unknown_0EA [[comment("Always 00")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    GENDER_A Gender [[comment("Character's gender")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in a MON#CHA file for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    SPL_COUNT<5> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<5> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize (Unused)")]];
    SPL_COUNT<5> SPL_Count_SP [[comment("Total number of Special spells the character can memorize")]];
    SPL_COUNT<5> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 XP_Award_Bonus [[comment("Additional XP awarded per HP of the character")]];
    u8 POR_Head [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 POR_Body [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    FLAGARRAY05 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    u8 Unknown_141 [[comment("Always 00")]];
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    STATUS_A Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 6 - Player/Monster character record
struct CHAR06 {
    u8 Name_Length [[comment("Contains the number of characters to read from the following Name field")]];
    char Name[15] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    u8 Unknown_01E [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    RACE_D Race [[comment("Index of the character's race")]];
    CLASS_B Class [[comment("Index of the character's current class")]];
    KNIGHTORDER KN_Order [[comment("Index of the character's knight order")]];
    DIETY CL_Diety [[comment("Index of the character's diety")]];
    ROBE MU_Robe [[comment("Index of the character's magic order/robe")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u16 Age [[comment("Character's age")]];
    u8 HP_Max [[comment("Character's max HP")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    MONEY Money [[comment("The amount of money the character has")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    GENDER_A Gender [[comment("Character's gender")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in MON1CHA.DAX for NPCs")]];
    u32 XP_Current [[comment("Character's current experience points with draining (if any) applied")]];
    u32 XP_PreDrain [[comment("Character's experience points without adjustments (draining) applied")]];
    u8 HP_PreDrain [[comment("Character's HP_Max before draining was applied")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u8 XP_Award_Bonus [[comment("Additional XP awarded per HP of the character")]];
    u8 ICO_Head [[format("FormatICOHead"),comment("ID number of the character's combat 'READY' head image for party members (+128 for 'ACTION' image ID)")]];
    u8 ICO_Body [[format("FormatICOBody"),comment("ID number of the character's combat 'READY' body image for party members - this follows the same logic as ICO_Head")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("Indicates if the character's icon is shorter or tall (i.e. Dwarf vs Human)")]];
    ICO_COLOR ICO_Color [[comment("Combat icon colors")]];
    FLAGARRAY06 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    u8 ITM_Count [[comment("Number of items in the character's ITM file")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    u32 ADDR_Spell [[comment("Pointer to the character's spell data")]];
    bool CanTrain [[comment("Indicates if the character has enough XP to train")]];
    STATUS_A Status [[comment("Index to the character's status")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
} [[name(std::format("{}", Name))]];

// 7 - Shared Player/Monster struct
struct CHAR_BASE07 {
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u32 XP_Current [[comment("Character's current experience points with draining (if any) applied")]];
    u32 XP_PreDrain [[comment("Character's experience points without adjustments (draining) applied")]];
    MONEY Money [[comment("The amount of money the character has")]];
    u16 Age [[comment("Character's age")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    RACE_E Race [[comment("Index of the character's race")]];
    CLASS_C Class [[comment("Index of the character's current class")]];
    u16 MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    u16 Unknown_05E [[comment("Unknown")]];
    GENDER_B Gender [[comment("Character's gender")]];
    ALIGNMENT_B Alignment [[comment("Index of the character's alignment")]];
    STATUS_C Status [[comment("Index to the character's status")]];
    u16 IsHostile [[comment("Indicates if the character wants to kill you")]];
    char Name[16] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    u8 Unknown_086 [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u8 HP_Max [[comment("Character's max HP")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("*Highest unmodified level of previous class for dual class characters (Unused)")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    u8 Unknown_09D [[comment("Always 00")]];
    CLASSLEVEL LVL_PreDrain [[comment("Level without adjustments (draining) applied")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in MONCHA.GLB for NPCs")]];
    u8 HP_PreDrain [[comment("Character's HP_Max before draining was applied")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    u8 POR_Head [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 POR_Body [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 ICO_Head [[comment("*Carried over from previous games but not used as characters are predefined in 7/10")]];
    u8 ICO_ID [[comment("Index to the image in CBODY.TLB for the character's combat icon")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("*Carried over from previous games but not used as characters are predefined in 7/10")]];
    FLAGARRAY07 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    u8 ITM_Count [[comment("Number of items in the character's inventory - Not set on MON records")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    bool CanTrain [[comment("Indicates if the character has enough XP to train")]];
    SPL_MEMORIZED SPL_Memorized[137] [[comment("Spells currently memorized by the character")]];
    SPL_KNOWN07 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    SPL_COUNT<9> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_SP [[comment("Total number of Special spells the character can memorize")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
    KNIGHTORDER KN_Order [[comment("Index of the character's knight order")]];
    DIETY CL_Diety [[comment("Index of the character's diety")]];
    u8 MON_Slot [[comment("Monster slot ID - 10 only (Unused)")]];
    ROBE MU_Robe [[comment("Index of the character's magic order/robe")]];
} [[name(std::format("{}", Name))]];

// 7 - Player character struct
struct CHAR_CHR07 : CHAR_BASE07 {
    ITEM Item[ITM_Count] [[comment("Items in the character's inventory")]];
    if (ADDR_Effect != 0) {
        SFX_CHR07 SFX_Effect[GetSFXCount(9)] [[comment("Active effect or ability")]];
    }
};

// 7 - Monster struct
struct CHAR_MON07 : CHAR_BASE07 {
    u8 SFX_Count [[comment("Number of active effects on the character")]];
    u8 ITM_Count_MON [[comment("Number of items in the character's inventory")]];
    SFX_BASE SFX_Effect[SFX_Count] [[comment("Active effect or ability")]];
    ITEM Item[ITM_Count_MON] [[comment("Items in the character's inventory")]];
    u8 Unknown_LastByte;
};

// 10 - Shared Player/Monster struct
struct CHAR_BASE10 {
    u32 ADDR_NextCharacter [[comment("Pointer to the next character record")]];
    u32 ADDR_Effect [[comment("Pointer to effects linked to this character")]];
    INVENTORY Inventory [[comment("Pointers to the character's inventory items")]];
    u32 ADDR_Combat [[comment("Pointer to combat data")]];
    u32 XP_Current [[comment("Character's current experience points with draining (if any) applied")]];
    u32 XP_PreDrain [[comment("Character's experience points without adjustments (draining) applied")]];
    MONEY Money [[comment("The amount of money the character has")]];
    u16 Age [[comment("Character's age")]];
    u16 XP_Award_Base [[comment("Base XP awarded for killing the character")]];
    u16 ITM_Weight [[comment("Total weight the character is carrying from items/money")]];
    RACE_C Race [[comment("Index of the character's race")]];
    CLASS_D Class [[comment("Index of the character's current class")]];
    UNDEADTYPE MON_UndeadLevel [[comment("Undead level used in turn undead calculations")]];
    u8 Unknown_05B [[comment("Always 00")]];
    GENDER_A Gender [[comment("Character's gender")]];
    ALIGNMENT_A Alignment [[comment("Index of the character's alignment")]];
    STATUS_B Status [[comment("Index to the character's status")]];
    bool IsHostile [[comment("Indicates if the character wants to kill you")]];
    char Name[16] [[format("std::string::to_string"),comment("The character's name")]];
    ABILITY Ability [[comment("Character ability values")]];
    u8 Unknown_07E [[comment("Always 00")]];
    u8 THAC0_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Base THAC0 value, unaltered by equipment/effects")]];
    u8 CanCureDisease [[comment("Indicates if character is able to use Paladin's cure disease ability")]];
    u8 HP_Max [[comment("Character's max HP")]];
    ICO_DIMENSION ICO_Dimension [[comment("Combo value that sets the number of tiles the character uses and a flag that indicates if the character is considered 'large' for combat calculations")]];
    SAVETHROW SAV_Base [[comment("Base saving throws")]];
    u8 MOV_Base [[comment("Base movement, excluding any modifiers")]];
    u8 LVL_Current_PreDrain [[comment("Highest unmodified level of currently active class")]];
    u8 LVL_Previous_PreDrain [[comment("Highest unmodified level of previous class for dual class characters")]];
    THIEFSKILL ThiefSkill [[comment("Thief skills")]];
    u8 Morale [[comment("Value used for calculating when the character should bravely run away")]];
    u8 LVL_Sweep [[comment("The level to use for the fighter sweep ability calculations")]];
    u8 Unknown_095 [[comment("Always 00")]];
    CLASSLEVEL LVL_PreDrain [[comment("Level without adjustments (draining) applied")]];
    CLASSLEVEL LVL_Current [[comment("Current level with adjustments (draining) applied")]];
    CLASSLEVEL LVL_Previous [[comment("Previous level for dual class characters")]];
    ATTACK ATK_Base [[comment("Base (unarmed) attack ability")]];
    u8 AC_Base [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC unadjusted by equipment")]];
    bool STR_Bonus [[comment("Indicates if character's strength bonus (if any) should be added to attacks")]];
    u8 MON_Index [[comment("Index to the original record in MONCHA.GLB for NPCs")]];
    u8 HP_PreDrain [[comment("Character's HP_Max before draining was applied")]];
    CLASSRESTRICTION ITM_Allowed [[comment("Bit array flagging the character's active classes")]];
    u8 HP_Base [[comment("Character's unadjusted HP")]];
    u8 POR_Head [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 POR_Body [[comment("*Carried over from 1 but no longer used as portraits were removed in later games")]];
    u8 ICO_Head [[comment("*Carried over from previous games but not used as characters are predefined in 7/10")]];
    u8 ICO_ID [[comment("Index to the image in CBODY.TLB for the character's combat icon")]];
    u8 Party_Position [[comment("Character's position in the party list")]];
    ICO_SIZE ICO_Size [[comment("*Carried over from previous games but not used as characters are predefined in 7/10")]];
    FLAGARRAY10 CharacterFlag [[comment("Bit array flagging various character attributes")]];
    u8 ITM_Count [[comment("Number of items in the character's inventory")]];
    u8 ITM_Hands [[comment("Number of equipped hands")]];
    u8 SAV_Bonus [[comment("Saving throw bonus")]];
    u8 SPL_Resistance [[comment("Character's magic resistance percentage")]];
    bool CanTrain [[comment("Indicates if the character has enough XP to train")]];
    SPL_MEMORIZED SPL_Memorized[141] [[comment("Spells currently memorized by the character")]];
    SPL_KNOWN10 SPL_Known [[comment("Spells known (can memorize) by the character")]];
    SPL_COUNT<9> SPL_Count_CL [[comment("Total number of Cleric spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_DR [[comment("Total number of Druid spells the character can memorize")]];
    SPL_COUNT<9> SPL_Count_MU [[comment("Total number of Magic-User spells the character can memorize")]];
    bool IsActive [[comment("Indicates if the character can still move in combat")]];
    bool IsQuickFight [[comment("Indicates if quick fight is enabled for that character")]];
    u8 THAC0_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Current THAC0 value with equipment/dexterity/effects applied")]];
    u8 AC_Current [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment")]];
    u8 AC_Back [[format_read("FormatACTHAC0"),format_write("FormatACTHAC0"),comment("Character's AC adjusted by equipment when attacked from behind")]];
    ATTACK ATK_Current [[comment("Current attack ability")]];
    u8 HP_Current [[comment("The character's current HP")]];
    u8 MOV_Current [[comment("The character's current movement with equipment/effects applied")]];
    u8 MON_Slot [[comment("Monster slot ID")]];
} [[name(std::format("{}", Name))]];

// 10 - Player character struct
struct CHAR_CHR10 : CHAR_BASE10 {
    ITEM Item[ITM_Count] [[comment("Items in the character's inventory")]];
    if (ADDR_Effect != 0) {
        SFX_CHR10 SFX_Effect[GetSFXCount(10)] [[comment("Active effect or ability")]];
    }
};

// 10 - Monster struct
struct CHAR_MON10 : CHAR_BASE10 {
    ITM_MON10 Item[16] [[comment("Items in the character's inventory")]];
// Since we're offsetting to get the ItemID/Quantity paired, it doesn't actually move the read position forward, so need to skip the Quantity values
    padding[16];
    SFX_MON10 SFX_EffectID[20] [[comment("Active effect or ability ID (0 = None)")]];
};

// Generic struct - ImHex doesn't export to PatternData on conditionals (or I'm doing it wrong) so using this as a workaround
struct CHAR {
    match (GameID,IsMON,IsSAV) {
        (1,_,_):            CHAR01 Character;
        (2|8,_,_):          CHAR0208 Character;
        (3,_,_):            CHAR03 Character;
        (4|9,_,_):          CHAR0409 Character;
        (5,_,_):            CHAR05 Character;
        (6,_,_):            CHAR06 Character;
        (7,true,false):     CHAR_MON07 Monster;
        (7,false,true):     CHAR_CHR07 Character[CHARCount] [[inline]];
        (7,false,false):    CHAR_CHR07 Character;
        (10,true,false):    CHAR_MON10 Monster;
        (10,false,true):    CHAR_CHR10 Character[CHARCount] [[inline]];
        (10,false,false):   CHAR_CHR10 Character;
    }
};

CHAR Character @ Offset [[inline]];
