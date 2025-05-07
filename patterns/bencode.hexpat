#pragma author WerWolv
#pragma description Torrent data (Bencode)

#pragma MIME application/x-bittorrent

import std.ctype;
import std.mem;
import std.string;

namespace bencode {

	struct ASCIIDecimal {
		char value[while(std::ctype::isdigit(std::mem::read_unsigned($, 1)))];
	} [[sealed, format("bencode::format_ascii_decimal"), transform("bencode::format_ascii_decimal")]];

	fn format_ascii_decimal(ASCIIDecimal adsasd) {
		return std::string::parse_int(adsasd.value, 10);
	};

	enum Type : u8 {
		Integer = 'i',
		Dictionary = 'd',
		List = 'l',

		String0 = '0',
		String1 = '1',
		String2 = '2',
		String3 = '3',
		String4 = '4',
		String5 = '5',
		String6 = '6',
		String7 = '7',
		String8 = '8',
		String9 = '9'
	};

	struct String {
		ASCIIDecimal length;
		char separator [[hidden]];
		char value[length];
	} [[sealed, format("bencode::format_string"), transform("bencode::format_string")]];

	fn format_string(String string) {
		return string.value;
	};

	using Bencode;
	using Value;

	struct DictionaryEntry {
		String key;
		Value value;
	};

	struct Value {
		Type type;

		if (type == Type::Dictionary) {
			DictionaryEntry entry[while(std::mem::read_unsigned($, 1) != 'e')];
			char end;
		} else if (type == Type::List) {
			  Value entry[while(std::mem::read_unsigned($, 1) != 'e')];
			  char end;
		} else if (type == Type::Integer) {
			ASCIIDecimal value;
			char end;
		} else {
			$ -= 1;
			String value;
		}
	};

	struct Bencode {
		Value value[while(!std::mem::eof())] [[inline]];
		char end;
	};

}

bencode::Bencode bencode @ 0x00;
