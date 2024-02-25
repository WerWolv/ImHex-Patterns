#pragma author WerWolv
#pragma description Static library archive files

#pragma MIME application/x-archive

import std.string;
import std.mem;
import std.sys;

struct ARFile {
	char file_name[16];
	char modification_timestamp[12];
	char owner_id[6];
	char group_id[6];
	char file_mode[8];
	char file_size[10];
	u16 end_marker;
	
	if (end_marker == 0x0A60) {
		u8 data[std::string::parse_int(this.file_size, 10)];
		padding[sizeof(data) & 1];
	}
};

char signature[8] @ 0x00;
std::assert(signature == "!<arch>\n", "File is not a valid archive!");

ARFile files[while($ < std::mem::size())] @ $;
