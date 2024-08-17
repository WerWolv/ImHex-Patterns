#pragma author endes
#pragma description ext4 volume layout parser (until inodes)

// Decodes the ext4 superblock, group descriptors and inodes.
// Does not decode the directory entries, inode data, jornal or superblock backups.
// Heavily based on the linux kernel documentation:
// https://www.kernel.org/doc/html/latest/filesystems/ext4/

#pragma endian little
#pragma magic [EF 53] @ 0x438
#pragma pattern_limit 0x90000

import type.time;
import type.size;
import type.magic;
import std.core;
import std.mem;
import std.math;


enum ext4_super_state : u16 {
    Cleanlyumounted       = 0x01,
    Errorsdetected        = 0x02,
    Orphansbeingrecovered = 0x03
};

enum ext4_super_errors : u16 {
    Continue        = 0x01,
    RemountReadOnly = 0x02,
    Panic           = 0x03
};

enum ext4_super_creator : u32 {
    Linux   = 0x00,
    Hurd    = 0x01,
    Masix   = 0x02,
    FreeBSD = 0x03,
    Lites   = 0x04
};

enum ext4_super_revision : u32 {
    ORIGINAL       = 0x00,
    V2_DYNAMIC_REV = 0x01
};

bitfield ext4_super_compat {
    COMPAT_DIR_PREALLOC       : 1 [[comment("Directory preallocation.")]];
    COMPAT_IMAGIC_INODES      : 1 [[comment("“imagic inodes”. Not clear from the code what this does.")]];
    COMPAT_HAS_JOURNAL        : 1 [[comment("Has a journal.")]];
    COMPAT_EXT_ATTR           : 1 [[comment("Supports extended attributes.")]];
    COMPAT_RESIZE_INODE       : 1 [[comment("Has reserved GDT blocks for filesystem expansion.")]];
    COMPAT_DIR_INDEX          : 1 [[comment("Has directory indices.")]];
    COMPAT_LAZY_BG            : 1 [[comment("“Lazy BG”. Not in Linux kernel, seems to have been for uninitialized block groups?.")]];
    COMPAT_EXCLUDE_INODE      : 1 [[comment("“Exclude inode”. Not used.")]];
    COMPAT_EXCLUDE_BITMAP     : 1 [[comment("“Exclude bitmap”. Seems to be used to indicate the presence of snapshot-related exclude bitmaps? Not defined in linux kernel or used in e2fsprogs.")]];
    COMPAT_SPARSE_SUPER2      : 1 [[comment("Sparse Super Block, v2. If this flag is set, the SB field s_backup_bgs points to the two block groups that contain backup superblocks.")]];
    COMPAT_FAST_COMMIT        : 1 [[comment("Journal fast commits supported.")]];
    padding                   : 1;
    RO_COMPAT_ORPHAN_PRESENT  : 1 [[comment("Orphan file allocated. This is the special file for more efficient tracking of unlinked but still open inodes.")]];
};

bitfield ext4_super_incompat {
    INCOMPAT_COMPRESSION    : 1;
    INCOMPAT_FILETYPE       : 1 [[comment("Directory entries record the file type.")]];
    INCOMPAT_RECOVER        : 1 [[comment("Filesystem needs recovery.")]];
    INCOMPAT_JOURNAL_DEV    : 1 [[comment("Filesystem has a separate journal device.")]];
    INCOMPAT_META_BG        : 1 [[comment("Meta block groups.")]];
    padding                 : 1;
    INCOMPAT_EXTENTS        : 1 [[comment("Files in this filesystem use extents.")]];
    INCOMPAT_64BIT          : 1 [[comment("Enable a filesystem size of 2^64 blocks.")]];
    INCOMPAT_MMP            : 1 [[comment("Multiple mount protection.")]];
    INCOMPAT_FLEX_BG        : 1 [[comment("Flexible block groups.")]];
    INCOMPAT_EA_INODE       : 1 [[comment("Inodes can be used to store large extended attribute values.")]];
    padding                 : 1 [[comment("Data in directory entry.")]];
    INCOMPAT_DIRDATA        : 1;
    INCOMPAT_CSUM_SEED      : 1 [[comment("Metadata checksum seed is stored in the superblock.")]];
    INCOMPAT_LARGEDIR       : 1 [[comment("Large directory >2GB or 3-level htree.")]];
    INCOMPAT_INLINE_DATA    : 1 [[comment("Data in inode.")]];
    INCOMPAT_ENCRYPT        : 1 [[comment("Encrypted inodes are present on the filesystem.")]];
};

bitfield ext4_super_compat_ro {
    RO_COMPAT_SPARSE_SUPER    : 1 [[comment("Sparse superblocks.")]];
    RO_COMPAT_LARGE_FILE      : 1 [[comment("This filesystem has been used to store a file greater than 2GiB.")]];
    RO_COMPAT_BTREE_DIR       : 1 [[comment("Not used in linux kernel or e2fsprogs.")]];
    RO_COMPAT_HUGE_FILE       : 1 [[comment("This filesystem has files whose sizes are represented in units of logical blocks, not 512-byte sectors. This implies a very large file indeed!.")]];
    RO_COMPAT_GDT_CSUM        : 1 [[comment("Group descriptors have checksums.")]];
    RO_COMPAT_DIR_NLINK       : 1 [[comment("Indicates that the old ext3 32,000 subdirectory limit no longer applies.")]];
    RO_COMPAT_EXTRA_ISIZE     : 1 [[comment("Indicates that large inodes exist on this filesystem.")]];
    RO_COMPAT_HAS_SNAPSHOT    : 1 [[comment("This filesystem has a snapshot.")]];
    RO_COMPAT_QUOTA           : 1;
    RO_COMPAT_BIGALLOC        : 1 [[comment("This filesystem supports “bigalloc”, which means that file extents are tracked in units of clusters (of blocks) instead of blocks.")]];
    RO_COMPAT_METADATA_CSUM   : 1 [[comment("This filesystem supports metadata checksumming.")]];
    RO_COMPAT_REPLICA         : 1 [[comment("Filesystem supports replicas. This feature is neither in the kernel nor e2fsprogs.")]];
    RO_COMPAT_READONLY        : 1 [[comment("Read-only filesystem image.")]];
    RO_COMPAT_PROJECT         : 1 [[comment("Filesystem tracks project quotas.")]];
    padding                   : 1;
    RO_COMPAT_VERITY          : 1 [[comment("Verity inodes may be present on the filesystem.")]];
    RO_COMPAT_ORPHAN_PRESENT  : 1 [[comment("Indicates orphan file may have valid orphan entries and thus we need to clean them up when mounting the filesystem.")]];
};

enum ext4_super_def_hash : u8 {
    LEGACY               = 0x00,
    HALF_MD4             = 0x01,
    TEA                  = 0x02,
    LEGACY_UNSIGNED      = 0x03,
    HALF_MD4_UNSIGNED    = 0x04,
    TEA_UNSIGNED         = 0x05
};

bitfield ext4_super_mountopts {
    EXT4_DEFM_DEBUG          : 1 [[comment("Print debugging info upon (re)mount.")]];
    EXT4_DEFM_BSDGROUPS      : 1 [[comment("New files take the gid of the containing directory (instead of the fsgid of the current process).")]];
    EXT4_DEFM_XATTR_USER     : 1 [[comment("Support userspace-provided extended attributes.")]];
    EXT4_DEFM_ACL            : 1 [[comment("Support POSIX access control lists (ACLs).")]];
    EXT4_DEFM_UID16          : 1 [[comment("Do not support 32-bit UIDs.")]];
    EXT4_DEFM_JMODE_DATA     : 1 [[comment("All data and metadata are committed to the journal.")]];
    EXT4_DEFM_JMODE_ORDER    : 1 [[comment("All data are flushed to the disk before metadata are committed to the journal.")]];
    padding                  : 1;
    EXT4_DEFM_NOBARRIER      : 1 [[comment("Disable write flushes.")]];
    EXT4_DEFM_BLOCK_VALIDITY : 1 [[comment("Track which blocks in a filesystem are metadata and therefore should not be used as data blocks.")]];
    EXT4_DEFM_DISCARD        : 1 [[comment("Enable DISCARD support, where the storage device is told about blocks becoming unused.")]];
    EXT4_DEFM_NODELALLOC     : 1 [[comment("Disable delayed allocation.")]];
};

bitfield ext4_super_flags {
    SIGNED_HASH_DIRECTORY   : 1;
    UNSIGNED_HASH_DIRECTORY : 1;
    TEST_DEV_CODE           : 1;
};

enum ext4_super_encrypt_algos : u8 {
    ENCRYPTION_MODE_INVALID     = 0x00,
    ENCRYPTION_MODE_AES_256_XTS = 0x01,
    ENCRYPTION_MODE_AES_256_GCM = 0x02,
    ENCRYPTION_MODE_AES_256_CBC = 0x03,
};


struct ext4_super_block {
    u32 s_inodes_count [[comment("Total inode count.")]];
    u32 s_blocks_count_lo [[comment("Total block count.")]];
    u32 s_r_blocks_count_lo [[comment("This number of blocks can only be allocated by the super-user.")]];
    u32 s_free_blocks_count_lo [[comment("Free block count.")]];
    u32 s_free_inodes_count [[comment("Free inode count.")]];
    u32 s_first_data_block [[comment("First data block. This must be at least 1 for 1k-block filesystems and is typically 0 for all other block sizes.")]];
    u32 s_log_block_size;
    u32 s_log_cluster_size;
    u64 block_size = std::math::pow(2, 10+s_log_block_size);
    u64 cluster_size = std::math::pow(2, 10+s_log_cluster_size);
    u32 s_blocks_per_group [[comment("Blocks per group.")]];
    u32 s_clusters_per_group [[comment("Clusters per group, if bigalloc is enabled. Otherwise s_clusters_per_group must equal s_blocks_per_group.")]];
    u32 s_inodes_per_group [[comment("Inodes per group.")]];

    type::time32_t s_mtime [[comment("Last mount time, in seconds since the epoch.")]];
    type::time32_t s_wtime [[comment("Last write time, in seconds since the epoch.")]];
    u16 s_mnt_count [[comment("Number of mounts since the last fsck.")]];
    u16 s_max_mnt_count [[comment("Number of mounts beyond which a fsck is needed.")]];

    type::Magic<"\xEF\x53"> s_magic;

    ext4_super_state s_state [[comment("File system state.")]];
    ext4_super_errors s_errors [[comment("Behaviour when detecting errors.")]];
    u16 s_minor_rev_level [[comment("Minor revision level.")]];
    type::time32_t s_lastcheck [[comment("Time of last check, in seconds since the epoch.")]];
    u32 s_checkinterval [[comment("Maximum time between checks, in seconds.")]];
    ext4_super_creator s_creator_os [[comment("Creator OS.")]];
    ext4_super_revision s_rev_level [[comment("Revision level.")]];

    u16 s_def_resuid [[comment("Default uid for reserved blocks.")]];
    u16 s_def_resgid [[comment("Default gid for reserved blocks.")]];

    // EXT2_DYNAMIC_REV superblock
    if (s_rev_level >= ext4_super_revision::V2_DYNAMIC_REV) {
        u32 s_first_ino [[comment("First non-reserved inode.")]];
        u16 s_inode_size [[comment("Size of inode structure, in bytes.")]];
        u16 s_block_group_nr [[comment("Block group number of this superblock.")]];

        ext4_super_compat s_feature_compat [[comment("Compatible feature set flags. Kernel can still read/write this fs even if it doesn’t understand a flag; fsck should not do that.")]];
        padding[2];
        ext4_super_incompat s_feature_incompat [[comment("Incompatible feature set. If the kernel or fsck doesn’t understand one of these bits, it should stop.")]];
        padding[1];
        ext4_super_compat_ro s_feature_ro_compat [[comment("Readonly-compatible feature set. If the kernel doesn’t understand one of these bits, it can still mount read-only.")]];
        padding[1];

        u8 s_uuid[16] [[comment("128-bit UUID for volume.")]];
        char s_volume_name[16] [[comment("Volume label.")]];
        char s_last_mounted[64] [[comment("Directory where filesystem was last mounted.")]];

        if (s_feature_incompat.INCOMPAT_COMPRESSION) {
            u32 s_algorithm_usage_bitmap;
        } else {
            padding[4];
        }

        // Performance hints
        if (s_feature_compat.COMPAT_DIR_PREALLOC) {
            u8 s_prealloc_blocks [[comment("Number of blocks to try to preallocate for ... files? (Not used in e2fsprogs/Linux).")]];
            u8 s_prealloc_dir_blocks [[comment("Number of blocks to preallocate for directories. (Not used in e2fsprogs/Linux).")]];
        } else {
            padding[2];
        }

        u16 s_reserved_gdt_blocks [[comment("Number of reserved GDT entries for future filesystem expansion.")]];

        // Journaling support
        if (s_feature_compat.COMPAT_HAS_JOURNAL) {
            u8 s_journal_uuid[16] [[comment("UUID of journal superblock.")]];
            u32 s_journal_inum [[comment("Inode number of journal file.")]];
            if (s_feature_incompat.INCOMPAT_JOURNAL_DEV) {
                u32 s_journal_dev [[comment("Device number of journal file.")]];
            } else {
                padding[4];
            }   
        } else {
            padding[24];
        }

        u32 s_last_orphan [[comment("Inode start of list of orphaned inodes to delete.")]];

        u32 s_hash_seed[4] [[comment("HTREE hash seed.")]];
        ext4_super_def_hash s_def_hash_version [[comment("Default hash algorithm to use for directory hashes.")]];

        u8 s_jnl_backup_type [[comment("If this value is 0 or EXT3_JNL_BACKUP_BLOCKS (1), then the s_jnl_blocks field contains a duplicate copy of the inode’s i_block[] array and i_size.")]];

        if (s_feature_incompat.INCOMPAT_64BIT) {
            u16 s_desc_size [[comment("Size of group descriptors, in bytes, if the 64bit incompat feature flag is set.")]];
        } else {
            padding[2];
        }
        ext4_super_mountopts s_default_mount_opts [[comment("Default mount options.")]];
        padding[2];

        if (s_feature_incompat.INCOMPAT_META_BG) {
            u32 s_first_meta_bg [[comment("First metablock block group, if the meta_bg feature is enabled.")]];
        } else {
            padding[4];
        }

        type::time32_t s_mkfs_time [[comment("When the filesystem was created, in seconds since the epoch.")]];

        u32 s_jnl_blocks[17] [[comment("Backup copy of the journal inode’s i_block[] array in the first 15 elements and i_size_high and i_size in the 16th and 17th elements, respectively.")]];

        if (s_feature_incompat.INCOMPAT_64BIT) {
            u32 s_blocks_count_hi [[comment("High 32-bits of the block count.")]];
            u32 s_r_blocks_count_hi [[comment("High 32-bits of the reserved block count.")]];
            u32 s_free_blocks_count_hi [[comment("High 32-bits of the free block count.")]];

            u64 s_blocks_count = u64(s_blocks_count_hi) << 32 + s_blocks_count_lo;
            u64 s_r_blocks_count = u64(s_r_blocks_count_hi) << 32 + s_r_blocks_count_lo;
            u64 s_free_blocks_count = u64(s_free_blocks_count_hi) << 32 + s_free_blocks_count_lo;
            u64 groups_count = std::math::ceil(s_blocks_count/float(s_blocks_per_group));
        } else {
            padding[12];

            u64 s_blocks_count = s_blocks_count_lo;
            u64 s_r_blocks_count = s_r_blocks_count_lo;
            u64 s_free_blocks_count = s_free_blocks_count_lo;
            u64 groups_count = std::math::ceil(s_blocks_count/float(s_blocks_per_group));
        }

        if (s_feature_ro_compat.RO_COMPAT_EXTRA_ISIZE) {
            u16 s_min_extra_isize [[comment("All inodes have at least # bytes.")]];
            u16 s_want_extra_isize [[comment("New inodes should reserve # bytes.")]];
        } else {
            padding[4];
        }

        ext4_super_flags s_flags [[comment("Miscellaneous flags.")]];
        padding[3];

        u16 s_raid_stride [[comment("RAID stride. This is the number of logical blocks read from or written to the disk before moving to the next disk. This affects the placement of filesystem metadata.")]];

        if (s_feature_incompat.INCOMPAT_MMP) {
            u16 s_mmp_interval [[comment("Number of seconds to wait in multi-mount prevention (MMP) checking.")]];
            u64 s_mmp_block [[comment("Block number for multi-mount protection data.")]];
        } else {
            padding[10];
        }
        
        u32 s_raid_stripe_width [[comment("RAID stripe width. This is the number of logical blocks read from or written to the disk before coming back to the current disk.")]];

        if (s_feature_incompat.INCOMPAT_FLEX_BG) {
            u8 s_log_groups_per_flex;
            u64 groups_per_flex = std::math::pow(2, s_log_groups_per_flex);
        } else {
            padding[1];
        }

        if (s_feature_ro_compat.RO_COMPAT_METADATA_CSUM) {
            u8 s_checksum_type [[comment("Metadata checksum algorithm type.")]];
        } else {
            padding[1];
        }
        padding[2];

        u64 s_kbytes_written [[comment("Number of KiB written to this filesystem over its lifetime.")]];

        if (s_feature_ro_compat.RO_COMPAT_HAS_SNAPSHOT) {
            u32 s_snapshot_inum [[comment("inode number of active snapshot. (Not used in e2fsprogs/Linux.)")]];
            u32 s_snapshot_id [[comment("Sequential ID of active snapshot. (Not used in e2fsprogs/Linux.)")]];
            u64 s_snapshot_r_blocks_count [[comment("Number of blocks reserved for active snapshot’s future use. (Not used in e2fsprogs/Linux.)")]];
            u32 s_snapshot_list [[comment("inode number of the head of the on-disk snapshot list. (Not used in e2fsprogs/Linux.)")]];
        } else {
            padding[20];
        }
        
        u32 s_error_count [[comment("Number of errors seen.")]];
        if (s_error_count > 0) {
            type::time32_t s_first_error_time [[comment("First time an error happened.")]];
            u32 s_first_error_ino [[comment("inode involved in first error.")]];
            u64 s_first_error_block [[comment("Number of block involved of first error.")]];
            char s_first_error_func[32] [[comment("Name of function where the error happened.")]];
            u32 s_first_error_line [[comment("Line number where error happened.")]];
            type::time32_t s_last_error_time [[comment("Last time an error happened.")]];
            u32 s_last_error_ino [[comment("inode involved in most recent error.")]];
            u32 s_last_error_line [[comment("Line number where most recent error happened.")]];
            u64 s_last_error_block [[comment("Number of block involved in most recent error.")]];
            char s_last_error_func[32] [[comment("Name of function where the most recent error happened.")]];
        } else {
            padding[104];
        }

        char s_mount_opts[64] [[comment("ASCIIZ string of mount options.")]];

        if (s_feature_ro_compat.RO_COMPAT_QUOTA) {
            u32 s_usr_quota_inum [[comment("Inode number of user quota file.")]];
            u32 s_grp_quota_inum [[comment("Inode number of group quota file.")]];
        } else {
            padding[8];
        }
        
        u32 s_overhead_blocks [[comment("Overhead blocks/clusters in fs. (Huh? This field is always zero, which means that the linux kernel calculates it dynamically.)")]];

        if (s_feature_compat.COMPAT_SPARSE_SUPER2) {
            u32 s_backup_bgs[2] [[comment("Block groups containing superblock backups.")]];
        } else {
            padding[8];
        }

        if (s_feature_incompat.INCOMPAT_ENCRYPT) {
            ext4_super_encrypt_algos s_encrypt_algos[4] [[comment("Encryption algorithms in use. There can be up to four algorithms in use at any time.")]];
            u8 s_encrypt_pw_salt[16] [[comment("Salt for the string2key algorithm for encryption.")]];
        } else {
            padding[20];
        }

        u32 s_lpf_ino [[comment("Inode number of lost+found.")]];

        if (s_feature_ro_compat.RO_COMPAT_PROJECT) {
            u32 s_prj_quota_inum [[comment("Inode that tracks project quotas.")]];
        } else {
            padding[4];
        }

        if (s_feature_ro_compat.RO_COMPAT_METADATA_CSUM) {
            u32 s_checksum_seed [[comment("Checksum seed used for metadata_csum calculations. This value is crc32c(~0, $orig_fs_uuid).")]];
        } else {
            padding[4];
        }

        u8 s_wtime_hi [[comment("Upper 8 bits of the s_wtime field.")]];
        u8 s_mtime_hi [[comment("Upper 8 bits of the s_mtime field.")]];
        u8 s_mkfs_time_hi [[comment("Upper 8 bits of the s_mkfs_time field.")]];
        u8 s_lastcheck_hi [[comment("Upper 8 bits of the s_lastcheck field.")]];
        u8 s_first_error_time_hi [[comment("Upper 8 bits of the s_first_error_time field.")]];
        u8 s_last_error_time_hi [[comment("Upper 8 bits of the s_last_error_time field.")]];

        padding[2];

        u16 s_encoding [[comment("Filename charset encoding.")]];
        u16 s_encoding_flags [[comment("Filename charset encoding flags.")]];

        if (s_feature_compat.RO_COMPAT_ORPHAN_PRESENT) {
            u32 s_orphan_file_inum [[comment("Orphan file inode number.")]];
        } else {
            padding[8];
        }

        padding[376];
        if (s_feature_ro_compat.RO_COMPAT_METADATA_CSUM) {
            u32 s_checksum [[comment("Superblock checksum.")]];
        } else {
            padding[4];
        }
    }
};

ext4_super_block super_block @ 0x400;

fn block_to_address(u32 block) {
    return super_block.block_size * block;
};

fn block_pointer_to_address(u32 block) {
    return block_to_address(block) - block;
};

struct ext4_bitmap {
    u8 data[super_block.block_size];
};

bitfield ext4_i_mode {
    S_IXOTH     : 1 [[comment("Others may execute.")]];
    S_IWOTH     : 1 [[comment("Others may write.")]];
    S_IROTH     : 1 [[comment("Others may read.")]];
    S_IXGRP     : 1 [[comment("Group members may execute.")]];
    S_IWGRP     : 1 [[comment("Group members may write.")]];
    S_IRGRP     : 1 [[comment("Group members may read.")]];
    S_IXUSR     : 1 [[comment("Owner may execute.")]];
    S_IWUSR     : 1 [[comment("Owner may write.")]];
    S_IRUSR     : 1 [[comment("Owner may read.")]];
    S_ISVTX     : 1 [[comment("Sticky bit.")]];
    S_ISGID     : 1 [[comment("Set GID.")]];
    S_ISUID     : 1 [[comment("Set UID.")]];
    S_IFIFO     : 1 [[comment("FIFO.")]];
    S_IFCHR     : 1 [[comment("Character device.")]];
    S_IFDIR     : 1 [[comment("Directory.")]];
    S_IFREG     : 1 [[comment("Regular file.")]];
};

bitfield ext4_i_flags {
    EXT4_SECRM_FL               : 1 [[comment("This file requires secure deletion.")]];
    EXT4_UNRM_FL                : 1 [[comment("This file should be preserved, should undeletion be desired.")]];
    EXT4_COMPR_FL               : 1 [[comment("File is compressed.")]];
    EXT4_SYNC_FL                : 1 [[comment("All writes to the file must be synchronous.")]];
    EXT4_IMMUTABLE_FL           : 1 [[comment("File is immutable.")]];
    EXT4_APPEND_FL              : 1 [[comment("File can only be appended.")]];
    EXT4_NODUMP_FL              : 1 [[comment("The dump utility should not dump this file.")]];
    EXT4_NOATIME_FL             : 1 [[comment("Do not update access time.")]];
    EXT4_DIRTY_FL               : 1 [[comment("Dirty compressed file.")]];
    EXT4_COMPRBLK_FL            : 1 [[comment("File has one or more compressed clusters.")]];
    EXT4_NOCOMPR_FL             : 1 [[comment("Do not compress file.")]];
    EXT4_ENCRYPT_FL             : 1 [[comment("Encrypted inode.")]];
    EXT4_INDEX_FL               : 1 [[comment("Directory has hashed indexes.")]];
    EXT4_IMAGIC_FL              : 1 [[comment("AFS magic directory.")]];
    EXT4_JOURNAL_DATA_FL        : 1 [[comment("File data must always be written through the journal.")]];
    EXT4_NOTAIL_FL              : 1 [[comment("File tail should not be merged.")]];
    EXT4_DIRSYNC_FL             : 1 [[comment("All directory entry data should be written synchronously.")]];
    EXT4_TOPDIR_FL              : 1 [[comment("Top of directory hierarchy.")]];
    EXT4_HUGE_FILE_FL           : 1 [[comment("This is a huge file.")]];
    EXT4_EXTENTS_FL             : 1 [[comment("Inode uses extents.")]];
    EXT4_VERITY_FL              : 1 [[comment("Verity protected file.")]];
    EXT4_EA_INODE_FL            : 1 [[comment("Inode stores a large extended attribute value in its data blocks.")]];
    EXT4_EOFBLOCKS_FL           : 1 [[comment("This file has blocks allocated past EOF.")]];
    padding                     : 1;
    EXT4_SNAPFILE_FL            : 1 [[comment("Inode is a snapshot.")]];
    padding                     : 1;
    EXT4_SNAPFILE_DELETED_FL    : 1 [[comment("Snapshot is being deleted.")]];
    EXT4_SNAPFILE_SHRUNK_FL     : 1 [[comment("Snapshot shrink has completed.")]];
    EXT4_INLINE_DATA_FL         : 1 [[comment("Inode has inline data.")]];
    EXT4_PROJINHERIT_FL         : 1 [[comment("Create children with the same project ID.")]];
    padding                     : 1;
    EXT4_RESERVED_FL            : 1 [[comment("Reserved for ext4 library.")]];
};

struct ext4_inode {
    ext4_i_mode i_mode [[comment("File mode.")]];
    u16 i_uid [[comment("Lower 16-bits of Owner UID.")]];
    u32 i_size [[comment("Lower 32-bits of size in bytes.")]];
    type::time32_t i_atime [[comment("Last access time.")]];
    type::time32_t i_ctime [[comment("Last inode change time.")]];
    type::time32_t i_mtime [[comment("Last data modification time.")]];
    type::time32_t i_dtime [[comment("Deletion Time.")]];
    u16 i_gid [[comment("Lower 16-bits of GID.")]];
    u16 i_links_count [[comment("Hard link count.")]];
    u32 i_blocks_lo [[comment("Lower 32-bits of “block” count.")]];
    ext4_i_flags i_flags [[comment("Inode flags.")]];
    u32 i_osd1 [[comment("Depends of the OS.")]];
    u32 i_block[15] [[comment("Block map or extent tree.")]];
    u32 i_generation [[comment("File version (for NFS).")]];
    u32 i_file_acl [[comment("Lower 32-bits of extended attribute block.")]];
    u32 i_dir_acl [[comment("Upper 32-bits of file/directory size.")]];
    u32 i_faddr [[comment("Fragment address.")]];
    u8 i_osd2[12] [[comment("Depends of the OS.")]];
    if (super_block.s_rev_level >= ext4_super_revision::V2_DYNAMIC_REV && super_block.s_inode_size > 0x80) {
        u16 i_extra_isize [[comment("Size of this inode - 128.")]];
        u16 i_checksum_hi [[comment("Upper 16-bits of the inode checksum.")]];
            if (super_block.s_inode_size > 0x84) {
                u32 i_ctime_extra [[comment("Extra change time bits.")]];
                u32 i_mtime_extra [[comment("Extra modification time bits.")]];
                u32 i_atime_extra [[comment("Extra access time bits.")]];
                u32 i_crtime [[comment("File creation time.")]];
                u32 i_crtime_extra [[comment("Extra file creation time bits.")]];
                if (super_block.s_inode_size > 0x98) {
                    u32 i_version_hi [[comment("Upper 32-bits for version number.")]];
                    if (super_block.s_inode_size > 0x9C) {
                        u32 i_projid [[comment("Project ID.")]];
                        if (super_block.s_inode_size > 0xA0) {
                            padding[super_block.s_inode_size - 0xA0];
                        }
                    }
                }
            }
    }
};

bitfield ext4_bg_flags {
    EXT4_BG_INODE_UNINIT   : 1 [[comment("Inode table and bitmap are not initialized.")]];
    EXT4_BG_BLOCK_UNINIT   : 1 [[comment("Block bitmap is not initialized.")]];
    EXT4_BG_INODE_ZEROED   : 1 [[comment("Inode table is zeroed.")]];
};

struct ext4_group_desc {
    ext4_bitmap *bg_block_bitmap : u32 [[pointer_base("block_pointer_to_address"), comment("Lower 32-bits of location of block bitmap.")]];
    ext4_bitmap *bg_inode_bitmap : u32 [[pointer_base("block_pointer_to_address"), comment("Lower 32-bits of location of inode bitmap.")]];
    ext4_inode *bg_inode_table[super_block.s_inodes_per_group] : u32 [[pointer_base("block_pointer_to_address"), comment("Lower 32-bits of location of inode table.")]];
    u16 bg_free_blocks_count [[comment("Lower 16-bits of free block count.")]];
    u16 bg_free_inodes_count [[comment("Lower 16-bits of free inode count.")]];
    u16 bg_used_dirs_count [[comment("Lower 16-bits of directory count.")]];
    ext4_bg_flags bg_flags [[comment("Block group flags.")]];
    padding[1];
    u32 bg_exclude_bitmap_lo [[comment("Lower 32-bits of location of snapshot exclusion bitmap.")]];
    u16 bg_block_bitmap_csum_lo [[comment("Lower 16-bits of the block bitmap checksum.")]];
    u16 bg_inode_bitmap_csum_lo [[comment("Lower 16-bits of the inode bitmap checksum.")]];
    u16 bg_itable_unused_lo [[comment("Lower 16-bits of unused inode count.")]];
    u16 bg_checksum [[comment("Group descriptor checksum.")]];

};

struct ext4_group_desc_64_bit : ext4_group_desc {
    u32 bg_block_bitmap_hi [[comment("Upper 32-bits of location of block bitmap.")]];
    u32 bg_inode_bitmap_hi [[comment("Upper 32-bits of location of inodes bitmap.")]];
    u32 bg_inode_table_hi [[comment("Upper 32-bits of location of inodes table.")]];
    u16 bg_free_blocks_count_hi [[comment("Upper 16-bits of free block count.")]];
    u16 bg_free_inodes_count_hi [[comment("Upper 16-bits of free inode count.")]];
    u16 bg_used_dirs_count_hi [[comment("Upper 16-bits of directory count.")]];
    u16 bg_itable_unused_hi [[comment("Upper 16-bits of unused inode count.")]];
    u32 bg_exclude_bitmap_hi [[comment("Upper 32-bits of location of snapshot exclusion bitmap.")]];
    u16 bg_block_bitmap_csum_hi [[comment("Upper 16-bits of the block bitmap checksum.")]];
    u16 bg_inode_bitmap_csum_hi [[comment("Upper 16-bits of the inode bitmap checksum.")]];
    padding[4];
};

struct ext4_group_descriptors {
    if (super_block.s_rev_level >= ext4_super_revision::V2_DYNAMIC_REV && super_block.s_feature_incompat.INCOMPAT_64BIT) {
        ext4_group_desc_64_bit group_desc[super_block.groups_count];
    } else {
        ext4_group_desc group_desc[super_block.groups_count];
    }
};

ext4_group_descriptors group_descs @ block_to_address(2);