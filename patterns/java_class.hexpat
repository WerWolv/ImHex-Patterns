#pragma endian big
#pragma MIME application/x-java-applet

#include <std/core.pat>
#include <std/io.pat>
#include <std/sys.pat>

using BitfieldOrder = std::core::BitfieldOrder;

// The Java documentations use the number of bytes instead of the number of bits for its type names
using u1 = u8;
using u2 = u16;
using u4 = u32;

using f4 = float;
using f8 = double;

enum cp_tag : u8 {
    CONSTANT_Utf8               = 1,
    CONSTANT_Integer            = 3,
    CONSTANT_Float              = 4,
    CONSTANT_Long               = 5,
    CONSTANT_Double             = 6,
    CONSTANT_Class              = 7,
    CONSTANT_String             = 8,
    CONSTANT_Fieldref           = 9,
    CONSTANT_Methodref          = 10,
    CONSTANT_InterfaceMethodref = 11,
    CONSTANT_NameAndType        = 12,
    CONSTANT_MethodHandle       = 15,
    CONSTANT_MethodType         = 16,
    CONSTANT_InvokeDynamic      = 18,
    CONSTANT_Module             = 19,
    CONSTANT_Package            = 20
};

enum major_version : u2 {
    JDK_1_1              = 45,
    JDK_1_2              = 46,
    JDK_1_3              = 47,
    JDK_1_4              = 48,

    Java_SE_5_0          = 49,
    Java_SE_6            = 50,
    Java_SE_7            = 51,
    Java_SE_8            = 52,
    Java_SE_9            = 53,
    Java_SE_10           = 54,
    Java_SE_11           = 55,
    Java_SE_12           = 56,
    Java_SE_13           = 57,
    Java_SE_14           = 58,
    Java_SE_15           = 59,
    Java_SE_16           = 60,
    Java_SE_17           = 61,
};

// Tag == CONSTANT_Utf8
struct CONSTANT_Utf8_info {
    u2 length;
    char bytes[length];    // u1 in documentation. Changed to char to improve readability
};

// Tag == CONSTANT_Integer
struct CONSTANT_Integer_info {
    u4 bytes;
};

// Tag == CONSTANT_Float
struct CONSTANT_Float_info {
    f4 bytes; // u4 in documentation. Changed to f4 to improve readablilty
};

// Tag == CONSTANT_Long
struct CONSTANT_Long_info {
    u4 high_bytes;
    u4 low_bytes;
};

// Tag == CONSTANT_Double
struct CONSTANT_Double_info {
    u4 high_bytes;
    u4 low_bytes;
};

// Tag == CONSTANT_Class
struct CONSTANT_Class_info {
    u2 name_index;
};

// Tag == CONSTANT_String
struct CONSTANT_String_info {
    u2 string_index;
};

// Tag == CONSTANT_Fieldref
struct CONSTANT_Fieldref_info {
    u2 class_index;
    u2 name_and_type_index;
};

// Tag == CONSTANT_Methodref
struct CONSTANT_Methodref_info {
    u2 class_index;
    u2 name_and_type_index;
};

// Tag == CONSTANT_InterfaceMethodref
struct CONSTANT_InterfaceMethodref_info {
    u2 class_index;
    u2 name_and_type_index;
};

// Tag == CONSTANT_NameAndType
struct CONSTANT_NameAndType_info {
    u2 name_index;
    u2 descriptor_index;
};

// Tag == CONSTANT_MethodHandle
struct CONSTANT_MethodHandle_info {
    u1 reference_kind;
    u2 reference_index;
};

// Tag == CONSTANT_MethodType
struct CONSTANT_MethodType_info {
    u2 descriptor_index;
};

// Tag == CONSTANT_InvokeDynamic
struct CONSTANT_InvokeDynamic_info {
    u2 bootstrap_method_attr_index;
    u2 name_and_type_index;
};

// Tag == CONSTANT_Module
struct CONSTANT_Module_info {
    u2 name_index;
};

// Tag == CONSTANT_Package
struct CONSTANT_Package_info {
    u2 name_index;
};

// All 8-byte constants take up two entries in the constant_pool table of the class file
u1 padding_entry_flag = 0;

struct cp_info {
    if (padding_entry_flag == 0) {
        cp_tag tag;

        if (tag == cp_tag::CONSTANT_Utf8)
            CONSTANT_Utf8_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Integer)
            CONSTANT_Integer_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Float)
            CONSTANT_Float_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Long) {
            CONSTANT_Long_info info [[inline]];
            padding_entry_flag = 1;
        }
        else if (tag == cp_tag::CONSTANT_Double) {
            CONSTANT_Double_info info [[inline]];
            padding_entry_flag = 1;
        }
        else if (tag == cp_tag::CONSTANT_Class)
            CONSTANT_Class_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_String)
            CONSTANT_String_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Fieldref)
            CONSTANT_Fieldref_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Methodref)
            CONSTANT_Methodref_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_InterfaceMethodref)
            CONSTANT_InterfaceMethodref_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_NameAndType)
            CONSTANT_NameAndType_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_MethodHandle)
            CONSTANT_MethodHandle_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_MethodType)
            CONSTANT_MethodType_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_InvokeDynamic)
            CONSTANT_InvokeDynamic_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Module)
            CONSTANT_Module_info info [[inline]];
        else if (tag == cp_tag::CONSTANT_Package)
            CONSTANT_Package_info info [[inline]];
    } else {
        padding_entry_flag = 0;
    }
};

bitfield access_flags_method  {
    ACC_PUBLIC      : 1;    // 0x0001
    ACC_PRIVATE     : 1;    // 0x0002
    ACC_PROTECTED   : 1;    // 0x0004
    ACC_STATIC      : 1;    // 0x0008
    ACC_FINAL       : 1;    // 0x0010
    ACC_SYNCHRONIZED: 1;    // 0x0020
    ACC_BRIDGE      : 1;    // 0x0040
    ACC_VARARGS     : 1;    // 0x0080
    ACC_NATIVE      : 1;    // 0x0100
    padding         : 1;    // 0x0200
    ACC_ABSTRACT    : 1;    // 0x0400
    ACC_STRICT      : 1;    // 0x0800
    ACC_SYNTHETIC   : 1;    // 0x1000
    padding         : 1;    // 0x2000
    padding         : 1;    // 0x4000
    padding         : 1;    // 0x8000
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];

bitfield access_flags_field  {
    ACC_PUBLIC      : 1;    // 0x0001
    ACC_PRIVATE     : 1;    // 0x0002
    ACC_PROTECTED   : 1;    // 0x0004
    ACC_STATIC      : 1;    // 0x0008
    ACC_FINAL       : 1;    // 0x0010
    padding         : 1;    // 0x0020
    ACC_VOLATILE    : 1;    // 0x0040
    ACC_TRANSIENT   : 1;    // 0x0080
    padding         : 1;    // 0x0100
    padding         : 1;    // 0x0200
    padding         : 1;    // 0x0400
    padding         : 1;    // 0x0800
    ACC_SYNTHETIC   : 1;    // 0x1000
    padding         : 1;    // 0x2000
    ACC_ENUM        : 1;    // 0x4000
    padding         : 1;    // 0x8000
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];

bitfield access_flags_class  {
    ACC_PUBLIC       : 1;    // 0x0001
    padding          : 1;    // 0x0002
    padding          : 1;    // 0x0004
    padding          : 1;    // 0x0008
    ACC_FINAL        : 1;    // 0x0010
    ACC_SUPER        : 1;    // 0x0020
    padding          : 1;    // 0x0040
    padding          : 1;    // 0x0080
    padding          : 1;    // 0x0100
    ACC_INTERFACE    : 1;    // 0x0200
    ACC_ABSTRACT     : 1;    // 0x0400
    padding          : 1;    // 0x0800
    ACC_SYNTHETIC    : 1;    // 0x1000
    ACC_ANNOTATION   : 1;    // 0x2000
    ACC_ENUM         : 1;    // 0x4000
    ACC_MODULE       : 1;    // 0x8000
} [[bitfield_order(BitfieldOrder::LeastToMostSignificant, 16)]];

struct attribute_info {
    u2 attribute_name_info;

    u4 attribute_length;

    u1 info[attribute_length];
};

struct field_info {
    access_flags_field     access_flags;
    u2                     name_index;
    u2                     descriptor_index;

    u2                     attribute_count;
    attribute_info         attributes[attribute_count];
};

struct method_info {
    access_flags_method    access_flags;
    u2                     name_index;
    u2                     descriptor_index;
    u2                     attributes_count;
    attribute_info         attributes[attributes_count];
};

struct ClassFile {
    u4 magic;

    u2                     minor_version;
    major_version          major_version;

    u2                     constant_pool_count;
    cp_info                constant_pool[constant_pool_count - 1];

    access_flags_class     access_flags;
    u2                     this_class;
    u2                     super_class;

    u2                     interfaces_count;
    u2                     interfaces[interfaces_count];

    u2                     fields_count;
    field_info             fields[fields_count];

    u2                     methods_count;
    method_info            methods[methods_count];

    u2                     attribute_count;
    attribute_info         attributes[attribute_count];
};

ClassFile class_file @ 0x00;

fn main() {

    std::assert(class_file.magic == 0xCAFEBABE, "File is not a valid Java Class file! Invalid header magic");


    std::print("Fields:");
    for (le u16 i = 0, i < class_file.fields_count, i = i + 1) {
        str field_string = "  ";

        if (class_file.fields[i].access_flags.ACC_PUBLIC)
            field_string = field_string + "public ";
        if (class_file.fields[i].access_flags.ACC_PRIVATE)
            field_string = field_string + "private ";
        if (class_file.fields[i].access_flags.ACC_PROTECTED)
            field_string = field_string + "protected ";
        if (class_file.fields[i].access_flags.ACC_STATIC)
            field_string = field_string + "static ";
        if (class_file.fields[i].access_flags.ACC_FINAL)
            field_string = field_string + "final ";
        if (class_file.fields[i].access_flags.ACC_VOLATILE)
            field_string = field_string + "volatile ";
        if (class_file.fields[i].access_flags.ACC_TRANSIENT)
            field_string = field_string + "transient ";
        if (class_file.fields[i].access_flags.ACC_ENUM)
            field_string = field_string + "enum ";

        field_string = field_string + class_file.constant_pool[class_file.fields[i].name_index - 1].info.bytes;
        field_string = field_string + " [ " + class_file.constant_pool[class_file.fields[i].descriptor_index - 1].info.bytes + " ]";

        std::print("{}", field_string);
    }

    std::print("Methods:");
    for (le u16 i = 0, i < class_file.methods_count, i = i + 1) {
        str method_string = "  ";

        if (class_file.methods[i].access_flags.ACC_PUBLIC)
            method_string = method_string + "public ";
        if (class_file.methods[i].access_flags.ACC_PRIVATE)
            method_string = method_string + "private ";
        if (class_file.methods[i].access_flags.ACC_PROTECTED)
            method_string = method_string + "protected ";
        if (class_file.methods[i].access_flags.ACC_STATIC)
            method_string = method_string + "static ";
        if (class_file.methods[i].access_flags.ACC_FINAL)
            method_string = method_string + "final ";
        if (class_file.methods[i].access_flags.ACC_SYNCHRONIZED)
            method_string = method_string + "synchronized ";
        if (class_file.methods[i].access_flags.ACC_NATIVE)
            method_string = method_string + "native ";
        if (class_file.methods[i].access_flags.ACC_ABSTRACT)
            method_string = method_string + "abstract ";
        if (class_file.methods[i].access_flags.ACC_STRICT)
            method_string = method_string + "strictfp ";

        method_string = method_string + class_file.constant_pool[class_file.methods[i].name_index - 1].info.bytes;
        method_string = method_string + " [ " + class_file.constant_pool[class_file.methods[i].descriptor_index - 1].info.bytes + " ]";

        std::print("{}", method_string);
    }

    std::print("Class Attributes:");
    for (le u16 i = 0, i < class_file.attribute_count, i = i + 1) {
        std::print("  {}", class_file.constant_pool[class_file.attributes[i].attribute_name_info - 1].info.bytes);
    }
};