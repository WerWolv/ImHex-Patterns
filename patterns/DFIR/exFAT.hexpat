#pragma author Formula Zero One Technologies
#pragma description exFAT Filesystem Structures
#pragma MIME application/x-ima
#pragma endian little

// -----------------------------------------------------------------------------
// CREDIT
// -----------------------------------------------------------------------------
// Based on /fs/exfat.hexpat by WerWolv
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// NOTES
// -----------------------------------------------------------------------------
// Imported by DISK_PARSER.hexpat
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// TODO
// -----------------------------------------------------------------------------
// Recursive parsing of Root Directory / SubDirs
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import std.core;
import std.io;
import std.time;
import std.mem;
import type.guid;
import type.magic;
import type.base;

// ------------------------------
// FORWARD DECS/GLOBALS
// ------------------------------

// 		*** ATTENTION ***	
// SET MAXIMUM NUMBER OF 4 BYTE CHUNKS TO PARSE FROM FAT1
// SET MAXIMUM NUMBER OF DIRECTORY ENTRIES TO PARSE FROM ROOT DIRECTORY
// DEFAULTS ARE 4096 | 2500
// Choose a value greater than 1 and less than 65536 OR increase the Array size limit with "#define... "

// -------**************---vvvv--- |
const u64 MAX_FAT_CHUNKS = 4096;
// -------**************---^^^^--- |

// -------**************---vvvv--- |
const u64 MAX_DIR_ENTRIES = 2500;
// -------**************---^^^^--- |

// 		*** ATTENTION ***	
// ---*******---*******----vvvv--- |
const bool VOLUME_REPORT = true;
// ---*******---*******----^^^^--- |

u64 allocated_file_count;
u64 rdc;
u32 entry_size = 32; 

// --------------------------
// exFAT DIRECTORY ENTRY HELPER
// --------------------------
enum EntryType : u8 {
    UNUSED_ENTRY                            = 0x00,
    ACTIVE_VOLUME_GUID_ENTRY				= 0xA0,
    INACTIVE_VOLUME_GUID_ENTRY				= 0x20,
    ACTIVE_TEXFAT_ENTRY						= 0xA1,
    INACTIVE_TEXFAT_ENTRY					= 0x21,
    ACTIVE_ACCESS_CONTROL_ENTRY				= 0xA2,
    INACTIVE_ACCESS_CONTROL_ENTRY			= 0x22,
    ACTIVE_VOLUME_LABEL_ENTRY				= 0x83,
    INACTIVE_VOLUME_LABEL_ENTRY				= 0x03,
    ACTIVE_ALLOCATION_BITMAP_ENTRY 			= 0x81,
    INACTIVE_ALLOCATION_BITMAP_ENTRY		= 0x01,
    ACTIVE_UPCASE_TABLE_ENTRY				= 0x82,
    INACTIVE_UPCASE_TABLE_ENTRY				= 0x02,
    ACTIVE_FILE_INFO_ENTRY					= 0x85,
    INACTIVE_FILE_INFO_ENTRY				= 0x05,
    ACTIVE_STREAM_ENTRY 					= 0xC0,
    INACTIVE_STREAM_ENTRY					= 0x40,
    ACTIVE_FILENAME_ENTRY					= 0xC1,
    INACTIVE_FILENAME_ENTRY					= 0x41,
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
// BITFIELD HELPERS
// ------------------------------
bitfield Entry_Flags {
    unsigned TypeCode 	: 5;
    unsigned Importance : 1;
    unsigned Category	: 1;
    unsigned InUse		: 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield Bitmap_Flags {
    unsigned Bitmap_1 : 1;
    unsigned Bitmap_2 : 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield General_Primary_Flags {
    unsigned Allocation_Possible 	: 1;
    unsigned No_FAT_Chain 			: 1;
    unsigned Reserved				: 6;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield General_Secondary_Flags {
    unsigned Allocation_Possible 	: 1;
    unsigned No_FAT_Chain 			: 1;
    unsigned Reserved				: 6;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

bitfield File_Attr_Flags {
    unsigned Read_Only			 	: 1;
    unsigned Hidden		 			: 1;
    unsigned System					: 1;
    unsigned Directory				: 1;
    unsigned Archive				: 1;
    Reserved						: 11;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 16)]];

// --------------------------
// exFAT DIRECTORY ENTRY STRUCTURES
// --------------------------
// xA0 / x20 = Volume GUID Entry
struct VolumeGUID_Entry {
    Entry_Flags EntryFlags					[[comment("ENTRY TYPE IDENTIFIER")]];                 			
	u8 SecondaryCount[3]					[[comment("COUNT OF SUBSEQUENT ENTRIES")]];
	type::Hex<u16> SetChecksum				[[comment("16bit CHECKSUM")]];
    General_Primary_Flags PrimaryFlags;
    type::GUID GUID;
    u8 Reserved_1[9];
};

// xA1 / x21 = TexFAT / Padding Entry
struct TexFATPadding_Entry {
    Entry_Flags Flags						[[comment("ENTRY TYPE IDENTIFIER")]];
    u8 Reserved_1[31];  
};

// xA2 / x22 = Access Control Entry
struct AccessControl_Entry {
    Entry_Flags Flags						[[comment("ENTRY TYPE IDENTIFIER")]];
    u8 Reserved[31];
};

// x83 / x03 = Volume Label Entry
struct VolumeLabel_Entry {
    Entry_Flags Flags						[[comment("ENTRY TYPE IDENTIFIER")]];
    u8 LabelLength                 			[[comment("NUMBER OF UTF-16 CHARACTERS")]];
    char16 Label[LabelLength]              	[[comment("VOLUME LABEL: UTF-16")]];
    u8 Reserved[32-2-(LabelLength * 2)];
};

// x81 / x01 = Allocation Bitmap Entry
struct AllocationBitmap_Entry {
    Entry_Flags Flags						[[comment("ENTRY TYPE IDENTIFIER")]];
    Bitmap_Flags BitmapFlags;
    u8 Reserved_1[18];
    u32 FirstCluster						[[comment("FIRST LOGICAL CLUSTER NUMBER")]];
    u64 DataLength							[[comment("DATA SIZE")]];
};

// x82 / x02 = UpCase Table Entry
struct UpCaseTable_Entry {
    Entry_Flags Flags						[[comment("ENTRY TYPE IDENTIFIER")]];
    u8 Reserved_1[3];
    type::Hex<u32> TableChecksum			[[comment("16bit CHECKSUM")]];
    u8 Reserved_2[12];
    u32 FirstCluster						[[comment("FIRST LOGICAL CLUSTER NUMBER")]];
    u64 DataLength							[[comment("DATA SIZE")]];
};

// x85 / x05 = File Info Entry
struct FileInfo_Entry {
    Entry_Flags EntryFlags					[[comment("ENTRY TYPE IDENTIFIER")]];
    u8 SecondaryCount						[[comment("COUNT OF SUBSEQUENT ENTRIES")]];
    type::Hex<u16> SetChecksum				[[comment("16bit CHECKSUM")]];
    File_Attr_Flags AttrFlags				[[comment("FILE ATTRS: RASH")]];
	u16 Reserved_1;
    std::time::DOSTime Created_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Created_Date 		[[format("format_dos_date_field")]];
    std::time::DOSTime Accessed_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Accessed_Date 		[[format("format_dos_date_field")]];
    std::time::DOSTime Modified_Time 		[[format("format_dos_time_field")]];
    std::time::DOSDate Modified_Date 		[[format("format_dos_date_field")]];
	u8 Created_10ms_Increments				[[comment("Add to Times for Refinement")]];   
	u8 Modified_10ms_Increments				[[comment("Add to Times for Refinement")]]; 
	s8 Created_UTC_Diff						[[comment("Add to Times for Refinement")]]; 
	s8 Modified_UTC_Diff					[[comment("Add to Times for Refinement")]]; 
	s8 Accessed_UTC_Diff					[[comment("Add to Times for Refinement")]]; 
    u8 Reserved[7];
};

// xC1 / x41 = File Name Entry
struct FileName_Entry {
    Entry_Flags EntryFlags					[[comment("ENTRY TYPE IDENTIFIER")]];
    General_Secondary_Flags SecondaryFlags	[[comment("COUNT OF SUBSEQUENT ENTRIES")]];
    char16 FileName[15]						[[comment("FILE NAME: UTF-16")]];
};

// xC0 / x40 = Stream Extension Entry
struct Stream_Entry {
    Entry_Flags EntryFlags					[[comment("ENTRY TYPE IDENTIFIER")]];;
    General_Secondary_Flags SecondaryFlags	[[comment("COUNT OF SUBSEQUENT ENTRIES")]];
	u8 Reserved_1;
    u8 NameLength							[[comment("STREAM LENGTH")]];
    type::Hex<u16> NameHash					[[comment("16bit QUICK HASH: USED FOR FILE SEARCHING")]];
    u16 Reserved_2;
    u64 InitSize							[[comment("INITIALIZED SIZE")]];
    u32 Reserved_3;
    u32 FirstCluster						[[comment("FIRST LOGICAL CLUSTER NUMBER")]];
    u64 ActualSize							[[comment("PHYSICAL DATA SIZE")]];;
    u8 FILE_DATA[InitSize] @ temp_root_location + (FirstCluster - exFAT_VBR.root_dir_cluster) * bytesPerCluster	[[comment("POINTER TO THE CLUSTER CONTENT")]];
};

// --------------------------
// exFAT ROOT DIRECTORY
// --------------------------
struct RootDir {
    EntryType Type;
    padding[31];

    match (Type) {
        (EntryType::UNUSED_ENTRY): {
        	continue;
        }
        (EntryType::ACTIVE_VOLUME_GUID_ENTRY | EntryType::INACTIVE_VOLUME_GUID_ENTRY):{
            VolumeGUID_Entry VOLUME_GUID_ENTRY @ $ - 32;  
        }    
        (EntryType::ACTIVE_TEXFAT_ENTRY | EntryType::INACTIVE_TEXFAT_ENTRY):{      
            TexFATPadding_Entry TEXFAT_PADDING_ENTRY @ $ - 32;
        }
        (EntryType::ACTIVE_ACCESS_CONTROL_ENTRY | EntryType::INACTIVE_ACCESS_CONTROL_ENTRY):{
            AccessControl_Entry ACCESS_CONTROL_ENTRY @ $ - 32;
        }
        (EntryType::ACTIVE_VOLUME_LABEL_ENTRY | EntryType::INACTIVE_VOLUME_LABEL_ENTRY):{
            VolumeLabel_Entry VOLUME_LABEL_ENTRY @ $ - 32; 
        }
        (EntryType::ACTIVE_ALLOCATION_BITMAP_ENTRY | EntryType::INACTIVE_ALLOCATION_BITMAP_ENTRY):{
    		AllocationBitmap_Entry ALLOCATION_BITMAP_ENTRY @ $ - 32;
        }
        (EntryType::ACTIVE_UPCASE_TABLE_ENTRY | EntryType::INACTIVE_UPCASE_TABLE_ENTRY):{
            UpCaseTable_Entry UPCASE_TABLE_ENTRY @ $ - 32;
        }
        (EntryType::ACTIVE_FILE_INFO_ENTRY | EntryType::INACTIVE_FILE_INFO_ENTRY):{
            FileInfo_Entry FILE_INFO_ENTRY @ $ - 32;
        }
        (EntryType::ACTIVE_STREAM_ENTRY | EntryType::INACTIVE_STREAM_ENTRY):{
            Stream_Entry STREAM_EXT_ENTRY @ $ - 32; 
    	}
        (EntryType::ACTIVE_FILENAME_ENTRY | EntryType::INACTIVE_FILENAME_ENTRY):{  
            FileName_Entry FILE_NAME_ENTRY @ $ - 32;
        }
    }
} [[name(format_entry_name(std::mem::read_unsigned($-32, 1), std::core::array_index()))]];

fn format_entry_name(auto entry_type, u64 idx) {
    return std::format("{}[{}]", type_name(entry_type), idx);
};

// ------------------------------
// TYPE RE-NAMER
// ------------------------------
fn type_name(u32 type) {
    if (type == EntryType::UNUSED_ENTRY) 						return "UNUSED_ENTRY";
    if (type == EntryType::ACTIVE_VOLUME_GUID_ENTRY)       		return "ACTIVE_VOLUME_GUID_ENTRY";
    if (type == EntryType::INACTIVE_VOLUME_GUID_ENTRY)          return "INACTIVE_VOLUME_GUID_ENTRY";
    if (type == EntryType::ACTIVE_TEXFAT_ENTRY)            		return "ACTIVE_TEXFAT_ENTRY";
    if (type == EntryType::INACTIVE_TEXFAT_ENTRY)  				return "INACTIVE_TEXFAT_ENTRY";
    if (type == EntryType::ACTIVE_ACCESS_CONTROL_ENTRY)         return "ACTIVE_ACCESS_CONTROL_ENTRY";
    if (type == EntryType::INACTIVE_ACCESS_CONTROL_ENTRY)   	return "INACTIVE_ACCESS_CONTROL_ENTRY";
    if (type == EntryType::ACTIVE_VOLUME_LABEL_ENTRY)           return "ACTIVE_VOLUME_LABEL_ENTRY";
    if (type == EntryType::INACTIVE_VOLUME_LABEL_ENTRY)         return "INACTIVE_VOLUME_LABEL_ENTRY";
    if (type == EntryType::ACTIVE_ALLOCATION_BITMAP_ENTRY)     	return "ACTIVE_ALLOCATION_BITMAP_ENTRY";
    if (type == EntryType::INACTIVE_ALLOCATION_BITMAP_ENTRY)    return "INACTIVE_ALLOCATION_BITMAP_ENTRY";
    if (type == EntryType::ACTIVE_UPCASE_TABLE_ENTRY)        	return "ACTIVE_UPCASE_TABLE_ENTRY";
    if (type == EntryType::INACTIVE_UPCASE_TABLE_ENTRY)       	return "INACTIVE_UPCASE_TABLE_ENTRY";
    if (type == EntryType::ACTIVE_FILE_INFO_ENTRY)              return "ACTIVE_FILE_INFO_ENTRY";
    if (type == EntryType::INACTIVE_FILE_INFO_ENTRY)         	return "INACTIVE_FILE_INFO_ENTRY";
    if (type == EntryType::ACTIVE_STREAM_ENTRY)                 return "ACTIVE_STREAM_ENTRY";
    if (type == EntryType::INACTIVE_STREAM_ENTRY)         		return "INACTIVE_STREAM_ENTRY";
    if (type == EntryType::ACTIVE_FILENAME_ENTRY)               return "ACTIVE_FILENAME_ENTRY";
    if (type == EntryType::INACTIVE_FILENAME_ENTRY)         	return "INACTIVE_FILENAME_ENTRY";
    return "UNKNOWN";
};

// -----------------------------------------------------------------------------
// exFAT FILE ALLOCATION TABLE (FAT1) PARSER
// -----------------------------------------------------------------------------

const u32 CLUSTER_SIZE_BYTES = 4;    // Each FAT32 entry = 4 bytes
const u32 FAT_EOF = 0x0FFFFFFF;    // End-of-file marker
const u32 FAT_BAD = 0x0FFFFFF7;    // Bad cluster marker
const u32 FIRST_ALLOC_CLUSTER = 2;   // First usable cluster after reserved

enum FAT_Flags : u32 {
	UNALLOCATED				= 0x00000000,
	END_OF_FILE				= 0xFFFFFFFF,		// L.END
	BAD_CLUSTER				= 0xFFFFFFF7,		// L.END
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
// FAT1 HEAPS/CHAINS
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
    bool is_bad      = next_cluster == FAT_BAD;
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
    
    else if (next_cluster == FAT_BAD)
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
// FAT HEADER PARSER
// ------------------------------
struct FAT_Header {
	Media_Descriptor mediaDescriptor		[[comment("0xF8=FIXED DISK | 0xF0=REMOVABLE")]];;
	u8 exFAT_FAT_HEADER[7]					[[comment("8 BYTES TOTAL: 4 BYTES REPRESENT PSUEDO CLUSTER 0 (SYSTEM)  | 4 BYTES REPRESENT PSUEDO CLUSTER 1 (SYSTEM)(EOF)")]];

    char dolla_BITMAP_label[4] @ $ [[
    	name(std::format(
    		"$Bitmap"
    	))
    ]];	

    char dolla_UPCASE_label[4] @ $ + 4 [[
    	name(std::format(
    		"$UpCase"
    	))
    ]];	

    char root_dir_label[4] @ $ + ((rdc - 2) * 4)  [[
    	name(std::format(
    		"ROOT_DIRECTORY"
    	))
    ]];			
};

// ------------------------------
//SIGNATURE HELPER
// ------------------------------
enum VBRSignature : u16 {
	VBR_SIG = 0xAA55
};

// ------------------------------
// EXTENDED BOOT REGION
// ------------------------------
struct ExtendedBoot {
	u8 Extended_Boot_Sector[1 * bytesPerSector];
	VBRSignature VBR_SIG @ $ - 2;
};

// ------------------------------
// BOOT SECTOR BITFIELD FLAGS
// ------------------------------
bitfield VolumeFlags {
    unsigned Active 		: 1;
    unsigned VolumeDirty 	: 1;
    unsigned Media_Failure	: 1;
    unsigned Clear_to_Zero	: 1;
    Rserved					: 12;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 16)]];

// ------------------------------
// EXFAT VOLUME BOOT RECORD
// ------------------------------
struct exFAT_BootSector {
    u8  jmp_boot[3];
    char fs_name[8];                // "EXFAT   "
    u8  must_be_zero[53];
    u64 partition_offset;           // in sectors
    u64 volume_length;              // in sectors
    u32 fat_offset;                 // in sectors
    u32 fat_length;                 // in sectors
    u32 cluster_heap_offset;        // in sectors
    u32 cluster_count;
    u32 root_dir_cluster;
    u32 volume_serial;
    u16 fs_revision;
    VolumeFlags volume_flags;
    u8  bytes_per_sector_shift;     // 2^n
    u8  sectors_per_cluster_shift;  // 2^n
    u8  number_of_fats;
    u8  drive_select;
    u8  percent_in_use;
    u8  reserved[7];
    u8  bootstrap[390];
    VBRSignature VBR_SIG;           // 0x55AA
    
    rdc = root_dir_cluster;
};

// -------------------------------------------------------------------------
// MAIN
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------

exFAT_BootSector exFAT_VBR @ 0x0;

// -------------------------------------------------------------------------
// DERIVED CONSTANTS
// -------------------------------------------------------------------------

// ============= SIZES ===================================================================
u32 bytesPerSector  = 1 << exFAT_VBR.bytes_per_sector_shift;
u32 bytesPerCluster = bytesPerSector << exFAT_VBR.sectors_per_cluster_shift;

// ============= OFFSETS =================================================================
u64 volumeStartSector = exFAT_VBR.partition_offset;
u64 volumeStartOffset = volumeStartSector * bytesPerSector;
u64 volumeSize        = exFAT_VBR.volume_length * bytesPerSector;

u64 FAT1_start_offset = exFAT_VBR.fat_offset * bytesPerSector;

//For printing absolute offset
u64 RootDir_Offset = (exFAT_VBR.cluster_heap_offset + 
     				((exFAT_VBR.root_dir_cluster - 2) << exFAT_VBR.sectors_per_cluster_shift)) 
     					* bytesPerSector + volumeStartOffset;

// ============= CLUSTERS ================================================================
u32 clusterSize  = bytesPerCluster;
u32 clusterCount = exFAT_VBR.cluster_count;
u64 clusterHeapOffset = exFAT_VBR.cluster_heap_offset * bytesPerSector;

// -------------------------------------------------------------------------
// SECONDARY
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ============= USAGE ===================================================================
u8  percentInUse = exFAT_VBR.percent_in_use;

// ============= EBS =====================================================================
ExtendedBoot Extended_Boot_Sectors[8] @ $;

// ============= OEM =====================================================================
u8 OEM_Parameters[1 * bytesPerSector] @ $;

// ============= ER ======================================================================
u8 Extended_Reserved[1 * bytesPerSector] @ $;

// ============= BCS =====================================================================
u8 Boot_Checksum[1 * bytesPerSector] @ $;

// ============= BBS =====================================================================
exFAT_BootSector Backup_Boot_Sector @ $;

// ============= BEBS ====================================================================
ExtendedBoot Backup_Extended_Boot_Sectors[8] @ $;

// ============= BOEM ====================================================================
u8 Backup_OEM_Parameters[1 * bytesPerSector] @ $;

// ============= BER =====================================================================
u8 Backup_Extended_Reserved[1 * bytesPerSector] @ $;

// ============= BBCS ====================================================================
u8 Backup_Boot_Checksum[1 * bytesPerSector] @ $;

// ============= FAT =====================================================================
// *** HAS GLOBAL AT TOP ***

FAT_Header FAT1_HEADER @ FAT1_start_offset;
FAT_Entry FAT1[MAX_FAT_CHUNKS] @ FAT1_start_offset + 8;

// ============= ROOT ====================================================================
// ROOT DIRECTORY
// *** HAS GLOBAL AT TOP ***

// for locating root directory within memory 
u64 temp_root_location = (exFAT_VBR.root_dir_cluster - 2) * clusterSize + clusterHeapOffset;
RootDir ROOT_DIRECTORY[MAX_DIR_ENTRIES] @ temp_root_location;


// ============= REPORT ==================================================================
// VOLUME REPORT
// *** HAS GLOBAL AT TOP ***

if (VOLUME_REPORT) {
    std::print(" ");
    std::print("-----------------------------------------");
    std::print("---------- EXFAT VOLUME_REPORT ----------");
    std::print("-----------------------------------------");
    std::print("FILE_SYSTEM      	= {}", exFAT_VBR.fs_name);
    std::print("SERIAL_NUMBER    	= 0x{:X}", exFAT_VBR.volume_serial);
    std::print("FS_REVISION      	= {}.{}", (exFAT_VBR.fs_revision >> 8) & 0xFF, exFAT_VBR.fs_revision & 0xFF);

	bool _any = false;
	if(exFAT_VBR.volume_flags.Active) {
    	std::print("FAT_FLAG            	= 0b{:X}", exFAT_VBR.volume_flags.Active);
    	_any = true;
    }
	if(exFAT_VBR.volume_flags.VolumeDirty) {
    	std::print("DIRTY_FLAG            	= 0b{:X}", exFAT_VBR.volume_flags.Volume_Dirty);
    	_any = true;
    }
	if(exFAT_VBR.volume_flags.Media_Failure) {
    	std::print("FAILURE_FLAG            	= 0b{:X}", exFAT_VBR.volume_flags.Media_Failure);
    	_any = true;
    }
	if(exFAT_VBR.volume_flags.Clear_to_Zero) {
    	std::print("CLEAR_TO_ZERO_FLAG            	= 0b{:X}", exFAT_VBR.volume_flags.Clear_to_Zero);
    	_any = true;    
    }
	if (!_any){
		std::print("VOL_FLAGS            = NONE");
	}

    std::print("-----------------------------------------");
    std::print("BYTES/SECTOR     	= {}", bytesPerSector);
    std::print("SECTORS/CLUSTER  	= {}", 1 << exFAT_VBR.sectors_per_cluster_shift);
    std::print("BYTES/CLUSTER    	= {}", bytesPerCluster);
    std::print("CLUSTER_COUNT    	= {}", clusterCount);

    std::print("-----------------------------------------");
    std::print("VOLUME_SIZE      	= {} SECTORS", exFAT_VBR.volume_length);
    std::print("VOLUME_SIZE      	= {:.4f} GB  @ 1000", volumeSize / 1000.0 / 1000.0 / 1000.0);
    std::print("VOLUME_SIZE      	= {:.4f} GiB @ 1024", volumeSize / 1024.0 / 1024.0 / 1024.0);

    std::print("-----------------------------------------");
    std::print("VOLUME_START_SEC 	= {}", volumeStartSector);
    std::print("VOLUME_START_OFF 	= 0x{:X}", volumeStartOffset);

    std::print("FAT1_START_OFF   	= 0x{:02X}", FAT1_start_offset);
    std::print("CLUSTER_HEAP_OFF 	= 0x{:02X}", clusterHeapOffset);
    std::print("ROOT_DIR_CLUSTER 	= {:02}", exFAT_VBR.root_dir_cluster);
    std::print("ROOT_DIR_OFFSET  	= 0x{:02X}", RootDir_Offset);

    std::print("-----------------------------------------");
    std::print("PERCENT_IN_USE   	= {:02} %", percentInUse);
    std::print("NUMBER_OF_FATS   	= {:02}", exFAT_VBR.number_of_fats);
    std::print("DRIVE_SELECT     	= 0x{:02X}", exFAT_VBR.drive_select);

    std::print("-----------------------------------------");
    std::print("------------------ END ------------------");
    std::print("-----------------------------------------");
    std::print(" ");
}