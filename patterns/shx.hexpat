#pragma author Calcoph
#pragma description ESRI shapefile indices

// Spec:
// https://www.esri.com/content/dam/esrisites/sitecore-archive/Files/Pdfs/library/whitepapers/pdfs/shapefile.pdf

enum ShapeType: u32 {
    Null = 0,
    Point = 1,
    PolyLine = 3,
    Polygon = 5,
    MultiPoint = 8,
    PointZ = 11,
    PolyLineZ = 13,
    PolygonZ = 15,
    MultiPointZ = 18,
    PointM = 21,
    PolyLineM = 23,
    PolygonM = 25,
    MultiPointM = 28,
    MultiPatch = 32,
};


struct Header {
    be u32 magic; // 9994
    padding[20]; // unused
    be u32 file_length; // in 16-bit words (including header)
    u32 version; // 1000
    ShapeType shape_type;
    // Bounding box
    double bb_xmin;
    double bb_ymin;
    double bb_xmax;
    double bb_ymax;
    double bb_zmin;
    double bb_zmax;
    double bb_mmin;
    double bb_mmax;
};

struct Record  {
    u32 offset;
    u32 content_length;
};

struct IndexFile {
    Header header;
    Record records[while($ < header.file_length * 2)];
};

IndexFile file @ 0x00;
