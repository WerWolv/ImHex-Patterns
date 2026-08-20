#pragma description OpenSSH private key

#pragma magic [ "-----BEGIN OPENSSH PRIVATE KEY" ] @ 0x00
#pragma endian big

import std.mem;
import std.core;
import type.magic;
import type.base64;

struct String {
    u32 length;
    char content[length];
};

struct Header {
    type::Magic<"openssh-key-v1\0"> signature;

    String cipher_name;

    String kdf_name;
    u32 number_of_kdf;
    std::assert(number_of_kdf == 0, "FIXME: Add support for kdf");

    u32 number_of_keys;
    std::assert(number_of_keys == 1, "FIXME: Add support for multiple keys");
};

struct PublicKey {
    u32 total_size;
    String name;
    String key;
    std::assert(sizeof(this) - sizeof(total_size) == total_size, "PublicKey size does not match total_size field");
};

struct PrivateKey {
    u32 total_size;
    u64 maybe_checksum;
    String key_type;

    std::assert(key_type.content == "ssh-ed25519", "This pattern only supports ed25519 keys");
    const u32 BLOCK_SIZE = 8;
    String public;
    String private;

    String comment;

    padding[(BLOCK_SIZE - ($ - addressof(this) + sizeof(total_size)) % BLOCK_SIZE) % BLOCK_SIZE];
    std::assert(sizeof(this) - sizeof(total_size) == total_size, "PrivateKey size does not match total_size field");
};

struct KeyMaterial {
    Header header;
    PublicKey public_key;
    PrivateKey private_key;
};

struct Key {
  type::Magic<"-----BEGIN OPENSSH PRIVATE KEY-----\n"> begin;
  char base64_data[while(std::mem::read_unsigned($, 4, std::mem::Endian::Native) != 0x2D2D2D2D)];
  type::Magic<"-----END OPENSSH PRIVATE KEY-----"> end;

  auto key_material_section = std::mem::create_section("KeyMaterial");
  std::mem::copy_value_to_section(type::impl::decode_base64(base64_data), key_material_section, 0);

  KeyMaterial data @ 0x00 in key_material_section;
};

Key key @ 0x00;
