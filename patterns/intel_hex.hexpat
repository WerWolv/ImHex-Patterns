/* If you have no delimiters between data records then remove 
 * the null_bytes field in the data_packet struct.
 * Set the array at the bottom to the highest index + 1 in the Pattern Data view
 * NOTE: these were ascii hex values for me, so use the calculator tool to convert 
 * values
*/
#pragma MIME text/plain
#pragma endian big

enum FileType: u16 {
	Data = 0x3030,
	EOF = 0x3031,
	Extended_Segment_Address = 0x3032,
	Start_Segment_Address = 0x3033,
	Extended_Linear_Address = 0x3034,
	Start_Linear_Address = 0x3035
};

struct Bytes {
	u8 HOB [[color("00FF6699")]];
	u8 LOB [[color("00FF6699")]];
};

struct data_packet {
	char start_code [[color("00EFECCA")]];
	Bytes byte_count [[color("00A9CBB7")]];
	u32 address [[color("00F7FF58")]];
	FileType recordType [[color("00FF934F")]];
	
	// both not A
	if (byte_count.HOB < 65 && byte_count.LOB < 65) {
		u16 data[((byte_count.HOB - 48) * 16) 
			+ (byte_count.LOB - 48)] [[color("0095B46A")]]; 
	// HOB is A but LOB is not
	} else if (byte_count.HOB >= 65 && byte_count.LOB < 65) {
		u16 data[((byte_count.HOB - 55) * 16) 
			+ (byte_count.LOB - 48)] [[color("0095B46A")]]; 
	// LOB is A but HOB is not
	} else if (byte_count.HOB < 65 && byte_count.LOB >= 65) {
		u16 data[((byte_count.HOB - 48) * 16) 
			+ (byte_count.LOB - 55)] [[color("0095B46A")]];
	// both are A
	} else {
		u16 data[((byte_count.HOB - 55) * 16) 
			+ (byte_count.LOB - 55)] [[color("0095B46A")]]; 
	}
	
	u16 checksum [[color("0045F0DF")]];
	u16 null_bytes [[color("005E565A")]];
};

data_packet data[1418] @ 0x00;