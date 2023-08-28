#pragma author WerWolv
#pragma description Xbox executable

#pragma MIME audio/x-xbox-executable

#include <type/magic.pat>
#include <type/size.pat>
#include <type/time.pat>

#include <std/io.pat>
#include <std/mem.pat>


bitfield AllowedMedia {
    HardDisk            : 1;
    DVD_X2              : 1;
    DVD_CD              : 1;
    CD                  : 1;
    DVD_5_RO            : 1;
    DVD_9_RO            : 1;
    DVD_5_RW            : 1;
    DVD_9_RW            : 1;
    Dongle              : 1;
    MediaBoard          : 1;
    padding             : 20;
    NonSecureHardDisk   : 1;
    NonSecureMode       : 1;
};

bitfield GameRegion {
    NorthAmerica    : 1;
    Japan           : 1;
    RestOfTheWorld  : 1;
    padding         : 28;
    Manufacturing   : 1;
};

struct Certificate {
    type::Size<u32> certificateSize;
    type::time32_t timeDate;
    u32 titleId;
    char16 titleName[0x50 / 2];
    u32 alternateTitleIds[16];
    AllowedMedia allowedMedia;
    GameRegion gameRegion;
    u32 gameRatings;
    u128 lanKey;
    u128 signatureKey;
    u128 alternateSignatureKeys[16];
};

bitfield InitializationFlags {
    MountUtilityDrive   : 1;
    FormatUtilityDrive  : 1;
    Limit64Megabytes    : 1;
    DontSetuptHarddisk  : 1;
    padding : 28;
};

union EntryPoint {
    u32 betaAddress [[format("format_beta_entrypoint")]];
    u32 debugAddress [[format("format_debug_entrypoint")]];
    u32 retailAddress [[format("format_retail_entrypoint")]];
    
    if ((betaAddress ^ 0xE682F45B) - parent.baseAddress < std::mem::size())
        u8 beta     @ (betaAddress ^ 0xE682F45B) - parent.baseAddress;;
    if ((debugAddress ^ 0x94859D4B) - parent.baseAddress < std::mem::size())    
        u8 debug    @ (debugAddress ^ 0x94859D4B) - parent.baseAddress;;
    if ((retailAddress ^ 0xA8FC57AB) - parent.baseAddress < std::mem::size())
        u8 retail   @ (retailAddress ^ 0xA8FC57AB) - parent.baseAddress;
};

fn format_beta_entrypoint(u32 value) {
    return std::format("0x{:08X}", value ^ 0xE682F45B);
};

fn format_debug_entrypoint(u32 value) {
    return std::format("0x{:08X}", value ^ 0x94859D4B);
};

fn format_retail_entrypoint(u32 value) {
    return std::format("0x{:08X}", value ^ 0xA8FC57AB);
};

#define KERNEL_BASE 0x8000'0000
enum KernelImageFunction : u32 {
    AvGetSavedDataAddress = 1 + KERNEL_BASE,
    AvSendTVEncoderOption = 2 + KERNEL_BASE,
    AvSetDisplayMode = 3 + KERNEL_BASE,
    AvSetSavedDataAddress = 4 + KERNEL_BASE,
    DbgBreakPoint = 5 + KERNEL_BASE,
    DbgBreakPointWithStatus = 6 + KERNEL_BASE,
    DbgLoadImageSymbols = 7 + KERNEL_BASE,
    DbgPrint = 8 + KERNEL_BASE,
    HalReadSMCTrayState = 9 + KERNEL_BASE,
    DbgPrompt = 10 + KERNEL_BASE,
    DbgUnLoadImageSymbols = 11 + KERNEL_BASE,
    ExAcquireReadWriteLockExclusive = 12 + KERNEL_BASE,
    ExAcquireReadWriteLockShared = 13 + KERNEL_BASE,
    ExAllocatePool = 14 + KERNEL_BASE,
    ExAllocatePoolWithTag = 15 + KERNEL_BASE,
    ExEventObjectType = 16 + KERNEL_BASE,
    ExFreePool = 17 + KERNEL_BASE,
    ExInitializeReadWriteLock = 18 + KERNEL_BASE,
    ExInterlockedAddLargeInteger = 19 + KERNEL_BASE,
    ExInterlockedAddLargeStatistic = 20 + KERNEL_BASE,
    ExInterlockedCompareExchange64 = 21 + KERNEL_BASE,
    ExMutantObjectType = 22 + KERNEL_BASE,
    ExQueryPoolBlockSize = 23 + KERNEL_BASE,
    ExQueryNonVolatileSetting = 24 + KERNEL_BASE,
    ExReadWriteRefurbInfo = 25 + KERNEL_BASE,
    ExRaiseException = 26 + KERNEL_BASE,
    ExRaiseStatus = 27 + KERNEL_BASE,
    ExReleaseReadWriteLock = 28 + KERNEL_BASE,
    ExSaveNonVolatileSetting = 29 + KERNEL_BASE,
    ExSemaphoreObjectType = 30 + KERNEL_BASE,
    ExTimerObjectType = 31 + KERNEL_BASE,
    ExfInterlockedInsertHeadList = 32 + KERNEL_BASE,
    ExfInterlockedInsertTailList = 33 + KERNEL_BASE,
    ExfInterlockedRemoveHeadList = 34 + KERNEL_BASE,
    FscGetCacheSize = 35 + KERNEL_BASE,
    FscInvalidateIdleBlocks = 36 + KERNEL_BASE,
    FscSetCacheSize = 37 + KERNEL_BASE,
    HalClearSoftwareInterrupt = 38 + KERNEL_BASE,
    HalDisableSystemInterrupt = 39 + KERNEL_BASE,
    HalDiskCachePartitionCount = 40 + KERNEL_BASE,
    HalDiskModelNumber = 41 + KERNEL_BASE,
    HalDiskSerialNumber = 42 + KERNEL_BASE,
    HalEnableSystemInterrupt = 43 + KERNEL_BASE,
    HalGetInterruptVector = 44 + KERNEL_BASE,
    HalReadSMBusValue = 45 + KERNEL_BASE,
    HalReadWritePCISpace = 46 + KERNEL_BASE,
    HalRegisterShutdownNotification = 47 + KERNEL_BASE,
    HalRequestSoftwareInterrupt = 48 + KERNEL_BASE,
    HalReturnToFirmware = 49 + KERNEL_BASE,
    HalWriteSMBusValue = 50 + KERNEL_BASE,
    InterlockedCompareExchange = 51 + KERNEL_BASE,
    InterlockedDecrement = 52 + KERNEL_BASE,
    InterlockedIncrement = 53 + KERNEL_BASE,
    InterlockedExchange = 54 + KERNEL_BASE,
    InterlockedExchangeAdd = 55 + KERNEL_BASE,
    InterlockedFlushSList = 56 + KERNEL_BASE,
    InterlockedPopEntrySList = 57 + KERNEL_BASE,
    InterlockedPushEntrySList = 58 + KERNEL_BASE,
    IoAllocateIrp = 59 + KERNEL_BASE,
    IoBuildAsynchronousFsdRequest = 60 + KERNEL_BASE,
    IoBuildDeviceIoControlRequest = 61 + KERNEL_BASE,
    IoBuildSynchronousFsdRequest = 62 + KERNEL_BASE,
    IoCheckShareAccess = 63 + KERNEL_BASE,
    IoCompletionObjectType = 64 + KERNEL_BASE,
    IoCreateDevice = 65 + KERNEL_BASE,
    IoCreateFile = 66 + KERNEL_BASE,
    IoCreateSymbolicLink = 67 + KERNEL_BASE,
    IoDeleteDevice = 68 + KERNEL_BASE,
    IoDeleteSymbolicLink = 69 + KERNEL_BASE,
    IoDeviceObjectType = 70 + KERNEL_BASE,
    IoFileObjectType = 71 + KERNEL_BASE,
    IoFreeIrp = 72 + KERNEL_BASE,
    IoInitializeIrp = 73 + KERNEL_BASE,
    IoInvalidDeviceRequest = 74 + KERNEL_BASE,
    IoQueryFileInformation = 75 + KERNEL_BASE,
    IoQueryVolumeInformation = 76 + KERNEL_BASE,
    IoQueueThreadIrp = 77 + KERNEL_BASE,
    IoRemoveShareAccess = 78 + KERNEL_BASE,
    IoSetIoCompletion = 79 + KERNEL_BASE,
    IoSetShareAccess = 80 + KERNEL_BASE,
    IoStartNextPacket = 81 + KERNEL_BASE,
    IoStartNextPacketByKey = 82 + KERNEL_BASE,
    IoStartPacket = 83 + KERNEL_BASE,
    IoSynchronousDeviceIoControlRequest = 84 + KERNEL_BASE,
    IoSynchronousFsdRequest = 85 + KERNEL_BASE,
    IofCallDriver = 86 + KERNEL_BASE,
    IofCompleteRequest = 87 + KERNEL_BASE,
    KdDebuggerEnabled = 88 + KERNEL_BASE,
    KdDebuggerNotPresent = 89 + KERNEL_BASE,
    IoDismountVolume = 90 + KERNEL_BASE,
    IoDismountVolumeByName = 91 + KERNEL_BASE,
    KeAlertResumeThread = 92 + KERNEL_BASE,
    KeAlertThread = 93 + KERNEL_BASE,
    KeBoostPriorityThread = 94 + KERNEL_BASE,
    KeBugCheck = 95 + KERNEL_BASE,
    KeBugCheckEx = 96 + KERNEL_BASE,
    KeCancelTimer = 97 + KERNEL_BASE,
    KeConnectInterrupt = 98 + KERNEL_BASE,
    KeDelayExecutionThread = 99 + KERNEL_BASE,
    KeDisconnectInterrupt = 100 + KERNEL_BASE,
    KeEnterCriticalRegion = 101 + KERNEL_BASE,
    MmGlobalData = 102 + KERNEL_BASE,
    KeGetCurrentIrql = 103 + KERNEL_BASE,
    KeGetCurrentThread = 104 + KERNEL_BASE,
    KeInitializeApc = 105 + KERNEL_BASE,
    KeInitializeDeviceQueue = 106 + KERNEL_BASE,
    KeInitializeDpc = 107 + KERNEL_BASE,
    KeInitializeEvent = 108 + KERNEL_BASE,
    KeInitializeInterrupt = 109 + KERNEL_BASE,
    KeInitializeMutant = 110 + KERNEL_BASE,
    KeInitializeQueue = 111 + KERNEL_BASE,
    KeInitializeSemaphore = 112 + KERNEL_BASE,
    KeInitializeTimerEx = 113 + KERNEL_BASE,
    KeInsertByKeyDeviceQueue = 114 + KERNEL_BASE,
    KeInsertDeviceQueue = 115 + KERNEL_BASE,
    KeInsertHeadQueue = 116 + KERNEL_BASE,
    KeInsertQueue = 117 + KERNEL_BASE,
    KeInsertQueueApc = 118 + KERNEL_BASE,
    KeInsertQueueDpc = 119 + KERNEL_BASE,
    KeInterruptTime = 120 + KERNEL_BASE,
    KeIsExecutingDpc = 121 + KERNEL_BASE,
    KeLeaveCriticalRegion = 122 + KERNEL_BASE,
    KePulseEvent = 123 + KERNEL_BASE,
    KeQueryBasePriorityThread = 124 + KERNEL_BASE,
    KeQueryInterruptTime = 125 + KERNEL_BASE,
    KeQueryPerformanceCounter = 126 + KERNEL_BASE,
    KeQueryPerformanceFrequency = 127 + KERNEL_BASE,
    KeQuerySystemTime = 128 + KERNEL_BASE,
    KeRaiseIrqlToDpcLevel = 129 + KERNEL_BASE,
    KeRaiseIrqlToSynchLevel = 130 + KERNEL_BASE,
    KeReleaseMutant = 131 + KERNEL_BASE,
    KeReleaseSemaphore = 132 + KERNEL_BASE,
    KeRemoveByKeyDeviceQueue = 133 + KERNEL_BASE,
    KeRemoveDeviceQueue = 134 + KERNEL_BASE,
    KeRemoveEntryDeviceQueue = 135 + KERNEL_BASE,
    KeRemoveQueue = 136 + KERNEL_BASE,
    KeRemoveQueueDpc = 137 + KERNEL_BASE,
    KeResetEvent = 138 + KERNEL_BASE,
    KeRestoreFloatingPointState = 139 + KERNEL_BASE,
    KeResumeThread = 140 + KERNEL_BASE,
    KeRundownQueue = 141 + KERNEL_BASE,
    KeSaveFloatingPointState = 142 + KERNEL_BASE,
    KeSetBasePriorityThread = 143 + KERNEL_BASE,
    KeSetDisableBoostThread = 144 + KERNEL_BASE,
    KeSetEvent = 145 + KERNEL_BASE,
    KeSetEventBoostPriority = 146 + KERNEL_BASE,
    KeSetPriorityProcess = 147 + KERNEL_BASE,
    KeSetPriorityThread = 148 + KERNEL_BASE,
    KeSetTimer = 149 + KERNEL_BASE,
    KeSetTimerEx = 150 + KERNEL_BASE,
    KeStallExecutionProcessor = 151 + KERNEL_BASE,
    KeSuspendThread = 152 + KERNEL_BASE,
    KeSynchronizeExecution = 153 + KERNEL_BASE,
    KeSystemTime = 154 + KERNEL_BASE,
    KeTestAlertThread = 155 + KERNEL_BASE,
    KeTickCount = 156 + KERNEL_BASE,
    KeTimeIncrement = 157 + KERNEL_BASE,
    KeWaitForMultipleObjects = 158 + KERNEL_BASE,
    KeWaitForSingleObject = 159 + KERNEL_BASE,
    KfRaiseIrql = 160 + KERNEL_BASE,
    KfLowerIrql = 161 + KERNEL_BASE,
    KiBugCheckData = 162 + KERNEL_BASE,
    KiUnlockDispatcherDatabase = 163 + KERNEL_BASE,
    LaunchDataPage = 164 + KERNEL_BASE,
    MmAllocateContiguousMemory = 165 + KERNEL_BASE,
    MmAllocateContiguousMemoryEx = 166 + KERNEL_BASE,
    MmAllocateSystemMemory = 167 + KERNEL_BASE,
    MmClaimGpuInstanceMemory = 168 + KERNEL_BASE,
    MmCreateKernelStack = 169 + KERNEL_BASE,
    MmDeleteKernelStack = 170 + KERNEL_BASE,
    MmFreeContiguousMemory = 171 + KERNEL_BASE,
    MmFreeSystemMemory = 172 + KERNEL_BASE,
    MmGetPhysicalAddress = 173 + KERNEL_BASE,
    MmIsAddressValid = 174 + KERNEL_BASE,
    MmLockUnlockBufferPages = 175 + KERNEL_BASE,
    MmLockUnlockPhysicalPage = 176 + KERNEL_BASE,
    MmMapIoSpace = 177 + KERNEL_BASE,
    MmPersistContiguousMemory = 178 + KERNEL_BASE,
    MmQueryAddressProtect = 179 + KERNEL_BASE,
    MmQueryAllocationSize = 180 + KERNEL_BASE,
    MmQueryStatistics = 181 + KERNEL_BASE,
    MmSetAddressProtect = 182 + KERNEL_BASE,
    MmUnmapIoSpace = 183 + KERNEL_BASE,
    NtAllocateVirtualMemory = 184 + KERNEL_BASE,
    NtCancelTimer = 185 + KERNEL_BASE,
    NtClearEvent = 186 + KERNEL_BASE,
    NtClose = 187 + KERNEL_BASE,
    NtCreateDirectoryObject = 188 + KERNEL_BASE,
    NtCreateEvent = 189 + KERNEL_BASE,
    NtCreateFile = 190 + KERNEL_BASE,
    NtCreateIoCompletion = 191 + KERNEL_BASE,
    NtCreateMutant = 192 + KERNEL_BASE,
    NtCreateSemaphore = 193 + KERNEL_BASE,
    NtCreateTimer = 194 + KERNEL_BASE,
    NtDeleteFile = 195 + KERNEL_BASE,
    NtDeviceIoControlFile = 196 + KERNEL_BASE,
    NtDuplicateObject = 197 + KERNEL_BASE,
    NtFlushBuffersFile = 198 + KERNEL_BASE,
    NtFreeVirtualMemory = 199 + KERNEL_BASE,
    NtFsControlFile = 200 + KERNEL_BASE,
    NtOpenDirectoryObject = 201 + KERNEL_BASE,
    NtOpenFile = 202 + KERNEL_BASE,
    NtOpenSymbolicLinkObject = 203 + KERNEL_BASE,
    NtProtectVirtualMemory = 204 + KERNEL_BASE,
    NtPulseEvent = 205 + KERNEL_BASE,
    NtQueueApcThread = 206 + KERNEL_BASE,
    NtQueryDirectoryFile = 207 + KERNEL_BASE
};

struct KernelImageThunk {
    KernelImageFunction addresses[while(std::mem::read_unsigned($, 4) != 0x00)];
    padding[4];
};

union KernelImageThunkAddress {
    u32 debugAddress [[format("format_debug_kernel_image_thunk_address")]];
    u32 retailAddress [[format("format_retail_kernel_image_thunk_address")]];
    
    if ((debugAddress ^ 0xEFB1F152) - parent.baseAddress < std::mem::size())    
        KernelImageThunk debug    @ (debugAddress ^ 0xEFB1F152) - parent.baseAddress;;
    if ((retailAddress ^ 0x5B6D40B6) - parent.baseAddress < std::mem::size())
        KernelImageThunk retail   @ (retailAddress ^ 0x5B6D40B6) - parent.baseAddress;
};

fn format_debug_kernel_image_thunk_address(u32 value) {
    return std::format("0x{:08X}", value ^ 0xEFB1F152);
};

fn format_retail_kernel_image_thunk_address(u32 value) {
    return std::format("0x{:08X}", value ^ 0x5B6D40B6);
};

struct TLS {
    u32 rawDataStart, rawDataEnd;
    u32 indexAddress;
    u32 callbacksAddress;
    type::Size<u32> zeroFillSize;
    u32 characteristics;
};

fn relative_to_base(auto pointer) {
    return -parent.baseAddress;
};

fn relative_to_base_section(auto pointer) {
    return -parent.parent.baseAddress;
};

bitfield LibraryFlags {
    QFEVersion  : 13;
    Approved    : 2;
    DebugBuild  : 1;
};

struct LibraryVersion {
    char libraryName[8];
    u16 major, minor, build;
    LibraryFlags flags;
};

bitfield SectionFlags {
    Writable            : 1;
    Preload             : 1;
    Executable          : 1;
    InsertedFile        : 1;
    HeadPageReadOnly    : 1;
    TailPageReadOnly    : 1;
    padding : 26;
};

struct SectionHeader {
    SectionFlags sectionFlags;
    u32 virtualAddress;
    type::Size<u32> virtualSize;
    u32 rawAddress;
    type::Size<u32> rawSize;
    char *sectionName[] : u32 [[pointer_base("relative_to_base_section")]];
    u32 *sectionNameRefrenceCount : u32 [[pointer_base("relative_to_base_section")]];
    u16 *headSharedPageReferenceCount : u32 [[pointer_base("relative_to_base_section")]];
    u16 *tailSharedPageReferenceCount : u32 [[pointer_base("relative_to_base_section")]];
    u8 sectionDigest[20];
    
    u8 data[rawSize] @ rawAddress [[sealed]];
};

struct XBEH {
    type::Magic<"XBEH"> magic;
    u8 signature[0x100] [[sealed]];
    u32 baseAddress;
    type::Size<u32> headerSize, imageSize, imageHeaderSize;
    type::time32_t timeDate;
    Certificate *certificate : u32 [[pointer_base("relative_to_base")]];
    u32 numSections;
    SectionHeader *sectionHeader[numSections] : u32 [[pointer_base("relative_to_base")]];
    InitializationFlags initializationFlags;
    EntryPoint entrypoint;
    TLS *tls : u32 [[pointer_base("relative_to_base")]];
    
    type::Size<u32> stackSize;
    u32 peHeapReserve, peHeapCommit, peBaseAddress;
    type::Size<u32> peImageSize;
    u32 peChecksum;
    type::time32_t peTimeDate;
    char *debugPathNameAddress[] : u32 [[pointer_base("relative_to_base")]];
    char *debugFileNameAddress[] : u32 [[pointer_base("relative_to_base")]];
    char16 *utf16DebugFileNameAddress[] : u32 [[pointer_base("relative_to_base")]];
    KernelImageThunkAddress kernelImageThunkAddress;
    u32 nonKernelImportDirectoryAddress;
    u32 numLibraryVersions;
    LibraryVersion *libraryVersonTable[numLibraryVersions] : u32 [[pointer_base("relative_to_base")]];
    LibraryVersion *kernelLibraryVersion : u32 [[pointer_base("relative_to_base")]];
    LibraryVersion *xapiLibraryVersion : u32 [[pointer_base("relative_to_base")]];
    u32 logoBitMapAddress, logoBitmapSize;
    u64 unknown1;
    u32 unknown2;
    
    u8 logoBitmap[logoBitmapSize] @ logoBitMapAddress - baseAddress;
};

XBEH xbeh @ 0x00;