#pragma description Assassin's Creed: Unity's Decompressed .data file
#pragma author haru233

// Thanks to yretenai on GitHub for helping with the Block Allocator part

import std.core;
import std.mem;

struct Block_Allocator_Type0 {
    padding[4];
    u32 Class_ID;
    u32 Size;
};

struct Block_Allocator_Type1 {
    padding[4];
    u32 Type_ID;
    u32 Size;
};

struct Block_Allocator {
    u16 Version;
    
    if (Version == 0) {
        u32 Block_Allocator_Number;
        Block_Allocator_Type0 block_allocator_type0[Block_Allocator_Number];
    }
    
    else if (Version == 1) {
        u32 Block_Allocator_Number;
        Block_Allocator_Type1 block_allocator_type1_[Block_Allocator_Number];
    }
    
    else if (Version == 2) {
        bool Has_Secondary_Block_Allocator;
        u32 Main_Block_Allocator_Number;
        
        Block_Allocator_Type1 block_allocator_type1__[Main_Block_Allocator_Number];
        
        if (Has_Secondary_Block_Allocator) {
            u32 Secondary_Block_Allocator_Number;
            Block_Allocator_Type1 block_allocator_type1___[Secondary_Block_Allocator_Number+1];
        }
    }


};

struct File {
    u32 Object_Hash;
    u32 File_Size;
    u32 Filename_Length;
    
    if (File_Size > 0) {
        if (Filename_Length == 0) {
            bool HasBlockAllocator;
            
            if (HasBlockAllocator) {
                Block_Allocator block_allocator;
                u8 File_Data[File_Size];
            }
            
            else
                u8 File_Data[File_Size];
        }
        
        else {
            char Filename[Filename_Length];
            
            bool HasBlockAllocator;
           
            if (HasBlockAllocator) {
                Block_Allocator block_allocator;
                u8 File_Data[File_Size];
            }
            
            else
                u8 File_Data[File_Size];
               
            
        }
        
    }
    
    else
        continue;   
  


};
    
    
File file[while(!std::mem::eof())] @0x00;