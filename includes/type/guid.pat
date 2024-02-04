#pragma once

import std.io;

/*!
	Types to deal with UUIDs (Universally Unique Identifiers) / GUIDs (Globally Unique Identifiers) as described in RFC 4122
*/

namespace type;

/**
	Type representing a GUID value
*/
struct GUID {
	u32 time_low;
	u16 time_mid;
	u16 time_high_and_version;
	u8 clock_seq_and_reserved;
	u8 clock_seq_low;
	u8 node[6];
} [[sealed, format("type::impl::format_guid")]];

/**
	Alias name for GUID
*/
using UUID = GUID;

namespace impl {

	fn format_guid(GUID guid) {
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

}