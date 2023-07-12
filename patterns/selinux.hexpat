#include <std/sys.pat>
#pragma pattern_limit 13107200
#pragma endian little

u32 version;
u32 symbols_count;
u32 object_contexts_count;
u32 type_primary_names_count = 0;
bool boundary_feature;

using Header;

enum magics: u32 {
    kernel = 0xf97cff8c,
    module = 0xf97cff8d,
};


enum policy_types: u32 {
    kernel = 0,
    base = 1,
    module = 2,
};

policy_types type_g;

enum targets: u32 {
    selinux = 0,
    xen = 1,
};

targets target;

struct list<T> {
    u32 count;
    T item[count];
};

struct symbols_list<T> {
    u32 primary_names_count;
    list<T> [[inline]];
};



struct permission {
    u32 length;
    u32 value;
    char key[length];
};


struct extensible_bitmap_node {
    u32 startbit;
    u64 map;
};
struct extensible_bitmap {
    u32 mapsize;
    std::assert(mapsize == 0x40 , "Incorrect mapsize");
    u32 highbit;
    std::assert(!(highbit & 0x3F) , "Incorrect highbit");
    u32 count;
    std::assert(!((highbit > 0) && (count == 0)) , "Incorrect bitmap");
    extensible_bitmap_node node[count];
};


struct type_set {
    extensible_bitmap types;
    extensible_bitmap negset;
    u32 flag;
};

enum expression_types: u32 {
    not = 1,
    and = 2,
    or = 3,
    attr = 4,
    names = 5,
};

struct expression {
    expression_types type_;
    u32 attribute;
    u32 operator;
    if (type_ == expression_types::names) {
        extensible_bitmap names;
    if ((type_g == policy_types::kernel && version >= 29) ||
        (type_g != policy_types::kernel))
        type_set type_names;
    } 
};

struct constraint {
    u32 permissions;
    list<expression> [[inline]];
};

struct mls_range {
    u32 items;
    u32 sensitivity0;
    if (items > 1)
        u32 sensitivity1;
    extensible_bitmap category0;
    if (items > 1)
        extensible_bitmap category1;
};

struct role_set {
    extensible_bitmap roles;
    u32 flags;
};

struct mls_level {
    u32 sensitivity;
    extensible_bitmap category;
};

struct semantic_category {
    u32 low;
    u32 high;
};

struct mls_semantic_level {
    u32 sensitivity;
    list<semantic_category> [[inline]];
};

struct mls_semantic_range {
    mls_semantic_level level0;
    mls_semantic_level level1;
};


struct context_s {
    u32 user;
    u32 role;
    u32 type_;
    if (((type_g == policy_types::kernel) && (version >= 19)) || ((type_g == policy_types::base) && (version >= 5)))
        mls_range mls_range;
};


struct common {
    u32 length;
    u32 value;
    u32 primary_names_count;
    u32 elements_count;
    char key[length];
    permission permission[elements_count];
};
using commons = symbols_list<common>;

struct class {
    u32 key_length;
    u32 common_key_length;
    u32 value;
    u32 primary_names_count;
    u32 elements_count;
    u32 constraints_count;
    char key[key_length];
    char common_key[common_key_length];
    permission permissions[elements_count];
    constraint constraints[constraints_count];
    if (((type_g == policy_types::kernel) && (version >= 19)) || (type_g == policy_types::base && version >= 5))
    u32 validatetrans_count;
    if ((type_g == policy_types::kernel && version >= 19) || (type_g == policy_types::base && version >= 5))
    constraint validatetrans[validatetrans_count];
    if  ((type_g == policy_types::kernel && version >= 27) || (type_g == policy_types::base && version >= 15)) {
        u32 default_user;
        u32 default_role;
        u32 default_range;
    }
    if ((type_g == policy_types::kernel && version >= 28) || (type_g == policy_types::base && version >= 16))
        u32 default_type;
};
using classes = symbols_list<class>;


struct role_s {
    u32 length;
    u32 value;
    u32 bounds;
    char key[length];
    extensible_bitmap dominates;
    if (type_g == policy_types::kernel)
        extensible_bitmap types;
    else
        type_set types;
    if ((type_g != policy_types::kernel && version >= 13)) {
        u32 flavor;
        extensible_bitmap roles;
    }
};
using roles = symbols_list<role_s>;


struct type_s {
    u32 length;
    u32 value;
    if ((boundary_feature && (type_g != policy_types::kernel && version >= 10)) || !boundary_feature)
        u32 primary;
    if (boundary_feature) {
        u32 properties;
        u32 bounds;
    }
    if (!boundary_feature && (type_g != policy_types::kernel))
        u32 flavor;
    if (!boundary_feature && (type_g != policy_types::kernel && version >= 8))
        u32 flags;
    if (type_g != policy_types::kernel)
        extensible_bitmap types;
    char key[length];
};
struct types_s {
    u32 primary_names_count;
    type_primary_names_count = primary_names_count;
    list<type_s> [[inline]];
};

struct user_s {
    u32 length;
    u32 value;
    if (boundary_feature)
        u32 bounds;
    char key[length];
    
    if (type_g == policy_types::kernel)
        extensible_bitmap roles;
    else
        role_set roles;
    
    if ((type_g == policy_types::kernel && version >= 19) || (type_g == policy_types::module && version >= 5 && version < 6) || (type_g == policy_types::base && version >= 5 && version < 6)) {
        mls_range exp_range;
        mls_level exp_dftlevel;
    }

    if ((type_g == policy_types::module || type_g == policy_types::base) && (version >= 6)) {
        mls_semantic_range range;
        mls_semantic_range dfltlevel;
    }
};
using users = symbols_list<user_s>;

struct bool_ { // conditional boolean
    u32 value;
    u32 state;
    u32 length;
    char key[length];
    if ((type_g != policy_types::kernel && version >= 14)) 
        u32 flags;
};
using bools = symbols_list<bool_>;

struct level {
    u32 length;
    u32 isalias;
    char key[length];
    mls_level level;
};
using sensitivity_levels = symbols_list<level>;

struct category {
    u32 length;
    u32 value;
    u32 isalias;
    char key[length];
};
using categories = symbols_list<category>;


struct symbols {
    commons commons;
    classes classes;
    roles roles;
    types_s types;
    users users;
    if (symbols_count >= 6)
        bools bools;
    if (symbols_count >= 7)
        sensitivity_levels levels; 
    if (symbols_count >= 8)
        categories cats;
};

struct module_header {
    u32 name_length;
    std::assert(name_length >= 1, "Invalid 'name_length' in module header.");
    char name[name_length];
    u32 version_length;
    std::assert(version_length >= 1, "Invalid 'version_length' in module header.");
    char version[version_length];
};


struct access_vector_old {
    u32 total;
    u32 source_type;
    u32 target_type;
    u32 target_class;
    u32 value;
    u32 data[8];
};
struct access_vector {
    u16 source_type;
    u16 target_type;
    u16 target_class;
    u16 specified;

    if ((specified & 0x700) != 0) {
        u8 xperms_specified;
        u8 xperms_drivers;
        u32 xperms_perms[8];
    }
    else
        u32 data;
};



struct avrule_item {
    u32 tclass;
    u32 data;
};
struct avrule {
    u32 specified;
    u32 flags;
    type_set stypes;
    type_set ttypes;

    u32 length;
    avrule_item avrule_item[length];

    if ((specified & (0x0100 | 0x0200 | 0x0400 | 0x0800)) != 0) {
        u8 xperms_specified;
        u8 xperms_driver;

        list<u32> perms[[inline]];
    }
};
struct avrule_list {
    u32 length;
    avrule avrule[length];
};


struct conditional_node_item {
    u32 expr_type;
    u32 boolean;
};

struct access_vector_table_s {
    if (version < 20)
        list<access_vector_old> access_vector_table;
    else
        list<access_vector> access_vector_table;
} [[inline]];

using cond_av_list = access_vector_table_s;

struct conditional_node {
    u32 current_state;
    u32 length;
    conditional_node_item item[length];

    if (type_g == policy_types::kernel) {
        cond_av_list true_list;
        cond_av_list false_list;
    } else {
        avrule_list avtrue_list;
        avrule_list avfalse_list;
        if (version >= 14)
            u32 flags;
    }
};
struct conditional_list {
    u32 length;
    conditional_node conditional_node[length];
};


struct role_trans_item {
    u32 role;
    u32 type_;
    u32 new_role;
    if (type_g == policy_types::kernel && version >= 26)
        u32 tclass;
};
using role_trans = list<role_trans_item>;

struct role_allow_item {
    u32 role;
    u32 new_role;
};
using role_allow = list<role_allow_item>;

struct filename_trans_item_old {
    u32 length;
    char name[length];
    u32 stype;
    u32 ttype;
    u32 tclass;
    u32 otype;
};
struct filename_trans_item_item {
    extensible_bitmap stypes;
    u32 otype;
};
struct filename_trans_item {
    u32 length;
    char name[length];
    u32 ttype;
    u32 tclass;
    list<filename_trans_item_item> types [[inline]];
};


struct role_trans_rule_item {
    role_set roles;
    role_set types;
    if (version >= 12) 
        extensible_bitmap classes;
    u32 new_role;
};
using role_trans_rule = list<role_trans_rule_item>;

struct  role_allow_rule_item {
    role_set roles;
    role_set new_roles;
};
using role_allow_rule = list<role_allow_rule_item>;


struct scope_s {
    u32 length;
    char key[length];

    u32 scope;

    u32 decl_ids_len;
    std::assert(decl_ids_len >= 1, "Invalid 'decl_ids_len'");
    u32 decl_id[decl_ids_len];
};
struct scope_index {
    extensible_bitmap scope[symbols_count];
    u32 class_perms_len;
    extensible_bitmap class_perms_map[class_perms_len];
};
using scope_list = list<scope_s>;


struct filename_trans_rule_item {
    u32 length;
    char name[length];
    type_set stypes;
    type_set ttypes;
    u32 tclass;
    u32 otype;

    if (version >= 21) 
        u32 flags;
};
using filename_trans_rule = list<filename_trans_rule_item>;


struct range_trans_rule_item {
    type_set stypes;
    type_set ttypes;
    extensible_bitmap tclasses;
    mls_semantic_range trange;
};
using range_trans_rule = list<range_trans_rule_item>;

struct avrule_decl {
    u32 decl_id;
    u32 enabled;
    conditional_list cond_list;
    avrule_list avrules;
    role_trans_rule role_tr_rules;
    role_allow_rule role_allow_rules;

    if (version >= 11)
        filename_trans_rule filename_trans_rules;

    if (version >= 6)
        range_trans_rule range_tr_rules;
    scope_index required;
    scope_index declared;
    symbols symbols;
};

struct avrule_block_item {
    u32 num_decls;
    if (num_decls > 0)
        avrule_decl avrule_decl[num_decls];
};
using avrule_block = list<avrule_block_item>;


struct initial_sid {
    u32 sid0;
    context_s context0;
};
struct filesystem {
    u32 length;
    char key[length];
    context_s context0;
    context_s context1;
};
struct port {
    u32 protocol;
    u32 low_port;
    u32 high_port;
    context_s context;
};
struct node {
    u32 addr;
    u32 mask;
    context_s context;
};
struct fsuse {
    u32 behavior;
    u32 length;
    char name[length];
    context_s context;
};
struct node6 {
    u32 addr[4];
    u32 mask[4];
    context_s context;
};
struct ibpkey {
    u32 low_pkey;
    u32 high_pkey;
    context_s context;
};
struct ibpendport {
    u32 length;
    u32 port;
    char dev_name[length];
    context_s context;
};


struct ocontext_selinux {
    if (object_contexts_count < 1) break;
    list<initial_sid> initial_sids;
    if (object_contexts_count < 2) break;
    list<filesystem> filesystems;
    if (object_contexts_count < 3) break;
    list<port> ports;
    if (object_contexts_count < 4) break;
    list<filesystem> network_interfaces; // same type
    if (object_contexts_count < 5) break;
    list<node> nodes;
    if (object_contexts_count < 6) break;
    list<fsuse> fsuses;
    if (object_contexts_count < 7) break;
    list<node6> nodes6;
    if (object_contexts_count < 8) break;
    list<ibpkey> ibpkeys;
    if (object_contexts_count < 9) break;
    list<ibpendport> ibpendports;
};


struct xen_isid {
    u32 sid0;
    context_s context0;
};

struct xen_pirq {
    u32 pirq;
    context_s context0;
};

struct xen_ioport {
    u32 low_port;
    u32 high_port;
    context_s context0;
};

struct xen_iomem {
    if (version >= 30) {
        u64 low_iomem;
        u64 high_iomem;
    } else {
        u32 low_iomem;
        u32 high_iomem;
    }
    context_s context;
};

struct xen_pcidevice {
    u32 device;
    context_s context;
};

struct xen_devicetree {
    u32 length;
    char name[length];
    context_s context;
};


struct ocontext_xen {
    if (object_contexts_count < 1) break;
    list<xen_isid> xen_isids;
    if (object_contexts_count < 2) break;
    list<xen_pirq> xen_pirqs;
    if (object_contexts_count < 3) break;
    list<xen_ioport> xen_ioports;
    if (object_contexts_count < 4) break;
    list<xen_iomem> xen_iomems;
    if (object_contexts_count < 5) break;
    list<xen_pcidevice> xen_pcidevices;
    if (object_contexts_count < 6) break;
    list<xen_devicetree> xen_devicetrees;
    if (object_contexts_count < 7) break;
};


struct genfs2_item {
    u32 length;
    char name[length];
    u32 sclass;
    context_s context0;
};
struct genfs_item {
    u32 length;
    char fstype[length];
    list<genfs2_item> [[inline]];
};

struct range_item {
    u32 source_type;
    u32 target_type;
    if (type_g == policy_types::kernel && version >= 21)
        u32 target_class;
    mls_range range_tr;
};

struct Header {
    magics magic;
    std::assert(magic == magics::kernel || magic == magics::module , "Unexpected magic");
    u32 policydb_str_len;
    char policydb_str[policydb_str_len];
    std::assert(policydb_str == "SE Linux" || policydb_str == "SE Linux Module" || policydb_str == "XenFlask", "Unexpected signature");
    if (policydb_str == "XenFlask")
        target = targets::xen;
    else
        target = targets::selinux;
    std::assert((magic == magics::kernel && (policydb_str == "SE Linux" || policydb_str == "XenFlask"))
        || (magic == magics::module && policydb_str == "SE Linux Module"), "Non matching magic and signature");
    if (magic == magics::module)
        u32 policy_subtype;
    if (magic == magics::kernel)
        type_g = policy_types::kernel;
    else
    if (policy_subtype == policy_types::module) 
        type_g = policy_types::module;
    else
        type_g = policy_types::base;        
    u32 __policyvers;
    version = __policyvers;
    boundary_feature = (type_g == policy_types::kernel && version >= 24) || (type_g != policy_types::kernel && version >= 9);
    std::assert((magic == magics::kernel && 15 <= version && version <= 33) || (magic != magics::kernel && 4 <= version && version <= 21), "Non matching type_g != and type");
    u32 config;
    u32 symbols_count_;
    symbols_count = symbols_count_;
    std::assert(0 <= symbols_count && symbols_count <= 9, "Invalid 'symbols_count' value.");
    u32 object_contexts_count_; 
    object_contexts_count = object_contexts_count_;
    std::assert(0 <= object_contexts_count && object_contexts_count <= 9, "Invalid 'object_contexts_count' value.");
    if (magic == magics::module)
        module_header module_header;

    if ((type_g == policy_types::kernel && version >= 22) || (version >= 7))
        extensible_bitmap policycaps;
    if (type_g == policy_types::kernel && version >= 23)
        extensible_bitmap permissive_map;
    symbols symbols;
    if (type_g == policy_types::kernel) {
        access_vector_table_s access_vector_table;
    }
    if (type_g == policy_types::kernel && version >= 16)
        conditional_list conditional_list;
    if (type_g == policy_types::kernel) {
        role_trans role_trans;
        role_allow role_allow;
        if (version >= 25) {
            if (version < 33)
                list<filename_trans_item_old> filename_trans;
            else
                list<filename_trans_item> filename_trans;
        }
    } else {
        list<avrule_block_item> avrule_block;
        list<scope_s> scope_list[symbols_count];
    }
    if (target == targets::selinux)
        ocontext_selinux ocontext_selinux;
    else
        ocontext_xen ocontext_xen;
    list<genfs_item> genfs;
    if (((type_g == policy_types::kernel) && (version >= 19)) || ((type_g == policy_types::base) && (version == 5)))
        list<range_item> range;
    if (type_g == policy_types::kernel)
        extensible_bitmap type_attr_map[type_primary_names_count];
};


Header header @ 0;
