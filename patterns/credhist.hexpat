#pragma description "CREDHIST"

/*
        FilePath: C:\Users\<USER>\AppData\Roaming\Microsoft\Protect\
        The files/folders are hidden.

        To unhide it
        1. Open Command Prompt (cmd.exe).
        2. Run the following command:
            => attrib -h -s

*/

import type.guid;
import std.mem;

// https://learn.microsoft.com/en-us/windows/win32/seccrypto/alg-id
enum ALG_ID : u32 {
    CALG_DH_EPHEM = 0x0000aa02,        // Diffie-Hellman ephemeral key exchange algorithm.
    CALG_DH_SF = 0x0000aa01,           // Diffie-Hellman store and forward key exchange algorithm.
    CALG_DSS_SIGN = 0x00002200,        // DSA public key signature algorithm.
    CALG_ECDH = 0x0000aa05,            // Elliptic curve Diffie-Hellman key exchange algorithm.
    CALG_ECDH_EPHEM = 0x0000ae06,      // Ephemeral elliptic curve Diffie-Hellman key exchange algorithm.
    CALG_ECDSA = 0x00002203,           // Elliptic curve digital signature algorithm.
    CALG_ECMQV = 0x0000a001,           // Elliptic curve Menezes, Qu, and Vanstone (MQV) key exchange algorithm.
    CALG_HASH_REPLACE_OWF = 0x0000800b, // One way function hashing algorithm.
    CALG_HUGHES_MD5 = 0x0000a003,      // Hughes MD5 hashing algorithm.
    CALG_HMAC = 0x00008009,            // HMAC keyed hash algorithm.
    CALG_KEA_KEYX = 0x0000aa04,        // KEA key exchange algorithm (FORTEZZA).
    CALG_MAC = 0x00008005,             // MAC keyed hash algorithm.
    CALG_MD2 = 0x00008001,             // MD2 hashing algorithm.
    CALG_MD4 = 0x00008002,             // MD4 hashing algorithm.
    CALG_MD5 = 0x00008003,             // MD5 hashing algorithm.
    CALG_NO_SIGN = 0x00002000,         // No signature algorithm.
    CALG_OID_INFO_CNG_ONLY = 0xffffffff, // Algorithm is only implemented in CNG.
    CALG_OID_INFO_PARAMETERS = 0xfffffffe, // Algorithm is defined in the encoded parameters.
    CALG_PCT1_MASTER = 0x00004c04,     // Used by the Schannel.dll operations system.
    CALG_RC2 = 0x00006602,             // RC2 block encryption algorithm.
    CALG_RC4 = 0x00006801,             // RC4 stream encryption algorithm.
    CALG_RC5 = 0x0000660d,             // RC5 block encryption algorithm.
    CALG_RSA_KEYX = 0x0000a400,        // RSA public key exchange algorithm.
    CALG_RSA_SIGN = 0x00002400,        // RSA public key signature algorithm.
    CALG_SCHANNEL_ENC_KEY = 0x00004c07, // Used by the Schannel.dll operations system.
    CALG_SCHANNEL_MAC_KEY = 0x00004c03, // Used by the Schannel.dll operations system.
    CALG_SCHANNEL_MASTER_HASH = 0x00004c02, // Used by the Schannel.dll operations system.
    CALG_SEAL = 0x00006802,            // SEAL encryption algorithm.
    CALG_SHA = 0x00008004,             // SHA hashing algorithm.
    CALG_SHA1 = 0x00008004,            // Same as CALG_SHA.
    CALG_SHA_256 = 0x0000800c,         // 256-bit SHA hashing algorithm.
    CALG_SHA_384 = 0x0000800d,         // 384-bit SHA hashing algorithm.
    CALG_SHA_512 = 0x0000800e,         // 512-bit SHA hashing algorithm.
    CALG_SKIPJACK = 0x0000660a,        // Skipjack block encryption algorithm (FORTEZZA).
    CALG_SSL2_MASTER = 0x00004c05,     // Used by the Schannel.dll operations system.
    CALG_SSL3_MASTER = 0x00004c01,     // Used by the Schannel.dll operations system.
    CALG_SSL3_SHAMD5 = 0x00008008,     // Used by the Schannel.dll operations system.
    CALG_TEK = 0x0000660b,             // TEK (FORTEZZA).
    CALG_TLS1_MASTER = 0x00004c06,     // Used by the Schannel.dll operations system.
    CALG_TLS1PRF = 0x0000800a          // Used by the Schannel.dll operations system.
};

// https://devblogs.microsoft.com/oldnewthing/20040315-00/?p=40253
struct SID {
    u8 revisionlvl[[name("RevisionLevel"), comment("SID_REVISION")]];
    u8 dashes[[name("NoOfDashes"), comment("number of dashes minus two")]]; // dashes = actualdashes - 0x2
    char ntauth[0x6][[name("NtAuthority"), comment("SECURITY_NT_AUTHORITY")]];
    u32  subatuh1[[name("SubAuthority1"), comment("SECURITY_NT_NON_UNIQUE")]];
    u32  subatuh2[[name("SubAuthority2"), comment("these identify the machine that issued the SID")]];
    u32  subatuh3[[name("SubAuthority3"), comment("these identify the machine that issued the SID")]];
    u32  subatuh4[[name("SubAuthority4"), comment("these identify the machine that issued the SID")]];
    u32  rid[[name("RID"), comment("unique user id on the machine")]];
};  


struct CREDHIST_HEADER{
    u32 version[[name("Version")]];
    type::GUID guid[[name("GUID")]];
    u32 nextlen[[name("NextCredSize")]];
};

struct CREDHIST {
    CREDHIST_HEADER credheader[[name("CredHistHeader")]];
    if (std::mem::eof()){
        break;
    }
    u32 flgas [[name("Flags")]];
    ALG_ID alghashid[[name("AlgorithmHashId")]];
    u32 rounds [[name("Rounds")]];
    u32 sidlen [[name("SIDLen")]];
    ALG_ID algcryptid[[name("AlgorithmCryptId")]];
    u32 sha1len[[name("SHA1Len")]];
    u32 md4len[[name("ntlmlen")]];
    char salt[0x10][[name("Salt")]];
    SID sid[[name("SID")]];
    char sha1hash[sha1len][[name("SHA1Hash")]];
    char md4hash[md4len][[name("NTLMHash")]];
    u64 unk1[[name("Unknown")]];
};

CREDHIST credhist [while(!std::mem::eof())] @ 0x0[[name("CredHist")]];