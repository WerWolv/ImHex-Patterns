struct Cluster {
    u16 x;
    u16 y;
    padding[2];
    u16 type;
    padding[8];
};

struct Node {
    u16 x;
    u16 y;
    padding[2];
    u16;
    u16 cluster;
    u16;
};

struct Link{
    u16 node_a_idx;
    u16 node_b_idx;
    u16 anchor_idx;
    
    // Technically, [[export]] works on local variables
    // so we could do Node a = parent.nodes[node_a_idx];
    // In practice, the pattern data view gets messed up
    Node a @ addressof(parent.nodes[node_a_idx]);
    Node b @ addressof(parent.nodes[node_b_idx]);
    if (anchor_idx != 0xFFFF) Node anchor @ addressof(parent.nodes[anchor_idx]);
    
    padding[2];
};

struct Header {
    padding[2];
    u16 cluster_count;
    u16 node_count;
    u16 link_count;
    padding[8];
};

// We need to group everything in a struct
// because it's too annoying to calculate
// the start and end offsets of each block 
struct Data {
    Header header;
    Cluster clusters[header.cluster_count];
    Node nodes[header.node_count];
    Link links[header.link_count];
};

Data data @ 0x0;