#pragma author Draxinusom
#pragma description Gold Box Games - Item Record
#include <GoldBox/GB_STRUCT_ITM.cs>
#include <GoldBox/GB_UTIL_ITM.cs>
import std.core;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the item detail
 record files for all Gold Box games (D&D, no one cares about Buck Rogers)

 Supported Games:
 01 - Pool of Radiance (ITEM[1-8].DAX / CHRDAT[A-J]#.ITM / MON[1-8]ITM.DAX)
 02 - Curse of the Azure Bonds (ITEM[1-6].DAX / CHRDAT[A-J]#.SWG / MON[1-6]ITM.DAX)
 03 - Secret of the Silver Blades (ITEM[1-3].DAX / CHRDAT[A-J]#.STF / MON1ITM.DAX)
 04 - Pools of Darkness (ITEM0.DAX / CHRDAT[A-J]#.THG / MON1ITM.DAX)
 05 - Champions of Krynn (ITEM[1-3].DAX / CHRDAT[A-J]#.STF / MON[1-3]ITM.DAX)
 06 - Death Knights of Krynn (ITEM0.DAX / CHRDAT[A-J]#.JNK / MON1ITM.DAX)
 07 - The Dark Queen of Krynn (DISK1\ITEM.DAT)
 08 - Gateway to the Savage Frontier (ITEM[2-8].DAX / CHRDAT[A-J]#.SWG / MON[2-8]ITM.DAX)
 09 - Treasures of the Savage Frontier (ITEM0.DAX / CHRDAT[A-J]#.THG / MON1ITM.DAX)
 10 - Unlimited Adventures (DISK1\ITEM.DAT)

 Standard/Monster items (i.e. ITEM1.DAX) must be decompressed first in order to view the records
 This means that in order to edit those you must recompress/recreate the DAX file afterwards

 7/10 monster record items are strictly pointers to the standard item file and therefore not needed/supported
 Additionally, items for CHR/SAV files are stored in the file itself and can be viewed/edited there

 Note:
 As the logic for items is also used in the vault and 7/10 CHR/SAV files, all functions/structs/etc
 are located in the shared GB_STRUCT_ITM/GB_UTIL_ITM.cs file included above

 The GameID variable below must be set for to the number in the list above for the source game
*********/
u8 GameID = 0;

u32 FileSize = std::mem::size();
u8 RecordSize = 0;

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

// Get RecordSize
if (GameID == 7) {
    RecordSize = 17;
}
else if (GameID == 10) {
    RecordSize = 18;
}
// Other games can be variable depending on if CHR/ITM/MON record, so use int truncation to figure out what it is
// CHR/MON/STD: 1-2/5/8 - MON/STD: 3 - CHR/MON: 6 - CHR: 4/9
else if (FileSize == ((FileSize / 63) * 63)) {
    RecordSize = 63;
}
// CHR: 3
else if (FileSize == ((FileSize / 67) * 67)) {
    RecordSize = 67;
}
// STD/MON: 4/9 - STD: 6
else if (FileSize == ((FileSize / 17) * 17)) {
    RecordSize = 17;
}
else {
    std::warning("Unknown file. Exiting.");
    return;
}

// Get ItemCount
u8 ItemCount = FileSize / RecordSize;

// Flag if game has Bundle of # Scrolls item
bool HasBundle = (GameID == 3 || GameID == 4 || GameID == 7 || GameID == 9 || GameID == 10) ? true : false;

ITEM Item[ItemCount] @ 0x00;