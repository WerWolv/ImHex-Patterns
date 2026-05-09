#pragma author Draxinusom
#pragma description Gold Box Games - Common Functions

// Formatting function for AC/THAC0 (RW)
fn FormatACTHAC0 (u8 Input) {
    s8 Val = 60 - Input;
    return Val;
};

// Formatting function for ICO_Body
fn FormatICOBody (u8 Input) {
    u8 IconSize @ $ + 2;
    return ((IconSize -1) * 64) + Input;
};

// Formatting function for ICO_Head (2 functions due to offset to ICO_Size)
fn FormatICOHead (u8 Input) {
    u8 IconSize @ $ + 3;
    return ((IconSize -1) * 64) + Input;
};

// Function to iterate through player character SFX records to get count - 7/10 only
fn GetSFXCount(u8 RecordLength) {
    // Only called if SFX exists so start at 1
    u8 SFXCount = 1;
    u8 NextEffectOffset = RecordLength == 10 ? 6 : 5;

// Iterate from current offset to check NextEffect address - Should break before but sanity check on mem::size to ensure in bounds
    for (u32 CurrentOffset = $, CurrentOffset <= (std::mem::size() - RecordLength), CurrentOffset = (CurrentOffset + RecordLength)) {
    // Get NextEffect address
        u32 ADDR_NextEffect @ CurrentOffset + NextEffectOffset;
    // Break if 0
        if (ADDR_NextEffect == 0) {
            break;
        }
    // Add to count if another effect exists
        else {
            SFXCount += 1;
        }
    }
    return SFXCount;
};

// Color attribute function for ICO_COLOR.COLOR - returns RGB value of icon colors (unused 7/10)
fn IconColorValue(auto Input) {
    if (Input == COLORNAME::DarkGray) {
        return 0x555555;
    }
    if (Input == COLORNAME::Blue) {
        return 0x0000AA;
    }
    if (Input == COLORNAME::Green) {
        return 0x00AA00;
    }
    if (Input == COLORNAME::Cyan) {
        return 0x00AAAA;
    }
    if (Input == COLORNAME::Red) {
        return 0xAA0000;
    }
    if (Input == COLORNAME::Magenta) {
        return 0xAA00AA;
    }
    if (Input == COLORNAME::Brown) {
        return 0xAA5500;
    }
    if (Input == COLORNAME::LightGray) {
        return 0xAAAAAA;
    }
    if (Input == COLORNAME::Black) {
        return 0x000000;
    }
    if (Input == COLORNAME::BrightBlue) {
        return 0x5555FF;
    }
    if (Input == COLORNAME::BrightGreen) {
        return 0x55FF55;
    }
    if (Input == COLORNAME::BrightCyan) {
        return 0x55FFFF;
    }
    if (Input == COLORNAME::BrightRed) {
        return 0xFF5555;
    }
    if (Input == COLORNAME::BrightMagenta) {
        return 0xFF55FF;
    }
    if (Input == COLORNAME::BrightYellow) {
        return 0xFFFF55;
    }
    if (Input == COLORNAME::BrightWhite) {
        return 0xFFFFFF;
    }
    else {
        return 0x000000;
    }
};