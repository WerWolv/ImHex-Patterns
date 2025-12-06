#pragma endian little
#pragma description Xilinx Zynq UltraScale+ Boot Image
#pragma MIME application/x-xilinx-boot-zynqmp
#pragma magic [ 58 4E 4C 58 ] @ 0x24

// Spec: Xilinx UG1283 https://docs.xilinx.com/r/en-US/ug1283-bootgen-user-guide/Zynq-UltraScale-MPSoC-Boot-and-Configuration

import type.magic;
import std.io;
import std.mem;
import std.array;
import std.ptr;

fn format_u32_string(auto arr) {
    str result = "";
    for (u32 i = 0, i < sizeof(arr) / 4, i = i + 1) {
        result += char((arr[i] >> 24) & 0xff);
        result += char((arr[i] >> 16) & 0xff);
        result += char((arr[i] >>  8) & 0xff);
        result += char((arr[i]      ) & 0xff);
    }
    return result;
};

fn pointer_word(auto offset) {
    return u128(offset) * 3;
};

// Based on std::ptr::NullablePtr
// Pointer addresses 4-byte words
struct NullableWordPtr<PointeeTy, PointerTy> {
    PointerTy pointerValue [[no_unique_address, hidden]];
    if (pointerValue == 0x0) {
        padding[sizeof(PointerTy)];
    } else {
        PointeeTy *data : PointerTy [[pointer_base("pointer_word"),inline]];
    }
};

namespace zynqmp {
    enum SpkUserEfuseSelect : u8 {
        Spk = 0x01,
        User = 0x10,
    };

    enum PpkKeySelect : u8 {
        Ppk0 = 0,
        Ppk1 = 1,
    };

    enum AcFormat : u8 {
        Pkcs1v1_5 = 0,
    };

    enum AcVersion : u8 {
        Current = 0,
    };

    enum PpkKeyType : u8 {
        Hash = 0,
    };

    enum PpkKeySource : u8 {
        Efuse = 0,
    };

    enum SpkEnable : u8 {
        Disabled = 0,
        Enabled = 1,
    };

    enum PublicStrength : u8 {
        b2048 = 0,
        b4096 = 1,
    };

    enum HashAlgo : u8 {
        Sha3_384 = 1,
    };

    enum PublicAlgo : u8 {
        Rsa = 1,
    };

    bitfield AuthenticationCertificationHeader {
        PublicAlgo public_algorithm : 2;
        HashAlgo hash_algorithm : 2;
        PublicStrength public_strength : 4;
        SpkEnable spk_enable : 1;
        PpkKeySource ppk_key_source : 2;
        PpkKeyType ppk_key_type : 1;
        AcVersion authentication_certificate_version : 2;
        AcFormat authentication_certificate_format : 2;
        PpkKeySelect ppk_key_select : 2;
        SpkUserEfuseSelect spk_user_efuse_select : 2;
        padding : 12;
    };

    struct AuthenticationCertificates {
        AuthenticationCertificationHeader authentication_header;
        u32 spk_id;
        u32 udf[14];
        u32 ppk_mod[128];
        u32 ppk_mod_ext[128];
        u32 ppk_exponent;
        padding[60];
        u32 spk_mod[128];
        u32 spk_mod_ext[128];
        u32 spk_exponent;
        padding[60];
        u32 spk_signature[128];
        u32 boot_header_signature[128];
        u32 partition_signature[128];
    };

    enum VectorLocation : u8 {
        Low = 0,
        High = 1,
    };

    enum EarlyHandoff : u8 {
        Disabled = 0,
        Enabled = 1,
    };

    enum Endianness : u8 {
        Little = 0,
        Big = 1,
    };

    enum PartitionOwner : u8 {
        Fsbl = 0,
        UBoot = 1,
    };

    enum RsaCertPresent : u8 {
        No = 0,
        Yes = 1,
    };

    enum ChecksumType : u8 {
        None = 0,
        Md5 = 1,
        Sha2 = 2,
        Sha3 = 3,
    };

    enum DestCpu : u8 {
        None = 0,
        A53_0 = 1,
        A53_1 = 2,
        A53_2 = 3,
        A53_3 = 4,
        R5_0 = 5,
        R5_1 = 6,
        R5Lockstep = 7,
        Pmu = 8,
    };

    enum EncryptionPresent : u8 {
        No = 0,
        Yes = 1,
    };

    enum DestDevice : u8 {
        None = 0,
        Ps = 1,
        Pl = 2,
        Pmu = 3,
        Xip = 4,
    };

    enum A5xExecState : u8 {
        Aarch64 = 0,
        Aarch32 = 1,
    };

    enum ExceptionLevel : u8 {
        El0 = 0,
        El1 = 1,
        El2 = 2,
        El3 = 3,
    };

    enum TrustZone : u8 {
        NonSecure = 0,
        Secure = 1,
    };

    bitfield PartitionAttributeBits {
        TrustZone trustzone : 1;
        ExceptionLevel exception_level : 2;
        A5xExecState a5x_exec_state : 1;
        DestDevice destination_device : 3;
        EncryptionPresent encryption_present : 1;
        DestCpu destination_cpu : 4;
        ChecksumType checksum_type : 3;
        RsaCertPresent rsa_authentication_certificate_present : 1;
        PartitionOwner partition_owner : 2;
        Endianness endianness : 1;
        EarlyHandoff early_handoff : 1;
        padding : 3;
        VectorLocation vector_location : 1;
        padding : 8;
    };

    struct PartitionHeader {
        u32 encrypted_partition_data_word_length;
        u32 unencrypted_data_word_length;
        u32 total_partition_word_length;

        NullableWordPtr<PartitionHeader, u32> next_partition_header_offset;

        u64 destination_execution_address;
        u64 destination_load_address;
        NullableWordPtr<std::Array<u8, encrypted_partition_data_word_length * 4>, u32> actual_partition_word_offset;

        PartitionAttributeBits attributes;
        u32 section_count;
        u32 checksum_word_offset;
        u32 image_header_word_offset;

        NullableWordPtr<AuthenticationCertificates, u32> ac_offset;

        u32 partition_number;
        u32 header_checksum;
    };

    struct ImageHeader {
        NullableWordPtr<ImageHeader, u32> image_header;

        NullableWordPtr<PartitionHeader, u32> corresponding_partition_header;

        padding[4];
        u32 partition_count;
        u32 image_name[] [[format("format_u32_string")]];
    };

    enum BootDevice : u32 {
        Same = 0,
        Qspi32 = 1,
        Qspi24 = 2,
        Nand = 3,
        Sd0 = 4,
        Sd1 = 5,
        Sdls = 6,
        Mmc = 7,
        Usb = 8,
        Ethernet = 9,
        PciE = 10,
        Sata = 11,
    };

    struct ImageHeaderTable {
        u32 version;
        u32 count_of_image_header;
        u32 first_partition_header_offset;

        NullableWordPtr<ImageHeader, u32> image_header_table_offset;

        NullableWordPtr<AuthenticationCertificates, u32> header_authentication_certificate;

        BootDevice secondary_boot_device;
        padding[36];
        u32 checksum;
    };

    struct RegisterInitializationTablePair {
        u32 address;
        u32 value;
    };

    struct RegisterInitializationTable {
        RegisterInitializationTablePair register_initialization_pairs[256];
    };

    enum CpuSelect : u8 {
        R5Single,
        A53Single32Bit,
        A53Single64Bit,
        R5Dual,
    };

    enum HashingSelect : u8 {
        NoIntegrityCheck = 0x0 ... 0x1,
        Sha3IntegrityCheck = 0x3,
    };

    enum PufHdLocation : u8 {
        Efuse = 0x0 ... 0x2,
        BootHeader = 0x3,
    };

    enum BootHeaderRsa : u8 {
        AuthDecidedByEfuse = 0x0 ... 0x2,
        AuthEnabled = 0x3,
    };

    bitfield BootHeaderAttributeBits {
        padding : 6;
        PufHdLocation puf_hd : 2;
        HashingSelect hashing_select : 2;
        CpuSelect cpu_select : 2;
        padding : 2;
        BootHeaderRsa bhdr_rsa : 2;
        padding : 16;
    };

    struct PufHelperData {
        u32 data[384];
        u32 chash;
        u16 aux;
        padding[2];
    };

    enum ArmVectorTable : u32 {
        Cortex32Bit = 0xEAFFFFFE,
        Cortex64Bit = 0x14000000,
    };

    enum KeySource : u32 {
        Unencrypted = 0x00000000,
        BlackKeyInEfuse = 0xA5C3C5A5,
        ObfuscatedKeyInEfuse = 0xA5C3C5A7,
        RedKeyInBbram = 0x3A5C3C5A,
        EfuseRedKeyInEfuse = 0xA5C3C5A3,
        ObfuscatedKeyInBootHeader =  0xA35C7CA5,
        UserKeyInBootHeader = 0xA3A5C3C5,
        BlackKeyInBootHeader = 0xA35C7C53,
    };

    struct BootHeader {
        ArmVectorTable arm_vector_table[8];
        u32 width_detection_word;
        type::Magic<"XNLX"> header_signature;
        KeySource key_source;
        u32 fsbl_execution_address;
        u32 source_offset;
        u32 pmu_image_length;
        u32 total_pmu_fw_length;
        u32 fsbl_image_length;
        u32 total_fsbl_length;
        BootHeaderAttributeBits fsbl_image_attributes;
        u32 boot_header_checksum;
        u32 obfuscated_black_key_storage[8];
        u32 shutter_value;
        u32 user_defined_fields[10];

        std::ptr::NullablePtr<ImageHeaderTable, u32> image_header_table_offset;

        u32 partition_header_table_offset;
        u32 secure_header_iv[3];
        u32 obfuscated_black_key_iv[3];

        if (fsbl_image_attributes.puf_hd == 0x3) {
            PufHelperData puf_helper_data @ 0x8b8;
        }

        if (source_offset > 0) {
            if (pmu_image_length > 0) {
                u8 pmu_firmware[total_pmu_fw_length] @ source_offset;
                u8 fsbl[total_fsbl_length] @ source_offset + total_pmu_fw_length;
            } else {
                u8 fsbl[total_fsbl_length] @ source_offset;
            }
        }
    };

    struct DeviceBootImage {
        BootHeader boot_header @ 0x0;
        RegisterInitializationTable register_initialization_table @ 0xB8;
    };
}

zynqmp::DeviceBootImage boot_image @ 0x00;
