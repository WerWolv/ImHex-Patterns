#pragma description Android VBMeta image

#pragma endian big
#include <std/core.pat>

using uint8_t = u8;
using uint32_t = u32;
using uint64_t = u64;

#define AVB_MAGIC_LEN 4
#define AVB_RELEASE_STRING_SIZE 48

enum AvbAlgorithmType : uint32_t {
  AVB_ALGORITHM_TYPE_NONE,
  AVB_ALGORITHM_TYPE_SHA256_RSA2048,
  AVB_ALGORITHM_TYPE_SHA256_RSA4096,
  AVB_ALGORITHM_TYPE_SHA256_RSA8192,
  AVB_ALGORITHM_TYPE_SHA512_RSA2048,
  AVB_ALGORITHM_TYPE_SHA512_RSA4096,
  AVB_ALGORITHM_TYPE_SHA512_RSA8192,
  _AVB_ALGORITHM_NUM_TYPES
};

struct AvbVBMetaImageHeader {
  /*   0: Four bytes equal to "AVB0" (AVB_MAGIC). */
  char magic[AVB_MAGIC_LEN];
  /*   4: The major version of libavb required for this header. */
  uint32_t required_libavb_version_major;
  /*   8: The minor version of libavb required for this header. */
  uint32_t required_libavb_version_minor;
  /*  12: The size of the signature block. */
  uint64_t authentication_data_block_size;
  /*  20: The size of the auxiliary data block. */
  uint64_t auxiliary_data_block_size;
  /*  28: The verification algorithm used, see |AvbAlgorithmType| enum. */
  AvbAlgorithmType algorithm_type;
  /*  32: Offset into the "Authentication data" block of hash data. */
  uint64_t hash_offset;
  /*  40: Length of the hash data. */
  uint64_t hash_size;
  /*  48: Offset into the "Authentication data" block of signature data. */
  uint64_t signature_offset;
  /*  56: Length of the signature data. */
  uint64_t signature_size;
  /*  64: Offset into the "Auxiliary data" block of public key data. */
  uint64_t public_key_offset;
  /*  72: Length of the public key data. */
  uint64_t public_key_size;
  /*  80: Offset into the "Auxiliary data" block of public key metadata. */
  uint64_t public_key_metadata_offset;
  /*  88: Length of the public key metadata. Must be set to zero if there
   *  is no public key metadata.
   */
  uint64_t public_key_metadata_size;
  /*  96: Offset into the "Auxiliary data" block of descriptor data. */
  uint64_t descriptors_offset;
  /* 104: Length of descriptor data. */
  uint64_t descriptors_size;
  /* 112: The rollback index which can be used to prevent rollback to
   *  older versions.
   */
  uint64_t rollback_index;
  /* 120: Flags from the AvbVBMetaImageFlags enumeration. This must be
   * set to zero if the vbmeta image is not a top-level image.
   */
  uint32_t flags;
  /* 124: The location of the rollback index defined in this header.
   * Only valid for the main vbmeta. For chained partitions, the rollback
   * index location must be specified in the AvbChainPartitionDescriptor
   * and this value must be set to 0.
   */
  uint32_t rollback_index_location;
  /* 128: The release string from avbtool, e.g. "avbtool 1.0.0" or
   * "avbtool 1.0.0 xyz_board Git-234abde89". Is guaranteed to be NUL
   * terminated. Applications must not make assumptions about how this
   * string is formatted.
   */
  char release_string[AVB_RELEASE_STRING_SIZE];
  /* 176: Padding to ensure struct is size AVB_VBMETA_IMAGE_HEADER_SIZE
   * bytes. This must be set to zeroes.
   */
  padding[80];
};

enum AvbDescriptorTag : uint64_t {
  AVB_DESCRIPTOR_TAG_PROPERTY,
  AVB_DESCRIPTOR_TAG_HASHTREE,
  AVB_DESCRIPTOR_TAG_HASH,
  AVB_DESCRIPTOR_TAG_KERNEL_CMDLINE,
  AVB_DESCRIPTOR_TAG_CHAIN_PARTITION,
};

struct AvbPropertyDescriptor {
  uint64_t key_num_bytes;
  uint64_t value_num_bytes;
  char key[key_num_bytes];
  padding[1];
  char value[value_num_bytes];
  padding[1];
} [[inline]];

bitfield AvbHashtreeDescriptorFlags {
    AVB_HASHTREE_DESCRIPTOR_FLAGS_DO_NOT_USE_AB      : 1;
    AVB_HASHTREE_DESCRIPTOR_FLAGS_CHECK_AT_MOST_ONCE : 1;
} [[bitfield_order(std::core::BitfieldOrder::LeastToMostSignificant, 32)]];

struct AvbHashtreeDescriptor {
  uint32_t dm_verity_version;
  uint64_t image_size;
  uint64_t tree_offset;
  uint64_t tree_size;
  uint32_t data_block_size;
  uint32_t hash_block_size;
  uint32_t fec_num_roots;
  uint64_t fec_offset;
  uint64_t fec_size;
  char hash_algorithm[32];
  uint32_t partition_name_len;
  uint32_t salt_len;
  uint32_t root_digest_len;
  AvbHashtreeDescriptorFlags flags;
  padding[60]; // reserved
  char partition_name[partition_name_len];
  u8 salt[salt_len];
  u8 root_digest[root_digest_len];
} [[inline]];

struct AvbHashDescriptor {
  uint64_t image_size;
  char hash_algorithm[32];
  uint32_t partition_name_len;
  uint32_t salt_len;
  uint32_t digest_len;
  uint32_t flags;
  padding[60]; // reserved
  char partition_name[partition_name_len];
  u8 salt[salt_len];
  u8 digest[digest_len];
} [[inline]];

struct AvbKernelCmdlineDescriptor {
  uint32_t flags;
  uint32_t kernel_cmdline_length;
  char kernel_cmdline[kernel_cmdline_length];
} [[inline]];

struct AvbChainPartitionDescriptor {
  uint32_t rollback_index_location;
  uint32_t partition_name_len;
  uint32_t public_key_len;
  padding[64]; // reserved
  char partition_name[partition_name_len];
  u8 public_key[public_key_len];
} [[inline]];

struct AvbDescriptor<auto end> {
  AvbDescriptorTag tag;
  uint64_t num_bytes_following;
  u8 data[num_bytes_following] [[hidden]];
  
  match (tag) {
    (AvbDescriptorTag::AVB_DESCRIPTOR_TAG_PROPERTY)       : AvbPropertyDescriptor descriptor @ addressof(data);
    (AvbDescriptorTag::AVB_DESCRIPTOR_TAG_HASHTREE)       : AvbHashtreeDescriptor descriptor @ addressof(data);
    (AvbDescriptorTag::AVB_DESCRIPTOR_TAG_HASH)           : AvbHashDescriptor descriptor @ addressof(data);
    (AvbDescriptorTag::AVB_DESCRIPTOR_TAG_KERNEL_CMDLINE) : AvbKernelCmdlineDescriptor descriptor @ addressof(data);
    (AvbDescriptorTag::AVB_DESCRIPTOR_TAG_CHAIN_PARTITION): AvbChainPartitionDescriptor descriptor @ addressof(data);
  }

  if ($ >= end)
    break;
};

struct AuthenticationData<auto authentication_data_block_size,
                          auto hash_offset, auto hash_size,
                          auto signature_offset, auto signature_size>
{
  u8 authentication_data_block[authentication_data_block_size] [[hidden]];

  u8 hash[hash_size] @ addressof(authentication_data_block) + hash_offset;
  u8 signature[signature_size] @ addressof(authentication_data_block) + signature_offset;
};

struct AuxiliaryData<auto auxiliary_data_block_size,
                     auto public_key_offset, auto public_key_size,
                     auto public_key_metadata_offset, auto public_key_metadata_size,
                     auto descriptors_offset, auto descriptors_size>
{
  u8 auxiliary_data_block[auxiliary_data_block_size] [[hidden]];

  u8 public_key[public_key_size] @ addressof(auxiliary_data_block) + public_key_offset;
  u8 public_key_metadata[public_key_metadata_size] @ addressof(auxiliary_data_block) + public_key_metadata_offset;

  if (descriptors_size > 0) {
    u8 descriptors_block[descriptors_size] @ addressof(auxiliary_data_block) + descriptors_offset [[hidden]];
    AvbDescriptor<addressof(descriptors_block) + descriptors_size> descriptors[200] @ addressof(descriptors_block);
  }
};

struct AvbVBMetaImage
{
  AvbVBMetaImageHeader header;

  AuthenticationData<header.authentication_data_block_size,
                     header.hash_offset, header.hash_size,
                     header.signature_offset, header.signature_size>
    authentication_data;
  
  AuxiliaryData<header.auxiliary_data_block_size,
                header.public_key_offset, header.public_key_size,
                header.public_key_metadata_offset, header.public_key_metadata_size,
                header.descriptors_offset, header.descriptors_size>
    auxiliary_data;
};

AvbVBMetaImage image @ 0;
