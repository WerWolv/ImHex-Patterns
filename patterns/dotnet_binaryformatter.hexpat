
/*
    References:
        .NET BinaryFormatter Specification "MS-NRBF":
            https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-nrbf/75b9fe09-be15-475f-85b8-ae7b7558cfe5
        .NET runtime:
            https://github.com/dotnet/runtime/blob/v8.0.17/src/libraries/System.Runtime.Serialization.Formatters/src/System/Runtime/Serialization/Formatters/Binary/BinaryParser.cs
        .NET Library for Parsing MS-NRBF streams:
            https://github.com/bbowyersmyth/BinaryFormatDataStructure
*/

#pragma author ODeux
#pragma description .NET BinaryFormatter (System.Runtime.Serialization.Formatters.Binary, obsolete)

#pragma endian little

import std.core;
import std.sys;
import std.mem;
import std.ptr;

fn offsetOf(ref auto value, ref auto value_field){
    return addressof(value_field) - addressof(value);
};

struct NullableArrayPtr<T, pointerSize, auto size>{
    pointerSize pointerValue [[no_unique_address, hidden]];
    if(pointerValue != 0)
        T *data[size]: pointerSize;
    else
        padding[sizeof(pointerSize)];
};

using _Ptr<T, PointerSize> = std::ptr::NullablePtr<T, PointerSize>;
using _ArrayPtr<T, PointerSize, auto size> = NullableArrayPtr<T, PointerSize, size>;

fn append_value_to_section(ref auto value, std::mem::Section section){
    u128 old_section_size = std::mem::get_section_size(section);
    std::mem::copy_value_to_section(value, section, old_section_size);
    return old_section_size;
};

fn todo(auto message){
    std::error(std::format("@0x{:08X} TODO: " + message, $));
};

using _Trackers;
std::mem::Section _TrackersSection = std::mem::create_section("_TrackersSection");
_Trackers _trackers @ 0x0 in _TrackersSection;
bool NeedUpdateTrackers = false;
bool IsUpdatingTrackers = false;

enum _ObjEnum: u64{
    Empty = 0,
    SerializedStreamHeader = 1,
    ClassWithId = 2, Object = _ObjEnum::ClassWithId,
    SystemClassWithMembers = 3, ObjectWithMap = _ObjEnum::SystemClassWithMembers,
    ClassWithMembers = 4, ObjectWithMapAssemId = _ObjEnum::ClassWithMembers,
    SystemClassWithMembersAndTypes = 5, ObjectWithMapTyped = _ObjEnum::SystemClassWithMembersAndTypes,
    ClassWithMembersAndTypes = 6, ObjectWithMapTypedAssemId = _ObjEnum::ClassWithMembersAndTypes,
    BinaryObjectString = 7, ObjectString = _ObjEnum::BinaryObjectString,
    BinaryArray = 8, Array = _ObjEnum::BinaryArray,
    MemberPrimitiveTyped = 9,
    MemberReference = 10,
    BinaryLibrary = 11, Assembly = _ObjEnum::BinaryLibrary,
    ObjectNullMultiple256 = 12,
    ObjectNullMultiple = 13,
    ArraySinglePrimitive = 14,
    ArraySingleObject = 15,
    ArraySingleString = 16,
    CrossAppDomainMap = 17,
    CrossAppDomainString = 18,
    CrossAppDomainAssembly = 19,
    MethodCall = 20,
    MethodReturn = 21
};

fn zeroedCurrObjTrackers(){
    _trackers.currentObj.TypeName.pointerValue = 0;
    _trackers.currentObj.AssemblyName.pointerValue = 0;
    _trackers.currentObj.objEnum = _ObjEnum::Empty;
    _trackers.currentObj.RawPtr = 0;
};

fn copyCurrObjAtIdTrackers(auto id){
    NeedUpdateTrackers = true;
    _trackers.objs[id].TypeName.pointerValue = _trackers.currentObj.TypeName.pointerValue;
    _trackers.objs[id].AssemblyName.pointerValue = _trackers.currentObj.AssemblyName.pointerValue;
    /* ! Enum does not get copied if we don't use a cast here for some reason ! */
    _trackers.objs[id].objEnum = u64(_trackers.currentObj.objEnum);
    _trackers.objs[id].RawPtr = _trackers.currentObj.RawPtr;
};

using BitfieldOrder = std::core::BitfieldOrder;

using TimeSpan = s64;

enum PrimitiveTypeEnum: u8{
    Invalid  = 0,
    Boolean  = 1,
    Byte     = 2,
    Char     = 3,
    Currency = 4, /* Not Used in this protocol */
    Decimal  = 5,
    Double   = 6,
    Int16    = 7,
    Int32    = 8,
    Int64    = 9,
    SByte    = 10,
    Single   = 11,
    TimeSpan = 12,
    DateTime = 13,
    UInt16   = 14,
    UInt32   = 15,
    UInt64   = 16,
    Null     = 17,
    String   = 18
};

struct PrimitiveTypeEnumT<auto _primitiveTypeEnumT>{
    PrimitiveTypeEnum primitiveTypeEnumT = _primitiveTypeEnumT;
    PrimitiveTypeEnum primitiveTypeEnum;
    if(_primitiveTypeEnumT > 0)
        std::assert(primitiveTypeEnum == primitiveTypeEnumT, std::format("Expected {} but got {}", primitiveTypeEnumT, primitiveTypeEnum));
};

enum BinaryTypeEnum: u8{
    Primitive      = 0,
    String         = 1,
    Object         = 2,
    SystemClass    = 3, ObjectUrt  = BinaryTypeEnum::SystemClass,
    Class          = 4, ObjectUser = BinaryTypeEnum::Class,
    ObjectArray    = 5,
    StringArray    = 6,
    PrimitiveArray = 7
};

enum BinaryArrayTypeEnum: u8{
    Single            = 0,
    Jagged            = 1,
    Rectangular       = 2,
    SingleOffset      = 3,
    JaggedOffset      = 4,
    RectangularOffset = 5
};

enum RecordTypeEnum: u8{
    SerializedStreamHeader         = 0,
    ClassWithId                    = 1, Object = RecordTypeEnum::ClassWithId,
    SystemClassWithMembers         = 2, ObjectWithMap = RecordTypeEnum::SystemClassWithMembers,
    ClassWithMembers               = 3, ObjectWithMapAssemId = RecordTypeEnum::ClassWithMembers,
    SystemClassWithMembersAndTypes = 4, ObjectWithMapTyped = RecordTypeEnum::SystemClassWithMembersAndTypes,
    ClassWithMembersAndTypes       = 5, ObjectWithMapTypedAssemId = RecordTypeEnum::ClassWithMembersAndTypes,
    BinaryObjectString             = 6, ObjectString = RecordTypeEnum::BinaryObjectString,
    BinaryArray                    = 7, Array = RecordTypeEnum::BinaryArray,
    MemberPrimitiveTyped           = 8,
    MemberReference                = 9,
    ObjectNull                     = 10,
    MessageEnd                     = 11,
    BinaryLibrary                  = 12, Assembly = RecordTypeEnum::BinaryLibrary,
    ObjectNullMultiple256          = 13,
    ObjectNullMultiple             = 14,
    ArraySinglePrimitive           = 15,
    ArraySingleObject              = 16,
    ArraySingleString              = 17,
    CrossAppDomainMap              = 18,
    CrossAppDomainString           = 19,
    CrossAppDomainAssembly         = 20,
    MethodCall                     = 21,
    MethodReturn                   = 22
};
using BinaryHeaderEnum = RecordTypeEnum;

struct RecordTypeEnumT<auto _recordTypeEnumT>{
    RecordTypeEnum recordTypeEnumT = _recordTypeEnumT;
    RecordTypeEnum recordTypeEnum;
    if(_recordTypeEnumT > 0)
        std::assert(recordTypeEnum == recordTypeEnumT, std::format("Expected {} but got {}", recordTypeEnumT, recordTypeEnum));
};

bitfield MessageFlags{
    bool NoArgs:                 1; /* Arg       Category */
    bool ArgsInline:             1; /* Arg       Category */
    bool ArgsIsArray:            1; /* Arg       Category */
    bool ArgsInArray:            1; /* Arg       Category */
    bool NoContext:              1; /* Context   Category */
    bool ContextInline:          1; /* Context   Category */
    bool ContextInArray:         1; /* Context   Category */
    bool MethodSignatureInArray: 1; /* Signature Category */
    bool PropertiesInArray:      1; /* Property  Category */
    bool NoReturnValue:          1; /* Return    Category */
    bool ReturnValueVoid:        1; /* Return    Category */
    bool ReturnValueInline:      1; /* Return    Category */
    bool ReturnValueInArray:     1; /* Return    Category */
    bool ExceptionInArray:       1; /* Exception Category */
    bool GenericMethod:          1; /* Generic   Category */
    unsigned unused: 17;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 32)]];

fn validate_MessageFlags(MessageFlags flags){
    u8 arg_cnt = flags.NoArgs + flags.ArgsInline + flags.ArgsIsArray + flags.ArgsInArray;
    u8 ctx_cnt = flags.NoContext + flags.ContextInline + flags.ContextInArray;
    u8 sig_cnt = flags.MethodSignatureInArray;
    u8 ret_cnt = flags.NoReturnValue + flags.ReturnValueVoid + flags.ReturnValueInline + flags.ReturnValueInArray;
    u8 excep_cnt = flags.ExceptionInArray;
    u8 prop_cnt = flags.PropertiesInArray;
    u8 gen_cnt = flags.GenericMethod;
    if(arg_cnt > 1 || ctx_cnt > 1 || sig_cnt > 1 || ret_cnt > 1 || excep_cnt > 1 || prop_cnt > 1 || gen_cnt > 1)
        return -1;
    if(arg_cnt   != 0 && excep_cnt != 0) return -1;
    if(ret_cnt   != 0 && excep_cnt != 0) return -1;
    if(ret_cnt   != 0 && sig_cnt   != 0) return -1;
    if(excep_cnt != 0 && sig_cnt   != 0) return -1;
    return 1;
};

enum DateTimeKind: u8{
    NOT_SPECIFIED = 0,
    UTC           = 1,
    Local         = 2
};

bitfield DateTime{
    s64 Ticks: 62;
    DateTimeKind kind: 2;
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 64)]];

struct vLength{
    /*
        Can't use that, it breaks when struct get re-parsed in _TrackersSection
    u8 data[while(std::mem::read_unsigned($, 1) & 0x80)];
    u8 last;
    */
    u64 bytes [[no_unique_address, hidden]];
    u8 cnt = 0;
    if(bytes & 0x80){
        if(bytes & 0x8000){
            if(bytes & 0x800000){
                if(bytes & 0x80000000){
                    if(bytes & 0x8000000000){
                        /* exceeding vLength 5 bytes, caller should crash */
                        cnt = 5;
                    }else cnt = 4;
                }else cnt = 3;
            }else cnt = 2;
        }else cnt = 1;
    }else cnt = 0;
    u8 data[cnt];
    u8 last;
} [[sealed, transform("LPS_Length_decode"), format("LPS_Length_decode")]];

fn LPS_Length_decode(auto Length){
    u64 length = 0;
    u8 i = 0;
    for(i = 0, i < sizeof(Length.data), i += 1)
        length |= u64(Length.data[i] & 0x7F) << i * 7;
    length |= u64(Length.last) << i * 7;
    return length;
};

struct LengthPrefixedString{
    vLength Length;
    std::assert(sizeof(Length) <= 5, "LengthPrefixedString.Length must be at most 5 bytes long");
    char String[Length];
};

using Decimal = LengthPrefixedString;

struct ClassTypeInfo{
    LengthPrefixedString TypeName;
    s32 LibraryId;
};

struct ValueWithCode{
    PrimitiveTypeEnum PrimitiveType;
    match(PrimitiveType){
        (PrimitiveTypeEnum::Boolean): bool Value;
        (PrimitiveTypeEnum::Byte): u8 Value;
        (PrimitiveTypeEnum::Char): char Value;
        (PrimitiveTypeEnum::Currency): std::error("Primitive currency not used in this protocol");
        (PrimitiveTypeEnum::Decimal): Decimal Value;
        (PrimitiveTypeEnum::Double): double Value;
        (PrimitiveTypeEnum::Int16): s16 Value;
        (PrimitiveTypeEnum::Int32): s32 Value;
        (PrimitiveTypeEnum::Int64): s64 Value;
        (PrimitiveTypeEnum::SByte): s8 Value;
        (PrimitiveTypeEnum::Single): float Value;
        (PrimitiveTypeEnum::TimeSpan): TimeSpan Value;
        (PrimitiveTypeEnum::DateTime): DateTime Value;
        (PrimitiveTypeEnum::UInt16): u16 Value;
        (PrimitiveTypeEnum::UInt32): u32 Value;
        (PrimitiveTypeEnum::UInt64): u64 Value;
        (PrimitiveTypeEnum::Null): {}
        (PrimitiveTypeEnum::String): LengthPrefixedString Value;
        (_): std::error(std::format("Unexpected {}", PrimitiveType));
    }
};

struct StringValueWithCode: PrimitiveTypeEnumT<PrimitiveTypeEnum::String>{
    LengthPrefixedString StringValue;
};

struct ArrayOfValueWithCode{
    s32 Length;
    ValueWithCode ListOfValueWithCode[Length];
};

struct ArrayInfo{
    s32 ObjectId;
    s32 Length;
};

struct ClassInfo{
    s32 ObjectId;
    LengthPrefixedString Name;
    s32 MemberCount;
    LengthPrefixedString MemberNames[MemberCount];
};

struct AdditionalInfo<auto _binaryTypeEnum>{
    BinaryTypeEnum binaryTypeEnum = _binaryTypeEnum;
    match(binaryTypeEnum){
        (BinaryTypeEnum::SystemClass): /* ObjectUrt */
            LengthPrefixedString String;
        (BinaryTypeEnum::Class): /* ObjectUser */
            ClassTypeInfo classTypeInfo;
        (BinaryTypeEnum::Primitive | BinaryTypeEnum::PrimitiveArray): {
            PrimitiveTypeEnum primitiveType;
            std::assert(primitiveType != PrimitiveTypeEnum::Null &&
                        primitiveType != PrimitiveTypeEnum::String, "Must not be Null or String");
        }
        (BinaryTypeEnum::String | BinaryTypeEnum::Object |
         BinaryTypeEnum::ObjectArray | BinaryTypeEnum::StringArray):
            {/* not using continue here, need to keep array index matching */}
        (_): std::error(std::format("Unrecognized {}", binaryTypeEnum));
    }
};

struct MemberTypeInfo<auto MemberCount>{
    BinaryTypeEnum binaryTypeEnums[MemberCount];
    AdditionalInfo<binaryTypeEnums[std::core::array_index()]> additionalInfo[MemberCount];
};

struct UntypedMember<auto _className, auto classInfo>{
    str className = _className;
    u64 MemberCount = classInfo.MemberCount;
    if(className == "System.Guid" && MemberCount == 11){
        match(std::core::array_index()){
            (0): s32 _a;
            (1): s16 _b;
            (2): s16 _c;
            (3): u8 _d;
            (4): u8 _e;
            (5): u8 _f;
            (6): u8 _g;
            (7): u8 _h;
            (8): u8 _i;
            (9): u8 _j;
            (10): u8 _k;
            (_): std::error("unreachable");
        }
    }else if(MemberCount == 1 && classInfo.MemberNames[0].String == "value__"){
        str Name = classInfo.MemberNames[0].String;
        s32 member [name(Name)];
    }else
        std::error(std::format("Unsupported untyped member: {}", className));
};

using Record;

struct Members<auto _Name, auto memberTypeInfo>{
    u64 i = std::core::array_index();
    str Name = _Name;
    BinaryTypeEnum binaryTypeEnum = memberTypeInfo.binaryTypeEnums[i];
    if(binaryTypeEnum == BinaryTypeEnum::Primitive){
        PrimitiveTypeEnum primitiveTypeEnum = memberTypeInfo.additionalInfo[i].primitiveType;
        match(primitiveTypeEnum){
            (PrimitiveTypeEnum::Boolean): bool Value [[name(Name)]];
            (PrimitiveTypeEnum::Byte): u8 Value [[name(Name)]];
            (PrimitiveTypeEnum::Char): char Value [[name(Name)]];
            (PrimitiveTypeEnum::Currency): std::error("Primitive currency not used in this protocol");
            (PrimitiveTypeEnum::Decimal): Decimal Value [[name(Name)]];
            (PrimitiveTypeEnum::Double): double Value [[name(Name)]];
            (PrimitiveTypeEnum::Int16): s16 Value [[name(Name)]];
            (PrimitiveTypeEnum::Int32): s32 Value [[name(Name)]];
            (PrimitiveTypeEnum::Int64): s64 Value [[name(Name)]];
            (PrimitiveTypeEnum::SByte): s8 Value [[name(Name)]];
            (PrimitiveTypeEnum::Single): float Value [[name(Name)]];
            (PrimitiveTypeEnum::TimeSpan): TimeSpan Value [[name(Name)]];
            (PrimitiveTypeEnum::DateTime): DateTime Value [[name(Name)]];
            (PrimitiveTypeEnum::UInt16): u16 Value [[name(Name)]];
            (PrimitiveTypeEnum::UInt32): u32 Value [[name(Name)]];
            (PrimitiveTypeEnum::UInt64): u64 Value [[name(Name)]];
            (PrimitiveTypeEnum::Null): {}
            (PrimitiveTypeEnum::String): LengthPrefixedString Value [[name(Name)]];
            (_): std::error(std::format("Unexpected {}", primitiveTypeEnum));
        }
    }else{
        Record record [[name(Name)]];
    }
};

struct ClassWithMembersAndTypes: RecordTypeEnumT<RecordTypeEnum::ClassWithMembersAndTypes>{
    ClassInfo classInfo;
    MemberTypeInfo<classInfo.MemberCount> memberTypeInfo;
    s32 LibraryId;
    Members<classInfo.MemberNames[std::core::array_index()].String, memberTypeInfo> members[classInfo.MemberCount];
};

struct ClassWithMembers: RecordTypeEnumT<RecordTypeEnum::ClassWithMembers>{
    ClassInfo classInfo;
    s32 LibraryId;
    UntypedMember<classInfo.Name.String, classInfo> members[classInfo.MemberCount];
};

struct SystemClassWithMembersAndTypes: RecordTypeEnumT<RecordTypeEnum::SystemClassWithMembersAndTypes>{
    ClassInfo classInfo;
    MemberTypeInfo<classInfo.MemberCount> memberTypeInfo;
    Members<classInfo.MemberNames[std::core::array_index()].String, memberTypeInfo> members[classInfo.MemberCount];
};

struct SystemClassWithMembers: RecordTypeEnumT<RecordTypeEnum::SystemClassWithMembers>{
    ClassInfo classInfo;
    UntypedMember<classInfo.Name.String, classInfo> members[classInfo.MemberCount];
};

struct ClassWithId: RecordTypeEnumT<RecordTypeEnum::ClassWithId>{
    s32 ObjectId;
    s32 MetadataId;
    if(!IsUpdatingTrackers && NeedUpdateTrackers){
        IsUpdatingTrackers = true;
        _Trackers _trackers @ 0x0 in _TrackersSection;
        IsUpdatingTrackers = false;
        NeedUpdateTrackers = false;
    }
    match(_trackers.objs[MetadataId].objEnum){
        (_ObjEnum::ClassWithMembersAndTypes): {
            u32 MemberCount = _trackers.objs[MetadataId].classWithMembersAndTypes.data.classInfo.MemberCount;
            Members<_trackers.objs[MetadataId].classWithMembersAndTypes.data.classInfo.MemberNames[std::core::array_index()].String, _trackers.objs[MetadataId].classWithMembersAndTypes.data.memberTypeInfo> members[MemberCount];
        }
        (_ObjEnum::SystemClassWithMembersAndTypes): {
            u32 MemberCount = _trackers.objs[MetadataId].systemClassWithMemberAndTypes.data.classInfo.MemberCount;
            Members<_trackers.objs[MetadataId].systemClassWithMemberAndTypes.data.classInfo.MemberNames[std::core::array_index()].String, _trackers.objs[MetadataId].systemClassWithMemberAndTypes.data.memberTypeInfo> members[MemberCount];
        }
        (_ObjEnum::SystemClassWithMembers): {
            str className = _trackers.objs[MetadataId].TypeName.data.String;
            u32 MemberCount = _trackers.objs[MetadataId].systemClassWithMembers.data.classInfo.MemberCount;
            UntypedMember<className, _trackers.objs[MetadataId].systemClassWithMembers.data.classInfo> members[MemberCount];
        }
        (_ObjEnum::ClassWithMembers): {
            str className = _trackers.objs[MetadataId].TypeName.data.String;
            u32 MemberCount = _trackers.objs[MetadataId].classWithMembers.data.classInfo.MemberCount;
            UntypedMember<className, _trackers.objs[MetadataId].classWithMembers.data.classInfo> members[MemberCount];
        }
        (_): std::error(std::format("Unexpected {}", _trackers.objs[MetadataId].objEnum));
    }
};

struct BinaryArray: RecordTypeEnumT<RecordTypeEnum::BinaryArray>{
    s32 ObjectId;
    BinaryArrayTypeEnum binaryArrayTypeEnum;
    s32 Rank;
    s32 Length[Rank];
    if(binaryArrayTypeEnum == BinaryArrayTypeEnum::SingleOffset ||
       binaryArrayTypeEnum == BinaryArrayTypeEnum::JaggedOffset ||
       binaryArrayTypeEnum == BinaryArrayTypeEnum::RectangularOffset)
        s32 LowerBounds[Rank];
    BinaryTypeEnum TypeEnum;
    AdditionalInfo<TypeEnum> additionalInfo;
};

struct ArraySinglePrimitive: RecordTypeEnumT<RecordTypeEnum::ArraySinglePrimitive>{
    ArrayInfo arrayInfo;
    PrimitiveTypeEnum primitiveTypeEnum;
    std::assert(primitiveTypeEnum != PrimitiveTypeEnum::Null &&
                primitiveTypeEnum != PrimitiveTypeEnum::String, "Can't be one of those");
    match(primitiveTypeEnum){
        (PrimitiveTypeEnum::Boolean): bool Values[arrayInfo.Length];
        (PrimitiveTypeEnum::Byte): u8 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Char): char Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Currency): std::error("Primitive currency not used in this protocol");
        (PrimitiveTypeEnum::Decimal): Decimal Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Double): double Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Int16): s16 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Int32): s32 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Int64): s64 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::SByte): s8 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Single): float Value[arrayInfo.Length];
        (PrimitiveTypeEnum::TimeSpan): TimeSpan Value[arrayInfo.Length];
        (PrimitiveTypeEnum::DateTime): DateTime Value[arrayInfo.Length];
        (PrimitiveTypeEnum::UInt16): u16 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::UInt32): u32 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::UInt64): u64 Value[arrayInfo.Length];
        (PrimitiveTypeEnum::Null): {}
        (PrimitiveTypeEnum::String): LengthPrefixedString Value[arrayInfo.Length];
        (_): std::error(std::format("Unexpected {}", primitiveTypeEnum));
    }
};

u64 ArraySinglElementSkipCount = 0;
struct ArraySingleElement<auto _recordTypeEnum>{
    RecordTypeEnum recordTypeEnum = _recordTypeEnum;
    if(ArraySinglElementSkipCount > 0)
        ArraySinglElementSkipCount -= 1;
    else{
        if(recordTypeEnum == RecordTypeEnum::ArraySingleString){
            Record record [[inline]];
            match(record.recordTypeEnum){
                (RecordTypeEnum::ObjectNullMultiple):
                    ArraySinglElementSkipCount = record.objectNullMultiple.NullCount;
                (RecordTypeEnum::ObjectNullMultiple256):
                    ArraySinglElementSkipCount = record.objectNullMultiple256.NullCount;
                (_): {}
            }
        }else{
            Record record [[inline]];
            if(record.recordTypeEnum == RecordTypeEnum::BinaryLibrary){
                Record record2 [[inline]];
                match(record2.recordTypeEnum){
                    (RecordTypeEnum::ObjectNullMultiple):
                        ArraySinglElementSkipCount = record2.objectNullMultiple.NullCount;
                    (RecordTypeEnum::ObjectNullMultiple256):
                        ArraySinglElementSkipCount = record2.objectNullMultiple256.NullCount;
                    (_): {}
                }
            }else{
                match(record.recordTypeEnum){
                    (RecordTypeEnum::ObjectNullMultiple):
                        ArraySinglElementSkipCount = record.objectNullMultiple.NullCount;
                    (RecordTypeEnum::ObjectNullMultiple256):
                        ArraySinglElementSkipCount = record.objectNullMultiple256.NullCount;
                    (_): {}
                }
            }
        }
    }
};

struct ArraySingleObject: RecordTypeEnumT<RecordTypeEnum::ArraySingleObject>{
    ArrayInfo arrayInfo;
    ArraySinglElementSkipCount = 0;
    ArraySingleElement<RecordTypeEnum::ArraySingleObject> records[arrayInfo.Length];
};

struct ArraySingleString: RecordTypeEnumT<RecordTypeEnum::ArraySingleString>{
    ArrayInfo arrayInfo;
    ArraySinglElementSkipCount = 0;
    ArraySingleElement<RecordTypeEnum::ArraySingleString> records[arrayInfo.Length];
};

struct MethodReturnCallArray{
    if(parent.MessageEnum.ReturnValueInArray)
        ArraySingleObject ReturnValue;
    if(parent.MessageEnum.ArgsInArray)
        ArraySingleObject OutputArguments;
    if(parent.MessageEnum.ExceptionInArray)
        ArraySingleObject Exception;
    if(parent.MessageEnum.ContextInArray)
        ArraySingleObject CallContext;
    if(parent.MessageEnum.PropertiesInArray)
        ArraySingleObject MessageProperties;
};

struct MethodCallArray{
    if(parent.MessageEnum.ArgsInArray)
        ArraySingleObject InputArguments;
    if(parent.MessageEnum.GenericMethod)
        ArraySingleObject GenericTypeArguments;
    if(parent.MessageEnum.MethodSignatureInArray)
        ArraySingleObject MethodSignature;
    if(parent.MessageEnum.ContextInArray)
        ArraySingleObject CallContext;
    if(parent.MessageEnum.PropertiesInArray)
        ArraySingleObject MessageProperties;
};

struct BinaryMethodReturn: RecordTypeEnumT<RecordTypeEnum::MethodReturn>{
    MessageFlags MessageEnum;
    std::assert(validate_MessageFlags(MessageEnum) >= 0, "Validation Failed");
    std::assert(!MessageEnum.MethodSignatureInArray && !MessageEnum.GenericMethod, "Can't be one of those");
    if(MessageEnum.ReturnValueInline)
        ValueWithCode ReturnValue;
    if(MessageEnum.ContextInline)
        StringValueWithCode CallContext;
    if(MessageEnum.ArgsInline)
        ArrayOfValueWithCode Args;
    MethodReturnCallArray ReturnCallArray;
};

struct BinaryMethodCall: RecordTypeEnumT<RecordTypeEnum::MethodCall>{
    MessageFlags MessageEnum;
    std::assert(validate_MessageFlags(MessageEnum) >= 0, "Validation Failed");
    std::assert(!MessageEnum.NoReturnValue && !MessageEnum.ReturnValueVoid &&
                !MessageEnum.ReturnValueInline && !MessageEnum.ReturnValueInArray &&
                !MessageEnum.ExceptionInArray, "Can't be one of those");
    StringValueWithCode MethodName;
    StringValueWithCode TypeName;
    if(MessageEnum.ContextInline)
        StringValueWithCode CallContext;
    if(MessageEnum.ArgsInline)
        ArrayOfValueWithCode Args;
    MethodCallArray CallArray;
};

struct MemberPrimitiveTyped: RecordTypeEnumT<RecordTypeEnum::MemberPrimitiveTyped>{
    PrimitiveTypeEnum primitiveTypeEnum;
    std::assert(primitiveTypeEnum != PrimitiveTypeEnum::Null &&
                primitiveTypeEnum != PrimitiveTypeEnum::String, "Can't be one of those");
    match(primitiveTypeEnum){
        (PrimitiveTypeEnum::Boolean): bool Value;
        (PrimitiveTypeEnum::Byte): u8 Value;
        (PrimitiveTypeEnum::Char): char Value;
        (PrimitiveTypeEnum::Currency): std::error("Primitive currency not used in this protocol");
        (PrimitiveTypeEnum::Decimal): Decimal Value;
        (PrimitiveTypeEnum::Double): double Value;
        (PrimitiveTypeEnum::Int16): s16 Value;
        (PrimitiveTypeEnum::Int32): s32 Value;
        (PrimitiveTypeEnum::Int64): s64 Value;
        (PrimitiveTypeEnum::SByte): s8 Value;
        (PrimitiveTypeEnum::Single): float Value;
        (PrimitiveTypeEnum::TimeSpan): TimeSpan Value;
        (PrimitiveTypeEnum::DateTime): DateTime Value;
        (PrimitiveTypeEnum::UInt16): u16 Value;
        (PrimitiveTypeEnum::UInt32): u32 Value;
        (PrimitiveTypeEnum::UInt64): u64 Value;
        (_): std::error(std::format("Unexpected {}", primitiveTypeEnum));
    }
};

struct MemberPrimitiveUnTyped<auto PrimitiveType>{
    match(PrimitiveType){
        (PrimitiveTypeEnum::Boolean): bool Value;
        (PrimitiveTypeEnum::Byte): u8 Value;
        (PrimitiveTypeEnum::Char): char Value;
        (PrimitiveTypeEnum::Currency): std::error("Primitive currency not used in this protocol");
        (PrimitiveTypeEnum::Decimal): Decimal Value;
        (PrimitiveTypeEnum::Double): double Value;
        (PrimitiveTypeEnum::Int16): s16 Value;
        (PrimitiveTypeEnum::Int32): s32 Value;
        (PrimitiveTypeEnum::Int64): s64 Value;
        (PrimitiveTypeEnum::SByte): s8 Value;
        (PrimitiveTypeEnum::Single): float Value;
        (PrimitiveTypeEnum::TimeSpan): TimeSpan Value;
        (PrimitiveTypeEnum::DateTime): DateTime Value;
        (PrimitiveTypeEnum::UInt16): u16 Value;
        (PrimitiveTypeEnum::UInt32): u32 Value;
        (PrimitiveTypeEnum::UInt64): u64 Value;
        (PrimitiveTypeEnum::Null): {}
        (PrimitiveTypeEnum::String):std::error("Can't be String");
        (_): std::error(std::format("Unexpected {}", PrimitiveType));
    }
};

struct MemberReference: RecordTypeEnumT<RecordTypeEnum::MemberReference>{
    s32 IdRef;
};

struct ObjectNull: RecordTypeEnumT<RecordTypeEnum::ObjectNull>{
};

struct ObjectNullMultiple: RecordTypeEnumT<RecordTypeEnum::ObjectNullMultiple>{
    s32 NullCount;
};

struct ObjectNullMultiple256: RecordTypeEnumT<RecordTypeEnum::ObjectNullMultiple256>{
    u8 NullCount;
};

struct BinaryObjectString: RecordTypeEnumT<RecordTypeEnum::BinaryObjectString>{
    s32 ObjectId;
    LengthPrefixedString Value;
};

struct SerializationHeaderRecord: RecordTypeEnumT<RecordTypeEnum::SerializedStreamHeader>{
    s32 RootId;
    s32 HeaderId;
    s32 MajorVersion;
    std::assert_warn(MajorVersion == 1, "MajorVersion should be 1");
    s32 MinorVersion;
    std::assert_warn(MinorVersion == 0, "MinorVersion should be 0");
};

struct BinaryLibrary: RecordTypeEnumT<RecordTypeEnum::BinaryLibrary>{
    s32 LibraryId;
    LengthPrefixedString LibraryName;
};

struct MessageEnd: RecordTypeEnumT<RecordTypeEnum::MessageEnd>{
};

struct CrossAppDomainMap: RecordTypeEnumT<RecordTypeEnum::CrossAppDomainMap>{
    s32 crossAppDomainArrayIndex;
};

struct CrossAppDomainString: RecordTypeEnumT<RecordTypeEnum::CrossAppDomainString>{
    s32 ObjectId;
    s32 Value;
};

struct CrossAppDomainAssembly: RecordTypeEnumT<RecordTypeEnum::CrossAppDomainAssembly>{
    s32 LibraryId;
    s32 LibraryIndex;
};

struct Record{
    RecordTypeEnum recordTypeEnum [[no_unique_address, hidden]];
    match(recordTypeEnum){
        (RecordTypeEnum::SerializedStreamHeader):
            std::error("SerializationStreamHeader can only appear at the top of the document");
        (RecordTypeEnum::ClassWithId): { /* RecordTypeEnum::Object */
            ClassWithId classWithId;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::ClassWithId;
                _trackers.currentObj.RawPtr = append_value_to_section(classWithId, _TrackersSection);
                _trackers.currentObj.TypeName.pointerValue = _trackers.objs[classWithId.MetadataId].TypeName.pointerValue;
                _trackers.currentObj.AssemblyName.pointerValue =_trackers.objs[classWithId.MetadataId].AssemblyName.pointerValue ;
                if(classWithId.ObjectId != 0)
                    copyCurrObjAtIdTrackers(classWithId.ObjectId);
            }
        }
        (RecordTypeEnum::SystemClassWithMembers): { /* RecordTypeEnum::ObjectWithMap */
            SystemClassWithMembers systemClassWithMembers;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::SystemClassWithMembers;
                _trackers.currentObj.RawPtr = append_value_to_section(systemClassWithMembers, _TrackersSection);
                _trackers.currentObj.TypeName.pointerValue = _trackers.currentObj.RawPtr + offsetOf(systemClassWithMembers, systemClassWithMembers.classInfo.Name);
                if(systemClassWithMembers.classInfo.ObjectId != 0)
                    copyCurrObjAtIdTrackers(systemClassWithMembers.classInfo.ObjectId);
            }
        }
        (RecordTypeEnum::ClassWithMembers): { /* RecordTypeEnum::ObjectWithMapAssemId */
            ClassWithMembers classWithMembers;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::ClassWithMembers;
                _trackers.currentObj.RawPtr = append_value_to_section(classWithMembers, _TrackersSection);
                _trackers.currentObj.TypeName.pointerValue = _trackers.currentObj.RawPtr + offsetOf(classWithMembers, classWithMembers.classInfo.Name);
                _trackers.currentObj.AssemblyName.pointerValue = _trackers.libs[classWithMembers.LibraryId].pointerValue;
                if(classWithMembers.classInfo.ObjectId != 0)
                    copyCurrObjAtIdTrackers(classWithMembers.classInfo.ObjectId);
            }
        }
        (RecordTypeEnum::SystemClassWithMembersAndTypes): { /* RecordTypeEnum::ObjectWithMapTyped */
            SystemClassWithMembersAndTypes systemClassWithMembersAndTypes;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::SystemClassWithMembersAndTypes;
                _trackers.currentObj.RawPtr = append_value_to_section(systemClassWithMembersAndTypes, _TrackersSection);
                _trackers.currentObj.TypeName.pointerValue = _trackers.currentObj.RawPtr + offsetOf(systemClassWithMembersAndTypes, systemClassWithMembersAndTypes.classInfo.Name);
                if(systemClassWithMembersAndTypes.classInfo.ObjectId != 0)
                    copyCurrObjAtIdTrackers(systemClassWithMembersAndTypes.classInfo.ObjectId);
            }
        }
        (RecordTypeEnum::ClassWithMembersAndTypes): { /* RecordTypeEnum::ObjectWithMapTypedAssemId */
            ClassWithMembersAndTypes classWithMembersAndTypes;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::ClassWithMembersAndTypes;
                _trackers.currentObj.RawPtr = append_value_to_section(classWithMembersAndTypes, _TrackersSection);
                _trackers.currentObj.TypeName.pointerValue = _trackers.currentObj.RawPtr + offsetOf(classWithMembersAndTypes, classWithMembersAndTypes.classInfo.Name);
                _trackers.currentObj.AssemblyName.pointerValue = _trackers.libs[classWithMembersAndTypes.LibraryId].pointerValue;
                if(classWithMembersAndTypes.classInfo.ObjectId != 0)
                    copyCurrObjAtIdTrackers(classWithMembersAndTypes.classInfo.ObjectId);
            }
        }
        (RecordTypeEnum::BinaryObjectString): { /* RecordTypeEnum::ObjectString */
            BinaryObjectString binaryObjectString;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::BinaryObjectString;
                _trackers.currentObj.RawPtr = append_value_to_section(binaryObjectString, _TrackersSection);
                if(binaryObjectString.ObjectId != 0)
                    copyCurrObjAtIdTrackers(binaryObjectString.ObjectId);
            }
        }
        (RecordTypeEnum::BinaryArray): { /* RecordTypeEnum::Array */
            BinaryArray binaryArray;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::BinaryArray;
                _trackers.currentObj.RawPtr = append_value_to_section(binaryArray, _TrackersSection);
                if(binaryArray.ObjectId != 0)
                    copyCurrObjAtIdTrackers(binaryArray.ObjectId);
            }
        }
        (RecordTypeEnum::MemberPrimitiveTyped): {
            MemberPrimitiveTyped memberPrimitiveTyped;
        }
        (RecordTypeEnum::MemberReference): {
            MemberReference memberReference;
        }
        (RecordTypeEnum::ObjectNull): {}
        (RecordTypeEnum::MessageEnd): break;
        (RecordTypeEnum::BinaryLibrary): { /* RecordTypeEnum::Assembly */
            BinaryLibrary library;
            if(!IsUpdatingTrackers)
                _trackers.libs[library.LibraryId].pointerValue = append_value_to_section(library.LibraryName, _TrackersSection);
        }
        (RecordTypeEnum::ObjectNullMultiple256): {
            ObjectNullMultiple256 objectNullMultiple256;
        }
        (RecordTypeEnum::ObjectNullMultiple): {
            ObjectNullMultiple objectNullMultiple;
        }
        (RecordTypeEnum::ArraySinglePrimitive): {
            ArraySinglePrimitive arraySinglePrimitive;
            if(!IsUpdatingTrackers){
                zeroedCurrObjTrackers();
                _trackers.currentObj.objEnum = _ObjEnum::ArraySinglePrimitive;
                _trackers.currentObj.RawPtr = append_value_to_section(arraySinglePrimitive, _TrackersSection);
                if(arraySinglePrimitive.arrayInfo.ObjectId != 0)
                    copyCurrObjAtIdTrackers(arraySinglePrimitive.arrayInfo.ObjectId);
            }
        }
        (RecordTypeEnum::ArraySingleObject): {
            ArraySingleObject arraySingleObject;
        }
        (RecordTypeEnum::ArraySingleString): {
            ArraySingleString arraySingleString;
        }
        (RecordTypeEnum::CrossAppDomainMap):
            CrossAppDomainMap crossAppDomainMap;
        (RecordTypeEnum::CrossAppDomainString):
            CrossAppDomainString crossAppDomainString;
        (RecordTypeEnum::CrossAppDomainAssembly):
            CrossAppDomainAssembly crossAppDomainAssembly;
        (RecordTypeEnum::MethodCall): {
            BinaryMethodCall binaryMethodCall;
        }
        (RecordTypeEnum::MethodReturn): {
            BinaryMethodReturn binaryMethodReturn;
        }
        (_): std::error(std::format("Unrecognized {}", recordTypeEnum));
    }
};

struct DotNetBinnaryFormatter{
    SerializationHeaderRecord Header;
    Record records[while(std::mem::read_unsigned($, 1) != RecordTypeEnum::MessageEnd)];
    MessageEnd End;
    if(!IsUpdatingTrackers && NeedUpdateTrackers){
        IsUpdatingTrackers = true;
        _Trackers _trackers @ 0x0 in _TrackersSection;
        IsUpdatingTrackers = false;
        NeedUpdateTrackers = false;
    }
};

struct _ObjTracker{
    _Ptr<LengthPrefixedString, u64> TypeName;
    _Ptr<LengthPrefixedString, u64> AssemblyName;
    _ObjEnum objEnum;
    u64 RawPtr [[no_unique_address]];
    /* Only enable the one we actually use to avoid significant slow down */
    match(objEnum){
        (_ObjEnum::Empty):
            u64 ptr;
        /*
        (_ObjEnum::ClassWithId): // _ObjEnum::Object
            _Ptr<ClassWithId, u64> classWithId;
        */
        (_ObjEnum::SystemClassWithMembers): // _ObjEnum::ObjectWithMap
            _Ptr<SystemClassWithMembers, u64> systemClassWithMembers;
        (_ObjEnum::ClassWithMembers): // _ObjEnum::ObjectWithMapAssemId
            _Ptr<ClassWithMembers, u64> classWithMembers;
        (_ObjEnum::SystemClassWithMembersAndTypes): // _ObjEnum::ObjectWithMapTyped
            _Ptr<SystemClassWithMembersAndTypes, u64> systemClassWithMemberAndTypes;
        (_ObjEnum::ClassWithMembersAndTypes): // _ObjEnum::ObjectWithMapTypedAssemId
            _Ptr<ClassWithMembersAndTypes, u64> classWithMembersAndTypes;
        /*
        (_ObjEnum::BinaryObjectString): // _ObjEnum::ObjectString
            _Ptr<BinaryObjectString, u64> binaryObjectString;
        (_ObjEnum::BinaryArray): // _ObjEnum::Array
            _Ptr<BinaryArray, u64> binaryArray;
        (_ObjEnum::MemberPrimitiveTyped):
            _Ptr<MemberPrimitiveTyped, u64> memberPrimitiveTyped;
        (_ObjEnum::MemberReference):
            _Ptr<MemberReference, u64> memberReference;
        (_ObjEnum::BinaryLibrary): // _ObjEnum::Assembly
            _Ptr<BinaryLibrary, u64> library;
        (_ObjEnum::ObjectNullMultiple256):
            _Ptr<ObjectNullMultiple256, u64> objectNullMultiple256;
        (_ObjEnum::ObjectNullMultiple):
            _Ptr<ObjectNullMultiple, u64> objectNullMultiple;
        (_ObjEnum::ArraySinglePrimitive):
            _Ptr<ArraySinglePrimitive, u64> arraySinglePrimitive;
        (_ObjEnum::ArraySingleObject):
            _Ptr<ArraySingleObject, u64> arraySingleObject;
        (_ObjEnum::ArraySingleString):
            _Ptr<ArraySingleString, u64> arraySingleString;
        (_ObjEnum::CrossAppDomainMap):
            _Ptr<CrossAppDomainMap, u64> crossAppDomainMap;
        (_ObjEnum::CrossAppDomainString):
            _Ptr<CrossAppDomainString, u64> crossAppDomainString;
        (_ObjEnum::CrossAppDomainAssembly):
            _Ptr<CrossAppDomainAssembly, u64> crossAppDomainAssembly;
        (_ObjEnum::MethodCall):
            _Ptr<BinaryMethodCall, u64> binaryMethodCall;
        (_ObjEnum::MethodReturn):
            _Ptr<BinaryMethodReturn, u64> binaryMethodReturn;
        */
        (_): u64 ptr; //std::error(std::format("Unexpected {}", objEnum));
    }
};

/* Should be an In variable with default non zero value in the future until we use a hash map */
#define _OBJECTS_TRACKER_CNT 232
#define _LIBRARIES_CNT 8

struct _Trackers{
    _ObjTracker currentObj;
    /* TODO: this should really be an hash map, the algorithm that generated is unspecified */
    _ObjTracker objs[_OBJECTS_TRACKER_CNT];
    _Ptr<LengthPrefixedString, u64> libs[_LIBRARIES_CNT];
};

std::mem::set_section_size(_TrackersSection, sizeof(_trackers));

DotNetBinnaryFormatter dotNetBinnaryFormatter @ 0x0;
