#pragma author WerWolv
#pragma description Ethernet II Frames (IP Packets)

 #pragma endian big

#include <std/sys.pat>
#include <std/io.pat>

struct MAC {
	u8 octets[6];
} [[format("mac_formatter")]];

fn mac_formatter(MAC mac) {
	return std::format("{0:02X}:{1:02X}:{2:02X}:{3:02X}:{4:02X}:{5:02X}",
		mac.octets[0],
		mac.octets[1],
		mac.octets[2],
		mac.octets[3],
		mac.octets[4],
		mac.octets[5]);
};

enum EtherType : u16 {
	IPv4 						= 0x0800,
	ARP 						= 0x0806,
	WakeOnLAN 					= 0x0842,
	AVTP 						= 0x22F0,
	IETF_TRILL 					= 0x22F3,
	SRP 						= 0x22EA,
	DEC_MOP_RC 					= 0x6002,
	DECnet 						= 0x6003,
	DEC_LAT 					= 0x6004,
	RARP 						= 0x8035,
	AppleTalk 					= 0x809B,
	AppleTalk_AARP 				= 0x80F3,
	VLANTaggedFrame 			= 0x8100,
	SLPP 						= 0x8102,
	VLACP 						= 0x8103,
	IPX 						= 0x8137,
	QNX_Qnet 					= 0x8204,
	IPv6 						= 0x860D,
	EthernetFlowControl 		= 0x8808,
	EthernetSlowProtocols 		= 0x8809,
	CobraNet 					= 0x8819,
	MPLS_Unicast 				= 0x8847,
	MPLS_Multicast 				= 0x8848,
	PPPoE_Discovery 			= 0x8863,
	PPPoE_Session 				= 0x8864,
	HomePlug 					= 0x887B,
	EAPOverLAN 					= 0x888E,
	PROFINET 					= 0x8892,
	HyperSCSI 					= 0x889A,
	ATAOverEthernet 			= 0x88A2,
	EtherCAT 					= 0x88A4,
	ServiceVLANTagIdentifier 	= 0x88A8,
	EthernetPowerlink 			= 0x88AB,
	GOOSE 						= 0x88B8,
	GSE 						= 0x88B9,
	SV 							= 0x88BA,
	MikroTik_RoMON				= 0x88BF,
	LLDP 						= 0x88CC,
	SERCOS_III 					= 0x88CD,
	HomePlugGreenPHY 			= 0x88E1,
	MRP 						= 0x88E3,
	IEEE802_1AE 				= 0x88E5,
	PBB 						= 0x88E7,
	PTP							= 0x88F7,
	NC_SI 						= 0x88F8,
	PRP 						= 0x88FB,
	CFM 						= 0x8902,
	FCoE 						= 0x8906,
	FCoEIP 						= 0x8914,
	RoCE 						= 0x8915,
	TTE 						= 0x891D,
	IEEE_1905_1 				= 0x893A,
	HSR 						= 0x892F,
	ECTP 						= 0x9000,
	RedundancyTag 				= 0xF1C1
};

namespace ip {

	enum Protocol : u8 {
		ICMP 	= 1,
		IGMP 	= 2,
		TCP 	= 6,
		UDP 	= 17,
		ENCAP 	= 41,
		OSPF 	= 89,
		SCTP 	= 132
	};
	
	namespace udp {
	
		struct Packet {
			u16 source_port;
			u16 destination_port;
			u16 length;
			std::assert(length >= 8, "UDP Packet has invalid length");
			u16 checksum;
			u8 data[length - 8];
		};
	
	}
	
	namespace tcp {
	
		bitfield Flags {
			data_offset : 4;
			padding : 3;
			ns : 1;
			cwr : 1;
			ece : 1;
			urg : 1;
			ack : 1;
			psh : 1;
			rst : 1;
			syn : 1;
			fin : 1;
		};
	
		struct Packet {
			u16 source_port;
			u16 destination_port;
			u32 sequence_number;
			u32 ack_number;
			Flags flags [[inline]];
			u16 window_size;
			u16 checksum;
			u16 urgent_pointer;
			
			if (flags.data_offset > 5)
				u8 options[(flags.data_offset - 5) * sizeof(u32)];
				
			u8 data[parent.parent.header.total_length - 40];
		};
	
	}
	
	struct Payload {
		if (parent.protocol == ip::Protocol::UDP)
			udp::Packet packet [[inline]];
		else if (parent.protocol == ip::Protocol::TCP)
			tcp::Packet packet [[inline]];
		else
			std::error(std::format("Unknown protocol: {}", parent.protocol));
	};

}

namespace ipv4 {

	struct Address {
		u8 octets[4];
	} [[format("ipv4::address_formatter")]];
	
	fn address_formatter(Address addr) {
		return std::format("{0}.{1}.{2}.{3}",
			addr.octets[0],
			addr.octets[1],
			addr.octets[2],
			addr.octets[3]);
	};

	bitfield Header {
		version 		: 4;
		ihl 			: 4;
		tos 			: 8;
		total_length 	: 16;
	};
	
	bitfield Flags {
		reserved 		: 1;
		df 				: 1;
		mf 				: 1;
		fragment_offset : 13;
	};
		
	
	struct Packet {
		Header header [[inline]];
		u16 identification;
		Flags flags [[inline]];
		u8 time_to_live;
		ip::Protocol protocol;
		u16 header_checksum;
		
		Address source_ip_address;
		Address destination_ip_address;
		
		if (header.ihl > 5)
			u8 options[(header.ihl - 5) * sizeof(u32)];
			
		ip::Payload payload;
	};
	
}


namespace ipv6 {

	struct Address {
		u16 segments[8];
	} [[format("ipv6::address_formatter")]];
	
	fn address_formatter(Address addr) {
		return std::format("{0:04X}:{1:04X}:{2:04X}:{3:04X}:{4:04X}:{5:04X}:{6:04X}:{7:04X}",
			addr.segments[0],
			addr.segments[1],
			addr.segments[2],
			addr.segments[3],
			addr.segments[4],
			addr.segments[5],
			addr.segments[6],
			addr.segments[7]);
	};

	bitfield Header {
		version 	: 4;
		ds 			: 6;
		ecn 		: 2;
		flow_label 	: 20;
	};
	
	struct Packet {
		Header header [[inline]];
		u16 payload_length;
		ip::Protocol next_header;
		u8 hop_limit;
		
		Address source_address;
		Address destination_address;
		
		ip::Payload payload;
	};

}



struct Payload {
	if (parent.type == EtherType::IPv4)
		ipv4::Packet packet [[inline]];
	else
		std::error(std::format("Unknown payload type: 0x{:04X}", parent.type));
};

bitfield TCI {
	pcp : 3;
	dei : 1;
	vid : 12;
};

struct EthernetIIFrame {
	MAC destination_address;
	MAC source_address;
	
	u16 possible_tpid [[no_unique_address, hidden]];
	if (possible_tpid == EtherType::VLANTaggedFrame) {
		u16 tpid;
		TCI tci [[inline]];
	}
	
	EtherType type;
	
	Payload payload;
	std::assert(sizeof(payload) >= 40 && sizeof(payload) <= 1500, std::format("Payload size out of range: {}", sizeof(payload)));
	
	u32 frame_check_sequence;
};

EthernetIIFrame frame @ 0x00;
