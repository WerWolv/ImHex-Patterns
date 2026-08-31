// vim: set sts=4 sw=4 et :
#pragma magic [ 05 0? ?? 00 00 ] @ 0x00
#pragma author Mikle_Bond
#pragma description MIT Kerberos 5 keytab file

import std.core;
import std.sys;
import std.mem;
import std.io;
import type.time;

bool is_keytab_v1 = false;

enum KRB5_NT : u32 {
    unassigned = 0x00000000 ... 0xFFFFFFFF,
    UNKNOWN              = 0,
    PRINCIPAL            = 1,    /**< Just the name of the principal */
    SRV_INST             = 2,    /**< Service and other unique instance (krbtgt) */
    SRV_HST              = 3,    /**< Service with host name as instance */
    SRV_XHST             = 4,    /**< Service with host as remaining components */
    UID                  = 5,    /**< Unique ID */
    X500_PRINCIPAL       = 6,    /**< PKINIT */
    SMTP_NAME            = 7,    /**< Name in form of SMTP email name */
    ENTERPRISE_PRINCIPAL = 10,   /**< Windows 2000 UPN */
    WELLKNOWN            = 11,   /**< Well-known (special) principal */
    MS_PRINCIPAL         = -128, /**< Windows 2000 UPN and SID */
    MS_PRINCIPAL_AND_ID  = -129, /**< NT 4 style name */
    ENT_PRINCIPAL_AND_ID = -130, /**< NT 4 style name and SID */
};

enum EncType : u16 {
    unassigned = 0x0000 ... 0xFFFF,
    NULL                        = 0x0000,
    DES_CBC_CRC                 = 0x0001, /**< @deprecated no longer supported */
    DES_CBC_MD4                 = 0x0002, /**< @deprecated no longer supported */
    DES_CBC_MD5                 = 0x0003, /**< @deprecated no longer supported */
    DES_CBC_RAW                 = 0x0004, /**< @deprecated no longer supported */
    DES3_CBC_SHA                = 0x0005, /**< @deprecated DES-3 cbc with SHA1 */
    DES3_CBC_RAW                = 0x0006, /**< @deprecated DES-3 cbc mode raw */
    DES_HMAC_SHA1               = 0x0008, /**< @deprecated no longer supported */
    DSA_SHA1_CMS                = 0x0009, /**< DSA with SHA1, CMS signature */
    MD5_RSA_CMS                 = 0x000a, /**< MD5 with RSA, CMS signature */
    SHA1_RSA_CMS                = 0x000b, /**< SHA1 with RSA, CMS signature */
    RC2_CBC_ENV                 = 0x000c, /**< RC2 cbc mode, CMS enveloped data */
    RSA_ENV                     = 0x000d, /**< RSA encryption, CMS enveloped data */
    RSA_ES_OAEP_ENV             = 0x000e, /**< RSA w/OEAP encryption, CMS enveloped data */
    DES3_CBC_ENV                = 0x000f, /**< DES-3 cbc mode, CMS enveloped data */
    DES3_CBC_SHA1               = 0x0010,
    AES128_CTS_HMAC_SHA1_96     = 0x0011, /**< RFC 3962 */
    AES256_CTS_HMAC_SHA1_96     = 0x0012, /**< RFC 3962 */
    AES128_CTS_HMAC_SHA256_128  = 0x0013, /**< RFC 8009 */
    AES256_CTS_HMAC_SHA384_192  = 0x0014, /**< RFC 8009 */
    ARCFOUR_HMAC                = 0x0017, /**< RFC 4757 */
    ARCFOUR_HMAC_EXP            = 0x0018, /**< RFC 4757 */
    CAMELLIA128_CTS_CMAC        = 0x0019, /**< RFC 6803 */
    CAMELLIA256_CTS_CMAC        = 0x001a, /**< RFC 6803 */
    UNKNOWN                     = 0x01ff,
};

struct CountedString {
    u16 length;
    char value[length];
} [[format("format_string")]];

fn format_string(ref CountedString d) {
    return d.value;
};

fn join_components(ref CountedString d) {
    auto len = std::core::member_count(d);
    if (len == 0) { return ""; }
    str tmp = d[0].value;
    for (auto i = 1, i < len, i += 1) {
        tmp += "/" + d[i].value;
    }
    return tmp;
};

struct Principal {
    u16 component_count;
    CountedString realm;
    u16 component_count_real = component_count - (is_keytab_v1 ? 1 : 0);
    CountedString component[component_count_real] [[format("join_components")]];
    if (!is_keytab_v1) {
        KRB5_NT name_type;
    }
} [[format("format_principal")]];

fn format_principal(Principal p) {
    return std::format("{}@{}",
        std::format(p.component),
        std::format(p.realm)
    );
};

struct Keyblock {
    EncType enctype;
    u16 length;
    u8 data[length];
} [[hex::visualize("hex_viewer", data)]];

struct EntryContents {
    auto entrystart = $;
    Principal principal;
    type::time32_t timestamp;
    u8 kvno;
    Keyblock key;
    if (4 + $ <= entrystart + parent.entry_size) {
        u32 kvno32;
    }
} [[inline,format("format_entry_contents")]];

fn format_entry_contents(ref EntryContents e) {
    return std::format("kvno {} {} ({}) @ {}",
        std::format(e.kvno),
        std::format(e.principal),
        std::format(e.key.enctype),
        std::time::format(std::time::to_local(e.timestamp), "%Y-%m-%d %H:%M:%S")
    );
};

struct Entry {
    s32 entry_size;
    auto entry_start = $;
    if (entry_size == 0) {
        // end of entry list
        break;
    }
    else if (entry_size < 0) {
        u8 _gap[-entry_size];
        continue;
    }
    else {
        EntryContents entry [[fixed_size(entry_size)]];
        $ = entry_start + entry_size;
    }
} [[format("format_entry")]];

fn format_entry(ref Entry e) {
    if (e.entry_size > 0)
        return e.entry;
    else if (e.entry_size == 0)
        return "EOF";
    else
        return "gap";
};

u8 keytab_version_1_endianness in;

struct Keytab52 {
    u8 kerberos_ver;
    std::assert(kerberos_ver == 0x05, "only kerberos v5 is supported");
    u8 keytab_ver;
    if (keytab_ver == 0x01) {
        is_keytab_v1 = true;
        std::print("This keytab has older format version (v1) and thus\ndepends on the endianness of the host it was created for.");
        std::print("Please, make sure the \"keytab_version_1_endianness\" is set correctly:");
        std::print("0 - try to guess (default)");
        std::print("1 - big endian");
        std::print("2 - little endian");
        match (keytab_version_1_endianness, std::mem::read_unsigned($, 2) == 0x0) {
            (0,  true): {
                std::print("Guessing: big endian");
                be Entry entries[while(!std::mem::eof())];
            }
            (0,  false): {
                std::print("Guessing: little endian");
                le Entry entries[while(!std::mem::eof())];
            }
            (1, _): be Entry entries[while(!std::mem::eof())];
            (2, _): le Entry entries[while(!std::mem::eof())];
        }
    } else if (keytab_ver == 0x02) {
        be Entry entries[while(!std::mem::eof())];
    } else {
        break;
    }
};

Keytab52 keytab @ 0x0;
