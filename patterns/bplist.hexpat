#pragma description TODO

import std.math;
import std.core;
import type.magic;
import type.time;

using CFBinaryPlistObject;

enum Marker : u8 {
    Null  = 0x00,
    False = 0x08,
    True = 0x09,
    Fill = 0x0F,
    Int = 0x10,
    Real = 0x20,
    Date = 0x30,
    Data = 0x40,
    ASCIIString = 0x50,
    Unicode16String = 0x60,
    UNK_0x70 = 0x70,
    UID = 0x80,
    UNK_0x90 = 0x90,
    Array = 0xA0,
    UNK_0xB0 = 0xB0,
    Set = 0xC0,
    Dict = 0xD0,
    UNK_0xE0 = 0xE0,
    UNK_0xF0 = 0xF0
};

fn get_marker_name(u8 marker) {    
    if (marker == Marker::Null){//    null	0000 0000
        return "Null ";
    }else if (marker == Marker::False){ //bool	0000 1000			// false
        return "False";
    }else if (marker == Marker::True){//bool	0000 1001			// true
        return "True";
    }else if (marker == Marker::Fill){ //fill	0000 1111			// fill byte  
        return "Fill";
    }else if (marker & 0xF0 == Marker::Int){ //int	0001 nnnn	...		// # of bytes is 2^nnnn, big-endian bytes
        return "Int";
    }else if (marker & 0xF0 == Marker:: Real){ //real	0010 nnnn	...		// # of bytes is 2^nnnn, big-endian bytes
        return "Real";
    }else if (marker == Marker::Date){ //date	0011 0011	...		// 8 byte float follows, big-endian bytes
        return "Date";
    }else if (marker & 0xF0 == Marker::Data){ //data	0100 nnnn	[int]	...	// nnnn is number of bytes unless 1111 then int count follows, followed by bytes
        return "Data";   
    }else if (marker & 0xF0 == Marker::ASCIIString){ //string	0101 nnnn	[int]	...	// ASCII string, nnnn is # of chars, else 1111 then int count, then bytes
        return "ASCIIString";
    }else if (marker & 0xF0 == Marker::Unicode16String){ //string	0110 nnnn	[int]	...	// Unicode string, nnnn is # of chars, else 1111 then int count, then big-endian 2-byte 
        return "Unicode16String";
    }else if (marker & 0xF0 == Marker::UNK_0x70){ //0111 xxxx			// unused
        return "UNK_0x70";
    }else if (marker & 0xF0 == Marker::UID){ //uid	1000 nnnn	...		// nnnn+1 is # of bytes
        return "UID";
    }else if (marker & 0xF0 == Marker::UNK_0x90){ // 1001 xxxx			// unused
        return "UNK_0x90";
    }else if (marker & 0xF0 == Marker::Array){ //array	1010 nnnn	[int]	objref*	// nnnn is count, unless '1111', then int count follows        
        return "Array";
    }else if (marker & 0xF0 == Marker::UNK_0xB0){ //1011 xxxx			// unused
        return "UNK_0xB0";
    }else if (marker & 0xF0 == Marker::Set){ //set	1100 nnnn	[int]	objref* // nnnn is count, unless '1111', then int count follows
        return "Set";
    }else if (marker & 0xF0 == Marker::Dict){ //dict	1101 nnnn	[int]	keyref* objref*	// nnnn is count, unless '1111', then int count follows	
        return "Dict";
    }else if (marker & 0xF0 == Marker::UNK_0xE0){ // 1110 xxxx			// unused
        return "UNK_0xE0";
    }else if (marker & 0xF0 == Marker::UNK_0xF0){  //1111 xxxx			// unused
        return "UNK_0xF0";
    }    
};

fn format_tag(u8 marker) {
    return std::format("{}", get_marker(marker));
};

fn coredata_to_date (double val){
    return type::impl::format_time_t(978307200 + val);
};

struct DictElement {  
    CFBinaryPlistObject key @ offsetTable[parent.objReference.key_refs[std::core::array_index()]].offset;
    CFBinaryPlistObject value @ offsetTable[parent.objReference.value_refs[std::core::array_index()]].offset;
};

struct ArrayElement {  
    CFBinaryPlistObject value @ offsetTable[parent.objReference.value_refs[std::core::array_index()]].offset;
};

struct ObjectReference{
    match(trailer.objectRefSize){
        (1): {
            be u8 key_refs[parent.ObjectLen.size];
            be u8 value_refs[parent.ObjectLen.size];
        }
        (2): {
            be u16 key_refs[parent.ObjectLen.size];
            be u16 value_refs[parent.ObjectLen.size];
        }
        (4): {
            be u32 key_refs[parent.ObjectLen.size];
            be u32 value_refs[parent.ObjectLen.size];
        }
        (8): {
            be u64 key_refs[parent.ObjectLen.size];
            be u64 value_refs[parent.ObjectLen.size];
        }
    }
};

struct ObjectReferenceArray{
    match(trailer.objectRefSize){
        (1): be u8 value_refs[parent.ObjectLen.size];
        (2): be u16 value_refs[parent.ObjectLen.size];
        (4): be u32 value_refs[parent.ObjectLen.size];
        (8): be u64 value_refs[parent.ObjectLen.size];
    }
};

struct ObjectLen{
    if (parent.marker_lsb != 0x0F){
        u8 size = parent.marker_lsb [[export]];
    }else{
        CFBinaryPlistObject obj;
        if (obj.marker & 0xF0 != Marker::Int){
            std::error(std::format("Expects a 'Int' marker. Got 0x{:x} marker, with value {}", obj.marker, obj.value));
        }

        u128 size = obj.value [[export]];
    }
};

struct CFBinaryPlistOffset{
    match (trailer.offsetIntSize){
        (1): be u8 offset;
        (2): be u16 offset;
        (4): be u32 offset;
        (8): be u64 offset;
    }
};

struct CFBinaryPlistObject{
    u8 marker [[format("get_marker_name")]];
    
    u8 marker_msb = marker & 0xF0;
    u8 marker_lsb  = marker & 0x0F;

    match (marker_msb){ 
        (0x0): {
                match (marker_lsb){
                    (Marker::Null): {
                        u8 value = 0x00 [[export]];
                    }
                    (Marker::False): { 
                        bool value = false [[export]];
                    }
                    (Marker::True): {
                        bool value = true [[export]];
                    }
                    (Marker::Fill): {  
                        //I think the correct implementation is to do nothing here. The marker will be used as padding (Fill) ???
                    }
                    (_): {
                        std::error("Detected unknown marker {}.", marker_msb);
                    }
                }
        }
        (Marker::Int): {
            be u8 size = std::math::pow(2, marker_lsb);     
            // in format version '00', 1, 2, and 4-byte integers have to be interpreted as unsigned,
            // whereas 8-byte integers are signed (and 16-byte when available)
            // negative 1, 2, 4-byte integers are always emitted as 8 bytes in format '00'
            // integers are not required to be in the most compact possible representation, but only the last 64 bits are significant currently
            // Source: https://opensource.apple.com/source/CF/CF-550/CFBinaryPList.c

            match (size) {
                (1): be u8 value;
                (2): be u16 value;
                (4): be u32 value;
                (8): be s64 value;
                (16): be s128 value;
                (_): std::error(std::format("Invalid size detected for 'Int' marker. Got size: {}.", size));
            }                    
        }
        (Marker::Real): {
            be u8 size = std::math::pow(2, marker_lsb); 
            match (size){
                (4): be float value;
                (8): be double value;
                (_): std::error(std::format("Invalid size detected for 'Real' marker. Got size: {}.", size));
            }
        }
        (Marker::Date): {
            be double value [[format("coredata_to_date")]];
        }
        (Marker::Data): {
            ObjectLen ObjectLen;
            u8 value[ObjectLen.size];      
        }
        (Marker::ASCIIString): {
            ObjectLen ObjectLen;
            char value[ObjectLen.size];
        }
        (Marker::Unicode16String): {
           ObjectLen ObjectLen;
           be char16 value[ObjectLen.size];
        }
        (Marker::UID): {
            //Not 100% sure if this is correct for UID. Need more testing
            u8 size = marker_lsb+1;
            match (size) {
                (1): be u8 value;
                (2): be u16 value;
                (4): be u32 value;
                (8): be u64 value;
                (16): be u128 value;
                (_): std::error(std::format("Invalid size detected for 'UID' marker. Got size: {}.", size));
            }      
        }
        (Marker::Set | Marker::Array): {
            ObjectLen ObjectLen;

            ObjectReferenceArray objReference;
            ArrayElement value[ObjectLen.size];
        }
        (Marker::Dict): {
            ObjectLen ObjectLen;
            
            ObjectReference objReference;
            DictElement value[ObjectLen.size];
        }
        (Marker::UNK_0x70 | Marker::UNK_0x90 | Marker::UNK_0xB0 | Marker::UNK_0xE0 | Marker::UNK_0xF0): {
            std::error(std::format("Got unused marker 0x{:x}", marker));
        }
        (_): {
            std::error(std::format("Got unknown marker 0x{:x}", marker));
        }    
    }
};

struct CFBinaryPlistHeader{
    type::Magic<"bplist"> magic;
    u16 version;
    if (version != 0x3030){
        std::error("Unsupported version detected. Only version 00 is supported (bplist00).");
    }
};

struct CFBinaryPlistTrailer {
    u8 unused[5];
    u8 sortVersion; 
    be u8 offsetIntSize;
    match (offsetIntSize){
        (1|2|4|8): {}
        (_): {std::error("Invalid offsetIntSize.");}
    }
    be u8 objectRefSize; 
    match (objectRefSize){
        (1|2|4|8): {}
        (_): {std::error("Invalid objectRefSize.");}
    }
    be u64 numObjects;
    be u64 topObject;
    be u64 offsetTableOffset;
};


CFBinaryPlistHeader header @ 0x00;
CFBinaryPlistTrailer trailer @ std::mem::size()-32;

CFBinaryPlistOffset offsetTable[trailer.numObjects] @ trailer.offsetTableOffset;
CFBinaryPlistObject objectTable  @ offsetTable[trailer.topObject].offset;