#pragma author Calcoph
#pragma description ESRI shapefile
#pragma magic [ 00 00 27 0A ] @ 0x00

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

struct NullShape {
};

struct Point {
    double x;
    double y;
};

struct MultiPoint {
    double box[4];
    u32 num_points;
    Point points[num_point];
};

struct PolyLine {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
};

struct Polygon {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
};

struct PointM {
    double x;
    double y;
    double m;
};

struct MultiPointM {
    double box[4];
    u32 num_points;
    Point points[num_point];
    double m_range[2];
    double m_array[num_points];
};

struct PolyLineM {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
    double m_range[2];
    double m_array[num_points];
};

struct PolygonM {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
    double m_range[2];
    double m_array[num_points];
};


struct PointZ {
    double x;
    double y;
    double z;
    double m;
};

struct MultiPointZ {
    double box[4];
    u32 num_points;
    Point points[num_point];
    double z_range[2];
    double z_array[num_points];
    double m_range[2];
    double m_array[num_points];
};

struct PolyLineZ {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
    double z_range[2];
    double z_array[num_points];
    double m_range[2];
    double m_array[num_points];
};

struct PolygonZ {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    Point points[num_points];
    double z_range[2];
    double z_array[num_points];
    double m_range[2];
    double m_array[num_points];
};

enum PartType: u32 {
    TriangleStrip = 0,
    TriangleFan = 1,
    OuterRing = 2,
    InnerRing = 3,
    FirstRing = 4,
    Ring = 5,
};

struct MultiPatch {
    double box[4];
    u32 num_parts;
    u32 num_points;
    u32 parts[num_parts];
    PartType part_types[num_parts];
    Point points[num_points];
    double z_range[2];
    double z_array[num_points];
    double m_range[2];
    double m_array[num_points];
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

struct RecordHeader {
    be u32 record_number; // starting at 1
    be u32 content_length; // in 16-bit words
};


struct Record {
    RecordHeader;
    ShapeType shape_type;
    match (shape_type) {
        (ShapeType::Null): NullShape;
        (ShapeType::Point): Point;
        (ShapeType::PolyLine): PolyLine;
        (ShapeType::Polygon): Polygon;
        (ShapeType::MultiPoint): MultiPoint;
        (ShapeType::PointZ): PointZ;
        (ShapeType::PolyLineZ): PolyLineZ;
        (ShapeType::PolygonZ): PolygonZ;
        (ShapeType::MultiPointZ): MultiPointZ;
        (ShapeType::PointM): PointM;
        (ShapeType::PolyLineM): PolyLineM;
        (ShapeType::PolygonM): PolygonM;
        (ShapeType::MultiPointM): MultiPointM;
        (ShapeType::MultiPatch): MultiPatch;
    }
};

struct ShapeFile {
    Header header;
    Record records[while ($ < (header.file_length * 2))];
};

ShapeFile file @ 0x00;
