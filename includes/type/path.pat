import std.mem;

/*!
	Types dealing with various kinds of resource paths
*/

namespace auto type {

	/**
		Type representing a single path segment. Use the `Path` type instead of using this on its own
		@tparam Delimeter The delimeter sequence used to separate two path segments
	*/
	struct PathSegment<auto Delimeter> {
		char string[while(std::mem::read_string($, std::string::length(Delimeter)) != Delimeter && std::mem::read_unsigned($, 1) != 0x00)];
		char separator [[hidden]];
		
		if (separator == 0x00) {
			$ -= 1;
			break;
		}
	} [[sealed, format("type::impl::format_path_segment")]];
	
	/**
		A generic type representing a path with an arbitrary delimeter
		@tparam Delimeter The delimeter sequence used to separate two path segments
	*/
	struct Path<auto Delimeter> {
		PathSegment<Delimeter> segments[while(true)];
	} [[format("type::impl::format_path")]];
	
	/**
		A type representing a Unix path using a '/' forwardslash as delimeter
	*/
	using UnixPath = Path<"/">;

	/**
		A type representing a DOS path using a '\\' backslash as delimeter
	*/
	using DOSPath = Path<"\\">;
	
	namespace impl {
	
		fn format_path_segment(ref auto segment) {
			return segment.string;
		};
	
		fn format_path(ref auto path) {
			return std::mem::read_string($, sizeof(path));
		};
	
	}

}
