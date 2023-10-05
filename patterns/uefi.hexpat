#pragma description UEFI structs for parsing efivars

#define WIN_CERT_TYPE_PKCS_SIGNED_DATA 0x0002
#define WIN_CERT_TYPE_EFI_PKCS115   0x0EF0
#define WIN_CERT_TYPE_EFI_GUID     0x0EF1 

struct EFI_TIME {
 u16  Year;             // 1900 – 9999
 u8   Month;            // 1 – 12
 u8   Day;              // 1 – 31
 u8   Hour;             // 0 – 23
 u8   Minute;           // 0 – 59
 u8   Second;           // 0 – 59
 u8   Pad1;
 u32  Nanosecond;       // 0 – 999,999,999
 s16  TimeZone;         // -1440 to 1440 or 2047
 u8   Daylight;
 u8   Pad2;
};

struct EFI_GUID {
	u32 Data1;
	u16 Data2;
	u16 Data3;
	u8 Data4[8];
};

struct WIN_CERTIFICATE {
	u32 Length;
	u16 Revision;
	u16 CertificateType;
	//u8 Certificate[];
};

struct WIN_CERTIFICATE_UEFI_GUID {
	WIN_CERTIFICATE Hdr;
	EFI_GUID CertType;
	u8 CertData[Hdr.Length-SizeofWIN_CERTIFICATE_UEFI_GUID];
};
#define SizeofWIN_CERTIFICATE_UEFI_GUID 24

struct EFI_VARIABLE_AUTHENTICATION_2 {
	EFI_TIME TimeStamp;
	WIN_CERTIFICATE_UEFI_GUID AuthInfo;
};

struct EFI_SIGNATURE_DATA {
	EFI_GUID SignatureOwner;
	u8 SignatureData[1076];
};

struct EFI_SIGNATURE_LIST {
	EFI_GUID SignatureType;
	u32 SignatureListSize;
	u32 SignatureHeaderSize;
	u32 SignatureSize;
	u8 SignatureHeader[SignatureHeaderSize];
	EFI_SIGNATURE_DATA Signatures;
};


struct dbx_esl {
	EFI_VARIABLE_AUTHENTICATION_2 Auth;
	EFI_SIGNATURE_LIST x509_1;
};

dbx_esl header @ 0x00;
