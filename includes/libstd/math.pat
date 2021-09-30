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

}