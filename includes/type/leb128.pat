#pragma once

#include <std/io.pat>
#include <std/mem.pat>

namespace type {
	
	struct LEB128 {
		u8 array[while($ == addressof(this) || std::mem::read_unsigned($-1, 1) & 0x80 != 0)] [[hidden]];
	} [[sealed, format("type::impl::format_leb128"), transform("type::impl::transform_leb128")]];
	
	namespace impl {
	
		fn transform_leb128_array(auto array) {
			u128 res = array[0] & 0x7f;
			for(u8 i = 1, array[i-1] & 0x80 != 0, i+=1) {
				res |= u64(array[i] & 0x7f) << 7 * i;
			}
			return res;
		};
		
		fn format_leb128(auto leb128) {
			u128 res = type::impl::transform_leb128_array(leb128.array);
			return std::format("{} ({:#x})", res, res);
		};
	
		fn transform_leb128(auto leb128) {
			return type::impl::transform_leb128_array(leb128.array);
		};
	}
	
}

