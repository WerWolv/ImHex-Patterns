#pragma once

import std.io;

/*!
	Types used to decode MAC Addresses
*/

namespace type;

/**
	A MAC Address as used in the Internet Protocol
*/
struct MACAddress {
	u8 bytes[6];
} [[sealed, format("type::impl::format_mac_address")]];

namespace impl {

	fn format_mac_address(MACAddress address) {
		return std::format("{:02X}:{:02X}:{:02X}:{:02X}:{:02X}:{:02X}",
			address.bytes[0],
			address.bytes[1],
			address.bytes[2],
			address.bytes[3],
			address.bytes[4],
			address.bytes[5]);
	};

}