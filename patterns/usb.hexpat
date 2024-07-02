#pragma description TODO

import std.core;
import std.io;
import std.mem;
import std.string;

using BitfieldOrder = std::core::BitfieldOrder;

enum DescriptorType : u8 {
    DeviceDescriptor                    = 0x01,
    ConfigDescriptor                    = 0x02,
    StringDescriptor                    = 0x03,
    InterfaceDescriptor                 = 0x04,
    EndpointDescriptor                  = 0x05,
    DeviceQualifierDescriptor           = 0x06,
    OtherSpeedConfigurationDescriptor   = 0x07,
    InterfacePowerDescriptor            = 0x08,
    OTGDescriptor                       = 0x09,
    DebugDescriptor                     = 0x0A,
    InterfaceAssociationDescriptor      = 0x0B,
    
    HIDDescriptor                       = 0x21,
    ReportDescriptor                    = 0x22,
    PhysicalDescriptor                  = 0x23
};

enum InterfaceClass : u8 {
    UseClassInformationInInterfaceDescriptors   = 0x00,
    Audio                                       = 0x01,
    CommunicationAndCDCControl                  = 0x02,
    HID                                         = 0x03,
    Physical                                    = 0x05,
    Image                                       = 0x06,
    Printer                                     = 0x07,
    MassStorage                                 = 0x08,
    Hub                                         = 0x09,
    CDCData                                     = 0x0A,
    SmartCard                                   = 0x0B,
    ContentSecurity                             = 0x0C,
    Video                                       = 0x0E,
    PersonalHealthcare                          = 0x0F,
    AudioVideoDevice                            = 0x10,
    BillboardDevice                             = 0x11,
    USBTypeCBridge                              = 0x12,
    I3CDevice                                   = 0x3C,
    DiagnosticDevice                            = 0xDC,
    WirelessController                          = 0xE0,
    Miscellaneous                               = 0xEF,
    ApplicationSpecific                         = 0xFE,
    VendorSpecific                              = 0xFF
};

enum CountryCode : u8 {
    NotSupported            = 0,
    Arabic                  = 1,
    Belgian                 = 2,
    CanadianBilingual       = 3,
    CanadianFrench          = 4,
    CzechRepublic           = 5,
    Danish                  = 6,
    Finnish                 = 7,
    French                  = 8,
    German                  = 9,
    Greek                   = 10,
    Hebrew                  = 11,
    Hungary                 = 12,
    International           = 13,
    Italian                 = 14,
    JapanKatakana           = 15,
    Korean                  = 16,
    LatinAmerican           = 17,
    Dutch                   = 18,
    Norwegian               = 19,
    PersianFarsi            = 20,
    Polish                  = 21,
    Portuguese              = 22,
    Russian                 = 23,
    Slovakian               = 24,
    Spanish                 = 25,
    Swedish                 = 26,
    SwissFrench             = 27,
    SwissGerman             = 28,
    Switzerland             = 29,
    Taiwan                  = 30,
    TurkishQ                = 31,
    EnglishUK               = 32,
    EnglishUS               = 33,
    Yugoslavian             = 34,
    TurkishF                = 35,
    Reserved                = 36 ... 255
};

enum HubInterfaceSubClass : u8 {
    Hub = 0x00
};

enum AudioVideoDeviceSubClass : u8 {
    AVControlInterface              = 0x01,
    AVDataVideoStreamingInterface   = 0x02,
    AVDataAudioStreamingInterface   = 0x03
};

enum HubInterfaceProtocol : u8 {
    FullSpeedHub                    = 0x00,
    HiSpeedHubWithSingleTT          = 0x01,
    HiSpeedHubWithMultipleTTs       = 0x02
};

struct Ampere {
    u8 amps;
} [[sealed, format("format_ampere")]];

fn format_ampere(Ampere ampere) {
    return std::format("{} mA", ampere.amps * 2);
};

bitfield ConfigAttributes {
    padding : 1;
    SelfPowered : 1;
    RemoteWakeup : 1;
    padding : 5;
} [[bitfield_order(BitfieldOrder::MostToLeastSignificant, 8)]];

struct BCD<auto Size> {
    u8 bytes[Size];
} [[sealed, format("format_bcd")]];

fn format_bcd(ref auto bcd) {
    str result;
    for (s8 i = sizeof(bcd.bytes) - 1, i >= 0, i -= 1)
        result += std::format("{:X}.", bcd.bytes[i]);
        
    return std::string::substr(result, 0, std::string::length(result) - 1);
};

struct DeviceDescriptor {
    BCD<2> bcdUSB;
    InterfaceClass bDeviceClass;
    if (bDeviceClass == InterfaceClass::Hub) {
        HubInterfaceSubClass bDeviceSubClass;
        if (bDeviceSubClass == HubInterfaceSubClass::Hub)
            HubInterfaceProtocol bDeviceSubClassProtocol;
        else
            u8 bDeviceSubClassProtocol;
    } else if (bDeviceClass == InterfaceClass::AudioVideoDevice) {
        AudioVideoDeviceSubClass bDeviceSubClass;
        u8 bDeviceSubClassProtocol;
    } else {
        u8 bDeviceSubClass;
    }
};

struct ConfigDescriptor {
    u16 wTotalLength;
    u8 bNumInterfaces;
    u8 bConfigurationValue;
    u8 iConfiguration;
    ConfigAttributes bmAttributes;
    Ampere bMaxPower;
};

struct StringDescriptor {
    char bString[parent.bLength - 2];
};

struct InterfaceDescriptor {
    u8 bInterfaceNumber;
    u8 bAlternateSetting;
    u8 bNumEndpoints;
    
    InterfaceClass bInterfaceClass;
    if (bInterfaceClass == InterfaceClass::Hub) {
        HubInterfaceSubClass bInterfaceSubClass;
        if (bInterfaceSubClass == HubInterfaceSubClass::Hub)
            HubInterfaceProtocol bInterfaceProtocol;
        else
            u8 bInterfaceProtocol;
    } else if (bInterfaceClass == InterfaceClass::AudioVideoDevice) {
        AudioVideoDeviceSubClass bInterfaceSubClass;
        u8 bInterfaceProtocol;
    } else {
        u8 bInterfaceSubClass;
        u8 bInterfaceProtocol;
    }
    
    u8 iInterface;
};

enum EndpointDirection : u8 {
    OUT = 0,
    IN = 1
};

fn format_direction(u8 value) {
    EndpointDirection direction;
    direction = value;
    return direction;
};

bitfield EndpointAddress {
    EndpointNumber : 4;
    padding        : 3;
    Direction      : 1 [[format("format_direction")]];
};

bitfield EndpointAttributes {
    TransferType : 2;
    SynchronizationType : 2;
    UsageType : 2;
};

struct EndpointDescriptor {
    EndpointAddress bEndPointAddress;
    EndpointAttributes bmAttributes;
    u16 wMaxPacketSize;
    u8 bInterval;
};

struct OtherSpeedConfigurationDescriptor {
    ConfigDescriptor content [[inline]];
};

struct DeviceQualifierDescriptor {
    DeviceDescriptor deviceDescriptor [[inline]];
    u8 bMaxPacketSize0;
    u8 bNumConfigurations;
    padding[1];
};

bitfield OTGAttributes {
    SRPSupport : 1;
    HNPSupport : 1;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 2)]];

struct OTGDescriptor {
    OTGAttributes bmAttributes;
};

struct HIDDescriptor {
    BCD<2> bcdVersion;
    CountryCode bCountryCode;
    u8 bNumDescriptors;
    DescriptorType bDescriptorType;
    u16 wDescriptorLength;
};

struct USBDescriptor {
    u8 bLength;
    DescriptorType bDescriptorType;
    
    if (bDescriptorType == DescriptorType::DeviceDescriptor)
        DeviceDescriptor deviceDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::ConfigDescriptor)
        ConfigDescriptor configDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::StringDescriptor)
        StringDescriptor stringDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::InterfaceDescriptor)
        InterfaceDescriptor interfaceDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::EndpointDescriptor)
        EndpointDescriptor endpointDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::OtherSpeedConfigurationDescriptor)
        OtherSpeedConfigurationDescriptor otherSpeedConfigurationDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::DeviceQualifierDescriptor)
        DeviceQualifierDescriptor deviceQualifierDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::OTGDescriptor)
        OTGDescriptor otgDescriptor [[inline]];
    else if (bDescriptorType == DescriptorType::HIDDescriptor)
        HIDDescriptor hidDescriptor [[inline]];
    
    padding[bLength - ($ - addressof(this))];
};

USBDescriptor descriptors[while(!std::mem::eof())] @ 0x00;