namespace std::string {

    fn to_string(auto x) {
        return std::format("{}", x);
    };

    fn starts_with(str string, str part) {
        return std::string::substr(string, 0, std::string::length(part)) == part;
    };

    fn ends_with(str string, str part) {
        return std::string::substr(string, std::string::length(string) - std::string::length(part), std::string::length(part)) == part;
    };

    fn contains(str a, str b) {
        s32 a_len, b_len;
        a_len = std::string::length(a);
        b_len = std::string::length(b);

        s32 i;
        while (i < a_len - b_len) {
            if (std::string::substr(a, i, b_len) == b)
                return true;
            i = i + 1;
        }

        return false;
    };

    fn reverse(str string) {	
        str result;
        
        s32 i;
        i = std::string::length(string);
        while (i > 0) {
            i = i - 1;
            result = result + std::string::at(string, i);
        }
            
        return result;
    };


}