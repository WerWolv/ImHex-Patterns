#pragma once

#include <std/io.pat>
#include <std/mem.pat>

namespace type {
	
	struct VarInt {
		u8 array[while($ == addressof(this) || std::mem::read_unsigned($-1, 1) & 0x80 != 0)] [[hidden]];
	} [[format("type::impl::format_varint"), transform("type::impl::transform_varint")]];
	
	namespace impl {
	
		fn transform_varint_array(auto array) {
			u64 res = array[0] & 0x7f;
			for(u8 i = 1, array[i-1] & 0x80 != 0, i+=1) {
				res <<= 7;
				res = res | u64(array[i] & 0x7f);
			}
			return res;
		};
		
		fn format_varint(auto varint) {
			u64 res = type::impl::transform_varint_array(varint.array);
			return std::format("{} ({:#x})", res, res);
		};
	
		fn transform_varint(auto varint) {
			return type::impl::transform_varint_array(varint.array);
		};
	}


	
}

