#pragma once

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

	bitfield DOSDate {
		day: 5;
		month: 4;
		year: 7;
	} [[sealed]];

	bitfield DOSTime {
		seconds: 5;
		minutes: 6;
		hours: 5;
	} [[sealed]];

	namespace impl {

		union DOSDateConverter {
			DOSDate date;
			u16 value;
		};

		union DOSTimeConverter {
			DOSTime time;
			u16 value;
		};

	}

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

	fn to_dos_date(u16 value) {
		impl::DOSDateConverter converter;

		converter.value = value;

		return converter.date;
	};

	fn to_dos_time(u16 value) {
		impl::DOSTimeConverter converter;

		converter.value = value;

		return converter.time;
	};

	fn format(Time time, str format_string = "%c") {
		TimeConverter converter;
		converter.time = time;

		return builtin::std::time::format(format_string, converter.value);
	};

	fn format_dos_date(DOSDate date, str format_string = "{}/{}/{}") {
		return std::format(format_string, date.day, date.month, date.year + 1980);
	};

	fn format_dos_time(DOSTime time, str format_string = "{:02}:{:02}:{:02}") {
		return std::format(format_string, time.hours, time.minutes, time.seconds * 2);
	};

}
