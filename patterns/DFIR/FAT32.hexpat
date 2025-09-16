#pragma author Formula Zero One Technologies
#pragma description FAT32 File System (FAT32_v2.0)
#pragma MIME application/x-ima
#pragma endian little

// -----------------------------------------------------------------------------
// CREDIT
// -----------------------------------------------------------------------------
// OG AUTHOR: WerWolv
// OG DESC: fs/fat32.hexpat_v1.0
// -----------------------------------------------------------------------------
// NOTES FOR v2.0               ** GLOBALS NEED YOUR INPUT **
// -----------------------------------------------------------------------------
// Imported by DISK_PARSER.hexpat
// Added section separators for organization
// Added recursive parsing for Root Dir and a next level
// Added D/T conversions
// Show filenames on hover
// Added comments to DFIR fields of interest
// Changed pattern output naming/structure.
// Parse FAT1/FAT2
// Show SFN <-> Starting Cluster Relation Overlay 
// -----------------------------------------------------------------------------
// TODO
// -----------------------------------------------------------------------------
// Parse all SFN/LFN entries, not just Root + 1
// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import std.core;
import std.io;
import std.mem;
import std.time;
import std.string;
import type.time;

// -----------------------------------------------------------------------------
// FORWARD DECS/GLOBALS
// -----------------------------------------------------------------------------
// 		*** ATTENTION ***	
// SET MAXIMUM NUMBER OF 4 BYTE CHUNKS TO PARSE FROM FAT1
// DEFAULT IS 4096
// Choose a value greater than 1 and less than 65536 OR increase the Array size limit with "#define... "

// -------**************---vvvv--- |
const u64 MAX_FAT_CHUNKS = 4096;
// -------**************---^^^^--- |

// 		*** ATTENTION ***	
// SET MAXIMUM NUMBER OF SFN = STARTING CLUSTER TO PROCESS
// DEFAULT IS 100 (2 LEVELS DEEP | ROOT DIR + 1)
// Choose a value greater than 1 and less than 65536 OR increase the Array size limit with "#define... "

// ---**************---************---vvv--- |
const u64 MAX_SFN_CLUSTER_RELATIONS = 100;
// ---**************---************---^^^--- |

// ---*******---*******----vvvv--- |
const bool VOLUME_REPORT = true;
// ---*******---*******----^^^^--- |

u64 bytesPerCluster = 0;
u64 rootDirSectors = 0;
u64 firstDataSector = 0;
u64 dataRegionStart = 0;
u64 sfn_count = 0;
u64 sfn_del_count = 0;
u64 lfn_count = 0;
u64 lfn_del_count = 0;
u64 start_index = 0;
u64 root_dir_start = 0;
u64 allocated_file_count = 0;

u64 VBR_OFFSET = 0;
u64 FAT1_start_offset = 0;
u64 FAT2_start_offset = 0;
u64 FAT_ClusterHeap_Count = 0;

u64 abs_FAT1_start_offset = 0;
u64 abs_FAT2_start_offset = 0;
u64 abs_rootDirStart_offset = 0;

// -----------------------------------------------------------------------------
// FILE ALLOCATION TABLE RELATED
// -----------------------------------------------------------------------------
//   V		V		V		V		V		V		V		V		V		V
// -----------------------------------------------------------------------------

// ------------------------------
// SFN <-> CLUSTER OVERLAY 
// ------------------------------
struct INFO_Overlay {
    u64 index = std::core::array_index(); 
    u64 start_location = FAT1_start_offset + 8 + (index * 4);
    u32 current_cluster = 2 + index;
    str filename = overlay_func_name(current_cluster);

    if (filename != "") {
    	char hover_label[4] @ start_location [[
        	name(std::format(
            	"SFN: {} | CLUSTER {}",
            	filename,
            	current_cluster
        ))]];
  	}
} [[inline]];

fn overlay_func_name(u32 cluster_num) {
    str fname = "";
    str ext = "";
    str combo = "";

    // Loop through all ROOT_DIR_ENTRIES
    for (u32 i = 0, i < std::core::member_count(ROOT_DIR_ENTRIES), i = i + 1) {

        // Check SFN_ALIAS and SFN_ENTRY in root entries
        if (std::core::has_member(ROOT_DIR_ENTRIES[i], "SFN_ALIAS")) {
            if (ROOT_DIR_ENTRIES[i].SFN_ALIAS.first_cluster == cluster_num) {
                combo = std::format("{}.{}", 
                	ROOT_DIR_ENTRIES[i].SFN_ALIAS.fileName,
                    ROOT_DIR_ENTRIES[i].SFN_ALIAS.extension);
                return combo;
            }
        } else if (std::core::has_member(ROOT_DIR_ENTRIES[i], "SFN_ENTRY")) {
            if (ROOT_DIR_ENTRIES[i].SFN_ENTRY.first_cluster == cluster_num) {
                combo = std::format("{}.{}", 
                	ROOT_DIR_ENTRIES[i].SFN_ENTRY.fileName,
                    ROOT_DIR_ENTRIES[i].SFN_ENTRY.extension);
                return combo;
            }
        }

        // Loop through all SUB_DIR_INDEX arrays for this root entry
        if (std::core::has_member(ROOT_DIR_ENTRIES[i], "SUB_DIR_INDEX")) {
            for (u32 j = 0, j < std::core::member_count(ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX), j = j + 1) {

                if (std::core::has_member(ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j], "SFN_ALIAS")) {
                    if (ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ALIAS.first_cluster == cluster_num) {
                        combo = std::format("{}.{}", 
                        	ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ALIAS.fileName,
                            ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ALIAS.extension);
                        return combo;
                    }

                } else if (std::core::has_member(ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j], "SFN_ENTRY")) {
                    if (ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ENTRY.first_cluster == cluster_num) {
                        combo = std::format("{}.{}", 
                        	ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ENTRY.fileName,
                            ROOT_DIR_ENTRIES[i].SUB_DIR_INDEX[j].SFN_ENTRY.extension);
                        return combo;
                    }
                }
            }
        }
    }
    return ""; // no match found
};

// -----------------------------------------------------------------------------
// FAT32 FILE ALLOCATION TABLE (FAT) PARSER
// -----------------------------------------------------------------------------

const u32 CLUSTER_SIZE_BYTES = 4;    // Each FAT32 entry = 4 bytes
const u32 FAT32_EOF = 0x0FFFFFFF;    // End-of-file marker
const u32 FAT32_BAD = 0x0FFFFFF7;    // Bad cluster marker
const u32 FIRST_ALLOC_CLUSTER = 2;   // First usable cluster after reserved

enum FAT_Flags : u32 {
	UNALLOCATED				= 0x00000000,
	END_OF_FILE				= 0x0FFFFFFF,		// L.END
	BAD_CLUSTER				= 0xFFFFFFF7,		// L.END
	//POINTER 				= Num >= 1			// INFO
};

union FAT_Union {
	u32 DECIMAL	[[hidden]];
    FAT_Flags FAT_FLAG;
};

// ------------------------------
// Helper function for pointer label
// ------------------------------
fn cluster_label(u32 val) {
    if (val == FAT_Flags::UNALLOCATED)
        return "UNALLOCATED";
    if (val == FAT_Flags::BAD_CLUSTER)
        return "BAD";
    if (val >= 0x0FFFFFF8)
        return "EOF";
    return std::format("{}", val);
};

// ------------------------------
// FAT1/FAT2 HEAPS/CHAINS
// ------------------------------
struct FAT_Entry {
	FAT_Union FAT [[inline]];

    u32 cluster_num  = (FIRST_ALLOC_CLUSTER) + (std::core::array_index());
    	
    u32 next_cluster = FAT.DECIMAL & 0x0FFFFFFF;
    
    char hover_label[4] @ $ - 4 [[
        name(std::format(
            "Cluster: {} → {}",
            cluster_num,
            cluster_label(next_cluster)
        ))
    ]];
    
    bool is_eof      = next_cluster >= 0x0FFFFFF8;
    bool is_bad      = next_cluster == FAT32_BAD;
    bool is_free     = next_cluster == 0;

    if (is_eof) {
    	allocated_file_count += 1;
    }
} [[name(format_fat_entry(FAT.DECIMAL, std::core::array_index(), FIRST_ALLOC_CLUSTER))]];

// ------------------------------
// FAT FORMATTER FUNC
// ------------------------------
fn format_fat_entry(u32 raw_value, u32 cluster_index, u32 first_alloc_cluster) {
    u32 next_cluster = raw_value & 0x0FFFFFFF;

    str next_label;
    
    if (next_cluster == 0)
        next_label = "UNALLOCATED";
    
    else if (next_cluster == FAT32_BAD)
        next_label = "BAD";
    
    else if (next_cluster == 0x0FFFFFFF)
        next_label = "EOF";
    
    else
        next_label = std::format("{}", next_cluster);

    u32 logical_cluster = first_alloc_cluster + cluster_index;

    if (next_label == "UNALLOCATED" || next_label == "BAD" || next_label == "EOF")
        return std::format("Cluster {}: {}", logical_cluster, next_label);
    else
        return std::format("Cluster {} → {}", logical_cluster, next_label);
};

// ------------------------------
// MEDIA DESCRIPTOR HELPER
// ------------------------------
enum Media_Descriptor : u8 {
	SINGLE_SIDE_FLOPPY		= 0xF0,
	DOUBLE_SIDE_FLOPPY		= 0xF9,
	HARD_DISK_DRIVE			= 0xF8,
};

// ------------------------------
// FAT1/FAT2 HEADER PARSER
// ------------------------------
struct FAT_Header {
	Media_Descriptor mediaDescriptor		[[comment("0xF8=FIXED DISK | 0xF0=REMOVABLE")]];;
	u8 FAT32_FAT_HEADER[7]					[[comment("8 BYTES TOTAL: 4 BYTES REPRESENT PSUEDO CLUSTER 0 (SYSTEM)  | 4 BYTES REPRESENT PSUEDO CLUSTER 1 (SYSTEM)(EOF)")]];
    char root_dir_label[4] @ $ [[
    	name(std::format(
    		"ROOT_DIRECTORY"
    	))
    ]];			
											// WHICH IS WHY THE ROOT DIRECTORY (FIRST DATA AREA ITEM) STARTS IN CLUSTER 2
};

// -----------------------------------------------------------------------------
// ROOT DIRECTORY RELATED
// -----------------------------------------------------------------------------
//   V		V		V		V		V		V		V		V		V		V
// -----------------------------------------------------------------------------
// ------------------------------
// ACTIVE LFN SEQUENCE NUMBER BITFIELD
// * EXCEPT DELETED ENTRIES - 0xE5 *
// ------------------------------
bitfield LFN_Sequence {
    padding	    	: 1;
    IS_LAST_ENTRY 	: 1 					[[name("IS_LAST_ENTRY: [0=NO | 1=YES] ==")]];
	padding			: 1;
    LFN_SEQ_NUM   	: 5;
} [[bitfield_order(
    	std::core::BitfieldOrder::MostToLeastSignificant, 8)]];

// ------------------------------
// DIRECTORY ENTRY STATUS/SEQUENCE HELPERS
// ------------------------------
enum Entry_Status : u8 {
	EMPTY_ENTRY					= 0x00,
	DOT_ENTRY 					= 0x2E,
	DELETED_ENTRY 				= 0xE5,					

	ACTIVE_1ST_ENTRY			= 0x01,
	ACTIVE_2ND_ENTRY			= 0x02,
	ACTIVE_3RD_ENTRY			= 0x03,
	ACTIVE_4TH_ENTRY			= 0x04,
	ACTIVE_5TH_ENTRY			= 0x05,
	ACTIVE_6TH_ENTRY			= 0x06,
	ACTIVE_7TH_ENTRY			= 0x07,
	ACTIVE_8TH_ENTRY			= 0x08,
	ACTIVE_9TH_ENTRY			= 0x09,
	ACTIVE_10TH_ENTRY			= 0x0A,
	ACTIVE_11TH_ENTRY			= 0x0B,
	ACTIVE_12TH_ENTRY			= 0x0C,
	ACTIVE_13TH_ENTRY			= 0x0D,
	ACTIVE_14TH_ENTRY			= 0x0E,
	ACTIVE_15TH_ENTRY			= 0x0F,
	ACTIVE_16TH_ENTRY			= 0x10,
	ACTIVE_17TH_ENTRY			= 0x11,
	ACTIVE_18TH_ENTRY			= 0x12,
	ACTIVE_19TH_ENTRY			= 0x13,
	ACTIVE_20TH_ENTRY			= 0x14,
	ACTIVE_1ST_ENTRY_LAST		= 0x41,
	ACTIVE_2ND_ENTRY_LAST		= 0x42,
	ACTIVE_3RD_ENTRY_LAST		= 0x43,
	ACTIVE_4TH_ENTRY_LAST		= 0x44,
	ACTIVE_5TH_ENTRY_LAST		= 0x45,
	ACTIVE_6TH_ENTRY_LAST		= 0x46,
	ACTIVE_7TH_ENTRY_LAST		= 0x47,
	ACTIVE_8TH_ENTRY_LAST		= 0x48,
	ACTIVE_9TH_ENTRY_LAST		= 0x49,
	ACTIVE_10TH_ENTRY_LAST		= 0x4A,
	ACTIVE_11TH_ENTRY_LAST		= 0x4B,
	ACTIVE_12TH_ENTRY_LAST		= 0x4C,
	ACTIVE_13TH_ENTRY_LAST		= 0x4D,
	ACTIVE_14TH_ENTRY_LAST		= 0x4E,
	ACTIVE_15TH_ENTRY_LAST		= 0x4F,
	ACTIVE_16TH_ENTRY_LAST		= 0x50,
	ACTIVE_17TH_ENTRY_LAST		= 0x51,
	ACTIVE_18TH_ENTRY_LAST		= 0x52,
	ACTIVE_19TH_ENTRY_LAST		= 0x53,
	ACTIVE_20TH_ENTRY_LAST		= 0x54,
};

// ------------------------------
// HELPER FOR LFN FIRST BYTE
// ------------------------------
union LFNEntry_FirstByte {
    Entry_Status status;
    LFN_Sequence seq_num;
};

// ------------------------------
// SFN ATTRIBUTE HELPER
// ------------------------------
bitfield Attributes {
	readOnly : 1;
	hidden : 1;
	systemFile : 1;
	volumeLabel : 1;
	subDirectory : 1;
	archive : 1;
	padding : 2;
} [[bitfield_order(
		std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

// ------------------------------
// ROOT DIRECTORY ENTRY FUNC
// ------------------------------
fn dir_entry_marker(u64 abs_off) {
    u8 first @ abs_off;
    return first;
};

// ------------------------------
// ROOT DIRECTORY ENTRY FUNC
// ------------------------------
fn dir_entry_attr(u64 abs_off) {
    u8 attr @ abs_off + 0x0B;
    return attr;
};

// ------------------------------
// DATES AND TIMES FUNC
// ------------------------------
fn format_dos_time_field(std::time::DOSTime t) {
    return std::time::format_dos_time(t, "{:02}:{:02}:{:02}");
};

fn format_dos_date_field(std::time::DOSDate d) {
    return std::time::format_dos_date(d, "{1:02}-{0:02}-{2:04}");
};

// ------------------------------
// SHORT FILE NAME ALIAS PARSER
// ------------------------------
struct SFN_Entry_Alias {
	char fileName[8]						[[name("SFN"), comment("Short File Name (8dot3)")]]; 
	char extension[3]						[[name("EXT"), comment("File Extension (8dot3)")]];
	Attributes attributes					[[name("RASH ATTR"), comment("Read-Only | Archive | System | Hidden | SubDir...")]];
	u8 reserved								[[comment("Zeros")]];
	u8 milliseconds							[[comment("Add to Times for Refinement")]];
    std::time::DOSTime Created_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Created_Date 		[[format("format_dos_date_field")]];
    std::time::DOSDate Accessed_Date 		[[format("format_dos_date_field")]];
    u16 Cluster_Hi							[[comment("High Cluster if Needed")]];
    std::time::DOSTime Modified_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Modified_Date 		[[format("format_dos_date_field")]];
	u16 Cluster_Lo							[[comment("Starting Cluster or Combine with Cluster_Hi")]];
	u32 fileSize							[[name("FILE_SIZE"), comment("File Size in Bytes")]];
	
	u32 first_cluster = (Cluster_Hi << 16) | Cluster_Lo;

	u8 FILE_DATA[fileSize] @ dataRegionStart + (first_cluster -2) * bytesPerCluster	[[comment("Pointer to the Files Content")]];
	
	sfn_count += 1;
	
	if (fileName[0] == 0xE5) {
		sfn_del_count += 1;
	}
};

// ------------------------------
// LOOOONG FILE NAME PARSER
// ------------------------------
struct LFN_Entry {
    u64 curr_first_byte = $;
    u8 curr_attr = dir_entry_attr(curr_first_byte);
    
    LFNEntry_FirstByte SeqByte				[[name("SEQUENCE_NUM"), comment("0x01-0x20 | Add 0x40 to Last LFN Entry")]];
    char16 NAME_1[5]						[[comment("First 5 Characters of LFN")]];                               
    Attributes attributes					[[name("LFN_ATTR"), comment("0x0F = LFN")]];
    padding[1]								[[comment("Zeros")]];   
    u8 nameChecksum							[[name("Checksum"), comment("Checksum Calculated on SFN_ALIAS")]];  
    char16 NAME_2[6]						[[comment("Next 6 Characters of LFN")]];                               
    padding[2]								[[comment("Zeros")]];   
    char16 NAME_3[2]						[[comment("Next 2 Characters of LFN")]];                               
	
	// ATTEMPT TO CLEANUP UNICODE LFN... DOES NOT ACCOUNT FOR MULTI LFN ENTRIES
	if (curr_attr == 0x0F) {
		char display_name[32] @ $ - 32 [[
    		name(
        		(NAME_1[0] >= 0x20 && NAME_1[0] <= 0x7E ? std::string::to_string(NAME_1[0]) : "") +
        		(NAME_1[1] >= 0x20 && NAME_1[1] <= 0x7E ? std::string::to_string(NAME_1[1]) : "") +
        		(NAME_1[2] >= 0x20 && NAME_1[2] <= 0x7E ? std::string::to_string(NAME_1[2]) : "") +
        		(NAME_1[3] >= 0x20 && NAME_1[3] <= 0x7E ? std::string::to_string(NAME_1[3]) : "") +
        		(NAME_1[4] >= 0x20 && NAME_1[4] <= 0x7E ? std::string::to_string(NAME_1[4]) : "") +

        		(NAME_2[0] >= 0x20 && NAME_2[0] <= 0x7E ? std::string::to_string(NAME_2[0]) : "") +
        		(NAME_2[1] >= 0x20 && NAME_2[1] <= 0x7E ? std::string::to_string(NAME_2[1]) : "") +
        		(NAME_2[2] >= 0x20 && NAME_2[2] <= 0x7E ? std::string::to_string(NAME_2[2]) : "") +
        		(NAME_2[3] >= 0x20 && NAME_2[3] <= 0x7E ? std::string::to_string(NAME_2[3]) : "") +
        		(NAME_2[4] >= 0x20 && NAME_2[4] <= 0x7E ? std::string::to_string(NAME_2[4]) : "") +
        		(NAME_2[5] >= 0x20 && NAME_2[5] <= 0x7E ? std::string::to_string(NAME_2[5]) : "") +

        		(NAME_3[0] >= 0x20 && NAME_3[0] <= 0x7E ? std::string::to_string(NAME_3[0]) : "") +
        		(NAME_3[1] >= 0x20 && NAME_3[1] <= 0x7E ? std::string::to_string(NAME_3[1]) : "")
    		)
		]];
	}
    lfn_count += 1;
    
    if (SeqByte.status == Entry_Status::DELETED_ENTRY) {
        lfn_del_count += 1;
    }   
};

// ------------------------------
// SHORT FILE NAME PARSER
// ------------------------------
struct SFN_Entry {
	char fileName[8]						[[name("SFN"), comment("Short File Name (8dot3)")]]; 
	char extension[3]						[[name("EXT"), comment("File Extension (8dot3)")]];
	Attributes attributes					[[name("RASH ATTR"), comment("Read-Only | Archive | System | Hidden | SubDir...")]];
	u8 reserved								[[comment("Zeros")]];
	u8 milliseconds							[[comment("Add to Times for Refinement")]];
    std::time::DOSTime Created_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Created_Date 		[[format("format_dos_date_field")]];
    std::time::DOSDate Accessed_Date 		[[format("format_dos_date_field")]];
    u16 Cluster_Hi							[[comment("High Cluster if Needed")]];
    std::time::DOSTime Modified_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Modified_Date 		[[format("format_dos_date_field")]];
	u16 Cluster_Lo							[[comment("Starting Cluster or Combine with Cluster_Hi")]];
	u32 fileSize							[[name("FILE_SIZE"), comment("File Size in Bytes")]];
	
	u32 first_cluster = (Cluster_Hi << 16) | Cluster_Lo;

	u8 FILE_DATA[fileSize] @ dataRegionStart + (first_cluster -2) * bytesPerCluster	[[comment("Pointer to the File Content")]];
	
	sfn_count += 1;
	
	if (fileName[0] == 0xE5) {
		sfn_del_count += 1;
	}
};

// ------------------------------
// SUBDIRECTORY PARSER | LEVEL 2
// ------------------------------
struct SubDirParser { 
	u8 first = dir_entry_marker($); 
	u8 attr = dir_entry_attr($); 

    u64 next_first_byte = $ + 32;
    u8 next_attr = dir_entry_attr(next_first_byte);		// current offset plus 12 bytes (offset 0x0B of entry) 
	
	if (first != 0x00 && attr == 0x0F) { 
		LFN_Entry LFN_ENTRY;
		
		if (next_first_byte != 0x00 && next_first_byte != 0xE5 && next_attr == 0x0F) {
			LFN_Entry next_LFN_ENTRY;
			SFN_Entry_Alias SFN_ALIAS;
        }
        
	} else if (first != 0x00 && attr != 0x0F) { 
		SFN_Entry SFN_ENTRY;
    }
};

// ------------------------------
// ROOT DIRECTORY ENTRY PARSER
// ROUGH METHOD OF PARSING SFN/LFN/SFN_ALIAS/SUBDIR TWO LEVELS DEEP
// IF THE PATTERN CRASHES - THIS IS LIKELY WHY
// ------------------------------
struct RootDirParser {
    u64 curr_first_byte = $;
    u8 curr_attr = dir_entry_attr(curr_first_byte);		// current offset plus 12 bytes (offset 0x0B of entry)
    
    u64 next_first_byte = $ + 32;
    u8 next_attr = dir_entry_attr(next_first_byte);		// current offset plus 12 bytes (offset 0x0B of entry)  
    
    bool is_subdir = false;
    
    if (curr_first_byte != 0x00 && curr_first_byte != 0xE5 && curr_attr == 0x0F) {
		LFN_Entry LFN_ENTRY;
		
		if (next_first_byte != 0x00 && next_first_byte != 0xE5 && next_attr == 0x0F) {
			LFN_Entry next_LFN_ENTRY;
			SFN_Entry_Alias SFN_ALIAS;
			
			is_subdir = SFN_ALIAS.attributes.subDirectory;
			
    		if (SFN_ALIAS.attributes.subDirectory && next_first_byte != 0x00 && next_attr != 0xE5) {
       			is_subdir = SFN_ALIAS.attributes.subDirectory;
       			
       			u64 dir_start_addr = dataRegionStart + (SFN_ALIAS.first_cluster - 2) * bytesPerCluster;
     			SubDirParser SUB_DIR_INDEX[while(std::mem::read_unsigned($, 1) != 0x00)] @ dir_start_addr;
    		}
        }
    
    	if (next_first_byte != 0x00 && next_first_byte != 0xE5 && next_attr != 0x0F) {
    		SFN_Entry_Alias SFN_ALIAS;
    		
    		is_subdir = SFN_ALIAS.attributes.subDirectory;
    		
    		if (SFN_ALIAS.attributes.subDirectory && next_first_byte != 0x00 && next_attr != 0xE5) {
       			is_subdir = SFN_ALIAS.attributes.subDirectory;
       			
       			u64 dir_start_addr = dataRegionStart + (SFN_ALIAS.first_cluster - 2) * bytesPerCluster;
     			SubDirParser SUB_DIR_INDEX[while(std::mem::read_unsigned($, 1) != 0x00)] @ dir_start_addr; 			
    		}

    	}
    
    } else if (curr_first_byte != 0x00 && curr_first_byte != 0xE5 && curr_attr != 0x0F) {
    	SFN_Entry SFN_ENTRY;
    	is_subdir = SFN_ENTRY.attributes.subDirectory;
    	
    	if (SFN_ENTRY.attributes.subDirectory && next_first_byte != 0x00 && next_attr != 0xE5) {
       		is_subdir = SFN_ENTRY.attributes.subDirectory;
       		
       		u64 dir_start_addr = dataRegionStart + (SFN_ENTRY.first_cluster - 2) * bytesPerCluster;
     		SubDirParser SUB_DIR_INDEX[while(std::mem::read_unsigned($, 1) != 0x00)] @ dir_start_addr;
    	}
   
    } else if (curr_first_byte != 0x00 && current_first_byte == 0xE5) {
		
		if (next_first_byte != 0x00 && next_attr == 0x0F) {
        	LFN_Entry LFN_ENTRY;
        	
        	if (next_first_byte != 0x00 && next_first_byte != 0xE5) {
        		
        		if (next_attr != 0x0F) {
    				SFN_Entry_Alias SFN_ALIAS;
    				
    				is_subdir = SFN_ALIAS.attributes.subDirectory;
    			
    					if (next_first_byte != 0x00 && next_first_byte != 0xE5 && next_attr != 0x0F) {
    						SFN_Entry_Alias SFN_ALIAS2; // otherwise switch to SFN
    						
    						is_subdir = SFN_ALIAS.attributes.subDirectory;

    						if (SFN_ALIAS.attributes.subDirectory && next_first_byte != 0x00 && next_attr != 0xE5) {
       							is_subdir = SFN_ALIAS.attributes.subDirectory;
       							
       							u64 dir_start_addr = dataRegionStart + (SFN_ALIAS.first_cluster - 2) * bytesPerCluster;
     							SubDirParser SUB_DIR_INDEX[while(std::mem::read_unsigned($, 1) != 0x00)] @ dir_start_addr;							
    						}
    					}
    				}
    			}        	
        } else {
        	SFN_Entry SFN_ENTRY;
        	is_subdir = SFN_ENTRY.attributes.subDirectory;
        }
    }
} [[name(format_element($, start_index, is_subdir)), comment("FILE/DIR [INDX #]")]];

// ------------------------------
// NAME FORMATTER
// ------------------------------
fn format_element(auto v, u64 offset, bool subdir) {
    if (subdir) {
        return std::format("SUB_DIR [{:02}]", std::core::array_index() + offset);
    } else {
        return std::format("FILE    [{:02}]", std::core::array_index() + offset);
    }
};

// ------------------------------
// ROOT DIRECTORY HEADER PARSER
// ------------------------------
struct RootDirHeader {
	char VolumeName[11]						[[comment("User Defined Name of the VOL")]]; 
	u8 VolumeLabelFlag						[[comment("Indicates the Preceding VOL LABEL")]];
	padding[10]								[[comment("Zeros")]];
    std::time::DOSTime Created_Time 		[[format("format_dos_time_field"), comment("Last Write Time - Typically when Created/Formatted, but NOT ALWAYS...(DISK IMAGE/FAT DRIVERS)")]];
    std::time::DOSDate Created_Date 		[[format("format_dos_date_field"), comment("Last Write Date - Typically when Created/Formatted, but NOT ALWAYS...(DISK IMAGE/FAT DRIVERS)")]];					
	padding[6]								[[comment("Zeros")]];
};

// ------------------------------
// VBR SIGNATURE HELPER
// ------------------------------
enum VBRSignature : u16 {
	VBR_SIG = 0xAA55
};

// ------------------------------
// FILE SYSTEM INFO BLOCK
// ------------------------------
struct FSInfo {
	u32 leadSignature						[[comment("RRaA")]];
	padding[480]							[[comment("Zeros")]];
	u32 structSignature						[[comment("FSINFO Signature")]];
	u32 freeClusterCount					[[comment("Approximate Free Cluster Count")]];
	u32 nextFreeCluster						[[comment("FAT1: Suggested Starting Point")]];
	padding[14]								[[comment("Zeros")]];
	VBRSignature VBR_SIG           			[[comment("0x55AA")]];
};

// ------------------------------
// FAT12/16/32 BIOS PARAMETER BLOCK (BPB)
// ------------------------------
struct BPB_Common {
    u8  jmp_boot[3]							[[comment("Assembly Instructions to Jump to Boot Code")]];
    char oem_name[8]						[[comment("MSDOS/BSD")]];
    u16 bytes_per_sector					[[comment("512,1024,2048,4096")]];
    u8  sectors_per_cluster					[[comment("Under 32K - Must be a power of 2")]];
    u16 reserved_sectors					[[comment("Size of Reserved Area in Sectors")]];
    u8  num_fats							[[comment("Typically 2, but can be 1 for Small Volumes")]];
    u16 root_entry_count           			[[comment("Max Num of Entries -- 0 for FAT32| 512 for FAT16")]];
    u16 total_sectors16            			[[comment("if 0, use total_sectors32")]];
    u8  media_type							[[comment("0xF8=FIXED DISK | 0xF0=REMOVABLE")]];
    u16 fat_size16                			[[comment("Size of each FAT in Sectors for FAT12/16; 0 for FAT32")]];
    u16 sectors_per_track					[[comment("Legacy")]];
    u16 num_heads							[[comment("Legacy")]];
    u32 hidden_sectors						[[comment("Num of Sectors before the Volume")]];
    u32 total_sectors32						[[comment("32bit Value of Total Num of Sectors in Volume")]];
// ----------------------vvv-----
// FAT32 EXTENDED
// ----------------------vvv-----
    u32 FAT_Sector_Count         			[[comment("Total Sectors per FAT")]];
    u16 ext_flags							[[comment("16bit Value: BIT_7 = 1 == 1 FAT USED | Otherwise both FATs USED")]];
    u16 fs_version							[[comment("Major and Minor | None")]];
    u32 root_cluster						[[comment("Cluster Num of Root Dir")]];
    u16 fs_info_sector						[[comment("FS_INFO Location")]];
    u16 backup_boot_sector					[[comment("VBR Backup Location")]];
    u8  reserved[12]						[[comment("Zeros")]];
    u8  drive_number						[[comment("BIOS INT13h Drive Num")]];
    u8  reserved1							[[comment("Zeros")]];
    u8  boot_signature            			[[comment("Extended Boot Sig = 0x29")]];
    u32 volume_id							[[comment("Volume Serial Number - Based on Created Date/Time")]];
    char volume_label[11]					[[comment("No Name | User Defined Name | Check Root Dir")]];
    char fs_type[8]              			[[comment("FAT32   ")]];
    u8  bootstrap[420]             			[[comment("Until Signature")]];
    VBRSignature VBR_SIG           			[[comment("0x55AA")]];
// ----------------------vvv-----
// UPDATE CONSTANTS/GLOBALS
// ----------------------vvv-----
    bytesPerCluster   						= sectors_per_cluster * bytes_per_sector;
    rootDirSectors    						= ((root_entry_count * 32) + (bytes_per_sector - 1)) / bytes_per_sector;
    firstDataSector   						= reserved_sectors + (num_fats * FAT_Sector_Count) + rootDirSectors;
    dataRegionStart   						= firstDataSector * bytes_per_sector;
};

// -----------------------------------------------------------------------------
// FAT32 MAIN RELATED
// -----------------------------------------------------------------------------
//   V		V		V		V		V		V		V		V		V		V
// -----------------------------------------------------------------------------
// ------------------------------
// FAT32 VOLUME BOOT RECORD
// ------------------------------
BPB_Common F32_VBR @ $;
VBR_OFFSET = F32_VBR.hidden_sectors * F32_VBR.bytes_per_sector;
    
/// ------------------------------
// FILE SYSTEM INFO BLOCK
// ------------------------------
FSInfo FS_INFO @ F32_VBR.fs_info_sector * F32_VBR.bytes_per_sector;
root_dir_start = dataRegionStart + ((F32_VBR.root_cluster - 2) * bytesPerCluster) + 32;

// ------------------------------
// FILE ALLOCATION TABLE
// *** HAS GLOBAL AT TOP ***
// ------------------------------
FAT1_start_offset = F32_VBR.reserved_sectors * F32_VBR.bytes_per_sector;
FAT2_start_offset = FAT1_start_offset + (F32_VBR.FAT_Sector_Count * F32_VBR.bytes_per_sector);
FAT_ClusterHeap_Count = F32_VBR.FAT_Sector_Count * F32_VBR.bytes_per_sector / CLUSTER_SIZE_BYTES;

FAT_Header FAT1_HEADER @ FAT1_start_offset;
FAT_Entry FAT1[MAX_FAT_CHUNKS] @ FAT1_start_offset + 8;

FAT_Header FAT2_HEADER @ FAT2_start_offset;
FAT_Entry FAT2[MAX_FAT_CHUNKS] @ FAT2_start_offset + 8;

// ------------------------------
// ROOT DIRECTORY HEADER
// ------------------------------
RootDirHeader ROOT_DIR_HEADER @ dataRegionStart + ((F32_VBR.root_cluster - 2) * bytesPerCluster);   

// ----*-----*------*------*-----
// * * ROOT DIRECTORY PARSER * *
// ----*-----*------*------*-----
RootDirParser ROOT_DIR_ENTRIES[while(std::mem::read_unsigned($, 1) != 0x00)] @ root_dir_start;

// ------------------------------
// SFN <-> CLUSTER RELATION OVERLAY
// *** HAS GLOBAL AT TOP ***
// ------------------------------
INFO_Overlay SFN_CLUSTER_LIST[MAX_SFN_CLUSTER_RELATIONS] @ FAT1_start_offset [[name("SFN <-> CLUSTER (DERIVED)")]];

// ------------------------------
// FAT32 VOLUME REPORT
// *** HAS GLOBAL AT TOP ***
// ------------------------------
abs_FAT1_start_offset = VBR_OFFSET + (F32_VBR.reserved_sectors * F32_VBR.bytes_per_sector);
abs_FAT2_start_offset = abs_FAT1_start_offset + (F32_VBR.FAT_Sector_Count * F32_VBR.bytes_per_sector);
abs_rootDirStart_offset = VBR_OFFSET  + dataRegionStart;

if (VOLUME_REPORT) {
    std::print(" ");
    std::print("-----------------------------------------");
    std::print("---------- FAT32 VOLUME_REPORT ----------");
    std::print("-----------------------------------------");
    std::print("VOL_LABEL        	= {}", F32_VBR.volume_label);
    std::print("FILE_SYSTEM      	= {}", F32_VBR.fs_type);
    std::print("SERIAL_NUMBER    	= 0x{:X}", F32_VBR.volume_id);

    std::print("-----------------------------------------");
    std::print("BYTES/SECTOR     	= {:02}", F32_VBR.bytes_per_sector);
    std::print("SECTORS/CLUSTER  	= {:02}", F32_VBR.sectors_per_cluster);
    std::print("BYTES/CLUSTER    	= {:02}", bytesPerCluster);
    std::print("ROOT_ENTRIES     	= {:02}", F32_VBR.root_entry_count);
    std::print("CLUSTER_COUNT    	= {:02}", (F32_VBR.total_sectors32 - firstDataSector) / F32_VBR.sectors_per_cluster);

    std::print("-----------------------------------------");
    std::print("VOLUME_SIZE      	= {:02} SECTORS", F32_VBR.total_sectors32);
    std::print("VOLUME_SIZE      	= {:.4f} GB  @ 1000", (F32_VBR.total_sectors32 * F32_VBR.bytes_per_sector) / 1000.0 / 1000.0 / 1000.0);
    std::print("VOLUME_SIZE      	= {:.4f} GiB @ 1024", (F32_VBR.total_sectors32 * F32_VBR.bytes_per_sector) / 1024.0 / 1024.0 / 1024.0);

    std::print("-----------------------------------------");
    std::print("RESERVED_SECTORS 	= {:02}", F32_VBR.reserved_sectors);
    std::print("FAT_COUNT        	= {:02}", F32_VBR.num_fats);
    std::print("FAT_SIZE         	= {:02} SECTORS", F32_VBR.FAT_Sector_Count);
    std::print("FAT1_START_OFF   	= {} | 0x{:02X}", abs_FAT1_start_offset, abs_FAT1_start_offset);
    std::print("FAT2_START_OFF   	= {} | 0x{:02X}", abs_FAT2_start_offset, abs_FAT2_start_offset);
    std::print("ROOT_DIR_CLUSTER 	= {:02}", F32_VBR.root_cluster);
    std::print("ROOT_DIR_OFFSET  	= {} | 0x{:02X}", abs_rootDirStart_offset, abs_rootDirStart_offset);

    std::print("-----------------------------------------");
    if (sfn_del_count >= 1) {
        std::print("SFN_DEL(xE5)     	= DETECTED");
    }
    if (lfn_del_count >= 1) {
        std::print("LFN_DEL(xE5)     	= DETECTED");
    }
    std::print("FAT1_EOF_COUNT   	= {:02}", allocated_file_count / 2); // divided by 2 (FAT1/FAT2)

    std::print("-----------------------------------------");
    std::print("------------------ END ------------------");
    std::print("-----------------------------------------");
    std::print(" ");
}
