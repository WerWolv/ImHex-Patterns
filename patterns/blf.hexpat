
// Pattern for binary logging files (Vector BLF)
// References used for writing this:
// https://python-can.readthedocs.io/en/stable/_modules/can/io/blf.html
// https://bitbucket.org/tobylorenz/vector_blf

#pragma magic [ 4C 4F 47 47 ] @ 0x00
#pragma description Vector BLF Frame Logging Files
#pragma array_limit 4194304
#pragma pattern_limit 4294967296
#pragma endian little

import hex.dec;
import std.io;
import type.magic;

enum object_type : u32 {
    unknown = 0, //< unknown object
    can_message = 1, //< CAN message object
    can_error = 2, //< CAN error frame object
    can_overload = 3, //< CAN overload frame object
    can_statistic = 4, //< CAN driver statistics object
    app_trigger = 5, //< application trigger object
    env_integer = 6, //< environment integer object
    env_double = 7, //< environment double object
    env_string = 8, //< environment string object
    env_data = 9, //< environment data object
    log_container = 10, //< container object
    lin_message = 11, //< LIN message object
    lin_crc_error = 12, //< LIN CRC error object
    lin_dlc_info = 13, //< LIN DLC info object
    lin_rcv_error = 14, //< LIN receive error object
    lin_snd_error = 15, //< LIN send error object
    lin_slv_timeout = 16, //< LIN slave timeout object
    lin_sched_modch = 17, //< LIN scheduler mode change object
    lin_syn_error = 18, //< LIN sync error object
    lin_baudrate = 19, //< LIN baudrate event object
    lin_sleep = 20, //< LIN sleep mode event object
    lin_wakeup = 21, //< LIN wakeup event object
    most_spy = 22, //< MOST spy message object
    most_ctrl = 23, //< MOST control message object
    most_lightlock = 24, //< MOST light lock object
    most_statistic = 25, //< MOST statistic object
    
    flexray_data = 29, //< FLEXRAY data object
    flexray_sync = 30, //< FLEXRAY sync object
    can_driver_error = 31, //< CAN driver error object
    most_pkt = 32, //< MOST Packet
    most_pkt2 = 33, //< MOST Packet including original timestamp
    most_hwmode = 34, //< MOST hardware mode event
    most_reg = 35, //< MOST register data (various chips)
    most_genreg = 36, //< MOST register data (MOST register)
    most_netstate = 37, //< MOST NetState event
    most_datalost = 38, //< MOST data lost
    most_trigger = 39, //< MOST trigger
    flexray_cycle = 40, //< FLEXRAY V6 start cycle object
    flexray_message = 41, //< FLEXRAY V6 message object
    lin_checksum_info = 42, //< LIN checksum info event object
    lin_spike_event = 43, //< LIN spike event object
    can_driver_sync = 44, //< CAN driver hardware sync
    flexray_status = 45, //< FLEXRAY status event object
    gps_event = 46, //< GPS event object
    flexray_error = 47, //< FLEXRAY error event object
    flexray_status = 48, //< FLEXRAY status event object
    flexray_startcycle = 49, //< FLEXRAY start cycle event object
    flexray_rcv_message = 50, //< FLEXRAY receive message event object
    realtime_clock = 51, //< Realtime clock object
    
    lin_statistic = 54, //< LIN statistic event object
    j1708_message = 55, //< J1708 message object
    j1708_virtual_message = 56, //< J1708 message object with more than 21 data bytes
    lin_message2 = 57, //< LIN frame object - extended
    lin_snd_error2 = 58, //< LIN transmission error object - extended
    lin_syn_error2 = 59, //< LIN sync error object - extended
    lin_crc_error2 = 60, //< LIN checksum error object - extended
    lin_crv_error2 = 61, //< LIN receive error object
    lin_wakeup2 = 62, //< LIN wakeup event object  - extended
    lin_spike_event2 = 63, //< LIN spike event object - extended
    lin_long_dom_sig = 64, //< LIN long dominant signal object
    app_text = 65, //< text object
    flexray_rcvmessage_ex = 66, //< FLEXRAY receive message ex event object
    most_statistic_ex = 67, //< MOST extended statistic event
    most_txlight = 68, //< MOST TxLight event
    most_alloctab = 69, //< MOST Allocation table event
    most_stress = 70, //< MOST Stress event
    ethernet_frame = 71, //< Ethernet frame object
    sys_variable = 72, //< system variable object
    can_error_ext = 73, //< CAN error frame object (extended)
    can_driver_error_ext = 74, //< CAN driver error object (extended)
    lin_long_dom_sig2 = 75, //< LIN long dominant signal object - extended
    most_150_message = 76, //< MOST150 Control channel message
    most_150_pkt = 77, //< MOST150 Asynchronous channel message
    most_ethernet_pkt = 78, //< MOST Ethernet channel message
    most_150_message_fragment = 79, //< Partial transmitted MOST50/150 Control channel message
    most_150_pkt_fragment = 80, //< Partial transmitted MOST50/150 data packet on asynchronous channel
    most_ethernet_pkt_fragment = 81, //< Partial transmitted MOST Ethernet packet on asynchronous channel
    most_system_event = 82, //< Event for various system states on MOST
    most_150_alloctab = 83, //< MOST50/150 Allocation table event
    most_50_message = 84, //< MOST50 Control channel message
    most_50_pkg = 85, //< MOST50 Asynchronous channel message
    can_message2 = 86, //< CAN message object - extended
    lin_unexpected_wakeup = 87,
    lin_short_or_slow_response = 88,
    lin_disturbance_event = 89,
    serial_event = 90,
    overrun_error = 91, //< driver overrun event
    event_comment = 92,
    wlan_frame = 93,
    wlan_statistic = 94,
    most_ecl = 95, //< MOST Electrical Control Line event
    global_marker = 96,
    afdx_frame = 97,
    afdx_statistic = 98,
    kline_statusevent = 99, //< E.g. wake-up pattern
    can_fd_message = 100, //< CAN FD message object
    can_fd_message_64 = 101, //< CAN FD message object
    ethernet_rx_error = 102, //< Ethernet RX error object
    ethernet_status = 103, //< Ethernet status object
    can_fd_error_64 = 104, //< CAN FD Error Frame object
    lin_short_or_slow_response2 = 105,
    afdx_status = 106, //< AFDX status object
    afdx_bus_statistic = 107, //< AFDX line-dependent busstatistic object
    
    afdx_error_event = 109, //< AFDX asynchronous error event
    a429_error = 110, //< A429 error object
    a429_status = 111, //< A429 status object
    a429_bus_statistic = 112, //< A429 busstatistic object
    a429_message = 113, //< A429 Message
    ethernet_statistic = 114, //< Ethernet statistic object
    restore_point_container = 115, //< Restore point container, use unknown
    
    test_structure = 118, //< Event for test execution flow
    diag_request_information = 119, //< Event for correct interpretation of diagnostic requests
    ethernet_frame_ex = 120, //< Ethernet packet extended object
    ethernet_frame_forwarded = 121, //< Ethernet packet forwarded object
    ethernet_error_ex = 122, //< Ethernet error extended object
    ethernet_error_forwarded = 123, //< Ethernet error forwarded object
    function_bus = 124, //< FunctionBus object
    data_lost_begin = 125, //< Data lost begin
    data_lost_end = 126, //< Data lost end
    water_mark_event = 127, //< Watermark event
    trigger_condition = 128, //< Trigger Condition event
    can_setting_changed = 129, //< CAN Settings Changed object
    distributed_object_member = 130, //< Distributed object member (communication setup)
    attribute_event = 131, //< ATTRIBUTE event (communication setup)
};

bitfield can_msg_flags {
    is_tx : 1;
    padding : 4;
    nerr : 1;
    wu : 1;
    rtr : 1;
};

struct can_msg {
    u16 channel;
    can_msg_flags flags;
    u8 dlc;
    u32 id;
    u8 data[8];
};
struct can_msg2 {
    u16 channel;
    can_msg_flags flags;
    u8 dlc;
    u32 id;

    auto struct_len = 2 + 1 + 1 + 4 + 4 + 1 + 1 + 2; // TODO: Alternative way of doing this?
    u8 data[parent.header.object_size - parent.header.header_size - struct_len];

    // The frame length in nanoseconds
    u32 frame_length;
    // Total number of bits of the CAN frame
    u8 bit_count;
    padding[1];
    padding[2];
};

bitfield can_fd_msg_flags {
    edl : 1; //< Extended data length
    brs : 1; //< Bit rate switch
    esi : 1; //< Error state indicator
    padding : 5;
};

fn format_can_fd_dlc(u8 dlc) {
    if (dlc > 8)
        return 8 + (dlc - 8) * 4;
    return dlc;
};

struct can_fd_msg {
    u16 channel;
    u8 flags;
    u8 dlc [[format("format_can_fd_dlc")]];
    u32 id;
    
    // The frame length in nanoseconds
    u32 frame_length;
    u8 arbitration_bit_count;
    can_fd_msg_flags fd_flags;
    u8 valid_data_bytes;
    padding[1];
    padding[4];

    u8 data[64];

    padding[4];
};

bitfield can_fd_msg_64_flags {
    padding : 2;
    nerr : 1;
    hv_wake_up : 1;
    remote_frame : 1;
    padding : 1;
    tx_ack : 1;
    tx_req : 1;
    padding : 1;
    srr : 1;
    r0 : 1;
    r1 : 1;
    edl : 1; //< Extended data length
    brs : 1; //< Bit rate switch
    esi : 1; //< Error state indicator
    padding : 2;
    burst : 1;
    padding : 13;
};
struct can_bitrate_cfg {
    u8 quartz_frequency;
    u8 prescaler;
    u8 btl_cycles;
    u8 sampling_point;
};
struct can_fd_msg_64 {
    u8 channel;
    u8 dlc [[format("format_can_fd_dlc")]];
    u8 valid_data_bytes;
    u8 tx_count;
    u32 id;
    u32 frame_length;
    can_fd_msg_64_flags flags;
    can_bitrate_cfg arbitration_bitrate;
    can_bitrate_cfg data_bitrate;
    u32 brs_time_offset;
    u32 crc_time_offset;
    u16 bit_length;
    u8 direction;
    u8 data_offset;
    u32 crc;
    
    u8 data[valid_data_bytes];
};

fn format_bus_load(u16 bus_load) {
    return std::format("{}%", float(bus_load) / 100.f);
};
struct can_statistic {
    u16 channel;
    // Bus load in 1/100 percent
    u16 bus_load [[format("format_bus_load")]];
    
    u32 standard_data_frames;
    u32 extended_data_frames;
    
    u32 standard_remote_frames;
    u32 extended_remote_frames;
    
    u32 error_frames;
    u32 overload_frames;
    
    u32 reserved;
};

struct can_driver_error {
    u16 channel;
    u8 tx_errors;
    u8 rx_errors;
    u32 error_code;
};

enum app_text_source : u32 {
    comment = 0,
    database_info = 1,
    metadata = 2,
};
enum database_bus_type : u8 {
    can = 1,
    lin = 5,
    most = 6,
    flexray = 7,
    j1708 = 9,
    ethernet = 10,
    wlan = 13,
    afdx = 14,
};
bitfield app_text_database_info {
    version : 8;
    channel_num : 8;
    database_bus_type bus_type : 8;
    is_can_fd : 1;
    padding : 7;
};
struct app_text {
    app_text_source source;
    if (source == 1)
        app_text_database_info database_info;
    else
        padding[4]; // TODO: This is not necessarily padding, there's data here
    u32 text_length;
    padding[4];
    char text[text_length];
};

// No idea what this is or does
struct restore_point_container {
    u8 rpc[14];
    u16 data_len;
    u8 data[data_len];
};

enum compression_method : u16 {
    no_compression = 0,
    zlib = 2,
};

// The following section contains all of the decompressed data at once
std::mem::Section decompressed_data = std::mem::create_section("Decompressed data");
// This section is used only for decompressing data
std::mem::Section zlib_decompress_result = std::mem::create_section("zlib decompress result");

struct log_container {
    u64 container_begin = $;

    compression_method compression_method;
    padding[2];
    padding[4];
    u32 uncompressed_size;
    padding[4];

    if (compression_method == compression_method::zlib) {
        std::mem::set_section_size(zlib_decompress_result, uncompressed_size);

        // Create a pattern that defines the compressed array data
        auto compressed_byte_len = parent.header.object_size - parent.header.header_size - ($ - container_begin);
        u8 compressed[compressed_byte_len];
        if (uncompressed_size != 0)
            padding[parent.header.object_size % 4]; // Idk, the format wants this... for some reason

        std::assert(hex::dec::zlib_decompress(compressed, zlib_decompress_result) == compressed_byte_len,
            "zlib decompress needs to succeed");

        // Copy the decompressed data to the end of the section
        std::mem::copy_section_to_section(zlib_decompress_result, 0,
            decompressed_data, std::mem::get_section_size(decompressed_data),
            std::mem::get_section_size(zlib_decompress_result));
    } else if (compression_method == compression_method::no_compression) {
        u8 data[uncompressed_size];
        std::mem::copy_value_to_section(data, decompressed_data, std::mem::get_section_size(decompressed_data));
    } else {
        std::assert(false, "Invalid/unknown compression method");
    }
};

enum object_flags : u32 {
    // Timestamps are stored with a unit of 10us (10 microseconds)
    time_10_us = 1,
    // Timestamps are stored with a unit of 1ns (1 nanosecond)
    time_1_ns = 2,
};

enum timestamp_status : u8 {
    // Means original timestamps are valid
    orig = 0x01,
    // Timestamp is generated by software (1) or by hardware (0)
    swhw = 0x02,
    user = 0x10,
};

struct obj_v1_header {
    object_flags flags;
    u16 client_index;
    u16 object_version;
    u64 timestamp;
};
struct obj_v2_header {
    object_flags flags;
    timestamp_status timestamp_status;
    padding[1];
    u16 object_version;
    u64 object_timestamp;
    u64 original_timestamp;
};

struct obj_header {
    type::Magic<"LOBJ"> magic; // 4C 4F 42 4A
    u16 header_size;
    u16 header_version;
    u32 object_size;
    object_type object_type;

    std::assert(header_version == 1 || header_version == 2, "Invalid/unknown header version");
};

struct obj_struct {
    auto object_begin = $;
    obj_header header [[inline]];

    if (header.object_type == object_type::log_container) {
        // Log containers seem to never include additional V1 or V2 headers
        log_container log [[inline]];
    } else {
        if (header.header_version == 1)
            obj_v1_header v1_header [[inline]];
        else if (header.header_version == 2)
            obj_v2_header v2_header [[inline]];

        match(header.object_type) {
            (object_type::can_message): {
                can_msg message [[inline]];
            }
            (object_type::can_statistic): {
                can_statistic statistics [[inline]];
            }
            (object_type::can_driver_error): {
                can_driver_error errors [[inline]];
            }
            (object_type::can_message2): {
                can_msg2 message [[inline]];
            }
            (object_type::can_fd_message): {
                can_fd_msg message [[inline]];
            }
            (object_type::can_fd_message_64): {
                can_fd_msg_64 message [[inline]];
                padding[header.object_size - ($ - object_begin)]; // TODO: This pattern doesn't support the extra data for this object
            }
            (object_type::app_text): {
                app_text text [[inline]];
                padding[header.object_size % 4];
            }
            (object_type::restore_point_container): {
                restore_point_container rpc [[inline]];
            }
            (_): u8 bytes[header.object_size - header.header_size];
        }
    }
};

enum application_id : u8 {
    unknown = 0,
    canalyzer = 1,
    canoe = 2,
    canstress = 3,
    canlog = 4,
    canape = 5,
    cancasexl = 6,
    vlconfig = 7,
    porsche_logger = 200,
    caetec_logger = 201,
    vector_net_sim = 202,
    ipetronik_logger = 203,
    rtpk = 204,
    piketec = 205,
    sparks = 206,
};

fn format_api_version(u32 api_version) {
    return std::format("{}.{}.{}",
        api_version / 1000000,
        (api_version % 1000000) / 1000,
        (api_version % 1000) / 100);
};

// Mostly just the zlib compression levels, but with some extras
enum compression_level : u8 {
    no_compression = 0,
    best_speed = 1,
    default_compression = 6,
    best_compression = 9,
    // This means that the file contains only log containers, usually compressed at level 6
    default_container_compression = 10,
};

struct timestamp {
    u16 year;
    u16 month;
    u16 day_of_week;
    u16 day;
    u16 hour;
    u16 minute;
    u16 second;
    u16 millisecond;
} [[format("format_timestamp")]];
fn format_timestamp(timestamp ts) {
    return std::format("{}-{}-{}_{}-{}-{}",
        ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second);
};

struct file_header {
    type::Magic<"LOGG"> magic; // 4C 4F 47 47
    u32 header_length;

    u32 api_version [[format("format_api_version")]];
    application_id app_id;
    compression_level compression_level;
    u8 app_major;
    u8 app_minor;

    u64 file_length;
    u64 uncompressed_length;
    u32 object_count;
    u32 application_build;

    timestamp start_timestamp;
    timestamp stop_timestamp;

    u64 restore_point_offset; // ?
} [[inline]];

struct file_layout {
    file_header header;
    padding[header.header_length - sizeof(header)];
    obj_struct objects[while($ < std::mem::size())];

    // Decode all objects from the zlib compressed data
    if (std::mem::get_section_size(decompressed_data) != 0)
        obj_struct decompressed_objects[header.object_count] @ 0x00 in decompressed_data;
} [[inline]];

file_layout file @ 0x00;

std::assert_warn(std::mem::size() == file.header.file_length, "file size mismatch");
