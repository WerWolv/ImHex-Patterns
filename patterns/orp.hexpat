#pragma description OpenRGB Profile

#pragma magic [ 4F 50 45 4E 52 47 42 5F 50 52 4F 46 49 4C 45 00 ] @ 0x00

import type.magic;
import std.mem;

using Controller;

struct Profile {
    type::Magic<"OPENRGB_PROFILE\x00"> signature;
    u32 version;
    Controller controllers[while(!std::mem::eof())];
};

Profile profile @ 0x00;

using Mode;
using Zone;
using led;
using RGBColor;
using _LedAltName;
struct Controller {
    u32 size;
    s32 device_type;
    u16 name_len;
    char name[name_len];
    u16 vendor_len;
    char vendor[vendor_len];
    u16 description_len;
    char description[description_len];
    if (parent.version >= 1) {
        u16 version_len;
        char version[version_len];
    }
    u16 serial_len;
    char serial[serial_len];
    u16 location_len;
    char location[location_len];
    u16 num_modes;
    u32 active_mode;
    Mode modes[num_modes];
    u16 num_zones;
    Zone zones[num_zones];
    u16 num_leds;
    led leds[num_leds];
    u16 num_colors;
    RGBColor colors[num_colors];
    if (parent.version >= 5) {
        u16 num_led_alt_names;
        _LedAltName led_alt_names[num_led_alt_names];
        u32 flags;
    }
};

struct Mode {
    u16 name_len;
    char name[name_len];
    u32 value;
    u32 flags;
    u32 speed_min;
    u32 speed_max;
    if (parent.parent.version >= 3) {
        u32 brightness_min;
        u32 brightness_max;
    }
    u32 colors_min;
    u32 colors_max;
    u32 speed;
    if (parent.parent.version >= 3) {
        u32 brightness;
    }
    u32 direction;
    u32 color_mode;
    u16 colors_len;
    RGBColor colors[colors_len];
};

using zone_type = s32;

using matrix_map_type;
using segment;
struct Zone {
    u16 name_len;
    char name[name_len];
    zone_type type;
    u32 leds_min;
    u32 leds_max;
    u32 leds_count;
    u16 matrix_len;
    matrix_map_type matrix[matrix_len];
    if (parent.parent.version >= 4) {
        u16 segments_len;
        segment segments[segments_len];
    }
    if (parent.parent.version >= 5) {
        u32 flags;
    }
};

struct led {
    u16 name_len;
    char name[name_len];
    u32 value;
};

struct RGBColor {
    u8 red   [[color("FF0000")]];
    u8 green [[color("00FF00")]];
    u8 blue  [[color("0000FF")]];
    u8 alpha;
} [[
    color(std::format("{:02X}{:02X}{:02X}{:02X}", red, green, blue, alpha)),
    hex::inline_visualize("color", red, green, blue, alpha)
]];

struct _LedAltName {
    u16 name_len;
    char name[name_len];
};

struct matrix_map_type {
    u32 height;
    u32 width;
    u32 map[width * height];
};

struct segment {
    u16 name_len;
    char name[name_len];
    zone_type type;
    u32 start_idx;
    u32 leds_count;
};
