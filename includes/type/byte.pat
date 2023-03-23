#pragma once

#include <std/io.pat>

namespace type {
    
    bitfield Bits {
        bit0 : 1;
        bit1 : 1;
        bit2 : 1;
        bit3 : 1;
        bit4 : 1;
        bit5 : 1;
        bit6 : 1;
        bit7 : 1;
    } [[format("type::impl::format_bits"), right_to_left]];
    
    bitfield Nibbles {
        low  : 4;
        high : 4;
    } [[format("type::impl::format_nibbles")]];
    
    union Byte {
        u8 value;
        Bits bits;
        Nibbles nibbles;
    } [[format("type::impl::format_byte"), single_color]];


	namespace impl {

        fn format_byte(Byte byte) {
            return std::format("0x{0:02X} (0b{1:08b}) LSB:{2}, MSB:{3}",
                byte.value,
                byte.value,
                byte.bits.bit0,
                byte.bits.bit7);
        };
        
        fn format_bits(Bits bits) {
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
        
        fn format_nibbles(Nibbles nibbles) {
            return std::format("{{ {0:0X}, {1:0X} }}", nibbles.high, nibbles.low);
        };

	}

}