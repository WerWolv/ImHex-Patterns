#pragma author gluecia
#pragma description PopCap's proprietary Lua bytecode (.luc)
#pragma endian little
#pragma magic [ 1B 4C 75 61 56 ] @ 0x00;

// original credit: https://github.com/wxarmstrong/PopLua-Disassembler
// i used this code as a jumping off point for figuring out how the
// format works, though there is quite a bit of my own work here as well.

import std.io;
import std.sys;

using PLChunk;
using PLConst;
using PLLocal;
using PLOp;
using PLStr;
using cType;


struct PLHeader {
    char magic[5];
    padding[18];
                
    // *technically* this is a part of the first top level chunk, though
    // it is essentially just a part of the header since it only appears there.
   u32 filenameSize [[hidden]];
   char16 filename[filenameSize] [[name("Filename")]];
};


// LOCALS
fn fmtLocal(PLLocal l) {
    return l.name;
};

struct PLLocal {
    u32 nameLength [[hidden]];
    char16 name[nameLength] [[name("Local")]];
    u32 begin [[name("Begin")]];
    u32 end [[name("End")]];
} [[format("fmtLocal")]];


// CONSTANTS
// constant types
fn fmtCType(cType t) {
    match (t) {
        (cType::Nil): return "nil";
        (cType::Int): return "int";
        (cType::Float): return "float";
        (cType::Str): return "str";
        (_): return "unknown";
    }
};

enum cType : u8 {
    Nil,
    Float = 3,
    Int,
    Str
} [[format("fmtCType")]];

// lua strings
fn fmtStr(PLStr s) {
    return std::format("\"{}\"", s.val);
};


struct PLStr {
    u32 len [[hidden]];
    if (len > 0)
        char16 val[len];
} [[format("fmtStr"), sealed]];

// constants struct
fn fmtConst(PLConst c) {
    if (c.type == cType::Nil) {
        return c.type;
    } else {
        return std::format("{} ({})", c.val, c.type);
    }
};

struct PLConst {
    cType type;
    match (type) {
        (cType::Float): double val;
        (cType::Int): s32 val;
        (cType::Str): PLStr val;
        (cType::Nil): continue;
        (_): std::error("unknown cType given");
    }
} [[format("fmtConst"), sealed]];


// PROTOTYPES
struct PLPrototype {
    padding[4];
    PLChunk chunk;
} [[inline]];


// UPVALUES
struct PLUpvalue {
    u32 len [[hidden]];
    char name[len] [[name("Upvalue")]];
} [[inline]];


// OPERANDS
fn fmtPLOp(PLOp o) {
    return o.opcode;
};

// source: https://github.com/wxarmstrong/PopLua-Disassembler/blob/master/popOp.cpp
enum PLOpType : u8 {
    MOVE, LOADK, LOADBOOL, LOADNIL, GETUVPVAL,
    GETGLOBAL, GETTABLE, SETGLOBAL, SETUPVAL,
    SETTABLE, NEWTABLE, SELF, ADD, SUB, MUL,
    DIV, MOD, POW, UNM, NOT, SIZ, CONCAT, JMP,
    EQ, LT, LE, TEST, CALL, TAILCALL, RETURN,
    FORLOOP, TFORLOOP, TFORPREP, SETLIST,
    SETLISTO, CLOSE, ALTSELF, CONSTGLOBAL,
    CONSTTABLE, DEFGLOBAL, DEFTABLE,
    SETSELFORGLOBAL, GETSELFORGLOBAL,
    SELFORGLOBAL, CALLSELFORGLOBAL,
    TAILCALLSELFORGLOBAL, INT, BREAK,
    CLOSURE
};

// this is for a different version of lua and its bytecode, but helped a LOT
// https://poga.github.io/lua53-notes/bytecode.html
struct PLOp {
    u32 raw [[hidden]];
    PLOpType opcode = raw & 0x3F [[name("Opcode"), hidden, export]];
    u32 rawOperands = raw >> 6;
    u8 opA = rawOperands & 0xFF [[name("Operand A"), export]];
    
    match(opcode) {
        (PLOpType::LOADK | PLOpType::CLOSURE): u32 Bx = (rawOperands >> 8) [[name("Operand Bx"), export]];
        // 131071 is the bias for sBx to make it signed, formed from (2^18 - 1) >> 1
        // where 2^18 - 1 is the maximum value for an 18 bit number
        (PLOpType::JMP | PLOpType::FORLOOP | PLOpType::TFORLOOP): s32 opSBx = (rawOperands >> 8) - 131071 [[name("Operand sBx"), comment("Signed displacement added to the PC."), export]];
        (_): {
            u16 opB = (rawOperands >> 8) & 0xFF01 [[name("Operand B"), export]];
            u16 opC = (rawOperands >> 17) & 0xFF01 [[name("Operand C"), export]];
        }
    }
} [[format("fmtPLOp")]];

// CHUNKS
struct PLChunk {
    char intro[0xC] [[name("Chunk Intro"), comment("Holds information on the function, but the format is unknown.")]];

    u32 sizecode [[name("Instructions Count")]];
    u32 linesArray[sizecode] [[name("Line Numbers"), comment("The line numbers for the given operations, this should be interpreted with the operations array.")]];
    
    u32 sizelocvars [[name("Locals Count")]];
    PLLocal localsArray[sizelocvars] [[name("Locals")]];
    
    u32 sizeupvalues [[name("Upvalues Count")]];
    PLUpvalue upvalsArray[sizeupvalues] [[name("Upvalues")]];
    
    u32 sizek [[name("Constants Count")]];
    PLConst constsArray[sizek] [[name("Constants")]];
    
    u32 sizep [[name("Prototype Count")]];
    PLPrototype protoArray[sizep] [[name("Prototypes")]];
    
    u32 sizecodeVerify [[hidden]];
    std::assert(sizecode == sizecodeVerify, std::format("sizecode ({}) did not match sizecodeVerify ({})!", sizecode, sizecodeVerify));
    
    PLOp opsArray[sizecode] [[name("Instructions"), comment("The raw bytes for operations, should be interpreted with the line numbers array.")]];
};

PLHeader Header @ 0x0;
PLChunk Body @ $;