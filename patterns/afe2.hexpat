#pragma endian little

#include <std/io.pat>
#include <std/sys.pat>

#define ATMOSPHERE_REBOOT_TO_FATAL_MAGIC   	"AFE2"
#define ATMOSPHERE_REBOOT_TO_FATAL_MAGIC_1 	"AFE1"
#define ATMOSPHERE_REBOOT_TO_FATAL_MAGIC_0 	"AFE0"

#define AMS_FATAL_ERROR_MAX_STACKTRACE 		0x20
#define AMS_FATAL_ERROR_MAX_STACKDUMP  		0x100
#define AMS_FATAL_ERROR_TLS_SIZE       		0x100

struct gprs_named {
	u64 gprs[29];
	u64 fp;
	u64 lr;
	u64 sp;
};

union gprs {
	u64 gprs[32];
	gprs_named named;
};

struct atmosphere_fatal_error_ctx {
	char magic[4];
	u32 error_desc;
	u64 program_id;
	gprs gprs;
	u64 pc;
	u64 module_base;
	u32 pstate;
	u32 afsr0;
	u32 afsr1;
	u32 esr;
	u64 far;
	u64 report_identifier; /* Normally just system tick */
	u64 stack_trace_size;
	u64 stack_dump_size;
	u64 stack_trace[AMS_FATAL_ERROR_MAX_STACKTRACE];
	u8 stack_dump[AMS_FATAL_ERROR_MAX_STACKDUMP];
    u8 tls[AMS_FATAL_ERROR_TLS_SIZE];
};

atmosphere_fatal_error_ctx ctx @ 0x00;

std::assert(ctx.magic == ATMOSPHERE_REBOOT_TO_FATAL_MAGIC   ||
       ctx.magic == ATMOSPHERE_REBOOT_TO_FATAL_MAGIC_1 ||
       ctx.magic == ATMOSPHERE_REBOOT_TO_FATAL_MAGIC_0,
       "File is not a valid Atmosphere fatal error binary!");
	   
std::assert_warn(ctx.magic == ATMOSPHERE_REBOOT_TO_FATAL_MAGIC, 
           "Atmosphere fatal error binary is for an older version!");


std::print("Error Description: 0x{:04X}", ctx.error_desc);
std::print("Program ID: {:016X}", ctx.program_id);
