#pragma author Omikorin
#pragma description Bad Mojo Redux .bmj save file

// upstream: https://github.com/Omikorin/bad-mojo-redux

#pragma endian little

import std.mem;

// Global game state (120 bytes total = 60 * 2 bytes)
struct GlobalGameState {
    s16 BNW09_Cigarette_Armed;     // 01
    s16 BottleCapBridgeSolved;     // 02
    s16 Cat_Roach_Tank_Solved;     // 03
    s16 CatBar_Movie_Seen;         // 04
    s16 CatDen_Movie_Seen;         // 05
    s16 Chili_Splat_Occurred;      // 06
    s16 Cigarette_On_Urinal;       // 07
    s16 Current_Island;            // 08
    s16 Eddie_Pisses_Played;       // 09
    s16 Eddie_Smokes_Played;       // 10
    s16 Fan_Gag_Solved;            // 11
    s16 Fax_Machine_Solved;        // 12
    s16 Final_Oracle_Played;       // 13
    s16 Fire_Started;              // 14
    s16 FishClue_Played;           // 15
    s16 Gimp_State;                // 16
    s16 Gimp_Movie_Played;         // 17
    s16 Heater_Flames_Running;     // 18
    s16 InitialSpinMoviePlayed;    // 19
    s16 Kaboom_Timer;              // 20
    s16 License_Movie_Armed;       // 21
    s16 License_Movie_Played;      // 22
    s16 MET2_Fuse_Count;           // 23
    s16 MET3_Dial_Number;          // 24
    s16 Momma_Mouse_Free;          // 25
    s16 Moth_Location;             // 26
    s16 Most_Recent_Oracle;        // 27
    s16 Mousetrap_Tripped;         // 28
    s16 Peanut_Left_Bank;          // 29
    s16 Pill_X;                    // 30
    s16 Pill_Y;                    // 31
    s16 Pousee_Cafe_NCorrect;      // 32
    s16 Rat_Lunge_Occurred;        // 33
    s16 Rat_Trap_Occurred;         // 34
    s16 Radio_Played;              // 35
    s16 Razor_Blades_Solved;       // 36
    s16 Renegade_BF13_Played;      // 37
    s16 Renegade_BNW09_Played;     // 38
    s16 Renegade_MET2_Played;      // 39
    s16 Renegade_RAD1_Played;      // 40
    s16 Renegade_WH03_Played;      // 41
    s16 Ring_Gag_Solved;           // 42
    s16 RoachMotelSolved;          // 43
    s16 SleepingPill_Armed;        // 44
    s16 SleepingPill_Used;         // 45
    s16 Spoon_Gag_Solved;          // 46
    s16 SS09_Clue_Played;          // 47
    s16 Stage_Achieved;            // 48
    s16 Stove_Burner_On;           // 49
    s16 tc02_tripped;              // 50
    s16 tc02_Spider_Down;          // 51
    s16 TM06_Tripped;              // 52
    s16 TM07_Tripped;              // 53
    s16 TM08_Tripped;              // 54
    s16 Towel_Solved;              // 55
    s16 Urinal_Cig_Solved;         // 56
    s16 Vacuum_State;              // 57
    s16 Vacuum_Shorted;            // 58
    s16 wh01_tripped;              // 59
    s16 Unknown_Var_60;            // 60
}; 

union SaveBlock {
    double as_double;
    u32    as_u32[2];
    u8     as_bytes[8];
};

// Flag for single game objects (1 byte)
struct StandardObjectFlag {
    u8 active [[comment("If != 0, sets flag 0x200 in object struct")]];
};

// Flags for paired game objects (doors, multi-part interactive elements) (2 bytes)
struct PairedObjectFlag {
    u8 item_a_active [[comment("Part A: If != 0, sets flag 0x200")]];
    u8 item_b_active [[comment("Part B: If != 0, sets flag 0x200")]];
};

// Scribble Object structure mapped from LoadScribbleObject (24 bytes total)
struct ScribbleObject {
    char name[14]        [[comment("0x00: Base filename (e.g., CIG0.SOB)")]];
    s16 id_state         [[comment("0x0E: Saved position/state ID (-1 as default)")]];
    s16 pos_x            [[comment("0x10: Screen X coordinate")]];
    s16 pos_y            [[comment("0x12: Screen Y coordinate")]];
    float rotation_scale [[comment("0x14: Float param (rotation/scale)")]];
};

// Module data stream parsing container
struct SaveModuleData {
    // (16 bytes total = 16 * 1 bytes)
    StandardObjectFlag standard_objects[16] [[comment("Single-object state flags from PTR_DAT_004f15f0")]];

    // (30 bytes total = 15 * 2 bytes)
    PairedObjectFlag paired_objects[15] [[comment("Paired-object state flags from PTR_DAT_004f1798")]];

    // (720 bytes total = 30 * 24 bytes)
    ScribbleObject scribble_objects[30] [[comment("Loaded via from DAT_004f1cc8")]];
};

struct BadMojoSave {
    GlobalGameState global_state [[comment("State variables from PTR_DAT_004efbb4")]];
    
    // Current room ID
    s16 room_id [[comment("thunk_FUN_00407a10()")]];
    
    // Player
    s16 player_pos_x  [[comment("DAT_0050deb8")]];
    s16 player_pos_y  [[comment("DAT_0050dc40")]];
    s16 player_state  [[comment("DAT_00503dcc")]];
    
    // The 5 specific 8-byte blocks (to be interpreted)
    SaveBlock save_block_1 [[comment("DAT_0050e3d0")]];
    SaveBlock save_block_2 [[comment("DAT_0050dd28")]];
    SaveBlock save_block_3 [[comment("DAT_0050cf50")]];
    SaveBlock save_block_4 [[comment("DAT_0050cfd0")]];
    SaveBlock save_block_5 [[comment("DAT_0050d034")]];
    
    SaveModuleData module_data [[comment("Data from FUN_004202f0 / FUN_00420180 and FUN_00428d10")]];

    if ($ < std::mem::size()) {
        u8 trailing_module_data[std::mem::size() - $] [[comment("Remaining unmapped file stream")]];
    }
};

BadMojoSave save_file @ 0x00;
