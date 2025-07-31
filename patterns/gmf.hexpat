#pragma author DmitriLeon2000
#pragma description Game Maker 3.x data
#pragma endian little

import std.mem;
import std.io;

struct Colors {
    u8 red   [[color("FF0000")]];
    u8 green [[color("00FF00")]];
    u8 blue  [[color("0000FF")]];
    padding[1];
} [[static, color(std::format("{:02X}{:02X}{:02X}", red, green, blue)),
    hex::inline_visualize("color", red, green, blue, 255)]];

struct PascalString {
    u32 length;
    char data[length];
};

struct BitmapData {
    u8 bfType[2];
    u32 bfSize;
    u8 bfData[bfSize-6] [[sealed]];
};

enum BackgroundType : s32 {
    Solid = 0,
    Image = 1,
    Gradient = 2,
    None = 3
};

enum BackImageStyle : s32 {
    Tile = 0,
    Stretch = 1,
    Scrolling = 2,
    LeftTop = 3
};

enum Transition : u32 {
    None = 0,
    CreateFromLeft = 1,
    CreateFromRight = 2,
    CreateFromTop = 3,
    CreateFromBottom = 4,
    CreateFromCenter = 5,
    ShiftFromLeft = 6,
    ShiftFromRight = 7,
    ShiftFromTop = 8,
    ShiftFromBottom = 9,
    PushFromLeft = 10,
    PushFromRight = 11,
    PushFromTop = 12,
    PushFromBottom = 13
};

struct SpriteBoundingBox {
    u32 left, right, bottom, top;
};

enum ActionID : s32 {
    EnumerateActions = 0,
    EndAction = 1,
    MoveFixed = 101,
    ReverseHorizontal = 102,
    ReverseVertical = 103,
    JumpPosition = 104,
    JumpRandom = 105,
    Bounce = 106,
    SetSpeedHorizontal = 111,
    SetSpeedVertical = 112,
    SetGravity = 121,
    SetFriction = 122,
    MoveFree = 131,
    SetAlarm = 201,
    InstanceCreate = 311,
    InstanceDestroy = 312,
    InstanceChange = 313,
    PositionDestroy = 321,
    Sound = 401,
    ShowMessage = 411,
    SetScore = 421,
    DisplayHighscore = 431,
    GoToRoom = 501,
    EndGame = 511,
    Sleep = 521,
    ExitEvent = 601,
    CheckPlaceFree = 701,
    CheckInstanceNumber = 702,
    CheckPlaceObject = 703,
    CheckPlaceCollision = 704,
    CheckQuestion = 721,
    Else = 751,
    CheckExpression = 801,
    ExecuteCode = 811,
    SetVariable = 821,
    BlockStart = 901,
    BlockEnd = 902,
    DrawImage = 1001,
    DrawText = 1002,
    SetFont = 1003
};

struct GameObjectAction {
    s32 version_verify [[hidden]];
    ActionID action_id;
    s32 apply_to; // -1 - self; -2 - not available
    bool relative;
    padding[3];
    u32 param_count;
    PascalString params[param_count];
    s32 action_group;
};

struct GameObjectSubEvent {
    s32 subevent_number;
    s32 version_verify [[hidden]];
    u32 action_count;
    GameObjectAction actions[action_count];
};

struct GameObjectEvent {
    GameObjectSubEvent subevents[while(std::mem::read_unsigned($, 4) != 0xFFFFFFFF)];
    padding[4];
};

struct GameSprite {
    s32 version_verify [[hidden]];
    s32 width, height;
    SpriteBoundingBox bounding_box1;
    u32 image_count;
    BitmapData images[image_count];
    SpriteBoundingBox bounding_box2;
};

struct GameObject {
    s32 version_verify [[hidden]];
    PascalString name;
    bool solid;
    padding[3];
    bool active;
    padding[3];
    if (version_verify >= 320)
        u32 parent_id;
    GameObjectEvent events[13];
    // Events: 0 - Create, 1 - Destroy, 2 - Alarm, 3 - Step, 4 - Collision,
    // 5 - Meeting, 6 - Mouse, 7 - Keyboard, 8 - Other, 9 - Drawing
    // 10 - Create duplicate, 11-13 - unused
    s32 cap [[hidden]];
    GameSprite sprite;
} [[name(name.data)]];

struct GameRoomView {
    bool enabled;
    padding[3];
    if (parent.version_verify >= 320)
        s32 left, top, left_cell, top_cell;
    u32 width;
    u32 height;
    if (parent.version_verify >= 320) {
        u32 border_horiz, border_vert;
    } else
        u32 border;
    u32 object_to_follow;
};

struct GameRoomInstance {
    s32 left, top, object_index;
};

struct GameRoom {
    u32 version_verify [[hidden]];
    PascalString name;
    Colors back_color1;
    if (version_verify >= 320) {
        Colors back_color2;
        bool vertical_gradient;
        padding[3];
    }
    // specify the name of the external image file from the data folder
    PascalString back_image_name;
    BackgroundType back_type;
    BackImageStyle back_image_style;
    s32 back_scroll_speed_horizontal, back_scroll_speed_vertical;
    s32 speed, width, height, cell_size;
    if (version_verify >= 320) {
        bool enable_views;
        padding[3];
        GameRoomView views[4];
    } else
        GameRoomView view;
    if (version_verify >= 320) {
        Transition transition;
        u32 transition_time, transition_steps;
    }
    u32 instance_count;
    GameRoomInstance instances[instance_count];
} [[name(name.data)]];

struct GameSound {
    u32 version_verify [[hidden]];
    PascalString name;
    u32 reserved;
    // specify the name of the external audio file from the data folder
    PascalString filename;
    bool allow_for_sound_effects;
    padding[3];
    u32 buffer_count;
} [[name(name.data)]];

struct GMF {
    u32 version;
    u32 verification[2];
    u32 version_verify_options [[hidden]];
    u32 option_count;
    PascalString options[option_count];
    u32 version_verify_objects [[hidden]];
    u32 object_count;
    GameObject objects[object_count];
    u32 version_verify_rooms [[hidden]];
    u32 room_count;
    GameRoom rooms[room_count];
    u32 version_verify_sounds [[hidden]];
    u32 sound_count;
    GameSound sounds[sound_count];
};

GMF gmf @ 0x0;