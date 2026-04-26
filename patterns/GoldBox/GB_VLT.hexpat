#pragma author Draxinusom
#pragma description Gold Box Games - Vault
#include <GoldBox/GB_STRUCT_ITM.cs>
#include <GoldBox/GB_UTIL_ITM.cs>
import std.core;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the vault files
 for all Gold Box games that have them (D&D, no one cares about Buck Rogers)

 Supported Games:
 03 - Secret of the Silver Blades (VAULT.DAT)
 04 - Pools of Darkness (VAULT[A-J].DAT)
 06 - Death Knights of Krynn (VAULT[A-J].DAT)
 07 - The Dark Queen of Krynn (VAULT[A-J].DAT)
 08 - Gateway to the Savage Frontier (VAULT.[A-J])
 09 - Treasures of the Savage Frontier (VAULT[A-J].DAT)
 10 - Unlimited Adventures (VAULT[A-J].DAT)

 Unsupported Games:
 01 - Pool of Radiance
 02 - Curse of the Azure Bonds
 05 - Champions of Krynn

 The GameID variable below must be set for to the number in the list of
 supported games above for the source game
**********/
u8 GameID = 0;

u32 FileSize = std::mem::size();
u8 RecordSize = 0;
u8 ItemCount = 0;
u32 Offset = 0;

// Check GameID is set
if (GameID == 0) {
    std::warning("Please set the GameID variable to the source game's number.");
    return;
}

// Ensure GameID is in range
if (GameID > 10) {
    std::warning("Invalid GameID. Aborting.");
    return;
}
// Ensure specified game _has_ a Vault
if (GameID < 3 || GameID == 5) {
    std::warning("Specified GameID for game that does not have a vault. Aborting.");
    return;
}

// Get RecordSize
if (GameID == 7 || GameID == 10) {
    RecordSize = GameID == 7 ? 17 : 18;
    u8 RecordCount @ 0x0E;
    ItemCount = RecordCount;
    Offset = 0x0E;
}
else {
    RecordSize = GameID == 3 ? 67 : 63;
    Offset = (GameID == 3 || GameID == 8) ? 0x1C : 0x0C;
    ItemCount = (FileSize - Offset) / RecordSize;
}

// Check file is likely a vault file
if (GameID == 7 || GameID == 10) {
    if (FileSize != (GameID == 7 ? 866 : 916)) {
        std::warning("File is not a valid vault file or incorrect GameID specified.\nAborting.");
        return;
    }
}
else if (Offset + (ItemCount * RecordSize) != FileSize) {
    std::warning("File is not a valid vault file or incorrect GameID specified.\nAborting.");
    return;
}

// Flag if game uses steel instead of platinum (Krynn games)
bool IsSteel = (GameID == 6 || GameID == 7);
// Flag if game has Bundle of # Scrolls item
bool HasBundle = (GameID == 3 || GameID == 4 || GameID == 7 || GameID == 9 || GameID == 10) ? true : false;

// Money
struct MONEY {
    if (GameID == 3 || GameID == 8) {
        s32 MNY_Copper [[name("Copper (CP)"),comment("Copper coins (CP) stored in the vault")]];
        s32 MNY_Silver [[name("Silver (SP)"),comment("Silver coins (SP) stored in the vault")]];
        s32 MNY_Electrum [[name("Electrum (EP)"),comment("Electrum coins (EP) stored in the vault")]];
        s32 MNY_Gold [[name("Gold (GP)"),comment("Gold coins (GP) stored in the vault")]];
    }
    s32 MNY_SteelPlatinum [[name(std::format("{}", IsSteel ? "Steel (SP)" : "Platinum (PP)")),comment(std::format("{} coins ({}P) stored in the vault", IsSteel ? "Steel" : "Platinum", IsSteel ? "S" : "P"))]];
    s32 MNY_Gem [[name("Gems"),comment("Unappraised gems stored in the vault")]];
    s32 MNY_Jewelry [[name("Jewelry"),comment("Unappraised jewelry stored in the vault")]];
} [[comment("Money stored in the vault")]];

// Wrapper struct for ITEM used to help make returning NumberOfItems (7/10) dynamic
struct ITEMVAULT {
    if (GameID == 7 || GameID == 10) {
        u16 NumberOfItems [[name("Number of items"),comment("Number of items stored in the vault\nUpdate this number to match new count if adding/removing items")]];
    }
    ITEM Item[ItemCount] [[inline]];
};

MONEY Money @ 0x00;
ITEMVAULT Item @ Offset [[comment("Items stored in the vault")]];