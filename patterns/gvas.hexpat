#pragma author Scott Anderson
#pragma description Unreal Engine Save Game

#pragma magic [ 47 56 41 53 0? 00 00 00 ] @ 0x00
#pragma endian little

#pragma array_limit    300000
#pragma pattern_limit 2000000

import std.io;
import std.math;
import type.magic;

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
/// See: Engine/Source/Runtime/Core/Public/UObject/UE5ReleaseStreamObjectVersions.inl
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
        try {
            char data[length - 1];
        } catch {
            std::error(std::format(
                "Invalid string length 0x{:x}",
                length));
        }
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
        : std::format("\"{}\"", string.data);
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

struct FCustomVersion {
    u128 key;
    match (key) {
        (GUID_UE5_RELEASE_STREAM): EUE5ReleaseStreamObjectVersion value;
        (GUID_EDITOR): EEditorObjectVersion value;
        (_): s32 value;
    }
} [[sealed, name(std::format("0x{:032X}", key)), format("format_fcustomversion")]];

fn format_fcustomversion(FCustomVersion version) {
    return version.value;
};

struct FSaveGameHeader {
    type::Magic<"GVAS"> fileTypeTag;
    SaveGameFileVersion saveGameFileVersion;
    EUnrealEngineObjectUE4Version packageFileVersion;
    if (packageFileVersion < EUnrealEngineObjectUE4Version::VER_UE4_OLDEST_LOADABLE_PACKAGE) {
        std::error(std::format(
            "Package file version {} is too old",
            u32(packageFileVersion)));
    }
    if (saveGameFileVersion >= SaveGameFileVersion::PackageFileSummaryVersionChange) {
        EUnrealEngineObjectUE5Version packageFileVersionUE5;
        if (packageFileVersionUE5 >= EUnrealEngineObjectUE5Version::AUTOMATIC_VERSION) {
            std::warning(std::format(
                "Package file version UE5 {} not recognized, attempting to load...",
                u32(packageFileVersionUE5)));
        }
    }
    FEngineVersion engineVersion;
    if (saveGameFileVersion >= SaveGameFileVersion::AddedCustomVersions) {
        s32 customVersionFormat, customVersionLength;
        FCustomVersion customVersions[customVersionLength] [[single_color]];
    }
    FString saveGameClassName;
};

// ====== Save Game Header ======

FSaveGameHeader header @ 0;

// ====== Property serialization logic ======

const bool propertyTagCompleteTypeName =
    (header.saveGameFileVersion >= SaveGameFileVersion::PackageFileSummaryVersionChange) &&
    (header.packageFileVersionUE5 >= EUnrealEngineObjectUE5Version::PROPERTY_TAG_COMPLETE_TYPE_NAME);

fn custom_version(u128 guid) {
    for (u32 i = 0, i < header.customVersionLength, i = i + 1) {
        if (header.customVersions[i].key == guid) {
            return header.customVersions[i].value;
        }
    }
    return 0; // not found
};

const EUE5ReleaseStreamObjectVersion releaseVersion = custom_version(GUID_UE5_RELEASE_STREAM);
const bool largeWorldCoordinates = releaseVersion >= EUE5ReleaseStreamObjectVersion::LargeWorldCoordinates;
const bool text64bitSupport      = releaseVersion >= EUE5ReleaseStreamObjectVersion::TextFormatArgumentData64bitSupport;

const EEditorObjectVersion editorVersion = custom_version(GUID_EDITOR);
const bool cultureInvariantStability = editorVersion >= EEditorObjectVersion::CultureInvariantTextSerializationKeyStability;

// ====== Property serialization ======

enum TextHistoryType : u8 {
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

enum FormatArgumentType: u8 {
    Int,
    UInt,
    Float,
    Double,
    Text,
};

using FText;
struct FormatArgumentValue {
    FormatArgumentType type;
    match (type) {
        (FormatArgumentType::Int): {
            // FUE5ReleaseStreamObjectVersion::TextFormatArgumentData64bitSupport
            if (text64bitSupport) {
                u64 value;
            } else {
                u32 value;
            }
        }
        (FormatArgumentType::Text): FText value;
        (_): {
            std::error(std::format(
                "Unknown FormatArgumentValue type {} ({})",
                type, u8(type)));
        }
    }
};

struct FormatArgument {
    FString key;
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
    u32 always_include_sign;
    u32 use_grouping;
    RoundingMode rounding_mode;
    s32 minimum_integral_digits;
    s32 maximum_integral_digits;
    s32 minimum_fractional_digits;
    s32 maximum_fractional_digits;
};

struct FTextHistory {
    TextHistoryType type;
    match (type) {
        (TextHistoryType::None): {
            if (cultureInvariantStability) {
                u32 hasCultureInvariantString;
                if (hasCultureInvariantString) {
                    FString cultureInvariantString;
                }
            } else {
                FString cultureInvariantString;
            }
        }
        (TextHistoryType::Base): {
            FString nameSpace;
            FString key;
            FString sourceString;
        }
        // (TextHistoryType::NamedFormat): {}
        // (TextHistoryType::OrderedFormat): {}
        (TextHistoryType::ArgumentFormat): {
            FText sourceFormat;
            u32 argumentCount;
            FormatArgument arguments[argumentCount];
        }
        (TextHistoryType::AsNumber): {
            FormatArgumentValue sourceValue;
            u32 hasFormatOptions;
            if (hasFormatOptions) {
                NumberFormattingOptions formatOptions;
            }
            FString targetCulture;
        }
        // (TextHistoryType::AsPercent): {}
        // (TextHistoryType::AsCurrency): {}
        // (TextHistoryType::AsDate): {}
        // (TextHistoryType::AsTime): {}
        // (TextHistoryType::AsDateTime): {}
        // (TextHistoryType::Transform): {}
        (TextHistoryType::StringTableEntry): {
            FString tableId;
            FString key;
        }
        // (TextHistoryType::TextGenerator): {}
        // (TextHistoryType::RawText): {}
        (_): {
            std::error(std::format(
                "Unsupported TextHistory type {} ({})",
                type, u8(type)));
        }
    }
};

struct FText {
    u32 flags;
    FTextHistory history [[inline]];
} [[single_color, format("format_ftext")]];

fn format_ftext(FText text) {
    match (text.history.type) {
        (TextHistoryType::None): {
            if (cultureInvariantStability) {
                if (text.history.hasCultureInvariantString) {
                    return text.history.cultureInvariantString;
                }
                return "";
            } else {
                return text.history.cultureInvariantString;
            }
        }
        (TextHistoryType::Base): return text.history.sourceString;
    }
    return text;
};

struct Rotator {
    if (largeWorldCoordinates) {
        double pitch, yaw, roll;
    } else {
        float pitch, yaw, roll;
    }
};

struct Vector {
    if (largeWorldCoordinates) {
        double x, y, z;
    } else {
        float x, y, z;
    }
};

struct Quat {
    if (largeWorldCoordinates) {
        double x, y, z, w;
    } else {
        float x, y, z, w;
    }
};

struct Delegate {
    FString object, functionName;
};

struct MulticastInlineDelegate {
    u32 count [[hidden]];
    Delegate delegates[count];
} [[inline]];

struct MulticastSparseDelegate {
    u32 count [[hidden]];
    Delegate delegates[count];
} [[inline]];

bitfield PropertyTagFlags {
    bool hasArrayIndex              : 1;
    bool hasPropertyGuid            : 1;
    bool hasPropertyExtensions      : 1;
    bool hasBinaryOrNativeSerialize : 1;
    bool boolTrue                   : 1;
};

struct TypeTreeNode {
    FString name;
    u32 children;
    if (children > 0) TypeTreeNode child[children];
} [[format("format_typetreenode")]];

fn format_typetreenode(TypeTreeNode node) {
    if (node.children == 0) return node.name.data;
    str a = std::format("{}<{}", node.name.data, node.child[0]);
    for (auto i = 1, i < node.children, i += 1) {
        a = std::format("{}, {}", a, node.child[i]);
    }
    return std::format("{}>", a);
};

using Properties;
struct StructPropertyValue<auto type, auto size> {
    try {
        match (type) {
            ("DateTime"): u64 value;
            ("Guid"): u128 value;
            ("Rotator"): Rotator value;
            ("Vector"): Vector value;
            ("Quat"): Quat value;
            (_): Properties value;
        }
    } catch {
        std::warning(std::format(
            "StructPropertyValue parsing failed for {}",
            type));
        // Wrap the unknown data
        std::mem::Bytes<size> value;
    }
} [[inline]];

struct FPropertyTag {
    const auto dollar = $;
    if (propertyTagCompleteTypeName) {
        PropertyTagFlags flags;
    }
    FString name;
    if (name.length == 0 || name.data == "None") {
        break;
    }
    const str prefix = std::format(
        "FPropertyTag {} @ 0x{:X};",
        name.data, dollar);
    // Debug logging
    if (propertyTagCompleteTypeName) {
        TypeTreeNode type;
        u32 size;
        if (flags.hasArrayIndex) {
            u32 arrayIndex;
        }
        if (flags.hasPropertyGuid) {
            u128 guid;
        }
        if (flags.hasPropertyExtensions) {
            std::error(std::format(
                "{} hasPropertyExtensions not supported", prefix));
        }
    } else {
        FString type;
        u32 size;
        u32 arrayIndex;
        match (type.data) {
            ("ArrayProperty"): FString propertyType;
            ("BoolProperty"): bool value;
            ("ByteProperty"): FString enumName;
            ("EnumProperty"): FString enumType;
            ("MapProperty"): {
                FString keyType;
                FString valueType;
            }
            ("SetProperty"): FString propertyType;
            ("StructProperty"): {
                FString typeName;
                u128 guid;
            }
        }
        type::Magic<"\x00"> terminator;
    }

    u32 start = $;
    match (propertyTagCompleteTypeName ? type.name.data : type.data) {
        ("ArrayProperty"): {
            u32 count;
            match (propertyTagCompleteTypeName ? type.child[0].name.data : propertyType.data) {
                ("BoolProperty"): bool values[count];
                ("ByteProperty"): {
                    if (count + 4 == size) {
                       std::mem::Bytes<count> values;
                    } else {
                        FString values[count];
                    }
                }
                ("DoubleProperty"): double values[count];
                ("EnumProperty" | "StrProperty" | "NameProperty" | "ObjectProperty"): FString values[count];
                ("FloatProperty"): float values[count];
                ("IntProperty"): s32 values[count];
                ("StructProperty"): {
                    if (!propertyTagCompleteTypeName) {
                        FString fieldName;
                        type::Magic<"\x0F\x00\x00\x00StructProperty\x00"> propertyType;
                        u32 propertySize, arrayIndex;
                        FString structName;
                        u128 guid;
                        type::Magic<"\x00"> terminator;
                        u32 propertyStart = $;
                    }
                    try {
                        match (propertyTagCompleteTypeName ? type.child[0].child[0].name.data : structName.data) {
                            ("Guid"): u128 values[count];
                            ("Rotator"): Rotator values[count];
                            ("Vector"): Vector values[count];
                            ("Quat"): Quat values[count];
                            (_): Properties values[count];
                        }
                    } catch {
                        std::warning(std::format(
                            "{} Failed to parse array of structs size {} in {}",
                            prefix, size,
                            propertyTagCompleteTypeName ? type.child[0].child[0] : structName));
                        // Wrap the unknown data
                        std::mem::Bytes<size-4> values;
                    }
                    if (!propertyTagCompleteTypeName) {
                        s32 propertyBytesRemaining = propertySize + propertyStart - $;
                        if (propertyBytesRemaining != 0) {
                            std::print(std::format(
                                "Struct parsing failed for {}. Bytes remaining: {}",
                                structName,
                                propertyBytesRemaining));
                            std::mem::Bytes<propertyBytesRemaining> warning;
                        }
                    }
                }
                ("TextProperty"): FText values[count];
                (_): {
                    std::warning(std::format(
                        "Unknown array element type {} in {}",
                        propertyType, name));
                    // Wrap the unknown data
                    std::mem::Bytes<size-4> values;
                }
            }
        }
        ("BoolProperty"): {
            if (propertyTagCompleteTypeName) {
                const bool value = flags.boolTrue;
            }
        }
        ("ByteProperty"): {
            match (size) {
                (0|1): u8 value;
                (_): FString value;
            }
        }
        ("DoubleProperty"): double value;
        ("FloatProperty"): float value;
        ("IntProperty"): s32 value;
        ("Int8Property"): s8 value;
        ("Int16Property"): s16 value;
        ("Int64Property"): s64 value;
        ("UInt16Property"): u16 value;
        ("UInt32Property"): u32 value;
        ("UInt64Property"): u64 value;
        ("DelegateProperty"): Delegate value;
        ("MulticastInlineDelegateProperty"): MulticastInlineDelegate value;
        ("MulticastSparseDelegateProperty"): MulticastSparseDelegate value;
        ("NameProperty"): std::mem::Bytes<size> value;
        ("SoftObjectProperty"): std::mem::Bytes<size> value;
        ("EnumProperty" | "StrProperty" | "ObjectProperty"): FString value;
        ("MapProperty" | "SetProperty"): std::mem::Bytes<size> value;
        ("StructProperty"): StructPropertyValue<propertyTagCompleteTypeName ? type.child[0].name.data : typeName.data, size> value;
        ("TextProperty"): {
            try {
                FText value;
            } catch {
                std::warning(std::format(
                    "FText {} @ 0x{:04X}; Failed to parse",
                    name.data, $));
                // Wrap the unknown data
                std::mem::Bytes<size> value;
            }
        }
        (_): {
            std::warning(std::format(
                "Unknown property type {} in {}",
                type, name));
            // Wrap the unknown data
            std::mem::Bytes<size> value;
        }
    }

    s32 bytesRemaining = size + start - $;
    if (bytesRemaining != 0) {
        std::warning(std::format(
            "Property length mismatch while parsing {}. Bytes {}: {}",
            name,
            bytesRemaining < 0 ? "overrun" : "remaining",
            std::math::abs(bytesRemaining)));
        // Adjust the file offset
        $ += bytesRemaining;
    }
} [[name(name.length == 0 ? "null" : name.data), format("format_fpropertytag")]];

fn format_fpropertytag(FPropertyTag property) {
    if (property.name.data == "None") {
        return "";
    }
    match (propertyTagCompleteTypeName ? property.type.name.data : property.type.data) {
        ("ArrayProperty"): return property.values;
    }
    return property.value;
};

struct Properties {
    FPropertyTag values[while(true)] [[inline]];
};

Properties properties @ $;
type::Magic<"\x00\x00\x00\x00"> footer @ $;

std::assert_warn(std::mem::eof(), std::format("Expected EOF @ 0x{:04X}", $));