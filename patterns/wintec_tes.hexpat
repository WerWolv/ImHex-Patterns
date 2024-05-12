// Wintec TES file
//
// Wintec produced small GPS-Loggers that created TES files. Each file 
// is a series of timestamps and coordinates. The format is exceedingly
// simple. The same 16 byte struct is repeated from start to finish.
//
// This would be a valid line:
// 01 00   31 F9 DE 60   A0 B1 9C 16   A0 AD 45 0E   88 00
// -----   -----------   -----------   -----------   -----
// flags   timestamp     latitude      longitude     altitude
//
// The line decodes to:
// flag 0x01 -> split mark (start of a new file)
// timestamp 2024-03-15 15:36:49
// latitude 37.936784°
// longitude 23.944746°
// altitude 136m
//
// Made with help from a (since deleted) GPSBabel definition
// https://github.com/GPSBabel/gpsbabel/blob/gpsbabel_1_8_0/wintec_tes.cc

#include "std/mem.pat"
#include "std/string.pat"

using WBTTimestamp;

// helper to format latitude and longitude in a human-readable form
// values are stored in an s32, but are actually scaled 1e-7 degrees.
fn decimalDegrees(s32 input) {
    return double(input)/10000000;
};

// same as above, but outputs a string for readability
fn stringDegrees(s32 input) {
    return std::format("{:f}°", double(input)/10000000);
};

// create the standard iso8601 format from any timestamp
fn iso8601(WBTTimestamp input) {
    return std::format("20{:02d}-{:02d}-{:02d}T{:02d}:{:02d}:{:02d}Z",input.year, input.month, input.day, input.hours, input.minutes, input.seconds);
};


// This 16 bit field is barely used. Only these two are known.
bitfield WBTFlags {
    split: 1 [[comment("start of a new file")]];
    waypoint: 1 [[comment("waypoint button pressed")]];
    padding: 14;
};


// The files store the timestamp in a somewhat uncommon 32 bit format
bitfield WBTTimestamp {
    seconds: 6;
    minutes: 6;
    hours: 5;
    day: 5;
    month: 4;
    year: 6;
} [[format("iso8601")]];


// This is what parses each line of the file. From the very beginning to the very end,
// all data is made up of this 16 byte struct.
struct WBTLine {
    WBTFlags flags;
    WBTTimestamp timestamp [[color("ff0000")]];
    s32 lat [[color("007FFF"), format("stringDegrees")]];
    s32 lon [[color("7F00FF"), format("stringDegrees")]];
    s16 alt [[color("0000FF")]];
} [[hex::visualize("coordinates", decimalDegrees(lat), decimalDegrees(lon))]];


// parsing that whole file start to finish:
WBTLine lines[while(!std::mem::eof())] @ 0x00;
