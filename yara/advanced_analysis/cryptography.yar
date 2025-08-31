rule HashMD5 {
    meta:
        category = "Hash Algorithms"
        name     = "MD5"

    strings:
        /* MD5("") */
        $md5_magic = { d4 1d 8c d9 8f 00 b2 04 e9 80 09 98 ec f8 42 7e }

    condition:
        any of them
}

rule HashSHA1 {
    meta:
        category = "Hash Algorithms"
        name     = "SHA1"

    strings:
        /* SHA-1("") */
        $sha1_example = { da 39 a3 ee 5e 6b 4b 0d 32 55 bf ef 95 60 18 90 af d8 07 09 }

    condition:
        any of them
}

rule HashSHA224 {
    meta:
        category = "Hash Algorithms"
        name     = "SHA224"

    strings:
        /* SHA-224("") */
        $sha224_empty = { d1 4a 02 8c 2a 3a 2b c9 47 61 02 bb 28 82 34 c4
                          15 a2 b0 1f 82 8e a6 2a c5 b3 e4 2f }

    condition:
        any of them
}

rule HashSHA256 {
    meta:
        category = "Hash Algorithms"
        name     = "SHA256"

    strings:
        /* SHA-256("") */
        $sha256_empty = { e3 b0 c4 42 98 fc 1c 14 9a fb f4 c8 99 6f b9 24
                          27 ae 41 e4 64 9b 93 4c a4 95 99 1b 78 52 b8 55 }

    condition:
        any of them
}

rule HashSHA384 {
    meta:
        category = "Hash Algorithms"
        name     = "SHA384"

    strings:
        /* SHA-384("") */
        $sha384_empty = { 38 b0 60 a7 51 ac 96 38 4c d9 32 7e b1 b1 e3 6a
                          21 fd b7 11 14 be 07 43 4c 0c c7 bf 63 f6 e1 da
                          27 4e de bf e7 6f 65 fb d5 1a d2 f1 48 98 b9 5b }

    condition:
        any of them
}

rule HashSHA512 {
    meta:
        category = "Hash Algorithms"
        name     = "SHA512"

    strings:
        /* SHA-512("") */
        $sha512_empty = { cf 83 e1 35 7e ef b8 bd f1 54 28 50 d6 6d 80 07
                          d6 20 e4 05 0b 57 15 dc 83 f4 a9 21 d3 6c e9 ce
                          47 d0 d1 3c 5d 85 f2 b0 ff 83 18 d2 87 7e ec 2f
                          63 b9 31 bd 47 41 7a 81 a5 38 32 7a f9 27 da 3e }

    condition:
        any of them
}

rule HashRIPEMD160 {
    meta:
        category = "Hash Algorithms"
        name     = "RIPEMD160"

    strings:
        /* RIPEMD-160("") */
        $ripemd160_empty = { 9c 11 85 a5 c5 e9 fc 54 61 28 08 97 7e e8 f5 48 b2 25 8d 31 }

    condition:
        any of them
}


rule CryptoAES {
    meta:
        category = "Cryptographic Algorithms"
        name     = "AES"

    strings:
        /* First 16 bytes of the AES S-box */
        $aes_sbox = { 63 7c 77 7b f2 6b 6f c5 30 01 67 2b fe d7 ab 76 }

    condition:
        any of them
}

rule CryptoDES {
    meta:
        category = "Cryptographic Algorithms"
        name     = "DES"

    strings:
        /* DES S-box 1 (first 16 entries) */
        $des_sbox1 = { 0e 04 0d 01 02 0f 0b 08 03 0a 06 0c 05 09 00 07 }

    condition:
        any of them
}

rule Crypto3DES {
    meta:
        category = "Cryptographic Algorithms"
        name     = "3DES"

    strings:
        /* Pattern: two consecutive DES S-box 1 sequences often appear in 3-DES code */
        $tdes_pattern = { 0e 04 0d 01 02 0f 0b 08 03 0a 06 0c 05 09 00 07 0e 04 0d 01 }

    condition:
        any of them
}

rule CryptoBlowfish {
    meta:
        category = "Cryptographic Algorithms"
        name     = "Blowfish"

    strings:
        /* Start of Blowfish P-array (Pi digits) */
        $blowfish_parray = { 24 3f 6a 88 85 a3 08 d3 13 19 8a 2e 03 70 73 44 }

    condition:
        any of them
}

rule CryptoRC4 {
    meta:
        category = "Cryptographic Algorithms"
        name     = "RC4"

    strings:
        /* RC4 state array after KSA init with zero-length key */
        $rc4_init = { 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f }

    condition:
        any of them
}

rule CryptoRSA {
    meta:
        category = "Cryptographic Algorithms"
        name     = "RSA"

    strings:
        /* ASN.1 OID 1.2.840.113549.1.1.1  (rsaCryptographic) */
        $rsa_oid = { 06 09 2a 86 48 86 f7 0d 01 01 01 }

    condition:
        any of them
}

rule CryptoECDSA_P256 {
    meta:
        category = "Cryptographic Algorithms"
        name     = "ECDSA-P256"

    strings:
        /* ASN.1 OID 1.2.840.10045.3.1.7 (secp256r1) */
        $ecdsa_p256_oid = { 06 08 2a 86 48 ce 3d 03 01 07 }

    condition:
        any of them
}

rule CryptoEd25519 {
    meta:
        category = "Cryptographic Algorithms"
        name     = "Ed25519"

    strings:
        /* ASN.1 OID 1.3.101.112 (Ed25519) */
        $ed25519_oid = { 06 03 2b 65 70 }

    condition:
        any of them
}

rule CryptoChaCha20Poly1305 {
    meta:
        category = "Cryptographic Algorithms"
        name     = "ChaCha20-Poly1305"

    strings:
        /* ASCII "expand 32-byte k" – ChaCha20 constant */
        $chacha_sigma = "expand 32-byte k" ascii wide
        $chacha_sigma_hex = { 65 78 70 61 6e 64 20 33 32 2d 62 79 74 65 20 6b }

    condition:
        any of them
}

rule CRC32 {
    meta:
        category = "CRC"
        name     = "CRC32"

    strings:
        /* First 16 entries of standard CRC32 IEEE 802.3 polynomial table (0xEDB88320) */
        $crc32_table = {
            00 00 00 00 77 07 30 96 ee 0e 61 2c 99 09 51 ba
            07 1c c2 5d 70 1b f2 cb e9 12 a3 71 9e 15 93 e7
        }
        /* Little-endian and big-endian representations of 0xEDB88320 */
        $crc32_poly_le = { 20 83 b8 ed }
        $crc32_poly_be = { ed b8 83 20 }

    condition:
        any of them
}


rule CRC16CCITT {
    meta:
        category = "CRC"
        name     = "CRC16-CCITT"

    strings:
        /* First 16 entries of CRC16-CCITT table (poly 0x1021) */
        $crc16_table = {
            00 00 10 21 20 42 30 63 40 84 50 a5 60 c6 70 e7
            81 08 91 29 a1 4a b1 6b c1 8c d1 ad e1 ce f1 ef
        }
        $crc16_poly_le = { 21 10 }
        $crc16_poly_be = { 10 21 }

    condition:
        any of them
}

rule CRC8 {
    meta:
        category = "CRC"
        name     = "CRC8"

    strings:
        /* First 16 entries of CRC8 table (poly 0x07, standard) */
        $crc8_table = {
            00 07 0e 09 1c 1b 12 15 38 3f 36 31 24 23 2a 2d
        }

    condition:
        any of them
}
