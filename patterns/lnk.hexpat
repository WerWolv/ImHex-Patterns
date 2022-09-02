#pragma MIME application/x-ms-shortcut

#include <type/guid.pat>
#include <type/size.pat>

bitfield LinkFlags {
	HasLinkTargetIDList 		: 1;
	HasLinkInfo					: 1;
	HasName						: 1;
	HasRelativePath				: 1;
	HasWorkingDir				: 1;
	HasArguments				: 1;
	HasIconLocation				: 1;
	IsUnicode					: 1;
	ForceNoLinkInfo				: 1;
	HasExpString				: 1;
	RunInSeparateProcess		: 1;
	padding						: 1;
	HasDarwinID					: 1;
	RunAsUser					: 1;
	HasExpIcon					: 1;
	NoPidlAlias					: 1;
	padding						: 1;
	RunWithShimLayer			: 1;
	ForceNoLinkTrack			: 1;
	EnableTargetMetadata		: 1;
	DisableLinkPathTracking		: 1;
	DisableKnownFolderTracking 	: 1;
	DisableKnownFolderAlias 	: 1;
	AllowLinkToLink				: 1;
	UnaliasOnSave				: 1;
	PreferEnvironmentPath		: 1;
	KeepLocalIDListForUNCTarget	: 1;
	padding						: 5;
} [[right_to_left]];

bitfield FileAttributesFlags {
	FILE_ATTRIBUTE_READONLY				: 1;
	FILE_ATTRIBUTE_HIDDEN				: 1;
	FILE_ATTRIBUTE_SYSTEM				: 1;
	padding								: 1;
	FILE_ATTRIBUTE_DIRECTORY			: 1;
	FILE_ATTRIBUTE_ARCHIVE				: 1;
	padding								: 1;
	FILE_ATTRIBUTE_NORMAL				: 1;
	FILE_ATTRIBUTE_TEMPORARY			: 1;
	FILE_ATTRIBUTE_SPARSE_FILE			: 1;
	FILE_ATTRIBUTE_REPARSE_POINT		: 1;
	FILE_ATTRIBUTE_COMPRESSED			: 1;
	FILE_ATTRIBUTE_OFFLINE				: 1;
	FILE_ATTRIBUTE_NOT_CONTENT_INDEXED	: 1;
	FILE_ATTRIBUTE_ENCRYPTED			: 1;
	padding								: 17;
} [[right_to_left]];

bitfield ModifierKeys {
	HOTKEYF_SHIFT	: 1;
	HOTKEYF_CONTROL : 1;
	HOTKEYF_ALT		: 1;
	padding			: 5;
} [[right_to_left]];

enum Keys : u8 {
	KEY_NONE	= 0x00,
	KEY_0		= 0x30,
	KEY_1		= 0x31,
	KEY_2		= 0x32,
	KEY_3		= 0x33,
	KEY_4		= 0x34,
	KEY_5		= 0x35,
	KEY_6		= 0x36,
	KEY_7		= 0x37,
	KEY_8		= 0x38,
	KEY_9		= 0x39,
	KEY_A		= 0x41,
	KEY_B		= 0x42,
	KEY_C		= 0x43,
	KEY_D		= 0x44,
	KEY_E		= 0x45,
	KEY_F		= 0x46,
	KEY_G		= 0x47,
	KEY_H		= 0x48,
	KEY_I		= 0x49,
	KEY_J		= 0x4A,
	KEY_K		= 0x4B,
	KEY_L		= 0x4C,
	KEY_M		= 0x4D,
	KEY_N		= 0x4E,
	KEY_O		= 0x4F,
	KEY_P		= 0x50,
	KEY_Q		= 0x51,
	KEY_R		= 0x52,
	KEY_S		= 0x53,
	KEY_T		= 0x54,
	KEY_U		= 0x55,
	KEY_V		= 0x56,
	KEY_W		= 0x57,
	KEY_X		= 0x58,
	KEY_Y		= 0x59,
	KEY_Z		= 0x5A,
	
	VK_F1		= 0x70,
	VK_F2		= 0x71,
	VK_F3		= 0x72,
	VK_F4		= 0x73,
	VK_F5		= 0x74,
	VK_F6		= 0x75,
	VK_F7		= 0x76,
	VK_F8		= 0x77,
	VK_F9		= 0x78,
	VK_F10		= 0x79,
	VK_F11		= 0x7A,
	VK_F12		= 0x7B,
	VK_F13		= 0x7C,
	VK_F14		= 0x7D,
	VK_F15		= 0x7E,
	VK_F16		= 0x7F,
	VK_F17		= 0x80,
	VK_F18		= 0x81,
	VK_F19		= 0x82,
	VK_F20		= 0x83,
	VK_F21		= 0x84,
	VK_F22		= 0x85,
	VK_F23		= 0x86,
	VK_F24		= 0x87,
	VK_NUMLOCK	= 0x90,
	VK_SCROLL	= 0x91,
};

struct HotKeyFlags {
	Keys Key;
	ModifierKeys ModifierKeys;
};

struct FILETIME {
	u32 dwLowDateTime;
	u32 dwHighDateTime;
};

enum SHOWWINDOW_FLAGS : u32 {
	SW_SHOWNORMAL		= 0x00000001,
	SW_SHOWMAXIMIZED	= 0x00000003,
	SW_SHOWMINNOACTIVE	= 0x00000007
};

struct ShellLinkHeader {
	type::Size32 HeaderSize;
	type::GUID LinkCLSID;
	LinkFlags LinkFlags;
	FileAttributesFlags FileAttributes;
	FILETIME CreationTime, AccessTime, WriteTime;
	type::Size32 FileSize;
	u32 IconIndex;
	SHOWWINDOW_FLAGS ShowCommand;
	HotKeyFlags HotKey;
	padding[2];
	padding[4];
	padding[4];	
};

struct ItemID {
	type::Size16 ItemIDSize;
	
	if (ItemIDSize == 0x00)
		break;
	else
		u8 Data[ItemIDSize - sizeof(ItemIDSize)];
};

struct IDList {
	ItemID ItemIDList[while(true)];
};

struct LinkTargetIDList {
	type::Size16 IDListSize;
	IDList IDList[while($ < (addressof(IDListSize) + IDListSize))];
};

bitfield LinkInfoFlags {
	VolumeIDAndLocalBasePath 				: 1;
	CommonNetworkRelativeLinkAndPathSuffix	: 1;
	padding									: 30;
};

enum DriveType : u32 {
	DRIVE_UNKNOWN		= 0x00000000,
	DRIVE_NO_ROOT_DIR	= 0x00000001,
	DRIVE_REMOVABLE		= 0x00000002,
	DRIVE_FIXED			= 0x00000003,
	DRIVE_REMOTE		= 0x00000004,
	DRIVE_CDROM			= 0x00000005,
	DRIVE_RAMDISK		= 0x00000006
};

struct VolumeID {
	type::Size32 VolumeIDSize;
	DriveType DriveType;
	u32 DriveSerialNumber;
	u32 VolumeLabelOffset;
	if (VolumeLabelOffset == 0x14)
		u32 VolumeLabelOffsetUnicode;
	char Data[VolumeIDSize - ($ - addressof(this))];
};

bitfield CommonNetworkRelativeLinkFlags {
	ValidDevice		: 1;
	ValidNetType	: 1;
	padding			: 30;
} [[right_to_left]];

enum NetworkProviderType : u32 {
	WNNC_NET_AVID			= 0x001A0000,
	WNNC_NET_DOCUSPACE		= 0x001B0000,
	WNNC_NET_MANGOSOFT		= 0x001C0000,
	WNNC_NET_SERNET			= 0x001D0000,
	WNNC_NET_RIVERFRONT1	= 0x001E0000,
	WNNC_NET_RIVERFRONT2	= 0x001F0000,
	WNNC_NET_DECORB			= 0x00200000,
	WNNC_NET_PROTSTOR		= 0x00210000,
	WNNC_NET_FJ_REDIR		= 0x00220000,
	WNNC_NET_DISTINCT		= 0x00230000,
	WNNC_NET_TWINS			= 0x00240000,
	WNNC_NET_RDR2SAMPLE		= 0x00250000,
	WNNC_NET_CSC			= 0x00260000,
	WNNC_NET_3IN1			= 0x00270000,
	WNNC_NET_EXTENDNET		= 0x00290000,
	WNNC_NET_STAC			= 0x002A0000,
	WNNC_NET_FOXBAT			= 0x002B0000,
	WNNC_NET_YAHOO			= 0x002C0000,
	WNNC_NET_EXIFS			= 0x002D0000,
	WNNC_NET_DAV			= 0x002E0000,
	WNNC_NET_KNOWARE		= 0x002F0000,
	WNNC_NET_OBJECT_DIRE	= 0x00300000,
	WNNC_NET_MASFAX			= 0x00310000,
	WNNC_NET_HOB_NFS		= 0x00320000,
	WNNC_NET_SHIVA			= 0x00330000,
	WNNC_NET_IBMAL			= 0x00340000,
	WNNC_NET_LOCK			= 0x00350000,
	WNNC_NET_TERMSRV		= 0x00360000,
	WNNC_NET_SRT			= 0x00370000,
	WNNC_NET_QUINCY			= 0x00380000,
	WNNC_NET_OPENAFS		= 0x00390000,
	WNNC_NET_AVID1			= 0x003A0000,
	WNNC_NET_DFS			= 0x003B0000,
	WNNC_NET_KWNP			= 0x003C0000,
	WNNC_NET_ZENWORKS		= 0x003D0000,
	WNNC_NET_DRIVEONWEB		= 0x003E0000,
	WNNC_NET_VMWARE			= 0x003F0000,
	WNNC_NET_RSFX			= 0x00400000,
	WNNC_NET_MFILES			= 0x00410000,
	WNNC_NET_MS_NFS			= 0x00420000,
	WNNC_NET_GOOGLE			= 0x00430000
};

struct CommonNetworkRelativeLink {
	type::Size32 CommonNetworkRelativeLinkSize;
	CommonNetworkRelativeLinkFlags CommonNetworkRelativeLinkFlags;
	u32 NetNameOffset;
	u32 DeviceNameOffset;
	NetworkProviderType NetworkProviderType;
	
	if (NetNameOffset > 0x14) {
		u32 NetNameOffsetUnicode;
		u32 DeviceNameOffsetUnicode;
	}
	
	char NetName[];
	char DeviceName[];
		
	if (NetNameOffset > 0x14) {
		char16 NetNameUnicode[];
		char16 DeviceNameUnicode[];
	}
};

struct LinkInfo {
	type::Size32 LinkInfoSize;
	type::Size32 LinkInfoHeaderSize;
	LinkInfoFlags LinkInfoFlags;
	u32 VolumeIDOffset;
	u32 LocalBasePathOffset;
	u32 CommonNetworkRelativeLinkOffset;
	u32 CommonPathSuffixOffset;
	
	if (LinkInfoHeaderSize >= 0x24) {
		u32 LocalBasePathOffsetUnicode;
		u32 CommonPathSuffixOffsetUnicode;
	}
	
	if (LinkInfoFlags.VolumeIDAndLocalBasePath) {
		VolumeID VolumeID;
		char LocalBasePath[];
	}	
	
	if (LinkInfoFlags.CommonNetworkRelativeLinkAndPathSuffix)
		CommonNetworkRelativeLink CommonNetworkRelativeLink;
		
	char CommonPathSuffix[];
	
	if (LinkInfoHeaderSize >= 0x24) {
		if (LinkInfoFlags.VolumeIDAndLocalBasePath)
			char16 LocalBasePathUnicode[];
		char16 CommonPathSuffixUnicode[];
	}
};

struct String {
	u16 CountCharacters;
	char16 String[CountCharacters];
};

struct StringData {
	if (parent.ShellLinkHeader.LinkFlags.HasName)
		String NAME_STRING;
	if (parent.ShellLinkHeader.LinkFlags.HasRelativePath)
		String RELATIVE_PATH;
	if (parent.ShellLinkHeader.LinkFlags.HasWorkingDir)
		String WORKING_DIR;
	if (parent.ShellLinkHeader.LinkFlags.HasArguments)
		String COMMAND_LINE_ARGUMENTS;
	if (parent.ShellLinkHeader.LinkFlags.HasIconLocation)
		String ICON_LOCATION;
};

bitfield FillAttributes {
	FOREGROUND_BLUE			: 1;
	FOREGROUND_GREEN		: 1;
	FOREGROUND_RED			: 1;
	FOREGROUND_INTENSITY	: 1;
	
	BACKGROUND_BLUE			: 1;
	BACKGROUND_GREEN		: 1;
	BACKGROUND_RED			: 1;
	BACKGROUND_INTENSITY	: 1;
	
	padding					: 8;
} [[right_to_left]];

struct ConsoleDataBlock {
	FillAttributes FillAttributes;
	FillAttributes PopupFillAttributes;
	u16 ScreenBufferSizeX, ScreenBufferSizeY;
	u16 WindowSizeX, WindowSizeY;
	u16 WindowOriginX, WindowOriginY;
	padding[4];
	padding[4];
	u32 FontSize;
	u32 FontFamily;
	u32 FontWeight;
	char16 FaceName[32];
	u32 CursorSize;
	u32 FullScreen;
	u32 QuickEdit;
	u32 InsertMode;
	u32 AutoPosition;
	u32 HistoryBufferSize;
	u32 NumberOfHistoryBuffers;
	u32 HistoryNoDup;
	u32 ColorTable[16];
};

struct ConsoleFEDataBlock {
	u32 CodePage;
};

struct DarwinDataBlock {
	char DarwinDataAnsi[260];
	char16 DarwinDataUnicode[260];
};

struct EnvironmentVariableDataBlock {
	char TargetAnsi[260];
	char16 TargetUnicode[260];
};

struct IconEnvironmentDataBlock {
	char TargetAnsi[260];
	char16 TargetUnicode[260];
};

struct KnownFolderDataBlock {
	type::GUID KnownFolderID;
	u32 Offset;
};

struct PropertyStoreDataBlock {
	u8 Bytes[parent.BlockSize - sizeof(parent.BlockSize) - sizeof(parent.BlockSignature)];
	std::warning("PropertyStoreDataBlock is not yet implemented!");
};

struct ShimDataBlock {
	char16 LayerName[(parent.BlockSize - sizeof(parent.BlockSize) - sizeof(parent.BlockSignature)) / sizeof(char16)];
};

struct SpecialFolderDataBlock {
	u32 SpecialFolderID;
	u32 Offset;
};

struct TrackerDataBlock {
	type::Size32 Length;
	u32 Version;
	char MachineID[16];
	type::GUID Droid[2];
	type::GUID DroidBirth[2];
};

struct VistaAndAboveIDListDataBlock {
	IDList IDList;
};

struct ExtraDataBlock {
	type::Size32 BlockSize;
	
	if (BlockSize < 0x04)
		break;
	else {
		u32 BlockSignature;
	
		if (BlockSignature == 0xA000'0002)
			ConsoleDataBlock CONSOLE_PROPS;
		else if (BlockSignature == 0xA000'0004)
			ConsoleFEDataBlock CONSOLE_FE_PROPS;
		else if (BlockSignature == 0xA000'0006)
			DarwinDataBlock DARWIN_PROPS;
		else if (BlockSignature == 0xA000'0001)
			EnvironmentVariableDataBlock ENVIRONMENT_PROPS;
		else if (BlockSignature == 0xA000'0007)
			IconEnvironmentDataBlock ICON_ENVIRONMENT_PROPS;
		else if (BlockSignature == 0xA000'000B)
			KnownFolderDataBlock KNOWN_FOLDER_PROPS;
		else if (BlockSignature == 0xA000'0009)
			PropertyStoreDataBlock PROPERTY_STORE_PROPS;
		else if (BlockSignature == 0xA000'0008)
			ShimDataBlock SHIM_PROPS;
		else if (BlockSignature == 0xA000'0005)
			SpecialFolderDataBlock SPECIAL_FOLDER_PROPS;
		else if (BlockSignature == 0xA000'0003)
			TrackerDataBlock TRACKER_PROPS;
		else if (BlockSignature == 0xA000'000C)
			VistaAndAboveIDListDataBlock VISTA_AND_ABOVE_IDLIST_PROPS;
	}
};

struct ExtraData {
	ExtraDataBlock ExtraDataBlock[while(true)];
};

struct LNK {
	ShellLinkHeader ShellLinkHeader;
	if (ShellLinkHeader.LinkFlags.HasLinkTargetIDList)
		LinkTargetIDList LinkTargetIDList;
	if (ShellLinkHeader.LinkFlags.HasLinkInfo)
		LinkInfo LinkInfo;
	StringData StringData;
	ExtraData ExtraData;
};

LNK lnk @ 0x00;