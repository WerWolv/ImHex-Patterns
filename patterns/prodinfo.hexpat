#pragma author WerWolv
#pragma description Nintendo Switch PRODINFO 

enum Model : u16 {
	NX = 1
};

struct WlanCountryCode {
	char code[3];
} [[static]];

struct Cert {
	u8 DeviceKey[0x30];
	padding[0x10];
	u8 DeviceCertificate[0x180];
	padding[0x10];
} [[static]];

enum RegionCode : u32 {
	JPN = 0,
	USA = 1,
	EUR = 2,
	AUS = 3,
	CHN = 4,
	KOR = 5,
	HKG = 6
};

enum ProductModel : u32 {
	Invalid = 0,
	NX = 1,
	Copper = 2,
	Iowa = 3,
	Hoag = 4,
	Calcio = 5,
	Aula = 6
};

struct PRODINFO {
	char MagicNumber[4];
	u32 Version;
	u32 BodySize;
	Model Model;
	u16 UpdateCount;
	
	padding[0x10];
	
	u8 BodyHash[0x20];
	char ConfigurationId1[0x1E];
	
	padding[0x02];
	padding[0x20];
	
	u32 WlanCountryCodesNum;
	u32 WlanCountryCodesLastIndex;
	WlanCountryCode WlanCountryCodes[WlanCountryCodesNum];
	padding[0x180 - sizeof(WlanCountryCodes)];
	padding[0x08];
	u8 WlanMacAddress[6];
	padding[0x10 - 6];
	u8 BdAddress[6];
	
	padding[0x10 - 6];
	
	u8 AccelerometerOffset[6];
	padding[2];
	u8 AccelerometerScale[6];
	padding[2];
	u8 GyroscopeOffset[6];
	padding[2];
	u8 GyroscopeScale[6];
	padding[2];
	
	char SerialNumber[0x18];
	
	padding[8];
	
	Cert EccP256Certificate;
	Cert EccB233Certificate;
	
	Cert Ecc256ETicket;
	Cert Ecc233ETicket;
	
	u8 SslKey[0x110];
	padding[0x10];
	u32 SslCertificateSize;
	padding[0x0C];
	u8 SslCertificate[0x800];
	u8 SslCertificateHash[0x20];
	
	u8 RandomNumber[0x1000];
	u8 RandomNumberHash[0x20];
	
	u8 GameCardKey[0x110];
	u8 GameCardCertificate[0x400];
	padding[0x10];
	u8 GameCardCertificateHash[0x20];
	
	u8 Rsa2048ETicketKey[0x220];
	padding[0x10];
	u8 Rsa2048ETicketCertificate[0x240];
	
	padding[0x10];
	
	char BatteryLot[0x18];
	
	padding[0x08];
	
	u8 SpeakerCalibrationValue[0x800];
	
	padding[0x10];
	
	RegionCode RegionCode;
	
	padding[0x0C];
	
	u8 AmiiboKey[0x50];
	padding[0x10];
	u8 AmiiboEcqvCertificate[0x14];
	padding[0x0C];
	u8 AmiiboEcdsaCertificate[0x70];
	padding[0x10];
	u8 AmiiboEcqvBlsKey[0x40];
	padding[0x10];
	u8 AmiiboEcqvBlsCertificate[0x20];
	padding[0x10];
	u8 AmiiboEcqvBlsRootCertificate[0x90];
	
	padding[0x10];
	
	ProductModel ProductModel;
	
	padding[0x0C];
	
	u8 ColorVariation[6];
	
	padding[0x0A];
	
	u8 LcdBacklightBrightnessMapping[0x0C];
	
	padding[0x04];
	
	u8 ExtendedEccB233DeviceKey[0x50];
	padding[0x10];
	u8 ExtendedEccP256ETicketKey[0x50];
	padding[0x10];
	u8 ExtendedEccB233ETicketKey[0x50];
	padding[0x10];
	u8 ExtendedRsa2048ETicketKey[0x240];
	padding[0x10];
	u8 ExtendedSslKey[0x130];
	padding[0x10];
	u8 ExtendedGameCardKey[0x130];
	padding[0x10];
	u32 LcdVendorId;
	
	padding[0x0C];
	
	u8 ExtendedRsa2048DeviceKey[0x240];
	padding[0x10];
	u8 Rsa2048DeviceCertificate[0x240];
	
	padding[0x10];
	
	u8 UsbTypeCPowerSourceCircuitVersion;
	
	padding[0x0F];
	
	u32 HousingSubColor;
	padding[0x0C];
	u32 HousingBezelColor;
	padding[0x0C];
	u32 HousingMainColor1;
	padding[0x0C];
	u32 HousingMainColor2;
	padding[0x0C];
	u32 HousingMainColor3;
	
	padding[0x0C];
	
	u8 AnalogStickModuleTypeL;
	padding[0x0F];
	u8 AnalogStickModelParameterL[0x12];
	padding[0x0E];
	u8 AnalogStickFactoryCalibrationL[0x09];
	padding[0x07];
	u8 AnalogStickModuleTypeR;
	padding[0x0F];
	u8 AnalogStickModelParameterR[0x12];
	padding[0x0E];
	u8 AnalogStickFactoryCalibrationR[0x09];
	
	padding[0x07];
	
	u8 ConsoleSixAxisSensorModuleType;
	padding[0x0F];
	u8 ConsoleSixAxisSensorHorizontalOffset[6];
	padding[0x0A];
	u8 BatteryVersion;
	padding[0x0F];
	u8 TouchIcVendorId;
	padding[0x0F];
	u32 ColorModel;
	padding[0x0C];
	u8 ConsoleSixAxisSensorMountType;
};

PRODINFO PRODINFO @ 0x00;