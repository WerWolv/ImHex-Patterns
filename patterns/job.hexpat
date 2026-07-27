import std.mem;
import std.core;
import std.io;
import std.array;
import type.guid;

#pragma endian little
#pragma author shark 

fn fmt_hex(auto val) {
    return std::format("{:#x}", val);
};

enum PriorityFlags : u32 {
    NormalPriorityClass         = 0x00000020,
    IdlePriorityClass           = 0x00000040,
    HighPriorityClass           = 0x00000080,
    RealtimePriorityClass       = 0x00000100
};

enum TriggerFlags: u32 {
        TRIGGER_ONCE            = 0,
        TRIGGER_DAILY           = 1,
        TRIGGER_WEEKLY          = 2,
        TRIGGER_MONTHLYDATE     = 3,
        TRIGGER_MONTHLYDOW      = 4,
        TRIGGER_ON_IDLE         = 5,
        TRIGGER_AT_SYSTEMSTART  = 6,
        TRIGGER_AT_LOGON        = 7
};

enum WeekDay: u16 {
    Sunday = 0x0000,
    Monday = 0x0001,
    Tuesday = 0x0002,
    Wednesday = 0x0003,
    Thursday = 0x0004,
    Friday = 0x0005,
    Saturday = 0x0006
};

struct JobDate {
    u16 Year;
    u16 Month;
    WeekDay wday[[name("WeekDay")]];
    u16 Day;
    u16 Hour;
    u16 Minutes;
    u16 Seconds;
    u16 MilliSeconds;
};  

struct TriggerStructure {
    u16 TriggerSize;
    u16 Reserved1;
    u16 BeginYear;
    u16 BeginMonth;
    u16 BeginDay;
    u16 EndYear;
    u16 EndMonth;
    u16 EndDay;
    u16 StartHour;
    u16 StartMinutes;
    u32 MinuteDuration;
    u32 MinuteInterval;
    TriggerFlags Flags; 
    u32 TriggerType;
    u16 TriggerSpecific0;
    u16 TriggerSpecific1;
    u16 TriggerSpecific2;
    u16 Padding;
    u16 Reserved2;
    u16 Reserved3;


};

enum TaskStatus: u32 {
  // Success codes
    TaskReady                = 0x00041300,
    TaskRunning              = 0x00041301,
    TaskDisabled             = 0x00041302,
    TaskHasNotRun            = 0x00041303,
    TaskNoMoreRuns           = 0x00041304,
    TaskNotScheduled         = 0x00041305, 
    TaskTerminated           = 0x00041306,
    TaskNoValidTriggers      = 0x00041307,
    EventTrigger             = 0x00041308,
    SomeTriggersFailed       = 0x0004131B,
    BatchLogonProblem        = 0x0004131C,
    TaskQueued               = 0x00041325,

    // Error codes
    TriggerNotFound          = 0x80041309,
    TaskNotReady             = 0x8004130A,
    TaskNotRunning           = 0x8004130B,
    ServiceNotInstalled      = 0x8004130C,
    CannotOpenTask           = 0x8004130D,
    InvalidTask              = 0x8004130E,
    AccountInformationNotSet = 0x8004130F,
    AccountNameNotFound      = 0x80041310,
    AccountDatabaseCorrupt   = 0x80041311,
    NoSecurityServices       = 0x80041312,
    UnknownObjectVersion     = 0x80041313,
    UnsupportedAccountOption = 0x80041314,
    ServiceNotRunning        = 0x80041315,
    UnexpectedNode           = 0x80041316,
    Namespace                = 0x80041317,
    InvalidValue             = 0x80041318,
    MissingNode              = 0x80041319,
    MalformedXml             = 0x8004131A,
    TooManyNodes             = 0x8004131D,
    PastEndBoundary          = 0x8004131E,
    AlreadyRunning           = 0x8004131F,
    UserNotLoggedOn          = 0x80041320,
    InvalidTaskHash          = 0x80041321,
    ServiceNotAvailable      = 0x80041322,
    ServiceTooBusy           = 0x80041323,
    TaskAttempted            = 0x80041324,
    TaskDisabledError        = 0x80041326,
    TaskNotV1Compat          = 0x80041327,
    StartOnDemand            = 0x80041328,
    TaskNotUbpmCompat        = 0x80041329,
    DeprecatedFeatureUsed    = 0x80041330
};

enum TFlags: u16 {
    Interactive               = 0x0001,
    DeleteWhenDone            = 0x0002,
    Disabled                  = 0x0004,

    StartOnlyIfIdle           = 0x0010,
    KillOnIdleEnd             = 0x0020,
    DontStartIfOnBatteries    = 0x0040,
    KillIfGoingOnBatteries    = 0x0080,
    RunOnlyIfDocked           = 0x0100,
    Hidden                    = 0x0200,
    RunIfConnectedToInternet  = 0x0400,
    RestartOnIdleResume       = 0x0800,
    SystemRequired            = 0x1000,
    RunOnlyIfLoggedOn         = 0x2000
};

struct TaskFlagStruct {
    TFlags flags [[name("Flags")]];
    u16 Unkn[[attribute("hidden")]];
};

struct ReservedData {
    
    u16 Unknown1;
    u16 Unknown2;

    u16 tflags [[ name("Flags"),format("fmt_hex")]];
    u16 Reserved;
    
};

struct JobTask{
    u16 ProductVersion;
    u16 FileVersion;
    type::GUID guid[[name("TaskGUID")]];
    
    u16 ApplicationNameOffset;
    u16 TriggerOffset;

    u16 ErrorRetryCount;
    u16 ErrorRetryInterval;

    u16 IdleDeadLine;
    u16 IdleWait;
    PriorityFlags pf[[name("PriorityFlags")]];

    u32 MaxRunTime;
    u32 ExitCode;

    TaskStatus ts[[name("TaskStatus")]];
    TaskFlagStruct tflags[[name("TaskFlags")]];

    JobDate date[[name("Date")]];
    u16 Reserved;

    u16 BinaryPathLen;
    char16 BinaryPath[BinaryPathLen];
    u16 ArgsLen;
    char16 Args[ArgsLen];
    u16 WorkingDirLen;
    char16 WorkingDir[WorkingDirLen];
    u16 AuthorNameLen;
    char16 AuthorName[AuthorNameLen];
    u16 CommentLen;
    char16 Comment[CommentLen];
    u16 AppDataLen;
    char AppMetaData[AppDataLen];
    be u32 StartError[[format("fmt_hex")]];
    
    u32 flags[[name("TaskFlags")]];
    u32 Unknown1;
    TriggerStructure tgs[[name("TriggerData")]];
};

JobTask jtask @0x0;