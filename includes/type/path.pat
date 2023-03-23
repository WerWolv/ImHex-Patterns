#include <std/mem.pat>

namespace type {

	struct UnixPathSegment {
		char string[while(std::mem::read_unsigned($, 1) != '/' && std::mem::read_unsigned($, 1) != 0x00)];
		char separator [[hidden]];
		
		if (separator == 0x00) {
			$ -= 1;
			break;
		}
	} [[sealed, format("type::impl::format_unix_path_segment")]];
	
	struct UnixPath {
		UnixPathSegment segments[while(true)];
	} [[format("type::impl::format_unix_path")]];
	
	
	namespace impl {
	
		fn format_unix_path_segment(UnixPathSegment segment) {
			return segment.string;
		};
	
		fn format_unix_path(UnixPath path) {
			return std::mem::read_string($, sizeof(path));
		};
	
	}

}