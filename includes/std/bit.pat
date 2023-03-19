#pragma once

#include <std/limits.pat>

/*!
	This library contains various helper functions for common bit operations.
*/

namespace std::bit {

	/**
		Calculates the number of 1 bits in a given number
		@param x The number
		@return The number of bits set to 1 in `x`
	*/
	fn popcount(u128 x) {
		x = (x & (std::limits::u128_max() /  3)) + ((x >> 1) & (std::limits::u128_max() /  3));
		x = (x & (std::limits::u128_max() /  5)) + ((x >> 2) & (std::limits::u128_max() /  5));
		x = (x & (std::limits::u128_max() / 17)) + ((x >> 4) & (std::limits::u128_max() / 17));
		
		return x % 0xFF;
	};

	/**
		Checks if only a single bit is set to 1 in a given number
		@param x The number
		@return True if there's a single bit set to 1 in `x`, false otherwise
	*/
	fn has_single_bit(u128 x) {
		return x != 0 && (x & (x - 1)) == 0;
	};
	
	/**
		Rounds the given number up to the next bigger power of two
		@param x The number
		@return Next bigger power of two that can fit `x`
	*/
	fn bit_ceil(u128 x) {		
		if (x == 0) return 0;
		
		u8 i;
		while ((1 << i) < x)
			i = i + 1;
		
		return 1 << i;
	};

	/**
		Rounds the given number down to the next bigger power of two
		@param x The number
		@return Next smaller power of two
	*/
	fn bit_floor(u128 x) {
		if (x == 0) return 0;
		
		u8 i;
		while ((x >> i) > 0)
			i = i + 1;
		
		return 1 << (i - 1);
	};

}
