#pragma description Assassin's Creed: Unity's .forge archive file
#pragma MIME archives/forge

// author = haru233, many thanks to AxCut
// ImHex Hex Pattern File for Assassin's Creed: Unity's Compressed .data files

import std.core;

struct Forge_Header {
    char MAGIC[8];
    padding[1];
    u32 Version;
    u32 File_Data_Header_Offset;
};

struct File_Data_Header {
    u32 File_Count;
    padding[32];
    u64 File_Data_Header2_Offset;
};

struct File_Data_Header2 {
    u32 File_Count2;
    padding[4];
    u64 File_Table_Offset;
    padding[12];
    u32 File_Count3;
    u64 File_Name_Table_Offset;
    padding[8];
};


struct File_Table {
    u64 Raw_Data_Offset;
    u64 File_ID;
    u32 Raw_Data_Size;
};

struct File_Name_Table {
    u32 Raw_Data_Size;
    padding[40];
    char Filename[128];
    padding[20];
};


Forge_Header forge_header @0x00;

File_Data_Header file_data_header @(forge_header.File_Data_Header_Offset);

File_Data_Header2 file_data_header2 @(file_data_header.File_Data_Header2_Offset);

File_Table file_table[file_data_header.File_Count] @(file_data_header2.File_Table_Offset);

File_Name_Table file_name_table[file_data_header.File_Count] @(file_data_header2.File_Name_Table_Offset);


struct Raw_Data_Table {
    u64 i = std::core::array_index();
    u8 Raw_Data[file_table[i].Raw_Data_Size] @ file_table[i].Raw_Data_Offset;
};


Raw_Data_Table raw_data_table[file_data_header.File_Count] @0x00;