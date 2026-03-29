#pragma author Draxinusom
#pragma description Gold Box Games - UA Script
import std.core;
import std.string;

/**********
 This is intended to allow looking up and/or modifying the SCRIPT.GLB file for Unlimited Adventures

 Supported Games:
 10 - Unlimited Adventures (DISK3\SCRIPT.GLB)

 Note:
 Edits that do not change the byte counts can be easily done but edits that change a field will require
 changing the field's FieldLength, the page it is on PageLength, the script record's DataEnd offset and
 all offsets after the modified script, and the FileSize at 0x0004

 A backup of the SCRIPT.GLB may be considered good advice before editing
 but that's for cowards and you should have confidence in yourself
**********/

/***********************
    Enumerations
***********************/
/***********
    Text Color
    Used to change the default colors of Label field types (0x03) from default BrightRed to
    LightGrey and other field type text from default LightGrey to BrightRed

    Other values above 2 _do_ work, at least so far as they do change the font
    However, different results observed depending on the event, typically a
    black, blue, or green background with a different foreground (text) color

    Based on that, I assume this is likely an overflow - all usages are 0 or 2
    though 1 is valid (color used for header, page #, and briefly displayed when clicking select boxes)

    Note: Color names are EGA standard names
***********/
enum TEXTCOLOR:u8 {
    LightGray = 0,
    BrightCyan = 1,
    BrightRed = 2
};

/***********
    Backgrounds
    These are used by field type Background (0x21) to set various background images and/or text
    below the page fields that are dynamically updated based on byte values or other controls

    Combat_Monster1/2:
    Used on page containing monsters 1-3/4-6 in Combat/PickOne events
    Displays the dungeon cave floor tile and displays the combat icon based on bytes 9/11/13 (1) or 15/17/19 (2)

    Shop_AvailableItem1-4:
    Used on Available Items screens in Shop/SmallTown events based on bytes 8/11/14/16 (14/16 only for SmallTown)
    to display the item names for the selected Item Kind (the buttons on that page are unlabelled)

    Monster_CurrentLevel:
    Used in the MonsterEditor on page one as a dynamic background to display the monster's current level
    SetCurrentLevel control (11) on ThiefLevel in page 2 performs the check for max value and updates

    NPC_OldClass:
    Used in the NPCEditor on page one as a dynamic background to display the NPC's "Old Class" for dual class NPCs
    between the character's current class and hit points - this will only display (including the "Old Class:" text label)
    for humans that are dual class, single class humans and all non-humans (even if hacked to have a previous class) will
    have empty space between class and hit points

    Note:
    Background may not be an accurate description, there are no static full page images it is loading, but it is displaying
    non-interactable text or images (floor + monster icons in Combat/PickOne) so I'm not sure what else to describe it as
***********/
enum BACKGROUND:u8 {
    Combat_Monster1 = 1,
    Combat_Monster2 = 2,
    Shop_AvailableItem1 = 3,
    Shop_AvailableItem2 = 4,
    Shop_AvailableItem3 = 5,
    Shop_AvailableItem4 = 6,
    Monster_CurrentLevel = 7,
    NPC_OldClass = 8
};

/***********
    Controls
    These are used by the Control property type (0x36) to perform additional data updates,
    modify/reformat entered values, and updates backgrounds

    SetImageType:
    Sets/clears bit 7 on byte 7 indicating if selected picture is a picture (1) or sprite (0)

    SetButton:
    Used in Dungeon/Overland Global Information step events to precheck all zones

    SetItemList:
    Used in Shop/SmallTown events and performs several tasks:
        1) Updates the Shop_AvailableItem1-4 backgrounds based on selected Item Kind (background contains the item names)
        2) Pre-checks all values for that type
        3) Clears selected Item Kind if all items unchecked on its Available Item screen

    SetACTHAC0:
    Converts AC/THAC0 value saved to/displayed from Gold Boxes standard format (base 60)

    SetMinusOne:
    Subtracts 1 from the entered number/adds 1 to the displayed number

    EventControl_ItemQuest/PercentChance/Facing/Class/Race:
    Controls which of the 5 values should be saved in byte 3 for event conditions
    The way this works is each of these are temporarily storing their values outside the
    20 byte available for events, starting at byte 20 for ItemQuest and ending at byte 24 for Race
    Based on the event control type it then saves the corresponding value from byte 20-24 to byte 3
    (or nothing if no applicable type is selected)

    SetCurrentLevel:
    Updates the Monster_CurrentLevel background in MonsterEditor by picking the highest class level

    Field_Disable:
    Makes the field unselected/editable - used in NPCEditor where it needs the fields to
    exist to display the values but doesn't allow modification

    I will note you can remove the Field_Disable controls (or set the control value to 0 so you don't have to mess with updating
    offsets/lengths) and edit the values but it does not properly handle class/race or level changes (i.e. changing a fighter to
    mage does not set/adjust spell counts, changing human to elf doesn't apply racial effects, etc)

    Unknown_51:
    Probably nothing but seems like there should be something here - no usages

    Field_Hide:
    Hides fields where value is unneeded for display - used in MonsterEditor to hide the 3 additional
    item and 5 additional effects on non-complex monsters

    EventControl_Type:
    Handles the enabling/disabling of condition fields for event controls
***********/
enum CONTROL:u8 {
    SetImageType = 1,
    SetButton = 2,
    SetItemList = 3,
    SetACTHAC0 = 4,
    SetMinusOne = 5,
    EventControl_ItemQuest = 6,
    EventControl_PercentChance = 7,
    EventControl_Facing = 8,
    EventControl_Class = 9,
    EventControl_Race = 10,
    SetCurrentLevel = 11,
    Field_Disable = 50,
    Unknown_51 = 51,
    Field_Hide = 52,
    EventControl_Type = 53
};

/***********
    Data Check
    These are used by field type DataCheck (0x20) to perform more complex data validation

    CheckGrid:
    Used in Dungeon/Overland Global Information on page 1 and Clear Module (56)
    to verify combination of Height/Width values are less than 576 max
    Note: Height/Width hidden on Overland (and not used in its Clear Module (55)) so doesn't really do anything there

    CheckMonster50:
    Used in Combat events to check the sum of all 6 monster types is less than 50,
    including doubling of values for "complex" types

    CheckMonster25:
    Used in PickOneCombat events to check "complex" monster types quantity is 25 or less
    Note: 31 max for non-complex controlled by Number field
***********/
enum DATACHECK:u8 {
    CheckGrid = 1,
    CheckMonster50 = 2,
    CheckMonster25 = 3
};

/***
    Field Types
    Records that make up a page - primarily what would be considered fields
    but page start/end and 3 whole page types included

    PageStart (0x01):
    Indicates the start of a page

    PageEnd (0x02):
    Page terminator record - a new page will immediately follow or 0x00 indicating end of the record's script data

    Label (0x03):
    A text string to display on the page with no data entry - primarily used for headers
    Default text color is BrightRed but is overridden in sections with Text_Color property to LightGrey

    Button (0x04):
    On/off radio button style control, typically (maybe always, haven't checked) sets a single bit value
    Unlike all other field types, the text is positioned to the right

    List (0x05):
    Drop down list allowing a single selection - available options defined as field properties

    Text Box (0x06):
    Large 6 line text input boxes primarily used in events - the string is compressed and stored in the STRG section
    of the file with the Store u16 property containing the string's index

    Number (0x07):
    Numeric value that always has Value_Min/Max properties

    Select (0x08):
    Used as large buttons that open another window to select a value (i.e. image, event, etc)

    String (0x09):
    Single line strings, the size is matched to the String_Length property - the string is uncompressed and stored directly where placed
    * See note below

    Text (0x0A):
    Single line strings, the size is matched to the String_Length property - the string is compressed and stored in the STRG section
    of the file with the Store u16 property containing the string's index - only used in EnterPassword/QuestionList

    Data Check (0x20):
    Runs the specified data check in properties when attempting to switch or leave the page - used for complex data validation types

    Background (0x21):
    Sets a dynamic background below the pages fields - typically auto updated by a control record

    Auto Set (0x22):
    Automatically sets a byte/bit value to the Default_u8/16/32 (and presumably String but no usage) - some usages set values that are not
    displayed such as setting the Transfer the Party value in Stairs to 0 (Attempts to Enter) and to 1 (Is In) on Teleporter events
    making this function as a hardcoded value in those cases

    Note:
    There are a few usages of the uncompressed string types in events, which cannot store those
    They are used where multiple strings are concatenated, such as with Question-Button/List or TavernDrinks

    How that works is it temporarily stores those strings outside the available 20 bytes for event records,
    like EventControl does, with the strings placed at bytes 40/80/120/160/200

    A hidden Text_Box field is then placed, typically (maybe always?) at the end of the page with a text caption of "~"
    That text box is used to concatenate the strings into a single ^ delimited compressed string and store the index to
    it at the byte specified
***/
enum FIELDTYPE:u8 {
    PageStart = 1,
    PageEnd = 2,
    Label = 3,
    Button = 4,
    List = 5,
    Text_Box = 6,
    Number = 7,
    Select = 8,
    String = 9,
    Text = 10,
    Data_Check = 32,
    Background = 33,
    Auto_Set = 34
};

/***
    Property Types

    Various attributes that control field's behavior and where/how it saves the data entered

    Text Color (0x30):
    Overrides the color of the text for that field - by default, Label field types are BrightRed and
    all others are LightGrey - following u8 byte specifies the color type (see enum above)

    Unknown 31 (0x31):
    Probably nothing but seems like there should be something here - no usages

    Store: u8-32 (0x32-34):
    Stores the value entered using 1, 2, or 4 bytes, depending on the type - following u16 value specifies the first (or only)
    byte to write the data to - for text this is the index to the compressed string

    Store: Bit (0x35):
    Stores the value as a bit value - typically used on buttons for setting a single bit but other multi bit values exist
    This type has a u8 byte that specifies the number of bits that are updated and is then followed with that number of u16
    values that specify the bit (counting up from the beginning of the record at 0) that is set
    The value is then stored across those bit with the first bit (bit 0) of the value stored in the first u16 bit specified,
    the second bit (1) stored in the second specified, etc - Typically stored in a contiguous range but not always (approach in Combat/PickOne splits one off)

    Store: Control (0x36):
    Performs additional logic when storing the value, either modifying (i.e. changing AC/THAC0 values), setting additional bytes/bits
    depending on the selected value, or shifting the data from temporary storage - has u8 byte that specifies behavior - see CONTROL enum above

    List Item (0x37):
    Used only by List field types, these are the values available on the list
    Begins with u8 value that is the ID number stored for the list entry, then a u8 byte indicating the item's string length (+2),
    then followed by a NULL (0x00) terminated string for the text displayed

    Value: Min/Max (0x38-39):
    Used by Numeric fields - has a s32 value indicating the minimum/maximum number allowed in the field
    Negative values only seen on AC/THAC0 numeric fields which have the SetACTHAC0 control on it

    Art (0x3A-43):
    Used by Select fields - These are identifiers for the image types to include in the selection window displayed
    when the button is clicked - Multiple types are allowed - These are always listed first and are added until another
    non-Art property type is hit - Note: while Sprites may be added to an event, they are suppressed in Overland maps

    Select (0x44/4A-4F):
    Used by Select field - Same as Art, however, these are always single types

    String: Length (0x45):
    Used by String type, sets the maximum number of characters allowed for the string - string box is adjusted to match

    Default: u8/16/32 (0x46-48):
    Sets the initial value to the following u8/16/32 value - this essentially functions as a hardcoded value
    for hidden AutoSet fields where the updated bit/byte is not viewable (i.e. Transfer the Party on Teleport events)

    Note:  Default 16/32 types are not used

    Default: String (0x49):
    Sets an initial/prepopulated string in text/string boxes - has a u8 value indicating the string length plus 2
    (i.e. 10 character default string will have a value of 12), followed by a null terminated character string
***/
enum PROPERTYTYPE:u8 {
    Text_Color = 48,
    Unknown_31 = 49,
    Store__u8 = 50,
    Store__u16 = 51,
    Store__u32 = 52,
    Store__Bit = 53,
    Store__Control = 54,
    List_Item = 55,
    Value__Min = 56,
    Value__Max = 57,
    Art__Small = 58,
    Art__Sprite = 59,
    Art__Icon_Monster = 60,
    Art__Icon_NPC = 61,
    Art__Big = 62,
    Art__Map = 63,
    Art__Tile_Indoor = 64,
    Art__Tile_Outdoor = 65,
    Art__Wall = 66,
    Art__Backdrop = 67,
    Select__Event = 68,
    String__Length = 69,
    Default__u8 = 70,
    Default__u16 = 71,
    Default__u32 = 72,
    Default__String = 73,
    Select__Module = 74,
    Select__Shop = 75,
    Select__Item = 76,
    Select__Effect = 77,
    Select__ItemKeyQuest = 78,
    Select__Spell = 79
};
// Note: double __ in enum names replaced as ": " to make the displayed name look nice :)

/***********************
    Functions
***********************/
fn Between (auto Value, auto Min, auto Max) {
    return (Value >= Min && Value <= Max);
};

fn IsAny (auto Value, auto Check) {
    for (u8 Iteration = 0, Iteration < std::core::member_count(Check), Iteration = Iteration + 1) {
        if (Value == Check[Iteration]) {
            return true;
        }
    }
    return false;
};

fn TitleCase (auto Input) {
    u8 StrLen = sizeof(Input);
    str OutString = "";
    str SpaceChar[9] = {" ", "-", "\\", "/", ".", ",", "(", ")", "\""};

    for (u8 Current = 0, Current < StrLen, Current = Current + 1) {
        str CurrentChar = str(std::string::at(Input, Current));

    // Always capitalize first character
        if (Current == 0) {
            OutString = OutString + std::string::to_upper(CurrentChar);

        }
        else {
        // Get previous character
            str PreviousChar = str(std::string::at(Input, Current - 1));

        // Capitalize current character if previous character is a SpaceChar
            if (IsAny(PreviousChar, SpaceChar)) {
                OutString = OutString + std::string::to_upper(CurrentChar);
            }
        // Otherwise just add in character
            else {
                OutString = OutString + CurrentChar;
            }
        }
    }

    return OutString;
};

// Cleans up ENUM values to make look a bit nicer as names
fn CleanEnum (auto Input) {
    str OutString = std::string::to_string(Input);
    for (u8 Pos = 0, Pos < sizeof(OutString), Pos = Pos + 1) {
        if (str(std::string::at(OutString, Pos)) == ":") {
            OutString = std::string::substr(OutString, Pos + 2, sizeof(OutString) - Pos - 2);
        }
    }

    return std::string::replace(std::string::replace(OutString, "__", ": "), "_", " ");
};

// Cleans up the text captions on fields to pad into field name
fn FieldText (str Input, u8 TypeID) {
// Some fields are just multiple spaces so removing all spaces for empty string check
    str StrTemp = std::string::replace(Input, " ", "");

// Break now if empty to avoid sticking " - " after the field name
    if (sizeof(StrTemp) == 1) {
        return "";
    }

    return " - " + TitleCase(std::string::replace(Input, ":", ""));
};

// Attempt to make Store: Bit properties a bit more readable
fn FormatStoreBit (ref auto Bits) {
    u8 BitCount = std::core::member_count(Bits);

// Iterate bits to bundle into ranges
    str OutString = "";
    for (u8 Index = 0, Index < BitCount, Index = Index + 1) {
    // Get current bit
        u16 CurrentBit = Bits[Index];
        u16 UntilBit = Bits[Index];

      // Get all sequential bits
        for (u8 SeqCheck = (Index + 1), SeqCheck < BitCount, SeqCheck = SeqCheck + 1) {
            u16 NextBit = Bits[SeqCheck];

        // Check if current last sequential bit equals next bit -1
            if (UntilBit == (NextBit - 1)) {
            // Push last bit/position forward
                UntilBit = NextBit;
                Index += 1;
            }
        // Break on hitting non-sequential bit
            else {
                break;
            }
        }

    // Pad bit range into OutString
        if (CurrentBit == UntilBit) {
    // If single bit, just add
            OutString = std::format("{}{:d}.{:d}", OutString + (OutString == "" ? "" : ", "), CurrentBit / 8, CurrentBit % 8);
        }
        else {
        // For range, grab the start/end bytes to make easier to compare if that should be included - not including end byte if same as beginning byte
            u16 CurrentByte = CurrentBit / 8;
            u16 UntilByte = UntilBit / 8;

            OutString = std::format("{}{:d}.{:d}-{}{:d}", OutString + (OutString == "" ? "" : ", "), CurrentByte, CurrentBit % 8, CurrentByte == UntilByte ? "" : std::string::to_string(UntilByte) + ".", UntilBit % 8);
        }
    }

    return OutString;
};

// Art select types allow multiple types to be added to a field so concatenate to make look nice :P
fn GetSelectType (auto SelectType) {
    u8 SelectCount = std::core::member_count(SelectType);
    str SelectList = Between(SelectType[0], 58, 67) ? "Art: " : "";

// ENUMs exist for this but doing a match is easier to concatenate and make clean display names
    for (u8 Index = 0, Index < SelectCount, Index = Index + 1) {
        match (SelectType[Index]) {
        // Art types
            (58):   SelectList = SelectList + "Picture/";
            (59):   SelectList = SelectList + "Sprite/";
            (60):   SelectList = SelectList + "Combat Icon (Monster)/";
            (61):   SelectList = SelectList + "Combat Icon (NPC)/";
            (62):   SelectList = SelectList + "Big Picture/";
            (63):   SelectList = SelectList + "Map/";
            (64):   SelectList = SelectList + "Dungeon/";
            (65):   SelectList = SelectList + "Wilderness/";
            (66):   SelectList = SelectList + "Wall Set/";
            (67):   SelectList = SelectList + "Backdrop/";
        // These are never combined but still including "/" at end to simplify return
            (68):   SelectList = SelectList + "Event/";
            (74):   SelectList = SelectList + "Module/";
            (75):   SelectList = SelectList + "Item Kind/";
            (76):   SelectList = SelectList + "Item/";
            (77):   SelectList = SelectList + "Special Effect/";
            (78):   SelectList = SelectList + "Variable/";
            (79):   SelectList = SelectList + "Spells Memorized/";
        }
    }

// Strip trailing "/" on return
    return std::string::substr(SelectList, 0, sizeof(SelectList) - 1);
};

// Offsets are stored as half the actual value so double on read
fn ReadOffset (u8 Input) {
  // Treat as u16 just in case
    u16 Output = Input * 2;
    return Output;
};

// and half on write
fn WriteOffset (u16 Input) {
  // Treat as u16 just in case
    u8 Output = Input / 2;
    return Output;
};

/***********************
    Structs
***********************/

// List field type items
struct LISTITEM {
    PROPERTYTYPE Property [[tree_hidden]];
    u8 ID;
    u8 StringLength [[tree_hidden,name("String Length")]]; // +2
    char DisplayName[] [[format("std::string::to_string")]];
} [[name(std::format("{:02d}: {}", ID, TitleCase(DisplayName)))]];

// Select field type selection options
struct SELECT {
    u8 Select[while(Between(std::mem::read_unsigned($, 1), 58, 68) || Between(std::mem::read_unsigned($, 1), 74, 79))] [[sealed,format("GetSelectType")]];
} [[inline]];

// Store: Bit field type bit arrays
struct STOREBIT {
    u8 BitCount [[tree_hidden,name("Bit Count")]];
    u16 Bit[BitCount] [[sealed,name(std::format("Store: {:d} Bit{}", BitCount, BitCount > 1 ? "s" : "")), format("FormatStoreBit"),comment("This cannot be directly edited\nMake any changes in the Hex editor section and ensure BitCount matches modified count")]];
} [[inline]];

// Field properties
struct PROPERTY<auto TypeID> {
    u8 Val @ $ [[hidden]];

    match (TypeID,Val) {
    // DataCheck
        (32,_): {
            DATACHECK DataCheck;
        }
    // Background
        (33,_): {
            BACKGROUND Background;
        }
    // 0x30 - TextColor
        (_,48): {
            PROPERTYTYPE Property [[tree_hidden]];
            TEXTCOLOR TextColor;
        }
    // 0x32 - Store_u8 - u16
        (_,50): {
            PROPERTYTYPE Property [[tree_hidden]];
            u16 Store_u8 [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x33 - Store_u16 - u16
        (_,51): {
            PROPERTYTYPE Property [[tree_hidden]];
            u16 Store_u16 [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x34 - Store_u32 - u16
        (_,52): {
            PROPERTYTYPE Property [[tree_hidden]];
            u16 Store_u32 [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x35 - Store_Bit - variable
        (_,53): {
            PROPERTYTYPE Property [[tree_hidden]];
            STOREBIT Store_Bit;
        }
    // 0x36 - Store_Control
        (_,54): {
            PROPERTYTYPE Property [[tree_hidden]];
            CONTROL Control;
        }
    // 0x37 - ListItem
        (_,55): {
            LISTITEM ListItem[while(std::mem::read_unsigned($, 1) == 55)] [[name("List Items")]];
        }
    // 0x38 - Value_Min - s32
        (_,56): {
            PROPERTYTYPE Property [[tree_hidden]];
            s32 Value_Min [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x39 - Value_Max - s32
        (_,57): {
            PROPERTYTYPE Property [[tree_hidden]];
            s32 Value_Max [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x3A-44/74-79 - Select Screen
        (_,58 ... 68|74 ... 79): {
            SELECT SelectScreen;
        }
    // 0x45 - String_Length - u8
        (_,69): {
            PROPERTYTYPE Property [[tree_hidden]];
            u8 String_Length [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x46 - Default_u8 - u8
        (_,70): {
            PROPERTYTYPE Property [[tree_hidden]];
            u8 Default_u8 [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x47 - Default_u16 - u16
        (_,71): {
            PROPERTYTYPE Property [[tree_hidden]];
            u16 Default_u16 [[name(std::format("{}", CleanEnum(Property)))]];
        }
    // 0x48 - Default_u32 - u32
        (_,72): {
            PROPERTYTYPE Property [[tree_hidden]];
            u32 Default_u32 [[name(std::format("{}", CleanEnum(Property)))]];
        }

    // 0x49 - Default_String
        (_,73): {
            PROPERTYTYPE Property [[tree_hidden]];
            u8 StringLength [[tree_hidden,name("Default String Length"),comment("Length is +2 of actual text length")]];
            char Default_String[] [[name("Default: String"), format("std::string::to_string")]];
        }
    // Fallback
        (_,_): {
            PROPERTYTYPE Property;
        }
    }
} [[inline]];

// Page fields
struct FIELD {
    u8 TypeID @ $ [[hidden]];
    bool IsAggregate = false;
    FIELDTYPE FieldType [[name("Field Type")]];
    u16 FieldLength [[tree_hidden]];
    match (TypeID) {
    // Auto/PageControl types
        (32|33|34): {
            u32 DataEnd = $ + FieldLength - 3;
            str Text = "";  // This is included to get field name to work (even though it won't hit it, it still fails if a "Text" type doesn't exist)
            PROPERTY<TypeID> Properties[while($ < DataEnd)] [[inline]];
        }
    // Fields
        (_): {
            u8 OffsetY [[name("Y Offset"),format_read("ReadOffset"),format_write("WriteOffset"),comment("Field\'s Y position on screen starting from top left")]];
            u8 OffsetX [[name("X Offset"),format_read("ReadOffset"),format_write("WriteOffset"),comment("Field\'s X position on screen starting from top left")]];
            u8 TextLength [[tree_hidden,name("Text Length"),comment("Length is +2 of actual text length")]];
            char Text[] [[format("std::string::to_string")]];   // Label is probably a more appropriate term but don't want to confuse with actual "Label" field type
        // Flag the string aggregate fields (used in QuestionList/Button & Tavern events) so can override name
            if (TypeID == 6 && TextLength == 3 && Text[0] == 0x7E) {
                IsAggregate = true;
            }
            u32 DataEnd = $ + FieldLength - sizeof(Text) - 6;
            PROPERTY<TypeID> Properties[while($ < DataEnd)] [[inline]];
        }
    }
} [[name(std::format("{:02d}: {}{}", std::core::array_index(), IsAggregate ? "String Aggregate" : CleanEnum(FieldType), (TypeID > 31 || IsAggregate) ? "" : FieldText(Text, TypeID)))]];

// Page records
struct PAGE {
    FIELDTYPE PageType [[tree_hidden]];
    u32 PageOffset = $;
    u16 PageLength [[tree_hidden,name("Page Length")]];    // Includes self
    u8 PageNumber [[tree_hidden,name("Page Number"),comment("Event pages all use Common Event Page as page 1\nMaking the page 2 the first page in a script")]];
    FIELD Field[while($ < (PageOffset + PageLength - 2))] [[inline]];
    FIELDTYPE PageEnd [[tree_hidden]]; // Always 2
} [[name(std::format("Page {:d}", PageNumber))]];

// Script data
struct SCRIPT {
    u8 HeaderLength [[tree_hidden,name("String Length"),comment("Length is +2 of actual header length")]]; // +2
    char Header[] [[format("std::string::to_string")]];  // Displays at top of all pages
    PAGE Page[while(std::mem::read_unsigned($, 1) == 1)] [[inline]];
};

/*** Unused
// GLB ID Table
struct ID {
    u16 RecordID;
    u16 Ordinal;
};
***/

struct RECORD {
    u32 Offset_Start [[name("Data offset")]];
    u32 Offset_End [[name("Data end"),no_unique_address]];   // no_unique_address means don't move the read position forward
  // Skip unused types (i.e. data size is 0)
    if (Offset_Start == Offset_End) {
        continue;
    }
/*** Not a thing for this file
    if (HasIDTable) {
        ID RecordID @ (16 + 4 + (RecordCount * 4) + 2 + (std::core::array_index() * 4)) [[inline]];
        be u16 DataLength_Uncompressed @ Offset_Start;
        char Data[Offset_End - Offset_Start -2] @ (Offset_Start + 2);
    }
    else {
        char Data[Offset_End - Offset_Start] @ (Offset_Start);
    }
***/
    SCRIPT Script @ (Offset_Start) [[inline]];
} [[name(std::format("{:02d}: {}", std::core::array_index(), std::core::has_member(this, "Script") ? TitleCase(Script.Header) : ""))]];

u32 FileSize @ 0x04 [[tree_hidden]];
u16 RecordCount @ 0x08 [[tree_hidden]]; // Includes ID table (if exists)
bool HasIDTable @ 0x0B [[tree_hidden]];

RECORD Records[(HasIDTable ? (RecordCount - 1): RecordCount)] @ (HasIDTable ? 0x14 : 0x10) [[inline]];
