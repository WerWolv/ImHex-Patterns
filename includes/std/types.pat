#include <std/io.pat>
#include <std/math.pat>

namespace std::type {

    struct GUID {
        u32 time_low;
        u16 time_mid;
        u16 time_high_and_version;
        u8 clock_seq_and_reserved;
        u8 clock_seq_low;
        u8 node[6];
    } [[format("std::type::guid_formatter"), single_color]];

    fn guid_formatter(GUID guid) {
        bool valid = ((le u16(guid.time_high_and_version) >> 12) <= 5) && (((guid.clock_seq_and_reserved >> 4) >= 8) || ((guid.clock_seq_and_reserved >> 4) == 0));

        return std::format("{}{{{:08X}-{:04X}-{:04X}-{:02X}{:02X}-{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}}}",
            valid ? "" : "Invalid ",
            le u32(guid.time_low),
            le u16(guid.time_mid),
            le u16(guid.time_high_and_version),
            guid.clock_seq_and_reserved,
            guid.clock_seq_low,
            guid.node[0],
            guid.node[1],
            guid.node[2],
            guid.node[3],
            guid.node[4],
            guid.node[5]);
    };


    using float16 = u16 [[format("std::type::float16_formatter")]];

    fn float16_formatter(float16 value) {	
        float sign = (value >> 15) == 0b01 ? -1.0 : 1.0;
        float exponent = std::math::pow(2.0, float((value >> 10) & 0x1F) - 14);
        u16 mantissa = value & 0x3FF;
        
        float fraction = 0;
        for (s8 i = 9, i >= 0, i -= 1) {
            if ((mantissa & (1 << i)) != 0) {
                fraction += 1.0 / std::math::pow(2.0, (10.0 - i));
            }
        }

        
        return std::format("{:f}", sign * exponent * fraction);
            
    };


    bitfield Bits {
        bit0 : 1;
        bit1 : 1;
        bit2 : 1;
        bit3 : 1;
        bit4 : 1;
        bit5 : 1;
        bit6 : 1;
        bit7 : 1;
    } [[format("std::type::bits_formatter"), right_to_left]];
    
    bitfield Nibbles {
        low  : 4;
        high : 4;
    } [[format("std::type::nibble_formatter")]];
    
    union Byte {
        u8 value;
        Bits bits;
        Nibbles nibbles;
    } [[format("std::type::byte_formatter"), single_color]];
    
    fn byte_formatter(Byte byte) {
        return std::format("0x{0:02X} (0b{1:08b}) LSB:{2}, MSB:{3}",
            byte.value,
            byte.value,
            byte.bits.bit0,
            byte.bits.bit7);
    };
    
    fn bits_formatter(Bits bits) {
        return std::format("0b{}{}{}{}{}{}{}{}", 
            bits.bit7,
            bits.bit6,
            bits.bit5,
            bits.bit4,
            bits.bit6,
            bits.bit2,
            bits.bit1,
            bits.bit0);
    };
    
    fn nibble_formatter(Nibbles nibbles) {
        return std::format("{{ {0:0X}, {1:0X} }}", nibbles.high, nibbles.low);
    };

}
