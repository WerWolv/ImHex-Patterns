#include <std/io.pat>
#include <std/string.pat>
#include <std/mem.pat>

/*!
    Type representing a Base64 encoded string
*/

namespace type {

    /**
        Type representing a Base64 encoded string
        @tparam T String type
    */
    struct Base64<T> {
        T string;
    } [[sealed, format("type::impl::transform_base64")]];

    namespace impl {

        fn get_decoded_value(char c) {
            if (c >= 'A' && c <= 'Z') return c - 'A';
            if (c >= 'a' && c <= 'z') return c - 'a' + 26;
            if (c >= '0' && c <= '9') return c - '0' + 52;
            if (c == '+') return 62;
            if (c == '/') return 63;
            return -1; // Invalid character
        };

        fn decode_base64(str input) {
            u64 inputLength = std::string::length(input);
            str result;

            s32 val = 0;
            s32 bits = -8;
            for (u32 i = 0, i < inputLength, i += 1) {
                char c = input[i];
                if (c == '=')
                    break;

                s32 index = type::impl::get_decoded_value(c);
                if (index == -1)
                    continue;

                val = (val << 6) + index;
                bits += 6;

                if (bits >= 0) {
                    result += char((val >> bits) & 0xFF);
                    bits -= 8;
                }
            }

            return result;
        };

        fn transform_base64(ref auto base64) {
            return type::impl::decode_base64(base64.string);
        };

    }

}
