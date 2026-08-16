import std.mem;
import std.core;
import std.io;
import type.guid;
import std.array;
import type.types.rust;

#pragma magic [50 53 4D 4F 44 55 4C 45 43 41 43 48 45] @ 0x00

#pragma array_limit 0x200000
#pragma loop_limit  0x100000

#pragma description PSModuleCacheFile (ModuleAnalysisCache)
#pragma author Sabhya (shark)

#define OneMilliSec  10000
#define OneSecond    10000000
#define OneMinute    600000000
#define OneHour      36000000000
#define OneDay       864000000000

#define DaysPerYear     365
#define DaysPer4Years   1461
#define DaysPer100Years 36524
#define DaysPer400Years 146097
#define DaysTo1970      719162


fn get_diff(auto a, auto b)  {
    return (a >= b) ? a-b : b-a ;
};

fn get_time(auto ticks, auto timeframe) {
    return ticks / timeframe;
};


fn fmt_ticks(auto ticks) {

    u32 exact_days = ticks / OneDay;
    u64 t_rem_days = ticks % OneDay; 
    u64 est_days = 0;

    u64 t_exact_days = exact_days;
    u32 t_calc_year = 0;

    u8 LeapYearMonths[12]   = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    u8 NormalYearMonths[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    while(t_exact_days > 0) {
        if (t_exact_days >= DaysTo1970) {
            t_calc_year += 1970;
            t_exact_days -= DaysTo1970;
        } else if (t_exact_days >= DaysPer400Years) {
            t_calc_year += 400;
            t_exact_days -= DaysPer400Years;
        } else if (t_exact_days >= DaysPer100Years) {
            t_calc_year += 100;
            t_exact_days -= DaysPer100Years;
        } else if (t_exact_days >= DaysPer4Years) {
            t_calc_year += 4;
            t_exact_days -= DaysPer4Years;
        } else if (t_exact_days >= DaysPerYear){
            t_calc_year += 1;
            t_exact_days -= DaysPerYear;
        } else {
            t_exact_days -= t_exact_days;
        }
    }

    u32 c_calc_year = t_calc_year;
    
    while(c_calc_year > 0) {
        if (c_calc_year >= 1970) {
            est_days += DaysTo1970;
            c_calc_year -= 1970;
        } else if ( c_calc_year >= 400) {
            est_days += DaysPer400Years;
            c_calc_year -= 400;
        } else if ( c_calc_year >= 100 ){
            est_days += DaysPer100Years;
            c_calc_year -= 100;
        } else if (c_calc_year >= 4){
            est_days += DaysPer4Years;
            c_calc_year -= 4;
        } else if ( c_calc_year >= 1){
            est_days += 365;
            c_calc_year -= 1;
        }
    }

    u32 current_year = t_calc_year ;

    bool is_leap = ((current_year % 4 == 0 && current_year % 100 != 0) || (current_year % 400 == 0));
    i32 diff_days = get_diff(exact_days, est_days);
    u32 month_idx = 0;
    while (month_idx < 12) {
        u8 month_days = is_leap ? LeapYearMonths[month_idx] : NormalYearMonths[month_idx];
        if (diff_days < month_days) {
            break; 
        }
        diff_days -= month_days;
        month_idx += 1;
    }

    u32 months = month_idx + 1;
    u32 days = diff_days + 1;

    u32 hours = get_time(t_rem_days, OneHour);
    t_rem_days = t_rem_days % OneHour;
    u32 minutes = get_time(t_rem_days, OneMinute);
    t_rem_days = t_rem_days % OneMinute;
    u32 seconds = get_time (t_rem_days, OneSecond);
    t_rem_days = t_rem_days % OneSecond;
    u32 milliseconds = get_time(t_rem_days,OneMilliSec);
    t_rem_days = t_rem_days % OneMilliSec;

    return std::format("{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}.{:03d}", current_year, months, days, hours, minutes, seconds, milliseconds);
};

enum CommandTypes:u32 {
    None            = 0x00000000,
    Alias           = 0x00000001,
    Function        = 0x00000002,
    Filter          = 0x00000004,
    CmdLet          = 0x00000008,
    ExternalScript  = 0x00000010,
    Application     = 0x00000020,
    Script          = 0x00000040,
    Workflow        = 0x00000080,
    Configuration   = 0x00000100,
    All             = 0x1ff
};

enum TypeAttributes: u32 {
        None = 0x00000000,
        Class = 0x00000001,
        Interface = 0x00000002,
        Enum      = 0x00000004
};

struct DateTime {
        u8 time[8];
};

struct ModuleCommandTypesStruct {
    u32 CmdLen;
    char CmdName[CmdLen];
    CommandTypes CmdType;
    std::print("\t\t{}\t\t{}", CmdType, CmdName);
};


struct ModuleTypeAttribStruct {
    u32 TypeLen;
    char TypeName[TypeLen];
    TypeAttributes TypeAttrib;
    std::print("\t\t{}\t\t{}", TypeAttrib, TypeName);
};


struct ModuleDetail {
        u64 date[[name("LastWriteTime"), format("fmt_ticks")]];
        u32 ModulePathLen;
        char ModulePath[ModulePathLen];
        std::print("{}", ModulePath);
        u32 CmdCounts;
        ModuleCommandTypesStruct Commands[CmdCounts];
        u32 LeftCmdCounts[[name("AdditionalTypesCounts")]];
        if (LeftCmdCounts != 0xffffffff) {
            ModuleTypeAttribStruct CmdLeft[LeftCmdCounts][[name("AdditionalTypes")]];
                    
        }
};


struct PSModuleCache {
        char header[13][[name("Header")]];
        if (header != "PSMODULECACHE") {
            return;
        }
        u8   version[[name("Version")]];
        u32  entries[[name("Entries")]];
        ModuleDetail mod[entries][[name("Modules")]];

};

PSModuleCache pscache @0x0[[name("PSModuleCache")]];