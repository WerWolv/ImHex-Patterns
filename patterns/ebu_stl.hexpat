#pragma description EBU STL Subtitle File Format (EBU Tech 3264)
#pragma endian big
#pragma MIME application/x-ebu-stl

import std.io;
import std.mem;

// EBU STL (EBU Tech 3264) - Subtitling data exchange format
// Used for broadcast subtitle distribution

// GSI Block - General Subtitle Information (1024 bytes)
struct GSI_Block {
    char cpn[3]     [[name("Code Page Number"), color("4A90E2")]];
    char dfc[8]     [[name("Disk Format Code"), color("4A90E2")]];
    char dsc        [[name("Display Standard Code"), color("4A90E2")]];
    char cct[2]     [[name("Character Code Table"), color("4A90E2")]];
    char lc[2]      [[name("Language Code"), color("4A90E2")]];
    
    char opt[32]    [[name("Original Programme Title"), color("50C878")]];
    char oet[32]    [[name("Original Episode Title"), color("50C878")]];
    char tpt[32]    [[name("Translated Programme Title"), color("50C878")]];
    char tet[32]    [[name("Translated Episode Title"), color("50C878")]];
    
    char tn[32]     [[name("Translator's Name"), color("9B59B6")]];
    char tcd[32]    [[name("Translator's Contact Details"), color("9B59B6")]];
    
    char slr[16]    [[name("Subtitle List Reference Code"), color("E67E22")]];
    
    char cd[6]      [[name("Creation Date"), color("E74C3C")]];
    char rd[6]      [[name("Revision Date"), color("E74C3C")]];
    char rn[2]      [[name("Revision Number"), color("E74C3C")]];
    
    char tnb[5]     [[name("Total Number of TTI Blocks"), color("F39C12")]];
    char tns[5]     [[name("Total Number of Subtitles"), color("F39C12")]];
    char tng[3]     [[name("Total Number of Subtitle Groups"), color("F39C12")]];
    
    char mnc[2]     [[name("Max Characters per Row"), color("1ABC9C")]];
    char mnr[2]     [[name("Max Number of Rows"), color("1ABC9C")]];
    
    char tcs        [[name("Time Code Status"), color("3498DB")]];
    char tcp[8]     [[name("Time Code: Start-of-Programme"), color("3498DB")]];
    char tcf[8]     [[name("Time Code: First In-Cue"), color("3498DB")]];
    
    u8 tnd          [[name("Total Number of Disks"), color("95A5A6")]];
    u8 dsn          [[name("Disk Sequence Number"), color("95A5A6")]];
    
    char co[3]      [[name("Country of Origin"), color("E91E63")]];
    
    char pub[32]    [[name("Publisher"), color("8E44AD")]];
    char en[32]     [[name("Editor's Name"), color("8E44AD")]];
    char ecd[32]    [[name("Editor's Contact Details"), color("8E44AD")]];
    
    u8 spare[75]    [[name("Spare Bytes"), color("34495E")]];
    u8 uda[576]     [[name("User-Defined Area"), color("7F8C8D")]];
} [[static]];

// TTI Block - Text and Timing Information (128 bytes)
struct TTI_Block {
    u8 sgn          [[name("Subtitle Group Number"), color("FF6B6B")]];
    u16 sn          [[name("Subtitle Number"), color("FF6B6B")]];
    u8 ebn          [[name("Extension Block Number"), color("FF6B6B")]];
    u8 cs           [[name("Cumulative Status"), color("FF6B6B")]];
    
    u8 tci_hours    [[name("Time Code In: Hours"), color("4ECDC4")]];
    u8 tci_mins     [[name("Time Code In: Minutes"), color("4ECDC4")]];
    u8 tci_secs     [[name("Time Code In: Seconds"), color("4ECDC4")]];
    u8 tci_frames   [[name("Time Code In: Frames"), color("4ECDC4")]];
    
    u8 tco_hours    [[name("Time Code Out: Hours"), color("44AF69")]];
    u8 tco_mins     [[name("Time Code Out: Minutes"), color("44AF69")]];
    u8 tco_secs     [[name("Time Code Out: Seconds"), color("44AF69")]];
    u8 tco_frames   [[name("Time Code Out: Frames"), color("44AF69")]];
    
    u8 vp           [[name("Vertical Position"), color("F7B801")]];
    u8 jc           [[name("Justification Code"), color("F7B801")]];
    u8 cf           [[name("Comment Flag"), color("F7B801")]];
    
    u8 tf[112]      [[name("Text Field"), color("C77DFF")]];
};

struct EBU_STL {
    GSI_Block gsi [[name("General Subtitle Information")]];
    TTI_Block tti[while(!std::mem::eof())] [[name("Text and Timing Information")]];
};

EBU_STL stl_file @ 0x00;

// Display file summary
std::print("=== EBU STL File ===");
std::print("Created: {}", stl_file.gsi.cd);
std::print("Format: {}", stl_file.gsi.dfc);
std::print("Language: {}", stl_file.gsi.lc);
std::print("Country: {}", stl_file.gsi.co);
std::print("Subtitles: {}", stl_file.gsi.tns);
std::print("Max Characters Per Row: {}", stl_file.gsi.mnc);
