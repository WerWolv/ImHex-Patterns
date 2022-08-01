#include <std/io.pat>

namespace std::time {

	struct Time {
		u8 sec;
		u8 min;
		u8 hour;
		u8 mday;
		u8 mon;
		u16 year;
		u8 wday;
		u16 yday;
		bool isdst;
	} [[sealed]];
	
	union TimeConverter {
		Time time;
		u128 value;
	};
	
	using EpochTime = u128;

	enum TimeZone : u8 {
		Local,
		UTC
	};

	fn epoch() {
		return builtin::std::time::epoch();
	};
	
	fn to_local(EpochTime epoch_time) {
		TimeConverter converter;
		
		converter.value = builtin::std::time::to_local(epoch_time);
	
		return converter.time;
	};
	
	fn to_utc(EpochTime epoch_time) {
		TimeConverter converter;
		
		converter.value = builtin::std::time::to_utc(epoch_time);
	
		return converter.time;
	};


	fn now(TimeZone time_zone = TimeZone::Local) {
		TimeConverter converter;
	
		if (time_zone == TimeZone::Local)
			converter.value = builtin::std::time::to_local(std::time::epoch());
		else if (time_zone == TimeZone::UTC)
			converter.value = builtin::std::time::to_utc(std::time::epoch());
		else
			converter.value = 0x00;
			
		return converter.time;
	};
	
	fn format(Time time, str format_string = "%c") {
		TimeConverter converter;
		converter.time = time;
	
		return builtin::std::time::format(format_string, converter.value);
	};
}