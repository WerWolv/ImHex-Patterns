#include <std/string.pat>
#include <bastion/util.hexpat>

struct VolumeData {
    float music_volume; // default 100%
    float fx_volume; // default 100%
    float dialog_volume; // default 100%
} [[format("fmt_volume")]];

fn fmt_volume(ref auto data) {
    return std::format(
            "Music: {}\nEffects: {}\nDialog: {}",
            fmt_percent(data.music_volume),
            fmt_percent(data.fx_volume),
            fmt_percent(data.dialog_volume));
};

enum MultiSampleType : s32 {
    None = 0,
    TwoSamples = 2,
    FourSamples = 4,
};

struct ProfileData {
    s32 version;
    
    if (version < 9)  return;
    
    Vector2<s32> resolution; // default (1024, 768)
    float brightness [[format("fmt_percent")]]; // default 50%
    VolumeData volume; // default all 100%
    bool subtitles; // default true if not English
    bool rumble; // default true
    bool has_save; // default false
    bool fullscreen; // default true
    MultiSampleType anti_alias; // default None
    bool vsync; // default true
    bool gamepad; // default true
    bool wasd; // default true
};

ProfileData profile @ 0x0;