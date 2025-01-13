#pragma author bake
#pragma description veadotube mini avatar file

import std.mem;
import std.io;

struct varint {
  u8 value;
};

struct String {
  varint length;
  char string[length.value];
};

struct Header {
  char magic[9];
};

struct Meta {
  String software;
  String credits;
  String description;
};

enum EffectFlag : u8 {
  Active = 0x1,
  UsePreset = 0x2,
  UsePresetChunk = 0x4,
};

struct Effect {
  String effect_id;
  EffectFlag flag;
  if (u8(flag) & EffectFlag::UsePresetChunk) {
    u32 chunk_id;
  }
  if (u8(flag) & EffectFlag::UsePreset) {
    String preset_id;
  }
  varint num_values;
  double values[num_values.value];
};

struct Effects {
  varint num_effects;
  Effect effects[num_effects.value];
};

enum StateFlag : u32 {
  Pixelated = 0x1,
  Blink = 0x2,
  Start = 0x4,
};

struct Signal {
  String source;
  String name;
};

enum ShortcutMode : char {
  Press = "PRES",
  Release = "RLSE",
  WhilePressed = "PRED",
};

struct Msta {
  String name;
  StateFlag state;
  u32 thumbnail_closed_mouth;
  u32 thumbnail_open_mouth;
  u32 thumbnail_blinking_closed_mouth;
  u32 thumbnail_blinking_open_mouth;
  u32 closed_mouth;
  u32 open_mouth;
  u32 blinking_closed_mouth;
  u32 blinking_open_mouth;
  double blink_duration;
  double min_blink_interval;
  double max_blink_interval;
  Effects closed_mouth_effects;
  Effects open_mouth_effects;
  Effects on_open_mouth_effects;
  Effects on_close_mouth_effects;
  varint num_signals;
  Signal signals[num_signals.value];
  char shortcut_mode[4];
};

struct AsfdMetadata {
  char type[4];
  varint num_metadata;
  u8 metadata[num_metadata.value];
};

struct AsfdEntry {
  String entry_name;
  u32 chunk_id;
  varint num_metadata;
  AsfdMetadata metadata[num_metadata.value];
};

struct Asfd {
  char root_code[4];
  AsfdEntry entries[];
};

struct Thmb {};

struct AimgFrame {
  u32 chunk_id;
  s32 offset_x;
  s32 offset_y;
  double duration;
};

struct Aimg {
  u32 width;
  u32 height;
  varint num_frames;
  if (num_frames.value > 1) {
    varint num_loops;
  }
  AimgFrame frames[num_frames.value];
};

struct Abmp {
  u32 width;
  u32 height;
  char format[4];
  u32 num_as;
  u32 num_rs;
  u32 num_gs;
  u32 num_bs;
  if (format == "VDD." && num_as < 0xffffff00) {
    u32 _as[num_as];
  }
  if (format == "VDD." && num_rs < 0xffffff00) {
    u32 _rs[num_rs];
  }
  if (format == "VDD." && num_gs < 0xffffff00) {
    u32 _gs[num_gs];
  }
  if (format == "VDD." && num_bs < 0xffffff00) {
    u32 _bs[num_bs];
  }
  if (format == "RAW.") {
    u32 data[];
  }
};

struct Chunk {
  u32 id;
  char type[4];
  u32 length;
  if (type == "META") {
    Meta meta;
  } else if (type == "MLST") {
    u32 chunk_ids[length / 4];
  } else if (type == "MSTA") {
    Msta msta;
  } else if (type == "ASFD") {
    u64 startAddress = $;
    Asfd asfd;
    AsfdEntry entries[while ($ - startAddress < length)];
  } else if (type == "THMB") {
    Thmb thmb;
    padding[length];
  } else if (type == "AIMG") {
    Aimg aimg;
  } else if (type == "ABMP") {
    Abmp abmp;
    padding[length - sizeof(abmp)];
  } else {
    std::print("unknown type {}", type);
    padding[length];
    break;
  }
};

Header header @0x00;
Chunk data[while (!std::mem::eof())] @$;
