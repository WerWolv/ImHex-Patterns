#pragma author Hrant Tadevosyan (Axcient, now ConnectWise)
#pragma description NT File System (NTFS)
#pragma endian little

// refs: 
// - https://github.com/libyal/libfsntfs
// - https://github.com/tuxera/ntfs-3g

import std.core;
import std.array;
import std.ptr;
import std.io;
import std.mem;
import type.magic;


using ntfschar = u16;

using leVCN = u64;
using leLCN = u64;
using leLSN = u64;
using leMFT_REF = u64;

struct GUID {
    u32 Data1;
    u16 Data2;
    u16 Data3;
    u8  Data4[8];
};

bitfield RUNLIST_HEADER {
    unsigned offset : 4;
    unsigned length : 4;
} [[bitfield_order(std::core::BitfieldOrder::MostToLeastSignificant, 8)]];

struct RUNLIST {
    RUNLIST_HEADER header;
    u8 count[header.length];
    u8 lcn[header.offset];
};

struct BIOS_PARAMETER_BLOCK {
    u16 bytes_per_sector;
    u8  sectors_per_cluster;
    u16 reserved_sectors;
    u8  fats;
    u16 root_entries;
    u16 sectors;
    u8  media_type;
    u16 sectors_per_fat;
    u16 sectors_per_track;
    u16 heads;
    u32 hidden_sectors;
    u32 large_sectors;
};

enum NTFS_RECORD_TYPES : u32  {
    magic_FILE  = 0x454c4946,
    magic_INDX  = 0x58444e49,   
    magic_HOLE  = 0x454c4f48,
    magic_RSTR  = 0x52545352,
    magic_RCRD  = 0x44524352,
    magic_CHKD  = 0x444b4843,
    magic_BAAD  = 0x44414142,
    magic_empty = 0xffffffff,
};

struct NTFS_RECORD {
    NTFS_RECORD_TYPES magic;
    u16 usa_ofs;
    u16 usa_count;
};

enum MFT_RECORD_FLAGS : u16 {
    MFT_RECORD_IN_USE           = 0x0001,
    MFT_RECORD_IS_DIRECTORY     = 0x0002,
    MFT_RECORD_IS_4             = 0x0004,
    MFT_RECORD_IS_VIEW_INDEX    = 0x0008,
    MFT_REC_SPACE_FILLER        = 0xffff,
};

enum ATTR_TYPES : u32  {
    AT_UNUSED                       = 0,
    AT_STANDARD_INFORMATION         = 0x10,
    AT_ATTRIBUTE_LIST               = 0x20,
    AT_FILE_NAME                    = 0x30,
    AT_OBJECT_ID                    = 0x40,
    AT_SECURITY_DESCRIPTOR          = 0x50,
    AT_VOLUME_NAME                  = 0x60,
    AT_VOLUME_INFORMATION           = 0x70,
    AT_DATA                         = 0x80,
    AT_INDEX_ROOT                   = 0x90,
    AT_INDEX_ALLOCATION             = 0xa0,
    AT_BITMAP                       = 0xb0,
    AT_REPARSE_POINT                = 0xc0,
    AT_EA_INFORMATION               = 0xd0,
    AT_EA                           = 0xe0,
    AT_PROPERTY_SET                 = 0xf0,
    AT_LOGGED_UTILITY_STREAM        = 0x100,
    AT_FIRST_USER_DEFINED_ATTRIBUTE = 0x1000,
    AT_END                          = 0xffffffff,
};

enum ATTR_DEF_FLAGS : u32  {
	ATTR_DEF_INDEXABLE	    = 0x02,
	ATTR_DEF_MULTIPLE	    = 0x04,
	ATTR_DEF_NOT_ZERO	    = 0x08,
	ATTR_DEF_INDEXED_UNIQUE	= 0x10,
	ATTR_DEF_NAMED_UNIQUE	= 0x20,
	ATTR_DEF_RESIDENT	    = 0x40,
	ATTR_DEF_ALWAYS_LOG	    = 0x80,
};

enum COLLATION_RULES : u32  {
    COLLATION_BINARY                = 0,
    COLLATION_FILE_NAME             = 1,
    COLLATION_UNICODE_STRING        = 2,
    COLLATION_NTOFS_ULONG           = 16,
    COLLATION_NTOFS_SID             = 17,
    COLLATION_NTOFS_SECURITY_HASH   = 18,
    COLLATION_NTOFS_ULONGS          = 19,
};

struct ATTR_DEF {
    ntfschar name[0x40];
    ATTR_TYPES type;
    u32 display_rule;
    COLLATION_RULES collation_rule;
    ATTR_DEF_FLAGS flags;
    u64 min_size;
    u64 max_size;
};

enum ATTR_FLAGS : u16 {
    ATTR_IS_COMPRESSED      = 0x0001,
    ATTR_COMPRESSION_MASK   = 0x00ff,
    ATTR_IS_ENCRYPTED       = 0x4000,
    ATTR_IS_SPARSE          = 0x8000,
};

enum RESIDENT_ATTR_FLAGS : u8 {
    RESIDENT_ATTR_IS_INDEXED = 0x01
};

enum FILE_ATTR_FLAGS : u32  {
    FILE_ATTR_READONLY              = 0x00000001,
    FILE_ATTR_HIDDEN                = 0x00000002,
    FILE_ATTR_SYSTEM                = 0x00000004,
    FILE_ATTR_DIRECTORY             = 0x00000010,
    FILE_ATTR_ARCHIVE               = 0x00000020,
    FILE_ATTR_DEVICE                = 0x00000040,
    FILE_ATTR_NORMAL                = 0x00000080,
    FILE_ATTR_TEMPORARY             = 0x00000100,
    FILE_ATTR_SPARSE_FILE           = 0x00000200,
    FILE_ATTR_REPARSE_POINT         = 0x00000400,
    FILE_ATTR_COMPRESSED            = 0x00000800,
    FILE_ATTR_OFFLINE               = 0x00001000,
    FILE_ATTR_NOT_CONTENT_INDEXED   = 0x00002000,
    FILE_ATTR_ENCRYPTED             = 0x00004000,
    FILE_ATTRIBUTE_RECALL_ON_OPEN   = 0x00040000,
    FILE_ATTR_VALID_FLAGS           = 0x00047fb7,
    FILE_ATTR_VALID_SET_FLAGS       = 0x000031a7,
    FILE_ATTR_I30_INDEX_PRESENT     = 0x10000000,
    FILE_ATTR_VIEW_INDEX_PRESENT    = 0x20000000,
};

enum FILE_NAME_TYPE_FLAGS : u8 {
    FILE_NAME_POSIX             = 0x00,
    FILE_NAME_WIN32             = 0x01,
    FILE_NAME_DOS               = 0x02,
    FILE_NAME_WIN32_AND_DOS     = 0x03,
};

struct STANDARD_INFORMATION_HEADER {
    u64 creation_time;
    u64 last_data_change_time;
    u64 last_mft_change_time;
    u64 last_access_time;
    FILE_ATTR_FLAGS file_attributes;
};

struct STANDARD_INFORMATION_OLD {
    STANDARD_INFORMATION_HEADER header [[inline]];
    u8 reserved12[12];
};

struct STANDARD_INFORMATION {
    STANDARD_INFORMATION_HEADER header [[inline]];
    u32 maximum_versions;
    u32 version_number;
    u32 class_id;
    u32 owner_id;
    u32 security_id;
    u64 quota_charged;
    u64 usn;
};

struct FILE_NAME_ATTR_PACKED {
    u16 packed_ea_size;
    u16 reserved;
};

union FILE_NAME_ATTR_FORM {
    FILE_NAME_ATTR_PACKED packed [[inline]];
    u32 reparse_point_tag;
};

struct FILE_NAME_ATTR {
    leMFT_REF parent_directory;
    u64 creation_time;
    u64 last_data_change_time;
    u64 last_mft_change_time;
    u64 last_access_time;
    u64 allocated_size;
    u64 data_size;
    FILE_ATTR_FLAGS file_attributes;
    FILE_NAME_ATTR_FORM form [[inline]];
    u8 file_name_length;
    FILE_NAME_TYPE_FLAGS file_name_type;
    ntfschar file_name[file_name_length];
};

struct OBJECT_ID_ATTR_INFO {
    GUID birth_volume_id;
    GUID birth_object_id;
    GUID domain_id;
};

union OBJECT_ID_ATTR_FORM {
    OBJECT_ID_ATTR_INFO info [[inline]];
    u8 extended_info[48];
};

struct OBJECT_ID_ATTR {
    GUID object_id;
    OBJECT_ID_ATTR_FORM form [[inline]];
};

enum VOLUME_FLAGS : u16 {
    VOLUME_IS_DIRTY             = 0x0001,
    VOLUME_RESIZE_LOG_FILE      = 0x0002,
    VOLUME_UPGRADE_ON_MOUNT     = 0x0004,
    VOLUME_MOUNTED_ON_NT4       = 0x0008,
    VOLUME_DELETE_USN_UNDERWAY  = 0x0010,
    VOLUME_REPAIR_OBJECT_ID     = 0x0020,
    VOLUME_CHKDSK_UNDERWAY      = 0x4000,
    VOLUME_MODIFIED_BY_CHKDSK   = 0x8000,
    VOLUME_FLAGS_MASK           = 0xc03f,
};

struct VOLUME_INFORMATION {
    u64 reserved;
    u8  major_ver;
    u8  minor_ver;
    VOLUME_FLAGS flags;
};

enum SECURITY_DESCRIPTOR_CONTROL : u16 {
    SE_OWNER_DEFAULTED          = 0x0001,
    SE_GROUP_DEFAULTED          = 0x0002,
    SE_DACL_PRESENT             = 0x0004,
    SE_DACL_DEFAULTED           = 0x0008,
    SE_SACL_PRESENT             = 0x0010,
    SE_SACL_DEFAULTED           = 0x0020,
    SE_DACL_AUTO_INHERIT_REQ    = 0x0100,
    SE_SACL_AUTO_INHERIT_REQ    = 0x0200,
    SE_DACL_AUTO_INHERITED      = 0x0400,
    SE_SACL_AUTO_INHERITED      = 0x0800,
    SE_DACL_PROTECTED           = 0x1000,
    SE_SACL_PROTECTED           = 0x2000,
    SE_RM_CONTROL_VALID         = 0x4000,
    SE_SELF_RELATIVE            = 0x8000,
};


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
    OBJECT_INHERIT_ACE          = 0x01,
    CONTAINER_INHERIT_ACE       = 0x02,
    NO_PROPAGATE_INHERIT_ACE    = 0x04,
    INHERIT_ONLY_ACE            = 0x08,
    INHERITED_ACE               = 0x10,
    VALID_INHERIT_FLAGS         = 0x1f,
    SUCCESSFUL_ACCESS_ACE_FLAG  = 0x40,
    FAILED_ACCESS_ACE_FLAG      = 0x80,
};

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

enum ACCESS_MASK : u32  {
    FILE_READ_DATA              = 0x00000001,
    FILE_LIST_DIRECTORY         = 0x00000001,
    FILE_WRITE_DATA             = 0x00000002,
    FILE_ADD_FILE               = 0x00000002,
    FILE_APPEND_DATA            = 0x00000004,
    FILE_ADD_SUBDIRECTORY       = 0x00000004,
    FILE_READ_EA                = 0x00000008,
    FILE_WRITE_EA               = 0x00000010,
    FILE_EXECUTE                = 0x00000020,
    FILE_TRAVERSE               = 0x00000020,
    FILE_DELETE_CHILD           = 0x00000040,
    FILE_READ_ATTRIBUTES        = 0x00000080,
    FILE_WRITE_ATTRIBUTES       = 0x00000100,
    DELETE                      = 0x00010000,
    READ_CONTROL                = 0x00020000,
    WRITE_DAC                   = 0x00040000,
    WRITE_OWNER                 = 0x00080000,
    SYNCHRONIZE                 = 0x00100000,
    STANDARD_RIGHTS_READ        = 0x00020000,
    STANDARD_RIGHTS_WRITE       = 0x00020000,
    STANDARD_RIGHTS_EXECUTE     = 0x00020000,
    STANDARD_RIGHTS_REQUIRED    = 0x000f0000,
    STANDARD_RIGHTS_ALL         = 0x001f0000,
    ACCESS_SYSTEM_SECURITY      = 0x01000000,
    MAXIMUM_ALLOWED             = 0x02000000,
    GENERIC_ALL                 = 0x10000000,
    GENERIC_EXECUTE             = 0x20000000,
    GENERIC_WRITE               = 0x40000000,
    GENERIC_READ                = 0x80000000,
};

struct ACCESS_ALLOWED_ACE {
    ACE_HEADER header [[inline]];
    ACCESS_MASK mask;
    SID sid;
};
using ACCESS_DENIED_ACE = ACCESS_ALLOWED_ACE;
using SYSTEM_ALARM_ACE  = ACCESS_ALLOWED_ACE;
using SYSTEM_AUDIT_ACE  = ACCESS_ALLOWED_ACE;

enum OBJECT_ACE_FLAGS : u32  {
    ACE_OBJECT_TYPE_PRESENT             = 1,
    ACE_INHERITED_OBJECT_TYPE_PRESENT   = 2,
};

struct ACCESS_ALLOWED_OBJECT_ACE {
    ACE_HEADER header [[inline]];
    ACCESS_MASK mask;
    OBJECT_ACE_FLAGS object_flags;
    GUID object_type;
    GUID inherited_object_type;
    SID sid;
};
using ACCESS_DENIED_OBJECT_ACE = ACCESS_ALLOWED_OBJECT_ACE;
using SYSTEM_AUDIT_OBJECT_ACE  = ACCESS_ALLOWED_OBJECT_ACE;
using SYSTEM_ALARM_OBJECT_ACE  = ACCESS_ALLOWED_OBJECT_ACE;


struct ACL {
    u8  revision;
    u8  alignment1;
    u16 size;
    u16 ace_count;
    u16 alignment2;

    std::mem::AlignTo<4>;
    padding[size];
    std::mem::AlignTo<4>;
};

#define SECURITY_DESCRIPTOR_RELATIVE_SIZE (20)
struct SECURITY_DESCRIPTOR_RELATIVE {
    u8      revision;
    u8      alignment;
    u16     control; // SECURITY_DESCRIPTOR_CONTROL
    u32     owner;
    u32     group;
    u32     sacl;
    u32     dacl;

    if (control & SECURITY_DESCRIPTOR_CONTROL::SE_DACL_PRESENT) {
        if (dacl > SECURITY_DESCRIPTOR_RELATIVE_SIZE) {
            padding[dacl - SECURITY_DESCRIPTOR_RELATIVE_SIZE];
        }
    }
    
    ACL acl;
};

enum INDEX_HEADER_FLAGS : u8 {
    SMALL_INDEX = 0,
    LARGE_INDEX = 1,
    LEAF_NODE   = 0,
    INDEX_NODE  = 1,
    NODE_MASK   = 1,
};

struct INDEX_HEADER {
    u32 entries_offset;
    u32 index_length;
    u32 allocated_size;
    INDEX_HEADER_FLAGS ih_flags;
    u8 reserved[3];
};

struct REPARSE_INDEX_KEY {
    u32 reparse_tag;
    leMFT_REF file_id;
};

struct SDS_ENTRY {
    u32 hash;
    u32 security_id;
    u64 offset;
    u32 length;
    SECURITY_DESCRIPTOR_RELATIVE sid;
};

using SII_INDEX_KEY = u32 ;

struct SDH_INDEX_KEY {
    u32  hash;
    u32  security_id;
};

enum INDEX_ENTRY_FLAGS : u16 {
    INDEX_ENTRY_NODE = 1,
    INDEX_ENTRY_END  = 2,
    INDEX_ENTRY_SPACE_FILLER = 0xffff,
};

struct INDEX_ENTR_HEADER_PTR {
    u16 data_offset;
    u16 data_length;
    u32 reservedV;
};

union INDEX_ENTR_HEADER_REF {
    leMFT_REF indexed_file;
    INDEX_ENTR_HEADER_PTR ptr;
};

struct INDEX_ENTRY_HEADER {
    INDEX_ENTR_HEADER_REF file_ref;
    u16 length;
    u16 key_length;
    u16 flags; // INDEX_ENTRY_FLAGS
    u16 reserved;
};

struct INDEX_ENTRY_FILE_NAME {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        FILE_NAME_ATTR key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }

    std::mem::AlignTo<8>;
};

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

struct INDEX_ENTRY_OBJ_ID {
    INDEX_ENTRY_HEADER header;

    if (!(header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_END)) {
        GUID key;
    }

    if (header.flags & INDEX_ENTRY_FLAGS::INDEX_ENTRY_NODE) {
        leVCN vcn;
    }

    std::mem::AlignTo<8>;
};

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

fn index_get_flags(u64 offset) {
    INDEX_ENTRY_HEADER index_entry_header @ offset;
    return index_entry_header.flags;
};

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

struct INDEX_ROOT {
    ATTR_TYPES type;
    COLLATION_RULES collation_rule;
    u32 index_block_size;
    s8  clusters_per_index_block;
    u8  reserved[3];

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

enum RESTART_AREA_FLAGS : u16 {
	RESTART_VOLUME_IS_CLEAN	= 0x0002,
	RESTART_SPACE_FILLER	= 0xffff,
};

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

struct LOG_CLIENT_RECORD {
    leLSN oldest_lsn;
    leLSN client_restart_lsn;
    u16 prev_client;
    u16 next_client;
    u16 seq_number;
    u8  reserved[6];
    u32 client_name_length;
    ntfschar client_name[64];
};

#define ATTR_RECORD_HEADER_SIZE                 (16)
#define ATTR_RECORD_RESIDENT_SIZE               (16 + 8)
#define ATTR_RECORD_NONRESIDENT_SIZE            (16 + 48)
#define ATTR_RECORD_NONRESIDENT_CMPR_SIZE       (16 + 48 + 8)
struct ATTR_RECORD {
    ATTR_TYPES type;
    u32 length;
    u8  non_resident;
    u8  name_length;
    u16 name_offset;
    u16 flags; // ATTR_FLAGS
    u16 instance;

    u32 name_offset_delta = 0;
    if (!non_resident) {
        u32 value_length;
        u16 value_offset;
        RESIDENT_ATTR_FLAGS resident_flags;
        s8 reservedR;

        if (name_offset > ATTR_RECORD_RESIDENT_SIZE) {
            name_offset_delta = name_offset - ATTR_RECORD_RESIDENT_SIZE; 
            padding[name_offset_delta];
        }
    } else {
        leVCN   lowest_vcn;
        leVCN   highest_vcn;
        u16     mapping_pairs_offset;
        u8      compression_unit;
        u8      reserved1[5];
        u64     allocated_size;
        u64     data_size;
        u64     initialized_size;
        
        if (flags & ATTR_FLAGS::ATTR_IS_COMPRESSED) {
            u64 compressed_size;
            
            if (name_offset > ATTR_RECORD_NONRESIDENT_CMPR_SIZE) {
                name_offset_delta = name_offset - ATTR_RECORD_NONRESIDENT_CMPR_SIZE; 
                padding[name_offset_delta];
            }
        } else {
            if (name_offset > ATTR_RECORD_NONRESIDENT_SIZE) {
                name_offset_delta = name_offset - ATTR_RECORD_NONRESIDENT_SIZE; 
                padding[name_offset_delta];
            }
        }
    }

    u32 name_length_bytes = name_length * sizeof (ntfschar);
    if (name_length > 0) {
        ntfschar name[name_length];
    }

    if (non_resident) {
        if (flags & ATTR_FLAGS::ATTR_IS_COMPRESSED) {
            if (mapping_pairs_offset > (ATTR_RECORD_NONRESIDENT_CMPR_SIZE + name_offset_delta + name_length_bytes)) {
                padding[mapping_pairs_offset - (ATTR_RECORD_NONRESIDENT_CMPR_SIZE + name_length_bytes)];
            }
        } else {
            if (mapping_pairs_offset > (ATTR_RECORD_NONRESIDENT_SIZE + name_offset_delta + name_length_bytes)) {
                padding[mapping_pairs_offset - (ATTR_RECORD_NONRESIDENT_SIZE + name_length_bytes)];
            }
        }

        RUNLIST runlist[];
    } else {
        u32 value_offset_delta = 0;
        if (value_offset > (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes)) {
            value_offset_delta = value_offset - (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes);
            padding[value_offset_delta];
        }

        match (type) {
            (ATTR_TYPES::AT_UNUSED): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_STANDARD_INFORMATION): {
                if (value_length > sizeof (STANDARD_INFORMATION_OLD)) {
                    STANDARD_INFORMATION info;

                } else {
                    STANDARD_INFORMATION_OLD info;
                }

                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta + sizeof (info));
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_ATTRIBUTE_LIST): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_FILE_NAME): FILE_NAME_ATTR file;
            (ATTR_TYPES::AT_OBJECT_ID): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_SECURITY_DESCRIPTOR): {
                SECURITY_DESCRIPTOR_RELATIVE sec;
            
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta + sizeof (sec));
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_VOLUME_NAME): ntfschar vol_name[value_length / sizeof (ntfschar)];
            (ATTR_TYPES::AT_VOLUME_INFORMATION): VOLUME_INFORMATION vol_info;
            (ATTR_TYPES::AT_DATA): {
                u8 buffer[value_length];

                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta + sizeof (buffer));
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_INDEX_ROOT): {
                INDEX_ROOT root;
            }
            (ATTR_TYPES::AT_INDEX_ALLOCATION): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_BITMAP): u8 buffer[value_length];
            (ATTR_TYPES::AT_REPARSE_POINT): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_EA_INFORMATION): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_EA): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_PROPERTY_SET): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_LOGGED_UTILITY_STREAM): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_FIRST_USER_DEFINED_ATTRIBUTE): {
                u32 attr_sum = (ATTR_RECORD_RESIDENT_SIZE + name_offset_delta + name_length_bytes + value_offset_delta);
                if (length > attr_sum) {
                    padding[length - attr_sum];
                }
            }
            (ATTR_TYPES::AT_END): {
                // length is no longer valid
            }
        }
    }

    std::mem::AlignTo<8>;
};

fn attr_get_type(u64 offset) {
    ATTR_RECORD attr @ offset;
    return attr.type;
};

#define MFT_RECORD_SIZE (sizeof (NTFS_RECORD) + 40)
struct MFT_RECORD {
    NTFS_RECORD header [[inline]];
    leLSN lsn;
    u16 sequence_number;
    u16 link_count;
    u16 attrs_offset;
    MFT_RECORD_FLAGS flags;
    u32 bytes_in_use;
    u32 bytes_allocated;
    leMFT_REF base_mft_record;
    u16 next_attr_instance;
    u16 reserved;
    u32 mft_record_number;

    if (header.usa_count > 0) {
        padding[header.usa_ofs - MFT_RECORD_SIZE];
    }
    u16 update_sequence[header.usa_count];

    std::mem::AlignTo<8>;
    ATTR_RECORD attrs[while(attr_get_type($) != ATTR_TYPES::AT_END)];
    ATTR_RECORD attr_end;
};

struct NTFS_BOOT_SECTOR {
    u8  jump[3];
    u64 oem_id;
    BIOS_PARAMETER_BLOCK bpb;
    u8  physical_drive;
    u8  current_head;
    u8  extended_boot_signature;
    u8  reserved2;
    u64 number_of_sectors;
    u64 mft_lcn;
    u64 mftmirr_lcn;
    s8  clusters_per_mft_record;
    u8  reserved0[3];
    s8  clusters_per_index_record;
    u8  reserved1[3];
    u64 volume_serial_number;
    u32 checksum;
    u8  bootstrap[426];
    u16 end_of_sector_marker;
};

fn mft_get_dat_attr_lcn(MFT_RECORD record, ATTR_TYPES type = ATTR_TYPES::AT_DATA) {
    u64 lcn = 0;

    for (u64 i = 0, i < record.next_attr_instance, i += 1) {
        if (record.attrs[i].type == type) {
            for (s64 j = record.attrs[i].runlist[0].header.offset - 1, j >= 0, j -= 1) {
                lcn |= record.attrs[i].runlist[0].lcn[j] << (8 * j);
            }
            break;
        }
    }

    return lcn;
};

// ============= VBR =============
NTFS_BOOT_SECTOR nbs @ 0x00 [[name("VBR")]];
u32 cluster_size = nbs.bpb.bytes_per_sector * nbs.bpb.sectors_per_cluster;
u32 mft_rec_size = 1 << -nbs.clusters_per_mft_record;

// ============= $MFT =============
MFT_RECORD mft @ nbs.mft_lcn * cluster_size + 0 * mft_rec_size [[name("$MFT")]];
MFT_RECORD mftmirr @ nbs.mftmirr_lcn * cluster_size [[name("$MFT Copy")]];

// ============= $MFTMirr =============
MFT_RECORD mft_mirr @ nbs.mft_lcn * cluster_size + 1 * mft_rec_size [[name("$MFTMirr")]];

// ============= $LogFile =============
MFT_RECORD mft_log @ nbs.mft_lcn * cluster_size + 2 * mft_rec_size [[name("$LogFile")]];

// ============= $Volume =============
MFT_RECORD mft_vol @ nbs.mft_lcn * cluster_size + 3 * mft_rec_size [[name("$Volume")]];

// ============= $AttrDef =============
MFT_RECORD mft_adef @ nbs.mft_lcn * cluster_size + 4 * mft_rec_size [[name("$AttrDef")]];
ATTR_DEF adef_dat_buf[16] @ mft_get_dat_attr_lcn(mft_adef) * cluster_size [[name("$AttrDef, array")]];

// ============= $I30 (Root) =============
MFT_RECORD mft_root @ nbs.mft_lcn * cluster_size + 5 * mft_rec_size [[name("$I30 (Root)")]];
INDEX_BLOCK root_index_block @ mft_get_dat_attr_lcn(mft_root, ATTR_TYPES::AT_INDEX_ALLOCATION) * cluster_size [[name("$I30 (Root), INDEX_BLOCK")]];

// ============= $Bitmap =============
MFT_RECORD mft_bm @ nbs.mft_lcn * cluster_size + 6 * mft_rec_size [[name("$Bitmap")]];

// ============= $Boot =============
MFT_RECORD mft_boot @ nbs.mft_lcn * cluster_size + 7 * mft_rec_size [[name("$Boot")]];

// ============= $BadClus =============
MFT_RECORD mft_badclus @ nbs.mft_lcn * cluster_size + 8 * mft_rec_size [[name("$BadClus")]];

// ============= $Secure ($Quota for NTFS 1.2) =============
MFT_RECORD mft_sec @ nbs.mft_lcn * cluster_size + 9 * mft_rec_size [[name("$Secure")]];

// ============= $UpCase =============
MFT_RECORD mft_uc @ nbs.mft_lcn * cluster_size + 10 * mft_rec_size [[name("$UpCase")]];

// ============= $Extend =============
MFT_RECORD mft_ext @ nbs.mft_lcn * cluster_size + 11 * mft_rec_size [[name("$Extend")]];