#pragma author lopqto
#pragma description ESP8266 Firmware Image v1
#pragma endian little
#pragma magic [ 0xE9 ] @ 0x00

/*
 * References:
 * https://github.com/espressif/esptool/blob/master/esptool/bin_image.py
 * https://github.com/esp8266/esp8266-wiki/wiki/
 */

import std.mem;

const u8 ESP8266_IMAGE_MAGIC = 0xE9;

enum esp8266_flash_mode_t : u8 {
    QIO  = 0,
    QOUT = 1,
    DIO  = 2,
    DOUT = 3
};

enum esp8266_flash_freq_t : u8 {
    FREQ_40M = 0,
    FREQ_26M = 1,
    FREQ_20M = 2,
    FREQ_80M = 0xF
};

enum esp8266_flash_size_t : u8 {
    FLASH_256KB    = 0,
    FLASH_512KB    = 1,
    FLASH_1MB      = 2,
    FLASH_2MB      = 3,
    FLASH_4MB      = 4,
    FLASH_2MB_CTR  = 5,
    FLASH_8MB      = 8,
    FLASH_16MB     = 9
};

bitfield flash_config_t {
    esp8266_flash_freq_t  freq : 4;
    esp8266_flash_size_t  size : 4;
};

struct header {
    u8                 magic         [[comment("ESP8266 image magic, 0xE9")]];
    u8                 segment_count [[comment("Number of segments following header")]];
    esp8266_flash_mode_t flash_mode    [[comment("0=QIO, 1=QOUT, 2=DIO, 3=DOUT")]];
    flash_config_t     flash_config [[comment("High 4 bits: size, Low 4 bits: freq")]];
    u32                entrypoint    [[comment("Entry point address")]];
};

struct segment {
    u32 load_addr [[comment("Load address in memory")]];
    u32 size      [[comment("Size of segment data")]];
    u8 data[size] [[comment("Segment data bytes")]];
};

// Main v1 image at offset 0
header  bootloader_header                  @ 0x00;
segment bootloader_segments[bootloader_header.segment_count] @ 0x08;

// Optional: Second image at 0x1000 (common in ESP8266 flash layout)
header  user_header                  @ 0x1000;
segment user_segments[user_header.segment_count] @ 0x1008;
