#pragma author MODIFIED BY: Formula Zero One Technologies
#pragma description NT File System (NTFS_v2.0)
#pragma endian little

// -----------------------------------------------------------------------------
// CREDIT
// -----------------------------------------------------------------------------
// OG AUTHOR: Hrant Tadevosyan (Axcient, now ConnectWise)
// OG DESC: ntfs.hexpat_v1.0
// So much work went into this pattern; NICE JOB!!
// -----------------------------------------------------------------------------
// NOTES FOR v2.0
// -----------------------------------------------------------------------------
// Imported by DISK_PARSER.hexpat
// Added recursive parsing for all $MFT records
// Added D/T conversions
// Changed most ntfschar to char16 to show filenames on hover
// Added comments to DFIR fields of interest
// Changed pattern output naming/structure. Similar to RunTime's DiskExplorer -- FREntry > FRHeader > ATTRName > ATTRHeader > ATTRBody > ATTREnd
// Reconfigured x50 ATTR and ACL processing
// Modified RunList - File Content Pointer
// -----------------------------------------------------------------------------
// NTFS MANTRAS FROM NW3C...
// -----------------------------------------------------------------------------
// --- 1 --- EVERYTHING IN NTFS IS A FILE (RECORD) (INCLUDING DIRs)
// --- 2 --- EVERY FILE (& DIR) HAS AN ENTRY IN THE $MFT, INCLUDING THE $MFT ITSELF
// --- 3 --- EVERY FILE (RECORD) IS MADE UP OF ATTRIBUTES
// --------- FILES = x10/x30/x80 (minimum)
// --------- DIRs  = x10/x30/x90 (minimum)
// -----------------------------------------------------------------------------
// -------------------------------------------------------------------------
// IMPORTS
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
import std.core;
import std.array;
import std.ptr;
import std.io;
import std.mem;
import std.string;
import std.time;
import type.magic;
import type.time;
import type.guid;
import type.base;

// -------------------------------------------------------------------------
// FWD DECs - GLOBALS
// -------------------------------------------------------------------------

// 		*** ATTENTION ***	

// ---*******---*******----vvvv--- |
const bool VOLUME_REPORT = true;
// ---*******---*******----^^^^--- |

u64 VBR_OFFSET;
u64 prev_lcn = 0;
u32 MFT_Count;
u32 Unused_Count;
u8  NT_Major;
u8  NT_Minor;
type::Hex<u32> mft_num;
type::Hex<u32> seq_num;
str Vol_Label;
u8 PRENT_MFT;
u8 PRENT_SEQ;

// -------------------------------------------------------------------------
// GENERAL HELPERS RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
using ntfschar = u16;
using leVCN = u64;
using leLCN = u64;
using leLSN = u64;
using leMFT_REF = u64;

bitfield RUNLIST_HEADER {
    unsigned SE_Offset : 4;
    unsigned Length : 4;
} [[bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 8)]];

// -------------------------------------------------------------------------
// RUNLIST
// -------------------------------------------------------------------------
struct RUNLIST {
    RUNLIST_HEADER RunList_Header
        [[comment("Left Nibble = S.E. Bytes | Right Nibble = S.E. Length")]];

    // Highlight the Stream Extent bytes
    char run_extent[RunList_Header.SE_Offset + RunList_Header.Length] @ $ 
        [[name(std::format("Run_Extent: {} + {} = {} Bytes       ",
            RunList_Header.SE_Offset,
            RunList_Header.Length,
            RunList_Header.SE_Offset + RunList_Header.Length)),
          comment("Start/Run Extent | Derived from Header")]];

    // Get number of clusters as a string
    str NoC_value = std::string::to_string(
        std::mem::read_unsigned($, RunList_Header.Length));

    // Highlight exactly RunList_Header.Length bytes
    char Num_of_Clusters[RunList_Header.Length]
        [[name(std::format("Num_of_Clusters = {}        ", NoC_value)),
          comment("Number of Clusters in a Run")]];

    // Needed for mft_get_dat_attr_lcn function only
    u8 Logical_Cluster_Num[RunList_Header.SE_Offset] [[hidden]];

    if (RunList_Header.SE_Offset > 0) {
        // Read run length (little-endian)
        u64 num_clusters = std::mem::read_unsigned(
            $ - (RunList_Header.SE_Offset + RunList_Header.Length),
            RunList_Header.Length);

        // Read signed LCN delta
        s64 lcn_delta = std::mem::read_signed(
            $ - RunList_Header.SE_Offset,
            RunList_Header.SE_Offset);

        u64 data_size = num_clusters * cluster_size;
        u64 content_offset = VBR_OFFSET + (lcn_delta * cluster_size);

        // Show both decimal LCN and absolute byte offset in the label
        char Start_LCN[RunList_Header.SE_Offset] @ $ - RunList_Header.SE_Offset
            [[name(std::format("Start_LCN {} | Offset 0x{:X}   ",
                lcn_delta,
                content_offset)),
              comment("Starting Logical Cluster Number")]];

        // Pointer to the file content
        char MAGIC_BYTES[4] @ content_offset - VBR_OFFSET				//u8 as needed...
            [[comment("Pointer to Start Cluster"), static, sealed]];
            
        // Select all allocated clusters for easy Section View
        // May error - array grew past end of data....
        //u8 CLUSTER_CONTENT[data_size] @ content_offset - VBR_OFFSET
        //    [[comment("Pointer to Cluster Content"), static, sealed]];
		//if (MAGIC_BYTES == 0xFFD8FF) {
		//	IMPORT AND CALL jpeg.hexpat
		//}
    }

    // Look ahead at the next byte to detect another run
    u8 next_byte @ $ [[hidden]];

    if (next_byte != 0x00) {
        RUNLIST Next_Run;  // recursively parse next run
    }
} [[inline]];

fn calc_lcn_str(u64 start_offset, u32 len) {
    if (len == 0) 
        return "0";
    return std::mem::read_unsigned(start_offset, len);
};

// -------------------------------------------------------------------------
// SIGNATURE HELPER
// -------------------------------------------------------------------------
enum VBRSignature : u16 {
	VBR_SIG = 0xAA55
};

// -------------------------------------------------------------------------
// WINDOWS FILETIME FUNC
// -------------------------------------------------------------------------
fn parse_filetime(u64 raw_ft) {
    // Convert raw FILETIME to Unix time
    u64 unix_time = type::impl::format_filetime_as_unix(raw_ft);

    // Convert Unix time to structured UTC time
    std::time::Time ts = std::time::to_utc(unix_time);

    // Format as string
    str formatted = std::time::format(ts, "%Y-%m-%d %H:%M:%S");

    return formatted;
};

// -------------------------------------------------------------------------
// NTFS VOLUME BOOT RECORD RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
struct BIOS_PARAMETER_BLOCK {
    u16 bytes_per_sector					[[comment("Bytes per Sector")]];
    u8  sectors_per_cluster					[[comment("Sectors per Cluster")]];
    u16 reserved_sectors					[[comment("Reserved")]];;
    u8  fats								[[comment("Zeros")]];;
    u16 root_entries						[[comment("Unused")]];
    u16 sectors								[[comment("Unused")]];
    u8  media_descriptor 					[[comment("Always F8-2003+")]];
    u16 sectors_per_fat						[[comment("Legacy")]];
    u16 sectors_per_track					[[comment("Legacy")]];
    u16 heads								[[comment("Legacy")]];
    u32 hidden_sectors						[[comment("Sectors before Volume")]];
    u32 large_sectors						[[comment("Legacy")]];
};

// -------------------------------------------------------------------------
// FILE RECORD ENTRY RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
enum NTFS_RECORD_TYPES : u32 {
    magic_FILE  							= 0x454c4946,
    magic_INDX  							= 0x58444e49,   
    magic_HOLE  							= 0x454c4f48,
    magic_RSTR  							= 0x52545352,
    magic_RCRD  							= 0x44524352,
    magic_CHKD  							= 0x444b4843,
    magic_BAAD  							= 0x44414142,
    magic_empty 							= 0xffffffff,
};

// For other records, such as Index
struct NTFS_RECORD {
    NTFS_RECORD_TYPES magic					[[comment("File Record Signature 'FILE'")]];;
    u16 usa_ofs								[[comment("Offset to Fix Up Array")]];
    u16 usa_count							[[comment("# of 2 Byte Entries in FUA")]];
};

enum MFT_RECORD_FLAGS : u16 {
	MFT_RECORD_NOT_IN_USE					= 0x0000,
    MFT_RECORD_IN_USE           			= 0x0001,
    MFT_RECORD_IS_DIRECTORY     			= 0x0002,
    MFT_RECORD_IS_4             			= 0x0004,
    MFT_RECORD_IS_VIEW_INDEX    			= 0x0008,
    MFT_REC_SPACE_FILLER        			= 0xffff,
};

// -------------------------------------------------------------------------
// FILE RECORD ATTRIBUTE RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
enum ATTR_TYPES : u32 {
    AT_UNUSED                       		= 0x00,
    AT_STANDARD_INFORMATION         		= 0x10,
    AT_ATTRIBUTE_LIST               		= 0x20,
    AT_FILE_NAME                   			= 0x30,
    AT_OBJECT_ID                    		= 0x40,
    AT_SECURITY_DESCRIPTOR          		= 0x50,
    AT_VOLUME_NAME                  		= 0x60,
    AT_VOLUME_INFORMATION           		= 0x70,
    AT_DATA                         		= 0x80,
    AT_INDEX_ROOT                   		= 0x90,
    AT_INDEX_ALLOCATION             		= 0xa0,
    AT_BITMAP                       		= 0xb0,
    AT_REPARSE_POINT                		= 0xc0,
    AT_EA_INFORMATION               		= 0xd0,
    AT_EA                           		= 0xe0,
    AT_PROPERTY_SET                 		= 0xf0,
    AT_LOGGED_UTILITY_STREAM        		= 0x100,
    AT_FIRST_USER_DEFINED_ATTRIBUTE 		= 0x1000,
    AT_END                          		= 0xffffffff,
};

enum ATTR_DEF_FLAGS : u32 {
	ATTR_DEF_INDEXABLE	    				= 0x02,
	ATTR_DEF_MULTIPLE	    				= 0x04,
	ATTR_DEF_NOT_ZERO	    				= 0x08,
	ATTR_DEF_INDEXED_UNIQUE					= 0x10,
	ATTR_DEF_NAMED_UNIQUE					= 0x20,
	ATTR_DEF_RESIDENT	    				= 0x40,
	ATTR_DEF_ALWAYS_LOG	    				= 0x80,
};

enum COLLATION_RULES : u32 {
    COLLATION_BINARY                		= 0,
    COLLATION_FILE_NAME             		= 1,
    COLLATION_UNICODE_STRING        		= 2,
    COLLATION_NTOFS_ULONG           		= 16,
    COLLATION_NTOFS_SID             		= 17,
    COLLATION_NTOFS_SECURITY_HASH   		= 18,
    COLLATION_NTOFS_ULONGS          		= 19,
};

struct ATTR_DEF {
    //ntfschar name[0x40];
    char16 name[0x40];
    ATTR_TYPES type;
    u32 display_rule;
    COLLATION_RULES collation_rule;
    ATTR_DEF_FLAGS flags;
    u64 min_size;
    u64 max_size;
};

enum ATTR_FLAGS : u16 {
    ATTR_IS_COMPRESSED      				= 0x0001,
    ATTR_COMPRESSION_MASK   				= 0x00ff,
    ATTR_IS_ENCRYPTED       				= 0x4000,
    ATTR_IS_SPARSE          				= 0x8000,
};

enum RESIDENT_ATTR_FLAGS : u8 {
    RESIDENT_ATTR_IS_INDEXED = 0x01,
    RESIDENT_ATTR_NOT_INDEXED = 0x00,
};

enum FILE_ATTR_FLAGS : u32 {
    FILE_ATTR_READONLY              		= 0x00000001,
    FILE_ATTR_HIDDEN                		= 0x00000002,
    FILE_ATTR_SYSTEM                		= 0x00000004,
    FILE_ATTR_DIRECTORY             		= 0x00000010,
    FILE_ATTR_ARCHIVE               		= 0x00000020,
    FILE_ATTR_DEVICE                		= 0x00000040,
    FILE_ATTR_NORMAL                		= 0x00000080,
    FILE_ATTR_TEMPORARY             		= 0x00000100,
    FILE_ATTR_SPARSE_FILE           		= 0x00000200,
    FILE_ATTR_REPARSE_POINT         		= 0x00000400,
    FILE_ATTR_COMPRESSED            		= 0x00000800,
    FILE_ATTR_OFFLINE               		= 0x00001000,
    FILE_ATTR_NOT_CONTENT_INDEXED   		= 0x00002000,
    FILE_ATTR_ENCRYPTED             		= 0x00004000,
    FILE_ATTRIBUTE_RECALL_ON_OPEN   		= 0x00040000,
    FILE_ATTR_VALID_FLAGS           		= 0x00047fb7,
    FILE_ATTR_VALID_SET_FLAGS       		= 0x000031a7,
    FILE_ATTR_I30_INDEX_PRESENT     		= 0x10000000,
    FILE_ATTR_VIEW_INDEX_PRESENT    		= 0x20000000,
};

enum FILE_NAME_TYPE_FLAGS : u8 {
    FILE_NAME_POSIX             			= 0x00,
    FILE_NAME_WIN32             			= 0x01,
    FILE_NAME_DOS               			= 0x02,
    FILE_NAME_WIN32_AND_DOS     			= 0x03,
};

// -------------------------------------------------------------------------
// STANDARD INFO ATTRIBUTE RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
struct STANDARD_INFORMATION_BODY_OLD {
	u64 Created_DT_UTC						[[format("parse_filetime"), comment("Created DT UTC")]];
	u64 Modified_DT_UTC   					[[format("parse_filetime"), comment("Modified DT UTC")]];
	u64 MFT_Mod_DT_UTC						[[format("parse_filetime"), comment("$MFT Mod DT UTC")]];
	u64 Accessed_DT_UTC   					[[format("parse_filetime"), comment("Accessed DT UTC")]];
    FILE_ATTR_FLAGS file_attributes			[[comment("RASH ATTR")]];;
} [[static]];

struct STANDARD_INFORMATION_OLD {
	u64 Created_DT_UTC						[[format("parse_filetime"), comment("Created DT UTC")]];
	u64 Modified_DT_UTC   					[[format("parse_filetime"), comment("Modified DT UTC")]];
	u64 MFT_Mod_DT_UTC						[[format("parse_filetime"), comment("$MFT Mod DT UTC")]];
	u64 Accessed_DT_UTC   					[[format("parse_filetime"), comment("Accessed DT UTC")]];
    FILE_ATTR_FLAGS file_attributes			[[comment("RASH ATTR")]];;
    u8 reserved12[12];
} [[static]];

struct STANDARD_INFORMATION {
	u64 Created_DT_UTC						[[format("parse_filetime"), comment("Created DT UTC")]];
	u64 Modified_DT_UTC   					[[format("parse_filetime"), comment("Modified DT UTC")]];
	u64 MFT_Mod_DT_UTC						[[format("parse_filetime"), comment("$MFT Mod DT UTC")]];
	u64 Accessed_DT_UTC   					[[format("parse_filetime"), comment("Accessed DT UTC")]];
    FILE_ATTR_FLAGS file_attributes			[[comment("RASH ATTR")]];;

    u32 maximum_versions					[[comment("Maximum Versions Allowed: Disabled = 0x00")]];;
    u32 version_number						[[comment("File Version Number")]];;
    u32 class_id							[[comment("Class ID")]];;
    u32 owner_id							[[comment("Owner ID - $Quota")]];;
    u32 security_id							[[comment("Security Permission Settings")]];;
    u64 quota_charged						[[comment("Number of Bytes Towards User Quota")]];;
    u64 usn									[[comment("Update Sequence Number - $USNJournal Index")]];;
} [[static]];

struct FILE_NAME_ATTR_PACKED {
    u16 packed_ea_size						[[comment("Size of xE0 ATTR")]];;
    u16 reserved							[[comment("Reserved")]];;
} [[static]];

union FILE_NAME_ATTR_FORM {
    FILE_NAME_ATTR_PACKED packed;			// [[inline]];
    u32 reparse_point_tag					[[comment("Reparse Point Tag")]];;
} [[static]];

struct FILE_NAME_ATTR {    
    PRENT_MFT = 0x00;
    PRENT_SEQ = 0x00;
    
    u8 MFT_Parent_Dir[6]					[[comment("Parent Directory $MFT File Record Number")]];
    u16 Parent_Seq_Num						[[comment("Parent Directory $MFT Sequence Number")]];
	u64 Created_DT_UTC						[[format("parse_filetime"), comment("Created DT in UTC")]];
	u64 Modified_DT_UTC   					[[format("parse_filetime"), comment("Modified DT in UTC")]];
	u64 MFT_Mod_DT_UTC						[[format("parse_filetime"), comment("MFT Mod DT in UTC")]];
	u64 Accessed_DT_UTC   					[[format("parse_filetime"), comment("Accessed DT in UTC")]];
    u64 allocated_size						[[comment("Size on Disk")]];
    u64 data_size							[[comment("Logical File Size")]];
    FILE_ATTR_FLAGS file_attributes			[[comment("RASH ATTR")]];
    FILE_NAME_ATTR_FORM form				[[inline, comment("Reparse Value")]];
    u8 file_name_length						[[comment("File Name Length")]];
    FILE_NAME_TYPE_FLAGS file_name_type		[[comment("Namespace Type: POSIX = 0x00 | Win32 = 0x01 | DOS_SFN = 0x02 | Win32&DOS = 0x03")]];
    char16 file_name[file_name_length]		[[comment("The Actual File Name")]];
    
    PRENT_MFT = MFT_Parent_Dir;
    PRENT_SEQ = Parent_Seq_Num;
};

// -------------------------------------------------------------------------
// SECURITY DESC | OBJECT ID RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
struct OBJECT_ID_ATTR_INFO {
    type::GUID birth_volume_id;
    type::GUID birth_object_id;
    type::GUID domain_id;
};

union OBJECT_ID_ATTR_FORM {
    OBJECT_ID_ATTR_INFO info [[inline]];
    u8 extended_info[48];
};

struct OBJECT_ID_ATTR {
    type::GUID object_id;
    OBJECT_ID_ATTR_FORM form [[inline]];
};

enum VOLUME_FLAGS : u16 {
    VOLUME_IS_DIRTY             			= 0x0001,
    VOLUME_RESIZE_LOG_FILE      			= 0x0002,
    VOLUME_UPGRADE_ON_MOUNT     			= 0x0004,
    VOLUME_MOUNTED_ON_NT4       			= 0x0008,
    VOLUME_DELETE_USN_UNDERWAY  			= 0x0010,
    VOLUME_REPAIR_OBJECT_ID     			= 0x0020,
    VOLUME_CHKDSK_UNDERWAY      			= 0x4000,
    VOLUME_MODIFIED_BY_CHKDSK   			= 0x8000,
    VOLUME_FLAGS_MASK           			= 0xc03f,
};

struct VOLUME_INFORMATION {
    u64 reserved;
    u8 major_ver;
    u8 minor_ver;
    VOLUME_FLAGS flags;
    NT_Major = major_ver;
    NT_Minor = minor_ver;
} [[static]];

enum SECURITY_DESCRIPTOR_CONTROL : u16 {
    SE_OWNER_DEFAULTED          			= 0x0001,
    SE_GROUP_DEFAULTED          			= 0x0002,
    SE_DACL_PRESENT             			= 0x0004,
    SE_DACL_DEFAULTED           			= 0x0008,
    SE_SACL_PRESENT             			= 0x0010,
    SE_SACL_DEFAULTED           			= 0x0020,
    SE_DACL_AUTO_INHERIT_REQ    			= 0x0100,
    SE_SACL_AUTO_INHERIT_REQ    			= 0x0200,
    SE_DACL_AUTO_INHERITED      			= 0x0400,
    SE_SACL_AUTO_INHERITED      			= 0x0800,
    SE_DACL_PROTECTED           			= 0x1000,
    SE_SACL_PROTECTED           			= 0x2000,
    SE_RM_CONTROL_VALID         			= 0x4000,
    SE_SELF_RELATIVE            			= 0x8000,
};


// ------------------------------
// Enums
// ------------------------------
enum ACE_TYPES : u8 {
    ACCESS_MIN_MS_ACE_TYPE                  = 0,
    ACCESS_ALLOWED_ACE_TYPE                 = 0,
    ACCESS_DENIED_ACE_TYPE                  = 1,
    SYSTEM_AUDIT_ACE_TYPE                   = 2,
    SYSTEM_ALARM_ACE_TYPE                   = 3,
    ACCESS_MAX_MS_V2_ACE_TYPE               = 3,
    ACCESS_ALLOWED_COMPOUND_ACE_TYPE        = 4,
    ACCESS_MAX_MS_V3_ACE_TYPE               = 4,
    ACCESS_MIN_MS_OBJECT_ACE_TYPE           = 5,
    ACCESS_ALLOWED_OBJECT_ACE_TYPE          = 5,
    ACCESS_DENIED_OBJECT_ACE_TYPE           = 6,
    SYSTEM_AUDIT_OBJECT_ACE_TYPE            = 7,
    SYSTEM_ALARM_OBJECT_ACE_TYPE            = 8,
    ACCESS_MAX_MS_OBJECT_ACE_TYPE           = 8,
    ACCESS_MAX_MS_V4_ACE_TYPE               = 8,
    ACCESS_MAX_MS_ACE_TYPE                  = 8,
    ACCESS_ALLOWED_CALLBACK_ACE_TYPE        = 9,
    ACCESS_DENIED_CALLBACK_ACE_TYPE         = 10,
    ACCESS_ALLOWED_CALLBACK_OBJECT_ACE_TYPE = 11,
    ACCESS_DENIED_CALLBACK_OBJECT_ACE_TYPE  = 12,
    SYSTEM_AUDIT_CALLBACK_ACE_TYPE          = 13,
    SYSTEM_ALARM_CALLBACK_ACE_TYPE          = 14,
    SYSTEM_AUDIT_CALLBACK_OBJECT_ACE_TYPE   = 15,
    SYSTEM_ALARM_CALLBACK_OBJECT_ACE_TYPE   = 16,
    SYSTEM_MANDATORY_LABEL_ACE_TYPE         = 17,
    SYSTEM_RESOURCE_ATTRIBUTE_ACE_TYPE      = 18,
    SYSTEM_SCOPED_POLICY_ID_ACE_TYPE        = 19,
    SYSTEM_PROCESS_TRUST_LABEL_ACE_TYPE     = 20,
};

enum ACE_FLAGS : u8 {
    OBJECT_INHERIT_ACE          			= 0x01,
    CONTAINER_INHERIT_ACE       			= 0x02,
    NO_PROPAGATE_INHERIT_ACE    			= 0x04,
    INHERIT_ONLY_ACE            			= 0x08,
    INHERITED_ACE               			= 0x10,
    VALID_INHERIT_FLAGS         			= 0x1f,
    SUCCESSFUL_ACCESS_ACE_FLAG  			= 0x40,
    FAILED_ACCESS_ACE_FLAG      			= 0x80,
};

enum ACCESS_MASK : u32 {
    FILE_READ_DATA              			= 0x00000001,
    FILE_LIST_DIRECTORY         			= 0x00000001,
    FILE_WRITE_DATA             			= 0x00000002,
    FILE_ADD_FILE               			= 0x00000002,
    FILE_APPEND_DATA            			= 0x00000004,
    FILE_ADD_SUBDIRECTORY       			= 0x00000004,
    FILE_READ_EA                			= 0x00000008,
    FILE_WRITE_EA               			= 0x00000010,
    FILE_EXECUTE                			= 0x00000020,
    FILE_TRAVERSE               			= 0x00000020,
    FILE_DELETE_CHILD           			= 0x00000040,
    FILE_READ_ATTRIBUTES        			= 0x00000080,
    FILE_WRITE_ATTRIBUTES       			= 0x00000100,
    DELETE                      			= 0x00010000,
    READ_CONTROL                			= 0x00020000,
    WRITE_DAC                   			= 0x00040000,
    WRITE_OWNER                 			= 0x00080000,
    SYNCHRONIZE                 			= 0x00100000,
    STANDARD_RIGHTS_READ        			= 0x00020000,
    STANDARD_RIGHTS_WRITE       			= 0x00020000,
    STANDARD_RIGHTS_EXECUTE     			= 0x00020000,
    STANDARD_RIGHTS_REQUIRED    			= 0x000f0000,
    STANDARD_RIGHTS_ALL         			= 0x001f0000,
    ACCESS_SYSTEM_SECURITY      			= 0x01000000,
    MAXIMUM_ALLOWED             			= 0x02000000,
    GENERIC_ALL                 			= 0x10000000,
    GENERIC_EXECUTE             			= 0x20000000,
    GENERIC_WRITE               			= 0x40000000,
    GENERIC_READ                			= 0x80000000,
};

enum OBJECT_ACE_FLAGS : u32 {
    ACE_OBJECT_TYPE_PRESENT             	= 1,
    ACE_INHERITED_OBJECT_TYPE_PRESENT   	= 2,
};

// ------------------------------
// ACE/SID
// ------------------------------
struct ACE_HEADER {
    ACE_TYPES type;
    ACE_FLAGS flags;
    u16 size;
};

struct SID {
    u8  revision;
    u8  sub_authority_count;
    u8  identifier_authority[6];
    u32 sub_authority[sub_authority_count];
};

struct ACCESS_ALLOWED_ACE {
    ACE_HEADER header [[inline]];
    ACCESS_MASK mask;
    SID sid;
};

using ACCESS_DENIED_ACE = ACCESS_ALLOWED_ACE;
using SYSTEM_ALARM_ACE  = ACCESS_ALLOWED_ACE;
using SYSTEM_AUDIT_ACE  = ACCESS_ALLOWED_ACE;

struct ACCESS_ALLOWED_OBJECT_ACE {
    ACE_HEADER header [[inline]];
    ACCESS_MASK mask;
    OBJECT_ACE_FLAGS object_flags;
    type::GUID object_type;
    type::GUID inherited_object_type;
    SID sid;
};

using ACCESS_DENIED_OBJECT_ACE = ACCESS_ALLOWED_OBJECT_ACE;
using SYSTEM_AUDIT_OBJECT_ACE  = ACCESS_ALLOWED_OBJECT_ACE;
using SYSTEM_ALARM_OBJECT_ACE  = ACCESS_ALLOWED_OBJECT_ACE;

// ------------------------------
// ACE HELPER
// ------------------------------
union ACE {
    ACE_HEADER hdr [[hidden]];

    match (hdr.type) {
        (ACE_TYPES::ACCESS_ALLOWED_ACE_TYPE):        ACCESS_ALLOWED_ACE allowed;
        (ACE_TYPES::ACCESS_DENIED_ACE_TYPE):         ACCESS_DENIED_ACE denied;
        (ACE_TYPES::SYSTEM_AUDIT_ACE_TYPE):          SYSTEM_AUDIT_ACE audit;
        (ACE_TYPES::SYSTEM_ALARM_ACE_TYPE):          SYSTEM_ALARM_ACE alarm;

        (ACE_TYPES::ACCESS_ALLOWED_OBJECT_ACE_TYPE): ACCESS_ALLOWED_OBJECT_ACE obj_allowed;
        (ACE_TYPES::ACCESS_DENIED_OBJECT_ACE_TYPE):  ACCESS_DENIED_OBJECT_ACE obj_denied;
        (ACE_TYPES::SYSTEM_AUDIT_OBJECT_ACE_TYPE):   SYSTEM_AUDIT_OBJECT_ACE obj_audit;
        (ACE_TYPES::SYSTEM_ALARM_OBJECT_ACE_TYPE):   SYSTEM_ALARM_OBJECT_ACE obj_alarm;
    }

    // Consume remaining bytes as raw padding
    padding[hdr.size - sizeof(ACE_HEADER)]; 
};

// ------------------------------
// ACL
// ------------------------------
struct ACL {
    u8  revision;
    u8  alignment1;
    u16 size;
    u16 ace_count;
    u16 alignment2;

    ACE aces[ace_count];
};

// ------------------------------
// SECURITY DESCRIPTOR
// ------------------------------
#define SECURITY_DESCRIPTOR_RELATIVE_SIZE (20)
struct SECURITY_DESCRIPTOR_RELATIVE {
    u32 struct_start = $;
    u8      revision;
    u8      alignment;
    u16     control; 						// SECURITY_DESCRIPTOR_CONTROL
    u32     owner;
    u32     group;
    u32     sacl;
    u32     dacl;

	if (control & SECURITY_DESCRIPTOR_CONTROL::SE_DACL_PRESENT) {
    	if (dacl != 0) {
        	// Skip to the relative offset
        	if ($ - struct_start < dacl) {
            	padding[dacl - ($ - struct_start)];
        	}
        	ACL dacl_acl;
    	}
	}
	if (control & SECURITY_DESCRIPTOR_CONTROL::SE_SACL_PRESENT) {
    	if (sacl != 0) {
        	if ($ - struct_start < sacl) {
            	padding[sacl - ($ - struct_start)];
        	}
        	ACL sacl_acl;
    	}
	}

    if (owner > 0) {
        u32 owner_bytes = $ - struct_start;
        if (owner > owner_bytes) {
            padding[owner - owner_bytes];
        }
        SID owner_sid;
    }

    if (group > 0) {
        u32 group_bytes = $ - struct_start;
        if (group > group_bytes) {
            padding[group - group_bytes];
        }
        SID group_sid;
    }
};

// -------------------------------------------------------------------------
// INDEX RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ------------------------------
// INDEX HEADER HELPER
// ------------------------------
enum INDEX_HEADER_FLAGS : u8 {
    SMALL_INDEX = 0,
    LARGE_INDEX = 1,
    LEAF_NODE   = 0,
    INDEX_NODE  = 1,
    NODE_MASK   = 1,
};

// ------------------------------
// INDEX HEADER PARSER
// ------------------------------
struct INDEX_HEADER {
    u32 entries_offset;
    u32 index_length;
    u32 allocated_size;
    INDEX_HEADER_FLAGS ih_flags;
    u8 reserved[3];
};

// ------------------------------
// REPARSE INDEX KEY PARSER
// ------------------------------
struct REPARSE_INDEX_KEY {
    u32 reparse_tag;
    leMFT_REF file_id;
};

// ------------------------------
// SDS_ENTRY PARSER
// ------------------------------
struct SDS_ENTRY {
    u32 hash;
    u32 security_id;
    u64 offset;
    u32 length;
    SECURITY_DESCRIPTOR_RELATIVE sid;
};

using SII_INDEX_KEY = u32 ;

// ------------------------------
// SDH INDEX KEY PARSER
// ------------------------------
struct SDH_INDEX_KEY {
    u32  hash;
    u32  security_id;
};

// ------------------------------
// INDEX ENTRY FLAG HELPER
// ------------------------------
enum INDEX_ENTRY_FLAGS : u16 {
    INDEX_ENTRY_NODE 						= 1,
    INDEX_ENTRY_END  						= 2,
    INDEX_ENTRY_SPACE_FILLER 				= 0xffff,
};

// ------------------------------
// INDEX HEADER POINTER
// ------------------------------
struct INDEX_ENTR_HEADER_PTR {
    u16 data_offset;
    u16 data_length;
    u32 reservedV;
};

// ------------------------------
// INDEX HEADER HELPER
// ------------------------------
union INDEX_ENTR_HEADER_REF {
    leMFT_REF indexed_file;
    INDEX_ENTR_HEADER_PTR ptr;
};

// ------------------------------
// INDEX HEADER PARSER
// ------------------------------
struct INDEX_ENTRY_HEADER {
    INDEX_ENTR_HEADER_REF file_ref;
    u16 length;
    u16 key_length;
    u16 flags; // INDEX_ENTRY_FLAGS
    u16 reserved;
};

// ------------------------------
// INDEX ENTRY FN ATTR
// Duplicated so that parent mft# and parent seq# tracking doesn't break.
// ------------------------------
struct IDX_FILE_NAME_ATTR{    
    u8 MFT_Parent_Dir[6]					[[comment("Parent Directory $MFT File Record Number")]];
    u16 Parent_Seq_Num						[[comment("Parent Directory $MFT Sequence Number")]];
	u64 Created_DT_UTC						[[format("parse_filetime"), comment("Created DT in UTC")]];
	u64 Modified_DT_UTC   					[[format("parse_filetime"), comment("Modified DT in UTC")]];
	u64 MFT_Mod_DT_UTC						[[format("parse_filetime"), comment("MFT Mod DT in UTC")]];
	u64 Accessed_DT_UTC   					[[format("parse_filetime"), comment("Accessed DT in UTC")]];
    u64 allocated_size						[[comment("Size on Disk")]];
    u64 data_size							[[comment("Logical File Size")]];
    FILE_ATTR_FLAGS file_attributes			[[comment("RASH ATTR")]];
    FILE_NAME_ATTR_FORM form				[[inline, comment("Reparse Value")]];
    u8 file_name_length						[[comment("File Name Length")]];
    FILE_NAME_TYPE_FLAGS file_name_type		[[comment("Namespace Type: POSIX = 0x00 | Win32 = 0x01 | DOS_SFN = 0x02 | Win32&DOS = 0x03")]];
    char16 file_name[file_name_length]		[[comment("The Actual File Name")]];
};

// ------------------------------
// INDEX ENTRY FN PARSER
// ------------------------------
struct INDEX_ENTRY_FILE_NAME {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        // Workaround -- Using new structure for IDX FNs -- Allows for setting parent info on non-IDX items
        IDX_FILE_NAME_ATTR key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY SII PARSER
// ------------------------------
struct INDEX_ENTRY_SII {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        SII_INDEX_KEY key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }

    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY SDH PARSER
// ------------------------------
struct INDEX_ENTRY_SDH {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        SDH_INDEX_KEY key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY OBJECT ID PARSER
// ------------------------------
struct INDEX_ENTRY_OBJ_ID {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        type::GUID key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY REPARSE POINT PARSER
// ------------------------------
struct INDEX_ENTRY_REPARSE {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        REPARSE_INDEX_KEY key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY SID PARSER
// ------------------------------
struct INDEX_ENTRY_SID {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        SID key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX ENTRY OWNER ID PARSER
// ------------------------------
struct INDEX_ENTRY_OWNER_ID {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        u64 key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }
    std::mem::AlignTo<8>;
};

// ------------------------------
// INDEX FLAGS FUNC
// ------------------------------
fn index_get_flags(u64 offset) {
    INDEX_ENTRY_HEADER index_entry_header @ offset;
    return index_entry_header.flags;
};

// ------------------------------
// INDEX BLOCK PARSER
// ------------------------------
struct INDEX_BLOCK {
    NTFS_RECORD header [[inline]];
    leLSN   lsn;
    leVCN   index_block_vcn;
    
    u32 index_head = $;
    INDEX_HEADER index;

    if (index.entries_offset > sizeof (index)) {
        padding[index.entries_offset - sizeof (index)];
    }

    INDEX_ENTRY_FILE_NAME ents[while(!(index_get_flags($) & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END))];
    INDEX_ENTRY_FILE_NAME ent_end;

    u32 index_used = $ - index_head;
    if (index.index_length > index_used) {
        padding[index.index_length - index_used];
    }
};

// ------------------------------
// INDEX ROOT PARSER
// ------------------------------
struct INDEX_ROOT {
    ATTR_TYPES type;
    COLLATION_RULES collation_rule;
    u32 index_block_size;
    s8  clusters_per_index_block;
    u8  reserved[3] 						[[static, sealed]];

    u32 index_head = $;
    INDEX_HEADER index;

    if (index.entries_offset > sizeof (index)) {
        padding[index.entries_offset - sizeof (index)];
    }

    match (type) {
        (ATTR_TYPES::AT_FILE_NAME): {
            INDEX_ENTRY_FILE_NAME ents[while(!(index_get_flags($) & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END))];
            INDEX_ENTRY_FILE_NAME ent_end;
        }
    }

    u32 index_used = $ - index_head;
    if (index.index_length > index_used) {
        padding[index.index_length - index_used];
    }
};

// -------------------------------------------------------------------------
// RESTART AREA RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ------------------------------
// RESTART AREA HEADER PARSER
// ------------------------------
struct RESTART_PAGE_HEADER {
    NTFS_RECORD_TYPES magic;
    u16 usa_ofs;
    u16 usa_count;
    leLSN chkdsk_lsn;
    u32 system_page_size;
    u32 log_page_size;
    u16 restart_area_offset;
    u16 minor_ver;
    u16 major_ver;
    u16 usn;
};

// ------------------------------
// RESTART AREA FLAG PARSER
// ------------------------------
enum RESTART_AREA_FLAGS : u16 {
	RESTART_VOLUME_IS_CLEAN	= 0x0002,
	RESTART_SPACE_FILLER	= 0xffff,
};

// ------------------------------
// RESTART AREA PARSER
// ------------------------------
struct RESTART_AREA {
    leLSN current_lsn;
    u16 log_clients;
    u16 client_free_list;
    u16 client_in_use_list;
    RESTART_AREA_FLAGS flags;
    u32 seq_number_bits;
    u16 restart_area_length;
    u16 client_array_offset;
    u64 file_size;
    u32 last_lsn_data_length;
    u16 log_record_header_length;
    u16 log_page_data_offset;
    u32 restart_log_open_count;
    u32 reserved;
};

// -------------------------------------------------------------------------
// LOG CLIENT RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ------------------------------
// LOG CLIENT PARSER
// ------------------------------
struct LOG_CLIENT_RECORD {
    leLSN oldest_lsn;
    leLSN client_restart_lsn;
    u16 prev_client;
    u16 next_client;
    u16 seq_number;
    u8  reserved[6];
    u32 client_name_length;
    //ntfschar client_name[64];
	char16 client_name[64];
};

// -------------------------------------------------------------------------
// ATTRIBUTE RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ------------------------------
// xD0 ATTRIBUTE PARSER
// ------------------------------
struct EA_INFO_ENTRY {
	u16 EA_packed_size						[[comment("Size of the Packed Extended Attributes")]];
    u16 EA_Count							[[comment("Number of Extended Attributes which have NEED_EA set")]];
    u32 EA_unpacked_size					[[comment("Size of the Unpacked Extended Attributes")]];
};

// ------------------------------
// xE0 ATTRIBUTE PARSER
// ------------------------------
struct EA_ENTRY {
	u32 entry_size							[[comment("EA Size: Offset to Next Extended Attribute")]];
    u8 flags								[[comment("Flags: 0x80 = Needs EA")]];
    u8 name_length							[[comment("EA Name Size")]];
	u16 value_length						[[comment("EA Value Size")]];
    char name[name_length]					[[comment("EA Name: LXUID/LXGID/LXMOD/ETC")]];
    padding[2];
	char value[value_length]				[[comment("EA Value: Related to HPFS+ Compatibility")]];
};

// ------------------------------
// ATTRIBUTE DEFS
// ------------------------------
#define ATTR_RECORD_HEADER_SIZE                 (16)
#define ATTR_RECORD_RESIDENT_SIZE               (16 + 8)
#define ATTR_RECORD_NONRESIDENT_SIZE            (16 + 48)
#define ATTR_RECORD_NONRESIDENT_CMPR_SIZE       (16 + 48 + 8)

// ------------------------------
// ATTRIBUTE HEADER
// ------------------------------
struct ATTRHeader {
    	ATTR_TYPES type								[[comment("Attribute Identifier")]];				
    	u32 length									[[comment("Size of this ATTR")]];
    	u8  non_resident							[[comment("0 = Resident | 1 = Non-Resident")]];
    	u8  name_length								[[comment("Size of the ATTR Stream Name, if any")]];
    	u16 name_offset								[[comment("Offset to the ATTR Stream Name")]];
    	u16 flags									[[comment("0x0001 = Compressed | 0x4000 = Encrypted | 0x8000 = Sparse")]]; // ATTR_FLAGS
    	u16 instance								[[comment("Sequential Order: 0x0000 = 1st")]];

    	u32 name_offset_delta = 0;
    	
    	if (!non_resident) {
        	u32 value_length						[[comment("Size of Resident Data")]];
        	u16 value_offset						[[comment("Offset to Resident Data")]];
        	RESIDENT_ATTR_FLAGS resident_flags		[[comment("Indexed Flag: 0x01 = Indexed | 0x00 = Not Indexed")]];
        	s8 reservedR							[[comment("Reserved")]];

        	//if (name_offset > ATTR_RECORD_RESIDENT_SIZE) {
            //	name_offset_delta = name_offset - ATTR_RECORD_RESIDENT_SIZE; 
            //	padding[name_offset_delta];
        	//}
        	
        }
};

// ------------------------------
// ATTRIBUTE BODY NON_RESIDENT
// ------------------------------
struct ATTRBody {
	leVCN   lowest_vcn						[[comment("Start Virtual Cluster Number")]];
    leVCN   highest_vcn						[[comment("End Virtual Cluster Number")]];
    u16     mapping_pairs_offset			[[comment("Offset to RunList")]];
    u8      compression_unit				[[comment("Compression Unit Size")]];
    u8      reserved1[5]					[[comment("Reserved")]];
    u64     allocated_size					[[comment("Size on Disk")]];
    u64     data_size						[[comment("Logical File Size")]];
    u64     initialized_size				[[comment("Initialized Size: Typical for Downloads")]];
};

// ------------------------------
// ATTRIBUTE RECORD BODY RELATED
// ------------------------------
struct ATTR_RECORD {  
	ATTRHeader ATTR_HEADER 					[[name("Header")]];

    if (ATTR_HEADER.non_resident) {
		ATTRBody x80_xB0_Body 				[[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
        
        if (ATTR_HEADER.flags & ATTR_FLAGS::ATTR_IS_COMPRESSED) {
            u64 compressed_size				[[comment("Compressed Size")]];
            
            if (ATTR_HEADER.name_offset > ATTR_RECORD_NONRESIDENT_CMPR_SIZE) {
                name_offset_delta = ATTR_HEADER.name_offset - ATTR_RECORD_NONRESIDENT_CMPR_SIZE; 
                padding[name_offset_delta];
            }
        } else {
            if (ATTR_HEADER.name_offset > ATTR_RECORD_NONRESIDENT_SIZE) {
                name_offset_delta = ATTR_HEADER.name_offset - ATTR_RECORD_NONRESIDENT_SIZE; 
                padding[name_offset_delta];
            }
        }
    }

    u32 name_length_bytes = ATTR_HEADER.name_length * sizeof (ntfschar);
    
    if (ATTR_HEADER.name_length > 0) {
        char16 name[ATTR_HEADER.name_length];
    }

    if (ATTR_HEADER.non_resident) {
        if (ATTR_HEADER.flags & ATTR_FLAGS::ATTR_IS_COMPRESSED) {
            if (x80_xB0_Body.mapping_pairs_offset > (ATTR_RECORD_NONRESIDENT_CMPR_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes)) {
                padding[x80_xB0_Body.mapping_pairs_offset - (ATTR_RECORD_NONRESIDENT_CMPR_SIZE + name_length_bytes)];
            }
        } else {
            if (x80_xB0_Body.mapping_pairs_offset > (ATTR_RECORD_NONRESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes)) {
                padding[x80_xB0_Body.mapping_pairs_offset - (ATTR_RECORD_NONRESIDENT_SIZE + name_length_bytes)];
            }
        }
		
		RUNLIST x80_xB0_RUNLIST[]						[[name(attr_type_name(u32(ATTR_HEADER.type)) + "_RUNLIST"), comment("$DATA or $BITMAP Run")]];
    } else {
        
        u32 value_offset_delta = 0;
        if (ATTR_HEADER.value_offset > (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes)) {
            value_offset_delta = ATTR_HEADER.value_offset - (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes);
            padding[value_offset_delta];
        }

        match (ATTR_HEADER.type) {
            (ATTR_TYPES::AT_UNUSED): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
            	}
            }
            (ATTR_TYPES::AT_STANDARD_INFORMATION): {
                if (ATTR_HEADER.value_length > sizeof(STANDARD_INFORMATION_OLD)) {
                    STANDARD_INFORMATION x10_Body 		[[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];

                } else {
                    STANDARD_INFORMATION_OLD x10_Body	[[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
                }

                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta + sizeof (x10_Body));
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_ATTRIBUTE_LIST): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_FILE_NAME): FILE_NAME_ATTR x30_Body [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
            (ATTR_TYPES::AT_OBJECT_ID): {              
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_SECURITY_DESCRIPTOR): {
                SECURITY_DESCRIPTOR_RELATIVE x50_Body	[[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta + sizeof (x50_Body));
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            //(ATTR_TYPES::AT_VOLUME_NAME): char16 vol_name[ATTR_HEADER.value_length / sizeof (ntfschar)] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body"), comment("User Defined Volume Name")]];
            (ATTR_TYPES::AT_VOLUME_NAME): { char16 vol_name[ATTR_HEADER.value_length / sizeof (ntfschar)] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body"), comment("User Defined Volume Name")]];
            	Vol_Label = str(vol_name);
            }
            
            (ATTR_TYPES::AT_VOLUME_INFORMATION): VOLUME_INFORMATION vol_info;
            (ATTR_TYPES::AT_DATA): {
                char x80_xB0_Stream[ATTR_HEADER.value_length] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta + sizeof (x80_xB0_Stream));
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_INDEX_ROOT): {
                INDEX_ROOT x90_Body [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
            }
            (ATTR_TYPES::AT_INDEX_ALLOCATION): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_BITMAP): u8 buffer[ATTR_HEADER.value_length] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
            (ATTR_TYPES::AT_REPARSE_POINT): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_EA_INFORMATION): {
                u64 attr_start = $ - (ATTR_HEADER.non_resident ? ATTR_RECORD_NONRESIDENT_SIZE : ATTR_RECORD_RESIDENT_SIZE);
                EA_INFO_ENTRY xD0_Body[while($ - (attr_start + ATTR_HEADER.value_offset) < ATTR_HEADER.value_length)] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
            }
            (ATTR_TYPES::AT_EA): {
                u64 attr_start = $ - (ATTR_HEADER.non_resident ? ATTR_RECORD_NONRESIDENT_SIZE : ATTR_RECORD_RESIDENT_SIZE);
                EA_ENTRY xE0_Body[while($ - (attr_start + ATTR_HEADER.value_offset) < ATTR_HEADER.value_length)] [[name(attr_type_name(u32(ATTR_HEADER.type)) + "_Body")]];
            }
            (ATTR_TYPES::AT_PROPERTY_SET): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_LOGGED_UTILITY_STREAM): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_FIRST_USER_DEFINED_ATTRIBUTE): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + ATTR_HEADER.name_offset_delta + name_length_bytes + value_offset_delta);
                if (ATTR_HEADER.length > attr_sum) {
                    padding[ATTR_HEADER.length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_END): {
                 //length is no longer valid
            }
        }
    }
    std::mem::AlignTo<8>; 
};
	
// ------------------------------
// ATTRIBUTE TYPE FUNC
// ------------------------------
fn attr_get_type(u64 offset) {
    ATTR_RECORD ATTR @ offset;
    return ATTR.ATTR_HEADER.type;
};

// -------------------------------------------------------------------------
// FILE RECORD ENTRY RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------

// ------------------------------
// PRIMARY FILE RECORD HEADER PARSER
// ------------------------------
struct NTFS_RECORD_HDR {
    NTFS_RECORD_TYPES magic					[[comment("File Record Signature 'FILE'")]];;
    u16 usa_ofs								[[comment("Offset to Fix Up Array")]];
    u16 usa_count							[[comment("# of 2 Byte Entries in FUA")]];
    leLSN lsn								[[comment("$LogFile Sequence #")]];
    u16 sequence_number						[[comment("Count of FR Entry Usage: 1=Once/Not Del")]];
    u16 link_count							[[comment("(HARDLINK) Count of File Name ATTR")]];
    u16 attr_offset							[[comment("Offset to 1st ATTR")]];
    MFT_RECORD_FLAGS flags					[[comment("Allocation Status Flags: 0x00=Del File||0x01=Alloc.File||0x02=Del DIR||0x03=Alloc.DIR")]];;
    u32 bytes_in_use						[[comment("Logical Size of FR Entry")]];
    u32 bytes_allocated						[[comment("Phys (Alloc.) Size of FR Entry")]];
    leMFT_REF base_mft_record				[[comment("Ref to additional FR Entry, if any")]];
    u16 next_attr_instance					[[comment("Count of ATTRs")]];
    u16 FU_Array							[[comment("Fix Up Array and ATTR-NT3.0")]]; // 2 bytes NTFS 3.0 (LEGACY)
	
	if (FU_Array <= 0) {					// FU_Array not in use -- NTFS 3.1+
		u32 mft_record_number				[[comment("MFT File Record Num")]];	// 4 bytes
    	mft_num = mft_record_number;
    	seq_num = sequence_number;	
    				
    	if (usa_count > 0) {
        	u16 update_sequence[usa_count]	[[comment("Fix Up Array and ATTR-NT3.1+")]];
    	}
    } else {
    	padding[4];
    	mft_num += 0x01;					
    }
};									

// ------------------------------
// QUICK ATTRIBUTE CHECK
// ------------------------------
fn attr_type_name(u32 type) {
    if (type == ATTR_TYPES::AT_STANDARD_INFORMATION) 	return "STANDARD_INFORMATION";
    if (type == ATTR_TYPES::AT_ATTRIBUTE_LIST)       	return "ATTRIBUTE_LIST";
    if (type == ATTR_TYPES::AT_FILE_NAME)            	return "FILE_NAME";
    if (type == ATTR_TYPES::AT_OBJECT_ID)            	return "OBJECT_ID";
    if (type == ATTR_TYPES::AT_SECURITY_DESCRIPTOR)  	return "SECURITY_DESCRIPTOR";
    if (type == ATTR_TYPES::AT_VOLUME_NAME)          	return "VOLUME_NAME";
    if (type == ATTR_TYPES::AT_VOLUME_INFORMATION)   	return "VOLUME_INFORMATION";
    if (type == ATTR_TYPES::AT_DATA)                 	return "DATA";
    if (type == ATTR_TYPES::AT_INDEX_ROOT)           	return "INDEX_ROOT";
    if (type == ATTR_TYPES::AT_INDEX_ALLOCATION)     	return "INDEX_ALLOCATION";
    if (type == ATTR_TYPES::AT_BITMAP)               	return "BITMAP";
    if (type == ATTR_TYPES::AT_REPARSE_POINT)        	return "REPARSE_POINT";
    if (type == ATTR_TYPES::AT_EA_INFORMATION)       	return "EA_INFORMATION";
    if (type == ATTR_TYPES::AT_EA)                   	return "EA";
    if (type == ATTR_TYPES::AT_PROPERTY_SET)         	return "PROPERTY_SET";
    if (type == ATTR_TYPES::AT_LOGGED_UTILITY_STREAM) 	return "LOGGED_UTILITY_STREAM";
    return "UNKNOWN";
};

fn peek_attr_type(u64 offset) {
    return std::mem::read_unsigned(offset, 4); // first 4 bytes of ATTRHeader
};

// ------------------------------
// ATTRIBUTE WRAPPER
// ------------------------------
struct ATTR_WRAPPER {
    ATTR_RECORD ATTR 						[[name(attr_type_name(peek_attr_type($)))]];
} 											[[inline, name(attr_type_name(peek_attr_type($)))]];

// ------------------------------
// PATTERN NAMING FUNC
// ------------------------------
fn get_file_name(auto ATTRS) {
    str fname = "";

    for (u32 i = 0, i < std::core::member_count(ATTRS), i = i + 1) {
    	
        if (ATTRS[i].ATTR.ATTR_HEADER.type == ATTR_TYPES::AT_FILE_NAME) {
            u8 len = ATTRS[i].ATTR.x30_Body.file_name_length;

            for (u32 j = 0, j < len, j = j + 1) {
                char16 cu = ATTRS[i].ATTR.x30_Body.file_name[j];
                u8 c = u8(cu);  // Cast to low byte
                fname = std::format("{}{}", fname, char(c));
            }
            break;
        }
    }
    return fname;
};

// ------------------------------
// PRIMARY FILE RECORD PARSER
// ------------------------------
u64 start_index = 12; 						// First 12 are hard-coded - We're parsing the rest of the MFT Entries

struct MFT_RECORD {
    u64 record_start_offset = $;
    NTFS_RECORD_HDR FR_HEADER;
    
	if (FR_HEADER.flags == 0x00 || FR_HEADER.flags == 0x02) {
    	Unused_Count += 1;
	}
	if (FR_HEADER.flags == 0x01 || FR_HEADER.flags == 0x03) {
    	MFT_Count += 1;
	}

    std::mem::AlignTo<8>;    
    ATTR_WRAPPER ATTRS[while(attr_get_type($) != ATTR_TYPES::AT_END)] [[inline]];
    str filename = get_file_name(ATTRS);
    
    if (filename == "") {
    	PRENT_MFT = 0x00;
    	PRENT_SEQ = 0x00;
    	filename = "FILE_REC";
    }
 
    ATTR_RECORD ATTR_END [[static, name("ATTR_END")]] ;
    std::mem::AlignTo<record_start_offset + 1024>;
	
} [[name(format_element(filename, $, start_index)),
    comment("DEC:[MFT#][SEQ#] | HEX:[MFT#][SEQ#] | PARENT_HEX:[MFT#][SEQ#]")]];

fn format_element(auto filename, auto v, u64 offset) {
    return std::format("{}   [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", filename, mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ);
};


// -------------------------------------------------------------------------
// VOLUME BOOT RECORD RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------
// ------------------------------
// NTFS VBR 
// ------------------------------
struct NTFS_BOOT_SECTOR {
    u8  jmp_boot[3] 						[[comment("Jump Instructions")]]; 
    char oem_id[8] 							[[comment("FS IDENTIFIER")]];
    BIOS_PARAMETER_BLOCK bpb;
    u8  physical_drive						[[comment("Legacy")]];
    u8  current_head						[[comment("Legacy")]];
    u8  extended_boot_signature				[[comment("Legacy")]];
    u8  reserved1							[[comment("Legacy")]];
    u64 total_sectors 						[[comment("Volume Size in Sectors")]];
    u64 mft_lcn 							[[comment("MFT Start Cluster")]];
    u64 mftmirr_lcn 						[[comment("MFTMirror Start Cluster")]];
    u8  clusters_per_mft_record 			[[comment("Size of MFT/Mirror in Clusters")]];
    u8  reserved2[3] 						[[comment("Unused")]];
    u8  clusters_per_index_buffer 			[[comment("Size of Index Buffer")]];
    u8  reserved3[3] 						[[comment("Unused")]];
    u64 volume_serial 						[[comment("Volume Serial #")]];
    u32 checksum 							[[comment("VBR Sector CRC32")]];
    u8  bootstrap[426] 						[[comment("Boot-strapping Instructions")]];
    VBRSignature VBR_SIG 					[[comment("End of VBR - 0x55AA")]];
};    

// ------------------------------
// $DATA FUNC HELPER FOR INDEXES
// ------------------------------
fn mft_get_dat_attr_lcn(MFT_RECORD record, ATTR_TYPES type = ATTR_TYPES::AT_DATA) {
    u64 lcn = 0;

    for (u64 i = 0, i < record.FR_HEADER.next_attr_instance, i += 1) {
        if (record.ATTRS[i].ATTR.ATTR_HEADER.type == type) {
            for (s64 j = record.ATTRS[i].ATTR.x80_xB0_RUNLIST[0].RunList_Header.SE_Offset - 1, j >= 0, j -= 1) {
                lcn |= record.ATTRS[i].ATTR.x80_xB0_RUNLIST[0].Logical_Cluster_Num[j] << (8 * j);
            }
            break;
        }
    }
    return lcn;
};

// -------------------------------------------------------------------------
// MAIN ENTRY RELATED
// -------------------------------------------------------------------------
//   V		V		V		V		V		V		V		 V		   V		
// -------------------------------------------------------------------------

// ============= VBR =============================================================================================
NTFS_BOOT_SECTOR nbs @ $ [[name("NTFS_VBR")]];
u32 cluster_size = nbs.bpb.bytes_per_sector * nbs.bpb.sectors_per_cluster;
u32 mft_rec_size = 1 << -nbs.clusters_per_mft_record;

VBR_OFFSET = $ + (nbs.bpb.hidden_sectors - 1) * nbs.bpb.bytes_per_sector;

// ============= $MFT ============================================================================================
MFT_RECORD mft @ nbs.mft_lcn * cluster_size + 0 * mft_rec_size 
				[[name(std::format("$MFT         [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]",
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

MFT_RECORD mftmirr @ nbs.mftmirr_lcn * cluster_size 
				[[name(std::format("$MFT COPY    (DERIVED FROM $MFTMirr)"))]];

// ============= $MFTMirr ========================================================================================
MFT_RECORD mft_mirr @ nbs.mft_lcn * cluster_size + 1 * mft_rec_size 
				[[name(std::format("$MFT Mirror  [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $LogFile ========================================================================================
MFT_RECORD mft_log @ nbs.mft_lcn * cluster_size + 2 * mft_rec_size 
				[[name(std::format("$LogFile     [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $Volume =========================================================================================
MFT_RECORD mft_vol @ nbs.mft_lcn * cluster_size + 3 * mft_rec_size 
				[[name(std::format("$Volume      [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $AttrDef ========================================================================================
MFT_RECORD mft_adef @ nbs.mft_lcn * cluster_size + 4 * mft_rec_size 
				[[name(std::format("$AttrDef     [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

ATTR_DEF adef_dat_buf[16] @ mft_get_dat_attr_lcn(mft_adef) * cluster_size 
				[[name("$AttrDef ARRAY (DERIVED)")]];

// ============= $I30 (Root) =====================================================================================
MFT_RECORD mft_root @ nbs.mft_lcn * cluster_size + 5 * mft_rec_size 
				[[name(std::format("$I30 (Root)  [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];
INDEX_BLOCK root_index_block @ mft_get_dat_attr_lcn(mft_root, ATTR_TYPES::AT_INDEX_ALLOCATION) * cluster_size 
				[[name(std::format("$I30 (Root)  INDEX_BLOCK (DERIVED)"))]];

// ============= $Bitmap =========================================================================================
MFT_RECORD mft_bm @ nbs.mft_lcn * cluster_size + 6 * mft_rec_size 
				[[name(std::format("$Bitmap      [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $Boot ===========================================================================================
MFT_RECORD mft_boot @ nbs.mft_lcn * cluster_size + 7 * mft_rec_size 
				[[name(std::format("$Boot        [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $BadClus ========================================================================================
MFT_RECORD mft_badclus @ nbs.mft_lcn * cluster_size + 8 * mft_rec_size 
				[[name(std::format("$BadClus     [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $Secure ($Quota for NTFS 1.2) ===================================================================
MFT_RECORD mft_sec @ nbs.mft_lcn * cluster_size + 9 * mft_rec_size 
				[[name(std::format("$Secure      [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

// ============= $UpCase =========================================================================================
MFT_RECORD mft_uc @ nbs.mft_lcn * cluster_size + 10 * mft_rec_size 
				[[name(std::format("$UpCase      [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];
u8 uc_tbl[1] @  mft_get_dat_attr_lcn(mft_uc) * cluster_size [[name("$UpCase TABLE (DERIVED)")]];
	
// ============= $Extend =========================================================================================
MFT_RECORD mft_ext @ nbs.mft_lcn * cluster_size + 11 * mft_rec_size 
				[[name(std::format("$Extend      [{:02}][{:02}] | [x{:02X}][x{:02X}] | PRENT:[x{:02X}][x{:02X}]", 
													mft_num, seq_num, mft_num, seq_num, PRENT_MFT, PRENT_SEQ))]];

//============== RESERVED / UNUSED================================================================================
// RESERVED/UNUSED FILE RECORD ENTRIES 12-23 | 0x0C-0x17 (13th-24th)
	
// ============= NEXT RECORDS ====================================================================================
// ---- FUNC TO CHECK FILE RECORD MAGIC
fn fr_magic(u64 abs_off) {
    NTFS_RECORD_TYPES magic @ abs_off;
    return magic;
};

// ---- CALL THE NEXT RECORDS ARRAY
MFT_RECORD NEXT_RECORDS[while(fr_magic($) == NTFS_RECORD_TYPES::magic_FILE)] @ (nbs.mft_lcn * cluster_size + 12 * mft_rec_size) [[inline, static]];

// ============= REPORT ==========================================================================================
// ------------------------------
// NTFS VOLUME REPORT
// *** HAS GLOBAL AT TOP ***
// ------------------------------
u64 mft_offset = VBR_OFFSET + nbs.mft_lcn * cluster_size + 0 * mft_rec_size;
u64 mft_mrr_offset = VBR_OFFSET + nbs.mftmirr_lcn * cluster_size;
u64 rootDir_offset = VBR_OFFSET + mft_get_dat_attr_lcn(mft_root, ATTR_TYPES::AT_INDEX_ALLOCATION) * cluster_size;

if (VOLUME_REPORT) {
    std::print("-----------------------------------------");
	std::print("------------- VOLUME_REPORT -------------");
    std::print("-----------------------------------------");
	std::print("VOL_LABEL			= {}", Vol_Label);
	std::print("NTFS_VERS			= {}.{}", NT_Major, NT_Minor);
	std::print("SECTOR_SIZE			= {:02} BYTES", nbs.bpb.bytes_per_sector);
	std::print("CLUSTER_SIZE			= {:02} BYTES", cluster_size);
	std::print("VOLUME_SIZE			= {:02} SECTORS", nbs.total_sectors);
	std::print("VOLUME_SIZE			= {:.4f} GB  @ 1000", (nbs.total_sectors * nbs.bpb.bytes_per_sector) / 1000.0 / 1000.0 / 1000.0);
	std::print("VOLUME_SIZE			= {:.4f} GiB @ 1024", (nbs.total_sectors * nbs.bpb.bytes_per_sector) / 1024.0 / 1024.0 / 1024.0);

    std::print("-----------------------------------------");
	std::print("MFT_OFFSET			= {} | 0x{:02X}", mft_offset, mft_offset);
	std::print("MFT_RECORDS			= ~{:02} IN USE", MFT_Count);
	std::print("MFT_RECORDS			= ~{:02} NOT IN USE", Unused_Count);

    std::print("-----------------------------------------");
	std::print("MFT_COPY_OFFSET		= {} | 0x{:02X}", mft_mrr_offset, mft_mrr_offset);
	std::print("ROOT_DIR_OFFSET		= {} | 0x{:02X}", rootDir_offset, rootDir_offset);
    std::print("-----------------------------------------");
    std::print("------------------ END ------------------");
    std::print("-----------------------------------------");
    std::print(" ");
}