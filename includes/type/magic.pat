#include <std/string.pat>
#include <std/sys.pat>
#include <std/io.pat>
#include <std/ctype.pat>

/*!
    Types used to parse and enforce specific magic numbers
*/

namespace type {

    /**
        A Magic number. Throws an error if the magic number does not match the expected value
        @tparam ExpectedValue A string representing the expected value
    */
    struct Magic<auto ExpectedValue> {
        char value[std::string::length(ExpectedValue)];
        std::assert(value == ExpectedValue, std::format("Invalid magic value! Expected \"{}\", got \"{}\".", ExpectedValue, value));
    } [[sealed, format("type::impl::format_magic")]];
    
    namespace impl {
    
        fn format_magic(ref auto magic) {
            str result;
            for (u32 i = 0, i < sizeof(magic.value), i += 1) {
                char c = magic.value[i];

                if (std::ctype::isprint(c))
                    result += c;
                else
                    result += std::format("\\x{:02X}", u8(c));
            }
            return std::format("\"{}\"", result);
        };
        
    }

}