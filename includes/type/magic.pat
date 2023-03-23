#include <std/string.pat>
#include <std/sys.pat>

namespace type {

    struct Magic<auto ExpectedValue> {
        char value[std::string::length(ExpectedValue)];
        std::assert(value == ExpectedValue, std::format("Invalid magic value! Expected \"{}\", got \"{}\".", ExpectedValue, value));
    } [[sealed, format("type::impl::format_magic")]];
    
    namespace impl {
    
        fn format_magic(ref auto magic) {
            return magic.value;
        };
        
    }

}
