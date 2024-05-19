#pragma description TODO

import std.mem;
import std.io;
import std.string;

struct Header {
    u32 magic;                     
    u32 version;                   
    u64 RootStructAltGUID; 
    u64 AssetChecksum;
    u32 DependencyCount;
    s32 DataBlockCount;
    s32 TagStructCount;
    s32 DataReferenceCount;
    s32 TagReferenceCount;
    u32 StringTableSize;
    u32 ZoneSetDataSize;
    u32 Unk_0x34;
    u32 HeaderSize;
    u32 DataSize;
    u32 ResourceDataSize;
    u32 ActualResoureDataSize;
    u8 HeaderAlignment;
    u8 TagDataAlignment;
    u8 ResourceDataAlignment;
    u8 ActualResourceDataAlignment;
    s32 IsResource;
};

enum curve_mode : u8 {
    choose_best = 0x00,
    force_FAST = 0x01,
    force_PRETTY = 0x02,
};
 
enum BitmapForcedFormat : u16 {
    Use_Default = 0x00,
    Best_Compressed_Color_Format = 0x01,
    Best_Uncompressed_Color_Format = 0x02,
    Best_Compressed_Bump_Format = 0x03,
    Best_Uncompressed_Bump_Format = 0x04,
    Best_Compressed_Monochrome_Format = 0x05,
    Best_Uncompressed_Monochrome_Format = 0x06,
    Best_Compressed_Monochrome_Format_Without_Alpha = 0x07,
    unused2 = 0x08,
    unused3 = 0x09,
    unused4 = 0x0A,
    unused5 = 0x0B,
    unused6 = 0x0C,
    Color_And_Alpha_Formats = 0x0D,
    bc1_unorm_DXT1_Compressed_Color_Key_Alpha = 0x0E,
    bc2_unorm_DXT3_Compressed_Color_4bit_Alpha = 0x0F,
    bc3_unorm_DXT5_Compressed_Color_Compressed_8bit_Alpha = 0x10,
    Color_24bit_Alpha_8bit = 0x11,
    Monochrome_8bit_Alpha_8bit = 0x12,
    Channel_Mask_3bit_Color_1bit_Alpha = 0x13,
    Color_30bit_Alpha_2bit = 0x14,
    Color_48bit_Alpha_16bit = 0x15,
    HALF_Color_Alpha = 0x16,
    FLOAT_Color_Alpha = 0x17,
    r8_unorm_8bit_Intensity_RGBA = 0x18,
    DEPRECATED_DXT3A_4bit_Intensity_ARGB = 0x19,
    bc4_unorm_rrrr_DXT5A_Compressed_Intensity_ARGB = 0x1A,
    Compressed_Monochrome_Alpha = 0x1B,
    b4g4r4a4_12bit_Color_4bit_Alpha = 0x1C,
    Color_Only_Formats = 0x1D,
    Monochrome_8bit = 0x1E,
    Compressed_Color_24bit = 0x1F,
    Color_32bit_R11G11B10 = 0x20,
    Monochrome_16bit = 0x21,
    Red_Green_Only_16bit = 0x22,
    Signed_RGBA_16bit = 0x23,
    HALF_Red_Only = 0x24,
    FLOAT_Red_Only = 0x25,
    HALF_Red_Green_Only = 0x26,
    FLOAT_Red_Green_Only = 0x27,
    HALF_Monochrome = 0x28,
    DEPRECATED_Compressed_Monochrome_4bit = 0x29,
    Compressed_Interpolated_Monochrome = 0x2A,
    bc6h_uf16_HDR_RGB_Unsigned_Half_Float = 0x2B,
    bc6h_sf16_HDR_RGB_Signed_Half_Float = 0x2C,
    bc7_unorm_High_Quality_bc3 = 0x2D,
    Alpha_Only_Formats = 0x2E,
    DEPRECATED_DXT3A_4bit_Alpha = 0x2F,
    bc4_unorm_000r_DXT5A_8bit_Compressed_Alpha = 0x30,
    Alpha_8bit = 0x31,
    unused28 = 0x32,
    unused29 = 0x33,
    unused30 = 0x34,
    Normal_Map_Formats = 0x35,
    bc5_snorm_DXN_Compressed_Normals_Better = 0x36,
    DEPRECATED_CTX1_Compressed_Normals_Smaller = 0x37,
    Normals_16bit = 0x38,
    Normals_32bit = 0x39,
    Vector_8bit_4_Channel = 0x3A,
};

enum BitmapDownsampleFilter : u8 {
    point_sampled = 0x01,
    box_filter = 0x02,
    blackman_filter = 0x03,
    lanczos_filter = 0x04,
    nuttall_filter = 0x05,
    blackman_harris_filter = 0x06,
    blackman_nuttall_filter = 0x07,
    flat_top_filter = 0x08,
    extreme_filter = 0x09,
    min_filter = 0x0A
};

enum BitmapType : u8 {
    _2D_Texture = 0x00,
    _3D_Texture = 0x01,
    CubeMap = 0x02,
    Array = 0x03,
};
    
enum BitmapColorSpace : u8 {
    Automatic = 0x00,
    Rec709 = 0x01,
    DCI_P3 = 0x02,
    Rec2020 = 0x03,
};

enum SignedDistanceFieldMethod : u8 {
    Neighbors_Multithreaded = 0x00,
    Neighbors = 0x01,
    Cached_Euclidean_Multithreaded = 0x02,
    Cached_Euclidean = 0x03,
    SSEDT = 0x04,
};

enum BitmapFormat : u16 {
    a8_unorm = 0x00,
    r8_unorm_rrr1 = 0x01,
    r8_unorm_rrrr = 0x02,
    r8g8_unorm_rrrg = 0x03,
    unused1 = 0x04,
    unused2 = 0x05,
    b5g6r5_unorm = 0x06,
    unused3 = 0x07,
    b5g6r5a1_unorm = 0x08,
    b4g4r4a4_unorm = 0x09,
    b8g8r8x8_unorm = 0x0A,
    b8g8r8a8_unorm = 0x0B,
    unused4 = 0x0C,
    DEPRECATED_dxt5_bias_alpha = 0x0D,
    bc1_unorm_dxt1 = 0x0E,
    bc2_unorm_dxt3 = 0x0F,
    bc3_unorm_dxt5 = 0x10,
    DEPRECATED_a4r4g4b4_font = 0x11,
    unused7 = 0x12,
    unused8 = 0x13,
    DEPRECATED_SOFTWARE_rgbfp32 = 0x14,
    unused9 = 0x15,
    r8g8_snorm_v8u8 = 0x16,
    DEPRECATED_g8b8 = 0x17,
    r32g32b32a32_float_abgrfp32 = 0x18,
    r16g16b16a16_float_abgrfp16 = 0x19,
    r16_float_rrr1_16f_mono = 0x1A,
    r16_float_r000_16f_red = 0x1B,
    r8g8b8a8_snorm_q8w8v8u8 = 0x1C,
    r10g10b10a2_unorm_a2r10g10b10 = 0x1D,
    r16g16b16a16_unorm_a16b16g16r16 = 0x1E,
    r16g16_snorm_v16u16 = 0x1F,
    r16_unorm_rrr0_L16 = 0x20,
    r16g16_unorm_r16g16 = 0x21,
    r16g16b16a16_snorm_signedr16g16b16a16 = 0x22,
    DEPRECATED_dxt3a = 0x23,
    bc4_unorm_rrrr_dxt5a = 0x24,
    bc4_snorm_rrrr = 0x25,
    DEPRECATED_dxt3a_1111 = 0x26,
    bc5_snorm_dxn = 0x27,
    DEPRECATED_ctx1 = 0x28,
    DEPRECATED_dxt3a_alpha_only = 0x29,
    DEPRECATED_dxt3a_monochrome_only = 0x2A,
    bc4_unorm_000r_dxt5a_alpha = 0x2B,
    bc4_unorm_rrr1_dxt5a_mono = 0x2C,
    bc5_unorm_rrrg_dxn_mono_alpha = 0x2D,
    bc5_snorm_rrrg_dxn_mono_alpha_signed = 0x2E,
    bc6h_uf16 = 0x2F,
    bc6h_sf16 = 0x30,
    bc7_unorm = 0x31,
    d24_unorm_s8_uint_depth_24 = 0x32,
    r11g11b10_float = 0x33,
    r16g16_float = 0x34,
};

enum BitmapCurve : u8 {
    unknown = 0x00,
    xRGB = 0x01,
    gamma_2 = 0x02,
    linear = 0x03,
    offset_log = 0x04,
    sRGB = 0x05,
    Rec709 = 0x06,
};

enum BitmapUsageFlag : u8 {
    ignore_curve_override = 0x00,
    do_not_allow_size_optimization = 0x01,
    swap_axes = 0x02,
    pre_filter_cubemaps = 0x03,
};

enum BitmapSlicer : u8 {
    automatically_determine_slicer = 0x00,
    no_slicing = 0x01,
    color_plate_slicer = 0x02,
    cube_map_slicer = 0x03,
    color_grading_slicer = 0x04,
};

enum BitmapPacker : u8 {
    no_packing = 0x00,
    sprite_packing = 0x01,
    sprite_packing_if_needed = 0x02,
    _3d_pack = 0x03,
};

enum BitmapSmallestMip : u8 {
    _1_pixel = 0x00,
    _2_pixel = 0x01,
    _4_pixel = 0x02,
    _8_pixel = 0x03,
    _16_pixel = 0x04,
    _32_pixel = 0x05,
    _64_pixel = 0x06,
    _128_pixel = 0x07,
    _256_pixel = 0x08,
    _512_pixel = 0x09,
    _1024_pixel = 0x0A,
};

enum Swizzle : u8 {
    default = 0x00,
    source_red_channel = 0x01,
    source_green_channel = 0x02,
    source_blue_channel = 0x03,
    source_alpha_channel = 0x04,
    set_to_1 = 0x05,
    set_to_0 = 0x06,
    set_to_0_5 = 0x07,
    Random = 0x08,
    one_minus_source_red_channel = 0x09,
    one_minus_source_green_channel = 0x0A,
    one_minus_source_blue_channel = 0x0B,
    one_minus_source_alpha_channel = 0x0C,
    negative_source_red_channel = 0x0D,
    negative_source_green_channel = 0x0E,
    negative_source_blue_channel = 0x0F,
    negative_source_alpha_channel = 0x10,
};

bitfield BitmapDicerFlag {
    convert_plate_color_key_to_alpha_channel : 1;
    rotate_cube_map_to_match_directX_format : 1;
    sprites_shrink_elements_to_smallest_non_zero_alpha_region : 1;
    sprites_shrink_elements_to_smallest_non_zero_color_and_alpha_region : 1;
    unsigned_signed_scale_and_bias : 1;
    color_grading_sRGB_correction : 1;
    color_grading_Rec709_correction : 1;
};

bitfield BitmapDownsampleFlag {
    sprites : 1;
    pre_multiply_alpha : 1;
    post_divide_alpha : 1;
    height_map : 1;
    detail_map : 1;
    _signed : 1;
    illum_map : 1;
    zbump_map : 1;
    cubemap : 1;
    calculate_spec_power : 1;
    downsample_bumps_in_angular_space : 1;
    standard_orientation_of_normals_in_angular_space_and_renormalize : 1;
    generate_rgb_luminance_into_alpha_channel : 1;
};

bitfield BitmapPackerFlag {
    shrink_sprite_texture_pages_tightly_to_content : 1;
};

bitfield BitmapDataResourceFlags {
    Contains_3D_Texture : 1;
    CPU_Gameplay_Required : 1;
    Single_Mip_Texture : 1;
    UI_Texture : 1;
};


bitfield BitmapGroupFlags {
    bitmap_is_tiled  : 1;
    use_less_blurry_bump_map : 1;
    dither_when_compressing : 1;
    generate_random_sprites : 1;
    ignore_alpha_channel : 1;
    alpha_channel_stores_transparency : 1;
    preserve_alpha_channel_in_mipmaps : 1;
    only_use_on_demand : 1;
    apply_max_resolution_after_slicing  :1;
    pre_filter_cubemaps : 1;
    has_valid_min_and_max_values : 1;
    SDF_Only_Store_Inside_values : 1;
    SDF_Store_Direction : 1;
    SDF_Store_Initial_Values_In_Alpha_Channel : 1;
    Has_CUstom_Mipmaps : 1;
    Validate_Has_Custom_Mipmaps : 1;
    Is_Light_Probes : 1;
    pad1 : 1;
    pad2 : 1;
    pad3 : 1;
    pad4 : 1;
    pad5 : 1;
    pad6 : 1;
    pad7 : 1;
    pad8 : 1;
};
   
bitfield BitmapFlags {
    power_of_two_dimension : 1;
    compressed : 1;
    swap_axes : 1;
    mutable_at_runtime : 1;
    pad1 : 1;
    pad2 : 1;
    pad3 : 1;
    pad4 : 1;
    pad5 : 1;
 };

struct Data_Block {
    u32 Size;
    u16 Padding;
    u16 Section;
    u64 Offset;
};

struct Tag_Def_Structure {
    s64 GUID_1;
    s64 GUID_2;
    u16 Type;
    u16 Unk_0x12;
    s32 TargetIndex;
    s32 FieldBlock;
    u32 FieldOffset;
};

struct Tag_Dependency {
    char GroupTag[4] [[format("std::string::reverse")]];
    u32 NameOffset;
    u64 AssetID;
    u32 GlobalID;
    u32 Unk_0x14;
};

struct Data_Reference {
    s32 ParentStructIndex;
    s32 Unk_0x04;
    s32 TargetIndex;
    s32 FieldBlock;
    u32 FieldOffset;
};

struct TagReference {
    s64 GlobalHandle;
    s32 ref_id_int;
    s32 ref_id_sub;
    s32 ref_id_center_int;
    char TagGroupRev[4] [[format("std::string::reverse")]];
    s32 local_handle;
};

struct Tag_Fixup_Reference {
    s32 FieldBlock;
    u32 FieldOffset;
    u32 NameOffset;
    s32 DependencyIndex;
    TagReference tagreference @ header.HeaderSize + datablocks[FieldBlock].Offset + FieldOffset;
};



struct RealARgbColor {
    float A;
    float R;
    float G;
    float B;
};

struct RealRgbColor {
    float R;
    float G;
    float B;
};

struct Bitmap_Resource_Handle {
    s32 pixels[6]; // sum of these equals pixel count.
    u32 hardware_format;
    s8 tileMode;
    s8 format;
    BitmapDataResourceFlags bitmap_data_resource_flags;
    s8 Alignment_Bits;
    u8 highResMipCountAndFlags;
    u8 mipCountPerArraySlice;
    char generated_padff1b[6];
    s64 runtime_data;
    char streamingData[20];
    s32 generated_padb266;
};

struct BitmapBlock {
    u16 width;
    u16 height;
    u16 depth;
    BitmapType Bitmap_Type;
    u8 generated_paddca;
    BitmapFormat bitmap_format;
    BitmapFlags bitmap_flags;
    s8 mipmap_count;
    BitmapCurve bitmap_curve;
    u16 generated_pad8fee;
    float streaming_scale;
    s16 source_width;
    s16 source_height;
    char bitmap_resource_handle_size[12];
    s32 bitmap_resource_handle_count;
    Bitmap_Resource_Handle bitmap_resource_handle[bitmap_resource_handle_count];
};

struct BitmapUsage {
    s32 name;
    s32 editor_group;
    u32 source_gamma;
    BitmapCurve bitmap_curve;
    BitmapUsageFlag bitmap_usage_flag;
    BitmapSlicer bitmap_slicer;
    BitmapDicerFlag bitmap_dicer;
    BitmapPacker bitmap_packer;
    BitmapPackerFlag bitmap_packer_flags;
    BitmapType bitmap_type;
    s8 mipmap_limit;
    BitmapSmallestMip bitmap_smallest_mip;
    BitmapDownsampleFilter bitmap_downsample_filter;
    s8 filter_radius_bias;
    char generated_pad122e[1];
    BitmapDownsampleFlag bitmap_downsample_flag;
    char generated_pad5ee3[2];
    RealRgbColor sprite_background_color;
    Swizzle swizzle_red;
    Swizzle swizzle_green;
    Swizzle swizzle_blue;
    Swizzle swizzle_alpha;
    BitmapFormat bitmap_formats;
    BitmapColorSpace source_color_space;
    BitmapColorSpace target_color_space;
};

struct BitmapGroupSprite {
    u32 bitmap_index;
    char generated_pad2095[2];
    s32 left;
    s32 right;
    s32 top;
    s32 bottom;
    s64 real_point_2D;
};

struct BitmapGroupSequence {
    char name[32];
    u32 first_bitmap_index;
    u32 bitmap_count;
    char sprites[16];
    s32 sprite_count;
    BitmapGroupSprite Sprites[sprite_count];
};


struct Bitm {
    u32 Usage;
    s32 UsageID;
    s32 Package;
    s32 texture_group;
    BitmapGroupFlags flags;
    u16 sprite_spacing;
    u16 mip_sample_count;
    float bump_map_height;
    float blur_factor;
    u32 blur;
    u32 mipmap_blur;
    curve_mode curvemode;
    s8 max_mipmap_level;
    u16 max_resolution;
    BitmapForcedFormat force_bitmap_format;
    SignedDistanceFieldMethod sdfgeneration;
    s8 target_platform;
    u16 spread_factor;
    u16 generated_pad8ed2;
    char usage_override[16];
    s32 usage_override_count;
    BitmapUsage bitmap_usage[usage_override_count];
    char manual_sequence[16]; 
    s32 manual_sequences_count;
    BitmapGroupSequence manual_sequences[manual_sequences_count];
    char source_data[24]; 
    char source_path[20]; 
    u64 source_checksum;
    RealARgbColor min_color;
    RealARgbColor max_color;
    char sequence[16]; 
    s32 sequences_count;
    BitmapGroupSequence sequences[sequences_count];
    char bitmapstart[16];
    s32 bitmap_block_count;
    BitmapBlock bitmap_block[bitmap_block_count];
    char RawDDSData[header.ActualResoureDataSize];
};
    

struct InternalStruct {
    s64 vtablespace;
    u32 global_tag_id;
    char local_tag_handle[4];
};


// TAG LAYOUT
Header header @ 0x00;
Tag_Dependency Dependencies[header.DependencyCount] @ 0x50;
Data_Block datablocks[header.DataBlockCount] @ header.DependencyCount * 0x18 + 0x50;
Tag_Def_Structure tagdefstructure[header.TagStructCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10;
Data_Reference Data_References[header.DataReferenceCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10 + header.TagStructCount * 0x20;
Tag_Fixup_Reference tagfixupreference[header.TagReferenceCount] @ header.DependencyCount * 0x18 + 0x50 + header.DataBlockCount * 0x10 + header.TagStructCount * 0x20 + header.DataReferenceCount * 0x14;
char ZoneSet[header.ZoneSetDataSize] @ header.HeaderSize - header.ZoneSetDataSize; // zonesets kinda make no sense
InternalStruct internalstruct @ header.HeaderSize;
Bitm bitmap @ header.HeaderSize + 16;