#pragma once

namespace std::math {

	fn min(auto a, auto b) {
		return a < b ? a : b;
	};
	
	fn max(auto a, auto b) {
		return a > b ? a : b;
	};

	fn clamp(auto x, auto min, auto max) {
		return (x < min) ? min : ((x > max) ? max : x); 
	};

	fn abs(auto x) {
		if (x < 0) return -x;
		else return x;
	};

	fn sign(auto x) {
		if (x > 0)
			return 1;
		else if (x < 0)
			return -1;
		else
			return 0;
	};

	fn copy_sign(auto x, auto y) {
		if (y >= 0)
			return std::math::abs(x);
		else
			return -std::math::abs(x);
	};

	fn factorial(u128 x) {
		u128 result;
		
		result = x;
		while (x > 1) {
			x = x - 1;
			result = result * x;
		}
		
		return result;
	};

	fn comb(u128 n, u128 k) {
		if (k > n)
			return 0;
		else
			return std::math::factorial(n) / (std::math::factorial(k) * std::math::factorial(n - k));
	};

	fn perm(u128 n, u128 k) {
		if (k > n)
			return 0;
		else
			return std::math::factorial(n) / std::math::factorial(n - k);
	};


	fn floor(auto value) { return builtin::std::math::floor(value); };
	fn ceil(auto value) { return builtin::std::math::ceil(value); };
	fn round(auto value) { return builtin::std::math::round(value); };
	fn trunc(auto value) { return builtin::std::math::trunc(value); };

	fn log10(auto value) { return builtin::std::math::log10(value); };
	fn log2(auto value) { return builtin::std::math::log2(value); };
	fn ln(auto value) { return builtin::std::math::ln(value); };

	fn fmod(auto value) { return builtin::std::math::fmod(value); };
	fn pow(auto base, auto exp) { return builtin::std::math::pow(base, exp); };
	fn sqrt(auto value) { return builtin::std::math::sqrt(value); };
	fn cbrt(auto value) { return builtin::std::math::cbrt(value); };

	fn sin(auto value) { return builtin::std::math::sin(value); };
	fn cos(auto value) { return builtin::std::math::cos(value); };
	fn tan(auto value) { return builtin::std::math::tan(value); };

	fn asin(auto value) { return builtin::std::math::asin(value); };
	fn acos(auto value) { return builtin::std::math::acos(value); };
	fn atan(auto value) { return builtin::std::math::atan(value); };
	fn atan2(auto value) { return builtin::std::math::atan2(value); };

	fn sinh(auto value) { return builtin::std::math::sinh(value); };
	fn cosh(auto value) { return builtin::std::math::cosh(value); };
	fn tanh(auto value) { return builtin::std::math::tanh(value); };

	fn asinh(auto value) { return builtin::std::math::asinh(value); };
	fn acosh(auto value) { return builtin::std::math::acosh(value); };
	fn atanh(auto value) { return builtin::std::math::atanh(value); };
	
}