#pragma author timschneeb
#pragma description ESP32 Firmware Image Format

#pragma endian little

// Reference: https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/system/app_image_format.html

import std.mem;

enum esp_chip_id_t : u16 {
    ESP_CHIP_ID_ESP32    = 0x0000,
    ESP_CHIP_ID_ESP32S2  = 0x0002,
    ESP_CHIP_ID_ESP32C3  = 0x0005,
    ESP_CHIP_ID_ESP32S3  = 0x0009,
    ESP_CHIP_ID_ESP32C2  = 0x000C,
    ESP_CHIP_ID_ESP32C6  = 0x000D,
    ESP_CHIP_ID_ESP32H2  = 0x0010,
    ESP_CHIP_ID_ESP32P4  = 0x0012,
    ESP_CHIP_ID_ESP32C5  = 0x0017,
    ESP_CHIP_ID_ESP32C61 = 0x0014,
    ESP_CHIP_ID_ESP32H21 = 0x0019,
    ESP_CHIP_ID_ESP32H4  = 0x001C,
    ESP_CHIP_ID_INVALID  = 0xFFFF
};

enum esp_image_spi_mode_t : u8 {
    QIO,
    QOUT,
    DIO,
    DOUT,
    FAST_READ,
    SLOW_READ
};

enum esp_image_spi_freq_t : u8 {
    DIV_2,
    DIV_3,
    DIV_4,
    DIV_1 = 0xF
};

enum esp_image_flash_size_t : u8 {
    FLASH_1MB,
    FLASH_2MB,
    FLASH_4MB,
    FLASH_8MB,
    FLASH_16MB,
    FLASH_32MB,
    FLASH_64MB,
    FLASH_128MB,
    FLASH_MAX
};

bitfield spi_config_t {
    esp_image_spi_freq_t  spi_speed : 4;
    esp_image_flash_size_t spi_size : 4;
};

const u32 ESP_APP_DESC_MAGIC_WORD = 0xABCD5432;

struct esp_app_desc_t {
    u32 magic_word; // ESP_APP_DESC_MAGIC_WORD
    u32 secure_version;
    u32 reserv1[2];
    char version[32];
    char project_name[32];
    char compile_time[16];
    char compile_date[16];
    char idf_ver[32];
    u8 app_elf_sha256[32];
    u16 min_efuse_blk_rev_full;
    u16 max_efuse_blk_rev_full;
    u8 mmu_page_size; // in log2 format
    u8 reserv3[3];
    u32 reserv2[18];
};

struct esp_image_header_t {
    u8 magic; // 0xE9
    u8 segment_count;
    esp_image_spi_mode_t spi_mode;
    spi_config_t spi_cfg;
    u32 entry_addr;
    u8 wp_pin              [[comment("Write protect pin")]];
    u8 spi_pin_drv[3]      [[comment("Drive settings for the SPI flash pins")]];
    esp_chip_id_t chip_id;
    u8 min_chip_rev        [[comment("Deprecated, replaced by min_chip_rev_full")]];
    u16 min_chip_rev_full  [[comment("Minimal revision (major*100+minor)")]];
    u16 max_chip_rev_full  [[comment("Maximal revision (major*100+minor)")]];
    u8 reserved[4];

    u8 hash_appended       [[comment("If 1, a SHA256 digest 'simple hash' (of the entire image) is appended after the checksum")]];
};

struct esp_image_segment_header_t {
    u32 load_addr;
    u32 data_len;
};

union esp_image_segment_data_t {
    u8 data[parent.header.data_len] [[hidden]];

    // Application segment
    if (std::mem::read_unsigned(addressof(data), 4) == ESP_APP_DESC_MAGIC_WORD) {
        esp_app_desc_t app_descriptor;
    }
};

struct esp_image_segment_t {
    esp_image_segment_header_t header;
    esp_image_segment_data_t data;
};

struct esp_image_t {
    esp_image_header_t header;
    esp_image_segment_t segments[header.segment_count];
};

esp_image_t image @ 0x0;
