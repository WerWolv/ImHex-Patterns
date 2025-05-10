#pragma description PcapNG 
#pragma MIME application/vnd.tcpdump.pcapng 
#pragma author 5h4rrK

import std.mem;
import std.core;
import std.math;
import std.io;

#define MAX_VALUE_U64 0xffffffffffffffff

fn format_version(auto version){
    return std::format(
        "{}.{}", version.major, version.minor
    );
};


fn is_valid_len(auto val){
    if (val == MAX_VALUE_U64){
        return std::format("[Not Specified]");
    }
    else{
        return val;   
    }
};

enum PcapOrder : u32{
    Little = 0x1a2b3c4d,
    Big = 0x4d3c2b1a,
};

struct Version {
    u16     major;
    u16     minor;
};

enum BlockType : u32{
    // Mandatory Blocks
    SectionHeader    = 0x0A0D0D0A,
    InterfaceDesc    = 0x00000001,

    // Optional Blocks
    SimplePacket     = 0x00000003,
    NameResolution   = 0x00000004,
    InterfaceStats   = 0x00000005,
    EnhancedPacket   = 0x00000006,
    Custom           = 0x00000BAD,
    CustomNoCopy     = 0x40000BAD,
    Systemd          = 0x00000009,
    Decryption       = 0x0000000A,

    // Obsolete Block
    Packet           = 0x00000002,

    // Reserved & Misc
    Reserved         = 0x00000000,
    IRIGTimestamp    = 0x00000007,
    AFDXInfo         = 0x00000008,

    // Hone Project Specific
    HoneMachine      = 0x00000101,
    HoneConnEvent    = 0x00000102,

    // Sysdig Specific
    SysdigMachine      = 0x00000201,
    SysdigProcessV1    = 0x00000202,
    SysdigFDList       = 0x00000203,
    SysdigEvent        = 0x00000204,
    SysdigIFList       = 0x00000205,
    SysdigUserList     = 0x00000206,
    SysdigProcessV2    = 0x00000207,
    SysdigEventFL      = 0x00000208,
    SysdigProcessV3    = 0x00000209,
    SysdigProcessV4    = 0x00000210,
    SysdigProcessV5    = 0x00000211,
    SysdigProcessV6    = 0x00000212,
    SysdigProcessV7    = 0x00000213,

};

enum LinkType : u16 {
    LINKTYPE_NULL = 0,
    LINKTYPE_ETHERNET = 1,
    LINKTYPE_AX25 = 3,
    LINKTYPE_IEEE802_5 = 6,
    LINKTYPE_ARCNET_BSD = 7,
    LINKTYPE_SLIP = 8,
    LINKTYPE_PPP = 9,
    LINKTYPE_FDDI = 10,
    LINKTYPE_PPP_HDLC = 50,
    LINKTYPE_PPP_ETHER = 51,
    LINKTYPE_ATM_RFC1483 = 100,
    LINKTYPE_RAW = 101,
    LINKTYPE_C_HDLC = 104,
    LINKTYPE_IEEE802_11 = 105,
    LINKTYPE_FRELAY = 107,
    LINKTYPE_LOOP = 108,
    LINKTYPE_LINUX_SLL = 113,
    LINKTYPE_LTALK = 114,
    LINKTYPE_PFLOG = 117,
    LINKTYPE_IEEE802_11_PRISM = 119,
    LINKTYPE_IP_OVER_FC = 122,
    LINKTYPE_SUNATM = 123,
    LINKTYPE_IEEE802_11_RADIOTAP = 127,
    LINKTYPE_ARCNET_LINUX = 129,
    LINKTYPE_APPLE_IP_OVER_IEEE1394 = 138,
    LINKTYPE_MTP2_WITH_PHDR = 139,
    LINKTYPE_MTP2 = 140,
    LINKTYPE_MTP3 = 141,
    LINKTYPE_SCCP = 142,
    LINKTYPE_DOCSIS = 143,
    LINKTYPE_LINUX_IRDA = 144,
    LINKTYPE_IEEE802_11_AVS = 163,
    LINKTYPE_BACNET_MS_TP = 165,
    LINKTYPE_PPP_PPPD = 166,
    LINKTYPE_GPRS_LLC = 169,
    LINKTYPE_GPF_T = 170,
    LINKTYPE_GPF_F = 171,
    LINKTYPE_LINUX_LAPD = 177,
    LINKTYPE_MFR = 182,
    LINKTYPE_BLUETOOTH_HCI_H4 = 187,
    LINKTYPE_USB_LINUX = 189,
    LINKTYPE_PPI = 192,
    LINKTYPE_IEEE802_15_4_WITHFCS = 195,
    LINKTYPE_SITA = 196,
    LINKTYPE_ERF = 197,
    LINKTYPE_BLUETOOTH_HCI_H4_WITH_PHDR = 201,
    LINKTYPE_AX25_KISS = 202,
    LINKTYPE_LAPD = 203,
    LINKTYPE_PPP_WITH_DIR = 204,
    LINKTYPE_C_HDLC_WITH_DIR = 205,
    LINKTYPE_FRELAY_WITH_DIR = 206,
    LINKTYPE_LAPB_WITH_DIR = 207,
    LINKTYPE_IPMB_LINUX = 209,
    LINKTYPE_FLEXRAY = 210,
    LINKTYPE_IEEE802_15_4_NONASK_PHY = 215,
    LINKTYPE_USB_LINUX_MMAPPED = 220,
    LINKTYPE_FC_2 = 224,
    LINKTYPE_FC_2_WITH_FRAME_DELIMS = 225,
    LINKTYPE_IPNET = 226,
    LINKTYPE_CAN_SOCKETCAN = 227,
    LINKTYPE_IPV4 = 228,
    LINKTYPE_IPV6 = 229,
    LINKTYPE_IEEE802_15_4_NOFCS = 230,
    LINKTYPE_DBUS = 231,
    LINKTYPE_DVB_CI = 235,
    LINKTYPE_MUX27010 = 236,
    LINKTYPE_STANAG_5066_D_PDU = 237,
    LINKTYPE_NFLOG = 239,
    LINKTYPE_NETANALYZER = 240,
    LINKTYPE_NETANALYZER_TRANSPARENT = 241,
    LINKTYPE_IPOIB = 242,
    LINKTYPE_MPEG_2_TS = 243,
    LINKTYPE_NG40 = 244,
    LINKTYPE_NFC_LLCP = 245,
    LINKTYPE_INFINIBAND = 247,
    LINKTYPE_SCTP = 248,
    LINKTYPE_USBPCAP = 249,
    LINKTYPE_RTAC_SERIAL = 250,
    LINKTYPE_BLUETOOTH_LE_LL = 251,
    LINKTYPE_NETLINK = 253,
    LINKTYPE_BLUETOOTH_LINUX_MONITOR = 254,
    LINKTYPE_BLUETOOTH_BREDR_BB = 255,
    LINKTYPE_BLUETOOTH_LE_LL_WITH_PHDR = 256,
    LINKTYPE_PROFIBUS_DL = 257,
    LINKTYPE_PKTAP = 258,
    LINKTYPE_EPON = 259,
    LINKTYPE_IPMI_HPM_2 = 260,
    LINKTYPE_ZWAVE_R1_R2 = 261,
    LINKTYPE_ZWAVE_R3 = 262,
    LINKTYPE_WATTSTOPPER_DLM = 263,
    LINKTYPE_ISO_14443 = 264,
    LINKTYPE_RDS = 265,
    LINKTYPE_USB_DARWIN = 266,
    LINKTYPE_SDLC = 268,
    LINKTYPE_LORATAP = 270,
    LINKTYPE_VSOCK = 271,
    LINKTYPE_NORDIC_BLE = 272,
    LINKTYPE_DOCSIS31_XRA31 = 273,
    LINKTYPE_ETHERNET_MPACKET = 274,
    LINKTYPE_DISPLAYPORT_AUX = 275,
    LINKTYPE_LINUX_SLL2 = 276,
    LINKTYPE_OPENVIZSLA = 278,
    LINKTYPE_EBHSCR = 279,
    LINKTYPE_VPP_DISPATCH = 280,
    LINKTYPE_DSA_TAG_BRCM = 281,
    LINKTYPE_DSA_TAG_BRCM_PREPEND = 282,
    LINKTYPE_IEEE802_15_4_TAP = 283,
    LINKTYPE_DSA_TAG_DSA = 284,
    LINKTYPE_DSA_TAG_EDSA = 285,
    LINKTYPE_ELEE = 286,
    LINKTYPE_Z_WAVE_SERIAL = 287,
    LINKTYPE_USB_2_0 = 288,
    LINKTYPE_ATSC_ALP = 289,
    LINKTYPE_ETW = 290
};

enum SHBType : u16{
    EndOfOpt = 0x0,
    Hardware = 0x2,
    OS = 0x3,
    Application = 0x4,
    EndOfOpt = 0x0
};

enum IDHType : u16 {
    EndOfOpt        = 0,
    Name            = 2,   // UTF-8 device name (e.g., "eth0")
    Description     = 3,   // UTF-8 device description
    IPv4Addr        = 4,   // IPv4 address + netmask (8 bytes)
    IPv6Addr        = 5,   // IPv6 address + prefix len (17 bytes)
    MACAddr         = 6,   // MAC address (6 bytes)
    EUIAddr         = 7,   // EUI-64 address (8 bytes)
    Speed           = 8,   // Interface speed (bps, 8 bytes)
    TimestampRes    = 9,   // Timestamp resolution (1 byte)
    TimeZone        = 10,  // Time zone (4 bytes)
    Filter          = 11,  // Capture filter string
    OS              = 12,  // OS name (UTF-8 string)
    FCSLength       = 13,  // Frame Check Sequence length (1 byte)
    TimestampOffset = 14,  // Timestamp offset (8 bytes)
    Hardware        = 15,  // Variable length
    TxSpeed         = 16,  // 8bytes
    RxSpeed         = 17   // 8bytes
};

enum NameResolutionType: u16 {
    EndOfRecord = 0x00,
    IPv4 = 0x01,
    IPv6 = 0x02 
};

enum InterfaceStatsType : u16 {
    EndOfOpt       = 0,
    Comment        = 1,  // isb_comment
    StartTime      = 2,  // isb_starttime
    EndTime        = 3,  // isb_endtime
    IfRecv         = 4,  // isb_ifrecv
    IfDrop         = 5,  // isb_ifdrop
    FilterAccept   = 6,  // isb_filteraccept
    OSdrop         = 7,  // isb_osdrop
    UserDeliver    = 8,  // isb_usrdeliv
};

enum EnhancedPacketType : u16 {
    EndOfOpt = 0x0,
    Flags = 0x2,
    Hash = 0x3,
    DropCount = 0x4,
    PacketId = 0x5,
    Queue  = 0x6,
    Verdict  = 0x7,
};

enum PacketBlockType : u16 {
    Flags = 0x2,
    Hash = 0x3,
    EndOfOpt = 0x0,
};


struct Option {

    if (this.parent.block_type == BlockType::SectionHeader) {
        SHBType option_type;
    } else if(this.parent.block_type == BlockType::InterfaceDesc) {
        IDHType option_type;
    } else if (this.parent.block_type == BlockType::NameResolution) {
        NameResolutionType record_type[[name("record")]];
    } else if (this.parent.block_type == BlockType::InterfaceStats){
        InterfaceStatsType option_type;
    } else if (this.parent.block_type == BlockType::EnhancedPacket) {
        EnhancedPacketType option_type;
    } else if (this.parent.block_type == BlockType::Packet){
        PacketBlockType option_type;
    } 
    u16 option_len;

    if (option_len > 0){
        char data[option_len];
    } else{ 
        return;
    }
    // u8 pad_size = (4 - ( $ % 4 ));
    u8 pad_size = (4 - ( $ % 4 )) % 4;
    // if(this.parent.block_type == BlockType::InterfaceStats) {
    //     std::print("Current Pos {:#x} {:#x}",$, pad_size);
    // }
    
    $ = $ + pad_size;
};  


struct SectionHeaderBlock {
    BlockType block_type;
    u32 length;
    PcapOrder sectionbyteorder;
    Version version [[name("Version"), format("format_version")]];
    u64 section_len [[name("SectionLen"), format("is_valid_len")]];
    u64 prev_pos = $;
    Option options [ while( $ < (prev_pos + length - 28))];
    u32 block_length [[name("BlockLen")]];

};


struct NameResolutionBlock {
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    u64 prev_pos = $;
    Option records [ while($ < (prev_pos + block_len1 - 12)) ];
    u32 block_len2[[name("BlockLen2")]];
};

struct SystemJournalExportBlock{
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    char data[block_len1]; 
    $ = $ + (4 - ($ % 4 ) ); // Padding 
    u32 block_len2[[name("BlockLen2")]];
};

struct CustomBlock{
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    u32 pen[[name("PrivateEnterpriseNumber")]];
    char data[block_len1]; 
    u64 prev_pos = $;
    $ = $ + (4 - ($ % 4 ) ); // Padding 
    Option options [while($ < (prev_pos + block_len1 - 16))] [[name("Options")]];
    u32 block_len2[[name("BlockLen2")]];
};  

struct InterfaceBlock{
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    LinkType link_type [[name("LinkType")]];
    u16 reserved [[name("Reserved")]];
    u32 snap_len [[name("SnapLen")]];
    u64 prev_pos = $;
    Option options [ while( $ < (prev_pos + block_len1 - 20))];
    u32 block_len2[[name("BlockLen2")]];
};

struct EnhancedPacketBlock{
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    u32 interface_id[[name("InterfaceID")]];
    u64 timestamp[[name("Timestamp")]];
    u32 captured_len[[name("CapturedLen")]];
    u32 pkt_len[[name("PacketLen")]];
    char data[captured_len][[name("Data")]];
    // 32 (BlockType + BlockLen1 + InterfaceID + Timestamp + CapturedLen + PacketLen + BlockLen2)
    $ = $ + (block_len1 - captured_len - 32);
    u64 prev_pos = $;
    // Current Pos - Prev Pos - 4 (BlockLen2) 
    // std::print("Option Size ::  {:#x}", ($  - prev_pos));
    if (($  - prev_pos )  > 0) {
        Option options [ while( $ <  ( prev_pos + ($ - prev_pos ) ) ) ];
    }
    u32 block_len2[[name("BlockLen2")]];

};

struct SimplePacketBlock {
    BlockType block_type[[name("BlockType")]]; 
    u32 block_len1[[name("BlockLen1")]];
    u32 pkt_len[[name("PacketLen")]];
    char data[[name("Data")]];
    u8 pad_size = (4 - ( $ % 4 )) % 4;
    $ = $ + pad_size;
    u32 block_len2[[name("BlockLen2")]];
};

// Obsolete!
struct PacketBlock {
    BlockType block_type[[name("BlockType")]]; 
    u32 block_len1[[name("BlockLen1")]];
    u16 interface_id[[name("InterfaceID")]];  
    u16 drop_count[[name("DropCount")]];  
    u64 timestamp[[name("Timestamp")]];
    u32 captured_len[[name("CapturedLen")]];
    u32 pkt_len[[name("PacketLen")]];
    if (block_len1 > 32){
        char data[captured_len];
    }
    u32 block_len2[[name("BlockLen2")]];
};

enum CompressionType: u8 {
    Uncompressed = 0x0,
    LempelZiv = 0x1,
    Gzip = 0x2
};

enum EncryptionType : u8 {
    // Experimental
};

enum FixedLengthType : u8 {
    // Experimental
};

// Experimental
struct CompressionBlock{
    BlockType block_type[[name("BlockType")]]; 
    u32 block_len1[[name("BlockLen1")]];  
    CompressionType comp_type [[name("Compresssion")]];
    char data[block_len1];
    u32 block_len2[[name("BlockLen2")]];  
};

// Experimental
struct EncryptionBlock{
    BlockType block_type[[name("BlockType")]]; 
    u32 block_len1[[name("BlockLen1")]];  
    EncryptionType comp_type [[name("Encryption")]];
    char data[block_len1];
    u32 block_len2[[name("BlockLen2")]];  
};

// Experimental
struct FixedLengthBlock {
    BlockType block_type[[name("BlockType")]]; 
    u32 block_len1[[name("BlockLen1")]];  
    FixedLengthType comp_type [[name("FixedLength")]];
    char data[block_len1];
    u32 block_len2[[name("BlockLen2")]];    
};

struct InterfaceStatsBlock {
    BlockType block_type[[name("BlockType")]];
    u32 block_len1[[name("BlockLen1")]];
    u32 interface_id[[name("InterfaceID")]];
    u64 timestamp[[name("Timestamp")]];
    if(block_len1 > 24) {
        u64 prev_pos = $;
        Option options [ while( $ < (prev_pos + block_len1 - 24))];
    }
    u32 block_len2[[name("BlockLen2")]];
};  

struct PCAPng{
    if (std::mem::eof()){
        break;
    }
    if (order == PcapOrder::Little){
        le u32 block_type = std::mem::read_unsigned($, 0x4, std::mem::Endian::Little);
    } else {
        be u32 block_type = std::mem::read_unsigned($, 0x4, std::mem::Endian::Big);
    }
    // std::print("{} , {:#x}, {:#x}", "Parsing", $, block_type);
    // std::print("Parsing : Offset({:#x}), Order({:#x}), BlockType({:#x})", $, order, block_type);
    if (block_type == BlockType::SectionHeader) {
        if (order == PcapOrder::Little) {
            le SectionHeaderBlock SHB;
        } else {
            be SectionHeaderBlock SHB;
        }
    } else if (block_type == BlockType::InterfaceDesc) {
        if (order == PcapOrder::Little) {
            le InterfaceBlock IDH;
        } else {
            be InterfaceBlock IDH;
        }
    } else if (block_type == BlockType::EnhancedPacket) {
        if (order == PcapOrder::Little) {
            le EnhancedPacketBlock EBP;
        } else {
            be EnhancedPacketBlock EBP;
        }
    } else if (block_type == BlockType::NameResolution) {
        if (order == PcapOrder::Little) {
            le NameResolutionBlock NRB;
        } else {
            be NameResolutionBlock NRB;
        }
    } else if (block_type == BlockType::InterfaceStats) {
        if (order == PcapOrder::Little) {
            le InterfaceStatsBlock ISB;
        } else {
            be InterfaceStatsBlock ISB;
        }
    } else if (block_type == BlockType::SimplePacket) {
        if (order == PcapOrder::Little) {
            le SimplePacketBlock SPB;
        } else {
            be SimplePacketBlock SPB;
        }
    } else if (block_type == BlockType::Packet) {
        if (order == PcapOrder::Little) {
            le PacketBlock PB;
        } else {
            be PacketBlock PB;
        }
    } else if (block_type == BlockType::Custom) {
        if (order == PcapOrder::Little) {
            le CustomBlock CB;
        } else {
            be CustomBlock CB;
        }
    } else if (block_type == BlockType::CustomNoCopy) {
        if (order == PcapOrder::Little) {
            le CustomBlock CBN;
        } else {
            be CustomBlock CBN;
        }
    } else {
        std::print("Unknown BlockType at offset {:#x}\n", $);
        break;
    }
} [[inline]];


u32 order = std::mem::read_unsigned(0x8, 0x4);
PCAPng PcapNG  [while(!std::mem::eof())] @0x00;
