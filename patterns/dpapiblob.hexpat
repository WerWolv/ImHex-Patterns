#pragma description "DPAPI Blob"

import type.guid;
import std.mem;

enum ALG_ID : u32 {
    CALG_DH_EPHEM = 0x0000aa02,        
    CALG_DH_SF = 0x0000aa01,           
    CALG_DSS_SIGN = 0x00002200,        
    CALG_ECDH = 0x0000aa05,            
    CALG_ECDH_EPHEM = 0x0000ae06,      
    CALG_ECDSA = 0x00002203,           
    CALG_ECMQV = 0x0000a001,           
    CALG_HASH_REPLACE_OWF = 0x0000800b, 
    CALG_HUGHES_MD5 = 0x0000a003,      
    CALG_HMAC = 0x00008009,            
    CALG_KEA_KEYX = 0x0000aa04,        
    CALG_MAC = 0x00008005,             
    CALG_MD2 = 0x00008001,             
    CALG_MD4 = 0x00008002,             
    CALG_MD5 = 0x00008003,             
    CALG_NO_SIGN = 0x00002000,         
    CALG_OID_INFO_CNG_ONLY = 0xffffffff, 
    CALG_OID_INFO_PARAMETERS = 0xfffffffe, 
    CALG_PCT1_MASTER = 0x00004c04,     
    CALG_RC2 = 0x00006602,             
    CALG_RC4 = 0x00006801,             
    CALG_RC5 = 0x0000660d,             
    CALG_RSA_KEYX = 0x0000a400,        
    CALG_RSA_SIGN = 0x00002400,        
    CALG_SCHANNEL_ENC_KEY = 0x00004c07, 
    CALG_SCHANNEL_MAC_KEY = 0x00004c03, 
    CALG_SCHANNEL_MASTER_HASH = 0x00004c02, 
    CALG_SEAL = 0x00006802,            
    CALG_SHA = 0x00008004,             
    CALG_SHA1 = 0x00008004,            
    CALG_SHA_256 = 0x0000800c,         
    CALG_SHA_384 = 0x0000800d,         
    CALG_SHA_512 = 0x0000800e,         
    CALG_SKIPJACK = 0x0000660a,        
    CALG_SSL2_MASTER = 0x00004c05,     
    CALG_SSL3_MASTER = 0x00004c01,     
    CALG_SSL3_SHAMD5 = 0x00008008,     
    CALG_TEK = 0x0000660b,             
    CALG_TLS1_MASTER = 0x00004c06,     
    CALG_TLS1PRF = 0x0000800a          
};

struct DPAPI_BLOB{
    u32 version[[name("Version")]];
    type::GUID providerguid[[name("ProviderGUID")]];
    u32 masterguid[[name("MasterKeyVersion")]];
    type::GUID guid[[name("MasterKeyGUID")]];
    u32 flags[[name("Flags")]];
    u32 desclen [[name("DescriptionLen")]];
    char16 desc[desclen / 0x02 ] [[name("Description")]];
    ALG_ID cryptid [[name("AlgCryptId")]];
    u32 algcryptlen[[name("AlgCryptLen")]];
    u32 saltlen [[name("SaltLen")]];
    char salt[saltlen][[name("Salt")]];
    u32 hmackeylen[[name("HMACKeyLen")]];
    char hmackey[hmackeylen][[name("HMACKey")]];
    ALG_ID algid[[name("AlgHashId")]];
    u32 alghashkeylen[[name("AlgHashKeyLen")]];
    u32 hmac2keylen[[name("HMAC2keylen")]];
    char hmac2[hmac2keylen][[name("HMAC2Key")]];
    u32 datalen[[name("DataLen")]];
    char data[datalen][[name("Data")]];
    u32 signlen[[name("signlen")]];
    char signhash[signlen][[name("SignHash")]];
};

DPAPI_BLOB dpapiblob @0x00 [[name("DPAPIBlob")]];