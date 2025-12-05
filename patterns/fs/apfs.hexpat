#pragma author Hrant Tadevosyan (Axcient, now ConnectWise)
#pragma description Apple File System (APFS)
#pragma endian little

// refs:
// - https://developer.apple.com/support/downloads/Apple-File-System-Reference.pdf
// - https://github.com/sgan81/apfs-fuse
// - https://github.com/libyal/libfsapfs

import std.core;
import std.hash;
import std.mem;
import type.guid;
import type.magic;
import type.time;

using paddr_t = s64;

struct prange {
    paddr_t pr_start_paddr;
    u64 pr_block_count;
};

using uuid_t = type::GUID;

#define MAX_CKSUM_SIZE 8

using oid_t = u64;
using xid_t = u64;

#define OID_NX_SUPERBLOCK       1
#define OID_INVALID             0ULL
#define OID_RESERVED_COUNT      1024

#define OBJECT_TYPE_MASK        0x0000ffff
#define OBJECT_TYPE_FLAGS_MASK  0xffff0000

#define OBJ_STORAGETYPE_MASK            0xc0000000
#define OBJECT_TYPE_FLAGS_DEFINED_MASK  0xf8000000

enum o_type_id_t : u16 {
    OBJECT_TYPE_NX_SUPERBLOCK       = 0x0001,
    OBJECT_TYPE_BTREE               = 0x0002,
    OBJECT_TYPE_BTREE_NODE          = 0x0003,
    OBJECT_TYPE_SPACEMAN            = 0x0005,
    OBJECT_TYPE_SPACEMAN_CAB        = 0x0006,
    OBJECT_TYPE_SPACEMAN_CIB        = 0x0007,
    OBJECT_TYPE_SPACEMAN_BITMAP     = 0x0008,
    OBJECT_TYPE_SPACEMAN_FREE_QUEUE = 0x0009,
    OBJECT_TYPE_EXTENT_LIST_TREE    = 0x000a,
    OBJECT_TYPE_OMAP                = 0x000b,
    OBJECT_TYPE_CHECKPOINT_MAP      = 0x000c,
    OBJECT_TYPE_FS                  = 0x000d,
    OBJECT_TYPE_FSTREE              = 0x000e,
    OBJECT_TYPE_BLOCKREFTREE        = 0x000f,
    OBJECT_TYPE_SNAPMETATREE        = 0x0010,
    OBJECT_TYPE_NX_REAPER           = 0x0011,
    OBJECT_TYPE_NX_REAP_LIST        = 0x0012,
    OBJECT_TYPE_OMAP_SNAPSHOT       = 0x0013,
    OBJECT_TYPE_EFI_JUMPSTART       = 0x0014,
    OBJECT_TYPE_FUSION_MIDDLE_TREE  = 0x0015,
    OBJECT_TYPE_NX_FUSION_WBC       = 0x0016,
    OBJECT_TYPE_NX_FUSION_WBC_LIST  = 0x0017,
    OBJECT_TYPE_ER_STATE            = 0x0018,
    OBJECT_TYPE_GBITMAP             = 0x0019,
    OBJECT_TYPE_GBITMAP_TREE        = 0x001a,
    OBJECT_TYPE_GBITMAP_BLOCK       = 0x001b,
    OBJECT_TYPE_ER_RECOVERY_BLOCK   = 0x001c,
    OBJECT_TYPE_SNAP_META_EXT       = 0x001d,
    OBJECT_TYPE_INTEGRITY_META      = 0x001e,
    OBJECT_TYPE_FEXT_TREE           = 0x001f,
    OBJECT_TYPE_RESERVED_20         = 0x0020,
    OBJECT_TYPE_INVALID             = 0x0000,
    OBJECT_TYPE_TEST                = 0x00ff,
    OBJECT_TYPE_CONTAINER_KEYBAG    = 0x7973, // ys  ->  keys
    OBJECT_TYPE_CONTAINER_KEYBAG_2  = 0x6B65, // ke  ->
    //OBJECT_TYPE_VOLUME_KEYBAG       = "recs",
    //OBJECT_TYPE_MEDIA_KEYBAG        = "mkey",
};

enum o_flag_id_t : u16 {
    OBJ_VIRTUAL             = 0x0000,
    OBJ_EPHEMERAL           = 0x8000,
    OBJ_PHYSICAL            = 0x4000,
    OBJ_NOHEADER            = 0x2000,
    OBJ_ENCRYPTED           = 0x1000,
    OBJ_NONPERSISTENT       = 0x0800,
};

struct o_type_t {
    o_type_id_t t_type;
    o_flag_id_t t_flag;
};

struct obj_phys_t {
    u8 o_cksum[MAX_CKSUM_SIZE];
    oid_t o_oid;
    xid_t o_xid;
    o_type_t o_type;
    o_type_t o_subtype;
};

#define NX_MAGIC_RE                     "BSXN"
#define NX_MAGIC                        "NXSB"
#define NX_MAX_FILE_SYSTEMS             100
#define NX_EPH_INFO_COUNT               4
#define NX_EPH_MIN_BLOCK_COUNT          8
#define NX_MAX_FILE_SYSTEM_EPH_STRUCTS  4
#define NX_TX_MIN_CHECKPOINT_COUNT      4
#define NX_EPH_INFO_VERSION_1           1

#define NX_RESERVED_1   0x00000001LL
#define NX_RESERVED_2   0x00000002LL
#define NX_CRYPTO_SW    0x00000004LL

#define NX_FEATURE_DEFRAG               0x0000000000000001ULL
#define NX_FEATURE_LCFD                 0x0000000000000002ULL
#define NX_SUPPORTED_FEATURES_MASK      (NX_FEATURE_DEFRAG | NX_FEATURE_LCFD)

bitfield nx_features_t {
    unsigned defrag : 1;
    unsigned lcfd   : 1;
    padding         : 62;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define NX_SUPPORTED_ROCOMPAT_MASK (0x0ULL)

bitfield nx_rocompat_features_t {
    padding : 64;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define NX_INCOMPAT_VERSION1            0x0000000000000001ULL
#define NX_INCOMPAT_VERSION2            0x0000000000000002ULL
#define NX_INCOMPAT_FUSION              0x0000000000000100ULL
#define NX_SUPPORTED_INCOMPAT_MASK      (NX_INCOMPAT_VERSION2 | NX_INCOMPAT_FUSION)

bitfield nx_incompat_features_t {
    version1 : 1;
    version2 : 1;
    padding  : 6;
    fusion   : 1;
    padding  : 55;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define NX_MINIMUM_BLOCK_SIZE 4096
#define NX_DEFAULT_BLOCK_SIZE 4096
#define NX_MAXIMUM_BLOCK_SIZE 65536

#define NX_MINIMUM_CONTAINER_SIZE 1048576

enum nx_counter_id_t : u64 {
    NX_CNTR_OBJ_CKSUM_SET   = 0,
    NX_CNTR_OBJ_CKSUM_FAIL  = 1,
    NX_NUM_COUNTERS         = 32
};

struct nx_superblock_t {
    obj_phys_t nx_o;
    type::Magic<NX_MAGIC> nx_magic;
    u32 nx_block_size;
    u64 nx_block_count;
    nx_features_t nx_features;
    nx_rocompat_features_t nx_readonly_compatible_features;
    nx_incompat_features_t nx_incompatible_features;
    uuid_t nx_uuid;
    oid_t nx_next_oid;
    xid_t nx_next_xid;
    u32 nx_xp_desc_blocks;
    u32 nx_xp_data_blocks;
    paddr_t nx_xp_desc_base;
    paddr_t nx_xp_data_base;
    u32 nx_xp_desc_next;
    u32 nx_xp_data_next;
    u32 nx_xp_desc_index;
    u32 nx_xp_desc_len;
    u32 nx_xp_data_index;
    u32 nx_xp_data_len;
    oid_t nx_spaceman_oid;
    oid_t nx_omap_oid;
    oid_t nx_reaper_oid;
    u32 nx_test_type;
    u32 nx_max_file_systems;
    oid_t nx_fs_oid[NX_MAX_FILE_SYSTEMS];
    nx_counter_id_t nx_counters[nx_counter_id_t::NX_NUM_COUNTERS];
    prange nx_blocked_out_prange;
    oid_t nx_evict_mapping_tree_oid;
    u64 nx_flags;
    paddr_t nx_efi_jumpstart;
    uuid_t nx_fusion_uuid;
    prange nx_keylocker;
    u64 nx_ephemeral_info[NX_EPH_INFO_COUNT];
    oid_t nx_test_oid;
    oid_t nx_fusion_mt_oid;
    oid_t nx_fusion_wbc_oid;
    prange nx_fusion_wbc;
    u64 nx_newest_mounted_version;
    prange nx_mkb_locker;
};

#define CHECKPOINT_MAP_LAST 0x00000001

struct checkpoint_mapping_t {
    o_type_t cpm_type;
    o_type_t cpm_subtype;
    u32 cpm_size;
    u32 cpm_pad;
    oid_t cpm_fs_oid;
    oid_t cpm_oid;
    oid_t cpm_paddr;
};

struct checkpoint_map_phys_t {
    obj_phys_t cpm_o;
    u32 cpm_flags;
    u32 cpm_count;

    checkpoint_mapping_t cpm_map[cpm_count];
};

struct evict_mapping_val_t {
    paddr_t dst_paddr;
    u64 len;
};

struct omap_phys_t {
    obj_phys_t om_o;
    u32 om_flags;
    u32 om_snap_count;
    u32 om_tree_type;
    u32 om_snapshot_tree_type;
    oid_t om_tree_oid;
    oid_t om_snapshot_tree_oid;
    xid_t om_most_recent_snap;
    xid_t om_pending_revert_min;
    xid_t om_pending_revert_max;
};

struct omap_key_t {
	oid_t ok_oid;
	oid_t ok_xid;
};

struct omap_val_t {
	u32 ov_flags;
	u32 ov_size;
	paddr_t ov_paddr;
};

struct omap_snapshot_t {
	u32 oms_flags;
	u32 oms_pad;
	oid_t oms_oid;
};

struct chunk_info_t {
	u64 ci_xid;
	u64 ci_addr;
	u32 ci_block_count;
	u32 ci_free_count;
	paddr_t ci_bitmap_addr;
};

struct chunk_info_block_t {
	obj_phys_t cib_o;
	u32 cib_index;
	u32 cib_chunk_info_count;
	chunk_info_t cib_chunk_info[cib_chunk_info_count];
};

struct cib_addr_block_t {
	obj_phys_t cab_o;
	u32 cab_index;
	u32 cab_cib_count;
	paddr_t cab_cib_addr[cab_cib_count];
};

struct spaceman_free_queue_key_t {
	xid_t sfqk_xid;
	paddr_t sfqk_paddr;
};

using spaceman_free_queue_val_t = u64;
struct spaceman_free_queue_entry_t {
	spaceman_free_queue_key_t sfqe_key;
	spaceman_free_queue_val_t sfqe_count;
};

struct spaceman_free_queue_t {
	u64 sfq_count;
	oid_t sfq_tree_oid;
	xid_t sfq_oldest_xid;
	u16 sfq_tree_node_limit;
	u16 sfq_pad16;
	u32 sfq_pad32;
	u64 sfq_reserved;
};

struct spaceman_device_t {
    u64 sm_block_count;
    u64 sm_chunk_count;
    u32 sm_cib_count;
    u32 sm_cab_count;
    u64 sm_free_count;
    u32 sm_addr_offset;
    u32 sm_reserved;
    u64 sm_reserved2;
};

enum smdev_t : u32 {
    SD_MAIN     = 0,
    SD_TIER2    = 1,
    SD_COUNT    = 2
};

enum sfq_t : u32 {
    SFQ_IP      = 0,
    SFQ_MAIN    = 1,
    SFQ_TIER2   = 2,
    SFQ_COUNT   = 3
};

struct spaceman_allocation_zone_boundaries_t {
    u64 saz_zone_start;
    u64 saz_zone_end;
};

#define SM_ALLOCZONE_INVALID_END_BOUNDARY       0
#define SM_ALLOCZONE_NUM_PREVIOUS_BOUNDARIES    7
struct spaceman_allocation_zone_info_phys_t {
    spaceman_allocation_zone_boundaries_t saz_current_boundaries;
    spaceman_allocation_zone_boundaries_t saz_previous_boundaries[SM_ALLOCZONE_NUM_PREVIOUS_BOUNDARIES];
    u16 saz_zone_id;
    u16 saz_previous_boundary_index;
    u32 saz_reserved;
};

struct spaceman_allocation_zones_t {
    spaceman_allocation_zone_info_phys_t sdz_allocation_zone_infos[smdev_t::SD_COUNT];
};

#define SM_DATAZONE_ALLOCZONE_COUNT 8
struct spaceman_datazone_info_phys_t {
    spaceman_allocation_zones_t sdz_allocation_zones[SM_DATAZONE_ALLOCZONE_COUNT];
};

struct spaceman_phys_t {
    obj_phys_t sm_o;
    u32 sm_block_size;
    u32 sm_blocks_per_chunk;
    u32 sm_chunks_per_cib;
    u32 sm_cibs_per_cab;
    spaceman_device_t sm_dev[smdev_t::SD_COUNT];
    u32 sm_flags;
    u32 sm_ip_bm_tx_multiplier;
    u64 sm_ip_block_count;
    u32 sm_ip_bm_size_in_blocks;
    u32 sm_ip_bm_block_count;
    paddr_t sm_ip_bm_base;
    paddr_t sm_ip_base;
    u64 sm_fs_reserve_block_count;
    u64 sm_fs_reserve_alloc_count;
    spaceman_free_queue_t sm_fq[sfq_t::SFQ_COUNT];
    u16 sm_ip_bm_free_head;
    u16 sm_ip_bm_free_tail;
    u32 sm_ip_bm_xid_offset;
    u32 sm_ip_bitmap_offset;
    u32 sm_ip_bm_free_next_offset;
    u32 sm_version;
    u32 sm_struct_size;
    spaceman_datazone_info_phys_t sm_datazone;
};

struct nx_reaper_phys_t {
	obj_phys_t nr_o;
	u64 nr_next_reap_id;
	u64 nr_completed_id;
	oid_t nr_head;
	oid_t nr_tail;
	u32 nr_flags;
	u32 nr_rlcount;
	u32 nr_type;
	u32 nr_size;
	oid_t nr_fs_oid;
	oid_t nr_oid;
	xid_t nr_xid;
	u32 nr_nrle_flags;
	u32 nr_state_buffer_size;
	u8 nr_state_buffer[nr_state_buffer_size];
};

struct nx_reap_list_entry_t {
	u32 nrle_next;
	u32 nrle_flags;
	u32 nrle_type;
	u32 nrle_size;
	oid_t nrle_fs_oid;
	oid_t nrle_oid;
	xid_t nrle_xid;
};

struct nx_reap_list_phys_t {
	obj_phys_t nrl_o;
	oid_t nrl_next;
	u32 nrl_flags;
	u32 nrl_max;
	u32 nrl_count;
	u32 nrl_first;
	u32 nrl_last;
	u32 nrl_free;
	nx_reap_list_entry_t nrl_entries[nrl_count];
};

enum nx_reap_phase_t : u32 {
	APFS_REAP_PHASE_START           = 0,
	APFS_REAP_PHASE_SNAPSHOTS       = 1,
	APFS_REAP_PHASE_ACTIVE_FS       = 2,
	APFS_REAP_PHASE_DESTROY_OMAP    = 3,
	APFS_REAP_PHASE_DONE            = 4,
};

struct keybag_entry_t {
	uuid_t ke_uuid;
	u16 ke_tag;
	u16 ke_keylen;
	padding[4];
	u8 ke_keydata[];
};

struct kb_locker_t {
	u16 kl_version;
	u16 kl_nkeys;
	u32 kl_nbytes;
	padding[8];
	u8 kl_entries[];
};

struct mk_obj_t {
	u8 o_cksum[MAX_CKSUM_SIZE];
	oid_t o_oid;
	xid_t o_xid;
	o_type_id_t o_type;
	o_type_id_t o_subtype;
};

struct media_keybag_t {
	mk_obj_t mk_obj;
	kb_locker_t mk_locker;
};

using crypto_flags_t = u32;
using cp_key_class_t = u32;
using cp_key_os_version_t = u32;
using cp_key_revision_t = u16;

struct wrapped_crypto_state_t {
	u16 major_version;
	u16 minor_version;
	crypto_flags_t cpflags;
	cp_key_class_t persistent_class;
	cp_key_os_version_t key_os_version;
	cp_key_revision_t key_revision;
	u16 key_len;
	u8 persistent_key[0];
};

struct wrapped_meta_crypto_state_t {
	u16 major_version;
	u16 minor_version;
	crypto_flags_t cpflags;
	cp_key_class_t persistent_class;
	cp_key_os_version_t key_os_version;
	cp_key_revision_t key_revision;
	u16 unused;
};

struct j_crypto_key_t {
	// j_key_t hdr;
};

struct j_crypto_val_t {
	u32 refcnt;
	wrapped_crypto_state_t state;
};

#define APFS_MODIFIED_NAMELEN 32
struct apfs_modified_by_t {
    u8 id[APFS_MODIFIED_NAMELEN];
    u64 timestamp;
    xid_t last_xid;
};

bitfield apfs_fs_flags_t {
    APFS_FS_UNENCRYPTED : 1;
    APFS_FS_RESERVED_2 : 1;
    APFS_FS_RESERVED_4 : 1;
    APFS_FS_ONEKEY : 1;
    APFS_FS_SPILLEDOVER : 1;
    APFS_FS_RUN_SPILLOVER_CLEANER : 1;
    APFS_FS_ALWAYS_CHECK_EXTENTREF : 1;
    APFS_FS_RESERVED_80 : 1;
    APFS_FS_RESERVED_100 : 1;
    padding : 55;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

bitfield apfs_incompatible_features_t {
    APFS_INCOMPAT_CASE_INSENSITIVE : 1;
    APFS_INCOMPAT_DATALESS_SNAPS : 1;
    APFS_INCOMPAT_ENC_ROLLED : 1;
    APFS_INCOMPAT_NORMALIZATION_INSENSITIVE : 1;
    APFS_INCOMPAT_INCOMPLETE_RESTORE : 1;
    APFS_INCOMPAT_SEALED_VOLUME : 1;
    APFS_INCOMPAT_RESERVED_40 : 1;
    padding : 57;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

apfs_incompatible_features_t apfs_incompatible_features_null;

#define APFS_MAGIC "BSPA"
#define APFS_MAGIC_LE "APSB"
#define APFS_MAX_HIST 8
#define APFS_VOLNAME_LEN 256
struct apfs_superblock_t {
    obj_phys_t apfs_o;
    type::Magic<APFS_MAGIC_LE> apfs_magic;
    u32 apfs_fs_index;
    u64 apfs_features;
    u64 apfs_readonly_compatible_features;
    apfs_incompatible_features_t apfs_incompatible_features;
    u64 apfs_unmount_time;
    u64 apfs_fs_reserve_block_count;
    u64 apfs_fs_quota_block_count;
    u64 apfs_fs_alloc_count;
    wrapped_meta_crypto_state_t apfs_meta_crypto;
    o_type_t apfs_root_tree_type;
    o_type_t apfs_extentref_tree_type;
    o_type_t apfs_snap_meta_tree_type;
    oid_t apfs_omap_oid;
    oid_t apfs_root_tree_oid;
    oid_t apfs_extentref_tree_oid;
    oid_t apfs_snap_meta_tree_oid;
    xid_t apfs_revert_to_xid;
    oid_t apfs_revert_to_sblock_oid;
    u64 apfs_next_obj_id;
    u64 apfs_num_files;
    u64 apfs_num_directories;
    u64 apfs_num_symlinks;
    u64 apfs_num_other_fsobjects;
    u64 apfs_num_snapshots;
    u64 apfs_total_blocks_alloced;
    u64 apfs_total_blocks_freed;
    uuid_t apfs_vol_uuid;
    u64 apfs_last_mod_time;
    apfs_fs_flags_t apfs_fs_flags;
    apfs_modified_by_t apfs_formatted_by;
    apfs_modified_by_t apfs_modified_by[APFS_MAX_HIST];
    char apfs_volname[APFS_VOLNAME_LEN];
    u32 apfs_next_doc_id;
    u16 apfs_role;
    u16 reserved;
    xid_t apfs_root_to_xid;
    oid_t apfs_er_state_oid;
    u64 apfs_cloneinfo_id_epoch;
    u64 apfs_cloneinfo_xid;
    oid_t apfs_snap_meta_ext_oid;
    uuid_t apfs_volume_group_id;
    oid_t apfs_integrity_meta_oid;
    oid_t apfs_fext_tree_oid;
    o_type_t apfs_fext_tree_type;
    u32 reserved_type;
    oid_t reserved_oid;
};

#define OBJ_ID_MASK     0x0FFFFFFFFFFFFFFF
#define OBJ_TYPE_MASK   0xF000000000000000
#define OBJ_TYPE_SHIFT  60

struct j_inode_key_t {
	// j_key_t hdr;
};

bitfield j_inode_flags_t {
	INODE_IS_APFS_PRIVATE : 1;
	INODE_MAINTAIN_DIR_STATS : 1;
	INODE_DIR_STATS_ORIGIN : 1;
	INODE_PROT_CLASS_EXPLICIT : 1;
	INODE_WAS_CLONED : 1;
	INODE_FLAGS_UNUSED : 1;
	INODE_HAS_SECURITY_EA : 1;
	INODE_BEING_TRUNCATED : 1;
	INODE_HAS_FINDER_INFO : 1;
	INODE_IS_SPARSE : 1;
	INODE_WAS_EVER_CLONED : 1;
	INODE_ACTIVE_FILE_TRIMMED : 1;
	INODE_PINNED_TO_MAIN : 1;
	INODE_PINNED_TO_TIER2 : 1;
	INODE_HAS_RSRC_FORK : 1;
	INODE_NO_RSRC_FORK : 1;
	INODE_ALLOCATION_SPILLEDOVER : 1;
	INODE_FAST_PROMOTE : 1;
	INODE_HAS_UNCOMPRESSED_SIZE : 1;
	INODE_IS_PURGEABLE : 1;
	INODE_WANTS_TO_BE_PURGEABLE : 1;
	INODE_IS_SYNC_ROOT : 1;
	INODE_SNAPSHOT_COW_EXEMPTION : 1;
    padding : 41;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define INODE_INHERITED_INTERNAL_FLAGS  (INODE_MAINTAIN_DIR_STATS | INODE_SNAPSHOT_COW_EXEMPTION)
#define INODE_CLONED_INTERNAL_FLAGS     (INODE_HAS_RSRC_FORK | INODE_NO_RSRC_FORK | INODE_HAS_FINDER_INFO | INODE_SNAPSHOT_COW_EXEMPTION)

#define  OWNING_OBJ_ID_INVALID  ~0ULL
#define  OWNING_OBJ_ID_UNKNOWN  ~1ULL

#define  JOBJ_MAX_KEY_SIZE      832
#define  JOBJ_MAX_VALUE_SIZE    3808

#define MIN_DOC_ID = 3;

#define FEXT_CRYPTO_ID_IS_TWEAK 0x01

enum mode_t : u16 {
    MODE_S_IFMT     = 0o170000,
    MODE_S_IFIFO    = 0o010000,
    MODE_S_IFCHR    = 0o020000,
    MODE_S_IFDIR    = 0o040000,
    MODE_S_IFBLK    = 0o060000,
    MODE_S_IFREG    = 0o100000,
    MODE_S_IFLNK    = 0o120000,
    MODE_S_IFSOCK   = 0o140000,
    MODE_S_IFWHT    = 0o160000,
};

struct j_inode_val_t {
	u64 parent_id;
	u64 private_id;
	type::time64_t create_time;
	type::time64_t mod_time;
	type::time64_t change_time;
	type::time64_t access_time;
	j_inode_flags_t internal_flags;

    u32 nchildren; // or links

	cp_key_class_t default_protection_class;

	u32 write_generation_counter;
	u32 bsd_flags;
	u32 owner;
	u32 group;
	mode_t mode;
	u16 pad1;
	u64 uncompressed_size;
	u8 xfields[1];
};

#define J_DREC_LEN_MASK     0x000003FF
#define J_DREC_HASH_MASK    0xFFFFFC00
#define J_DREC_HASH_SHIFT   10

struct j_drec_key_t {
	// j_key_t hdr;
	u16 name_len;
	char name[name_len];
};

bitfield j_drec_hashed_len_t {
    length : 10;
    hash : 22;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 32)]];

struct j_drec_hashed_key_t {
	// j_key_t hdr;
	j_drec_hashed_len_t name_len_and_hash;
	char name[name_len_and_hash.length];
};

enum dir_rec_flags_type_t : u8 {
    DT_UNKNOWN  = 0,
    DT_FIFO     = 1,
    DT_CHR      = 2,
    DT_DIR      = 4,
    DT_BLK      = 6,
    DT_REG      = 8,
    DT_LNK      = 10,
    DT_SOCK     = 12,
    DT_WHT      = 14,
};

bitfield dir_rec_flags_t {
	DREC_TYPE_MASK  : 8;
	RESERVED_10     : 1;
    padding : 55;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

struct j_drec_val_t {
	u64 file_id;
	u64 date_added;
	dir_rec_flags_t flags;
	u8 xfields[];
};

struct j_dir_stats_key_t {
	// j_key_t hdr;
};

struct j_dir_stats_val_t {
	u64 num_children;
	u64 total_size;
	u64 chained_key;
	u64 gen_count;
};

struct j_xattr_key_t {
	// j_key_t hdr;
	u16 name_len;
	char name[name_len];
};

bitfield j_xattr_flags_t {
	XATTR_DATA_STREAM       : 1;
	XATTR_DATA_EMBEDDED     : 1;
	XATTR_FILE_SYSTEM_OWNED : 1;
	XATTR_RESERVED_8        : 1;
    padding : 12;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 16)]];

#define XATTR_MAX_EMBEDDED_SIZE 3804
#define SYMLINK_EA_NAME             "com.apple.fs.symlink"
#define FIRMLINK_EA_NAME            "com.apple.fs.firmlink"
#define APFS_COW_EXEMPT_COUNT_NAME  "com.apple.fs.cow-exempt-file-count"

struct j_xattr_val_t {
	j_xattr_flags_t flags;
	u16 xdata_len;
	u8 xdata[xdata_len];
};

enum j_obj_kinds_t : u8 {
	APFS_KIND_ANY           = 0,
	APFS_KIND_NEW           = 1,
	APFS_KIND_UPDATE        = 2,
	APFS_KIND_DEAD          = 3,
	APFS_KIND_UPDATE_REFCNT = 4,

	APFS_KIND_INVALID = 255
};

bitfield j_inode_bsd_flags {
	APFS_UF_NODUMP : 1;
	APFS_UF_IMMUTABLE : 1;
	APFS_UF_APPEND : 1;
	APFS_UF_OPAQUE : 1;
	APFS_UF_NOUNLINK : 1;
	APFS_UF_COMPRESSED : 1;
	APFS_UF_TRACKED : 1;
	APFS_UF_DATAVAULT : 1;
    reserved : 7;
	APFS_UF_HIDDEN : 1;
	APFS_SF_ARCHIVED : 1;
	APFS_SF_IMMUTABLE : 1;
	APFS_SF_APPEND : 1;
	APFS_SF_RESTRICTED : 1;
	APFS_SF_NOUNLINK : 1;
	APFS_SF_SNAPSHOT : 1;
	APFS_SF_FIRMLINK : 1;
    padding : 6;
	APFS_SF_DATALESS : 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define INVALID_INO_NUM         0
#define ROOT_DIR_PARENT         1
#define ROOT_DIR_INO_NUM        2
#define PRIV_DIR_INO_NUM        3
#define SNAP_DIR_INO_NUM        6
#define PURGEABLE_DIR_INO_NUM   7
#define MIN_USER_INO_NUM        16

#define UNIFIED_ID_SPACE_MARK 0x0800000000000000

struct j_phys_ext_key_t {
	// j_key_t hdr;
};

struct j_phys_ext_val_t {
	u64 len_and_kind;
	u64 owning_obj_id;
	u32 refcnt;
};

#define PEXT_LEN_MASK 0x0fffffffffffffffULL
#define PEXT_KIND_MASK 0xf000000000000000ULL
#define PEXT_KIND_SHIFT 60

struct j_file_extent_key_t {
	// j_key_t hdr;
	u64 logical_addr;
};

struct j_file_extent_val_t {
	u64 len_and_flags;
	u64 phys_block_num;
	u64 crypto_id;
};

#define J_FILE_EXTENT_LEN_MASK 0x00ffffffffffffffULL
#define J_FILE_EXTENT_FLAG_MASK 0xff00000000000000ULL
#define J_FILE_EXTENT_FLAG_SHIFT 56

struct j_dstream_id_key_t {
	// j_key_t hdr;
};

struct j_dstream_id_val_t {
	u32 refcnt;
};

struct j_dstream_t {
	u64 size;
	u64 alloced_size;
	u64 default_crypto_id;
	u64 total_bytes_written;
	u64 total_bytes_read;
};

struct j_xattr_dstream_t {
	u64 xattr_obj_id;
	j_dstream_t dstream;
};

struct xf_blob_t {
	u16 xf_num_exts;
	u16 xf_used_data;
	u8 xf_data[];
};

enum x_type_t : u8 {
	DREC_EXT_TYPE_SIBLING_ID = 1,

	INO_EXT_TYPE_SNAP_XID = 1,
	INO_EXT_TYPE_DELTRA_TREE_OID = 2,
	INO_EXT_TYPE_DOCUMENT_ID = 3,
	INO_EXT_TYPE_NAME = 4,
	INO_EXT_TYPE_PREV_FSIZE = 5,
	INO_EXT_TYPE_RESERVED_6 = 6,
	INO_EXT_TYPE_FINDER_INFO = 7,
	INO_EXT_TYPE_DSTREAM = 8,
	INO_EXT_TYPE_RESERVED_9 = 9,
	INO_EXT_TYPE_DIR_STATS_KEY = 10,
	INO_EXT_TYPE_FS_UUID = 11,
	INO_EXT_TYPE_RESERVED_12 = 12,
	INO_EXT_TYPE_SPARSE_BYTES = 13,
	INO_EXT_TYPE_RDEV = 14,
	INO_EXT_TYPE_PURGEABLE_FLAGS = 15,
	INO_EXT_TYPE_ORIG_SYNC_ROOT_ID = 16
};

bitfield x_flags_t {
    XF_DATA_DEPENDENT : 1;
    XF_DO_NOT_COPY : 1;
    XF_RESERVED_4 : 1;
    XF_CHILDREN_INHERIT : 1;
    XF_USER_FIELD : 1;
    XF_SYSTEM_FIELD : 1;
    XF_RESERVED_40 : 1;
    XF_RESERVED_80 : 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 8)]];

struct x_field_t {
	x_type_t x_type;
	x_flags_t x_flags;
	u16 x_size;
};

struct j_sibling_key_t {
	// j_key_t hdr;
	u64 sibling_id;
};

struct j_sibling_val_t {
	u64 parent_id;
	u16 name_len;
	char name[name_len];
};

struct j_sibling_map_key_t {
	// j_key_t hdr;
};

struct j_sibling_map_val_t {
	u64 file_id;
};

struct j_snap_metadata_key_t {
	// j_key_t hdr;
};

bitfield snap_meta_flags_t {
	SNAP_META_PENDING_DATALESS  : 1;
	SNAP_META_MERGE_IN_PROGRESS : 1;
    padding : 30;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 32)]];

struct j_snap_metadata_val_t {
	oid_t extentref_tree_oid;
	oid_t sblock_oid;
	type::time64_t create_time;
	type::time64_t change_time;
	u64 inum;
	o_type_t extentref_tree_type;
	snap_meta_flags_t flags;
	u16 name_len;
	char name[name_len];
};

struct j_snap_name_key_t {
	// j_key_t hdr;
	u16 name_len;
	char name[name_len];
};

struct j_snap_name_val_t {
	xid_t snap_xid;
};

bitfield j_file_info_lba_t {
    lba : 56;
    type : 8;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

#define J_FILE_INFO_LBA_MASK    0x00FFFFFFFFFFFFFF
#define J_FILE_INFO_TYPE_MASK   0xFF00000000000000
#define J_FILE_INFO_TYPE_SHIFT  56
struct j_file_info_key_t {
	// j_key_t hdr;
	j_file_info_lba_t info_and_lba;
};

struct j_file_data_hash_val_t {
	u16 hashed_len;
	u8 hash_size;
	u8 hash[hash_size];
};

struct j_file_info_val_t {
	j_file_data_hash_val_t dhash;
};

enum j_obj_types_t : u8 {
	APFS_TYPE_ANY           = 0,
	APFS_TYPE_SNAP_METADATA = 1,
	APFS_TYPE_EXTENT        = 2,
	APFS_TYPE_INODE         = 3,
	APFS_TYPE_XATTR         = 4,
	APFS_TYPE_SIBLING_LINK  = 5,
	APFS_TYPE_DSTREAM_ID    = 6,
	APFS_TYPE_CRYPTO_STATE  = 7,
	APFS_TYPE_FILE_EXTENT   = 8,
	APFS_TYPE_DIR_REC       = 9,
	APFS_TYPE_DIR_STATS     = 10,
	APFS_TYPE_SNAP_NAME     = 11,
	APFS_TYPE_SIBLING_MAP   = 12,
	APFS_TYPE_FILE_INFO     = 13,
	APFS_TYPE_INVALID       = 15,
};

bitfield j_key_t {
    unsigned obj_id : 60;
    j_obj_types_t obj_type : 4;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 64)]];

struct nloc_t {
	u16 off;
	u16 len;
};

struct kvloc_t {
	nloc_t key_loc;
	nloc_t val_loc;
};

struct kvoff_t {
	u16 key_off;
	u16 val_off;
};

struct kvgen_t<auto subtype, auto btn_level, auto btn_flags, auto key_area, auto val_area, auto vol_incomp> {
    u16 key_off = 0;
    u16 val_off = 0;
    if (btn_flags.BTNODE_FIXED_KV_SIZE) {
        kvoff_t range;

        key_off = range.key_off;
        val_off = range.val_off;
    } else {
        kvloc_t range;

        key_off = range.key_loc.off;
        val_off = range.val_loc.off;
    }
    
    match (subtype) {
        (o_type_id_t::OBJECT_TYPE_OMAP): {
            omap_key_t key @ key_area + key_off;
                
            if (btn_level > 0) {
                oid_t node_oid @ val_area - val_off;
            } else {
                omap_val_t val @ val_area - val_off;
            }
        }
        (o_type_id_t::OBJECT_TYPE_FSTREE | o_type_id_t::OBJECT_TYPE_BLOCKREFTREE | o_type_id_t::OBJECT_TYPE_SNAPMETATREE): {
            j_key_t key @ key_area + key_off;
            match (key.obj_type) {
                (j_obj_types_t::APFS_TYPE_SNAP_METADATA): {
                    j_snap_metadata_key_t snap_meta_key @ key_area + key_off + sizeof (key);
            
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_snap_metadata_val_t snap_meta_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_EXTENT): {
                    j_phys_ext_key_t phys_ext_key @ key_area + key_off + sizeof (key);
                    
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_phys_ext_val_t phys_ext_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_INODE): {
                    j_inode_key_t inode_key @ key_area + key_off + sizeof (key); 

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_inode_val_t inode_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_XATTR): {
                    j_xattr_key_t xattr_key @ key_area + key_off + sizeof (key);

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_xattr_val_t xattr_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_SIBLING_LINK): {
                    j_sibling_key_t sibling_link_key @ key_area + key_off + sizeof (key);
                                        
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_sibling_val_t sibling_link_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_DSTREAM_ID): {
                    j_dstream_id_key_t dstream_id_key @ key_area + key_off + sizeof (key);

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_dstream_id_val_t dstream_id_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_CRYPTO_STATE): {
                    j_crypto_key_t crypto_key @ key_area + key_off + sizeof (key);

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_crypto_val_t crypto_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_FILE_EXTENT): {
                    j_file_extent_key_t file_ext_key @ key_area + key_off + sizeof (key);

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_file_extent_val_t file_ext_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_DIR_REC): {
                    if (vol_incomp.APFS_INCOMPAT_CASE_INSENSITIVE ||
                        vol_incomp.APFS_INCOMPAT_NORMALIZATION_INSENSITIVE) {
                        j_drec_hashed_key_t drec_key @ key_area + key_off + sizeof (key);
                    } else {
                        j_drec_key_t drec_key @ key_area + key_off + sizeof (key);
                    }

                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_drec_val_t drec_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_DIR_STATS): {
                    j_dir_stats_key_t dir_stats_key @ key_area + key_off + sizeof (key);
                    
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_dir_stats_val_t dir_stats_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_SNAP_NAME): {
                    j_snap_name_key_t snap_name_key @ key_area + key_off + sizeof (key);
                                        
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_snap_name_val_t snap_name_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_SIBLING_MAP): {
                    j_sibling_key_t sibling_key @ key_area + key_off + sizeof (key);
                                        
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_sibling_val_t sibling_val @ val_area - val_off;
                    }
                }
                (j_obj_types_t::APFS_TYPE_FILE_INFO): {
                    j_file_info_key_t file_info_key @ key_area + key_off + sizeof (key);
                                        
                    if (btn_level > 0) {
                        oid_t node_oid @ val_area - val_off;
                    } else {
                        j_file_info_val_t file_info_val @ val_area - val_off;
                    }
                }
            }
        }
    }
};

bitfield btn_flags_t {
    BTNODE_ROOT : 1;
    BTNODE_LEAF : 1;
    BTNODE_FIXED_KV_SIZE : 1;
    BTNODE_HASHED : 1;
    BTNODE_NOHEADER : 1;
    padding : 10;
    BTNODE_CHECK_KOFF_INVAL : 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 16)]];

bitfield bt_flags_t {
    BTREE_UINT64_KEYS : 1;
    BTREE_SEQUENTIAL_INSERT : 1;
    BTREE_ALLOW_GHOSTS : 1;
    BTREE_EPHEMERAL : 1;
    BTREE_PHYSICAL : 1;
    BTREE_NONPERSISTENT : 1;
    BTREE_KV_NONALIGNED : 1;
    BTREE_HASHED : 1;
    BTREE_NOHEADER : 1;
    padding : 23;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 32)]];

struct btree_info_fixed_t {
	bt_flags_t bt_flags;
	u32 bt_node_size;
	u32 bt_key_size;
	u32 bt_val_size;
};

struct btree_info_t {
	btree_info_fixed_t bt_fixed;
	u32 bt_longest_key;
	u32 bt_longest_val;
	u64 bt_key_count;
	u64 bt_node_count;
};

struct btree_node_phys_t<auto block_size, auto vol_incomp> {
    u32 node_start = $;

	obj_phys_t btn_o;
	btn_flags_t btn_flags;
	u16 btn_level;
	u32 btn_nkeys;
	nloc_t btn_table_space;
	nloc_t btn_free_space;
	nloc_t btn_key_free_list;
	nloc_t btn_val_free_list;
	
    if (btn_table_space.off > $) {
        padding[btn_table_space.off - $];
    }
    u32 btn_toc_start = $;

    padding[btn_table_space.len];
    u32 key_area = $;
    u32 val_area = node_start + block_size;
    if (btn_flags.BTNODE_ROOT) {
        val_area -= sizeof (btree_info_t);
    }

    u8 btn_key_area;
    kvgen_t<btn_o.o_subtype.t_type, btn_level, btn_flags, key_area, val_area, vol_incomp> btn_toc[btn_nkeys] @ btn_toc_start;

    padding[btn_free_space.off];
    u8 btn_free_area_start;

    std::mem::AlignTo<block_size>;

    if (btn_flags.BTNODE_ROOT) {
        btree_info_t info @ node_start + block_size - sizeof (btree_info_t);
    }
};

#define BTREE_NODE_HASH_SIZE_MAX 64
struct btn_index_node_val_t {
	oid_t binv_child_oid;
	u8 binv_child_hash[BTREE_NODE_HASH_SIZE_MAX];
};

// ================== HELPERS ==================
fn fletcher64(u64 offset, u64 count, u64 init) {
	u64 sum1 = init & 0xFFFFFFFF;
	u64 sum2 = init >> 32;

	for (u64 key = 0, key < count, key += 1) {
        u32 data @ offset + key * sizeof (u32);
		sum1 += data;
		sum2 += sum1;
	}

	sum1 %= 0xFFFFFFFF;
	sum2 %= 0xFFFFFFFF;

	return (sum2 << 32) | sum1;
};

fn block_verify(u64 offset, u64 size) {
    u64 chk @ offset;
	if (chk == 0)
		return false;
	if (chk == 0xFFFFFFFFFFFFFFFF)
		return false;

    u64 cks = fletcher64(offset + MAX_CKSUM_SIZE, size / sizeof (u32) - 2, 0);
    cks = fletcher64(offset, MAX_CKSUM_SIZE / sizeof (u32), cks);
    
    std::assert(cks == 0, std::format("block verification failed, offset: 0x{:X}, size: 0x{:X}", offset, size));
};

fn object_get_latest(u64 offset, u64 count, u64 size, o_type_id_t type, u64 max = 0) {
    if (max == 0) {
        max = count;
    }

    u64 max_xid = 0;
    u64 result = 0;
    for (u64 address = offset, address <= (offset + count), address += 1) {
        if ((address - offset) >= max) {
            return result;
        }

        obj_phys_t object @ address * size;

        if (object.o_type.t_type != type) {
            continue;
        }

        if (max_xid < object.o_xid) {
            max_xid = object.o_xid;
            result = address * size;
        }
    }

    return result;
};

fn checkpoint_map_lookup(checkpoint_map_phys_t checkpoint_map, oid_t oid, o_type_id_t type) {
    for (u64 iter = 0, iter < checkpoint_map.cpm_count, iter += 1) {
        if (checkpoint_map.cpm_map[iter].cpm_oid == oid &&
            checkpoint_map.cpm_map[iter].cpm_type.t_type == type) {
            return checkpoint_map.cpm_map[iter];
        }
    }

    checkpoint_mapping_t empty;
    return empty;
};

fn keybag_is_encrypted(media_keybag_t keybag) {
    bool is_decrypted = 
        keybag.mk_obj.o_type == o_type_id_t::OBJECT_TYPE_CONTAINER_KEYBAG &&
        keybag.mk_obj.o_subtype == o_type_id_t::OBJECT_TYPE_CONTAINER_KEYBAG_2;

    std::assert(is_decrypted, "encrypted keybags are not supported");
};

fn omap_node_lookup(paddr_t off, u64 block_size, oid_t oid, xid_t xid) {
    while (true) {
        btree_node_phys_t<block_size, apfs_incompatible_features_null> node @ off;
        if (node.btn_nkeys <= 0) {
            return 0;
        }

        s64 beg = 0;
        s64 end = node.btn_nkeys - 1;
        s64 mid = 0;
        s64 idx = 0;
        while (beg <= end) {
            mid = beg + (end - beg) / 2;

            omap_key_t key = node.btn_toc[mid].key;
            if (oid > key.ok_oid) {
                beg += 1;
            } else if (oid < key.ok_oid) {
                end -= 1;
            } else if (xid > key.ok_xid) {
                beg += 1;
                idx = mid;
            } else if (xid < key.ok_xid) {
                end -= 1;
                idx = mid;
            } else {
                idx = mid;
                break;
            }
        }

        if (node.btn_level > 0) {
            off = node.btn_toc[idx].node_oid * block_size;
            continue;
        }

        omap_key_t key = node.btn_toc[idx].key;
        if (key.ok_oid == oid) {
            return node.btn_toc[idx].val.ov_paddr;
        } else {
            return 0;
        }
    }
};

fn fstree_inode_lookup(
    paddr_t root_off,
    paddr_t omap_off,
    u64 block_size,
    u64 ino,
    apfs_incompatible_features_t incomp,
    xid_t xid
) {
    u64 inode_key = (j_obj_types_t::APFS_TYPE_INODE << OBJ_TYPE_SHIFT) | (ino & OBJ_ID_MASK);
    u64 node_off = root_off;
    while (true) {
        btree_node_phys_t<block_size, incomp> node @ node_off;
        
        s64 beg = 0;
        s64 end = node.btn_nkeys - 1;
        s64 mid = 0;
        s64 current = 0;
        while (beg <= end) {
            mid = beg + (end - beg) / 2;
            u64 entry_key @ addressof (node.btn_toc[mid].key);
            if ((entry_key & OBJ_ID_MASK) > (inode_key & OBJ_ID_MASK)) {
                end -= 1;
            } else if ((entry_key & OBJ_ID_MASK) < (inode_key & OBJ_ID_MASK)) {
                beg += 1;
            } else if (((entry_key & OBJ_TYPE_MASK) >> OBJ_TYPE_SHIFT) > ((inode_key & OBJ_TYPE_MASK) >> OBJ_TYPE_SHIFT)) {
                end -= 1;
                current = mid;
            } else if (((entry_key & OBJ_TYPE_MASK) >> OBJ_TYPE_SHIFT) < ((inode_key & OBJ_TYPE_MASK) >> OBJ_TYPE_SHIFT)) {
                beg += 1;
                current = mid;
            } else {
                current = mid;
                break;
            }
        }

        if (node.btn_level > 0) {
            node_off = omap_node_lookup(
                omap_off,
                block_size,
                node.btn_toc[current].node_oid,
                xid) * superblock.nx_block_size;
            continue;
        }

        u64 entry_key @ addressof (node.btn_toc[current].key);
        if (entry_key != inode_key) {
            return 0;
        }

        return addressof (node.btn_toc[current].inode_val);
    }
};

// ================== PARSE ==================
nx_superblock_t initial_superblock @ 0x00;
nx_superblock_t superblock @ object_get_latest(
    initial_superblock.nx_xp_desc_base,
    initial_superblock.nx_xp_desc_blocks,
    initial_superblock.nx_block_size,
    o_type_id_t::OBJECT_TYPE_NX_SUPERBLOCK);

checkpoint_map_phys_t checkpoint_map @ (superblock.nx_xp_desc_base + superblock.nx_xp_desc_index) * superblock.nx_block_size;

omap_phys_t object_map @ superblock.nx_omap_oid * superblock.nx_block_size;
btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> object_map_tree @ object_map.om_tree_oid * superblock.nx_block_size;

apfs_superblock_t volume @ omap_node_lookup(
    addressof (object_map_tree),
    superblock.nx_block_size,
    superblock.nx_fs_oid[0],
    superblock.nx_o.o_xid) * superblock.nx_block_size;
omap_phys_t volume_object_map @ volume.apfs_omap_oid * superblock.nx_block_size;
btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> volume_object_map_tree @ volume_object_map.om_tree_oid * superblock.nx_block_size;

btree_node_phys_t<superblock.nx_block_size, volume.apfs_incompatible_features> volume_root_tree @ omap_node_lookup(
    addressof (volume_object_map_tree),
    superblock.nx_block_size,
    volume.apfs_root_tree_oid,
    volume.apfs_o.o_xid) * superblock.nx_block_size;
j_inode_val_t volume_root_folder @ fstree_inode_lookup(
    addressof (volume_root_tree),
    addressof (volume_object_map_tree),
    superblock.nx_block_size,
    ROOT_DIR_INO_NUM,
    volume.apfs_incompatible_features,
    volume.apfs_o.o_xid
);

btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> volume_extentref_tree @ volume.apfs_extentref_tree_oid * superblock.nx_block_size;
btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> volume_snapshot_tree @ volume.apfs_snap_meta_tree_oid * superblock.nx_block_size;

apfs_superblock_t snapshot_volume @ volume_snapshot_tree.btn_toc[0].snap_meta_val.sblock_oid * superblock.nx_block_size;
btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> snapshot_extentref_tree @ volume_snapshot_tree.btn_toc[0].snap_meta_val.extentref_tree_oid * superblock.nx_block_size;

checkpoint_mapping_t spaceman_cp = checkpoint_map_lookup(checkpoint_map, superblock.nx_spaceman_oid, o_type_id_t::OBJECT_TYPE_SPACEMAN);
spaceman_phys_t spaceman @ spaceman_cp.cpm_paddr * superblock.nx_block_size;

checkpoint_mapping_t spaceman_freequeue_manager_cp = checkpoint_map_lookup(
    checkpoint_map,
    spaceman.sm_fq[sfq_t::SFQ_IP].sfq_tree_oid,
    o_type_id_t::OBJECT_TYPE_BTREE);
btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> spaceman_freequeue_manager @ spaceman_freequeue_manager_cp.cpm_paddr * superblock.nx_block_size;

checkpoint_mapping_t spaceman_freequeue_volume_cp = checkpoint_map_lookup(
    checkpoint_map,
    spaceman.sm_fq[sfq_t::SFQ_MAIN].sfq_tree_oid,
    o_type_id_t::OBJECT_TYPE_BTREE);

btree_node_phys_t<superblock.nx_block_size, apfs_incompatible_features_null> spaceman_freequeue_volume @ spaceman_freequeue_volume_cp.cpm_paddr * superblock.nx_block_size;

paddr_t spaceman_main_cibs_addr @ addressof (spaceman) + spaceman.sm_dev[smdev_t::SD_MAIN].sm_addr_offset;
chunk_info_block_t spaceman_main_cibs[spaceman.sm_dev[smdev_t::SD_MAIN].sm_cib_count] @ spaceman_main_cibs_addr * superblock.nx_block_size;

paddr_t spaceman_tier2_cibs_addr @ addressof (spaceman) + spaceman.sm_dev[smdev_t::SD_TIER2].sm_addr_offset;
chunk_info_block_t spaceman_tier2_cibs[spaceman.sm_dev[smdev_t::SD_TIER2].sm_cib_count] @ spaceman_tier2_cibs_addr * superblock.nx_block_size;

checkpoint_mapping_t reaper_cp = checkpoint_map_lookup(checkpoint_map, superblock.nx_reaper_oid, o_type_id_t::OBJECT_TYPE_NX_REAPER);
nx_reaper_phys_t reaper @ reaper_cp.cpm_paddr * superblock.nx_block_size;

media_keybag_t container_keybag @ superblock.nx_keylocker.pr_start_paddr * superblock.nx_block_size;

// ================== VERIFY ==================
block_verify(addressof (initial_superblock), initial_superblock.nx_block_size);
block_verify(addressof (superblock), superblock.nx_block_size);
block_verify(addressof (object_map), superblock.nx_block_size);
block_verify(addressof (object_map_tree), superblock.nx_block_size);
block_verify(addressof (volume), superblock.nx_block_size);
block_verify(addressof (volume_object_map), superblock.nx_block_size);
block_verify(addressof (volume_root_tree), superblock.nx_block_size);
block_verify(addressof (spaceman), superblock.nx_block_size);
block_verify(addressof (reaper), superblock.nx_block_size);
block_verify(addressof (spaceman_freequeue_manager), superblock.nx_block_size);
block_verify(addressof (spaceman_freequeue_volume), superblock.nx_block_size);
block_verify(addressof (container_keybag), superblock.nx_block_size);
keybag_is_encrypted(container_keybag);