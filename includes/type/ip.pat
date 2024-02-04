#pragma once

import std.io;
import std.string;

/*!
    Types used to decode IP addresses
*/

namespace type;

/**
    A 4 byte IPv4 Address as described in RFC 791
*/
struct IPv4Address {
    u8 bytes[4];
} [[sealed, format("type::impl::format_ipv4_address")]];

/**
    A 16 byte IPv6 Address as described in RFC 8200
*/
struct IPv6Address {
    be u16 words[8];
} [[sealed, format("type::impl::format_ipv6_address")]];

namespace impl {

    fn format_ipv4_address(IPv4Address address) {
        return std::format("{}.{}.{}.{}",
            address.bytes[0],
            address.bytes[1],
            address.bytes[2],
            address.bytes[3]);
    };

    fn format_ipv6_address(IPv6Address address) {
        str result;

        bool hadZeros = false;
        s8 startIndex = -1;

        for (u8 i = 0, i < 8, i += 1) {
            if (address.words[i] == 0x00 && !hadZeros) {
                hadZeros = true;
                startIndex = i;

                while (i < 7) {
                    if (address.words[i + 1] != 0x00)
                        break;
                    i += 1;
                }

                if (startIndex == 0 || i == 7)
                    result += ":";
            } else {
                result += std::format("{:X}", address.words[i]);
            }

            result += ":";
        }

        return std::string::substr(result, 0, std::string::length(result) - 1);
    };

}