namespace std::bit {

	fn popcount(u128 x) {
		x = (x & (std::limits::u128_max() /  3)) + ((x >> 1) & (std::limits::u128_max() /  3));
		x = (x & (std::limits::u128_max() /  5)) + ((x >> 2) & (std::limits::u128_max() /  5));
		x = (x & (std::limits::u128_max() / 17)) + ((x >> 4) & (std::limits::u128_max() / 17));
		
		return x % 0xFF;
	};
	
	fn bit_ceil(u128 x) {		
		if (x == 0) return 0;
		
		u8 i;
		while ((1 << i) < x)
			i = i + 1;
		
		return 1 << i;
	};
	
	fn bit_floor(u128 x) {
		if (x == 0) return 0;
		
		u8 i;
		while ((x >> i) > 0)
			i = i + 1;
		
		return 1 << (i - 1);
	};

}