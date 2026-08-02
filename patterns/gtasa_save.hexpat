#pragma description GTA San Andreas Save Game
#pragma author haru233

import std.mem;
#pragma endian little

fn getBlockContent(u16 idx){
  return std::mem::find_string_in_range(idx, 0, std::mem::size(), "BLOCK") + 5;
};

struct GTASABlock0 {
    s32 version;
    padding[0x78];
    s32 minuteLength;
    padding[0x06];
    u8 timeHour;
    u8 timeMinute;
    u8 timeDayOfWeek;
    padding[0x57];
    bool riots;
    padding[0x0D];
    bool uncensored;
    padding[0x45];
    bool helpStealVehicle;
    bool taxiNitro;
    bool prostitutesPay;
};

struct GTASABlock15 {
    padding[0x04];
    s32 money;
    padding[0x08];
    s32 moneyOnScreen;
    padding[0x0C];
    bool infiniteRun;
    bool fastReload;
    bool fireProof;
    padding[0x02];
    bool freeBustedOnce;
    bool freeWastedOnce;
    bool enableDriveby;
};

struct GTASABlock16 {
    padding[0x54];
    float fat;
    float stamina;
    float muscle;
    float maxHealth;
    padding[0x9C];
    float respect;
    padding[0x10];
    float weaponPistol;
    float weaponSilencedPistol;
    float weaponDesertEagle;
    float weaponShotgun;
    float weaponSawnoffShotgun;
    float weaponCombatShotgun;
    float weaponMachinePistol;
    float weaponSmg;
    float weaponAk47;
    float weaponM4;
    padding[0x04];
    float sexAppeal;
    float gamblingSkill;
    padding[0x34];
    s32 timesBusted;
    s32 daysPassed;
    s32 timesWasted;
    padding[0x04];
    s32 timesCheated;
    padding[0x58];
    s32 drivingSkill;
    padding[0x50];
    s32 storyLine;
    padding[0xA4];
    s32 flyingSkill;
    padding[0x04];
    s32 lungCapacity;
    padding[0x0C];
    s32 bikeSkill;
    s32 cyclingSkill;
    s32 snapshotsCollected;
    padding[0x24];
    s32 horseshoesCollected;
    padding[0x04];
    s32 oystersCollected;
};

GTASABlock0  Block0 @ getBlockContent(0);
GTASABlock15 Block1 @ getBlockContent(15);
GTASABlock16 Block16 @ getBlockContent(16);
