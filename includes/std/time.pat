#pragma once

import std.io;

/*!
	Library to handle time and date related operations.
*/

namespace std::time;

/**
	A structured representation of a time and date.
*/
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

/**
	A helper type to convert between Time and u128.
*/
union TimeConverter {
	Time time;
	u128 value;
};

/**
	A type to represent a time in seconds since the epoch.
*/
using EpochTime = u32;

/**
	A type to represent a time zone.
*/
enum TimeZone : u8 {
	Local,
	UTC
};

/**
	A type to represent a DOS date.
*/
bitfield DOSDate {
	day: 5;
	month: 4;
	year: 7;
} [[sealed]];

/**
	A type to represent a DOS time.
*/
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


/**
	Returns the current time in seconds since the epoch.
	@return The current time in seconds since the epoch.
*/
fn epoch() {
	return builtin::std::time::epoch();
};

/**
	Converts a time in seconds since the epoch to a local time.
	@param epoch_time The time in seconds since the epoch.
	@return The local time.
*/
fn to_local(EpochTime epoch_time) {
	le TimeConverter converter;

	converter.value = builtin::std::time::to_local(epoch_time);

	return converter.time;
};

/**
	Converts a time in seconds since the epoch to a UTC time.
	@param epoch_time The time in seconds since the epoch.
	@return The UTC time.
*/
fn to_utc(EpochTime epoch_time) {
	le TimeConverter converter;

	converter.value = builtin::std::time::to_utc(epoch_time);

	return converter.time;
};

/**
	Queries the current time in the specified time zone.
	@param time_zone The time zone to query.
	@return The current time in the specified time zone.
*/
fn now(TimeZone time_zone = TimeZone::Local) {
	le TimeConverter converter;

	if (time_zone == TimeZone::Local)
		converter.value = builtin::std::time::to_local(std::time::epoch());
	else if (time_zone == TimeZone::UTC)
		converter.value = builtin::std::time::to_utc(std::time::epoch());
	else
		converter.value = 0x00;

	return converter.time;
};

/**
	Converts a value to a DOS date.
	@param value The value to convert.
	@return The DOS date.
*/
fn to_dos_date(u16 value) {
	le impl::DOSDateConverter converter;

	converter.value = value;

	return converter.date;
};

/**
	Converts a value to a DOS time.
	@param value The value to convert.
	@return The DOS time.
*/
fn to_dos_time(u16 value) {
	le impl::DOSTimeConverter converter;

	converter.value = value;

	return converter.time;
};

/**
	Converts a FILETIME to unix time.
	@param value The value to convert.
	@return Timestamp formatted as unix time.
*/
fn filetime_to_unix(u64 value) {
	return value / 10000000 - 11644473600;
};

/**
	Formats a time according to the specified format string.
	@param time The time to format.
	@param format_string The format string to use.
	@return The formatted time.
*/
fn format(Time time, str format_string = "%c") {
	le TimeConverter converter;
	converter.time = time;

	return builtin::std::time::format(format_string, converter.value);
};

/**
	Formats a DOS date according to the specified format string.
	@param date The DOS date to format.
	@param format_string The format string to use.
	@return The formatted DOS date.
*/
fn format_dos_date(DOSDate date, str format_string = "{}/{}/{}") {
	return std::format(format_string, date.day, date.month, date.year + 1980);
};

/**
	Formats a DOS time according to the specified format string.
	@param time The DOS time to format.
	@param format_string The format string to use.
	@return The formatted DOS time.
*/
fn format_dos_time(DOSTime time, str format_string = "{:02}:{:02}:{:02}") {
	return std::format(format_string, time.hours, time.minutes, time.seconds * 2);
};