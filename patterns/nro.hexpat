struct MOD0 {
	char magic[4];
	u32 dynamic_offset [[name(".dynamic offset")]];
	u32 bss_start_offset [[name(".bss start offset")]];
	u32 bss_end_offset [[name(".bss end offset")]];
	u32 eh_frane_hdr_start_offset [[name(".eh_frame_hdr start offset")]];
	u32 eh_frane_hdr_end_offset [[name(".eh_frame_hdr end offset")]];
	u32 runtime_generated_module_object_offset;
};

struct Start {
	padding[4];
	MOD0 *mod0 : u32;
	char hb_magic[8];
};

struct SegmentHeader {
	u32 offset;
	u32 size;
};

struct Header {
	char magic[4];
	u32 version;
	u32 file_size;
	u32 flags;
	SegmentHeader segment_header_1[3];
	u32 bss_size;
	padding[4];
	u8 module_id[0x20];
	u32 dso_handle_offset;
	padding[4];
	SegmentHeader segment_header_2[3];
};

struct AssetSection {
	u8 *asset_offset : u64 [[pointer_base("asset_ptr")]];
	u64 size;
};

struct AssetHeader {
	if (is_homebrew()) {
		char magic[4];
		u32 version;
		AssetSection icon;
		AssetSection nacp;
		AssetSection romfs;
	}
};


fn asset_ptr(u128 offset) {
	return header.file_size;
};

fn is_homebrew() {
	return start.hb_magic == "HOMEBREW";
};


Start start @ 0x00;
Header header @ $;
std::assert(header.magic == "NRO0", "Invalid NRO File!");

AssetHeader assets @ header.file_size;

fn main() {
	if (is_homebrew())
		std::print("This is a Homebrew NRO!");
};