#pragma description 7z File Format
#pragma MIME application/x-7z-compressed

import std.io; 
import std.mem; 
import std.math; 


enum Type:u8{ 
    startPosition = 0x00,       // Start position 
    sizeStartHeader = 0x20,  // Size of start Header       
}; 

enum TypeB:u48{ 
    sevenZipSignature = 0x1C27AFBC7A37,  // Defining 7z signature   
};   

struct StartHeader { 
    // File signature 
    u48 signature  [[color("FF0000")] ];  
    // Version format 
    u16 formatVersion [[color("00FF00")]];  
    // CRC start header 
    u32 crcOfTheFollowing20Bytes [[color("0000FF")]]; 
    // Relative offset of End Header 
    u64 relativeOffsetEndHeader [[color("FFFF00")]]; 
    // Length of End Header 
    u64 theLengthOfEndHeader [[color("00FFFF")]];  
    // CRC of End Ender 
    u32 crcOftheEndHeader [[color("FF00FF")]]; 
    // File size calculation 
    u64 fileSize = relativeOffsetEndHeader + theLengthOfEndHeader + Type::sizeStartHeader; 
    // Absolute offset calculation End Header 
    u64 startEndHeader = relativeOffsetEndHeader +  Type::sizeStartHeader; 
}; 

StartHeader startheader @ Type::startPosition; 
 
struct CompressedData { 
     // Start of compressed data     
     u8 startOfCompressedData[4] [[color("C0C0C0")]];          
}; 

CompressedData compresseddata @ Type::sizeStartHeader; 

  
struct EndHeader { 
    // Set padding to place End Header in right position 
    padding[startheader.relativeOffsetEndHeader]; 
    // Mark link to meta block 
    u8 linkToMetaBlock [[color("FF0000")]];     
    // Mark all End Header 
    char fullEndHeader[startheader.theLengthOfEndHeader] [[color("63954A")]];  
    // Detect LZMA signature 
    u64 lzmaSignaturePosition = std::mem::find_sequence_in_range(0, addressof(fullEndHeader), addressof(fullEndHeader) + sizeof(fullEndHeader), 0x23, 0x03, 0x01, 0x01, 0x05, 0x5D);    
                                                 
    // Mark positions if LZMA signature was detected 
    if(lzmaSignaturePosition != 0xFFFFFFFFFFFFFFFF){ 
        u48 lzmaSignature @ lzmaSignaturePosition [[color("0000FF")]];   
    } 
}; 

EndHeader endheader @ Type::sizeStartHeader; 
 
// Check 7z type 
if(startheader.signature ==  TypeB::sevenZipSignature){ 
    std::print("It is a 7z File Type");  
}else{ 
    std::print("The file is not 7z type");  
}  

std::print("Format Version {} ",startheader.formatVersion);  

// Version verification 
if(startheader.formatVersion ==  0x0400){ 
    std::print("Major Version 0x00 || 0 -  Minor Version 0x04 || 4");  
}    

// Verification of the compressed method is LZMA, Bzip2 or LZMA2 
if(compresseddata.startOfCompressedData[0] ==  Type::startPosition){  
     std::print("Compressed Method LZMA");    
}else if(compresseddata.startOfCompressedData[0] ==  0x42){  
    std::print("Compressed Method Bzip2");    
}else{  
    std::print("Compressed Method LZMA2");    
} 

  

std::print("CRC Start Header 0x{:X}",startheader.crcOfTheFollowing20Bytes);     

std::print("CRC End Header 0x{:X} ", startheader.crcOftheEndHeader);  

std::print("CompressedData length 0x{:X} || {} bytes ",startheader.relativeOffsetEndHeader, startheader.relativeOffsetEndHeader);  

std::print("Relative Offset of End Header 0x{:X} || {} bytes",startheader.relativeOffsetEndHeader, startheader.relativeOffsetEndHeader);  

std::print("Offset to start End Header 0x{:X} || {} bytes",startheader.startEndHeader,startheader.startEndHeader);  

std::print("End Header length 0x{:X} || {} bytes",startheader.theLengthOfEndHeader,startheader.theLengthOfEndHeader);  

std::print("File size 0x{:X} || {} bytes",startheader.fileSize, startheader.fileSize); 
