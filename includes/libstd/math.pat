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

}