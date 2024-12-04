#pragma description "DPAPIMasterKey"

/*
        FilePath: C:\Users\<USER>\AppData\Roaming\Microsoft\Protect\<SID>
        This files are hidden.
        To unhide it,
        1. Open Command Prompt (cmd.exe).
        2. Run the following command:
        - attrib -h -s

*/

import type.guid;

// https://learn.microsoft.com/en-us/windows/win32/seccrypto/alg-id
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


struct CREDHIST_MASTERKEY {
    u32 version[[name("Version")]];
    type::GUID guid[[name("GUID")]];
    
};

struct DOMAINKEY_MASTERKEY {
    u32 version[[name("Version")]];
    u32 seclen[[name("SecretLen")]];
    u32 accesschklen[[name("AccessCheckLen")]];
    type::GUID backupguid_[[name("BackupKeyGUID")]];
    char blob[seclen][[name("Secret")]];
    char accesschk[accesschklen][[name("AccessCheck")]];

};  

struct BACKUP_MASTERKEY {
    u32 start = $;
    u32 version[[name("Version")]];
    char salt[16][[name("Salt")]];
    u32 rounds [[name("PBKDF2IterationCount")]];
    ALG_ID alghashid[[name("HMACAlgId")]];
    ALG_ID algcryptid[[name("CryptAlgId")]];
    u32 meta = $ - start;
    char key[parent.backupkeylen - meta][[name("Key")]];
};

struct PASSWORD_MASTERKEY {
    u32 start = $;
    u32 version[[name("Version")]];
    char salt[16][[name("Salt")]];
    u32 rounds [[name("PBKDF2IterationCount")]];
    ALG_ID alghashid[[name("HMACAlgId")]];
    ALG_ID algcryptid[[name("CryptAlgId")]];
    u32 meta = $ - start;
    char key[parent.masterkeylen - meta][[name("Key")]];
};

struct DPAPIMasterKey {
    u32 version[[name("Version")]];
    u32 unk1[[name("Unknown1")]];
    u32 unk2[[name("Unknown2")]];
    char16 guid[0x24][[name("GUID"), comment("This GUID is the fileName itself")]];
    u32 unk3[[name("Unknown3")]];
    u32 unk4[[name("Unknown4")]];
    u32 policy[[name("Policy")]];
    u64 masterkeylen [[name("MasterKeyLen")]];
    u64 backupkeylen [[name("BackupKeyLen")]];
    u64 credhistlen [[name("CredHistoryLen")]];
    u64 domainkeylen [[name("DomainKeyLen")]];
    if (masterkeylen > 0){
        PASSWORD_MASTERKEY  masterkey[[name("MasterKey")]];
    }
    if (backupkeylen > 0){
        BACKUP_MASTERKEY    backupkey[[name("BackupKey")]];
    }
    if (credhistlen > 0){
        CREDHIST_MASTERKEY  credhistkey[[name("CredHistoryKey")]];
    }
    if (domainkeylen > 0){
        DOMAINKEY_MASTERKEY domainkey[[name("DomainKey")]];
    }
};

DPAPIMasterKey masterkey  @0x00[[name("DPAPIMasterKey")]];