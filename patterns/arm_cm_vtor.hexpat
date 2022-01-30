#pragma endian little

#include <std/io.pat>
#include <std/mem.pat>

#define VTOR	0x00000000
#define EXTERNAL_INTERRUPT_COUNT	64

using Address = u32;

struct Exceptions {
	Address reset [[name("Reset Handler")]];
	Address nmi [[name("Non-maskable Interrupt Handler")]];
	Address hard_fault [[name("HardFault Handler")]];
	Address mem_manage [[name("Memory Protection Error Handler")]];
	Address bus_fault [[name("Bus Fault Handler")]];
	Address usage_fault [[name("UsageFault (Instruction Execution fault) Handler")]];
	Address reserved_1[4] [[hidden]];
	Address sv_call [[name("Synchronous Supervisor Call (SVC Instruction) Handler")]];
	Address debug_monitor [[name("Synchronous Debug Event Handler")]];
	Address reserved_2[1] [[hidden]];
	Address pend_sv [[name("Asynchronous Supervisor Call Handler")]];
	Address sys_tick [[name("System Timer Tick Handler")]];
};

struct ExternalInterrupts {
	Address external_interrupt[EXTERNAL_INTERRUPT_COUNT] [[inline]];
};

struct VectorTable {
	Address initial_sp [[name("Initial Stack Pointer Value")]];
	Exceptions exceptions [[inline, name("Exceptions")]];
	ExternalInterrupts external_interrupts [[name("External Interrupts")]];
};

VectorTable vector_table @ VTOR;

fn main() {
	u32 table_size = sizeof(vector_table);
	
	u32 default_handler_address = 0x00;
	
	for (u32 i = 4, i < table_size, i = i + 4) {
		u32 occurrences = 0;
		for (u32 j = 4, j < table_size, j = j + 4) {
			if (std::mem::read_unsigned(i, 4) == std::mem::read_unsigned(j, 4)) {
				occurrences = occurrences + 1;
				
				if (occurrences > 1)
					default_handler_address = std::mem::read_unsigned(i, 4);
			}
		}
	}
	
	if (default_handler_address != 0x00)
		std::print("Default Handler implementation at 0x{:08X}", default_handler_address);
};