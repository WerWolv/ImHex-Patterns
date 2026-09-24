#pragma loop_limit 20000
#pragma array_limit 131072
#pragma allow_edits

import std.string;
import std.mem;
import std.io;
import std.core;

// Helper structures
struct UE5_GUID {
    u8 guid[16];
} [[format("format_ue_guid")]];

fn format_ue_guid(UE5_GUID ID) {
    return std::format(
            "{:02X}{:02X}{:02X}{:02X}-{:02X}{:02X}-{:02X}{:02X}-{:02X}{:02X}-{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}",
            ID.guid[3], ID.guid[2], ID.guid[1], ID.guid[0],
            ID.guid[7], ID.guid[6],
            ID.guid[5], ID.guid[4],
            ID.guid[11], ID.guid[10],
            ID.guid[9], ID.guid[8], ID.guid[15], ID.guid[14], ID.guid[13], ID.guid[12]
    );
};

struct UE5_CustomVersion {
    UE5_GUID GUID;
    s32 Version;
};

struct FString {
    s32 StrLen;
    if(StrLen < 0 && StrLen > -2147483648)
    {
        //This is a unicode character UTF-16 a 16 bit 2 byte character.
        u16 String[(-StrLen) - 1];
        padding[2];
    }
    else if(StrLen > 0) {
        char String[while($[$] != 0x00)];
        padding[1];
    }
    else if(StrLen >= 0)
        char String[StrLen];
} [[format("GetDisplayString")]];

fn GetDisplayString(FString Str) {
    return std::format(Str.String);
};

struct Generation
{
    s32 ExportCount;
    s32 NameCount;
};

enum EPackageFlags : u32
{
    ///<summary>No flags</summary>
    PKG_None = 0x00000000,
    ///<summary>Newly created package, not saved yet. In editor only.</summary>
    PKG_NewlyCreated = 0x00000001,
    ///<summary>Purely optional for clients.</summary>
    PKG_ClientOptional = 0x00000002,
    ///<summary>Only needed on the server side.</summary>
    PKG_ServerSideOnly = 0x00000004,
    ///<summary>This package is from "compiled in" classes.</summary>
    PKG_CompiledIn = 0x00000010,
    ///<summary>This package was loaded just for the purposes of diffing</summary>
    PKG_ForDiffing = 0x00000020,
    ///<summary>This is editor-only package (for example: editor module script package)</summary>
    PKG_EditorOnly = 0x00000040,
    ///<summary>Developer module</summary>
    PKG_Developer = 0x00000080,
    ///<summary>Loaded only in uncooked builds (i.e. runtime in editor)</summary>
    PKG_UncookedOnly = 0x00000100,
    ///<summary>Package is cooked</summary>
    PKG_Cooked = 0x00000200,
    ///<summary>Package doesn't contain any asset object (although asset tags can be present)</summary>
    PKG_ContainsNoAsset = 0x00000400,
    ///<summary>Uses unversioned property serialization instead of versioned tagged property serialization</summary>
    PKG_UnversionedProperties = 0x00002000,
    ///<summary>Contains map data (UObjects only referenced by a single ULevel) but is stored in a different package</summary>
    PKG_ContainsMapData = 0x00004000,
    ///<summary>package is currently being compiled</summary>
    PKG_Compiling = 0x00010000,
    ///<summary>Set if the package contains a ULevel/ UWorld object</summary>
    PKG_ContainsMap = 0x00020000,
    ///<summary>???</summary>
    PKG_RequiresLocalizationGather = 0x00040000,
    ///<summary>Set if the package was created for the purpose of PIE</summary>
    PKG_PlayInEditor = 0x00100000,
    ///<summary>Package is allowed to contain UClass objects</summary>
    PKG_ContainsScript = 0x00200000,
    ///<summary>Editor should not export asset in this package</summary>
    PKG_DisallowExport = 0x00400000,
    ///<summary>This package should resolve dynamic imports from its export at runtime.</summary>
    PKG_DynamicImports = 0x10000000,
    ///<summary>This package contains elements that are runtime generated, and may not follow standard loading order rules</summary>
    PKG_RuntimeGenerated = 0x20000000,
    ///<summary>This package is reloading in the cooker, try to avoid getting data we will never need. We won't save this package.</summary>
    PKG_ReloadingForCooker = 0x40000000,
    ///<summary>Package has editor-only data filtered out</summary>
    PKG_FilterEditorOnly = 0x80000000
};

struct FEngineVersion {
    u16 Major;
    u16 Minor;
    u16 Patch;
    u32 Changelist;
    FString Branch;
};

struct UE5_Header {
    u32 EPackageFileTag;

    s32 LegacyFileVersion;
    s32 LegacyUE3Version;
    s32 FileVersionUE4;

    if (LegacyFileVersion <= -8) {
        s32 FileVersionUE5;
    }
    else {
        s32 FileVersionUE5 = 0;
    }

    s32 FileVersionLicenseeUE4;

    s32 CustomVersionCount;
    UE5_CustomVersion CustomVersions[CustomVersionCount];

    s32 TotalHeaderSize;

    FString FolderName;

    u32 PackageFlags;

    s32 NameCount;
    s32 NameOffset;

    if (FileVersionUE5 >= 0x0151) { // VER_UE5_ADD_SOFTOBJECTPATH_LIST
        u32 SoftObjectPathsCount;
        u32 SoftObjectPathsOffset;
    }
    else {
        u32 SoftObjectPathsCount = 0;
        u32 SoftObjectPathsOffset = 0;
    }

    if ((PackageFlags & EPackageFlags::PKG_FilterEditorOnly) == 0)
    FString LocalizationId;

    s32 GatherableTextDataCount;
    s32 GatherableTextDataOffset;

    s32 ExportCount;
    s32 ExportOffset;
    s32 ImportCount;
    s32 ImportOffset;
    s32 DependsOffset;

    if (FileVersionUE4 >= 0x0154) { // VER_UE4_ADD_STRING_ASSET_REFERENCES_MAP
        u32 SoftPackageReferencesCount;
        u32 SoftPackageReferencesOffset;
    }
    else {
        u32 SoftPackageReferencesCount = 0;
        u32 SoftPackageReferencesOffset = 0;
    }

    if (FileVersionUE4 >= 0x0163) { // VER_UE4_ADDED_SEARCHABLE_NAMES
        s32 SearchableNamesOffset;
    }
    else {
        s32 SearchableNamesOffset = 0;
    }

    s32 ThumbnailTableOffset;

    UE5_GUID PackageGuid;

    if (FileVersionUE4 >= 0x0166) { // VER_UE4_ADDED_PACKAGE_OWNER
        UE5_GUID PersistentGuid;
    }
    else {
        PersistentGuid = 0;; // Default empty GUID
    }

    if (FileVersionUE4 >= 0x0166 && FileVersionUE4 < 0x0183) { // VER_UE4_NON_OUTER_PACKAGE_IMPORT
        UE5_GUID OwnerPersistentGuid;
    }
    else {
        s32 OwnerPersistentGuid = 0;; // Default empty GUID
    }

    s32 GenerationsCount;
    if (GenerationsCount < 0 || GenerationsCount > 0x1e5) // failsafe for some specific games
    {
        $ = $ - 20;
        u8 GarbageData[8];
        UE5_GUID SecondPackageGuid [[hidden]];
        PackageGuid = SecondPackageGuid;
        s32 SecondGenerationsCount;
        GenerationsCount = SecondGenerationsCount;
    }
    Generation Generations[GenerationsCount];

    if (FileVersionUE4 >= 0x0171) { // VER_UE4_ENGINE_VERSION_OBJECT
        FEngineVersion SavedByEngineVersion;
    }
    else {
        FString SavedByEngineVersion = 0;
        s32 EngineChangelist;
    }

    if (FileVersionUE4 >= 0x0175) { // VER_UE4_PACKAGE_SUMMARY_HAS_COMPATIBLE_ENGINE_VERSION
        FEngineVersion CompatibleWithEngineVersion;
    }
    else {
        FString CompatibleWithEngineVersion = SavedByEngineVersion;
    }

    u32 CompressionFlags;

    s32 CompressedChunksCount;

    u32 PackageSource;
    u32 AdditionalPackagesToCookCount;

    if (LegacyFileVersion > -7) {
        s32 NumTextureAllocations;
    }
    else {
        s32 NumTextureAllocations = 0;
    }

    s32 AssetRegistryDataOffset;
    s64 BulkDataStartOffset;

    if (FileVersionUE4 >= 0x0183) { // VER_UE4_WORLD_LEVEL_INFO
        s32 WorldTileInfoDataOffset;
    }
    else {
        s32 WorldTileInfoDataOffset = 0;
    }

    if (FileVersionUE4 >= 0x0191) { // VER_UE4_CHANGED_CHUNKID_TO_BE_AN_ARRAY_OF_CHUNKIDS
        s32 ChunkIDsCount;
        s32 ChunkIDs[ChunkIDsCount];
    }
    else if (FileVersionUE4 >= 0x0192) { // VER_UE4_ADDED_CHUNKID_TO_ASSETDATA_AND_UPACKAGE
        s32 ChunkID;
    }
    else {
        s32 ChunkID = 0;
    }

    if (FileVersionUE4 >= 0x0194) { // VER_UE4_PRELOAD_DEPENDENCIES_IN_COOKED_EXPORTS
        s32 PreloadDependencyCount;
        s32 PreloadDependencyOffset;
    }
    else {
        s32 PreloadDependencyCount = -1;
        s32 PreloadDependencyOffset = 0;
    }

    if (FileVersionUE5 >= 0x0196) { // VER_UE5_NAMES_REFERENCED_FROM_EXPORT_DATA
        s32 NamesReferencedFromExportDataCount;
    }
    else {
        s32 NamesReferencedFromExportDataCount = 0;
    }

    if (FileVersionUE5 >= 0x0197) { // VER_UE5_PAYLOAD_TOC
        s64 PayloadTocOffset;
    }
    else {
        s64 PayloadTocOffset = -1;
    }

    if (FileVersionUE5 >= 0x0198) { // VER_UE5_DATA_RESOURCES
        s32 DataResourceOffset;
    }
    else {
        s32 DataResourceOffset = 0;
    }
};

struct DataName {
    FString Name;
    u16 NonCasePreservingHash;
    u16 CasePreservingHash;
} [[format("GetDataDisplayValue")]];

fn GetDataDisplayValue(DataName dName) {
    return std::format(dName.Name.String);
};

struct SourceSiteContext {
    FString KeyName;
    FString SiteDesc;
    u32 IsEditorOnly;
    u32 IsOptional;
    s32 InfoMetaDataValueCount;
    if(MetaDataValue > 0)
    {
        //throw error unsupported.
    }
    s32 KeyMetaDataValueCount;
    if (KeyMetaDataValueCount > 0)
    {
        //Another unsupported feature
    }
};

struct GatherableTextData {
    FString Namespace;
    FString Source;
    s32 MetaDataValue;
    if (MetaDataValue > 0)
    {
        // Throw Error
    }
    s32 SourceSitesCount;
    SourceSiteContext SourceSites[SourceSitesCount];
};

bitfield I64Export {
        b0 :1;
        b1 :1;
        b2 :1;
        b3 :1;
        b4 :1;
        b5 :1;
        b6 :1;
        b7 :1;
};

struct Int64Export {
    if ($ + 8 < std::mem::size()) {
        u8 Buffer[8];
        s64 BuiltValue = (s64(Buffer[0]) | (s64(Buffer[1]) << 8) | (s64(Buffer[2]) << 16) | (s64(Buffer[3]) << 24) |
                          (s64(Buffer[4]) << 32) | (s64(Buffer[5]) << 40) | (s64(Buffer[6]) << 48) | (s64(Buffer[7]) << 56));
    }
    else {
        s64 BuiltValue = 0;
    }
} [[format("GetInt64ExportValue")]];

fn GetInt64ExportValue(Int64Export i64e) {
    return std::format(i64e.BuiltValue);
};

fn lowerBytes(u64 value) {
    return u32(value & 0xFFFFFFFF);
};

fn higherBytes(u64 value) {
    return u32((value >> 32) & 0xFFFFFFFF);
};

fn pullIndividualBytes(u64 value, u8 segment) {
    
    if (segement == 0){
    return u8(value & 0xFFFFFFFF);
    }
    else if (segement == 1){
    return u8(value >> 8 & value << 16 & 0xFFFFFFFF);
    }
    else if (segement == 2){
    return u8(value >> 16 & value << 24 & 0xFFFFFFFF);
    }
    else if (segement == 3){
    return u8(value >> 24 & value << 32 &  0xFFFFFFFF);
    }
    else if (segement == 4){
    return u8(value >> 32 & value << 40 & 0xFFFFFFFF);
    }
    else if (segement == 5){ 
    return u8(value >> 40 & value << 48 & 0xFFFFFFFF);
    }
    else if (segement == 6){
    return u8(value >> 48 & value << 54 & 0xFFFFFFFF);
    }
    else if (segement == 7){ 
    return u8(value >> 56 & 0xFFFFFFFF); 
    }  
       
};

fn pullIndividualBytes32(u32 value, u8 segment) {
    
    if (segement == 0){
    return u8(value & 0xFFFFFFFF);
    }
    else if (segement == 1){
    return u8(value >> 8 & value << 16 & 0xFFFFFFFF);
    }
    else if (segement == 2){
    return u8(value >> 16 & value << 24 & 0xFFFFFFFF);
    }
    else if (segement == 3){
    return u8(value >> 24 &  0xFFFFFFFF);
    }
       
};

enum PropName : u8 {
    Entity,
    EntityGuid,
    GeneratedProperty,
    ParentClass,
    BlueprintSystemVersion,
    UbergraphPages,
    UbergraphPage
};
enum PropType : u8 {
    Int,
    Guid,
    FString,
    Long
};

struct MetaProperty {
    u64 ArrayIndex = std::core::array_index() [[hidden]];
    s32 Reserved;
    match(ArrayIndex) {
            (0): {
                PropName Property = PropName::Entity;
                PropType PropertyType = PropType::Int;
                s32 IntValue;
            }
            (1): {
                PropName Property = PropName::EntityGuid;
                PropType PropertyType = PropType::Guid;
                UE5_GUID Guid;
            }
            (2): {
                PropName Property = PropName::Entity;
                PropType PropertyType = PropType::Int;
                s32 IntValue;
            }
            (3): {
                PropName Property = PropName::EntityGuid;
                PropType PropertyType = PropType::Guid;
                UE5_GUID Guid;
            }
    }
};


struct ExportPropertyBase<T, auto HasSubType> {
    s64 ObjectTypeId [[hidden]];
    DataName ObjectType @ addressof(parent.parent.parent.parent.TextNames[ObjectTypeId]);
    s64 Size;
    if(HasSubType) {
        u64 ObjectSubTypeId [[hidden]];
        DataName ObjectSubType @ addressof(parent.parent.parent.parent.TextNames[ObjectSubTypeId]);
    }
    u8 Flag;
    T PropertyDetail;
};

struct ExportBlueprintSysVersion {
    if (parent.ObjectType == "IntProperty") {
        PropName Property = PropName::BlueprintSystemVersion;
        PropType PropertyType = PropType::Int;
        s32 Value;
    }
};

struct ExportGeneratedClass {
    if (parent.ObjectType == "ObjectProperty") {
        PropName Property = PropName::GeneratedClass;
        PropType PropertyType = PropType::Int;
        s32 Value;
    }
};

struct ExportParentClass {
    if (parent.ObjectType == "ObjectProperty") {
        PropName Property = PropName::ParentClass;
        PropType PropertyType = PropType::Int;
        s32 Value;
    }
};

struct ExportAdvancedPinDisplay {

    if (parent.ObjectType == "ByteProperty") {
       
        PropName PropertyName = PropName::AdvancedPinDisplayName;
        PropType PropertyType = PropType::String;
        u64 Size;
        u8 Flag;
    }
};




struct ExportCategoryName {    

    if (parent.ObjectType == "TextProperty") {
        PropName PropertyName = PropName::CategoryName;
        PropType PropertyType = PropType::String;
        u64 Value;
        u8 Flag;
    }
};

struct ExportCategory {
    
    u32 CategoryInt32; //unknowns so ileft em
    u8 CategoryByte; 
    
    if (Parent.ObjectType == "TextProperty") {
    
         PropName PropertyName = PropName::CategoryName;
         PropType PropertyType = PropType::String;
         u64 Size;
         u8 Flag;
        
    }
};

struct ExportSchema {
    s64 Schema64;
    u8  SchemaByte;
    s32 Schema32;
};

struct ExportUbergraphPage {
    PropName Property = PropName::UbergraphPage;
    PropType PropertyType = PropType::Int;
    s32 ArrayIndex = std::core::array_index();
    s32 Value;
    s32 Reserved;
};

struct ExportCategorySorting {

    if (parent.ObjectType == "ArrayProperty") {
        u64 size;
        u8 flag ;
        PropName PropertyName = PropName::CategorySortingName;
        PropType PropertyType = PropType::String;
    }
};

struct ExportPropertyGuids {
    u64 size;
    u8 flag;
    u32 FirstGuid = lowerBytes(size);
    u32 SecondGuid = higherBytes(size);
    
    PropName PropertyName = PropName::PropertyGuidsName;
    PropType PropertyType = PropType::String;
   
};

struct ExportbLegacyNeedToPurgeSkelRefs {
    
    u64 size;
    u8 flag;
    if (parent.ObjectType == "BoolProperty") {
        
        PropName PropertyName = PropName::ExportbLegacyNeedToPurgeSkelRefName;
        PropType PropertyType = PropType::Bool;
    }

};

struct ExportbConsumeInput {

   u64 size;
    u8 flag;
    if (parent.ObjectType == "BoolProperty") {
        
        PropName PropertyName = PropName::bConsumeInputName;
        PropType PropertyType = PropType::Bool;
    }


};

struct ExportbOverrideParentBinding {

   u64 size;
    u8 flag;
    if (parent.ObjectType == "BoolProperty") {
        
        PropName PropertyName = PropName::bOverrideParentName;
        PropType PropertyType = PropType::Bool;
    }

};

struct ExportbShift {

    u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bShiftName;
        PropType PropertyType = PropType::Bool;
        
     }        
};

struct ExportbExecuteWhenPaused {

    u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bExecuteWhenPaused;
        PropType PropertyType = PropType::Bool;
        
     }        
};

struct ExportMetaDataArray {

    u64 size;
    u8 flag;

    if (parent.ObjectType == "ArrayProperty") {
    
        PropName PropertyName = PropName::MetaDataArray;
        PropType PropertyType = PropType::String;
        //property.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size);

    }

};

struct ExportFunctionNameToBind {

    u64 size;
    u8 flag;
    
    if (parent.ObjectType == "NameProperty") {
        PropName PropertyName = PropName::FunctionNameToBind;
        PropType PropertyType = PropType::String;
    }

};

struct ExportInputKeyEvent {

    u64 size;
    u8 flag;
     
    if (parent.ObjectType == "ByteProperty") {
    
        PropName PropertyName = PropName::InputKeyEvent;
        PropType PropertyType = PropType::String;
    }

};

struct ExportbCmd {

   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bCmd;
        PropType PropertyType = PropType::Bool;
        
     }      

};

struct ExportbCtrl {

   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bCtrl;
        PropType PropertyType = PropType::Bool;
        
     }      

};

struct ExportbAlt{

   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bAlt;
        PropType PropertyType = PropType::Bool;
        
     }      

};

struct ExportLastEditedDocuments {

    u64 size;
    u8 flag;
    if (parent.ObjectType == "ArrayProperty") {
    
       PropName PropertyName = PropName::LastEditedDocuments;
       PropType PropertyType = PropType::String;
       // property.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size);
    }
};

struct ExportVarType {

    u64 size;
    u8 flag;
    
    PropName PropertyName = PropName::ExportVarType;
    PropType PropertyType = PropType::String;
    
    u32 FirstVarType = lowerBytes(size);
    u32 SecondVarType = higherBytes(size);
    
    u8 FirstVarTypeByte = pullIndividualBytes(size, 0);
    u8 SecondVarTypeByte = pullIndividualBytes(size, 1);
    u8 ThirdVarTypeByte = pullIndividualBytes(size, 2);
    u8 FourthVarTypeByte = pullIndividualBytes(size, 3);
    u8 FifthVarTypeByte = pullIndividualBytes(size, 4);
    u8 SixthVarTypeByte = pullIndividualBytes(size, 5);
    u8 SeventhVarTypeByte = pullIndividualBytes(size, 6);
    u8 EigthVarTypeByte = pullIndividualBytes(size, 7);


};

struct ExportDefaultValue {

 u64 size;
 u8 flag;
    if (parent.ObjectType == "StrProperty") {
    
       PropName PropertyName = PropName::DefaultValue;
       PropType PropertyType = PropType::String;
    }

};

struct ExportVarName {
u64 size;
 u8 flag;
    if (parent.ObjectType == "NameProperty") {
    
       PropName PropertyName = PropName::VarName;
       PropType PropertyType = PropType::String;
    }

};

struct ExportPropertyFlags {

    u64 size;
    u8 flag;
    if (parent.ObjectType == "UInt64Property") {
       PropName PropertyName = PropName::PropertyFlags;
       PropType PropertyType = PropType::Int;
       // property.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size);

    }
};

struct ExportFriendlyName {
 u64 size;
 u8 flag;
    if (parent.ObjectType == "StrProperty") {
    
       PropName PropertyName = PropName::FriendlyName;
       PropType PropertyType = PropType::String;
    }

};

struct ExportRepNotifyFunc {
u64 size;
 u8 flag;
    if (parent.ObjectType == "NameProperty") {
    
       PropName PropertyName = PropName::RepNotifyFunc;
       PropType PropertyType = PropType::String;
       }
};

struct ExportReplicationCondition {
u64 size;
 u8 flag;
    if (parent.ObjectType == "ByteProperty") {
    
       PropName PropertyName = PropName::ReplicationCondition;
       PropType PropertyType = PropType::String;
       }
};

struct ExportNewVariables {

     // read size
   // std::string subType = resolveFName(readInt64()); // read subtype
     
    if (parent.ObjectType == "ArrayProperty") {
       // if (subType == "StructProperty") {
            u64 size;
            u8 flag;
            u32 value;
       // }
    }
    else if (parent.ObjectType == "StructProperty") {
      //  if (subType == "BPVariableDescription") {
          u64 size;
          u8 flag;
      //  }
    }

};

struct ExportDynamicBindingObjects {

    u64 size;
    PropName PropertyName = PropName::DynamicBindingObjects;
    PropType PropertyType = PropType::String;
    u32 FirstBinding = lowerBytes(size);
    u32 SecondBinding = higherBytes(size);

};

struct ExportUberGraphFrame {
    u64 size;
    //std::string subType = resolveFName(readInt64()); // read subtype
   // std::string subType1 = resolveFName(readInt64()); // read subtype1
    u8 flag;
    u64 value;
    
    if (exportData.metadata.ObjectType == "StructProperty") {
     //   if (subType == "PointerToUberGraphFrame") {
            PropName PropertyName = PropName::UberGraphFrame;
            PropType PropertyType = PropType::Int;
       //}
    }
};

struct ExportKeyName {

       u64 size;
       u8 flag;    
       PropName PropertyName = PropName::KeyName;
       PropType PropertyType = PropType::String;

};

struct ExportbCommentBubbleVisible_InDetailsPanel {

    u8 flag;
    u8 value;

    PropName PropertyName = PropName::bCommentBubbleVisible_InDetailsPanel-Value;
    PropType PropertyType = PropType::Bool;

};

struct ExportbCommentBubbleVisible {
u64 size;
u8 byte;
u8 byte2;


};

struct ExportbCommentBubblePinned {
   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bCommentBubblePinned;
        PropType PropertyType = PropType::Bool;
        
     }  

};

struct ExportbHiddenEdTemporary {
u64 size;
u8 byte;
u8 byte2;

};

struct ExportbIsEditable {
   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bIsEditable;
        PropType PropertyType = PropType::Bool;
        
     }  

};

struct ExportbSelfContext {
   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bSelfContext;
        PropType PropertyType = PropType::Bool;
        
     }  

};

struct ExportNone {

};

struct ExportInputChord {
    
    u64 size;
  //  std::string subType = resolveFName(readInt64()); // read subType

   // if (subType == "InputChord") {
        u64 val;
        u64 val1;
        u8 flag;
        PropName PropertyName = PropName::UberGraphFrame;
        PropType PropertyType = PropType::Int;
  //  }

};

struct ExportKey {
    u64 size;
 //   std::string subType = resolveFName(readInt64()); // read subType

   // if (subType == "Key") {
        u64 val = readInt64();
        u64 val1 = readInt64();
        u8 flag = readByte();
        PropName PropertyName = PropName::Key;
        PropType PropertyType = PropType::Int;
 
  //  }

};

struct ExportInputKeyDelegateBindings {

    u64 size; // read size
    //std::String subType = resolveFName(readInt64()); // read subType

    if (parent.ObjectType == "StructProperty") {
        u8 flag;
        u32 val;
        PropName PropertyName = PropName::InputKeyDelegateBindings;
        PropType PropertyType = PropType::Int;
    } 
    else if (parent.ObjectType == "BlueprintInputKeyDelegateBinding") {

        u64 val;
        u64 val1;
        u8 flag;
        PropName PropertyName = PropName::InputKeyDelegateBindingsValue;
        PropType PropertyType = PropType::Int;
    }
};

struct ExportDelegateReference {
    u64 size;
    u8 flag;

    if (parent.ObjectType == "StructProperty") {

        PropName PropertyName = PropName::DelegateReference;
        PropType PropertyType = PropType::String;
        
     }  

};

struct ExportFunctionReference {
    u64 size;
    u8 flag;
    if (parent.ObjectType == "StructProperty") {
        PropName PropertyName = PropName::FunctionReference;
        PropType PropertyType = PropType::String;        
     } 

};

struct ExportbIsPureFunc {
u64 size;
u8 byte;
u8 byte2;

};

struct ExportbIsConstFunc {
   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bIsConstFunc;
        PropType PropertyType = PropType::Bool;
        
     }  

};

struct ExportbOverrideFunction {
   u64 size;
    u8 flag;

    if (parent.ObjectType == "BoolProperty") {

        PropName PropertyName = PropName::bOverrideFunction;
        PropType PropertyType = PropType::Bool;
        
     } 

};

struct ExportNodePosX {

    u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodePosX;
    PropType PropertyType = PropType::Int;
    s32 value;

};

struct ExportNodePosY {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodePosY;
    PropType PropertyType = PropType::Int;
    s32 value;
};

struct ExportNodeWidth {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodeWidth;
    PropType PropertyType = PropType::Int;
    s32 value;

};

struct ExportNodeHeight {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodeHeight;
    PropType PropertyType = PropType::Int;
    s32 value;

};

struct ExportNodeComment {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodeComment;
    PropType PropertyType = PropType::String;


};

struct ExportCustomFunctionName {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::CustomFunctionName;
    PropType PropertyType = PropType::String;

};

struct ExportEventReference {
    u64 ref1;
    u64 ref2;
    u64 ref3;
    u64 ref4;
    u8 byte;
   
    

};

struct ExportExtraFlags {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::ExtraFlags;
    PropType PropertyType = PropType::Int;
    u32 val;

};

struct ExportCustomClass {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::CustomClass ;
    PropType PropertyType = PropType::Int;
    u32 val;
};

struct ExportInputKey {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::InputKey;
    PropType PropertyType = PropType::Fstring;
    u64 key;
    u64 key2;
};

struct ExportVariableReference {
    u64 ref1;
    u64 ref2;
    u64 ref3;
    u64 ref4;
    u8 byte;

};

struct ExportbVisualizeComponent {
    u64 size;
    PropName PropertyName = PropName::bVisualizeComponent;

};

struct ExportComponentClass {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::ComponentClass;
    PropType PropertyType = PropType::Int;
    u32 val;

};

struct ExportComponentTemplate {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::ComponentTemplate;
    PropType PropertyType = PropType::Int;
    u32 val;

};

struct ExportRootNodes {
    u64 size;
    u8 flag;
    u32 value;

    if (parent.ObjectType == "ArrayProperty") {

            PropName PropertyName = PropName::RootNodes;
            PropType PropertyType = PropType::Int;
            u32 Node1 = higherBytes(size);
            u32 Node2 = lowerBytes(size);
            }
                          
};

struct ExportAllNodes {
    u64 size;
    u8 flag;
    u32 value;

    if (parent.ObjectType == "ArrayProperty") {

            PropName PropertyName = PropName::AllNodes;
            PropType PropertyType = PropType::Int;
            u32 Node1 = higherBytes(size);
            u32 Node2 = lowerBytes(size);
            }
};

struct ExportDefaultSceneRootNode {
   
    u64 size;
    u8 flag;
    u32 value;
    if (exportData.metadata.ObjectType == "ObjectProperty") {
 
     PropName PropertyName = PropName::DefaultSceneRootNode;
     PropType PropertyType = PropType::Int;
    }

};

struct ExportInternalVariableName {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::InternalVariableName;
    PropType PropertyType = PropType::Fstring;

};

struct ExportNodes{
    u64 size;
    u8 flag;
    PropName PropertyName = PropName::Nodes;
    PropType PropertyType = PropType::Int;
    u32 Node1 = higherBytes(size);
    u32 Node2 = lowerBytes(size);            

};

struct ExportGraphGuid {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::ExportGraphGuid;
    PropType PropertyType = PropType::Fstring;


};

struct ExportBlueprintGuid {
 u64 size;
    u8 byte;
    PropName PropertyName = PropName::BlueprintGuid;
    PropType PropertyType = PropType::Fstring;

};

struct ExportVarGuid {
   u64 size;
    u8 byte;
    PropName PropertyName = PropName::ExportVarGuid;
    PropType PropertyType = PropType::Fstring;

};

struct ExportNodeGuid {
   u64 size;
    u8 byte;
    PropName PropertyName = PropName::NodeGuid;
    PropType PropertyType = PropType::Fstring;

};

struct ExportbAllowDeletion {
    u64 size; // read zero
    u8 flag;
    u8 val;
    PropName PropertyName = PropName::bAllowDeletion;
    PropType PropertyType = PropType::Bool;

};

struct ExportMemberReference {
    u64 size;
    u8 byte;
};

struct ExportMemberParent {
    u64 size;
    u8 flag;
    PropName PropertyName = PropName::MemberParent;
    PropType PropertyType = PropType::Int;

};

struct ExportMemberName {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::MemberName;
    PropType PropertyType = PropType::Fstring;

};

struct ExportSimpleConstructionScript {
    u64 size;
    u8 flag;

    if (exportData.metadata.ObjectType == "ObjectProperty") {
        u32 value;
    }
    
    PropName PropertyName = PropName::SimpleConstructionScript;
    PropType PropertyType = PropType::Int;

};

struct ExportUberGraphFunction {
    u64 size;
    u8 flag;
    u32 value;

    if (exportData.metadata.ObjectType == "ObjectProperty") {
        u32 count;    
        PropName PropertyName = PropName::UberGraphFunction;
        PropType PropertyType = PropType::Int;
    }

};

struct ExportFunctionGraphs {
    u64 size; 
    //readInt64();
    u8 byte;
    PropName PropertyName = PropName::FunctionGraphs;
    PropType PropertyType = PropType::Int;
    
    u32 graphPart1 = higherBytes(size);
    u32 graphPart2 = lowerBytes(size);

};

struct ExportVariableGuid {
 u64 size;
    u8 byte;
    PropName PropertyName = PropName::ExportVariableGuid;
    PropType PropertyType = PropType::Fstring;

};

struct ExportMemberGuid {
 u64 size;
    u8 byte;
    PropName PropertyName = PropName::ExportMemberGuid;
    PropType PropertyType = PropType::Fstring;

};

struct ExportEnabledState {
    u64 size;
    u8 flag;
    PropName PropertyName = PropName::EnabledState;
    PropType PropertyType = PropType::Fstring;

};

struct ExportTransformComponent {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::TransformComponent;
    PropType PropertyType = PropType::Int;

};

struct ExportRootComponent {
    u64 size;
    u8 byte;
    PropName PropertyName = PropName::RootComponent;
    PropType PropertyType = PropType::Int;
    u32 value;

};

struct Exportthen {
    u32 value;
    PropName PropertyName = PropName::then;
    PropType PropertyType = PropType::String;
    

    if (value == 8) {
    
    u8 byte1 = pullIndividualBytes32(value, 0);
    u8 byte2 = pullIndividualBytes32(value, 1);
    u8 byte3 = pullIndividualBytes32(value, 2);
    u8 byte4 = pullIndividualBytes32(value, 3);

    }
    else if (val1 == 0) {
        u8 byte;
    }

};

struct ExportDelegate {
    u32 value;
    PropName PropertyName = PropName::Delegate;
    PropType PropertyType = PropType::String;
    

    if (value == 8) {
    
    u8 byte1 = pullIndividualBytes32(value, 0);
    u8 byte2 = pullIndividualBytes32(value, 1);
    u8 byte3 = pullIndividualBytes32(value, 2);
    u8 byte4 = pullIndividualBytes32(value, 3);

    }
    else if (val1 == 0) {
        u8 byte;
    }


};

struct Exportself {
    u32 value;
    PropName PropertyName = PropName::self;
    PropType PropertyType = PropType::String;
    

    if (value == 8) {
    
    u8 byte1 = pullIndividualBytes32(value, 0);
    u8 byte2 = pullIndividualBytes32(value, 1);
    u8 byte3 = pullIndividualBytes32(value, 2);
    u8 byte4 = pullIndividualBytes32(value, 3);

    }
    else if (val1 == 0) {
        u8 byte;
    }


};

struct Exportexec {

   //int size = 82; 32 + 36 = 68
    u64 size;
    PropName PropertyName = PropName::exec;
    PropType PropertyType = PropType::String;
   

   /* if (readInt64() == 1) {
        // read entity and guid
        UassetData::Export::Property property1;
        property1.PropertyName = "object - Entity";
        property1.PropertyType = "int";
        property1.intValue = readInt32();;
        exportData.properties.push_back(property1);
        UassetData::Export::Property property2;
        property2.PropertyName = "object - Entity Guid";
        property2.PropertyType = "FString";
        property2.stringValue = readGuid();;
        exportData.properties.push_back(property2);

        // read 36 bytes
        int size3 = 36;
        UassetData::Export::Property property3;
        property3.PropertyName = "object - 36 bytes unknown";
        property3.PropertyType = "FString";
        property3.stringValue = "bytes";
        property3.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size3);
        exportData.properties.push_back(property3);
        currentIdx += size3;

        // read entity and guid value
        UassetData::Export::Property property4;
        property4.PropertyName = "object - Entity";
        property4.PropertyType = "int";
        property4.intValue = readInt32();;
        exportData.properties.push_back(property4);
        property4.PropertyName = "object - Entity Guid";
        property4.PropertyType = "FString";
        property4.stringValue = readGuid();;
        exportData.properties.push_back(property4);

        // read entity and guid value
        UassetData::Export::Property property5;
        property5.PropertyName = "object - Entity";
        property5.PropertyType = "int";
        property5.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property5.PropertyName = "object - Entity Guid";
        property5.PropertyType = "FString";
        property5.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else if (readInt64() == 0) {
        // read 36 bytes
        int size31 = 32;
        UassetData::Export::Property property31;
        property31.PropertyName = "object - 36 bytes unknown";
        property31.PropertyType = "FString";
        property31.stringValue = "bytes";
        property31.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size31);
        exportData.properties.push_back(property31);
        currentIdx += size31;

        // read entity and guid value
        UassetData::Export::Property property41;
        property41.PropertyName = "object - Entity";
        property41.PropertyType = "int";
        property41.intValue = readInt32();;
        exportData.properties.push_back(property41);
        property41.PropertyName = "object - Entity Guid";
        property41.PropertyType = "FString";
        property41.stringValue = readGuid();;
        exportData.properties.push_back(property41);

        // read entity and guid value
        UassetData::Export::Property property51;
        property51.PropertyName = "object - Entity";
        property51.PropertyType = "int";
        property51.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property51.PropertyName = "object - Entity Guid";
        property51.PropertyType = "FString";
        property51.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else {
        ;
    } */

};

struct Exportdelegate {

   //int size = 82; 64 + 16 + 2?
    u64 size;
    PropName PropertyName = PropName::delegate;
    PropType PropertyType = PropType::String;
   

   /* if (readInt64() == 1) {
        // read entity and guid
        UassetData::Export::Property property1;
        property1.PropertyName = "object - Entity";
        property1.PropertyType = "int";
        property1.intValue = readInt32();;
        exportData.properties.push_back(property1);
        UassetData::Export::Property property2;
        property2.PropertyName = "object - Entity Guid";
        property2.PropertyType = "FString";
        property2.stringValue = readGuid();;
        exportData.properties.push_back(property2);

        // read 36 bytes
        int size3 = 36;
        UassetData::Export::Property property3;
        property3.PropertyName = "object - 36 bytes unknown";
        property3.PropertyType = "FString";
        property3.stringValue = "bytes";
        property3.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size3);
        exportData.properties.push_back(property3);
        currentIdx += size3;

        // read entity and guid value
        UassetData::Export::Property property4;
        property4.PropertyName = "object - Entity";
        property4.PropertyType = "int";
        property4.intValue = readInt32();;
        exportData.properties.push_back(property4);
        property4.PropertyName = "object - Entity Guid";
        property4.PropertyType = "FString";
        property4.stringValue = readGuid();;
        exportData.properties.push_back(property4);

        // read entity and guid value
        UassetData::Export::Property property5;
        property5.PropertyName = "object - Entity";
        property5.PropertyType = "int";
        property5.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property5.PropertyName = "object - Entity Guid";
        property5.PropertyType = "FString";
        property5.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else if (readInt64() == 0) {
        // read 36 bytes
        int size31 = 32;
        UassetData::Export::Property property31;
        property31.PropertyName = "object - 36 bytes unknown";
        property31.PropertyType = "FString";
        property31.stringValue = "bytes";
        property31.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size31);
        exportData.properties.push_back(property31);
        currentIdx += size31;

        // read entity and guid value
        UassetData::Export::Property property41;
        property41.PropertyName = "object - Entity";
        property41.PropertyType = "int";
        property41.intValue = readInt32();;
        exportData.properties.push_back(property41);
        property41.PropertyName = "object - Entity Guid";
        property41.PropertyType = "FString";
        property41.stringValue = readGuid();;
        exportData.properties.push_back(property41);

        // read entity and guid value
        UassetData::Export::Property property51;
        property51.PropertyName = "object - Entity";
        property51.PropertyType = "int";
        property51.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property51.PropertyName = "object - Entity Guid";
        property51.PropertyType = "FString";
        property51.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else {
        ;
    } */

};

struct Exportobject {
    //int size = 82; 32 + 36 = 68
    u64 size;
    PropName PropertyName = PropName::object;
    PropType PropertyType = PropType::String;
   

   /* if (readInt64() == 1) {
        // read entity and guid
        UassetData::Export::Property property1;
        property1.PropertyName = "object - Entity";
        property1.PropertyType = "int";
        property1.intValue = readInt32();;
        exportData.properties.push_back(property1);
        UassetData::Export::Property property2;
        property2.PropertyName = "object - Entity Guid";
        property2.PropertyType = "FString";
        property2.stringValue = readGuid();;
        exportData.properties.push_back(property2);

        // read 36 bytes
        int size3 = 36;
        UassetData::Export::Property property3;
        property3.PropertyName = "object - 36 bytes unknown";
        property3.PropertyType = "FString";
        property3.stringValue = "bytes";
        property3.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size3);
        exportData.properties.push_back(property3);
        currentIdx += size3;

        // read entity and guid value
        UassetData::Export::Property property4;
        property4.PropertyName = "object - Entity";
        property4.PropertyType = "int";
        property4.intValue = readInt32();;
        exportData.properties.push_back(property4);
        property4.PropertyName = "object - Entity Guid";
        property4.PropertyType = "FString";
        property4.stringValue = readGuid();;
        exportData.properties.push_back(property4);

        // read entity and guid value
        UassetData::Export::Property property5;
        property5.PropertyName = "object - Entity";
        property5.PropertyType = "int";
        property5.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property5.PropertyName = "object - Entity Guid";
        property5.PropertyType = "FString";
        property5.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else if (readInt64() == 0) {
        // read 36 bytes
        int size31 = 32;
        UassetData::Export::Property property31;
        property31.PropertyName = "object - 36 bytes unknown";
        property31.PropertyType = "FString";
        property31.stringValue = "bytes";
        property31.byteBuffer.assign(bytesPtr->begin() + currentIdx, bytesPtr->begin() + currentIdx + size31);
        exportData.properties.push_back(property31);
        currentIdx += size31;

        // read entity and guid value
        UassetData::Export::Property property41;
        property41.PropertyName = "object - Entity";
        property41.PropertyType = "int";
        property41.intValue = readInt32();;
        exportData.properties.push_back(property41);
        property41.PropertyName = "object - Entity Guid";
        property41.PropertyType = "FString";
        property41.stringValue = readGuid();;
        exportData.properties.push_back(property41);

        // read entity and guid value
        UassetData::Export::Property property51;
        property51.PropertyName = "object - Entity";
        property51.PropertyType = "int";
        property51.intValue = readInt32();;
        //  exportData.properties.push_back(property5);
        property51.PropertyName = "object - Entity Guid";
        property51.PropertyType = "FString";
        property51.stringValue = readGuid();;
        //  exportData.properties.push_back(property5);
    }
    else {
        ;
    } */

};

struct ExportOutputDelegate {
   u32 value;
    PropName PropertyName = PropName::OutputDelegate;
    PropType PropertyType = PropType::String;
    

    if (value == 8) {
    
    u8 byte1 = pullIndividualBytes32(value, 0);
    u8 byte2 = pullIndividualBytes32(value, 1);
    u8 byte3 = pullIndividualBytes32(value, 2);
    u8 byte4 = pullIndividualBytes32(value, 3);

    }
    else if (val1 == 0) {
        u8 byte;
    }

};

struct Exportexecute {
    u32 val1; // PinFriendlyName
    u32 val2; // PinFriendlyName
    u8 val3; // PinFriendlyName
    u32 val4; // Source index
    u8 val5; // Direction
    
    
    PropName PropertyName = PropName::execute;
    PropType PropertyType = PropType::Int;
    
    //PropType PropertyType = PropType::String;
    //PropType PropertyType = PropType::Int;
 

};

struct ExportWorldContextObject {
    u32 val1 = readInt32();
    u32 val2 = readInt32();
    u32 val3 = readInt32();
    u8 val4 = readByte();
    u8 byte;
    PropName PropertyName = PropName::WorldContextObject;
    PropType PropertyType = PropType::Fstring;


};

struct ExportIntProperty {

};




struct ExportUbergraphPages {
    //We should probably handle sub type count and everything inside of the parent of this struct.

    if(parent.ObjectType == "ArrayProperty" && parent.ObjectSubType == "ObjectProperty") {
        PropName Property = PropName::UbergraphPages;
        PropType PropertyType = PropType::Int;
        s32 Value; // count of items in array
        s32 Reserved1;
        ExportUbergraphPage GraphPages[Value];
    }
    else {
        std::print("Missing handler for object type {} in ExportUbergraphPages", parent.ObjectSubType);
    }
};

struct Property {
    s64 index = std::core::array_index();
    s64 ObjectClassId;
    if (ObjectClassId == 0) {
        padding[while($[$] == 0x00 && $ < std::mem::size())];
        $ = $ - 1;
        std::print("Our property is fucked now, with a bunch of null values!! at address 0x{:02X}", addressof(ObjectClassId));
        continue;
    }

    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 1) {
        MetaProperty MetaProperties[4];
    }
    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 2) {
        MetaProperty MetaProperties[4];
    }
    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 3) {
        MetaProperty MetaProperties[4];
    }
    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 4) {
        MetaProperty MetaProperties[4];
    }
    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 5) {
        MetaProperty MetaProperties[4];
    }
    if(lowerBytes(ObjectClassId) == 0 && higherBytes(ObjectClassId) == 10) {
        MetaProperty MetaProperties[4];
    }
    if(ObjectClassId >= 0 && ObjectClassId < std::core::member_count(parent.parent.parent.TextNames))
    DataName ObjectClass @ addressof(parent.parent.parent.TextNames[ObjectClassId]);
    
    try {
        std::print("Parsing property: {}", ObjectClass.Name.String);
        match(ObjectClass.Name.String) {
            ("ParentClass"): {
                ExportPropertyBase<ExportParentClass, false> PropertyItem;
                //ParentClass parentClass;//(exportData, exportDataIdx);

            }
            ("AdvancedPinDisplay"): {
             ExportPropertyBase<ExportAdvancedPinDisplay, false> PropertyItem;
               // std::print("Object Class Type: {} Not Implemented Yet.", ObjectClass.Name.String);
                //processAdvancedPinDisplay(exportData, exportDataIdx);
            }
            ("CategorySorting"): {
               ExportPropertyBase<ExportCategorySorting, false> PropertyItem;
                //processCategorySorting(exportData, exportDataIdx);
            }
            ("CategoryName"): {
                ExportPropertyBase<ExportCategoryName, false> PropertyItem;
                
                //processCategoryName(exportData, exportDataIdx);
            }
            ("PropertyGuids"): {
            ExportPropertyBase<ExportPropertyGuids, false> PropertyItem;
                //processPropertyGuids(exportData, exportDataIdx);
            }
            ("GeneratedClass"): {
                ExportPropertyBase<ExportGeneratedClass, false> PropertyItem;
            }
            ("bLegacyNeedToPurgeSkelRefs"): {
            ExportPropertyBase<ExportbLegacyNeedToPurgeSkelRefs, false> PropertyItem;
                 //processbLegacyNeedToPurgeSkelRefs(exportData, exportDataIdx);
            }
            ("bConsumeInput"): {
               ExportPropertyBase<ExportbConsumeInput, false> PropertyItem; 
                //processbConsumeInput(exportData, exportDataIdx);
            }
            ("bExecuteWhenPaused"): {
              ExportPropertyBase<ExportbExecuteWhenPaused, false> PropertyItem; 
               //processbExecuteWhenPaused(exportData, exportDataIdx);
            }
            ("bOverrideParentBinding"): {
                ExportPropertyBase<ExportbOverrideParentBinding, false> PropertyItem;
                //processbOverrideParentBinding(exportData, exportDataIdx);
            }
            ("bShift"): {
                ExportPropertyBase<ExportbShift, false> PropertyItem;
                //processbShift(exportData, exportDataIdx);
            }
            ("FunctionNameToBind"): {
                ExportPropertyBase<ExportFunctionNameToBind, false> PropertyItem;
                //processFunctionNameToBind(exportData, exportDataIdx);
            }
            ("InputKeyEvent"): {
                ExportPropertyBase<ExportInputKeyEvent, false> PropertyItem;
                //processInputKeyEvent(exportData, exportDataIdx);
            }
            ("bCmd"): {
                 ExportPropertyBase<ExportbCmd, false> PropertyItem; 
                 //processbCmd(exportData, exportDataIdx);
            }
            ("bCtrl"): {
                ExportPropertyBase<ExportbCtrl, false> PropertyItem;
                //processbCtrl(exportData, exportDataIdx);
            }
            ("bAlt"): {
                ExportPropertyBase<ExportbAlt, false> PropertyItem;
                //processbAlt(exportData, exportDataIdx);
            }
            ("LastEditedDocuments"): {
               ExportPropertyBase<ExportLastEditedDocuments, false> PropertyItem;
               //processLastEditedDocuments(exportData, exportDataIdx);
            }
            ("VarType"): {
               ExportPropertyBase<ExportVarType, false> PropertyItem; 
                //processVarType(exportData, exportDataIdx);
            }
            ("DefaultValue"): {
                ExportPropertyBase<ExportDefaultValue, false> PropertyItem; 
                //processDefaultValue(exportData, exportDataIdx);
            }
            ("VarName"): {
                ExportPropertyBase<ExportVarName, false> PropertyItem;
                //processVarName(exportData, exportDataIdx);
            }
            ("PropertyFlags"): {
                ExportPropertyBase<ExportPropertyFlags, false> PropertyItem;
                //processPropertyFlags(exportData, exportDataIdx);
            }
            ("Category"): {
                ExportPropertyBase<ExportCategory, false> PropertyItem;
                //processCategory(exportData, exportDataIdx);
            }
            ("MetaDataArray"): {
                ExportPropertyBase<ExportMetaDataArray, false> PropertyItem;
                //processMetaDataArray(exportData, exportDataIdx);
            }
            ("FriendlyName"): {
                ExportPropertyBase<ExportFriendlyName, false> PropertyItem;
                //processFriendlyName(exportData, exportDataIdx);
            }
            ("RepNotifyFunc"): {
                ExportPropertyBase<ExportRepNotifyFunc, false> PropertyItem;
                //processRepNotifyFunc(exportData, exportDataIdx);
            }
            ("ReplicationCondition"): {
                ExportPropertyBase<ExportReplicationCondition, false> PropertyItem;
                //processReplicationCondition(exportData, exportDataIdx);
            }
            ("NewVariables"): {
                ExportPropertyBase<ExportNewVariables, false> PropertyItem;
                //processNewVariables(exportData, exportDataIdx);
            }
            ("DynamicBindingObjects"): {
                ExportPropertyBase<ExportDynamicBindingObjects, false> PropertyItem;
                //processDynamicBindingObjects(exportData, exportDataIdx);
            }
            ("KeyName"): {
                ExportPropertyBase<ExportKeyName, false> PropertyItem;
                //processKeyName(exportData, exportDataIdx);
            }
            ("UberGraphFrame"): {
                ExportPropertyBase<ExportUberGraphFrame, false> PropertyItem;
                //processUberGraphFrame(exportData, exportDataIdx);
            }
            ("Schema"): {
            
              ExportPropertyBase<ExportSchema, false> PropertyItem;
                //processSchema(exportData, exportDataIdx);
            }
            ("bCommentBubbleVisible_InDetailsPanel"): {
               ExportPropertyBase<ExportbCommentBubbleVisible_InDetailsPanel, false> PropertyItem;
                //processbCommentBubbleVisible_InDetailsPanel(exportData, exportDataIdx);
            }
            ("bCommentBubbleVisible"): {
                ExportPropertyBase<ExportbCommentBubbleVisible, false> PropertyItem;
                //processbCommentBubbleVisible(exportData, exportDataIdx);
            }
            ("bCommentBubblePinned"): {
                ExportPropertyBase<ExportbCommentBubblePinned, false> PropertyItem;
                //processbCommentBubblePinned(exportData, exportDataIdx);
            }
            ("bHiddenEdTemporary"): {
                ExportPropertyBase<ExportbHiddenEdTemporary, false> PropertyItem;
                //processbHiddenEdTemporary(exportData, exportDataIdx);
            }
            ("bIsEditable"): {
                ExportPropertyBase<ExportbIsEditable, false> PropertyItem;
                //processbIsEditable(exportData, exportDataIdx);
            }
            ("bSelfContext"): {
                ExportPropertyBase<ExportbSelfContext, false> PropertyItem;
                //processbSelfContext(exportData, exportDataIdx);
            }
            ("None"): {
               ExportPropertyBase<ExportNone, false> PropertyItem;
                //processNone(exportData, exportDataIdx);
            }
            ("InputChord"): {
                ExportPropertyBase<ExportInputChord, false> PropertyItem;
                //processInputChord(exportData, exportDataIdx);
            }
            ("Key"): {
                ExportPropertyBase<ExportKey, false> PropertyItem;
                //processKey(exportData, exportDataIdx);
            }
            ("InputKeyDelegateBindings"): {
                ExportPropertyBase<ExportInputKeyDelegateBindings, false> PropertyItem;
                //processInputKeyDelegateBindings(exportData, exportDataIdx);
            }
            ("DelegateReference"): {
                ExportPropertyBase<ExportDelegateReference, false> PropertyItem;
                 //processDelegateReference(exportData, exportDataIdx);
            }
            ("FunctionReference"): {
                ExportPropertyBase<ExportFunctionReference, false> PropertyItem;
                //processFunctionReference(exportData, exportDataIdx);
            }
            ("bIsPureFunc"): {
                ExportPropertyBase<ExportbIsPureFunc, false> PropertyItem;
                 //processbIsPureFunc(exportData, exportDataIdx);
            }
            ("bIsConstFunc"): {
               ExportPropertyBase<ExportbIsConstFunc, false> PropertyItem;
                //processbIsConstFunc(exportData, exportDataIdx);
            }
            ("bOverrideFunction"): {
                ExportPropertyBase<ExportbOverrideFunction, false> PropertyItem;
                //processbOverrideFunction(exportData, exportDataIdx);
            }
            ("NodePosX"): {
                ExportPropertyBase<ExportNodePosX, false> PropertyItem;
                //processNodePosX(exportData, exportDataIdx);
            }
            ("NodePosY"): {
                ExportPropertyBase<ExportNodePosY, false> PropertyItem;
                //processNodePosY(exportData, exportDataIdx);
            }
            ("NodeWidth"): {
                ExportPropertyBase<ExportNodeWidth, false> PropertyItem;
                //processNodeWidth(exportData, exportDataIdx);
            }
            ("NodeHeight"): {
               ExportPropertyBase<ExportNodeHeight, false> PropertyItem;
                //processNodeHeight(exportData, exportDataIdx);
            }
            ("NodeComment"): {
                ExportPropertyBase<ExportNodeComment, false> PropertyItem;
                //processNodeComment(exportData, exportDataIdx);
            }
            ("CustomFunctionName"): {
                ExportPropertyBase<ExportCustomFunctionName, false> PropertyItem;
                //processCustomFunctionName(exportData, exportDataIdx);
            }
            ("EventReference"): {
                ExportPropertyBase<ExportEventReference, false> PropertyItem;
                //processEventReference(exportData, exportDataIdx);
            }
            ("ExtraFlags"): {
                ExportPropertyBase<ExportExtraFlags, false> PropertyItem;
                //processExtraFlags(exportData, exportDataIdx);
            }
            ("CustomClass"): {
                ExportPropertyBase<ExportCustomClass, false> PropertyItem;
                //processCustomClass(exportData, exportDataIdx);
            }
            ("InputKey"): {
                ExportPropertyBase<ExportInputKey, false> PropertyItem;
                //processInputKey(exportData, exportDataIdx);
            }
            ("VariableReference"): {
                ExportPropertyBase<ExportVariableReference, false> PropertyItem;
                //processVariableReference(exportData, exportDataIdx);
            }
            ("bVisualizeComponent"): {
                ExportPropertyBase<ExportbVisualizeComponent, false> PropertyItem;
                //processbVisualizeComponent(exportData, exportDataIdx);
            }
            ("ComponentClass"): {
                ExportPropertyBase<ExportComponentClass, false> PropertyItem;
                //processComponentClass(exportData, exportDataIdx);
            }
            ("ComponentTemplate"): {
                ExportPropertyBase<ExportComponentTemplate, false> PropertyItem;
                //processComponentTemplate(exportData, exportDataIdx);
            }
            ("RootNodes"): {
                ExportPropertyBase<ExportRootNodes, false> PropertyItem;
                //processRootNodes(exportData, exportDataIdx);
            }
            ("AllNodes"): {
               ExportPropertyBase<ExportAllNodes, false> PropertyItem;
               //processAllNodes(exportData, exportDataIdx);
            }
            ("DefaultSceneRootNode"): {
                ExportPropertyBase<ExportDefaultSceneRootNode, false> PropertyItem;
                 //processDefaultSceneRootNode(exportData, exportDataIdx);
            }
            ("InternalVariableName"): {
                ExportPropertyBase<ExportInternalVariableName, false> PropertyItem;
                //processInternalVariableName(exportData, exportDataIdx);
            }
            ("Nodes"): {
                ExportPropertyBase<ExportNodes, false> PropertyItem;
                //processNodes(exportData, exportDataIdx);
            }
            ("GraphGuid"): {
                ExportPropertyBase<ExportGraphGuid, false> PropertyItem;
                //processGraphGuid(exportData, exportDataIdx);
            }
            ("BlueprintGuid"): {
                ExportPropertyBase<ExportBlueprintGuid, false> PropertyItem;
                //processBlueprintGuid(exportData, exportDataIdx);
            }
            ("VarGuid"): {
                ExportPropertyBase<ExportVarGuid, false> PropertyItem;
                //processVarGuid(exportData, exportDataIdx);
            }
            ("NodeGuid"): {
               ExportPropertyBase<ExportNodeGuid, false> PropertyItem;
               //processNodeGuid(exportData, exportDataIdx);
            }
            ("bAllowDeletion"): {
                ExportPropertyBase<ExportbAllowDeletion, false> PropertyItem;
                //processbAllowDeletion(exportData, exportDataIdx);
            }
            ("MemberReference"): {
                ExportPropertyBase<ExportMemberReference, false> PropertyItem;
                 //processMemberReference(exportData, exportDataIdx);
            }
            ("MemberParent"): {
               ExportPropertyBase<ExportMemberParent, false> PropertyItem;
               //processMemberParent(exportData, exportDataIdx);
            }
            ("MemberName"): {
                ExportPropertyBase<ExportMemberName, false> PropertyItem;
                //processMemberName(exportData, exportDataIdx);
            }
            ("BlueprintSystemVersion"): {
                ExportPropertyBase<ExportBlueprintSysVersion, false> PropertyItem;
                //std::print("Object Class Type: {} Not Implemented Yet.", ObjectClass.Name.String);
                //processBlueprintSystemVersion(exportData, exportDataIdx);
            }
            ("SimpleConstructionScript"): {
               ExportPropertyBase<ExportSimpleConstructionScript, false> PropertyItem;
               //processSimpleConstructionScript(exportData, exportDataIdx);
            }
            ("UbergraphPages"): {
                ExportPropertyBase<ExportUbergraphPages, true> PropertyItem;
                //std::print("Object Class Type: {} Not Implemented Yet.", ObjectClass.Name.String);
                //processUbergraphPages(exportData, exportDataIdx);
            }
            ("FunctionGraphs"): {
                ExportPropertyBase<ExportFunctionGraphs, false> PropertyItem;
                //processFunctionGraphs(exportData, exportDataIdx);
            }
            ("UberGraphFunction"): {
               ExportPropertyBase<ExportUberGraphFunction, false> PropertyItem;
               //processUberGraphFunction(exportData, exportDataIdx);
            }
            ("VariableGuid"): {
                ExportPropertyBase<ExportVariableGuid, false> PropertyItem;
                //processVariableGuid(exportData, exportDataIdx);
            }
            ("MemberGuid"): {
                ExportPropertyBase<ExportMemberGuid, false> PropertyItem;
                //processMemberGuid(exportData, exportDataIdx);
            }
            ("EnabledState"): {
                ExportPropertyBase<ExportEnabledState, false> PropertyItem;
                //processEnabledState(exportData, exportDataIdx);
            }
            ("TransformComponent"): {
               ExportPropertyBase<ExportTransformComponent, false> PropertyItem;
                //processTransformComponent(exportData, exportDataIdx);
            }
            ("RootComponent"): {
                ExportPropertyBase<ExportRootComponent, false> PropertyItem;
                //processRootComponent(exportData, exportDataIdx);
            }
            ("then"): {
                ExportPropertyBase<Exportthen, false> PropertyItem;
                //processthen(exportData, exportDataIdx);
            }
            ("Delegate"): {
               ExportPropertyBase<ExportDelegate, false> PropertyItem;
               //processDelegate(exportData, exportDataIdx);
            }
            ("self"): {
               ExportPropertyBase<Exportself, false> PropertyItem;
                //processself(exportData, exportDataIdx);
            }
            ("exec"): {
               ExportPropertyBase<Exportexec, false> PropertyItem;
                //processexec(exportData, exportDataIdx);
            }
            ("delegate"): {
                ExportPropertyBase<Exportdelegate, false> PropertyItem;
                //processdelegate(exportData, exportDataIdx);
            }
            ("object"): {
               ExportPropertyBase<Exportobject, false> PropertyItem;
               //processobject(exportData, exportDataIdx);
            }
            ("OutputDelegate"): {
                ExportPropertyBase<ExportOutputDelegate, false> PropertyItem;
                //processOutputDelegate(exportData, exportDataIdx);
            }
            ("execute"): {
                ExportPropertyBase<Exportexecute, false> PropertyItem;
                //processexecute(exportData, exportDataIdx);
            }
            ("WorldContextObject"): {
                ExportPropertyBase<ExportWorldContextObject, false> PropertyItem;
                //processWorldContextObject(exportData, exportDataIdx);
            }
            ("IntProperty"): {
                //ExportPropertyBase<ExportIntProperty, false> PropertyItem;
                std::print("Object Class Type: {} Not Implemented Yet.", ObjectClass.Name.String);
                //processWorldContextObject(exportData, exportDataIdx);
            }
            (_): {
                std::print("Object Class Type: {} Not Implemented Yet, and missing case statement. Buffer Address 0x{:02X}", ObjectClass.Name.String, addressof(ObjectClassId));
            }
        }
    }
    catch
    {

    }
};

//fn ReadStructure(

struct AssetExportDetails {
//Read export data here
    u64 PropertyStartAddr = $;
    if (parent.parent.header.FileVersionUE5 >= 0x03F4)
    u8 ReservedForUE5_4_4;
    s64 ObjectNameId;
    DataName ObjectName @ addressof(parent.parent.TextNames[ObjectNameId]);
    Property Properties[while($ < parent.SerialOffset.BuiltValue + parent.SerialSize.BuiltValue)] @ parent.SerialOffset.BuiltValue + 1;

};

struct AssetExport {
    u64 TotalSizeOfFile = std::mem::size();
    s32 ClassIndex;
    s32 SuperIndex;
    if (parent.header.FileVersionUE4 >= 0x00AD) {
        s32 TemplateIndex;
    }
    else
    s32 TemplateIndex = 0;
    s32 OuterIndex;
    s32 ObjectNameId;
    DataName ObjectName @ addressof(parent.TextNames[ObjectNameId]);
    s32 Reserved1;
    u32 ObjectFlags;
    if($ + 8 < TotalSizeOfFile)
    Int64Export SerialSize;
    if($ + 8 < TotalSizeOfFile)
    Int64Export SerialOffset;
    s32 ForcedExport;
    s32 NotForClient;
    s32 NotForServer;
    UE5_GUID PackageGuid;
    u32 PackageFlags;

    if (parent.header.FileVersionUE4 >= 0x00AC)
    s32 NotAlwaysLoadedForEditorGame;
    else
    s32 NotAlwaysLoadedForEditorGame = 0;

    if (parent.header.FileVersionUE4 >= 0x00AE) // VER_UE4_COOKED_ASSETS_IN_EDITOR_SUPPORT
    s32 IsAsset;
    else
    s32 IsAsset = 0;

    if (parent.header.FileVersionUE5 >= 0x0197) // VER_UE5_OPTIONAL_RESOURCES
    s32 GeneratePublicHash;
    else
    s32 GeneratePublicHash = 0;

    if (parent.header.FileVersionUE4 >= 0x0194) // VER_UE4_PRELOAD_DEPENDENCIES_IN_COOKED_EXPORTS
    {
        s32 FirstExportDependency;
        s32 SerializationBeforeSerializationDependencies;
        s32 CreateBeforeSerializationDependencies;
        s32 SerializationBeforeCreateDependencies;
        s32 CreateBeforeCreateDependencies;
    }
    else
    {
        s32 FirstExportDependency = 0;
        s32 SerializationBeforeSerializationDependencies = 0;
        s32 CreateBeforeSerializationDependencies = 0;
        s32 SerializationBeforeCreateDependencies = 0;
        s32 CreateBeforeCreateDependencies = 0;
    }

    if(SerialOffset.BuiltValue > 0) {
        u8 ChunkData[SerialSize.BuiltValue] @ SerialOffset.BuiltValue;
    }

    s32 Reserved2;
    AssetExportDetails Detail @ SerialOffset.BuiltValue;

};

struct AssetImport {
    s64 ClassPackageId;
    s64 ClassNameId;
    s32 OuterIndex;
    s64 ObjectNameId;
    if (ClassPackageId >= 0 && ClassPackageId < parent.header.NameCount) {
        DataName ClassPackage @ addressof(parent.TextNames[ClassPackageId]);
    }
    if (ClassNameId >= 0 && ClassNameId < parent.header.NameCount) {
        DataName ClassName @ addressof(parent.TextNames[ClassNameId]);
    }
    if (ObjectNameId >= 0 && ObjectNameId < ClassNameId < parent.header.NameCount) {
        DataName ObjectName  @ addressof(parent.TextNames[ObjectNameId]);
    }

    if (parent.header.FileVersionUE4 >= 0x0166) {
        s64 PackageNameId;
        DataName PackageName @ addressof(parent.TextNames[PackageNameId]);
    }

    if (parent.header.FileVersionUE5 >= 0x0197) {
        s32 ImportOptional;
    }
};
enum ImageType : u8 {
    JPEG,
    PNG
};

struct ThumbnailIndex {
    FString AssetClassName;
    FString ObjectPath;
    s32 FileOffset;
};

struct Thumbnail {
    s64 DataOffset = parent.Indexes[std::core::array_index()].FileOffset;
    $ = DataOffset;
    s32 Width;
    s32 Height;

    if (Height < 0) {
        ImageType ImageFormat = ImageType::JPEG;
        Height = -Height;
    }
    else
    ImageType ImageFormat = ImageType::PNG;

    s32 ImageLength;
    if(ImageLength > 0)
    u8 ImageData[ImageLength];
};

struct Thumbnails {
    s32 Count;
    ThumbnailIndex Indexes[Count];
    Thumbnail ThumbnailData[Count];
};

struct Tag {
    FString Key;
    FString Value;
};

struct RegistryEntry {
    FString ObjectPath;
    FString ObjectClassName;

    s32 Count;
    Tag Tags[Count];
};

struct AssetRegistryData {
    s64 DependencyDataOffset;
    s32 Count;

    RegistryEntry Entries[Count];
};

struct UE5_Asset {
    UE5_Header header;
    DataName TextNames[header.NameCount] @ header.NameOffset;
    GatherableTextData TextData[header.GatherableTextDataCount] @ header.GatherableTextDataOffset;
    AssetImport Imports[header.ImportCount] @ header.ImportOffset;
    AssetExport Exports[header.ExportCount] @ header.ExportOffset;
    if (header.ThumbnailTableOffset > 0)
        Thumbnails ThumbnailDictionary @ header.ThumbnailTableOffset;;
    if (header.AssetRegistryDataOffset > 0)
        AssetRegistryData RegistryData @ header.AssetRegistryDataOffset;
};

UE5_Asset ue_asset_file @ 0x00;
