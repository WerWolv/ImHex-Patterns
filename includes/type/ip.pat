#include <std/io.pat>

namespace type {

	struct IPv4Address {
		u8 bytes[4];
	} [[sealed, format("type::impl::format_ipv4_address")]];

    struct IPv6Address {
		u16 words[8];
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
			return std::format("{:04X}:{:04X}:{:04X}:{:04X}:{:04X}:{:04X}:{:04X}:{:04X}",
				address.words[0],
				address.words[1],
				address.words[2],
				address.words[3],
				address.words[4],
				address.words[5],
				address.words[6],
				address.words[7]);
		};
				
	}

}