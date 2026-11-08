#pragma author Scott Anderson
#pragma description Unreal Engine Save Game

#pragma magic [ 47 56 41 53 0? 00 00 00 ] @ 0x00
#pragma endian little

// Subnautica 2
#pragma magic [ 47 53 57 55 ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 47 56 41 53 0? 00 00 00 ] @ 0x00

#pragma eval_depth         64
#pragma array_limit    300000
#pragma pattern_limit 2000000

import std.core;
import std.io;
import std.math;
import std.mem;
import std.time;
import type.magic;
import type.size;

// ====== Save Game Header constants ======

/// Save Game File Version from FSaveGameFileVersion::Type
/// See: Engine/Source/Runtime/Engine/Private/GameplayStatics.cpp
enum SaveGameFileVersion : u32 {
    InitialVersion = 1,
    AddedCustomVersions,
    PackageFileSummaryVersionChange,
};

/// UE4 object versions.
/// See: Engine/Source/Runtime/Core/Public/UObject/ObjectVersion.h
enum EUnrealEngineObjectUE4Version : u32 {
    VER_UE4_OLDEST_LOADABLE_PACKAGE = 214,
    VER_UE4_FTEXT_HISTORY = 368,
    VER_UE4_FTEXT_HISTORY_DATE_TIMEZONE = 422,
};

/// UE5 object versions
/// See: Engine/Source/Runtime/Core/Public/UObject/ObjectVersion.h
enum EUnrealEngineObjectUE5Version : u32 {
    INITIAL_VERSION = 1000,
    NAMES_REFERENCED_FROM_EXPORT_DATA,
    PAYLOAD_TOC,
    OPTIONAL_RESOURCES,
    LARGE_WORLD_COORDINATES,
    REMOVE_OBJECT_EXPORT_PACKAGE_GUID,
    TRACK_OBJECT_EXPORT_IS_INHERITED,
    FSOFTOBJECTPATH_REMOVE_ASSET_PATH_FNAMES,
    ADD_SOFTOBJECTPATH_LIST,
    DATA_RESOURCES,
    SCRIPT_SERIALIZATION_OFFSET,
    PROPERTY_TAG_EXTENSION_AND_OVERRIDABLE_SERIALIZATION,
    PROPERTY_TAG_COMPLETE_TYPE_NAME,
    ASSETREGISTRY_PACKAGEBUILDDEPENDENCIES,
    METADATA_SERIALIZATION_OFFSET,
    VERSE_CELLS,
    PACKAGE_SAVED_HASH,
    OS_SUB_OBJECT_SHADOW_SERIALIZATION,
    IMPORT_TYPE_HIERARCHIES,

    // new versions can be added before this line
    AUTOMATIC_VERSION_PLUS_ONE,
    AUTOMATIC_VERSION = EUnrealEngineObjectUE5Version::AUTOMATIC_VERSION_PLUS_ONE - 1
};

// ====== Custom version constants ======

/// Custom serialization version for changes made in //UE5/Release-* stream
/// See: Engine/Source/Runtime/Core/Public/UObject/UE5ReleaseStreamObjectVersion.h
enum EUE5ReleaseStreamObjectVersion : s32 {
    BeforeCustomVersionWasAdded = 0,
    ReflectionMethodEnum,
    WorldPartitionActorDescSerializeHLODInfo,
    RemovingTessellation,
    LevelInstanceSerializeRuntimeBehavior,
    PoseAssetRuntimeRefactor,
    WorldPartitionActorDescSerializeActorFolderPath,
    HairStrandsVertexFormatChange,
    AddChaosMaxLinearAngularSpeed,
    PackedLevelInstanceVersion,
    PackedLevelInstanceBoundsFix,
    CustomPropertyAnimGraphNodesUseOptionalPinManager,
    TextFormatArgumentData64bitSupport,
    MaterialLayerStacksAreNotParameters,
    MaterialInterfaceSavedCachedData,
    AddClothMappingLODBias,
    AddLevelActorPackagingScheme,
    WorldPartitionActorDescSerializeAttachParent,
    ConvertedActorGridPlacementToSpatiallyLoadedFlag,
    ActorGridPlacementDeprecateDefaultValueFixup,
    PackedLevelActorUseWorldPartitionActorDesc,
    AddLevelActorFolders,
    RemoveSkeletalMeshLODModelBulkDatas,
    ExcludeBrightnessFromEncodedHDRCubemap,
    VolumetricCloudSampleCountUnification,
    PoseAssetRawDataGUID,
    ConvolutionBloomIntensity,
    WorldPartitionHLODActorDescSerializeHLODSubActors,
    LargeWorldCoordinates,
};
const u128 GUID_UE5_RELEASE_STREAM = 0xDF6417798412ACA824BD4D46D89B5E42;

/// Custom serialization version for changes made in Dev-Editor stream.
/// See: Engine/Source/Runtime/Core/Public/UObject/EditorObjectVersion.h
enum EEditorObjectVersion : s32 {
    BeforeCustomVersionWasAdded = 0,
    GatheredTextProcessVersionFlagging,
    GatheredTextPackageCacheFixesV1,
    RootMetaDataSupport,
    GatheredTextPackageCacheFixesV2,
    TextFormatArgumentDataIsVariant,
    SplineComponentCurvesInStruct,
    ComboBoxControllerSupportUpdate,
    RefactorMeshEditorMaterials,
    AddedFontFaceAssets,
    UPropertryForMeshSection,
    WidgetGraphSchema,
    AddedBackgroundBlurContentSlot,
    StableUserDefinedEnumDisplayNames,
    AddedInlineFontFaceAssets,
    UPropertryForMeshSectionSerialize,
    FastWidgetTemplates,
    MaterialThumbnailRenderingChanges,
    NewSlateClippingSystem,
    MovieSceneMetaDataSerialization,
    GatheredTextEditorOnlyPackageLocId,
    AddedAlwaysSignNumberFormattingOption,
    AddedMaterialSharedInputs,
    AddedMorphTargetSectionIndices,
    SerializeInstancedStaticMeshRenderData,
    MeshDescriptionNewSerializationMovedToRelease,
    MeshDescriptionNewAttributeFormat,
    ChangeSceneCaptureRootComponent,
    StaticMeshDeprecatedRawMesh,
    MeshDescriptionBulkDataGuid,
    MeshDescriptionRemovedHoles,
    ChangedWidgetComponentWindowVisibilityDefault,
    CultureInvariantTextSerializationKeyStability,
    ScrollBarThicknessChange,
    RemoveLandscapeHoleMaterial,
    MeshDescriptionTriangles,
    ComputeWeightedNormals,
    SkeletalMeshBuildRefactor,
    SkeletalMeshMoveEditorSourceDataToPrivateAsset,
    NumberParsingOptionsNumberLimitsAndClamping,
    SkeletalMeshSourceDataSupport16bitOfMaterialNumber,
};
const u128 GUID_EDITOR = 0x2E46BB41A231DA0BF49442E9E4B068ED;

// ====== Save Game Header types ======

struct FString {
    s32 length;
    if (length > 0) {
        // ASCII, treated as UTF-8
        char data[length - 1];
        type::Magic<"\x00"> terminator;
    } else if (length < 0) {
        // UTF-16
        char16 data[-length - 1];
        type::Magic<"\x00\x00"> terminator;
    } else {
        // Null
    }
} [[sealed, format("format_fstring")]];

fn format_fstring(FString string) {
    return string.length == 0
        ? "null"
        : std::format("\"{}\"", std::string::replace(std::format("{}", string.data), "\n", "\\n"));
};

struct FEngineVersion {
    u16 major, minor, patch;
    u32 changeList;
    FString branch;
} [[sealed, format("format_fengineversion")]];

fn format_fengineversion(FEngineVersion version) {
    const str branch = std::string::replace(version.branch.data, "+", "/");
    return std::format(
        "{}.{}.{}-{} {}",
        version.major, version.minor, version.patch,
        version.changeList,
        branch);
};

struct FGuid {
    u32 a, b, c, d;
} [[sealed, format("format_fguid")]];

fn format_fguid(FGuid value) {
    return std::format("{{{:08X}-{:04X}-{:04X}-{:04X}-{:04X}{:08X}}}",
        value.a,
        value.b >> 16,
        value.b & 0xFFFF,
        value.c >> 16,
        value.c & 0xFFFF,
        value.d);
};

fn guid_u128(FGuid value) {
    return u128(value.d) << 96 | u128(value.c) << 64 | u128(value.b) << 32 | value.a;
};

struct FCustomVersion {
    FGuid key;
    match (guid_u128(key)) {
        (GUID_UE5_RELEASE_STREAM): EUE5ReleaseStreamObjectVersion value;
        (GUID_EDITOR): EEditorObjectVersion value;
        (_): s32 value;
    }
} [[name(format_fguid(key)), format("format_fcustomversion")]];

fn format_fcustomversion(FCustomVersion version) {
    return version.value;
};

enum ECustomVersionSerializationFormat : u32 {
    Unknown,
    Guids,
    Enums,
    Optimized,
};

struct FPackageFileVersion<auto saveGameFileVersion> {
    if (saveGameFileVersion >= SaveGameFileVersion::PackageFileSummaryVersionChange) {
        EUnrealEngineObjectUE4Version fileVersionUE4;
        EUnrealEngineObjectUE5Version fileVersionUE5;
        if (fileVersionUE5 >= EUnrealEngineObjectUE5Version::AUTOMATIC_VERSION) {
            std::warning(std::format(
                "Package file version UE5 {} not recognized, attempting to load...",
                u32(fileVersionUE5)));
        }
    } else {
        EUnrealEngineObjectUE4Version fileVersion;
        const EUnrealEngineObjectUE4Version fileVersionUE4 = fileVersion;
    }
    if (fileVersionUE4 < EUnrealEngineObjectUE4Version::VER_UE4_OLDEST_LOADABLE_PACKAGE) {
        std::error(std::format(
            "Package file version {} is too old",
            u32(fileVersionUE4)));
    }
};

struct FCustomVersionContainer {
    ECustomVersionSerializationFormat customVersionFormat;
    if (customVersionFormat != ECustomVersionSerializationFormat::Optimized) {
        std::error(std::format(
            "Unsupported custom version format {}",
            u32(customVersionFormat)));
    }
    s32 count;
    FCustomVersion customVersions[count] [[single_color]];
};

struct FSaveGameHeader {
    if (std::mem::read_unsigned($, 4, std::mem::Endian::Little) == 0x55575347) {
        padding[16];
    }
    type::Magic<"GVAS"> fileTypeTag;
    SaveGameFileVersion saveGameFileVersion;
    FPackageFileVersion<saveGameFileVersion> packageFileVersion;
    FEngineVersion engineVersion;
    if (saveGameFileVersion >= SaveGameFileVersion::AddedCustomVersions) {
        FCustomVersionContainer customVersions;
    }
    FString saveGameClassName;
};

// ====== Save Game Header ======

FSaveGameHeader header @ 0;

// ====== Property serialization logic ======

const EUnrealEngineObjectUE4Version fileVersionUE4 = header.packageFileVersion.fileVersionUE4;
const bool ftextHistoryDateTimezone =
    fileVersionUE4 >= EUnrealEngineObjectUE4Version::VER_UE4_FTEXT_HISTORY_DATE_TIMEZONE;
const bool propertyTagCompleteTypeName =
    (header.saveGameFileVersion >= SaveGameFileVersion::PackageFileSummaryVersionChange) &&
    (header.packageFileVersion.fileVersionUE5 >= EUnrealEngineObjectUE5Version::PROPERTY_TAG_COMPLETE_TYPE_NAME);
const bool fsoftobjectpathRemoveAssetPathFNames =
    (header.saveGameFileVersion >= SaveGameFileVersion::PackageFileSummaryVersionChange) &&
    (header.packageFileVersion.fileVersionUE5 >= EUnrealEngineObjectUE5Version::FSOFTOBJECTPATH_REMOVE_ASSET_PATH_FNAMES);

fn custom_version(u128 guid) {
    for (u32 i = 0, i < header.customVersions.count, i = i + 1) {
        if (guid_u128(header.customVersions.customVersions[i].key) == guid) {
            return header.customVersions.customVersions[i].value;
        }
    }
    return 0; // not found
};

const EUE5ReleaseStreamObjectVersion releaseVersion = custom_version(GUID_UE5_RELEASE_STREAM);
const bool      text64bitSupport = releaseVersion >= EUE5ReleaseStreamObjectVersion::TextFormatArgumentData64bitSupport;
const bool largeWorldCoordinates = releaseVersion >= EUE5ReleaseStreamObjectVersion::LargeWorldCoordinates;

const EEditorObjectVersion editorVersion = custom_version(GUID_EDITOR);
const bool         includeAlwaysSign = editorVersion >= EEditorObjectVersion::AddedAlwaysSignNumberFormattingOption;
const bool cultureInvariantStability = editorVersion >= EEditorObjectVersion::CultureInvariantTextSerializationKeyStability;

// ====== Text serialization ======

enum EFormatArgumentType: u8 {
    Int,
    UInt,
    Float,
    Double,
    Text,
    Gender,
};

using FText;
struct FormatArgumentValue {
    EFormatArgumentType type;
    match (type) {
        (EFormatArgumentType::Double): double value;
        (EFormatArgumentType::Float): float value;
        (EFormatArgumentType::Int): {
            if (text64bitSupport) {
                s64 value;
            } else {
                s32 value;
            }
        }
        (EFormatArgumentType::UInt | EFormatArgumentType::Gender): {
            if (text64bitSupport) {
                u64 value;
            } else {
                u32 value;
            }
        }
        (EFormatArgumentType::Text): FText value;
        (_): {
            std::error(std::format(
                "Unknown FormatArgumentValue type {} ({})",
                type, u8(type)));
        }
    }
};

struct ArgumentFormatEntry {
    FString name;
    FormatArgumentValue value;
};

enum RoundingMode : s8 {
    HalfToEven,
    HalfFromZero,
    HalfToZero,
    FromZero,
    ToZero,
    ToNegativeInfinity,
    ToPositiveInfinity,
};

struct NumberFormattingOptions {
    if (includeAlwaysSign) u32 alwaysSign;
    u32 useGrouping;
    RoundingMode roundingMode;
    s32 minimumIntegralDigits;
    s32 maximumIntegralDigits;
    s32 minimumFractionalDigits;
    s32 maximumFractionalDigits;
};

enum ETextHistoryType : u8 {
    None = 255,
    Base = 0,
    NamedFormat,
    OrderedFormat,
    ArgumentFormat,
    AsNumber,
    AsPercent,
    AsCurrency,
    AsDate,
    AsTime,
    AsDateTime,
    Transform,
    StringTableEntry,
    TextGenerator,
};

enum EDateTimeStyle : s8 {
    Default,
    Short,
    Medium,
    Long,
    Full,
    Custom,
};

using FDateTime;
struct FTextHistory {
    ETextHistoryType type;
    match (type) {
        (ETextHistoryType::None): {
            if (cultureInvariantStability) {
                u32 hasCultureInvariantString;
                if (hasCultureInvariantString) {
                    FString cultureInvariantString;
                }
            } else {
                const bool hasCultureInvariantString = false;
            }
        }
        (ETextHistoryType::Base): {
            FString nameSpace;
            FString key;
            FString sourceString;
        }
        (ETextHistoryType::NamedFormat): {
            FText formatText;
        }
        (ETextHistoryType::OrderedFormat): {
            FText formatText;
        }
        (ETextHistoryType::ArgumentFormat): {
            FText sourceFormat;
            u32 argumentCount;
            ArgumentFormatEntry arguments[argumentCount];
        }
        (ETextHistoryType::AsNumber): {
            FormatArgumentValue sourceValue;
            u32 hasFormatOptions;
            if (hasFormatOptions) {
                NumberFormattingOptions formatOptions;
            }
            FString targetCulture;
        }
        // (ETextHistoryType::AsPercent): {}
        // (ETextHistoryType::AsCurrency): {}
        (ETextHistoryType::AsDate): {
            FDateTime sourceDateTime;
            EDateTimeStyle dateStyle;
            if (ftextHistoryDateTimezone) {
                FString timeZone;
            }
            FString cultureName;
        }
        (ETextHistoryType::AsTime): {
            FDateTime sourceDateTime;
            EDateTimeStyle timeStyle;
            FString timeZone;
            FString cultureName;
        }
        (ETextHistoryType::AsDateTime): {
            FDateTime sourceDateTime;
            EDateTimeStyle dateStyle, timeStyle;
            if (dateStyle == EDateTimeStyle::Custom) {
                FString customPattern;
            }
            FString timeZone;
            FString cultureName;
        }
        // (ETextHistoryType::Transform): {}
        (ETextHistoryType::StringTableEntry): {
            FString tableId;
            FString key;
        }
        // (ETextHistoryType::TextGenerator): {}
        // (ETextHistoryType::RawText): {}
        (_): {
            std::error(std::format(
                "Unsupported TextHistory type {} ({})",
                type, u8(type)));
        }
    }
};

struct FText {
    u32 flags;
    if (fileVersionUE4 < EUnrealEngineObjectUE4Version::VER_UE4_FTEXT_HISTORY) {
        std::error("Not supported");
    } else {
        FTextHistory history [[inline]];
    }
} [[single_color, format("format_ftext")]];

fn format_ftext(FText text) {
    match (text.history.type) {
        (ETextHistoryType::None): {
            if (cultureInvariantStability) {
                if (text.history.hasCultureInvariantString) {
                    return text.history.cultureInvariantString;
                }
                return "";
            } else {
                return text.history.cultureInvariantString;
            }
        }
        (ETextHistoryType::Base): return text.history.sourceString;
    }
    return text;
};

// ====== Struct serialization ======

struct FDateTime {
    u64 ticks;
} [[format("format_fdatetime")]];

fn format_fdatetime(FDateTime dt) {
    // Convert 100-ns intervals since 01-01-0001 to seconds since 01-01-1970
    std::time::EpochTime et = dt.ticks / 10000000 - 62135596800;
    std::time::Time t = std::time::to_local(et);
    str s = std::time::format(t);
    return s;
};

struct FGameplayTagContainer {
    u32 count;
    FString tags[count];
};

struct FIntPoint {
    s32 x, y;
};

struct FLinearColor {
    float r, g, b, a;
};

struct FQuat {
    if (largeWorldCoordinates) {
        double x, y, z, w;
    } else {
        float x, y, z, w;
    }
};

struct FRotator {
    if (largeWorldCoordinates) {
        double pitch, yaw, roll;
    } else {
        float pitch, yaw, roll;
    }
};

struct FTimespan {
    u64 ticks;
};

struct FVector2D {
    double x, y;
};

struct FVector {
    if (largeWorldCoordinates) {
        double x, y, z;
    } else {
        float x, y, z;
    }
};

// ====== Property serialization ======

struct FDelegateProperty {
    FString object, functionName;
};

struct FMulticastInlineDelegateProperty {
    u32 count [[hidden]];
    FDelegateProperty delegates[count];
} [[inline]];

struct FMulticastSparseDelegateProperty {
    u32 count [[hidden]];
    FDelegateProperty delegates[count];
} [[inline]];

struct FSoftObjectProperty {
    FString asset_path;
    if (fsoftobjectpathRemoveAssetPathFNames) {
        FString package;
        FString asset;
    } else {
        FString sub_path;
    }
};

bitfield EPropertyTagFlags {
    bool hasArrayIndex              : 1;
    bool hasPropertyGuid            : 1;
    bool hasPropertyExtensions      : 1;
    bool hasBinaryOrNativeSerialize : 1;
    bool boolTrue                   : 1;
};

struct FPropertyTypeName {
    FString name;
    u32 count;
    if (count > 0) FPropertyTypeName children[count];
} [[format("format_fpropertytypename")]];

fn format_fpropertytypename(FPropertyTypeName node) {
    if (node.count == 0) return node.name.data;
    str a = std::format("{}<{}", node.name.data, node.children[0]);
    for (auto i = 1, i < node.count, i += 1) {
        a = std::format("{}, {}", a, node.children[i]);
    }
    return std::format("{}>", a);
};

using TaggedProperties;
struct FStructProperty<auto structType, auto size> {
    try {
        match (structType) {
            ("DateTime"): FDateTime value;
            ("GameplayTagContainer"): FGameplayTagContainer value;
            ("Guid"): FGuid value;
            ("IntPoint"): FIntPoint value;
            ("LinearColor"): FLinearColor value;
            ("Quat"): FQuat value;
            ("Rotator"): FRotator value;
            ("Timespan"): FTimespan value;
            ("Vector"): FVector value;
            ("Vector2D"): FVector2D value;
            (_): TaggedProperties value;
        }
    } catch {
        std::warning(std::format(
            "StructProperty parsing failed for {}",
            structType));
        // Wrap the unknown data
        std::mem::Bytes<size> value;
    }
} [[inline, format("format_fstructproperty")]];

fn format_fstructproperty(auto property) {
    return property.value;
};

struct FProperty<auto type> {
    match (type) {
        ("DoubleProperty"): double value;
        ("FloatProperty"): float value;
        ("IntProperty"): s32 value;
        ("Int8Property"): s8 value;
        ("Int16Property"): s16 value;
        ("Int64Property"): s64 value;
        ("UInt16Property"): u16 value;
        ("UInt32Property"): u32 value;
        ("UInt64Property"): u64 value;
        ("DelegateProperty"): FDelegateProperty value;
        ("MulticastInlineDelegateProperty"): FMulticastInlineDelegateProperty value;
        ("MulticastSparseDelegateProperty"): FMulticastSparseDelegateProperty value;
        ("SoftObjectProperty"): FSoftObjectProperty value;
        ("EnumProperty" | "StrProperty" | "NameProperty" | "ObjectProperty"): FString value;
        ("TextProperty"): FText value;
        ("StructProperty"): TaggedProperties value;
        (_): std::error(std::format("Unsupported property {}", type));
    }
} [[format("format_fproperty")]];

fn format_fproperty(auto property) {
    return property.value;
};

struct MapEntry<auto K, auto V> {
    FProperty<K> key;
    FProperty<V> value;
} [[name(key), format("format_mapentry")]];

fn format_mapentry(auto entry) {
    return entry.value;
};

struct FMapProperty<auto K, auto V> {
    u32 allocationFlags;
    u32 count;
    MapEntry<K, V> properties[count] [[inline]];
};

struct FSetProperty<auto T> {
    u32 allocationFlags;
    u32 count;
    FProperty<T> properties[count] [[inline]];
};

/// The header that precedes each property value.
/// See: Engine/Source/Runtime/CoreUObject/Private/UObject/PropertyTag.cpp
struct FPropertyTag {
    FString name;
    if (name.length == 0 || name.data == "None") {
        break;
    }
    if (propertyTagCompleteTypeName) {
        FPropertyTypeName propertyType;
        type::Size32 size;
        EPropertyTagFlags flags;
        if (flags.hasArrayIndex) {
            u32 arrayIndex;
        }
        if (flags.hasPropertyGuid) {
            FGuid propertyGuid;
        }
        if (flags.hasPropertyExtensions) {
            std::error(std::format(
                "FPropertyTag {} @ 0x{:X}; hasPropertyExtensions not supported",
                name.data, addressof(name)));
        }
        const str propertyTypeStr = propertyType.name.data;
        match (propertyTypeStr) {
            ("ArrayProperty"): {
                const str arrayInnerType = propertyType.children[0].name.data;
                if (arrayInnerType == "StructProperty") {
                    const str structTypeName = propertyType.children[0].children[0].name.data;
                }
            }
            ("SetProperty"): {
                const str setElementType = propertyType.children[0].name.data;
            }
            ("MapProperty"): {
                const str mapKeyType = propertyType.children[0].name.data;
                const str mapValueType = propertyType.children[1].name.data;
            }
            ("StructProperty"): {
                const str structTypeName = propertyType.children[0].name.data;
            }
        }
        const bool boolValue = flags.boolTrue;
    } else {
        FString propertyType;
        type::Size32 size;
        u32 arrayIndex;
        const str propertyTypeStr = propertyType.data;
        match (propertyTypeStr) {
            ("StructProperty"): {
                FString typeName;
                FGuid structGuid;
                const str structTypeName = typeName.data;
            }
            ("BoolProperty"): {
                bool value;
                const bool boolValue = value;
            }
            ("ByteProperty" | "EnumProperty"): FString enumName;
            ("ArrayProperty"): {
                FString innerType;
                const str arrayInnerType = innerType.data;
            }
            ("SetProperty"): {
                FString innerType;
                const str setElementType = innerType.data;
            }
            ("OptionalProperty"): FString innerType;
            ("MapProperty"): {
                FString innerType;
                FString valueType;
                const str mapKeyType = innerType.data;
                const str mapValueType = valueType.data;
            }
        }
        bool hasPropertyGuid;
        if (hasPropertyGuid) {
            FGuid propertyGuid;
        }
    }
} [[format("format_fpropertytag")]];

fn format_fpropertytag(FPropertyTag tag) {
    if (propertyTagCompleteTypeName) {
        return tag.propertyType;
    }
    match (tag.propertyTypeStr) {
        ("ArrayProperty" | "SetProperty" | "OptionalProperty"):
            return std::format("{}<{}>", tag.propertyTypeStr, tag.innerType.data);
        ("MapProperty"):
            return std::format("{}<{}, {}>", tag.propertyTypeStr, tag.innerType.data, tag.valueType.data);
        ("StructProperty"):
            return std::format("{}<{}>", tag.propertyTypeStr, tag.typeName.data);
        ("ByteProperty" | "EnumProperty"):
            return std::format("{}<{}>", tag.propertyTypeStr, tag.enumName.data);
    }
    return tag.propertyTypeStr;
};

struct FArrayProperty<auto tag> {
    const u128 end = $ + tag.size;
    u32 count;
    match (tag.arrayInnerType) {
        ("BoolProperty"): bool values[count];
        ("ByteProperty"): {
            if (count + 4 == tag.size) {
                std::mem::Bytes<count> values;
            } else {
                FString values[count];
            }
        }
        ("DoubleProperty"): double values[count];
        ("EnumProperty" | "StrProperty" | "NameProperty" | "ObjectProperty"): FString values[count];
        ("FloatProperty"): float values[count];
        ("IntProperty"): s32 values[count];
        ("SoftObjectProperty"): FSoftObjectProperty values[count];
        ("StructProperty"): {
            if (propertyTagCompleteTypeName) {
                const str structTypeName = tag.structTypeName;
            } else {
                // Arrays of structs repeat the tag once, for all elements
                FPropertyTag innerTag;
                std::assert(innerTag.propertyTypeStr == "StructProperty", std::format(
                    "Array {} @ 0x{:X}; expected StructProperty, got {}",
                    tag.name.data, addressof(innerTag), innerTag.propertyTypeStr));
                const str structTypeName = innerTag.structTypeName;
            }
            try {
                match (structTypeName) {
                    ("DateTime"): FDateTime values[count];
                    ("GameplayTagContainer"): FGameplayTagContainer values[count];
                    ("Guid"): FGuid values[count];
                    ("IntPoint"): FIntPoint values[count];
                    ("LinearColor"): FLinearColor values[count];
                    ("Quat"): FQuat values[count];
                    ("Rotator"): FRotator values[count];
                    ("Timespan"): FTimespan values[count];
                    ("Vector"): FVector values[count];
                    ("Vector2D"): FVector2D values[count];
                    (_): TaggedProperties values[count];
                }
            } catch {
                std::warning(std::format(
                    "Array {} @ 0x{:X}; Failed to parse array of structs size {} in {}",
                    tag.name.data, addressof(this), tag.size, structTypeName));
                // Wrap the unknown data
                std::mem::Bytes<end - $> values;
            }
        }
        ("TextProperty"): FText values[count];
        (_): {
            std::warning(std::format(
                "Unknown array element type {} in {}",
                tag.arrayInnerType, tag.name.data));
            // Wrap the unknown data
            std::mem::Bytes<end - $> values;
        }
    }
} [[format("format_farrayproperty")]];

fn format_farrayproperty(auto array) {
    return array.values;
};

/// A property tag followed by the property value it describes.
struct TaggedProperty {
    FPropertyTag tag;
    const u128 start = $;
    match (tag.propertyTypeStr) {
        ("ArrayProperty"): FArrayProperty<tag> property;
        ("BoolProperty"): {
            const bool property = tag.boolValue;
        }
        ("ByteProperty"): {
            match (tag.size) {
                (0|1): u8 property;
                (_): FString property;
            }
        }
        ("DoubleProperty"): double property;
        ("FloatProperty"): float property;
        ("IntProperty"): s32 property;
        ("Int8Property"): s8 property;
        ("Int16Property"): s16 property;
        ("Int64Property"): s64 property;
        ("UInt16Property"): u16 property;
        ("UInt32Property"): u32 property;
        ("UInt64Property"): u64 property;
        ("DelegateProperty"): FDelegateProperty property;
        ("MulticastInlineDelegateProperty"): FMulticastInlineDelegateProperty property;
        ("MulticastSparseDelegateProperty"): FMulticastSparseDelegateProperty property;
        ("SoftObjectProperty"): FSoftObjectProperty property;
        ("EnumProperty" | "StrProperty" | "NameProperty" | "ObjectProperty"): FString property;
        ("MapProperty"): {
            if (propertyTagCompleteTypeName && tag.flags.hasBinaryOrNativeSerialize) {
                // Wrap the unknown data
                std::mem::Bytes<tag.size> property;
            } else {
                try {
                    FMapProperty<tag.mapKeyType, tag.mapValueType> property;
                } catch {
                    std::warning(std::format(
                        "MapProperty<{}, {}> {} @ 0x{:04X}; Failed to parse",
                        tag.mapKeyType, tag.mapValueType, tag.name.data, $));
                    // Wrap the unknown data
                    std::mem::Bytes<tag.size> property;
                }
            }
        }
        ("SetProperty"): {
            try {
                FSetProperty<tag.setElementType> property;
            } catch {
                std::warning(std::format(
                    "SetProperty<{}> {} @ 0x{:04X}; Failed to parse",
                    tag.setElementType, tag.name.data, $));
                // Wrap the unknown data
                std::mem::Bytes<tag.size> property;
            }
        }
        ("StructProperty"): FStructProperty<tag.structTypeName, tag.size> property;
        ("TextProperty"): {
            try {
                FText property;
            } catch {
                std::warning(std::format(
                    "FText {} @ 0x{:04X}; Failed to parse",
                    tag.name.data, $));
                // Wrap the unknown data
                std::mem::Bytes<tag.size> property;
            }
        }
        (_): {
            std::warning(std::format(
                "Unknown property type {} in {}",
                tag, tag.name.data));
            // Wrap the unknown data
            std::mem::Bytes<tag.size> property;
        }
    }

    s32 bytesRemaining = tag.size + start - $;
    if (bytesRemaining != 0) {
        std::warning(std::format(
            "Property length mismatch while parsing {} {}. Bytes {}: {}",
            tag,
            tag.name.data,
            bytesRemaining < 0 ? "overrun" : "remaining",
            std::math::abs(bytesRemaining)));
        // Adjust the file offset
        $ += bytesRemaining;
    }
} [[name(tag.name.length == 0 ? "null" : tag.name.data), format("format_taggedproperty")]];

fn format_taggedproperty(TaggedProperty property) {
    if (!std::core::has_member(property, "property")) {
        return "";
    }
    return property.property;
};

struct TaggedProperties {
    TaggedProperty values[while(true)] [[inline]];
};

struct SaveGameFile {
    if (propertyTagCompleteTypeName) {
        type::Magic<"\x00"> spacer [[hidden]];
    }
    TaggedProperties properties;
    type::Magic<"\x00\x00\x00\x00"> footer;
};
SaveGameFile file @ $ [[inline]];

std::assert_warn(std::mem::eof(), std::format("Expected EOF @ 0x{:04X}", $));