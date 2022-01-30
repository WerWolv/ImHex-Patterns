#pragma once

namespace std::limits {
	
	fn u8_min() {
		return u8(0);
	};
	
	fn u8_max() {
		return u8(-1);
	};

    fn s8_min() {
		return -s8((std::limits::u8_max() / 2)) - 1;
	};
	
	fn s8_max() {
		return s8((u8_max() / 2));
	};

	fn u16_min() {
		return u16(0);
	};
	
	fn u16_max() {
		return u16(-1);
	};
	
	fn s16_min() {
		return -s16((std::limits::u16_max() / 2)) - 1;
	};
	
	fn s16_max() {
		return s16((u16_max() / 2));
	};
	
	fn u32_min() {
		return u32(0);
	};
	
	fn u32_max() {
		return u32(-1);
	};
	
	fn s32_min() {
		return -s32((std::limits::u32_max() / 2)) - 1;
	};
	
	fn s32_max() {
		return s32((u32_max() / 2));
	};
	
	fn u64_min() {
		return u64(0);
	};
	
	fn u64_max() {
		return u64(-1);
	};
	
	fn s64_min() {
		return -s64((std::limits::u64_max() / 2)) - 1;
	};
	
	fn s64_max() {
		return s64((u64_max() / 2));
	};
	
	fn u128_min() {
		return u128(0);
	};
	
	fn u128_max() {
		return u128(-1);
	};
	
	fn s128_min() {
		return -s128((std::limits::u128_max() / 2)) - 1;
	};
	
	fn s128_max() {
		return s128((u128_max() / 2));
	};
	
}