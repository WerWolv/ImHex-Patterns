#pragma author DmitriLeon2000
#pragma description Game Maker 4.0-6.1A data (GMD/GMR/GM6)
#pragma endian little
#pragma magic [ 91 D5 12 00 ] @ 0x00;

import std.mem;
import std.io;

enum ColorDepth : u32 {
    HighColor = 0,
    TrueColor = 1
};

enum ColorDepthV2 : u32 {
    Native = 0,
    HighColor = 1,
    TrueColor = 2
};

enum Resolution : u32 {
    SixFortyByFourEighty = 0,
    EightHundredBySixHundred = 1,
    TenTwentyFourBySevenSixtyEight = 2,
    TwelveEightyByTenTwentyFour = 3,
    Native = 4,
    ThreeTwentyByTwoForty = 5,
    SixteenHundredByTwelveHundred = 6
};

enum ResolutionV2 : u32 {
    Native = 0,
    ThreeTwentyByTwoForty = 1,
    SixFortyByFourEighty = 2,
    EightHundredBySixHundred = 3,
    TenTwentyFourBySevenSixtyEight = 4,
    TwelveEightyByTenTwentyFour = 5,
    ThreeTwentyByTwoForty = 6,
    SixteenHundredByTwelveHundred = 7
};

enum RefreshRate : u32 {
    SixtyHertz = 0,
    SeventyHertz = 1,
    EightyFiveHertz = 2,
    HundredHertz = 3,
    Native = 4
};

enum RefreshRateV2 : u32 {
    Native = 0,
    SixtyHertz = 1,
    SeventyHertz = 2,
    EightyFiveHertz = 3,
    HundredHertz = 4,
    HundredTwentyHertz = 5
};

enum ShowLoadingBar : u8 {
    False = 0,
    True = 1,
    Custom = 2
};

struct RGBA8 {
    u8 red, green, blue; padding[1];
} [[color(std::format("{:02X}{:02X}{:02X}", red, green, blue)),
    hex::inline_visualize("color", red, green, blue, 255)]];

struct BGR8 {
    u8 blue, green, red;
} [[color(std::format("{:02X}{:02X}{:02X}", red, green, blue)),
    hex::inline_visualize("color", red, green, blue, 255)]];

struct RLEImageDataRow {
    u32 segment_count;
    u8 lengths[segment_count];
    BGR8 colors[segment_count];
};

struct RLEImage {
    u32 width, height;
    RLEImageDataRow rle[height];
};

struct RLEImageColorTabledDataRow {
    u32 segment_count;
    u8 lengths[segment_count];
    u8 color_ids[segment_count];
};

struct RLEImageColorTabled {
    u32 color_count;
    BGR8 colors[color_count];
    u32 width, height;
    RLEImageColorTabledDataRow rle[height];
};

struct PascalString {
    u32 length;
    char data[length];
} [[format_read("PascalStringDisplay")]];

fn PascalStringDisplay(PascalString myString) {
    return myString.data;
};

struct BitmapData {
    s32 bmType;
    match (bmType) {
        (0): {
            u8 bfType[2];
            u32 bfSize;
            u8 bfData[bfSize-6] [[sealed, static]];}
        (1): RLEImage bfData [[sealed, static]];
        (2): RLEImageColorTabled bfData [[sealed, static]];
        (10): {u32 bmSize; u8 bmData[bmSize] [[sealed, static]];}
    }
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

enum SoundKind : u32 {
    WAVE = 0,
    MIDI = 1,
    MP3 = 2,
    None = 0xFFFFFFFF
};

enum SoundKindV2 : u32 {
    WAVE = 0,
    MIDI = 1,
    ThreeDimensional = 2,
    MP3 = 3
};

struct BoundingBox {
    u32 left, right, bottom, top;
};

struct RectRegion {
    s32 left, top, width, height;
};

enum BoundingBoxType : u32 {
    Automatic = 0,
    FullImage = 1,
    Manual = 2
};

enum ActionGroupID : s32 { //Introduced in 5.0 beta
    None = 0,
    Move = 1
};   

enum ActionID : s32 {
    None = 0,
    Move = 1,
    ReverseX = 2,
    ReverseY = 3,
    MoveTo = 4,
    MoveRandom = 5,
    Bounce = 6,
    SetSpeedHorizontal = 7,
    SetSpeedVertical = 8,
    SetGravity = 9,
    SetFriction = 10,
    SetMotion = 11,
    SetAlarm = 12,
    InstanceCreate = 13,
    InstanceDestroy = 14,
    InstanceChange = 15,
    PositionDestroy = 16,
    SoundPlay = 17,
    ShowMessage = 18,
    SetScore = 19,
    DisplayHighscore = 20,
    RoomAnother = 21,
    EndGame = 22,
    Sleep = 23,
    ExitEvent = 24,
    CheckPlaceFree = 25,
    CheckInstanceNumber = 26,
    CheckPlaceObject = 27,
    CheckPlaceCollision = 28,
    CheckQuestion = 29,
    CheckExpression = 30,
    Else = 31,
    BlockStart = 32,
    BlockEnd = 33,
    ExecuteCode = 34,
    SetVariable = 35,
    DrawSprite = 36,
    DrawText = 37,
    SetFont = 38,
    SoundStop = 39,
    SnapToGrid = 40,
    RoomPrevious = 41,
    RoomNext = 42,
    ExecuteScript = 43,
    DrawRectangle = 44,
    DrawEllipse = 45,
    DrawLine = 46,
    SetBrushColor = 47,
    SetPenColor = 48,
    MoveStart = 49,
    MovePoint = 50,
    SetSprite = 51,
    SetLives = 52,
    RoomCurrent = 53,
    DrawBackground = 54,
    CheckRandom = 55,
    CheckSound = 56,
    SaveGame = 57,
    LoadGame = 58,
    Repeat = 59,
    RestartGame = 60,
    ShowInfo = 61,
    SwitchFullscreen = 62,
    CheckMouseButton = 63,
    CheckGridAlign = 64,
    Inherited = 65,
    Comment = 66,
    SetPath = 67, // Paths introduced in version 4.2
    TestVariable = 68, // Introduced in 4.3
    DrawVariable = 69 // Introduced in 4.3
};

enum ActionID2 : s32 {
    None = 0,
    Move = 101,
    SetMotion = 102,
    SetSpeedHorizontal = 103,
    SetSpeedVertical = 104,
    MovePoint = 105,
    SetGravity = 107,
    SetFriction = 108,
    JumpPosition = 109,
    JumpStartPosition = 110,
    JumpRandom = 111,
    Wrap = 112,
    ReverseHorizontal = 113,
    ReverseVertical = 114,
    Bounce = 115,
    MoveContact = 116,
    SnapToGrid = 117,
    SetPathOld = 118,
    SetPath = 119,
    StepLinear = 120,
    StepPotential = 121,
    PathPosition = 122,
    PathSpeed = 123,
    PathEnd = 124,
    InstanceCreate = 201,
    InstanceChange = 202,
    InstanceDestroy = 203,
    PositionDestroy = 204,
    SetSpriteOld = 205,
    InstanceCreateMoving = 206,
    InstanceCreateRandom = 207,
    SoundPlay = 211,
    SoundStop = 212,
    CheckSound = 213,
    RoomPrevious = 221,
    RoomNext = 222,
    RoomCurrent = 223,
    RoomAnother = 224,
    CheckRoomPrevious = 225,
    CheckRoomNext = 226,
    SetAlarm = 301,
    Sleep = 302,
    SetTimeline = 303,
    SetTimelinePosition = 304,
    ShowMessage = 321,
    ShowInfo = 322,
    ShowSplashVideo = 323,
    RestartGame = 331,
    EndGame = 332,
    SaveGame = 333,
    LoadGame = 334,
    CheckPlaceFree = 401,
    CheckPlaceCollision = 402,
    CheckPlaceObject = 403,
    CheckInstanceNumber = 404,
    CheckRandom = 405,
    CheckQuestion = 407,
    CheckExpression = 408,
    CheckMouseButton = 409,
    CheckGridAlign = 410,
    Else = 421,
    BlockStart = 422,
    Repeat = 423,
    BlockEnd = 424,
    ExitEvent = 425,
    DrawSprite = 501,
    DrawBackground = 502,
    DrawRectangle = 511,
    DrawEllipse = 512,
    DrawLine = 513,
    DrawText = 514,
    DrawArrow = 515,
    DrawGradientHorizontal = 516,
    DrawGradientVertical = 517,
    DrawGradientEllipse = 517,
    DrawTextTransformed = 519,
    SetBrushColor = 521,
    SetPenColor = 522,
    SetFontOld = 523,
    SetColors = 524,
    SetFontOld2 = 525,
    SetFont = 526,
    SwitchFullscreen = 531,
    CreateEffect = 532,
    SetSprite = 541,
    TransformSprite = 542,
    ColorBlendSprite = 543,
    ExecuteScript = 601,
    ExecuteCode = 603,
    Inherited = 604,
    Comment = 605,
    SetVariable = 611,
    CheckVariable = 612,
    DrawVariable = 613,
    SetScore = 701,
    CheckScore = 702,
    DrawScore = 703,
    DisplayHighscoreOld = 706,
    ClearHighscore = 707,
    DisplayHighscore = 709,
    SetLives = 711,
    CheckLives = 712,
    DrawLives = 713,
    DrawLivesSprite = 714,
    SetHealth = 721,
    CheckHealth = 722,
    DrawHealth = 723,
    SetCaption = 731,
    SetMouse = 801,
    ScreenSnapshot = 802,
    ReplaceSprite = 803,
    ReplaceSound = 804,
    ReplaceBackground = 805,
    GradientBackground = 806,
    OpenWebpage = 807,
    CDPlay = 808,
    CDStop = 809,
    CDPause = 810,
    CDResume = 811,
    CheckCD = 812,
    CheckCDPlaying = 813,
    ParticleSystemCreate = 820,
    ParticleSystemDestroy = 821,
    ParticlesClear = 822,
    ParticleTypeCreate = 823,
    ParticleTypeColor = 824,
    ParticleTypeCreateOld = 825,
    ParticleTypeLife = 826,
    ParticleTypeSpeed = 827,
    ParticleTypeGravity = 828,
    ParticleTypeSecondary = 829,
    ParticleEmitterCreate = 831,
    ParticleEmitterDestroy = 832,
    ParticleEmitterBurst = 833,
    ParticleEmitterStream = 834
};

enum ActionParamWidgetType : u32 {
    Input = 0,
    InputString = 1,
    InputMemo = 2,
    DropDownBoolean = 3,
    DropDownNumber = 4,
    DropDownSprite = 5,
    DropDownSound = 6,
    DropDownBackground = 7,
    DropDownPath = 8,
    DropDownScript = 9,
    DropDownObject = 10,
    DropDownRoom = 11,
    DropDownColor = 13,
    DropDownTimeline = 14,
    DropDownFontCustom = 15
};

bitfield ActionFlags {
    has_name:   1;
    expression: 1;
};

struct GameObjectAction {
    s32 version_verify;
    if (version_verify >= 440) {
        u32 reserved;
        ActionID2 action_id;
    }
    else ActionID action_id;
    if (version_verify >= 440) {
        u32 code_id; /* 1 - start, 2 - end, 3 - else, 4 - exit, 5 - repeat, 6 - var, 7 - code chunks */
        bool has_relative; padding[3];
        bool conditional; padding[3];
        bool can_target_objects; padding[3];
        ActionFlags flags; padding[3];
        PascalString action_name;
        PascalString action_value;
        u32 widget_count_active;
        u32 widget_count_total;
        ActionParamWidgetType widget_types[widget_count_active];
        padding[(widget_count_total-widget_count_active)*4];
    }
    s32 apply_to [[format_read("GetApplyToObjectNameByIndex")]];
    bool relative; padding[3];
    u32 param_count;
    PascalString params[param_count];
    if (version_verify >= 440) {bool inverted_condition; padding[3];}
};

struct GameObjectSubEvent {
    s32 subevent_number;
    s32 version_verify;
    u32 action_count;
    GameObjectAction actions[action_count];
};

struct GameObjectEvent {
    GameObjectSubEvent subevents[while(std::mem::read_unsigned($, 4) != 0xFFFFFFFF)];
    padding[4];
};

struct Sprite {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        u32 width, height;
        BoundingBox bounding_box;
        bool transparent; padding[3];
        if (version_verify >= 540) {
            bool smooth_edges; padding[3];
            bool preload; padding[3];
        }
        BoundingBoxType bounding_box_mode;
        bool precise_collider; padding[3];
        if (version_verify <= 530) {
            bool video_memory; padding[3];
            bool load_only_on_use; padding[3];
        }
        s32 origin_x, origin_y;
        u32 image_count;
        BitmapData images[image_count];
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct Background {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        u32 width, height;
        bool transparent; padding[3];
        if (version_verify >= 540) {
        bool smooth_edges; padding[3];
        bool preload; padding[3];
        bool is_a_tileset; padding[3];
        u32 tile_width, tile_height, tile_x_offset, tile_y_offset, tile_x_seperation, tile_y_seperation;
        } else {
            bool video_memory; padding[3];
            bool load_only_on_use; padding[3];
        }
        u32 image_count;
        BitmapData images[image_count];
    }
} [[name(data_present ? name.data : "<dead data>")]];

enum PathEndAction : u32 {
    Stop = 0,
    JumpToStart = 1,
    MoveToStart = 2,
    Reverse = 3,
    Continue = 4
};

struct PathPoint {
    double x, y, speed;
};

struct Path {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        bool curved; padding[3];
        if (version_verify >= 530) {
            bool closed; padding[3];
            u32 precision;
            s32 background_room [[format_read("GetRoomNameByIndex")]];
            s32 grid_width, grid_height;
        } else {
            PathEndAction end_action;
            padding[4];
        }
        u32 point_count;
        PathPoint points[point_count];
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct Script {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        PascalString code;
    }
} [[name(data_present ? name.data : "<dead data>")]];

enum DataFileExportMode : u32 {
    None = 0,
    TempDirectory = 1,
    WorkingDirectory = 2,
    Font = 3
};

struct DataFile {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        PascalString file_name;
        u32 size;
        u8 file[size] [[sealed, static]];
        DataFileExportMode export_mode;
        bool overwrite; padding[3];
        bool free_data_memory; padding[3];
        bool remove_at_game_end; padding[3];
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct Font {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        PascalString font_name;
        u32 size;
        bool bold; padding[3];
        bool italic; padding[3];
        u32 char_min, char_max;
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct Timeline {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        u32 moment_count;
        GameObjectSubEvent moments[moment_count];
        // PascalString code;
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct GameObject {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        s32 sprite_index [[format_read("GetSpriteNameByIndex")]];
        bool solid; padding[3];
        bool visible; padding[3];
        s32 depth;
        bool persistent; padding[3];
        s32 parent_index [[format_read("GetObjectNameByIndex")]];
        s32 mask_index [[format_read("GetMaskSpriteNameByIndex")]];
        if (version_verify >= 430) {
            u32 event_count;
            GameObjectEvent events[event_count+1];
        } else GameObjectEvent events[9];
        // Events: 0 - Create, 1 - Destroy, 2 - Alarm, 3 - Step, 4 - Collision,
        // 5 - Mouse, 6 - Keyboard, 7 - Other, 8 - Drawing
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct RoomView {
    bool enabled; padding[3];
    s32 x, y;
    u32 width, height;
    if (parent.version_verify < 541)
        s32 x_screen, y_screen;
    else s32 x_port, y_port, width_port, height_port;
    u32 border_horiz, border_vert;
    s32 hspeed, vspeed;
    s32 object_to_follow [[format_read("GetObjectNameByIndex")]];
};

struct RoomBackground {
    bool enabled; padding[3];
    bool foreground; padding[3];
    s32 background_index [[format_read("GetBackgroundNameByIndex")]];
    s32 x, y;
    bool tile_horiz; padding[3];
    bool tile_vert; padding[3];
    s32 hspeed, vspeed;
    if (parent.version_verify >= 520) {bool stretch; padding[3];}
};

struct RoomInstance {
    s32 x, y;
    s32 object_index [[format_read("GetObjectNameByIndex")]];
    s32 id;
    if ((parent.version_verify >= 440) && (parent.version_verify < 520)) {
        padding[8];
    } else if (parent.version_verify >= 520) {
        PascalString creation_code;
        bool locked; padding[3];
    }
};

struct RoomTile {
    s32 x, y;
    s32 tileset_index [[format_read("GetBackgroundNameByIndex")]];
    RectRegion region;
    s32 depth;
    s32 id;
    if (parent.version_verify >= 520) {
        bool locked; padding[3];
    }
};

struct Room {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        PascalString caption;
        s32 width, height, grid_width, grid_height;
        if (version_verify >= 520) {bool grid_isometric; padding[3];}
        s32 speed;
        bool persistent; padding[3];
        RGBA8 back_color;
        bool draw_back_color; padding[3];
        if (version_verify >= 411) PascalString creation_code;
        u32 background_count;
        RoomBackground backgrounds[background_count];
        bool enabled_views; padding[3];
        u32 view_count;
        RoomView views[view_count];
        u32 instance_count;
        RoomInstance instances[instance_count];
        if (version_verify >= 420) {
            u32 tile_count;
            RoomTile tiles[tile_count];
        }
        if ((version_verify >= 440) && (version_verify <= 530)) padding[80];
        if (version_verify >= 541) padding[56];
    }
} [[name(data_present ? name.data : "<dead data>")]];

bitfield SoundAudioEffects {
    chorus:  1;
    echo:    1;
    flanger: 1;
    gargle:  1;
    reverb:  1;
};

struct Sound {
    bool data_present [[hidden]]; padding[3];
    if (data_present) {
        PascalString name;
        s32 version_verify;
        if (version_verify >= 600) SoundKindV2 data_kind;
        else SoundKind data_kind;
        if (data_kind != SoundKind::None) {
            PascalString file_type;
        }
        if (version_verify >= 600) {
            PascalString file_name;
            padding[4];
        }
        u32 data_size;
        u8 data[data_size] [[sealed, static]];
        if (version_verify >= 600) {
            SoundAudioEffects effects; padding[3];
            double volume;
            double panning;
            bool preload; padding[3];
        } else {
            bool allow_for_sfx; padding[3];
            u32 buffer_count;
            bool load_only_on_use; padding[3];
        }
    }
} [[name(data_present ? name.data : "<dead data>")]];

struct GameConstant {
    PascalString name, value;
};

struct GameOptions {
    s32 version_verify;
    // Graphics
    bool fullscreen_startup; padding[3];
    if (version_verify >= 600) {bool antialiased; padding[3];}
    if (version_verify >= 411) {bool no_border_windowed; padding[3];}
    bool display_cursor; padding[3];
    if (version_verify >= 420) {
        s32 scale_percentage_windowed;
        if (version_verify >= 600) {
            bool allow_resizing; padding[3];
            bool always_on_top; padding[3];
            RGBA8 outside_color;
        } else {
            s32 scale_percentage_fullscreen;
            bool scale_hardware_only; padding[3];
        }
        bool set_resolution; padding[3];
    } else {bool fullscreen_scale; padding[3];}
    if (version_verify < 600) {bool exclusive_gfx_mode; padding[3];}
    if (version_verify >= 600) ColorDepthV2 color_depth;
    else ColorDepth color_depth;
    if (version_verify >= 600) ResolutionV2 resolution;
    else Resolution resolution;
    if ((version_verify >= 420) && (version_verify < 600))
        RefreshRate refresh_rate;
    if (version_verify >= 600) {
        RefreshRateV2 refresh_rate;
        bool no_system_menu; padding[3];
    }
    bool wait_for_Vblank; padding[3];
    if (version_verify < 600) {bool fullscreen_caption; padding[3];}
    if ((version_verify >= 440) && (version_verify < 600)) {bool no_system_menu; padding[3];}
    // Keys
    bool keys_f4_fullscreen; padding[3];
    bool keys_f1_info; padding[3];
    bool keys_esc_end; padding[3];
    bool keys_f5f6_saveload; padding[3];
    if (version_verify >= 520) {u8 game_process_priority; padding[3];}
    // Score (until version 5.0)
    if (version_verify < 500) {
        bool score_display; padding[3];
        bool score_background; padding[3];
        if (score_background)
            BitmapData score_background_image;
        RGBA8 score_color_new;
        RGBA8 score_color_other;
        RGBA8 score_color_background;
        PascalString score_text_font;
        u32 score_text_size;
        bool score_border; padding[3];
    }
    // Interaction
    if (version_verify < 600) {
        bool continuous_key_events; padding[3];
        bool continuous_mouse_events; padding[3];
    }
    bool lose_focus_freeze; padding[3];
    // Loading
    if (version_verify >= 411) {
        ShowLoadingBar loading_show_bar; padding[3];
        if (loading_show_bar == ShowLoadingBar::Custom) {
            BitmapData loading_bar_back_image;
            BitmapData loading_bar_front_image;
        }
    } else {bool loading_show_bar; padding[3];}
    bool loading_background; padding[3];
    if (loading_background)
        BitmapData loading_background_image;
    if (version_verify >= 510) {
        bool loading_transparency; padding[3];
        u8 loading_alpha; padding[3];
        bool loading_bar_stretch; padding[3];
    }
    if (version_verify >= 411) {
        u32 icon_size;
        u8 icon_data[icon_size] [[sealed, static]];
    }
    // Errors
    if (version_verify >= 420) {
        bool display_errors; padding[3];
        bool write_to_game_errors_log; padding[3];
        bool abort_on_all_error_messages; padding[3];
        bool uninitialized_as_zeroes; padding[3];
    }
    // Info
    if (version_verify >= 500) {
        PascalString author;
        s32 game_version;
        u64 datetime_changed;
        PascalString information;
    }
    if (version_verify >= 530) {
        u32 constant_count;
        GameConstant constants[constant_count];
    }
    if (version_verify >= 600) {
        u32 includes_count;
        PascalString includes[includes_count];
        bool includes_to_temp; padding[3];
        bool includes_overwrite; padding[3];
        bool includes_remove_on_exit; padding[3];
    }
};

struct GameInformation {
    s32 version_verify;
    RGBA8 back_color;
    if (version_verify >= 430) {
        bool mimic_main_form; padding[3];
    }
    if (version_verify >= 600) {
        PascalString caption;
        s32 x,y, width, height;
        bool show_border; padding[3];
        bool allow_resizing; padding[3];
        bool always_on_top; padding[3];
        bool pause_game; padding[3];
    }
    PascalString info;
};

fn GetSpriteNameByIndex(s32 index) {
    return (index == -1 ? "<no sprite>" : gmd.sprites[index].name.data);
};

fn GetMaskSpriteNameByIndex(s32 index) {
    return (index == -1 ? "<same as sprite>" : gmd.sprites[index].name.data);
};

fn GetBackgroundNameByIndex(s32 index) {
    return (index == -1 ? "<no image>" : gmd.backgrounds[index].name.data);
};

fn GetObjectNameByIndex(s32 index) {
    match (index) {
        (-100): return "<no parent>";
        (-1):   return "<no object>";
        (_):    return gmd.objects[index].name.data;
    }
};

fn GetApplyToObjectNameByIndex(s32 index) {
    match (index) {
        (-2): return "<other>";
        (-1):   return "<self>";
        (_):    return gmd.objects[index].name.data;
    }
};

fn GetRoomNameByIndex(s32 index) {
    return (index == -1 ? "<no room>" : gmd.rooms[index].name.data);
};

enum TreeNodeType : u32 {
    None = 0,
    Folder = 1,
    Subfolder = 2,
    Data = 3
};

enum TreeNodeSubtype : u32 {
    None = 0,
    Object = 1,
    Sprite = 2,
    Sound = 3,
    Room = 4,
    Background = 6,
    Script = 7,
    Path = 8,
    DataFile = 9, // Now Fonts in 6.x onward
    GameInfo = 10,
    GameOptions = 11,
    TimeLine = 12
};

struct TreeNode {
    TreeNodeType type;
    TreeNodeSubtype subtype;
    u32 uid;
    PascalString node_name;
    u32 child_count;
    TreeNode child_nodes[child_count];
} [[name(node_name)]];

struct GMD {
    s32 signature;
    s32 ide_version;
    if (ide_version < 600) u32 standalone_key; // 4.0 GMR only
    s32 identifier;
    if (ide_version >= 411)
        u8 unique_id[16] [[sealed, static]];
    GameOptions options;
    s32 version_verify_sounds;
    s32 sound_count;
    if (ide_version < 600) Sound sounds[(standalone_key > 0 ? sound_count / standalone_key : sound_count)];
    else Sound sounds[sound_count];
    s32 version_verify_sprites;
    s32 sprite_count;
    if (ide_version < 600) Sprite sprites[(standalone_key > 0 ? sprite_count / standalone_key : sprite_count)];
    else Sprite sprites[sprite_count];
    s32 version_verify_backgrounds;
    s32 background_count;
    if (ide_version < 600) Background backgrounds[(standalone_key > 0 ? background_count / standalone_key : background_count)];
    else Background backgrounds[background_count];
    if (ide_version >= 420) {
        s32 version_verify_paths;
        s32 path_count;
        Path paths[path_count];
    }
    s32 version_verify_scripts;
    s32 script_count;
    if (ide_version < 600) Script scripts[(standalone_key > 0 ? script_count / standalone_key : script_count)];
    else Script scripts[script_count];
    if ((ide_version >= 440) && (ide_version < 600)) {
        s32 version_verify_datafiles [[hidden]];
        s32 datafile_count;
        DataFile datafiles[datafile_count];
    }
    if (ide_version >= 600) {
        s32 version_verify_fonts;
        s32 font_count;
        Font fonts[font_count];
    }
    if (ide_version >= 500) {
        s32 version_verify_timelines;
        s32 timeline_count;
        Timeline timelines[timeline_count];
    }
    s32 version_verify_objects;
    s32 object_count;
    if (ide_version < 600) GameObject objects[(standalone_key > 0 ? object_count / standalone_key : object_count)];
    else GameObject objects[object_count];
    s32 version_verify_rooms;
    s32 room_count;
    if (ide_version < 600) Room rooms[(standalone_key > 0 ? room_count / standalone_key : room_count)];
    else Room rooms[room_count];
    s32 last_instance_id;
    if (ide_version >= 420)
        s32 last_tile_id;
    GameInformation information;
    if (ide_version >= 500) {
        s32 version_verify_dummy;
        s32 dummy_count;
        padding[4*dummy_count];
    }
    s32 version_verify_resource_tree;
    u32 active_room_count;
    u32 active_room_ids[active_room_count];
    TreeNode resource_tree[while(!std::mem::eof())];
};

GMD gmd @ 0x0;
