#pragma author Adiee5
#pragma description Atari 8-bit binary format (.xex)
#pragma endian little
#pragma magic [ FF FF ] @ 0

import std.mem;
import std.io;

u16 header @ 0;

if (header != 0xFFFF)
    std::error("Not a valid XEX file");
    
fn hex_dec_addr(u16 num){
    return std::format("0x{:04X} ({})", num, num);
};

struct block {
    u16 start [[comment("Address of the first byte"), format("hex_dec_addr")]];
    if (start == 0xFFFF) continue; //an unnecessary header to be ignored
    u16 end [[comment("Address of the last byte"), format("hex_dec_addr")]];
    
    // since 1 and 2 byte blocks sometimes have special meanings,
    // we make them regural variables instead of byte arrays, 
    // so that reading their values from the GUI is easier
    match (end-start){
        (0): u8 data;
        (1): u16 data [[format("hex_dec_addr")]];
        (_): u8 data[end-start+1];
    }
        
};

block data_blocks[while(!std::mem::eof())] @ 2 [[name("Data Blocks")]];