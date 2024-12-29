#pragma author andreasWallner
#pragma description STDFv4 (Standard Test Data Format)
#pragma pattern_limit 5000000

// Specification used: http://www.kanwoda.com/wp-content/uploads/2015/05/std-spec.pdf
// Example file used for testing: https://roos.com/docs/RBEH-AH4R8T?Open

import std.mem;
import std.time;
import std.sys;
import type.byte;
import std.io;

namespace format {
    fn epoch(auto epoch) {
        return std::format("{} ({})", std::time::format(std::time::to_local(epoch)), epoch);
    };
    fn absent_255(u8 x) {
        if (x == 255) {
            return "- absent - (255)";
        } else {
            return x;
        }
    };
    fn absent_neg_32768(s16 x) {
        if (x == -32768) {
            return "- absent - (-32768)";
        } else {
            return x;
        }
    };
    fn absent_65_535(u16 x) {
        if (x == 65535) {
            return "- absent - (65535)";
        } else {
            return x;
        }
    };
    fn absent_4_294_967_295(u32 x) {
        if (x == 4294967295) {
            return "- absent - (4,294,967,295)";
        } else {
            return x;
        }
    };
    fn absent_space(auto x) {
        if (x == ' ') {
            return "- absent - ( )";
        } else {
            return x;
        }
    };
    fn absent_0(auto x) {
        if (x == 0) {
            return "- absent - (0)";
        } else {
            return x;
        }
    };
    fn absent_1(auto x) {
        if (x == 1) {
            return "- absent - (1)";
        } else {
            return x;
        }
    };
}

fn format_VarLenStr(ref auto vls) {
    return std::format("\"{}\"", vls.string);
};
/// Variable length string (C*n in spec)
struct VarLenStr {
    u8 len;
    char string[len];
} [[format("format_VarLenStr")]];

fn format_VarLenBytes(ref auto vlb) {
    return vlb.bytes;
};
/// Variable length bytes string (D*n in spec)
struct VarLenBytes {
    u8 len;
    u8 bytes[len];
} [[format("format_VarLenBytes")]];

fn format_VarLenBits(ref auto vlb) {
    return std::format("{} valid bits", vlb.bitlen);
};
/// Variable length bit string (B*n in spec)
struct VarLenBits {
    u16 bitlen;
    u8 bits[bitlen/8];
};

fn format_VarLenNibbles(ref auto vln) {
    return vlb.n;
};
/// Variable length nibble array (kxN*1 in spec)
struct VarLenNibbles {
    u8 len;
    type::Nibbles n[(len+1)/2];
};

// See STDF V4, File Attributes Record, p.16
enum CpuType : u8 {
    PDP11_VAX = 0,
    SUN1234 = 1,
    IBM = 2,
};

struct Header {
    u16 REC_LEN;
    u8 REC_TYPE;
    u8 REC_SUB;
} [[static]];

struct UnknownRecord : Header {
    u8 data[REC_LEN];
};

// See STDF V4, File Attributes Record, p.16
struct FAR : Header {
    CpuType CPU_TYPE [[comment("CPU type that wrote this file")]];
    u8 STDF_VER [[comment("STDF version number")]];
} [[static]];

// See STDF V4, Audit Trail Record, p.17
struct ATR : Header {
    std::time::EpochTime MOD_TIM [[comment("Date and time of STDF file modification"), format("format::epoch")]];
    VarLenStr CMD_LINE [[comment("Command line of program")]];
};

// See STDF V4, Master Information Record, p.18
fn format_MODE_COD(char x) {
    match (x) {
        ('A'): return "AEL (Automatic Edge Lock) mode (A)";
        ('C'): return "Checker mode (C)";
        ('D'): return "Development/Debug test mode (D)";
        ('E'): return "Engineering mode (same as Development mode) (E)";
        ('M'): return "Maintenance mode (M)";
        ('P'): return "Production test mode (P)";
        ('Q'): return "Quality Control (Q)";
        (' '): return "- absent -";
        (_): return std::format("Unknown station mode: {}", x);
    }
};
fn format_RTST_COD(char x) {
    match (x) {
        ('Y'): return "Lot was previously tested (Y)";
        ('N'): return "Lot has not been previously tested (N)";
        (' '): return "Not known if lot has been previously tested";
        ('0' ... '9'): return std::format("Lot has been tested previously {} times", x);
        (_): return std::format("Unknown retest condition: {}", x);
    }
};
struct MIR : Header {
    auto start = $;
    std::time::EpochTime SETUP_T [[comment("Date and time of job setup"), format("format::epoch")]];
    std::time::EpochTime START_T [[comment("Date and time first part tested"), format("format::epoch")]];
    u8 STAT_NUM [[comment("Tester station number")]];
    char MODE_COD [[comment("Test mode code (e.g. prod, dev) (absent if 'space')"), format("format_MODE_COD")]];
    char RTST_COD [[comment("Lot retest code (absent if 'space')"), format("format_RTST_COD")]];
    char PROT_COD [[comment("Data protection code (absent if 'space')"), format("format::absent_space")]];
    u16 BURN_TIM [[comment("Burn-in time (in minutes) (absent if 65,535)"), format("format::absent_65_535")]];
    char CMOD_COD [[comment("Command mode code (absent if 'space')"), format("format::absent_space")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LOT_ID [[comment("Lot ID (customer specified)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PART_TYP [[comment("Part Type (or product ID)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr NODE_NAM [[comment("Name of node that generated data")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TSTR_TYP [[comment("Tester type")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr JOB_NAM [[comment("Job name (test program name)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr JOB_REV [[comment("Job (test program) revision number (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SBLOT_ID [[comment("Sublot ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr OPER_NAM [[comment("Operator name or ID (at setup time) (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXEC_TYP [[comment("Tester executive software type (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXEC_VER [[comment("Tester exec software version number (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_COD [[comment("Test phase or step code (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TST_TEMP [[comment("Test temperature (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr USER_TXT [[comment("Generic user text (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr AUX_FILE [[comment("Name of auxiliary data file (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PKG_TYP [[comment("Package type (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FAMLY_ID [[comment("Product family ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr DATE_COD [[comment("Date code (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FACIL_ID [[comment("Test facility ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FLOOR_ID [[comment("Test floor ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PROC_ID [[comment("Fabrication process ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr OPER_FRQ [[comment("Operation frequency or step (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SPEC_NAM [[comment("Test specification name (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SPEC_VER [[comment("Test specification version number (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FLOW_ID [[comment("Test flow ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SETUP_ID [[comment("Test setup ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr DSGN_REV [[comment("Device design revision (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr ENG_ID [[comment("Engineering lot ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr ROM_COD [[comment("ROM code ID (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SERL_NUM [[comment("Tester serial number (absent if length byte=0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SUPR_NAM [[comment("Supervisor name or ID (absent if length byte=0)")]];
};

// See STDF V4, Master Results Record, p.21
struct MRR : Header {
    auto start = $;
    std::time::EpochTime FINISH_T [[comment("Date and time of the last part tested"), format("format::epoch")]];
    if (($ - start) == REC_LEN) { return; }
    char DISP_COD[1] [[comment("Lot disposition code")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr USR_DESC [[comment("Lot description supplied by user")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXC_DESC [[comment("Lot description supplied by exec")]];
};

// See STDF V4, Part Count Record, p.22
fn format_HEAD_NUM(u8 x) {
    if (x == 255) {
        return std::format("all test sites (255)");
    } else {
        return x;
    }
};
struct PCR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number"), format("format_HEAD_NUM")]];
    u8 SITE_NUM [[comment("Test site number")]];
    if (($ - start) == REC_LEN) { return; }
    u32 PART_CNT [[comment("Number of parts tested (absent i 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 RTST_CNT [[comment("Number of parts retested (absent i 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 ABRT_CNT [[comment("Number of aborts during testing (absent i 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 GOOD_CNT [[comment("Number of good (passed) parts tested (absent i 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 FUNC_CNT [[comment("Number of functional parts tested (absent i 4,294,967,295)"), format("format::absent_4_294_967_295")]];
} [[static]];

// See STDF V4, Hardware Bin Record, p.23
enum HBRHbinPf : char {
    PASS = 'P',
    FAIL = 'F',
    UNKNOWN = ' '
};
struct HBR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number"), format("format_HEAD_NUM")]];
    u8 SITE_NUM [[comment("Test site number")]];
    u16 HBIN_NUM [[comment("Hardware bin number")]];
    u32 HBIN_CNT [[comment("Number of parts in bin")]];
    if (($ - start) == REC_LEN) { return; }
    HBRHbinPf HBIN_PF [[comment("Pass/fail indication (absent if 'space')")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr HBIN_NAM [[comment("Name of hardware bin (absent if length byte = 0)")]];
};

// See STDF V4, Software Bin Record, p.25
enum SBRSbinPf : char {
    PASS = 'P',
    FAIL = 'F',
    UNKNOWN = ' '
};
struct SBR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number"), format("format_HEAD_NUM")]];
    u8 SITE_NUM [[comment("Test site number")]];
    u16 SBIN_NUM [[comment("Software bin number")]];
    u32 SBIN_CNT [[comment("Number of parts in bin")]];
    if (($ - start) == REC_LEN) { return; }
    SBRSbinPf SBIN_PF [[comment("Pass/fail indication (absent if 'space')")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SBIN_NAM [[comment("Name of software bin (absent if length byte = 0)")]];
};

// See STDF V4, Pin Map Record, p.27
fn format_PMR_HEAD_NUM(u8 x) {
    if (x == 1) {
        return "Unidentified (1)";
    } else {
        return x;
    }
};
struct PMR : Header {
    auto start = $;
    u16 PMR_INDX [[comment("Unique index associated with pin")]];
    if (($ - start) == REC_LEN) { return; }
    u16 CHAN_TYP [[comment("Channel type (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CHAN_NAM [[comment("Channel name (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PHY_NAM [[comment("Physical name of pin (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LOG_NAM [[comment("Logical name of pin (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    u8 HEAD_NUM [[comment("Head number associated with channel (absent if 1)"), format("format_PMR_HEAD_NUM")]];
    if (($ - start) == REC_LEN) { return; }
    u8 SITE_NUM [[comment("Site number associated with channel (absent if 1)"), format("format::absent_1")]];
};

// See STDF V4, Pin Group Record, p.29
struct PGR : Header {
    auto start = $;
    u16 GRP_INDX [[comment("Unique index associated with pin group")]];
    VarLenStr GRP_NAM [[comment("Name of pin group (absent if length byte = 0)")]];
    u16 INDX_CNT [[comment("Count (k) of PMR indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u16 PMR_INDX[INDX_CNT] [[comment("Array of indexes for pins in the group (absent if INDX_CNT = 0)")]];
};

// See STDF V4, Pin List Record, p.30
fn format_PLR_GRP_MODE(u16 x) {
    match (x) {
        (0): return "Unknown";
        (10): return "Normal";
        (20): return "SCIO (Same Cycle I/O)";
        (21): return "SCIO Midband";
        (22): return "SCIO Valid";
        (23): return "SCIO Window Sustain";
        (30): return "Dual drive (two drive bits per cycle)";
        (31): return "Dual drive Midband";
        (32): return "Dual drive Valid";
        (33): return "Dual drive Window Sustain";
        (32767 ... 65535): return std::format("Customer specific use ({})", x);
        (_): return std::format("RFU ({})", x);
    }
};
enum PLRGrpRadx : u8 {
    DEFAULT = 0,
    BINARY = 2,
    OCTAL = 8,
    DECIMAL = 10,
    HEX = 16,
    SYMBOLIC = 20
};
struct PLR : Header {
    auto start = $;
    u16 GRP_CNT [[comment("Count (k) of pins or pin groups")]];
    if (($ - start) == REC_LEN) { return; }
    u16 GRP_INDX[GRP_CNT] [[comment("Array of pin or pin group indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u16 GRP_MODE[GRP_CNT] [[comment("Operating mode of pin group (absent if 0)"), format("format_PLR_GRP_MODE")]];
    if (($ - start) == REC_LEN) { return; }
    PLRGrpRadx GRP_RADX[GRP_CNT] [[comment("Display radix of pin group (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PGM_CHAR[GRP_CNT] [[comment("Program state encoding characters (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr RTN_CHAR[GRP_CNT] [[comment("Return state encoding characters (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PGM_CHAL[GRP_CNT] [[comment("Program state encoding characters (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr RTN_CHAL[GRP_CNT] [[comment("Return state encoding characters (absent if length byte = 0)")]];
};

// See STDF V4, Retest Data Record, p.32
struct RDR : Header {
    auto start = $;
    u16 NUM_BINS [[comment("Number (k) of bins being retested")]];
    if (($ - start) == REC_LEN) { return; }
    u16 RTST_BIN[NUM_BINS] [[comment("Array of retest bin numbers (absent if NUM_BINS = 0)")]];
} [[static]];

// See STDF V4, Site Description Record, p.33
struct SDR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_GRP [[comment("Site group number")]];
    u8 SITE_CNT [[comment("Number (k) of test sites in site group")]];
    u8 SITE_NUM[SITE_CNT] [[comment("Array of test site numbers")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr HAND_TYP [[comment("Handler or prober type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr HAND_ID [[comment("Handler or prober ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CARD_TYP [[comment("Probe card type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CARD_ID [[comment("Probe card ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LOAD_TYP [[comment("Load board type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LOAD_ID [[comment("Load board ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr DIB_TYP [[comment("DIB board type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr DIB_ID [[comment("DIB board ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CABL_TYP [[comment("Interface cable type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CABL_ID [[comment("Interface cable ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CONT_TYP [[comment("Handler contactor type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr CONT_ID [[comment("Handler contactor ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LASR_TYP [[comment("Laser type (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr LASR_ID [[comment("Laser ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXTR_TYP [[comment("Extra equipment type field (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXTR_ID [[comment("Extra equipment ID (absent if length byte = 0)")]];
};

// See STDF V4, Wafer Information Record, p.25
fn format_WIR_SITE_GRP(u8 x) {
    if (x == 255) {
        return "Unknown or unsupported (255)";
    } else {
        return x;
    }
};
struct WIR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_GRP [[comment("Site group number (absent if '255')"), format("format_WIR_SITE_GRP")]];
    u32 START_T [[comment("Date and time first part tested")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr WAFER_ID [[comment("Wafer ID (absent if length byte = 0)")]];
};

// See STDF V4, Wafer Results Record, p.36
struct WRR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_GRP [[comment("Site group number (absent if '255')"), format("format::absent_255")]];
    u32 FINISH_T [[comment("Date and time last part tested")]];
    u32 PART_CNT [[comment("Number of parts tested")]];
    if (($ - start) == REC_LEN) { return; }
    u32 RTST_CNT [[comment("Number of parts retested (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 ABRT_CNT [[comment("Number of aborts during testing (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 GOOD_CNT [[comment("Number of good (passed) parts tested (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 FUNC_CNT [[comment("Number of functional parts tested (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr WAFER_ID [[comment("Wafer ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FABWF_ID [[comment("Fab wafer ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr FRAME_ID [[comment("Wafer frame ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr MASK_ID [[comment("Wafer mask ID (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr USR_DESC [[comment("Wafer description supplied by user (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr EXC_DESC [[comment("Wafer description supplied by exec (absent if length byte = 0)")]];
};

// See STDF V4, Wafer Configuration Record, p.38
enum WCRWfUnits : u8 {
    Unknown = 0,
    INCH = 1,
    CM = 2,
    MM = 3,
    MIL = 4,
};
enum WCRWfFlat : char {
    UP = 'U',
    DOWN = 'D',
    LEFT = 'L',
    RIGHT = 'R',
    UNKNOWN = ' '
};
enum WCRPosX : char {
    LEFT = 'L',
    RIGHT = 'R',
    UNKNOWN = ' '
};
enum WCRPosY : char {
    UP = 'U',
    DOWN = 'D',
    UNKNOWN = ' '
};
struct WCR : Header {
    auto start = $;
    if (($ - start) == REC_LEN) { return; }
    float WAFR_SIZ [[comment("Diameter of wafer in WF_UNITS (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    float DIE_HT [[comment("Height of die in WF_UNITS (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    float DIE_WID [[comment("Width of die in WF_UNITS (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    WCRWfUnits WF_UNITS [[comment("Units for wafer and die dimensions (absent if 0)"), format("format::absent_0")]];
    if (($ - start) == REC_LEN) { return; }
    WCRWfFlat WF_FLAT [[comment("Orientation of wafer flat (absent if 'space')"), format("format::absent_space")]];
    if (($ - start) == REC_LEN) { return; }
    s16 CENTER_X [[comment("X coordinate of center die on wafer (invalid if -32768"), format("format::absent_neg_32768")]];
    if (($ - start) == REC_LEN) { return; }
    s16 CENTER_Y [[comment("Y coordinate of center die on wafer (invalid if -32768"), format("format::absent_neg_32768")]];
    if (($ - start) == REC_LEN) { return; }
    WCRPosX POS_X [[comment("Positive X direction of wafer (absent if 'space')"), format("format::absent_space")]];
    if (($ - start) == REC_LEN) { return; }
    WCRPosY POS_Y [[comment("Positive Y direction of wafer (absent if 'space')"), format("format::absent_space")]];
} [[static]];

// See STDF V4, Part Information Record, p.40
fn format_PIR_PRR_x_NUM(u8 x) {
    if (x == 1) {
        return "No parallel testing or no test site/head identification";
    } else {
        return x;
    }
};
struct PIR : Header {
    u8 HEAD_NUM [[comment("Test head number"), format("format_PIR_PRR_x_NUM")]];
    u8 SITE_NUM [[comment("Test site number"), format("format_PIR_PRR_x_NUM")]];
} [[static]];

// See STDF V4, Part Results Record, p.41
bitfield PRRPartFlg {
    supersedes_prev_same_part_id: 1 [[comment("0 = This is a new part. Its data device does not supersede that of any previous device.\n\n1 = The PIR, PTR, MPR, FTR, and PRR records that make up the current sequence (identified as having the same HEAD_NUM and SITE_NUM) supersede any previous sequence of records with the same PART_ID. (A repeated part sequence usually indicates a mistested part.)")]];
    supersedes_prev_same_xy: 1 [[comment("0 = This is a new part. Its data device does not supersede that of any previous device.\n\n1 = The PIR, PTR, MPR, FTR, and PRR records that make up the current sequence (identified as having the same HEAD_NUM and SITE_NUM) supersede any previous sequence of records with the same X_COORD and Y_COORD. (A repeated part sequence usually indicates a mistested part.)")]];
    abnormal_test_end: 1 [[comment("0 = Part testing completed normally\n\n1 = Abnormal end of testing")]];
    part_failed: 1 [[comment("0 = Part passed\n\n1 = Part failed")]];
    no_pass_fail: 1 [[comment("0 = Pass/fail flag (bit 3) is valid\n\n1 = Device completed testing with no pass/fail indication (i.e., bit 3 is invalid)")]];
};  
struct PRR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number"), format("format_PIR_PRR_x_NUM")]];
    u8 SITE_NUM [[comment("Test site number"), format("format_PIR_PRR_x_NUM")]];
    PRRPartFlg PART_FLG [[comment("Part information flag")]];
    u16 NUM_TEST [[comment("Number of tests executed")]];
    u16 HARD_BIN [[comment("Hardware bin number")]];
    if (($ - start) == REC_LEN) { return; }
    u16 SOFT_BIN [[comment("Software bin number (absent if 65535)"), format("format::absent_65_535")]];
    if (($ - start) == REC_LEN) { return; }
    s16 X_COORD [[comment("(Wafer) X coordinate (absent if -32768"), format("format::absent_neg_32768")]];
    if (($ - start) == REC_LEN) { return; }
    s16 Y_COORD [[comment("(Wafer) Y coordinate (absent if -32768"), format("format::absent_neg_32768")]];
    if (($ - start) == REC_LEN) { return; }
    u32 TEST_T [[comment("Elapsed test time in milliseconds 0")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PART_ID [[comment("Part identification (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PART_TXT [[comment("Part description text (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    type::Nibbles PART_FIX [[comment("Part repair information (absent if length byte = 0)")]];
};

// See STDF V4, Test Synopsis Record, p.43
fn format_TSR_HEAD_NUM(u8 x) {
    if (x == 255) {
        return "Summary for all test sites";
    } else {
        return x;
    }
};
enum TSRTestTyp : char {
    PARAMETRIC = 'P',
    FUNCTIONAL = 'F',
    MULTIPLE_RESULT = 'M',
    UNKNOWN = ' ',
};
bitfield TSROptFlag {
    TEST_MIN_invalid: 1;
    TEST_MAX_invalid: 1;
    TEST_TIM_invalid: 1;
    padding: 1;
    TST_SUMS_invalid: 1;
    TST_SQRS_invalid: 1;
    padding: 2;
};
struct TSR : Header {
    auto start = $;
    u8 HEAD_NUM [[comment("Test head number See note"), format("format_TSR_HEAD_NUM")]];
    u8 SITE_NUM [[comment("Test site number")]];
    TSRTestTyp TEST_TYP [[comment("Test type (absent if 'space')"), format("format::absent_space")]];
    u32 TEST_NUM [[comment("Test number")]];
    if (($ - start) == REC_LEN) { return; }
    u32 EXEC_CNT [[comment("Number of test executions (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 FAIL_CNT [[comment("Number of test failures (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    u32 ALRM_CNT [[comment("Number of alarmed tests (absent if 4,294,967,295)"), format("format::absent_4_294_967_295")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_NAM [[comment("Test name (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr SEQ_NAME [[comment("Sequencer (program segment/flow) name (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_LBL [[comment("Test label or text (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    TSROptFlag OPT_FLAG [[comment("Optional data flag")]];
    if (($ - start) == REC_LEN) { return; }
    float TEST_TIM [[comment("Average test execution time in seconds (invalid if OPT_FLAG bit 2 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float TEST_MIN [[comment("Lowest test result value (invalid if OPT_FLAG bit 0 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float TEST_MAX [[comment("Highest test result value (invalid if OPT_FLAG bit 1 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float TST_SUMS [[comment("Sum of test result values (invalid if OPT_FLAG bit 4 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float TST_SQRS [[comment("Sum of squares of test result values (invalid if OPT_FLAG bit 5 = 1)")]];
};

// See STDF V4, Parametric Test Record, p.45
bitfield PTRTestFlg {
    alarm: 1 [[comment("0 = No alarm\n\n1 = Alarm detected during testing")]];
    result_valid: 1 [[comment("0 = The value in the RESULT field is valid (see note on RESULT)\n\n1 = The value in the RESULT field is not valid. This setting indicates that the test was executed, but no datalogged value was taken. You should read bits 6 and 7 of TEST_FLG to determine if the test passed or failed.")]];
    unreliable: 1 [[comment("0 = Test result is reliable\n\n1 = Test result is unreliable")]];
    timeout: 1 [[comment(" 0 = No timeout\n\n1 = Timeout occurred")]];
    executed: 1 [[comment("0 = Test was executed\n\n1 = Test not executed")]];
    aborted: 1 [[comment("0 = No abort\n\n1 = Test aborted")]];
    pass_fail_valid: 1 [[comment("0 = Pass/fail flag (bit 7) is valid\n\n1 = Test completed with no pass/fail indication")]];
    failed: 1 [[comment("0 = Test passed\n\n1 = Test failed")]];
} [[static]];
bitfield ParamFlg {
    scale_error: 1 [[comment("0 = No scale error\n\n1 = Scale error")]];
    drift_error: 1 [[comment("0 = No drift error\n\n1 = Drift error (unstable measurement)")]];
    oscillation_detected: 1 [[comment("0 = No oscillation\n\n1 = Oscillation detected")]];
    gt_test_limit: 1 [[comment("0 = Measured value not high\n\n1 = Measured value higher than high test limit")]];
    lt_test_limit: 1 [[comment("0 = Measured value not low\n\n1 = Measured value lower than low test limit")]];
    passed_alternate_limits: 1 [[comment("0 = Test failed or test passed standard limits\n\n1 = Test passed alternate limits")]];
    eq_low_is_pass: 1 [[comment("0 = If result = low limit, then result is “fail.”\n\n1 = If result = low limit, then result is “pass.”")]];
    eq_high_is_pass: 1 [[comment("0 = If result = high limit, then result is “fail.”\n\n1 = If result = high limit, then result is “pass.”")]];
} [[static]];
bitfield PTROptFlag {
    res_scal_invalid: 1 [[comment("set = RES_SCAL value is invalid. The default set by the first PTR with this test number will be used.")]];
    padding: 1;
    no_lo_spec_limit: 1 [[comment("set = No low specification limit.")]];
    no_hi_spec_limit: 1 [[comment("set = No high specification limit.")]];
    lo_limit_llm_scal_invalid: 1 [[comment("set = LO_LIMIT and LLM_SCAL are invalid. The default values set for these fields in the first PTR with this test number will be used.")]];
    hi_limit_hlm_scal_invalid: 1 [[comment("set = HI_LIMIT and HLM_SCAL are invalid. The default values set for these fields in the first PTR with this test number will be used.")]];
    no_low_limit: 1 [[comment("No Low Limit for this test (LO_LIMIT and LLM_SCAL are invalid).")]];
    no_high_limit: 1 [[comment("No High Limit for this test (HI_LIMIT and HLM_SCAL are invalid).")]];
} [[static]];
struct PTR : Header {
    u64 start = $;
    u32 TEST_NUM [[comment("Test number")]];
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_NUM [[comment("Test site number")]];
    PTRTestFlg TEST_FLG [[comment("Test flags (fail, alarm, etc.)")]];
    ParamFlg PARM_FLG [[comment("Parametric test flags (drift, etc.)")]];
    if (($ - start) == REC_LEN) { return; }
    float RESULT [[comment("Test result (only valid if TEST_FLG bit 1 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_TXT [[comment("Test description text or label (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr ALARM_ID [[comment("Name of alarm (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    PTROptFlag OPT_FLAG [[comment("Optional data flag See note")]];
    if (($ - start) == REC_LEN) { return; }
    s8 RES_SCAL [[comment("Test results scaling exponent (invalid if OPT_FLAG bit 0 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s8 LLM_SCAL [[comment("Low limit scaling exponent (invalid if OPT_FLAG bit 4 or 6 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s8 HLM_SCAL [[comment("High limit scaling exponent (invalid if OPT_FLAG bit 5 or 7 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float LO_LIMIT [[comment("Low test limit value (invalid if OPT_FLAG bit 4 or 6 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float HI_LIMIT [[comment("High test limit value (invalid if OPT_FLAG bit 5 or 7 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr UNITS [[comment("Test units (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_RESFMT [[comment("ANSI C result format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_LLMFMT [[comment("ANSI C low limit format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_HLMFMT [[comment("ANSI C high limit format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    float LO_SPEC [[comment("Low specification limit value (invalid if OPT_FLAG bit 2 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float HI_SPEC [[comment("High specification limit value (invalid if OPT_FLAG bit 3 = 1)")]];
};

// See STDF V4, Multiple-Result Parametric Record, p.51
bitfield MPR_FTR_TestFlg {
    alarm: 1 [[comment("0 = No alarm\n\n1 = Alarm detected during testing")]];
    padding: 1;
    results_unreliable: 1 [[comment("0 = Test results are reliable\n\n1 = Test results are unreliable")]];
    timeout: 1 [[comment("0 = No timeout\n\n1 = Timeout occurred")]];
    test_not_executed: 1 [[comment("0 = Test was executed\n\n1 = Test not executed")]];
    test_aborted: 1 [[comment("0 = No abort\n\n1 = Test aborted")]];
    completed_no_pass_fail: 1 [[comment("0 = Pass/fail flag (bit 7) is valid\n\n1 = Test completed with no pass/fail indication")]];
    test_failed: 1 [[comment("0 = Test passed\n\n1 = Test failed")]];
} [[static]];
bitfield MPROptFlag {
    res_scal_invalid: 1 [[comment("set = RES_SCAL value is invalid. The default set by the first MPR with this test number will be used.")]];
    start_incr_in_incr_invalid: 1 [[comment("set = START_IN and INCR_IN are invalid.")]];
    no_lo_spec_limit: 1 [[comment("set = No low specification limit.")]];
    no_hi_spec_limit: 1 [[comment("set = No high specification limit.")]];
    lo_limit_llm_scal_invalid: 1 [[comment("set = LO_LIMIT and LLM_SCAL are invalid. The default values set for these fields in the first MPR with this test number will be used.")]];
    hi_limit_hlm_scal_invalid: 1 [[comment("set = HI_LIMIT and HLM_SCAL are invalid. The default values set for these fields in the first MPR with this test number will be used.")]];
    no_lo_limit: 1 [[comment("set = No Low Limit for this test (LO_LIMIT and LLM_SCAL are invalid).")]];
    no_hi_limit: 1 [[comment("set = No High Limit for this test (HI_LIMIT and HLM_SCAL are invalid).")]];
} [[static]];
struct MPR : Header {
    auto start = $;
    u32 TEST_NUM [[comment("Test number")]];
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_NUM [[comment("Test site number")]];
    MPR_FTR_TestFlg TEST_FLG [[comment("Test flags (fail, alarm, etc.)")]];
    ParamFlg PARM_FLG [[comment("Parametric test flags (drift, etc.)")]];
    u16 RTN_ICNT [[comment("Count (j) of PMR indexes")]];
    u16 RSLT_CNT [[comment("Count (k) of returned results")]];
    if (($ - start) == REC_LEN) { return; }
    type::Nibbles RTN_STAT[(RTN_ICNT+1)/2] [[comment("Array of returned states (absent if RTN_ICNT = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    float RTN_RSLT[RSLT_CNT] [[comment("Array of returned results (absent if RSLT_CNT = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_TXT [[comment("Descriptive text or label (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr ALARM_ID [[comment("Name of alarm (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    MPROptFlag OPT_FLAG [[comment("Optional data flag")]];
    if (($ - start) == REC_LEN) { return; }
    s8 RES_SCAL [[comment("Test result scaling exponent (absent if OPT_FLAG bit 0 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s8 LLM_SCAL [[comment("Test low limit scaling exponent (absent if OPT_FLAG bit 4 or 6 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s8 HLM_SCAL [[comment("Test high limit scaling exponent (absent if OPT_FLAG bit 5 or 7 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float LO_LIMIT [[comment("Test low limit value (absent if OPT_FLAG bit 4 or 6 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float HI_LIMIT [[comment("Test high limit value (absent if OPT_FLAG bit 5 or 7 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float START_IN [[comment("Starting input value (condition) (absent if OPT_FLAG bit 1 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float INCR_IN [[comment("Increment of input condition (absent if OPT_FLAG bit 1 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    u16 RTN_INDX[RTN_ICNT] [[comment("Array of PMR indexes")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr UNITS [[comment("Units of returned results (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr UNITS_IN [[comment("Input condition units (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_RESFMT [[comment("ANSI C result format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_LLMFMT [[comment("ANSI C low limit format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr C_HLMFMT [[comment("ANSI C high limit format string (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    float LO_SPEC [[comment("Low specification limit value (absent if OPT_FLAG bit 2 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    float HI_SPEC [[comment("High specification limit value (absent if OPT_FLAG bit 3 = 1)")]];
};

// See STDF V4, Functional Test Record, p.55
bitfield FTROptFlag {
    CYCL_CNT_invalid: 1 [[comment("set = CYCL_CNT data is invalid")]];
    REL_VADR_invalid: 1 [[comment("set = REL_VADR data is invalid")]];
    REPT_CNT_invalid: 1 [[comment("set = REPT_CNT data is invalid")]];
    NUM_FAIL_invalid: 1 [[comment("set = NUM_FAIL data is invalid")]];
    XFAIL_AD_YFAIL_AD_invalid: 1 [[comment("set = XFAIL_AD and YFAIL_AD data are invalid")]];
    VECT_OFF_invalid: 1 [[comment("set = VECT_OFF data is invalid (offset defaults to 0)")]];
    padding: 2;
} [[static]];
struct FTR : Header {
    auto start = $;
    u32 TEST_NUM [[comment("Test number")]];
    u8 HEAD_NUM [[comment("Test head number")]];
    u8 SITE_NUM [[comment("Test site number")]];
    MPR_FTR_TestFlg TEST_FLG [[comment("Test flags (fail, alarm, etc.)")]];
    if (($ - start) == REC_LEN) { return; }
    FTROptFlag OPT_FLAG [[comment("Optional data flag")]];
    if (($ - start) == REC_LEN) { return; }
    u32 CYCL_CNT [[comment("Cycle count of vector (absent if OPT_FLAG bit 0 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    u32 REL_VADR [[comment("Relative vector address (absent if OPT_FLAG bit 1 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    u32 REPT_CNT [[comment("Repeat count of vector (absent if OPT_FLAG bit 2 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    u32 NUM_FAIL [[comment("Number of pins with 1 or more failures (absent if OPT_FLAG bit 3 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s32 XFAIL_AD [[comment("X logical device failure address (absent if OPT_FLAG bit 4 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s32 YFAIL_AD [[comment("Y logical device failure address (absent if OPT_FLAG bit 4 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    s16 VECT_OFF [[comment("Offset from vector of interest (absent if OPT_FLAG bit 5 = 1)")]];
    if (($ - start) == REC_LEN) { return; }
    u16 RTN_ICNT [[comment("Count (j) of return data PMR indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u16 PGM_ICNT [[comment("Count (k) of programmed state indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u16 RTN_INDX[RTN_ICNT] [[comment("Array of return data PMR indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u8 RTN_STAT[(RTN_ICNT+1)/2] [[comment("Array of returned states\n\n0 = 0 or low\n1 = 1 or high\n2 = midband\n3 = glitch\n4 = undetermined\n5 = failed low\n6 = failed high\n7 = failed midband\n8 = failed with a glitch\n9 = open\nA = short")]];
    if (($ - start) == REC_LEN) { return; }
    u16 PGM_INDX[PGM_ICNT] [[comment("Array of programmed state indexes")]];
    if (($ - start) == REC_LEN) { return; }
    u8 PGM_STAT[(PGM_ICNT+1)/2] [[comment("Array of programmed states")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenNibbles FAIL_PIN [[comment("Failing pin bitfield (absent if length bytes = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr VECT_NAM [[comment("Vector module pattern name (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TIME_SET [[comment("Time set name (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr OP_CODE [[comment("Vector Op Code (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr TEST_TXT [[comment("Descriptive text or label (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr ALARM_ID [[comment("Name of alarm (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr PROG_TXT [[comment("Additional programmed information (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenStr RSLT_TXT [[comment("Additional result information (absent if length byte = 0)")]];
    if (($ - start) == REC_LEN) { return; }
    u8 PATG_NUM [[comment("Pattern generator number (absent if 255)"), format("format::absent_255")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenNibbles SPIN_MAP [[comment("Bit map of enabled comparators (absent if length byte = 0)")]];
};

// See STDF V4, Begin Program Record, p.60
struct BPS : Header {
    VarLenStr SEQ_NAME [[comment("Program section (or sequencer) name (absent if length byte = 0)")]];
};

// See STDF V4, End Program Section Record, p.61
struct EPS : Header {} [[static]];

// See STDF V4, Generic Data Record, p.62
enum GenDataType : u8 {
    PAD = 0,
    U1 = 1,
    U2 = 2,
    U4 = 3,
    I1 = 4,
    I2 = 5,
    I4 = 6,
    R4 = 7,
    R8 = 8,
    Cn = 10,
    Bn = 11,
    Dn = 12,
    N1 = 13,
} [[static]];
struct GenData {
    u8 type;
    match (type) {
        (GenDataType::PAD): return;
        (GenDataType::U1): u8 data;
        (GenDataType::U2): u16 data;
        (GenDataType::U4): u32 data;
        (GenDataType::I1): s8 data;
        (GenDataType::I2): s16 data;
        (GenDataType::I4): s32 data;
        (GenDataType::R4): float data;
        (GenDataType::R8): double data;
        (GenDataType::Cn): VarLenStr data;
        (GenDataType::Bn): VarLenBytes data;
        (GenDataType::Dn): VarLenBits data;
        (GenDataType::N1): type::Nibbles data;
    }
};
    
struct GDR : Header {
    auto start = $;
    u16 FLD_CNT [[comment("Count of data fields in record")]];
    if (($ - start) == REC_LEN) { return; }
    VarLenBytes GEN_DATA [[comment("Data type code and data for one field")]];
};

// See STDF V4, Datalog Text Record, p.64
struct DTR : Header {
    VarLenStr TEXT_DAT [[comment("ASCII text string")]];
};

struct Record {
    u64 start = $;
    Header hh [[hidden, no_unique_address]];
    match (hh.REC_TYPE, hh.REC_SUB) {
        (0, 10): FAR FAR [[comment("Contains the information necessary to determine how to decode the STDF data contained in the file.")]];
        (0, 20): ATR ATR [[comment("Used to record any operation that alters the contents of the STDF file. The name of the program and all its parameters should be recorded in the ASCII field provided in this record. Typically, this record will be used to track filter programs that have been applied to the data.")]];
        (1, 10): MIR MIR [[comment("The MIR and the MRR (Master Results Record) contain all the global information that is to be stored for a tested lot of parts. Each data stream must have exactly one MIR, immediately after the FAR (and the ATRs, if they are used). This will allow any data reporting or analysis programs access to this information in the shortest possible amount of time.")]];
        (1, 20): MRR MRR [[comment("The Master Results Record (MRR) is a logical extension of the Master Information Record (MIR). The data can be thought of as belonging with the MIR, but it is not available when the tester writes the MIR information. Each data stream must have exactly one MRR as the last record in the data stream.")]];
        (1, 30): PCR PCR [[comment("Contains the part count totals for one or all test sites. Each data stream must have at least one PCR to show the part count.")]];
        (1, 40): HBR HBR [[comment("Stores a count of the parts “physically” placed in a particular bin after testing. (In wafer testing, “physical” binning is not an actual transfer of the chip, but rather is represented by a drop of ink or an entry in a wafer map file.) This bin count can be for a single test site (when parallel testing) or a total for all test sites. The STDF specification also supports a Software Bin Record (SBR) for logical binning categories. A part is “physically” placed in a hardware bin after testing. A part can be “logically” associated with a software bin during or after testing.")]];
        (1, 50): SBR SBR [[comment("Stores a count of the parts associated with a particular logical bin after testing. This bin count can be for a single test site (when parallel testing) or a total for all test sites. The STDF specification also supports a Hardware Bin Record (HBR) for actual physical binning. A part is “physically” placed in a hardware bin after testing. A part can be “logically” associated with a software bin during or after testing.")]];
        (1, 60): PMR PMR [[comment("Provides indexing of tester channel names, and maps them to physical and logical pin names. Each PMR defines the information for a single channel/pin combination.")]];
        (1, 62): PGR PGR [[comment("Associates a name with a group of pins.")]];
        (1, 63): PLR PLR [[comment("Defines the current display radix and operating mode for a pin or pin group.")]];
        (1, 70): RDR RDR [[comment("Signals that the data in this STDF file is for retested parts. The data in this record, combined with information in the MIR, tells data filtering programs what data to replace when processing retest data.")]];
        (1, 80): SDR SDR [[comment("Contains the configuration information for one or more test sites, connected to one test head, that compose a site group.")]];
        (2, 10): WIR WIR [[comment("Acts mainly as a marker to indicate where testing of a particular wafer begins for each wafer tested by the job plan. The WIR and the Wafer Results Record (WRR) bracket all the stored information pertaining to one tested wafer. This record is used only when testing at wafer probe. A WIR/WRR pair will have the same HEAD_NUM and SITE_GRP values.")]];
        (2, 20): WRR WRR [[comment("Contains the result information relating to each wafer tested by the job plan. The WRR and the Wafer Information Record (WIR) bracket all the stored information pertaining to one tested wafer. This record is used only when testing at wafer probe time. A WIR/WRR pair will have the same HEAD_NUM and SITE_GRP values.")]];
        (2, 30): WCR WCR [[comment("Contains the configuration information for the wafers tested by the job plan. The WCR provides the dimensions and orientation information for all wafers and dice in the lot. This record is used only when testing at wafer probe time.")]];
        (5, 10): PIR PIR [[comment("Acts as a marker to indicate where testing of a particular part begins for each part tested by the test program. The PIR and the Part Results Record (PRR) bracket all the stored information pertaining to one tested part.")]];
        (5, 20): PRR PRR [[comment("Contains the result information relating to each part tested by the test program. The PRR and the Part Information Record (PIR) bracket all the stored information pertaining to one tested part.")]];
        (10, 30): TSR TSR [[comment("Contains the test execution and failure counts for one parametric or functional test in the test program. Also contains static information, such as test name. The TSR is related to the Functional Test Record (FTR), the Parametric Test Record (PTR), and the Multiple Parametric Test Record (MPR) by test number, head number, and site number.")]];
        (15, 10): PTR PTR [[comment("Contains the results of a single execution of a parametric test in the test program. The first occurrence of this record also establishes the default values for all semi-static information about the test, such as limits, units, and scaling. The PTR is related to the Test Synopsis Record (TSR) by test number, head number, and site number.")]];
        (15, 15): MPR MPR [[comment("Contains the results of a single execution of a parametric test in the test program where that test returns multiple values. The first occurrence of this record also establishes the default values for all semi-static information about the test, such as limits, units, and scaling. The MPR is related to the Test Synopsis Record (TSR) by test number, head number, and site number.")]];
        (15, 20): FTR FTR [[comment("Contains the results of the single execution of a functional test in the test program. The first occurrence of this record also establishes the default values for all semi-static information about the test. The FTR is related to the Test Synopsis Record (TSR) by test number, head number, and site number.")]];
        (20, 10): BPS BPS [[comment("Marks the beginning of a new program section (or sequencer) in the job plan.")]];
        (20, 20): EPS EPS [[comment("Marks the end of the current program section (or sequencer) in the job plan.")]];
        (50, 10): GDR GDR [[comment("Contains information that does not conform to any other record type defined by the STDF specification. Such records are intended to be written under the control of job plans executing on the tester. This data may be used for any purpose that the user desires.")]];
        (50, 30): DTR DTR [[comment("Contains text information that is to be included in the datalog printout. DTRs may be written under the control of a job plan: for example, to highlight unexpected test results. They may also be generated by the tester executive software: for example, to indicate that the datalog sampling rate has changed. DTRs are placed as comments in the datalog listing.")]];
        
        (_, _): UnknownRecord;
    }
    std::assert($ == (start + hh.REC_LEN + 4), std::format("Inconsistent record size at offset {}", start));
};

struct STDF {
    le FAR far_try [[hidden, no_unique_address]];
    if (far_try.REC_LEN == 0x0002 && far_try.REC_TYPE == 0 && far_try.REC_SUB == 10 && far_try.CPU_TYPE == CpuType::IBM) {
        std::core::set_endian(std::mem::Endian::Little);
    } else if(far_try.REC_LEN == 0x0200 && far_try.REC_TYPE == 0 && far_try.REC_SUB == 10 && far_try.CPU_TYPE == CpuType::SUN1234) {
        std::core::set_endian(std::mem::Endian::Big);
    } else if(far_try.REC_LEN == 0x01200 && far_try.REC_TYPE == 0 && far_try.REC_SUB == 10 && far_try.CPU_TYPE == CpuType::PDP11_VAX) {
        std::error("Mixed endianess of PDP11 / VAX not supported");
    } else {
        std::warning("No valid FAR found at beginning of the file, endiness unknown - defaulting to native endianess");
    }
    std::assert(far_try.STDF_VER == 4, "Pattern is for STDF version 4, file indicates a different version in FAR");
    
    Record records[while(!std::mem::eof())];
};

STDF stdf @ 0x00;