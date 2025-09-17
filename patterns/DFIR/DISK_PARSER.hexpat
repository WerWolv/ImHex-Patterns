#pragma author Formula Zero One Technologies
#pragma description DFIR_DISK_PARSER_v2.0
#pragma MIME application/x-ima
#pragma endian little

// -----------------------------------------------------------------------------
// CREDIT
// -----------------------------------------------------------------------------
// Based on /fs/pattern.hexpat by WerWolv
// -----------------------------------------------------------------------------
// TODO
// -----------------------------------------------------------------------------
// Refine File System Detection/Match
// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import std.core;
import std.io;
import std.time;
import type.guid;
import type.magic;
import type.time;
import type.base;
import hex.provider;

// WORKING IMPORTS
import * from DFIR.FAT32 as FAT32Pat;
import * from DFIR.exFAT as EXFATPat;
import * from DFIR.NTFS as NTFSPat;

// ------------------------------------
// DISABLED IMPORTS
// REFS - UNTESTED
// EXT4 - GROUP DESC ERRORS
// APFS - PARTIALLY WORKS
	// Comment out "using uuid_t = type::GUID"
		// Replace all instances of "uuid_t" with "type::GUID"
	// Comment out line 1456-EOF 
// JPEG/PNG - OFFSET ERRORS
// ------------------------------------
//import * from fs.apfs as APFSPat;
//import * from fs.ext4 as EXT4Pat;
//import * from fs.refs as REFSPat;
//import * from jpeg as JPEGPat;
//import * from png as PNGPat;

// -----------------------------------------------------------------------------
// FWD DECs - GLOBAL
// -----------------------------------------------------------------------------
bool has_ext = false;
bool has_gpt = false;
u64 partitionOffset = 0;
u64 containerStartOffset = 0;

u32 mptIndex = 0;
u32 extIndex = 0;
str entryName = "";

u32 MPT_Count = 0;
u32 EXT_VolCount = 0;
u32 GPT_Count = 0;

u32 memory_size 	= std::mem::size();
str disk_path 		= hex::prv::get_information("file_path","");
u128 sector_size 	= hex::prv::get_information("sector_size","");

// -----------------------------------------------------------------------------
// REPORT HEADER		** ATTENTION **
// -----------------------------------------------------------------------------

// ---******---*******---vvvv--- |
const bool DISK_REPORT = true;
// ---******---*******---^^^^--- |

if (DISK_REPORT) {
	std::print("           # # # #   # #   ");
	std::print("           #     #     #   ");
	std::print("           #     #     #   ");
	std::print("           # # # #   # # # ");
	std::print("            I  m  H  e  x    ");
	std::print(" ");
	std::print("-----------------------------------------");
	std::print(" ");
	std::print("  ENTITY: _____________________");
	std::print(" ");
	std::print("EXAMINER: _____________________");
	std::print(" ");
	u128 timestamp           = std::time::epoch();
	std::time::Time local_ts = std::time::to_local(timestamp);
	std::time::Time utc_ts   = std::time::to_utc(timestamp);
	std::print("-----------------------------------------");
	std::print("   LOCAL: {}",
    	std::format("{:02}/{:02}/{:04} @ {:02}:{:02}:{:02}",
        	local_ts.mon + 1, 
        	local_ts.mday,
        	local_ts.year + 1900,
        	local_ts.hour,
        	local_ts.min,
        	local_ts.sec
    	));
	std::print("     UTC: {}",
    	std::format("{:02}/{:02}/{:04} @ {:02}:{:02}:{:02}",
        	utc_ts.mon + 1,
        	utc_ts.mday,
        	utc_ts.year + 1900,
        	utc_ts.hour,
        	utc_ts.min,
        	utc_ts.sec
    	));
	std::print("-----------------------------------------");
	std::print(" ");
}

// -----------------------------------------------------------------------------
// SIGNATURE HELPER
// -----------------------------------------------------------------------------
enum MBRSignature : u16 {
    MBR_SIG = 0xAA55			// 0x55AA -> Read LE
};

// -----------------------------------------------------------------------------
// CHS HELPER
// -----------------------------------------------------------------------------
bitfield CHS_Decoder {
    head : 8;
    sector : 6;
    cylinder : 10;
} [[format("chs_formatter")]];

fn chs_formatter(CHS_Decoder CHS) {
    return std::format("({:X}, {:X}, {:X}) | 0x{:X}", CHS.cylinder, CHS.head, CHS.sector, (CHS.cylinder * 16 + CHS.head) * 63 + (CHS.sector - 1));
};

// -----------------------------------------------------------------------------
// TIMESTAMP HELPER
// -----------------------------------------------------------------------------
struct DiskTimeStamp {
    u8 seconds, minutes, hours;
};

// -----------------------------------------------------------------------------
// DISK PROTECTION HELPER
// -----------------------------------------------------------------------------
enum DiskProtection : u16 {
    NotProtected    = 0x0000,
    CopyProtected   = 0x5A5A
};

// -----------------------------------------------------------------------------
// PARTITION STATUS HELPER
// -----------------------------------------------------------------------------
enum PartitionStatus : u8 {
    Not_Active = 0x00,              // not_bootable
    Active = 0x80                   // bootable
};

enum MPTPartLabel : u8 {
    UNUSED_OR_HIDDEN_ENTRY  = 0x00,
    PRIMARY		            = 0x07,
    PRIMARY_F32_SMALL       = 0x0B,
    PRIMARY_0C_BIG          = 0x0C,
    EXTENDED_CONT_SMALL     = 0x05,
    EXTENDED_CONT_BIG       = 0x0F,
    LEGACY_MBR				= 0xEE
};

// -----------------------------------------------------------------------------
// PARTITION TYPE HELPER
// -----------------------------------------------------------------------------
enum PartitionTypeCode : u8 {
    UNUSED_ENTRY		    = 0x00,
    FAT12_HDD               = 0x01,
    FAT12_HIDDEN            = 0x11,
    FAT16_SMALL             = 0x04,
    FAT16_SMALL_HIDDEN      = 0x14,
    FAT16_BIG               = 0x06,
    FAT16_BIG_HIDDEN        = 0x16,
    FAT32_SMALL             = 0x0B,
    FAT32_SMALL_HIDDEN      = 0x1B,
    FAT32_BIG               = 0x0C,
    FAT32_BIG_HIDDEN        = 0x1C,
    EXT_PART_SMALL          = 0x05,
    EXT_PART_SMALL_HIDDEN   = 0x15,
    EXT_PART_BIG            = 0x0F,
    EXT_PART_BIG_HIDDEN     = 0x1F,
    NTFS_EXFAT              = 0x07,
    NTFS_EXFAT_HIDDEN       = 0x17,
	WINDOWS_RECOVERY 		= 0x27,
    NTFS_VOL_SET_1			= 0x86,
    NTFS_VOL_SET_2 			= 0x87,
    macOSX 					= 0xA8,
	OS2_HIDDEN_CDRIVE 		= 0x84,
    LINUX_EXT               = 0x83,
    LINUX_EXT2	 			= 0x85,
    LINUX_LVM 				= 0x8E,
    LINUX_PA_RISC 			= 0xF0,
    LINUX_RAID 				= 0xFD,
    FREE_BSD 				= 0xA5,
    OPEN_BSD 				= 0xA6,
    QNX_1                   = 0x4D,
    QNX_2                   = 0x4E,
    QNX_3                   = 0x4F,
    GPT_DISK_STD            = 0xEE,
    GPT_DISK_SYS            = 0xEF,
    UNKNOWN 				= 0xFF,
};

// -----------------------------------------------------------------------------
// GUID PARTITION TABLE (GPT) PARTIONING SCHEME RELATED
// -----------------------------------------------------------------------------
//   V		V		V		V		V		V		V		V		V		V
// -----------------------------------------------------------------------------
// GPT PARTITION LABEL HELPER
// -----------------------------------------------------------------------------
enum GUIDPartLabel : u128 {
    // ---------------- COMMON ----------------
    UNUSED_ENTRY                              	= 0x00000000000000000000000000000000,
    EFI_SYSTEM_PART                    			= 0x3BC93EC9A0004BBA11D2F81FC12A7328, 
    APPLE_APFS_CONT                     		= 0xACEC4365300011AA11AA00007C3457EF,
    APPLE_HFS_PLUS_PART                       	= 0xACEC4365300011AA11AA000048465300,
    MICROSOFT_RESERVED_PART            			= 0xAE1502F92DF97D81B84D5C0BE3E3C9E3,
	WINDOWS_REC_ENVIRONMENT              		= 0xACD67901D5BF6AA1404DD106A4BB94DE,
    BASIC_DATA_PART                     		= 0xC79926B7B668C0874433B9E5EBD0A0A2, 
    
    // ---------------- LINUX ----------------
    LINUX_FILE_SYSTEM                         	= 0xE47D47D8693D798E477284830FC63DAF,
    RAID_PART                          			= 0x1E91840F3F7406A04D3B05FCA19D880F,
    ROOT_PART_X86                        		= 0x8A45F0D531D1F79A41B2F29744479540,
    ROOT_PART_X86_64                     		= 0x09B784F9CAFBE7964DB1E8CD4F68BCE3,
    ROOT_PART_ARM                        		= 0xD3BE9AD4A1216CB14E3C2CE469DAD710,
    ROOT_PART_ARM_64                     		= 0xAE3F0D286F4C44AF41C31DF0B921B045,
    BOOT_PART                            		= 0x72716FFD75B252A3426259E6BC13C2FF,
    SWAP_PART                            		= 0x4F4F4BC83309E58443C4A4AB0657FD6D,
    LOGICAL_VOLUME_MGR_PART          			= 0x28F93D2A8F233CA244C2F507E6D6D379,
    HOME_PART                            		= 0x15F9AEE2140E44B84F132EB4933AC7E1,
    SRV_SERVER_DATA_PART                 		= 0xE8986FA7251A7F904F3B20E03B8F8425,
    PLAIN_DMCRYPT_PART                   		= 0xB786550AA13E418949B72D007FFEC5C9,
    LUKS_PART                            		= 0xCC59605342171C864C5363EDCA7D7CCB,

    // ---------------- APPLE ----------------
    APPLE_UFS_CONT                       		= 0xACEC4365300011AA11AA000055465300,
    APPLE_ZFS                                 	= 0x316673200008A69911B21DD26A898CC3,
    APPLE_RAID_PART                      		= 0xACEC4365300011AA11AA000052414944,
    APPLE_RAID_PART_OFFLINE              		= 0xACEC4365300011AA11AA5F4F52414944,
    APPLE_BOOT_PART_REC_HD          			= 0xACEC4365300011AA11AA0000426F6F74,
    APPLE_LABEL                               	= 0xACEC4365300011AA11AA6C004C616265,
    APPLE_TV_RECOVERY_PART               		= 0xACEC4365300011AA11AA76655265636F,
    APPLE_CORE_STORAGE_CONT              		= 0xACEC4365300011AA11AA616753746F72,
    HFS_FILEVAULT_VOLUME_CONT            		= 0xACEC4365300011AA11AA616753746F72,
    APPLE_APFS_PREBOOT_PART              		= 0xACEC4365300011AA11AA006769646961,
    APPLE_APFS_RECOVERY_PART             		= 0xACEC4365300011AA11AA007972637652,

    // ---------------- WINDOWS ----------------
    LOGICAL_DISK_MGR_META_PART   				= 0xB3CF34E104E1D28542E08F7EAAC80858,
    LOGICAL_DISK_MGR_DATA_PART       			= 0xAD694A71113368BC4F621431A0609BAF,
    IBM_GENERAL_PARALLEL_FILE_SYS_PART			= 0x74B155E07A2DC3914E4EEF7D90FFAA37,
    STORAGE_SPACES_PART                  		= 0x2DECF6E501B0A3AFEE4CF6808FAF5CE7,
    STORAGE_REPLICA_PART                 		= 0xD123292BD147C8AAC043A1ACC58D4355,
};
// -----------------------------------------------------------------------------
// BASIC DATA PARTITION ATTRIBUTES
// -----------------------------------------------------------------------------
bitfield GPT_BDP_Attributes {
    bool platform_required     : 1 				[[comment("Bit 0: RequiredPartition - Volume must be preserved")]];
    bool io_ignore             : 1 				[[comment("Bit 1: NoBlockIOProtocol - EFI ignores this Volume, no FS Mapping")]];
    bool legacy_flag           : 1 				[[comment("Bit 2: LegacyBIOSBootable - Active/Bootable under BIOS")]];
    reserved_UEFI          	   : 45 			[[comment("Bits 3–47: Reserved for UEFI")]];
    reserved_MS            	   : 12 			[[comment("Bits 48–59: Reserved for Microsoft")]];
    bool read_only             : 1 				[[comment("Bit 60: BasicDataPart - Read-Only Volume")]];
    bool shadow_copy           : 1 				[[comment("Bit 61: BasicDataPart - Shadow Copy Volume")]];
    bool hidden                : 1 				[[comment("Bit 62: BasicDataPart - Hidden Volume")]];
    bool no_drive_letter       : 1 				[[comment("Bit 63: BasicDataPart - Do not Auto-Assign Drive Letter")]];
} [[bitfield_order(
     std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

// -----------------------------------------------------------------------------
// GPT ENTRIES PARSER
// LBA2-LBA33
// EACH ENTRY IS 128 BYTES (DESCRIBES A VOLUME)
// -----------------------------------------------------------------------------
union PartitionUnion {
    le type::GUID PartTypeGUID;         		// HUMAN READABLE GUID
    GUIDPartLabel PartTypeLabel					[[name(std::format("PartTypeLabel (DERIVED)"))]];        // OBJECT LABEL
};

struct GPT_PartitionEntry {
    PartitionUnion Type							[[comment("Known Partition Type GUID: Global Identifier")]];               
    le type::GUID Unique_GUID					[[comment("Unique Partition GUID: Every Volume has its own Unique GUID")]];          
    u64 Start_LBA								[[comment("The first Sector of the Volume (Offset by 1)")]];                  
    u64 End_LBA									[[comment("The last Sector of the Volume (Offset by 1)")]];                    
    GPT_BDP_Attributes ATTR		        		[[comment("ATTRs for a Basic Data Partition may not be the same as a Microsoft Reserved Partition")]];
    char16 PartName[36]	            			[[comment("Partition Name: Based on Known Partition Type GUID, except for Disk Images")]];

    if (Type.PartTypeLabel != GUIDPartLabel::UNUSED_ENTRY) {
    	GPT_Count += 1;
    }

    u64 GPTpartitionOffset = Start_LBA * sector_size 
    	[[name(std::format("VOL_OFFSET {} | 0x{:02X} (DERIVED)", Start_LBA * sector_size, Start_LBA * sector_size)),
    		export]];

    match (Type.PartTypeLabel) {
        (GUIDPartLabel::UNUSED_ENTRY):
        	continue;
        
        (GUIDPartLabel::EFI_SYSTEM_PART):
            FAT32Pat EFI_SYS_VOL @ GPTpartitionOffset;

        (GUIDPartLabel::BASIC_DATA_PART | 
        GUIDPartLabel::WINDOWS_REC_ENVIRONMENT): {
			char gpt_fat32_magic[8]  @ GPTpartitionOffset + 82			[[hidden]];			
			char gpt_ntfs_magic[8]   @ GPTpartitionOffset + 3 			[[hidden]];
			char gpt_exfat_magic[8]  @ GPTpartitionOffset + 3 			[[hidden]];

            if (gpt_fat32_magic == "FAT32   ")
                FAT32Pat FAT32_VOL @ GPTpartitionOffset;
            if (gpt_ntfs_magic == "NTFS    ")
                NTFSPat NTFS_VOL @ GPTpartitionOffset;
            else if (gpt_exfat_magic == "EXFAT   ") 
                EXFATPat EXFAT_VOL @ GPTpartitionOffset;        	
	    }
	    // --------- DISABLED -----------------
	    // EXT4 PATTERN WAS INOP WHEN TESTED
	    //(GUIDPartLabel::LINUX_FILE_SYSTEM):
	    	//EXT4Pat EXT4_VOL @ GPTpartitionOffset;
	    //(GUIDPartLabel::APPLE_APFS_CONT):
	    //	APFSPat APFS_VOL @ GPTpartitionOffset;
	}
} [[name(std::format("GPT_ENTRY [{}]", std::core::array_index()))]];

// -----------------------------------------------------------------------------
// GPT HEADER PARSER
// LBA1 OFFSETS 0-91 (92 bytes of 512 bytes used)
// -----------------------------------------------------------------------------
struct GPT_Header {                  	
    type::Magic<"EFI PART"> signature 		[[comment("Signature (EFI PART)")]];
    u32 revision 							[[comment("Header Revision Value")]];
    u32 header_size 						[[comment("Size of Header - 92 Bytes")]];
	type::Hex<u32> header_crc32 			[[comment("GPT Header Checksum")]];
    u32 reserved 							[[comment("Zeros")]];
    u64 current_lba 						[[comment("Current LBA - GPT Header Location")]];
    u64 backup_lba 							[[comment("Location of Backup - Header & GPT")]];
    u64 first_usable_lba 					[[comment("1st Sector Available for Logical VOL")]];
    u64 last_usable_lba 					[[comment("Last Sector Available for Logical VOL")]];
    type::GUID disk_guid 					[[comment("Unique Disk GUID")]];
    u64 partition_entries_lba 				[[comment("1st Sector of GPT")]];
    u32 num_partition_entries				[[comment("Total Number of Partition Entries Available - 128 on Windows")]];
    u32 size_of_partition_entry				[[comment("Size in Bytes of each GPT Entry")]];
	type::Hex<u32> partition_entries_crc32	[[comment("GPT Array Checksum")]];
};

// -----------------------------------------------------------------------------
// MASTER BOOT RECORD (MBR) PARTIONING SCHEME RELATED
// -----------------------------------------------------------------------------
//   V		V		V		V		V		V		V		V		V		V
// -----------------------------------------------------------------------------
// MASTER PARTITION TABLE (MPT) 
// LBA0 > 0FFSETS 446-509
// Each Entry Describes a Logical Volume (type/start_loc/size)
// -----------------------------------------------------------------------------
union MBRPartitionUnion {
    PartitionTypeCode Part_Type;
    MPTPartLabel PartTypeLabel;  // overlay for 0x00
};

struct PartitionTableEntry {
    // partition table fields
    PartitionStatus ActiveFlag;
    CHS_Decoder Starting_CHS;
    MBRPartitionUnion Type;
    CHS_Decoder Ending_CHS;
    u32 Start_LBA;
    u32 Total_Sectors;

    if (Type.PartTypeLabel != MPTPartLabel::UNUSED_OR_HIDDEN_ENTRY) {
    	// Track Count of Logical Volumes in the Extended Container
    	//MPT_Count += 1;
    	if (containerStartOffset == 0) {
        	// top-level MBR entry
        	MPT_Count = MPT_Count + 1;
    	} else {
        	// a logical inside an extended container
        	EXT_VolCount = EXT_VolCount + 1;
    	}   
   }

    partitionOffset = containerStartOffset + (Start_LBA * sector_size);
	
    match (Type.PartTypeLabel) {
        (PartitionTypeCode::UNUSED_ENTRY): continue;
        (PartitionTypeCode::FAT32_SMALL | PartitionTypeCode::FAT32_BIG): {
            FAT32Pat FAT32_VOL @ partitionOffset;
        }
        (PartitionTypeCode::NTFS_EXFAT): {
            char magic[8] @ partitionOffset + 3;
            if (magic == "NTFS    ")
                NTFSPat NTFS_VOL @ partitionOffset;
            else
                EXFATPat EXFAT_VOL @ partitionOffset;
        }
        (PartitionTypeCode::EXT_PART_SMALL | PartitionTypeCode::EXT_PART_BIG): {
            // Save parent state
            bool parent_has_ext = has_ext;
            has_ext = true;
             
            containerStartOffset = partitionOffset;
            
            // Parse first two entries of the extended partition
            PartitionTableEntry EXTENDED_PARTITION[2] @ partitionOffset + 446;
            
            has_ext = parent_has_ext;
        }
        (PartitionTypeCode::GPT_DISK_STD | PartitionTypeCode::GPT_DISK_SYS): 
            // Set global flag
            has_gpt = true;
    }
	if (!has_ext) {
  		entryName = std::format("MPT_ENTRY [{}]", mptIndex);
   		mptIndex += 1;
	} else {
    	if (std::core::array_index() <= 0) {
        	entryName = std::format("LOGICAL_VOL (EXT) [{}]", extIndex);
    	} else if (std::core::array_index() == 1) {
        	entryName = "NEXT VOL POINTER (EXT)";
    	} else {
        	entryName = std::format("LOGICAL_VOL (EXT) [{}]", extIndex);
    	}
    	extIndex += 1;
	}
} [[name(entryName)]];

// -----------------------------------------------------------------------------
// MBR PARSER
// LBA0 > OFFSETS 0-511 (512 bytes)
// -----------------------------------------------------------------------------
struct MasterBootRecord {
    u8 bootstrapCodeArea1[218] 				[[comment("Boot Strapping Code")]];
    padding[2] 								[[comment("Zeros")]];
    u8 originalPhysicalDrive 				[[comment("???")]];
    DiskTimeStamp diskTimeStamp				[[comment("Timestamp of Disk OG Partitioning")]];
    u8 bootstrapCodeArea2[216] 				[[comment("Boot Strapping Code")]];
    u32 diskSignature						[[comment("Disk Signature")]];
    DiskProtection diskProtection 			[[comment("Disk Protection - 0x0000=Not | 0x5A5A=Prot")]];
    PartitionTableEntry PT[4]				[[comment("Master Partition Table (MPT) Offset 446-509")]];
    MBRSignature MBR_SIG 					[[comment("End of MBR - 0x55AA")]];
};

// -----------------------------------------------------------------------------
// DISK PARSER
// -----------------------------------------------------------------------------
struct DiskRoot {
    // Master Boot Record at LBA 0 (1st physical sector)
    MasterBootRecord MBR @ 0x00;

	if (has_gpt) {
    	// GPT Header at LBA 1 (2nd physical sector)
    	GPT_Header GPT_HEADER @ 0x200;
    	// The GPT (table) at LBA 2 (3rd physical sector) to LBA 33 (34th physical sector)
    	// 32 sectors total (Windows) that can define up to 128 - (primary) logical volumes
		GPT_PartitionEntry GPT_ENTRIES[GPT_HEADER.num_partition_entries] @ (GPT_HEADER.partition_entries_lba * 512);
	}
};

// -----------------------------------------------------------------------------
// ROOT OBJECT
// -----------------------------------------------------------------------------
// ---
DiskRoot DISK @ 0x0;
// ---


// ------------------------------
// DISK REPORT
// ------------------------------

if (DISK_REPORT) {
    std::print("-----------------------------------------");
    std::print("-------------- DISK_REPORT --------------");
    std::print("-----------------------------------------");

    // Disk Basics
    std::print("DISK_PATH        	 = {}", disk_path);
    std::print("SECTOR_SIZE      	 = {} BYTES", sector_size);
    std::print("DISK_SIZE		 	 = {} SECTORS", memory_size / sector_size);
    std::print("DISK_SIZE        	 = {:.4f} GB  @ 1000", memory_size / 1000.0 / 1000.0 / 1000.0);
    std::print("DISK_SIZE        	 = {:.4f} GiB @ 1024", memory_size / 1024.0 / 1024.0 / 1024.0);

    // Disk Protection
    str diskProtectionStr;
    if (DISK.MBR.diskProtection == DiskProtection::NotProtected) {
        diskProtectionStr = "NOT_COPY_PROTECTED";
    } else if (DISK.MBR.diskProtection == DiskProtection::CopyProtected) {
        diskProtectionStr = "COPY_PROTECTED";
    } else {
        diskProtectionStr = "UNKNOWN";
    }
    std::print("DISK_PROTECT  	     = {}", diskProtectionStr);
   
    // Partition Scheme
    if (MPT_Count >= 1 && GPT_Count == 0) {
        std::print("PART_SCHEME 	 	 = MBR");
    } else if (GPT_Count >= 1 && MPT_Count == 0) {
        std::print("PART_SCHEME 	 	 = GPT");
    } else if (GPT_Count >= 1 && MPT_Count >= 1) {
        std::print("PART_SCHEME 	 	 = HYBRID (MBR + GPT)");
    } else {
        std::print("PART_SCHEME 	 	 = UNKNOWN");
    }

    // MBR MPT Partitions
    for (u32 i = 0, i < MPT_Count, i = i + 1) {
        std::print("-----------------------------------------");
        std::print("-------------- MBR_MPT [{}] --------------", i);
    	std::print("-----------------------------------------");
        
        // STATUS
        str statusStr;
        if (DISK.MBR.PT[i].ActiveFlag == PartitionStatus::Active) {
            statusStr = "ACTIVE/BOOTABLE";
        } else if (DISK.MBR.PT[i].ActiveFlag == PartitionStatus::Not_Active) {
            statusStr = "INACTIVE/NOT_BOOTABLE";
        } else {
            statusStr = "UNKNOWN";
        }
        std::print(" STATUS          	 = {}", statusStr);
		
        // TYPE_CODE
        str typeStr;
        if (DISK.MBR.PT[i].Type.Part_Type == PartitionTypeCode::FAT32_SMALL) {
            typeStr = "FAT32 (CHS) (0x0B)";
        } else if (DISK.MBR.PT[i].Type.Part_Type == PartitionTypeCode::FAT32_BIG) {
            typeStr = "FAT32 (LBA) (0x0C)";
        } else if (DISK.MBR.PT[i].Type.Part_Type == PartitionTypeCode::NTFS_EXFAT) {
            typeStr = "NTFS/EXFAT (0x07)";
        } else if (DISK.MBR.PT[i].Type.Part_Type == PartitionTypeCode::GPT_DISK_STD) {
            typeStr = "GPT_PROTECTIVE (0xEE)";
        } else if (DISK.MBR.PT[i].Type.Part_Type == PartitionTypeCode::EXT_PART_BIG) {
            typeStr = "EXTENDED (0x0F)";
        } else {
            typeStr = "OTHER/UNKNOWN";
        }
        std::print(" TYPE_CODE       	 = {}", typeStr);
		
        // LBA and size        
        std::print(" FIRST_LBA       	 = {:02}", DISK.MBR.PT[i].Start_LBA);
        std::print(" LAST_LBA            = {:02}", DISK.MBR.PT[i].Start_LBA + DISK.MBR.PT[i].Total_Sectors - 1);
        std::print(" VOL_SIZE		 	 = {:02} SECTORS", DISK.MBR.PT[i].Total_Sectors);
        std::print(" VOL_SIZE		 	 = {:.4f} GB", (DISK.MBR.PT[i].Total_Sectors * sector_size) / 1000.0 / 1000.0 / 1000.0);
        std::print(" VOL_SIZE		 	 = {:.4f} GiB", (DISK.MBR.PT[i].Total_Sectors * sector_size) / 1024.0 / 1024.0 / 1024.0);
		
    	if (DISK.MBR.PT[i].Type.PartTypeLabel == MPTPartLabel::EXTENDED_CONT_SMALL ||
        	DISK.MBR.PT[i].Type.PartTypeLabel == MPTPartLabel::EXTENDED_CONT_BIG) {
        
        	u32 logicalCount = std::core::member_count(DISK.MBR.PT[i].EXTENDED_PARTITION);
        	//u32 logicalCount = std::mem::size(DISK.MBR.PT[i].EXTENDED_PARTITION);

        	for (u32 e = 0, e < logicalCount, e = e + 1) {
            	if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.PartTypeLabel == MPTPartLabel::UNUSED_OR_HIDDEN_ENTRY)
                	continue;

            		std::print("-----------------------------------------");
            		std::print("---------- LOGICAL (EXT) [{}] ------------", e);
            		std::print("-----------------------------------------");

        			// STATUS
        			str EXTstatusStr;
        			if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].ActiveFlag == PartitionStatus::Active) {
            			EXTstatusStr = "ACTIVE/BOOTABLE";
        			} else if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].ActiveFlag == PartitionStatus::Not_Active) {
            			EXTstatusStr = "INACTIVE/NOT_BOOTABLE";
        			} else {
            			EXTstatusStr = "UNKNOWN";
        			}
        			std::print(" STATUS          	 = {}", EXTstatusStr);
		
        			// TYPE_CODE
        			str EXTtypeStr;
        			if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.Part_Type == PartitionTypeCode::FAT32_SMALL) {
            			EXTtypeStr = "FAT32 (CHS) (0x0B)";
        			} else if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.Part_Type == PartitionTypeCode::FAT32_BIG) {
            			EXTtypeStr = "FAT32 (LBA) (0x0C)";
        			} else if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.Part_Type == PartitionTypeCode::NTFS_EXFAT) {
            			EXTtypeStr = "NTFS/EXFAT (0x07)";
        			} else if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.Part_Type == PartitionTypeCode::GPT_DISK_STD) {
            			EXTtypeStr = "GPT_PROTECTIVE (0xEE)";
        			} else if (DISK.MBR.PT[i].EXTENDED_PARTITION[e].Type.Part_Type == PartitionTypeCode::EXT_PART_BIG) {
            			EXTtypeStr = "EXTENDED (0x0F)";
        			} else {
            			EXTtypeStr = "OTHER/UNKNOWN";
        			}
        			std::print(" TYPE_CODE       	 = {}", EXTtypeStr);

            		std::print(" FIRST_LBA           = {}", DISK.MBR.PT[i].EXTENDED_PARTITION[e].Start_LBA);
            		std::print(" LAST_LBA            = {}", DISK.MBR.PT[i].EXTENDED_PARTITION[e].Start_LBA + 
                                        DISK.MBR.PT[i].EXTENDED_PARTITION[e].Total_Sectors - 1);
            		std::print(" VOL_SIZE            = {} SECTORS", DISK.MBR.PT[i].EXTENDED_PARTITION[e].Total_Sectors);
           			std::print(" VOL_SIZE            = {:.4f} GB", 
               							(DISK.MBR.PT[i].EXTENDED_PARTITION[e].Total_Sectors * sector_size) / 1000.0 / 1000.0 / 1000.0);
            		std::print(" VOL_SIZE            = {:.4f} GiB", 
                						(DISK.MBR.PT[i].EXTENDED_PARTITION[e].Total_Sectors * sector_size) / 1024.0 / 1024.0 / 1024.0);
        		}
    		}
    	}

    // GPT Header
    if (GPT_Count >= 1) {
		std::print("-----------------------------------------");
        std::print("-------------- GPT_HEADER ---------------");
    	std::print("-----------------------------------------");
        std::print("SIGNATURE         	 = {}", DISK.GPT_HEADER.signature);
        std::print("REVISION          	 = 0x{:02X}", DISK.GPT_HEADER.revision);
        std::print("GPT_HDR_CRC		  	 = 0x{:02X}", DISK.GPT_HEADER.header_crc32);
        std::print("GPT_HDR_BACKUP_LBA   = {}", DISK.GPT_HEADER.backup_lba);
        std::print("DISK_GUID         	 = {}", DISK.GPT_HEADER.disk_guid);
        std::print("FIRST_USABLE_LBA  	 = {}", DISK.GPT_HEADER.first_usable_lba);
        std::print("LAST_USABLE_LBA   	 = {}", DISK.GPT_HEADER.last_usable_lba);
        std::print("MAX_GPT_ENTRIES   	 = {:02}", DISK.GPT_HEADER.num_partition_entries);
        std::print("GPT_ENTRY_SIZE	  	 = {:02} BYTES", DISK.GPT_HEADER.size_of_partition_entry);
        std::print("GPT_ARRAY_CRC	  	 = 0x{:02X}", DISK.GPT_HEADER.partition_entries_crc32);
    	
        // GPT Partitions
        for (u32 j = 0, j < GPT_Count, j = j + 1) {
        	std::print("-----------------------------------------");
        	std::print("------------- GPT_PART [{}] --------------", j);
    		std::print("-----------------------------------------");     
            std::print(" PART_TYPE_LABEL	 = {}", DISK.GPT_ENTRIES[j].Type.PartTypeLabel);       
            std::print(" PART_TYPE_GUID      = {}", DISK.GPT_ENTRIES[j].Type.PartTypeGUID);
            std::print(" UNIQUE_PART_GUID    = {}", DISK.GPT_ENTRIES[j].Unique_GUID);
            std::print(" FIRST_LBA           = {:02}", DISK.GPT_ENTRIES[j].Start_LBA);
            std::print(" LAST_LBA            = {:02}", DISK.GPT_ENTRIES[j].End_LBA);

			bool _any = false;
			std::print(" ATTR_FLAGS |");
			if(DISK.GPT_ENTRIES[j].ATTR.platform_required) {
    			std::print("            |- - - - > PlatformRequired");
				_any = true;
    		}
			if(DISK.GPT_ENTRIES[j].ATTR.io_ignore) {
    			std::print("            |- - - - > NO_FS_MAP");
				_any = true;
    		}
			if(DISK.GPT_ENTRIES[j].ATTR.legacy_flag) {
    			std::print("            |- - - - > LEGACY_BOOT");
				_any = true;
    		}
			if(DISK.GPT_ENTRIES[j].Type.PartTypeLabel == GUIDPartLabel::BASIC_DATA_PART) {
    			if(DISK.GPT_ENTRIES[j].ATTR.read_only) {
        			std::print("            |- - - - > READ_ONLY");
					_any = true;
        		}
    			if(DISK.GPT_ENTRIES[j].ATTR.shadow_copy) {
        			std::print("            |- - - - > SHADOW_COPY");
					_any = true;
        		}
    			if(DISK.GPT_ENTRIES[j].ATTR.hidden) {
        			std::print("            |- - - - > HIDDEN");
					_any = true;
        		}
    			if(DISK.GPT_ENTRIES[j].ATTR.no_drive_letter) {
        			std::print("            |- - - - > NO_AUTO_MOUNT");
					_any = true;
        		}
        	} 
			// if nothing was printed, say "NONE"
			if (!_any) {        	
        		//std::print("                     |> NONE");
        		std::print("            |- - - - > NONE");
			}
        	std::print(" PART_TYPE_NAME		 = {}", DISK.GPT_ENTRIES[j].PartName);
    	}
    }
    std::print("-----------------------------------------");
    std::print("------------------ END ------------------");
    std::print("-----------------------------------------");
    std::print(" ");
}
