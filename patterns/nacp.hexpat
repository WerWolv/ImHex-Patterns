#pragma author WerWolv
#pragma description Nintendo Switch NACP files

#pragma endian little

#include <std/sys.pat>
#include <std/io.pat>

struct ApplicationTitle {
	char name[0x200];
	char publisher[0x100];
};

enum VideoCapture : u8 {
	Disabled  = 0,
	Enabled   = 1,
	Automatic = 2
};

enum PlayLogPolicy : u8 {
	All 			= 0,
	LogOnly 		= 1,
	None 			= 2,
	InputFlagSet 	= 3
};

enum PlayLogQueryCapability : u8 {
	None 		= 0,
	WhiteList 	= 1,
	All 		= 2
};

struct ApplicationNeighborDetectionClientConfiguration {
	u8 send_group_configuration[0x18];
	u8 receivable_group_configurations[0x180];
};

struct ApplicationJitConfiguration {
	u64 flags;
	u64 memory_size;
};

bitfield SupportedLanguages {
	american_english 		: 1;
	british_english 		: 1;
	japanese 				: 1;
	french 					: 1;
	herman 					: 1;
	latin_american_spanish 	: 1;
	spanish 				: 1;
	italian 				: 1;
	dutch 					: 1;
	canadian_french			: 1;
	portuguese				: 1;
	russian					: 1;
	korean					: 1;
	traditional_chinese		: 1;
	simplified_chinese		: 1;
	padding 				: 17;
};

struct Nacp {
	ApplicationTitle american_english_title;
	ApplicationTitle british_english_title;
	ApplicationTitle japanese_title;
	ApplicationTitle french_title;
	ApplicationTitle herman_title;
	ApplicationTitle latin_american_spanish_title;
	ApplicationTitle spanish_title;
	ApplicationTitle italian_title;
	ApplicationTitle dutch_title;
	ApplicationTitle canadian_french_title;
	ApplicationTitle portuguese_title;
	ApplicationTitle russian_title;
	ApplicationTitle korean_title;
	ApplicationTitle traditional_chinese_title;
	ApplicationTitle simplified_chinese_title;
	ApplicationTitle reserved_title;
	char isbn[0x25];
	bool startup_user_account;
	bool user_account_switch_lock;
	u8 add_on_content_registration_type;
	u32 attribute_flag;
	be SupportedLanguages supported_language_flag;
	u32 parential_control_flag;
	bool screenshot;
	VideoCapture video_capture;
	bool data_loss_confirmation;
	PlayLogPolicy play_log_policy;
	u64 presence_group_id;
	char rating_age[0x20];
	char display_version[0x10];
	u64 add_on_content_base_id;
	u64 save_data_owner_id;
	u64 user_account_save_data_size;
	u64 user_account_save_data_journal_size;
	u64 device_save_data_size;
	u64 device_save_data_journal_size;
	u64 bcat_delivery_cache_storage_size;
	u64 application_error_code_category;
	u64 local_communication_id[8];
	u8 logo_type;
	u8 logo_handling;
	u8 runtime_add_on_content_install;
	u8 runtime_parameter_delivery;
	padding[2];
	bool crash_report;
	bool hdcp;
	u64 pseudo_device_id_seed;
	u8 bcat_passprase[0x41];
	bool startup_user_account_option;
	u8 user_accout_save_data_operation[6];
	u64 user_account_save_data_size_max;
	u64 user_account_save_data_journal_size_max;
	u64 device_save_data_size_max;
	u64 device_save_data_journal_size_max;
	u64 temporary_storage_size;
	u64 cache_storage_size;
	u64 cache_storage_journal_size;
	u64 cache_storage_data_and_journal_size_max;
	u16 cache_storage_index_max;
	padding[6];
	u64 play_log_queryable_application_id[0x10];
	PlayLogQueryCapability play_log_query_capability;
	bool repair;
	u8 program_index;
	bool requires_network_service_license_on_launch;
	padding[4];
	ApplicationNeighborDetectionClientConfiguration neighbor_detection_client_configuration;
	ApplicationJitConfiguration jit_configuration;
	u16 required_add_on_contents_set_binary_descriptor[0x20];
	bool play_report_permission;
	bool crash_screenshot_for_prod;
	bool crash_screenshot_for_dev;
	padding[5];
	u64 accessible_launch_required_version[8];
	padding[0xBB8];
};

Nacp nacp @ 0x00;

std::assert(sizeof(nacp) == 0x4000, "NACP Struct invalid");

fn main() {
	std::print("Application Name:       {}", nacp.american_english_title.name);
	std::print("Application Publisher:  {}", nacp.american_english_title.publisher);
	std::print("Application Version:    {}", nacp.display_version);
	
	if (nacp.device_save_data_size_max > 0)
		std::print("This application has a device save file!");
};