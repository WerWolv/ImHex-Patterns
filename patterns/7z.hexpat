#include <std/io.pat>
#include <std/mem.pat>
#include <std/math.pat>

enum Type:u8{
    startPosition = 0x00,
    sizeStartHeader = 0x20,      
};

enum TypeB:u48{
    sevenZipSignature = 0x1C27AFBC7A37,  
};

struct StartHeader {

    u48 signature  [[color("FF0000")] ]; 
    
    u16 formatVersion [[color("00FF00")]]; 
    
    u32 crcOfTheFollowing20Bytes [[color("0000FF")]];
    
    u64 relativeOffsetEndHeader [[color("FFFF00")]];
    
    u64 theLengthOfEndHeader [[color("00FFFF")]]; 
    
    u32 crcOftheEndHeader [[color("FF00FF")]];
    
    u64 fileSize = relativeOffsetEndHeader + theLengthOfEndHeader + Type::sizeStartHeader;
  
    u64 startEndHeader = relativeOffsetEndHeader +  Type::sizeStartHeader;
       
};


StartHeader startheader @ Type::startPosition;

struct CompressedData {
     u8 startOfCompressedData[4] [[color("C0C0C0")]];         
};

CompressedData compresseddata @ Type::sizeStartHeader;

struct EndHeader {

    padding[startheader.relativeOffsetEndHeader];
    
    u8 linkToMetaBlock [[color("FF0000")]];    
    
    char fullEndHeader[startheader.theLengthOfEndHeader] [[color("63954A")]]; 
    
    u64 lzmaSignaturePosition = std::mem::find_sequence_in_range(0, addressof(fullEndHeader), addressof(fullEndHeader) + sizeof(fullEndHeader), 0x23, 0x03, 0x01, 0x01, 0x05, 0x5D);                                                   
    
    if(lzmaSignaturePosition != 0xFFFFFFFFFFFFFFFF){

        u48 lzmaSignature @ lzmaSignaturePosition [[color("0000FF")]];  
    }
          
};

EndHeader endheader @ Type::sizeStartHeader;

        
if(startheader.signature ==  TypeB::sevenZipSignature){
    std::print("It is a 7z File Type"); 
} 

std::print("Format Version {} ",startheader.formatVersion); 

if(startheader.formatVersion ==  0x0400){
    std::print("Major Version 0x00 || 0 -  Minor Version 0x04 || 4");  
}   

std::print("CRC Start Header 0x{:X}",startheader.crcOfTheFollowing20Bytes);    

std::print("CRC End Header 0x{:X} ", startheader.crcOftheEndHeader); 
 
std::print("CompressedData length 0x{:X} || {} bytes ",startheader.relativeOffsetEndHeader, startheader.relativeOffsetEndHeader); 

std::print("Relative Offset of End Header 0x{:X} || {} bytes",startheader.relativeOffsetEndHeader, startheader.relativeOffsetEndHeader); 

std::print("Offset to start End Header 0x{:X} || {} bytes",startheader.startEndHeader,startheader.startEndHeader); 

std::print("End Header length 0x{:X} || {} bytes",startheader.theLengthOfEndHeader,startheader.theLengthOfEndHeader); 

std::print("File size 0x{:X} || {} bytes",startheader.fileSize, startheader.fileSize); 

if(compresseddata.startOfCompressedData[0] ==  Type::startPosition){
    std::print("Compressed Method LZMA");   
}else{
    std::print("Compressed Method LZMA2");    
}
