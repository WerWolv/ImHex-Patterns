#pragma author gmestanley
#pragma description GameBoy ROM file GBX footer

import gb;

bitfield SachenMMC2SolderPad {
	padding : 5;
	opt1 : 1;
	openBus512KiBOuterBanks : 1;
	openBus1MiBOuterBanks : 1;
};

bitfield VastFameRunningValueType {
	TaiwanReleases : 1;
	MainlandChinaReleases : 1;
};

enum VastFamePCBType : u8 {
	DSHGGB81,
	BCR1616T3P
};

fn specialMapper(str value) { return value == "SAM2" || value == "VF01" || value == "GB81"; };

struct MapperVariables {
	match(parent.mapper) {
		("SAM2"): SachenMMC2SolderPad solderPadConfig;
		("VF01"): VastFameRunningValueType runningValue;
		("GB81"): VastFamePCBType pcb; }
	padding[3*specialMapper(parent.mapper)];
	u32 mapperVariables[8-specialMapper(parent.mapper)];
};

struct CartridgeInformation {
	char mapper[4];
	bool battery;
	bool rumble;
	bool timer;
	padding[1];
	u32 romSize;
	u32 ramSize;
	if (specialMapper(mapper))
		MapperVariables mapperVariables;
	else
		MapperVariables mapperVariables [[inline]];
};

struct GBXMetadata {
	u32 footerSize;
	u32 majorVersion;
	u32 minorVersion;
	char signature[4];
};

struct GBXFooter {
	CartridgeInformation cartInfo;
	GBXMetadata metadata;
};

be GBXFooter gbxFooter @ std::mem::size() - 0x40;