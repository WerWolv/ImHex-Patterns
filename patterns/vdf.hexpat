#pragma author WerWolv
#pragma description Binary Value Data Format (.vdf) files

#pragma eval_depth 0x10000

#include <std/mem.pat>
#include <std/sys.pat>

enum Type : u8 {
	Set = 0x00,
	String = 0x01,
	Integer = 0x02,
	EndSet = 0x08
};

struct Entry {
	Type type;
	
	char name[];
	
	if (type == Type::Set) {
		Entry entries[while (std::mem::read_unsigned($, 1) != Type::EndSet)];
		Type endSet [[hidden]];
		std::assert(endSet == Type::EndSet, "Invalid end of set byte!");
	}
	else if (type == Type::Integer)
		u32 value;
	else if (type == Type::String) {
		char value[];
	}
};

struct Set {
	Entry entry [[inline]];
	Type endSet [[hidden]];
	std::assert(endSet == Type::EndSet, "Invalid end of set byte!");
};

Set set[while (std::mem::read_unsigned($ - 1, 1) != Type::EndSet)] @ 0x00;