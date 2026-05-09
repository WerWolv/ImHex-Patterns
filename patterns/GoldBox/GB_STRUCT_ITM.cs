#pragma author Draxinusom
#pragma description Gold Box Games - Common Item Structs
#pragma once

// Item Flags
bitfield ITEMFLAGARRAY {
    HideNamePart1 : 1 [[comment("Indicates if NamePart1 is identified\ni.e. is displayed")]];
    HideNamePart2 : 1 [[comment("Indicates if NamePart2 is identified\ni.e. is displayed")]];
    HideNamePart3 : 1 [[comment("Indicates if NamePart3 is identified\ni.e. is displayed")]];
    match (GameID) {
        (4|10): {
            padding : 2;
            Unknown_05 : 1 [[name("Unknown_05**"),comment(std::format("{}\nLikely error", GameID == 6 ? "Only set on invalid item" : "Only set on Dagger +4"))]];
            Unknown_06 : 1 [[name("Unknown_06**"),comment(std::format("{}\nLikely error", GameID == 6 ? "Only set on invalid item" : "Only set on Bolt +4"))]];
        }
        (5|6|7): {
            IsBlackRobe : 1 [[name(std::format("{}", GameID == 6 ? "IsBlackRobe**" : "IsBlackRobe*")),comment(std::format("{}", GameID == 6 ? "Only set on invalid item\nLikely error" : "Unused"))]];
            IsWhiteRobe : 1 [[comment("Indicates if item is Red Robe Mage only\nUsed by scrolls only")]];
            IsRedRobe : 1 [[comment("Indicates if item is Red Robe Mage only\nUsed by scrolls only")]];
            if (GameID == 7) {
                Unknown_06 : 1 [[comment("Only set on Bolt +4\nLikely error")]];
            }
        }
        (8): {
            padding : 3;
            Unknown_06 : 1 [[comment("Set on some MON/NPC equipment and found/reward items like the Luskan pirate treasure (SwordOfIcewindDale/etc)\nUnknown purpose")]];
        }
    }
};

// Item Detail struct
struct ITEM {
// Used in CHR/MON/STD/VLT: 1-3/5/8 - CHR/MON/VLT: 6 - CHR/VLT: 4/9
    if (RecordSize > 62) {
        u8 DisplayName_Length [[comment("Number of characters in description field to read")]];
        char DisplayName[DisplayName_Length] [[comment("Display name for the item in the UI\nThese are only really valid in save item files as they're often incorrect/have errors in standard item/enemy files")]];
        padding[41 - DisplayName_Length];
        u32 ADDR_NextItem [[comment("Pointer to next item in file\n0x00000000 if last item")]];
    }
// Used in all
    u8 BaseTypeID [[comment("Index of the base record for this item in the ITEMS file")]];
    u8 NamePart3 [[format("GetItemNamePart"),comment("String index for the 3rd part of item name\n0x00 if item does not have a 3rd part")]];
// Get NamePart1 to check if Bundle of - is string index 77 in all games it's used in (3-4/7/9-10)
    u8 NamePartID1 @ $ +1 [[hidden]];
// NamePart2 is the original bundle quantity (Quantity is current) for Bundle of # Scrolls so direct convert value instead of lookup
    u8 NamePart2 [[format(std::format("{}", HasBundle && NamePartID1 == 77 ? "std::string::to_string" : "GetItemNamePart")),comment("String index for the 2nd part of item name\n0x00 if item does not have a 2nd part")]];
    u8 NamePart1 [[format("GetItemNamePart"),comment("String index for the 1st part of item name\nThis should always have a value")]];
// 7/10 varies column order (for some reason?)
    match (GameID) {
        (7|10): {
            s16 Weight [[comment("The item's weight in coins")]];
            s16 Value [[comment("The item's monetary/resell value")]];
            s8 Bonus [[comment("+ or - to apply to AC/THAC0\nIs also used for XP value of magical treasure\n(XP = Bonus * 400)")]];
            s8 SaveBonus [[comment("The bonus to saves for magic armor/rings")]];
            bool IsEquipped [[comment("Indicates if item is equipped")]];
            ITEMFLAGARRAY ItemFlag [[comment("Flag array used primarily for setting which NamePart strings to display for items that need identified")]];
            bool IsCursed [[comment("Indicates if an item is cursed\ni.e. you can't unequip it")]];
            u8 Quantity [[comment("Total number of stacked items\nIf 0, there is 1 item and it cannot be stacked")]];
        }
        (_): {
            s8 Bonus [[comment("+ or - to apply to AC/THAC0\nIs also used for XP value of magical treasure\n(XP = Bonus * 400)")]];
            s8 SaveBonus [[comment("The bonus to saves for magic armor/rings")]];
            bool IsEquipped [[comment(std::format("Indicates if item is equipped{}", (GameID == 3 || GameID == 5 || GameID == 6 || GameID == 8) ? "\nSet to 0x80 (128) on some MON/NPC items\nUnknown usage" : ""))]];
            ITEMFLAGARRAY ItemFlag [[comment("Flag array used primarily for setting which NamePart strings to display for items that need identified")]];
            bool IsCursed [[comment("Indicates if an item is cursed\ni.e. you can't unequip it")]];
            s16 Weight [[comment("The item's weight in coins")]];
            u8 Quantity [[comment("Total number of stacked items\nIf 0, there is 1 item and it cannot be stacked")]];
            s16 Value [[comment("The item's monetary/resell value")]];
        }
    }
// Could clean these up but think it would make editing a bit messy/confusing
    u8 Property3 [[comment("Variable usage, depending on item type")]];
    u8 Property2 [[comment("Variable usage, depending on item type")]];
    u8 Property1 [[comment("Variable usage, depending on item type")]];
    match (RecordSize) {
    // 10 only
        (18):   u8 Unknown_11 [[comment("Always 0x00")]];
    // 3  only
        (67):   u32 ADDR_NextSubItem [[comment("Pointer to next sub-item in file\nUsed for Bundles of # Scrolls")]];
    }
} [[name(std::format("{}: {}", FormatIndex(std::core::array_index(), ItemCount), GetDisplayName(NamePart1, NamePart2, NamePart3, Quantity)))]];