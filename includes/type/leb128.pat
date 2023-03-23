#pragma once

#include <std/io.pat>
#include <std/mem.pat>

namespace type {
	
	struct _LEB128 {
		u8 array[while($ == addressof(this) || std::mem::read_unsigned($-1, 1) & 0x80 != 0)] [[hidden]];
	} [[sealed]];

	using uLEB128 = _LEB128 [[format("type::impl::format_uleb128"), transform("type::impl::transform_uleb128")]];
	using sLEB128 = _LEB128 [[format("type::impl::format_sleb128"), transform("type::impl::transform_sleb128")]];

	using LEB128 = uLEB128;
	
	namespace impl {
	
		fn transform_uleb128_array(auto array) {
			u128 res = array[0] & 0x7f;
			for(u8 i = 1, array[i-1] & 0x80 != 0, i+=1) {
				res |= u128(array[i] & 0x7f) << 7 * i;
			}
			return res;
		};

		fn transform_sleb128_array(auto array) {			
			s128 res = type::impl::transform_uleb128_array(array);
			if (res & 0x40 != 0) {
				res |= ~0 << (sizeof(array) / sizeof(u8)) * 7;
			}
			return res;
		};
		
		fn format_uleb128(auto leb128) {
			u128 res = type::impl::transform_uleb128_array(leb128.array);
			return std::format("{} ({:#x})", res, res);
		};
	
		fn transform_uleb128(auto leb128) {
			return type::impl::transform_uleb128_array(leb128.array);
		};

		fn format_sleb128(auto leb128) {
			s128 res = type::impl::transform_sleb128_array(leb128.array);
			return std::format("{} ({:#x})", res, res);
		};
	
		fn transform_sleb128(auto leb128) {
			return type::impl::transform_sleb128_array(leb128.array);
		};

	}
	
}
