#pragma description Commodore BASIC

import std.io;
import std.mem;

bool in_quotes = false;

le u16 LoadAddress @0 [[color("ff0000")]];

fn formatll(u16 offset) {
    if (offset&0xff00 == 0)
        return "No next line";
    u16 fo = offset-LoadAddress+2;
    return std::format("Next line: ${:04X} (offset ${:04X})", offset, fo);
};

enum Token : u8 {
    END      = 0x80,
    FOR      = 0x81,
    NEXT     = 0x82,
    DATA     = 0x83,
    INPUT_   = 0x84,
    INPUT    = 0x85,
    DIM      = 0x86,
    READ     = 0x87,
    LET      = 0x88,
    GOTO     = 0x89,
    RUN      = 0x8a,
    IF       = 0x8b,
    RESTORE  = 0x8c,
    GOSUB    = 0x8d,
    RETURN   = 0x8e,
    REM      = 0x8f,
    STOP     = 0x90,
    ON       = 0x91,
    WAIT     = 0x92,
    LOAD     = 0x93,
    SAVE     = 0x94,
    VERIFY   = 0x95,
    DEF      = 0x96,
    POKE     = 0x97,
    PRINT_   = 0x98,
    PRINT    = 0x99,
    CONT     = 0x9a,
    LIST     = 0x9b,
    CLR      = 0x9c,
    CMD      = 0x9d,
    SYS      = 0x9e,
    OPEN     = 0x9f,
    CLOSE    = 0xa0,
    GET      = 0xa1,
    NEW      = 0xa2,
    TAB_     = 0xa3,
    TO       = 0xa4,
    FN       = 0xa5,
    SPC_     = 0xa6,
    THEN     = 0xa7,
    NOT      = 0xa8,
    STEP     = 0xa9,
    PLUS_    = 0xaa,
    MINUS_   = 0xab,
    TIMES_   = 0xac,
    DIVIDE_  = 0xad,
    POW_     = 0xae,
    AND      = 0xaf,
    OR       = 0xb0,
    GT_      = 0xb1,
    EQ_      = 0xb2,
    LT_      = 0xb3,
    SGN      = 0xb4,
    INT      = 0xb5,
    ABS      = 0xb6,
    USR      = 0xb7,
    FRE      = 0xb7,
    POS      = 0xb9,
    SQR      = 0xba,
    RND      = 0xbb,
    LOG      = 0xbc,
    EXP      = 0xbd,
    COS      = 0xbe,
    SIN      = 0xbf,
    TAN      = 0xc0,
    ATN      = 0xc1,
    PEEK     = 0xc2,
    LEN      = 0xc3,
    STR_     = 0xc4,
    VAL      = 0xc5,
    ASC      = 0xc6,
    CHR_     = 0xc7,
    LEFT_    = 0xc8,
    RIGHT_   = 0xc9,
    MID_     = 0xca,
    PI_      = 0xff
} [[format("formate")]];

// Can't seem to put attributes on enum members. Hack around it.
fn formate(Token t) {
    match (t) {
        (Token::INPUT_):  return "INPUT#"; // $84
        (Token::PRINT_):  return "PRINT#"; // $98
        (Token::TAB_):    return "TAB(";   // $a3
        (Token::SPC_):    return "SPC(";   // $a6
        (Token::PLUS_):   return "+";      // $aa
        (Token::MINUS_):  return "-";      // $ab
        (Token::TIMES_):  return "*";      // $ac
        (Token::DIVIDE_): return "/";      // $ad
        //(Token::POW_):    return "↑";      // $ae
        (Token::GT_):     return ">";      // $b1
        (Token::EQ_):     return "=";      // $b2
        (Token::LT_):     return "<";      // $b3
        (Token::STR_):    return "STR$";   // $c4
        (Token::CHR_):    return "CHR$";   // $c7
        (Token::LEFT_):   return "LEFT$";  // $c8
        (Token::RIGHT_):  return "RIGHT$"; // $c9
        (Token::MID_):    return "MID$";   // $ca
        //(Token::PI_):     return "π";      // $ff
    }

    return t;
};

fn NotZero() {
    u8 b = std::mem::read_unsigned($, 1);
    return b!=0;
};

fn IsToken() {
     u8 b = std::mem::read_unsigned($, 1);
     return b&0x80!=0;
};

fn IsPETSCII() {
    u8 b = std::mem::read_unsigned($, 1);
    if (b == '"')
        in_quotes = !in_quotes;
    return (b!=0) && (in_quotes || (b&0x80)==0);
};

struct LineSegment
{
    Token tokens[while(IsToken())] [[color("a040a0")]]; 
    char petscii[while(IsPETSCII())] [[color("a0a0a0")]]; 
};

struct Line
{
    in_quotes = false;

    u16 next [[color("8080ff"), format("formatll")]];
    if (next&0xff00 == 0)
        break;
    le u16 line_number [[color("00FF00")]];
    LineSegment contents[while(NotZero())];
    u8 eol [[color("00ffff")]];
};

Line Lines[65536] @ 2;