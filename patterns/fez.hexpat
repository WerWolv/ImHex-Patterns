import std.core;
import std.io;
import type.time;
import std.sys;

using int = s32;
using long = s64;

struct SevenBitEncodedIntByte {
    u8 byte;
    if ((byte & 0x80) == 0x00)
        break;
};

struct SevenBitEncodedInt {
    SevenBitEncodedIntByte bytes[while(true)];
} [[sealed, format("transformSevenBitEncodedInt"), transform("transformSevenBitEncodedInt")]];

fn transformSevenBitEncodedInt(ref auto encodedInt) {
  u64 result = 0;

  for (u32 i = 0, i < std::core::member_count(encodedInt.bytes), i += 1) {
    result |= (encodedInt.bytes[i].byte & 0x7F) << (i * 7);
  }
  
  return result;
};

struct String {
    SevenBitEncodedInt size;
    char string[size];
} [[format("formatString")]];

fn formatString(ref auto string) {
    return string.string;
};

struct Object<T> {
    bool hasValue [[tree_hidden]];
    
    if (hasValue)
        T value;
} [[sealed, format("formatObject")]];

fn formatObject(ref auto object) {
    if (!object.hasValue)
        return "<Empty>";
    else
        return object.value;
};

struct KeyValuePair<Key, Value> {
    Key key;
    Value value;
} [[name(std::format("[{}]", this.key))]];

enum Viewpoint : int {
    None,
    Front,
    Right,
    Back,
    Left,
    Up,
    Down,
    Perspective
};

struct Vector3 {
    float x, y, z;
};

struct List<T> {
    int count;
    T items[count];
};

enum ActorType : int {
  None,
  Ladder,
  Bouncer,
  Sign,
  GoldenCube,
  PickUp,
  Bomb,
  Destructible,
  DestructiblePermanent,
  Vase,
  Door,
  Heart,
  Watcher,
  Crystal,
  BlackHole,
  Vine,
  BigBomb,
  TntBlock,
  TntPickup,
  MotorBlock,
  Hurt,
  Checkpoint,
  TreasureChest,
  CubeShard,
  BigHeart,
  SkeletonKey,
  ExploSwitch,
  PushSwitch,
  EightBitDoor,
  PushSwitchSticky,
  PushSwitchPermanent,
  SuckBlock,
  WarpGate,
  OneBitDoor,
  SpinBlock,
  PivotHandle,
  FourBitDoor,
  LightningPlatform,
  LightningGhost,
  Tombstone,
  SplitUpCube,
  UnlockedDoor,
  Hole,
  Couch,
  Valve,
  Rumbler,
  Waterfall,
  Trickle,
  Drips,
  Geyser,
  ConnectiveRail,
  BoltHandle,
  BoltNutBottom,
  BoltNutTop,
  CodeMachine,
  NumberCube,
  LetterCube,
  TriSkull,
  Tome,
  SecretCube,
  LesserGate,
  Crumbler,
  LaserEmitter,
  LaserBender,
  LaserReceiver,
  RebuildingHexahedron,
  TreasureMap,
  Timeswitch,
  TimeswitchMovingPart,
  Mail,
  Mailbox,
  Bookcase,
  TwoBitDoor,
  SixteenBitDoor,
  ThirtyTwoBitDoor,
  SixtyFourBitDoor,
  Owl,
  Bell,
  RotatingGroup,
  BigWaterfall,
  Telescope,
  SinkPickup,
  QrCode,
  FpsPost,
  PieceOfHeart,
  SecretPassage,
  Piston
};

struct TrileEmplacement {
    int x, y, z;
};

struct WinConditions {
    int lockedDoorCount;
    int unlockedDoorCount;
    int chestCount;
    int cubeShardCount;
    int otherCollectibleCount;
    int splitUpCount;
    List<int> scriptIds;
    int secretCount;
};

struct LevelSaveData {
    List<TrileEmplacement> destroyedTriles;
    List<TrileEmplacement> inactiveTriles;
    List<int> inactiveArtObjects;
    List<int> inactiveEvents;
    List<int> InactiveGroups;
    List<int> inactiveVolumes;
    List<int> inactiveNPCs;
    List<KeyValuePair<int, int>> pivotRotations;
    Object<float> lastStableLiquidHeight;
    Object<String> scriptingState;
    bool firstVsisit;
    WinConditions filledConditions;
};

struct FezSaveFile {
    long fileTime;

    long version;
    std::assert(version == 6, "Unsupported Save File Version. Only Version 6 is supported");
    long creationTime;
    bool finished32;
    bool finished64;
    bool hasFpView;
    bool hasStereo3d;
    bool canNewGamePlus;
    bool isNewGamePlus;
    List<KeyValuePair<Object<String>, bool>> oneTimeTutorials;
    Object<String> level;
    Viewpoint view;
    Vector3 ground;
    long timeOfDay;
    List<Object<String>> unlockedWarpDestinations;
    int keys;
    int cubeShards;
    int secretCubes;
    int collectedParts;
    int collectedOwls;
    int piecesOfHeart;
    List<Object<String>> maps;
    List<ActorType> artifacts;
    List<Object<String>> earnedAchievements;
    List<Object<String>> earnedGamerPictures;
    Object<String> scriptingState;
    bool fezHidden;
    Object<float> globalWaterLevelModifier;
    bool hasHadMapHelp;
    bool canOpenMap;
    bool achievementCheatCodeDone;
    bool anyCodeDeciphered;
    bool mapCheatCodeDone;
    List<KeyValuePair<Object<String>, LevelSaveData>> worlds;
    bool scoreDirty;
    bool hasDoneHeartReboot;
    long playTime;
    bool isNew;
} [[fixed_size(0xA000)]];

FezSaveFile saveFile @ 0x00;