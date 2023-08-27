#pragma description pcap header and packets

#include <std/mem.pat>
#pragma MIME application/vnd.tcpdump.pcap

enum network_type : u32 {
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

enum magic : u32 {
	BE = 0xA1B2C3D4,
	LE = 0xD4C3B2A1
};


struct pcap_record_t {
    u32 ts_sec;         /* timestamp seconds */
    u32 ts_usec;        /* timestamp microseconds */
    u32 incl_len;       /* number of octets of packet saved in file */
    u32 orig_len;       /* actual length of packet */
    u8  data[incl_len];
};

struct pcap_header_t {
    u16 version_major;    /* major version number */
    u16 version_minor;    /* minor version number */
    s32 thiszone;         /* GMT to local correction */
    u32 sigfigs;          /* accuracy of timestamps */
    u32 snaplen;          /* max length of captured packets, in octets */
    network_type network; /* data link type */
};

struct pcap {
    be magic magic_number;
    if (magic_number == magic::BE) {
        be pcap_header_t header;
        be pcap_record_t packet[while(!std::mem::eof())];
    } else {
        le pcap_header_t header;
        le pcap_record_t packet[while(!std::mem::eof())];
    }
};

pcap pcap @ 0x00;
