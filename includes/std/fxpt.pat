#pragma once

namespace std::fxpt {

	using fixed = s128;

	fn to_float(fixed fxt, u32 precision) {
		return double(fxt) / double((1 << precision));
	};
	
	fn to_fixed(double flt, u32 precision) {
		return fixed((flt * (1 << precision)));
	};

	fn change_precision(fixed value, u32 start_precision, u32 end_precision) {
		return std::fxpt::to_fixed(std::fxpt::to_float(value, start_precision), end_precision);
	};
	
	fn add(fixed a, fixed b, u32 precision) {
		return a + b;
	};
	
	fn subtract(fixed a, fixed b, u32 precision) {
		return a - b;
	};
	
	fn multiply(fixed a, fixed b, u32 precision) {
		return (a * b) / (1 << precision);
	};
	
	fn divide(fixed a, fixed b, u32 precision) {
		return (a << precision) / b;
	};

}
