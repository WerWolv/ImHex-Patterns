import std.string;
import std.sys;
import std.io;
import std.ctype;

/*!
    Types used to parse and enforce specific magic numbers
*/

namespace auto type
{
    fn fm(ref auto value)
    {
        str result;
        for (u32 i = 0, i < sizeof(value), i += 1)
        {
            char c = value[i];

            if (std::ctype::isprint(c))
                result += c;
            else
                result += std::format("\\x{:02X}", u8(c));
        }
        return std::format("\"{}\"", result);
    };

    /**
        A Magic number. Throws an error if the magic number does not match the expected value
        @tparam ExpectedValue A string representing the expected value
    */
    struct Magic<auto ExpectedValue>
    {
        char value[std::string::length(ExpectedValue)];
        std::assert_warn(value == ExpectedValue, std::format("Invalid magic value! Expected {}, got {} at position 0x{:X}", type::fm(ExpectedValue), type::fm(value), $ - std::string::length(ExpectedValue)));
    } [[sealed, format("type::impl::format_magic")]];
    namespace impl
    {
        fn format_magic(ref auto magic)
        {
            return type::fm(magic.value);
        };
    }
}