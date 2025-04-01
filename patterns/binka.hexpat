#pragma author DexrnZacAttack
#pragma description RAD Game Tools BINKA (Bink Audio)
#pragma magic [31 46 43 42] @ 0x00

import std.string;
import std.math;
import type.magic;

fn getDuration(u32 duration_ts, u32 sample_rate) {
    return float(duration_ts) / float(sample_rate);
};

struct Binka {
    type::Magic<"1FCB"> magic;
    u8; // can't get this to change anything when using ffprobe
    u8 channel_count [[name(std::format("Channel Count: {}", this))]];
    u16 sample_rate [[name(std::format("Sample Rate: {}", this))]];
    u32 duration_ts [[name(std::format("Duration: {}s", std::math::floor(getDuration(this, sample_rate))))]];
    u32;
    u32 size [[name(std::format("File Size: {} bytes", this))]];
    u8 data[size - 20];
};

Binka binka @ 0x00;
