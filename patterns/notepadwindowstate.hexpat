#pragma author ogmini https://github.com/ogmini
#pragma description Windows 11 Notepad Window State file
#pragma magic [ 4E 50 ] @ 0x00
// File found at %localappdata%/Packages/Microsoft.WindowsNotepad_8wekyb3d8bbwe/LocalState/WindowState

#include <std/string.pat>
#include <type/leb128.pat>
#include <std/time.pat>
#include <std/core.pat>

using ul = type::uLEB128;
using int = u32;

struct Tab
{
    u128 GUID;
};

struct WindowState
{
    char HeaderIdentifier[2]; // NP
    ul SequenceNumber;
    ul BytesToCRC32;
    u8 Delim[1];
    ul NumberTabs;

    Tab Tabs[NumberTabs];
    
    ul ActiveTab;
    
    int CoordTopLeftX;
    int CoordTopLeftY;
    
    int CoordBottomRightX;
    int CoordBottomRightY;
    
    int WindowSizeWidth;
    int WindowSizeHeight;
    
    u8 Delim2[1];
    
    int CRC32;

    u8 SlackSpace[while(!std::mem::eof())];
};




// -- Declaration --

WindowState state @ 0x0;
