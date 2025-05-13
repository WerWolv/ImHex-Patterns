import type.magic;
import type.size;
import type.guid;
import std.mem;

import * from elf as ELF;

enum shdr_img_type : u32 {
    SHDR_TA = 0,
    SHDR_BOOTSTRAP_TA = 1,
    SHDR_ENCRYPTED_TA = 2,
    SHDR_SUBKEY = 3
};

enum tee_algorithm : u32 {
    TEE_ALG_AES_ECB_NOPAD                   = 0x10000010,
    TEE_ALG_AES_CBC_NOPAD                   = 0x10000110,
    TEE_ALG_AES_CTR                         = 0x10000210,
    TEE_ALG_AES_CTS                         = 0x10000310,
    TEE_ALG_AES_XTS                         = 0x10000410,
    TEE_ALG_AES_CBC_MAC_NOPAD               = 0x30000110,
    TEE_ALG_AES_CBC_MAC_PKCS5               = 0x30000510,
    TEE_ALG_AES_CMAC                        = 0x30000610,
    TEE_ALG_AES_CCM                         = 0x40000710,
    TEE_ALG_AES_GCM                         = 0x40000810,
    TEE_ALG_DES_ECB_NOPAD                   = 0x10000011,
    TEE_ALG_DES_CBC_NOPAD                   = 0x10000111,
    TEE_ALG_DES_CBC_MAC_NOPAD               = 0x30000111,
    TEE_ALG_DES_CBC_MAC_PKCS5               = 0x30000511,
    TEE_ALG_DES3_ECB_NOPAD                  = 0x10000013,
    TEE_ALG_DES3_CBC_NOPAD                  = 0x10000113,
    TEE_ALG_DES3_CBC_MAC_NOPAD              = 0x30000113,
    TEE_ALG_DES3_CBC_MAC_PKCS5              = 0x30000513,
    TEE_ALG_SM4_ECB_NOPAD                   = 0x10000014,
    TEE_ALG_SM4_CBC_NOPAD                   = 0x10000114,
    TEE_ALG_SM4_CTR                         = 0x10000214,
    TEE_ALG_RSASSA_PKCS1_V1_5_MD5           = 0x70001830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA1          = 0x70002830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA224        = 0x70003830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA256        = 0x70004830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA384        = 0x70005830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA512        = 0x70006830,
    TEE_ALG_RSASSA_PKCS1_V1_5_MD5SHA1       = 0x7000F830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA3_224      = 0x70008830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA3_256      = 0x70009830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA3_384      = 0x7000A830,
    TEE_ALG_RSASSA_PKCS1_V1_5_SHA3_512      = 0x7000B830,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA1      = 0x70212930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA224    = 0x70313930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA256    = 0x70414930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA384    = 0x70515930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA512    = 0x70616930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA3_224  = 0x70818930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA3_256  = 0x70919930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA3_384  = 0x70A1A930,
    TEE_ALG_RSASSA_PKCS1_PSS_MGF1_SHA3_512  = 0x70B1B930,
    TEE_ALG_RSAES_PKCS1_V1_5                = 0x60000130,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA1      = 0x60210230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA224    = 0x60310230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA256    = 0x60410230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA384    = 0x60510230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA512    = 0x60610230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA3_224  = 0x60810230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA3_256  = 0x60910230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA3_384  = 0x60A10230,
    TEE_ALG_RSAES_PKCS1_OAEP_MGF1_SHA3_512  = 0x60B10230,
    TEE_ALG_RSA_NOPAD                       = 0x60000030,
    TEE_ALG_DSA_SHA1                        = 0x70002131,
    TEE_ALG_DSA_SHA224                      = 0x70003131,
    TEE_ALG_DSA_SHA256                      = 0x70004131,
    TEE_ALG_DSA_SHA3_224                    = 0x70008131,
    TEE_ALG_DSA_SHA3_256                    = 0x70009131,
    TEE_ALG_DSA_SHA3_384                    = 0x7000A131,
    TEE_ALG_DSA_SHA3_512                    = 0x7000B131,
    TEE_ALG_SM2_DSA_SM3                     = 0x70006045,
    TEE_ALG_DH_DERIVE_SHARED_SECRET         = 0x80000032,
    TEE_ALG_SM2_KEP                         = 0x60000045,
    TEE_ALG_MD5                             = 0x50000001,
    TEE_ALG_SHA1                            = 0x50000002,
    TEE_ALG_SHA224                          = 0x50000003,
    TEE_ALG_SHA256                          = 0x50000004,
    TEE_ALG_SHA384                          = 0x50000005,
    TEE_ALG_SHA512                          = 0x50000006,
    TEE_ALG_SHA3_224                        = 0x50000008,
    TEE_ALG_SHA3_256                        = 0x50000009,
    TEE_ALG_SHA3_384                        = 0x5000000A,
    TEE_ALG_SHA3_512                        = 0x5000000B,
    TEE_ALG_MD5SHA1                         = 0x5000000F,
    TEE_ALG_HMAC_MD5                        = 0x30000001,
    TEE_ALG_HMAC_SHA1                       = 0x30000002,
    TEE_ALG_HMAC_SHA224                     = 0x30000003,
    TEE_ALG_HMAC_SHA256                     = 0x30000004,
    TEE_ALG_HMAC_SHA384                     = 0x30000005,
    TEE_ALG_HMAC_SHA512                     = 0x30000006,
    TEE_ALG_HMAC_SM3                        = 0x30000007,
    TEE_ALG_HMAC_SHA3_224                   = 0x30000008,
    TEE_ALG_HMAC_SHA3_256                   = 0x30000009,
    TEE_ALG_HMAC_SHA3_384                   = 0x3000000A,
    TEE_ALG_HMAC_SHA3_512                   = 0x3000000B,
    
    /*
     * These are used in the OP-TEE ABI, due to an inconsistency in the v1.1
     * specification the wrong values we assumed and now we're stuck with those.
     *
     * In GP Internal Core API v1.1
     *     "Table 6-12:  Structure of Algorithm Identifier"
     *     indicates ECDSA have the algorithm "0x41" and ECDH "0x42"
     * whereas
     *     "Table 6-11:  List of Algorithm Identifiers" defines
     *     TEE_ALG_ECDSA_P192 as 0x70001042
     *
     * We chose to define __OPTEE_TEE_ALG_ECDSA_P192 as 0x70001041 and so on
     * to conform to table 6-12.
     */
    __OPTEE_ALG_ECDSA_P192                  = 0x70001041,
    __OPTEE_ALG_ECDSA_P224                  = 0x70002041,
    __OPTEE_ALG_ECDSA_P256                  = 0x70003041,
    __OPTEE_ALG_ECDSA_P384                  = 0x70004041,
    __OPTEE_ALG_ECDSA_P521                  = 0x70005041,
    __OPTEE_ALG_ECDH_P192                   = 0x80001042,
    __OPTEE_ALG_ECDH_P224                   = 0x80002042,
    __OPTEE_ALG_ECDH_P256                   = 0x80003042,
    __OPTEE_ALG_ECDH_P384                   = 0x80004042,
    __OPTEE_ALG_ECDH_P521                   = 0x80005042,
    
    /* TEE_ALG_ECDSA_P* and TEE_ALG_ECDH_P* are deprecated */
    TEE_ALG_ECDSA_P192                      = tee_algorithm::TEE_ALG_ECDSA_SHA1,
    TEE_ALG_ECDSA_P224                      = tee_algorithm::TEE_ALG_ECDSA_SHA224,
    TEE_ALG_ECDSA_P256                      = tee_algorithm::TEE_ALG_ECDSA_SHA256,
    TEE_ALG_ECDSA_P384                      = tee_algorithm::TEE_ALG_ECDSA_SHA384,
    TEE_ALG_ECDSA_P521                      = tee_algorithm::TEE_ALG_ECDSA_SHA512,
    TEE_ALG_ECDH_P192                       = tee_algorithm::TEE_ALG_ECDH_DERIVE_SHARED_SECRET,
    TEE_ALG_ECDH_P224                       = tee_algorithm::TEE_ALG_ECDH_DERIVE_SHARED_SECRET,
    TEE_ALG_ECDH_P256                       = tee_algorithm::TEE_ALG_ECDH_DERIVE_SHARED_SECRET,
    TEE_ALG_ECDH_P384                       = tee_algorithm::TEE_ALG_ECDH_DERIVE_SHARED_SECRET,
    TEE_ALG_ECDH_P521                       = tee_algorithm::TEE_ALG_ECDH_DERIVE_SHARED_SECRET,
    
    TEE_ALG_ECDH_DERIVE_SHARED_SECRET       = 0x80000042,
    TEE_ALG_ECDSA_SHA1                      = 0x70001042,
    TEE_ALG_ECDSA_SHA224                    = 0x70002042,
    TEE_ALG_ECDSA_SHA256                    = 0x70003042,
    TEE_ALG_ECDSA_SHA384                    = 0x70004042,
    TEE_ALG_ECDSA_SHA512                    = 0x70005042,
    TEE_ALG_ECDSA_SHA3_224                  = 0x70006042,
    TEE_ALG_ECDSA_SHA3_256                  = 0x70007042,
    TEE_ALG_ECDSA_SHA3_384                  = 0x70008042,
    TEE_ALG_ECDSA_SHA3_512                  = 0x70009042,
    
    TEE_ALG_ED25519                         = 0x70006043,
    TEE_ALG_ED448                           = 0x70006044,
    TEE_ALG_SM2_PKE                         = 0x80000046,
    TEE_ALG_HKDF                            = 0x80000047,
    TEE_ALG_SM3                             = 0x50000007,
    TEE_ALG_X25519                          = 0x80000044,
    TEE_ALG_X448                            = 0x80000045,
    TEE_ALG_SM4_ECB_PKCS5                   = 0x10000015,
    TEE_ALG_SM4_CBC_PKCS5                   = 0x10000115,
    TEE_ALG_ILLEGAL_VALUE                   = 0xEFFFFFFF,
    
    TEE_ALG_SHA3_224                        = 0x50000008,
    TEE_ALG_SHA3_256                        = 0x50000009,
    TEE_ALG_SHA3_384                        = 0x5000000A,
    TEE_ALG_SHA3_512                        = 0x5000000B,
    TEE_ALG_SHAKE128                        = 0x50000101,
    TEE_ALG_SHAKE256                        = 0x50000102
};

struct shdr {
    type::Magic<"HSTO"> magic;
    shdr_img_type img_type;
    type::Size<u32> img_size;
    tee_algorithm algo;
    type::Size<u16> hash_size;
    type::Size<u16> sig_size;
    
    std::mem::Bytes<hash_size> hash;
    std::mem::Bytes<sig_size> sig;
};

struct shdr_bootstrap_ta {
    be type::GUID uuid;
    u32 ta_version;
};

enum shdr_enc_key_type : u32 {
    SHDR_ENC_KEY_DEV_SPECIFIC = 0,
    SHDR_ENC_KEY_CLASS_WIDE = 1,
};

struct shdr_encrypted_ta {
    tee_algorithm enc_algo;
    shdr_enc_key_type flags;
    type::Size<u16> iv_size;
    type::Size<u16> tag_size;
    
    std::mem::Bytes<iv_size> iv;
    std::mem::Bytes<tag_size> tag;
};

struct OPTEE_TrustedApplication {
    shdr shdr;
    match (shdr.img_type) {
        (shdr_img_type::SHDR_BOOTSTRAP_TA): {
            shdr_bootstrap_ta bootstrap_ta_subheader;
        }
        (shdr_img_type::SHDR_ENCRYPTED_TA): {
            shdr_bootstrap_ta bootstrap_ta_subheader;
            shdr_encrypted_ta encrypted_ta_subheader;
        }
    }
    
    if (shdr.img_type == shdr_img_type::SHDR_ENCRYPTED_TA) {
        std::mem::Bytes<std::mem::size() - $> encrypted_data;
    } else {
        ELF elf;
    }
};

OPTEE_TrustedApplication trusted_application @ 0x00;