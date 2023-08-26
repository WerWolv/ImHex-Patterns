#include <std/io.pat>
#include <type/base.pat>

#pragma MIME image/x-3ds

// Heavily based off of ZiZi's 010 Editor 3DS Template
enum ChunkIdentifier : u16 {    
    NULL_CHUNK                            = 0x0000,
    ChunkType                             = 0x0995,
    ChunkUnique                           = 0x0996,
    NotChunk                              = 0x0997,
    Container                             = 0x0998,
    IsChunk                               = 0x0999,

    /* Dummy Chunk that sometimes appears in 3ds files created by prerelease 3D Studio R2 */
    DUMMY                                 = 0xFFFF,

    /* Chunk Types for Open*, Write*, Close* functions */
    POINT_ARRAY_ENTRY                     = 0xF110,
    POINT_FLAG_ARRAY_ENTRY                = 0xF111,
    FACE_ARRAY_ENTRY                      = 0xF120,
    MSH_MAT_GROUP_ENTRY                   = 0xF130,
    TEX_VERTS_ENTRY                       = 0xF140,
    SMOOTH_GROUP_ENTRY                    = 0xF150,
    POS_TRACK_TAG_KEY                     = 0xF020,
    ROT_TRACK_TAG_KEY                     = 0xF021,
    SCL_TRACK_TAG_KEY                     = 0xF022,
    FOV_TRACK_TAG_KEY                     = 0xF023,
    ROLL_TRACK_TAG_KEY                    = 0xF024,
    COL_TRACK_TAG_KEY                     = 0xF025,
    MORPH_TRACK_TAG_KEY                   = 0xF026,
    HOT_TRACK_TAG_KEY                     = 0xF027,
    FALL_TRACK_TAG_KEY                    = 0xF028,

    /* 3DS File Chunk IDs */
    COLOR_F                               = 0x0010, // r,g,b: Single precision float
    COLOR_24                              = 0x0011, // r,g,b: Byte
    LIN_COLOR_24                          = 0x0012, // r,g,b: Byte (gamma corrected)
    LIN_COLOR_F                           = 0x0013, // r,g,b: Single precision float (gamma corrected)
    
    INT_PERCENTAGE                        = 0x0030, // u16 integer
    FLOAT_PERCENTAGE                      = 0x0031, // Single precision float
    
    M3DMAGIC                              = 0x4D4D,
    SMAGIC                                = 0x2D2D,
    LMAGIC                                = 0x2D3D,
    MLIBMAGIC                             = 0x3DAA,
    MATMAGIC                              = 0x3DFF,
        M3D_VERSION                       = 0x0002,
        MDATA                             = 0x3D3D,
            MESH_VERSION                  = 0x3D3E,
            WORLD_VIEWPORT_DATA           = 0x7011,
            WORLD_VIEWPORT_DATA3          = 0x7012,
            WORLD_VIEWPORT_SIZE           = 0x7020,
            WORLD_VIEWPORT_LAYOUT         = 0x7001,
            MASTER_SCALE                  = 0x0100,
            BIT_MAP                       = 0x1100, // Background bitmap filename
            USE_BIT_MAP                   = 0x1101, // Use background bitmap
            SOLID_BGND                    = 0x1200, // Background color
            USE_SOLID_BGND                = 0x1201, // Use background color
            V_GRADIENT                    = 0x1300, // Background gradient colors
            USE_V_GRADIENT                = 0x1301, // Use background gradient colors
            LO_SHADOW_BIAS                = 0x1400,
            HI_SHADOW_BIAS                = 0x1410,
            SHADOW_MAP_SIZE               = 0x1420,
            SHADOW_SAMPLES                = 0x1430,
            SHADOW_RANGE                  = 0x1440,
            SHADOW_FILTER                 = 0x1450,
            RAY_BIAS                      = 0x1460,
            USE_RAYTRACE                  = 0x1470,
            O_CONSTS                      = 0x1500,
    
            AMBIENT_LIGHT                 = 0x2100,

            FOG                           = 0x2200,
            USE_FOG                       = 0x2201,
            FOG_BGND                      = 0x2210,
            DISTANCE_CUE                  = 0x2300,
            USE_DISTANCE_CUE              = 0x2301,
            WORLD_LAYERED_FOG             = 0x2302,
            WORLD_USE_LAYERED_FOG         = 0x2303,
            
            DEFAULT_VIEW                  = 0x3000,
            VIEW_TOP                      = 0x3010,
            VIEW_BOTTOM                   = 0x3020,
            VIEW_LEFT                     = 0x3030,
            VIEW_RIGHT                    = 0x3040,
            VIEW_FRONT                    = 0x3050,
            VIEW_BACK                     = 0x3060,
            VIEW_USER                     = 0x3070,
            VIEW_CAMERA                   = 0x3080,
            VIEW_WINDOW                   = 0x3090,
            
            NAMED_OBJECT                  = 0x4000,
                OBJ_HIDDEN                = 0x4010,
                OBJ_VIS_LOFTER            = 0x4011,
                OBJ_DOESNT_CAST           = 0x4012,
                OBJ_MATTE                 = 0x4013,
                OBJ_FAST                  = 0x4014,
                OBJ_PROCEDURAL            = 0x4015,
                OBJ_FROZEN                = 0x4016,
                OBJ_DONT_RCVSHADOW        = 0x4017,
    
            N_TRI_OBJECT                  = 0x4100,
                POINT_ARRAY               = 0x4110,
                POINT_FLAG_ARRAY          = 0x4111,
                FACE_ARRAY                = 0x4120,
                    MSH_MAT_GROUP         = 0x4130,
                    OLD_MAT_GROUP         = 0x4131,
                    SMOOTH_GROUP          = 0x4150,
                TEX_VERTS                 = 0x4140,
                MESH_MATRIX               = 0x4160,
                MESH_COLOR                = 0x4165,
                MESH_TEXTURE_INFO         = 0x4170,
                PROC_NAME                 = 0x4181,
                PROC_DATA                 = 0x4182,
                MSH_BOXMAP                = 0x4190,

                N_D_L_OLD                 = 0x4400,

                N_CAM_OLD                 = 0x4500,

            N_DIRECT_LIGHT                = 0x4600,
                DL_SPOTLIGHT              = 0x4610,
                    DL_RAYSHAD            = 0x4627,
                    DL_SHADOWED           = 0x4630,
                    DL_LOCAL_SHADOW       = 0x4640,
                    DL_LOCAL_SHADOW2      = 0x4641,
                    DL_SEE_CONE           = 0x4650,
                    DL_SPOT_RECTANGULAR   = 0x4651,
                    DL_SPOT_OVERSHOOT     = 0x4652,
                    DL_SPOT_PROJECTOR     = 0x4653,
                    DL_EXCLUDE            = 0x4654,
                    DL_RANGE              = 0x4655, /* Not used in R3 */ 
                    DL_SPOT_ROLL          = 0x4656,
                    DL_SPOT_ASPECT        = 0x4657,
                    DL_RAY_BIAS           = 0x4658,
                DL_OFF                    = 0x4620,
                DL_ATTENUATE              = 0x4625,
                DL_INNER_RANGE            = 0x4659,
                DL_OUTER_RANGE            = 0x465A,
                DL_MULTIPLIER             = 0x465B,
                
            N_AMBIENT_LIGHT               = 0x4680,
        
            N_CAMERA                      = 0x4700,
            CAM_SEE_CONE                  = 0x4710,
            CAM_RANGES                    = 0x4720,
            
            HIERARCHY                     = 0x4F00,
            PARENT_OBJECT                 = 0x4F10,
            PIVOT_OBJECT                  = 0x4F20,
            PIVOT_LIMITS                  = 0x4F30,
            PIVOT_ORDER                   = 0x4F40,
            XLATE_RANGE                   = 0x4F50,
            
            POLY_2D                       = 0x5000,
            
            /* Flags in shaper file that tell whether polys make up an ok shape */
            SHAPE_OK                      = 0x5010,
            SHAPE_NOT_OK                  = 0x5011,

            SHAPE_HOOK                    = 0x5020,

            PATH_3D                       = 0x6000,
            PATH_MATRIX                   = 0x6005,
            SHAPE_2D                      = 0x6010,
            M_SCALE                       = 0x6020,
            M_TWIST                       = 0x6030,
            M_TEETER                      = 0x6040,
            M_FIT                         = 0x6050,
            M_BEVEL                       = 0x6060,
            XZ_CURVE                      = 0x6070,
            YZ_CURVE                      = 0x6080,
            INTERPCT                      = 0x6090,
            DEFORM_LIMIT                  = 0x60A0,
            
            /* Flags for Modeler options */ 
            USE_CONTOUR                   = 0x6100,
            USE_TWEEN                     = 0x6110,
            USE_SCALE                     = 0x6120,
            USE_TWIST                     = 0x6130,
            USE_TEETER                    = 0x6140,
            USE_FIT                       = 0x6150,
            USE_BEVEL                     = 0x6160,

            /* Viewport description chunks */ 
            VIEWPORT_LAYOUT_OLD           = 0x7000,
            VIEWPORT_DATA_OLD             = 0x7010,
            VIEWPORT_LAYOUT               = 0x7001,
            VIEWPORT_DATA                 = 0x7011,
            VIEWPORT_DATA_3               = 0x7012,
            VIEWPORT_SIZE                 = 0x7020,
            NETWORK_VIEW                  = 0x7030,

            /* External Application Data */ 
            XDATA_SECTION                 = 0x8000,
            XDATA_ENTRY                   = 0x8001,
            XDATA_APPNAME                 = 0x8002,
            XDATA_STRING                  = 0x8003,
            XDATA_FLOAT                   = 0x8004,
            XDATA_DOUBLE                  = 0x8005,
            XDATA_SHORT                   = 0x8006,
            XDATA_LONG                    = 0x8007,
            XDATA_VOID                    = 0x8008,
            XDATA_GROUP                   = 0x8009,
            XDATA_RFU6                    = 0x800A,
            XDATA_RFU5                    = 0x800B,
            XDATA_RFU4                    = 0x800C,
            XDATA_RFU3                    = 0x800D,
            XDATA_RFU2                    = 0x800E,
            XDATA_RFU1                    = 0x800F,

            PARENT_NAME                   = 0x80F0,
            
            /* Material Chunk IDs */ 
            MAT_ENTRY                     = 0xAFFF,
                MAT_NAME                  = 0xA000,
                MAT_AMBIENT               = 0xA010,
                MAT_DIFFUSE               = 0xA020,
                MAT_SPECULAR              = 0xA030,
                MAT_SHININESS             = 0xA040,
                MAT_SHIN2PCT              = 0xA041,
                MAT_SHIN3PCT              = 0xA042,
                MAT_TRANSPARENCY          = 0xA050,
                MAT_XPFALL                = 0xA052,
                MAT_REFBLUR               = 0xA053,
                
                MAT_SELF_ILLUM            = 0xA080,
                MAT_TWO_SIDE              = 0xA081,
                MAT_DECAL                 = 0xA082,
                MAT_ADDITIVE              = 0xA083,
                MAT_SELF_ILPCT            = 0xA084,
                MAT_WIRE                  = 0xA085,
                MAT_SUPERSMP              = 0xA086,
                MAT_WIRESIZE              = 0xA087,
                MAT_FACEMAP               = 0xA088,
                MAT_XPFALLIN              = 0xA08A,
                MAT_PHONGSOFT             = 0xA08C,
                MAT_WIREABS               = 0xA08E,
                
                MAT_SHADING               = 0xA100,
                
                MAT_TEXMAP                = 0xA200,
                    MAT_MAPNAME           = 0xA300,
                    MAT_ACUBIC            = 0xA310,
                    
                    MAT_MAP_TILINGOLD     = 0xA350,
                    MAT_MAP_TILING        = 0xA351,
                    MAT_MAP_TEXBLUR_OLD   = 0xA352,
                    MAT_MAP_TEXBLUR       = 0xA353,
                    MAT_MAP_USCALE        = 0xA354,
                    MAT_MAP_VSCALE        = 0xA356,
                    MAT_MAP_UOFFSET       = 0xA358,
                    MAT_MAP_VOFFSET       = 0xA35A,
                    MAT_MAP_ANG           = 0xA35C,
                    MAT_MAP_COL1          = 0xA360,
                    MAT_MAP_COL2          = 0xA362,
                    MAT_MAP_RCOL          = 0xA364,
                    MAT_MAP_GCOL          = 0xA366,
                    MAT_MAP_BCOL          = 0xA368,
                    
                MAT_SPECMAP               = 0xA204,
                MAT_OPACMAP               = 0xA210,
                MAT_REFLMAP               = 0xA220,
                MAT_BUMPMAP               = 0xA230,
                MAT_USE_REFBLUR           = 0xA250,
                MAT_BUMP_PERCENT          = 0xA252,
                
                MAT_SXP_TEXT_DATA         = 0xA320,
                MAT_SXP_TEXT2_DATA        = 0xA321,
                MAT_SXP_OPAC_DATA         = 0xA322,
                MAT_SXP_BUMP_DATA         = 0xA324,
                MAT_SXP_SPEC_DATA         = 0xA325,
                MAT_SXP_SHIN_DATA         = 0xA326,
                MAT_SXP_SELFI_DATA        = 0xA328,
                MAT_SXP_TEXT_MASKDATA     = 0xA32A,
                MAT_SXP_TEXT2_MASKDATA    = 0xA32C,
                MAT_SXP_OPAC_MASKDATA     = 0xA32E,
                MAT_SXP_BUMP_MASKDATA     = 0xA330,
                MAT_SXP_SPEC_MASKDATA     = 0xA332,
                MAT_SXP_SHIN_MASKDATA     = 0xA334,
                MAT_SXP_SELFI_MASKDATA    = 0xA336,
                MAT_SXP_REFL_MASKDATA     = 0xA338,
                
                MAT_TEX2MAP               = 0xA33A,
                MAT_SHINMAP               = 0xA33C,
                MAT_SELFIMAP              = 0xA33D,
                MAT_TEXMASK               = 0xA33E,
                MAT_TEX2MASK              = 0xA340,
                MAT_OPACMASK              = 0xA342,
                MAT_BUMPMASK              = 0xA344,
                MAT_SHINMASK              = 0xA346,
                MAT_SPECMASK              = 0xA348,
                MAT_SELFIMASK             = 0xA34A,
                MAT_REFLMASK              = 0xA34C,
                
        /* Keyframe Chunk IDs */ 
        KFDATA                            = 0xB000,
            KFHDR                         = 0xB00A,
            AMBIENT_NODE_TAG              = 0xB001,
            OBJECT_NODE_TAG               = 0xB002,
            CAMERA_NODE_TAG               = 0xB003,
            TARGET_NODE_TAG               = 0xB004,
            LIGHT_NODE_TAG                = 0xB005,
            L_TARGET_NODE_TAG             = 0xB006,
            SPOTLIGHT_NODE_TAG            = 0xB007,
            
            KFSEG                         = 0xB008,
            KFCURTIME                     = 0xB009,
            
                NODE_HDR                  = 0xB010,
                INSTANCE_NAME             = 0xB011,
                PRESCALE                  = 0xB012, 
                PIVOT                     = 0xB013,
                BOUNDBOX                  = 0xB014,
                MORPH_SMOOTH              = 0xB015,
                POS_TRACK_TAG             = 0xB020,
                ROT_TRACK_TAG             = 0xB021,
                SCL_TRACK_TAG             = 0xB022,
                FOV_TRACK_TAG             = 0xB023,
                ROLL_TRACK_TAG            = 0xB024,
                COL_TRACK_TAG             = 0xB025,
                MORPH_TRACK_TAG           = 0xB026,
                HOT_TRACK_TAG             = 0xB027,
                FALL_TRACK_TAG            = 0xB028,
                HIDE_TRACK_TAG            = 0xB029,
                NODE_ID                   = 0xB030,
                
    
	CMAGIC                                = 0xC23D,
    
        C_MDRAWER                         = 0xC010,
        C_TDRAWER                         = 0xC020,
        C_SHPDRAWER                       = 0xC030,
        C_MODDRAWER                       = 0xC040,
        C_RIPDRAWER                       = 0xC050,
        C_TXDRAWER                        = 0xC060,
        C_PDRAWER                         = 0xC062,
        C_MTLDRAWER                       = 0xC064,
        C_FLIDRAWER                       = 0xC066,
        C_CUBDRAWER                       = 0xC067,
        C_MFILE                           = 0xC070,
        C_SHPFILE                         = 0xC080,
        C_MODFILE                         = 0xC090,
        C_RIPFILE                         = 0xC0A0,
        C_TXFILE                          = 0xC0B0,
        C_PFILE                           = 0xC0B2,
        C_MTLFILE                         = 0xC0B4,
        C_FLIFILE                         = 0xC0B6,
        C_PALFILE                         = 0xC0B8,
        C_TX_STRING                       = 0xC0C0,
        C_CONSTS                          = 0xC0D0,
        C_SNAPS                           = 0xC0E0,
        C_GRIDS                           = 0xC0F0,
        C_ASNAPS                          = 0xC100,
        C_GRID_RANGE                      = 0xC110,
        C_RENDTYPE                        = 0xC120,
        C_PROGMODE                        = 0xC130,
        C_PREVMODE                        = 0xC140,
        C_MODWMODE                        = 0xC150,
        C_MODMODEL                        = 0xC160,
        C_ALL_LINES                       = 0xC170,
        C_BACK_TYPE                       = 0xC180,
        C_MD_CS                           = 0xC190,
        C_MD_CE                           = 0xC1A0,
        C_MD_SML                          = 0xC1B0,
        C_MD_SMW                          = 0xC1C0,
        C_LOFT_WITH_TEXTURE               = 0xC1C3,
        C_LOFT_L_REPEAT                   = 0xC1C4,
        C_LOFT_W_REPEAT                   = 0xC1C5,
        C_LOFT_UV_NORMALIZE               = 0xC1C6,
        C_WELD_LOFT                       = 0xC1C7,
        C_MD_PDET                         = 0xC1D0,
        C_MD_SDET                         = 0xC1E0,
        C_RGB_RMODE                       = 0xC1F0,
        C_RGB_HIDE                        = 0xC200,
        C_RGB_MAPSW                       = 0xC202,
        C_RGB_TWOSIDE                     = 0xC204,
        C_RGB_SHADOW                      = 0xC208,
        C_RGB_AA                          = 0xC210,
        C_RGB_OVW                         = 0xC220,
        C_RGB_OVH                         = 0xC230,
        C_RGB_PICTYPE                     = 0xC240,
        C_RGB_OUTPUT                      = 0xC250,
        C_RGB_TODISK                      = 0xC253,
        C_RGB_COMPRESS                    = 0xC254,
        C_JPEG_COMPRESSION                = 0xC255,
        C_RGB_DISPDEV                     = 0xC256,
        C_RGB_HARDDEV                     = 0xC259,
        C_RGB_PATH                        = 0xC25A,
        C_BITMAP_DRAWER                   = 0xC25B,
        C_RGB_FILE                        = 0xC260,
        C_RGB_OVASPECT                    = 0xC270,
            
        C_RGB_ANIMTYPE                    = 0xC271,
        C_RENDER_ALL                      = 0xC272,
        C_REND_FROM                       = 0xC273,
        C_REND_TO                         = 0xC274,
        C_REND_NTH                        = 0xC275,
        C_PAL_TYPE                        = 0xC276,
        C_RND_TURBO                       = 0xC277,
        C_RND_MIP                         = 0xC278,
        C_BGND_METHOD                     = 0xC279,
        C_AUTO_REFLECT                    = 0xC27A,
        C_VP_FROM                         = 0xC27B,
        C_VP_TO                           = 0xC27C,
        C_VP_NTH                          = 0xC27D,
        C_REND_TSTEP                      = 0xC27E,
        C_VP_TSTEP                        = 0xC27F,

        C_SRDIAM                          = 0xC280,
        C_SRDEG                           = 0xC290,
        C_SRSEG                           = 0xC2A0,
        C_SRDIR                           = 0xC2B0,
        C_HETOP                           = 0xC2C0,
        C_HEBOT                           = 0xC2D0,
        C_HEHT                            = 0xC2E0,
        C_HETURNS                         = 0xC2F0,
        C_HEDEG                           = 0xC300,
        C_HESEG                           = 0xC310,
        C_HEDIR                           = 0xC320,
        C_QUIKSTUFF                       = 0xC330,
        C_SEE_LIGHTS                      = 0xC340,
        C_SEE_CAMERAS                     = 0xC350,
        C_SEE_3D                          = 0xC360,
        C_MESHSEL                         = 0xC370,
        C_MESHUNSEL                       = 0xC380,
        C_POLYSEL                         = 0xC390,
        C_POLYUNSEL                       = 0xC3A0,
        C_SHPLOCAL                        = 0xC3A2,
        C_MSHLOCAL                        = 0xC3A4,
        C_NUM_FORMAT                      = 0xC3B0,
        C_ARCH_DENOM                      = 0xC3C0,
        C_IN_DEVICE                       = 0xC3D0,
        C_MSCALE                          = 0xC3E0,
        C_COMM_PORT                       = 0xC3F0,
        C_TAB_BASES                       = 0xC400,
        C_TAB_DIVS                        = 0xC410,
        C_MASTER_SCALES                   = 0xC420,
        C_SHOW_1STVERT                    = 0xC430,
        C_SHAPER_OK                       = 0xC440,
        C_LOFTER_OK                       = 0xC450,
        C_EDITOR_OK                       = 0xC460,
        C_KEYFRAMER_OK                    = 0xC470,
        C_PICKSIZE                        = 0xC480,
        C_MAPTYPE                         = 0xC490,
        C_MAP_DISPLAY                     = 0xC4A0,
        C_TILE_XY                         = 0xC4B0,
        C_MAP_XYZ                         = 0xC4C0,
        C_MAP_SCALE                       = 0xC4D0,
        C_MAP_MATRIX_OLD                  = 0xC4E0,
        C_MAP_MATRIX                      = 0xC4E1,
        C_MAP_WID_HT                      = 0xC4F0,
        C_OBNAME                          = 0xC500,
        C_CAMNAME                         = 0xC510,
        C_LTNAME                          = 0xC520,
        C_CUR_MNAME                       = 0xC525,
        C_CURMTL_FROM_MESH                = 0xC526,
        C_GET_SHAPE_MAKE_FACES            = 0xC527,
        C_DETAIL                          = 0xC530,
        C_VERTMARK                        = 0xC540,
        C_MSHAX                           = 0xC550,
        C_MSHCP                           = 0xC560,
        C_USERAX                          = 0xC570,
        C_SHOOK                           = 0xC580,
        C_RAX                             = 0xC590,
        C_STAPE                           = 0xC5A0,
        C_LTAPE                           = 0xC5B0,
        C_ETAPE                           = 0xC5C0,
        C_KTAPE                           = 0xC5C8,
        C_SPHSEGS                         = 0xC5D0,
        C_GEOSMOOTH                       = 0xC5E0,
        C_HEMISEGS                        = 0xC5F0,
        C_PRISMSEGS                       = 0xC600,
        C_PRISMSIDES                      = 0xC610,
        C_TUBESEGS                        = 0xC620,
        C_TUBESIDES                       = 0xC630,
        C_TORSEGS                         = 0xC640,
        C_TORSIDES                        = 0xC650,
        C_CONESIDES                       = 0xC660,
        C_CONESEGS                        = 0xC661,
        C_NGPARMS                         = 0xC670,
        C_PTHLEVEL                        = 0xC680,
        C_MSCSYM                          = 0xC690,
        C_MFTSYM                          = 0xC6A0,
        C_MTTSYM                          = 0xC6B0,
        C_SMOOTHING                       = 0xC6C0,
        C_MODICOUNT                       = 0xC6D0,
        C_FONTSEL                         = 0xC6E0,
        C_TESS_TYPE                       = 0xC6f0,
        C_TESS_TENSION                    = 0xC6f1,

        C_SEG_START                       = 0xC700,
        C_SEG_END                         = 0xC705,
        C_CURTIME                         = 0xC710,
        C_ANIMLENGTH                      = 0xC715,
        C_PV_FROM                         = 0xC720,
        C_PV_TO                           = 0xC725,
        C_PV_DOFNUM                       = 0xC730,
        C_PV_RNG                          = 0xC735,
        C_PV_NTH                          = 0xC740,
        C_PV_TYPE                         = 0xC745,
        C_PV_METHOD                       = 0xC750,
        C_PV_FPS                          = 0xC755,
        C_VTR_FRAMES                      = 0xC765,
        C_VTR_HDTL                        = 0xC770,
        C_VTR_HD                          = 0xC771,
        C_VTR_TL                          = 0xC772,
        C_VTR_IN                          = 0xC775,
        C_VTR_PK                          = 0xC780,
        C_VTR_SH                          = 0xC785,
   
/* Material chunks */ 
        C_WORK_MTLS                       = 0xC790, /* Old-style -- now ignored */ 
        C_WORK_MTLS_2                     = 0xC792, /* Old-style -- now ignored */ 
        C_WORK_MTLS_3                     = 0xC793, /* Old-style -- now ignored */ 
        C_WORK_MTLS_4                     = 0xC794, /* Old-style -- now ignored */ 
        C_WORK_MTLS_5                     = 0xCB00, /* Old-style -- now ignored */ 
        C_WORK_MTLS_6                     = 0xCB01, /* Old-style -- now ignored */ 
        C_WORK_MTLS_7                     = 0xCB02, /* Old-style -- now ignored */ 
        C_WORK_MTLS_8                     = 0xCB03, /* Old-style -- now ignored */ 
        C_WORKMTL                         = 0xCB04,
        C_SXP_TEXT_DATA                   = 0xCB10,
        C_SXP_TEXT2_DATA                  = 0xCB20,
        C_SXP_OPAC_DATA                   = 0xCB11,
        C_SXP_BUMP_DATA                   = 0xCB12,
        C_SXP_SPEC_DATA                   = 0xCB24,
        C_SXP_SHIN_DATA                   = 0xCB13,
        C_SXP_SELFI_DATA                  = 0xCB28,
        C_SXP_TEXT_MASKDATA               = 0xCB30,
        C_SXP_TEXT2_MASKDATA              = 0xCB32,
        C_SXP_OPAC_MASKDATA               = 0xCB34,
        C_SXP_BUMP_MASKDATA               = 0xCB36,
        C_SXP_SPEC_MASKDATA               = 0xCB38,
        C_SXP_SHIN_MASKDATA               = 0xCB3A,
        C_SXP_SELFI_MASKDATA              = 0xC3C,
        C_SXP_REFL_MASKDATA               = 0xCB3E,

        C_BGTYPE                          = 0xC7A1,
        C_MEDTILE                         = 0xC7B0,
   
/* Contrast */
        C_LO_CONTRAST                     = 0xC7D0,
        C_HI_CONTRAST                     = 0xC7D1,
 
/* 3d frozen display */ 
        C_FROZ_DISPLAY                    = 0xC7E0,
 
/* Booleans */ 
        C_BOOLWELD                        = 0xc7f0,
        C_BOOLTYPE                        = 0xc7f1,

        C_ANG_THRESH                      = 0xC900,
        C_SS_THRESH                       = 0xC901,
        C_TEXTURE_BLUR_DEFAULT            = 0xC903,

        C_MAPDRAWER                       = 0xCA00,
        C_MAPDRAWER1                      = 0xCA01,
        C_MAPDRAWER2                      = 0xCA02,
        C_MAPDRAWER3                      = 0xCA03,
        C_MAPDRAWER4                      = 0xCA04,
        C_MAPDRAWER5                      = 0xCA05,
        C_MAPDRAWER6                      = 0xCA06,
        C_MAPDRAWER7                      = 0xCA07,
        C_MAPDRAWER8                      = 0xCA08,
        C_MAPDRAWER9                      = 0xCA09,
        C_MAPDRAWER_ENTRY                 = 0xCA10,
   
/* System Options */ 
        C_BACKUP_FILE                     = 0xCA20,
        C_DITHER_256                      = 0xCA21,
        C_SAVE_LAST                       = 0xCA22,
        C_USE_ALPHA                       = 0xCA23,
        C_TGA_DEPTH                       = 0xCA24,
        C_REND_FIELDS                     = 0xCA25,
        C_REFLIP                          = 0xCA26,
        C_SEL_ITEMTOG                     = 0xCA27,
        C_SEL_RESET                       = 0xCA28,
        C_STICKY_KEYINF                   = 0xCA29,
        C_WELD_THRESHOLD                  = 0xCA2A,
        C_ZCLIP_POINT                     = 0xCA2B,
        C_ALPHA_SPLIT                     = 0xCA2C,
        C_KF_SHOW_BACKFACE                = 0xCA30,
        C_OPTIMIZE_LOFT                   = 0xCA40,
        C_TENS_DEFAULT                    = 0xCA42,
        C_CONT_DEFAULT                    = 0xCA44,
        C_BIAS_DEFAULT                    = 0xCA46,

        C_DXFNAME_SRC                     = 0xCA50,
        C_AUTO_WELD                       = 0xCA60,
        C_AUTO_UNIFY                      = 0xCA70,
        C_AUTO_SMOOTH                     = 0xCA80,
        C_DXF_SMOOTH_ANG                  = 0xCA90,
        C_SMOOTH_ANG                      = 0xCAA0,
   
/* Special network-use chunks */ 
        C_NET_USE_VPOST                   = 0xCC00,
        C_NET_USE_GAMMA                   = 0xCC10,
        C_NET_FIELD_ORDER                 = 0xCC20,

        C_BLUR_FRAMES                     = 0xCD00,
        C_BLUR_SAMPLES                    = 0xCD10,
        C_BLUR_DUR                        = 0xCD20,
        C_HOT_METHOD                      = 0xCD30,
        C_HOT_CHECK                       = 0xCD40,
        C_PIXEL_SIZE                      = 0xCD50,
        C_DISP_GAMMA                      = 0xCD60,
        C_FBUF_GAMMA                      = 0xCD70,
        C_FILE_OUT_GAMMA                  = 0xCD80,
        C_FILE_IN_GAMMA                   = 0xCD82,
        C_GAMMA_CORRECT                   = 0xCD84,
        C_APPLY_DISP_GAMMA                = 0xCD90,  /* OBSOLETE */
        C_APPLY_FBUF_GAMMA                = 0xCDA0,  /* OBSOLETE */
        C_APPLY_FILE_GAMMA                = 0xCDB0,  /* OBSOLETE */
        C_FORCE_WIRE                      = 0xCDC0,
        C_RAY_SHADOWS                     = 0xCDD0,
        C_MASTER_AMBIENT                  = 0xCDE0,
        C_SUPER_SAMPLE                    = 0xCDF0,
        C_OBJECT_MBLUR                    = 0xCE00,
        C_MBLUR_DITHER                    = 0xCE10,
        C_DITHER_24                       = 0xCE20,
        C_SUPER_BLACK                     = 0xCE30,
        C_SAFE_FRAME                      = 0xCE40,
        C_VIEW_PRES_RATIO                 = 0xCE50,
        C_BGND_PRES_RATIO                 = 0xCE60,
        C_NTH_SERIAL_NUM                  = 0xCE70,
   
    /* Video Post */ 
    VPDATA                                = 0xd000,

        P_QUEUE_ENTRY                     = 0xd100,
        P_QUEUE_IMAGE                     = 0xd110,
        P_QUEUE_USEIGAMMA                 = 0xd114,
        P_QUEUE_PROC                      = 0xd120,
        P_QUEUE_SOLID                     = 0xd130,
        P_QUEUE_GRADIENT                  = 0xd140,
        P_QUEUE_KF                        = 0xd150,
        P_QUEUE_MOTBLUR                   = 0xd152,
        P_QUEUE_MB_REPEAT                 = 0xd153,
        P_QUEUE_NONE                      = 0xd160,

        P_QUEUE_RESIZE                    = 0xd180,
        P_QUEUE_OFFSET                    = 0xd185,
        P_QUEUE_ALIGN                     = 0xd190,

        P_CUSTOM_SIZE                     = 0xd1a0,
     
        P_ALPH_NONE                       = 0xd210,
        P_ALPH_PSEUDO                     = 0xd220,  /* Old chunk */
        P_ALPH_OP_PSEUDO                  = 0xd221,  /* Old chunk */
        P_ALPH_BLUR                       = 0xd222,  /* Replaces pseudo */
        P_ALPH_PCOL                       = 0xd225,
        P_ALPH_C0                         = 0xd230,
        P_ALPH_OP_KEY                     = 0xd231,
        P_ALPH_KCOL                       = 0xd235,
        P_ALPH_OP_NOCONV                  = 0xd238,
        P_ALPH_IMAGE                      = 0xd240,
        P_ALPH_ALPHA                      = 0xd250,
        P_ALPH_QUES                       = 0xd260,
        P_ALPH_QUEIMG                     = 0xd265,
        P_ALPH_CUTOFF                     = 0xd270,
        P_ALPHANEG                        = 0xd280,

        P_TRAN_NONE                       = 0xd300,
        P_TRAN_IMAGE                      = 0xd310,
        P_TRAN_FRAMES                     = 0xd312,
        P_TRAN_FADEIN                     = 0xd320,
        P_TRAN_FADEOUT                    = 0xd330,
        P_TRANNEG                         = 0xd340,

        P_RANGES                          = 0xd400,

        P_PROC_DATA                       = 0xd500
};

struct Vector2f {
    float x, y;
} [[static]];

struct Vector3f {
    float x, y, z;
} [[static]];

bitfield FaceFlags {
    CA_Visible  : 1;
    BC_Visible  : 1;
    AB_Visible  : 1;
    Mapped      : 1;
    padding     : 9;
    CA_Selected : 1;
    BC_Selected : 1;
    AB_Selected : 1;
};

struct Face {
    u16 v0, v1,v2;
    FaceFlags flags;
};

bitfield VertexFlags {
    padding : 13;
    selected3 : 1;
    selected2 : 1;
    selected1 : 1;
};

bitfield KeyFlags1 {
    Show_Path   : 1;
    Smooth      : 1;
    padding     : 2;
    Motion_Blur : 1;
    padding     : 1;
    Morph_Mat   : 1;
};

bitfield KeyFlags2 {
    padding     : 10;
    Hidden      : 1;
};

struct RGB<T> {
    T r, g, b;
};

bitfield Spline {
    Use_Tension    : 1;
    Use_Continuity : 1;
    Use_Bias       : 1;
    Use_Ease_To    : 1;
    Use_Ease_From  : 1;
    
    padding : 3;

    if (Use_Tension == 1)
        float Tension;
    if (Use_Continuity == 1)
        float Continuity;
    if (Use_Bias == 1)
        float Bias;
    if (Use_Ease_To == 1)
        float Ease_To;
    if (Use_Ease_From == 1)
        float Ease_From;
        
    padding : 8;
};

struct VectorKey {
    u32 index;
    Spline splineData;
    Vector3f value;
};

struct RotationKey {
    u32 index;
    Spline splineData;
    float angle;
    Vector3f vector;
};

struct AngleKey {
    u32 index;
    Spline splineData;
    float angle;
};

struct MorphKey{
    u32 index;
    Spline splineData;
    char objectName[];
};

struct HideKey {
    u32 index;
    Spline splineData;
};

struct Keys<auto identifier> {
    u32 count;
    match (identifier) {
        (
            ChunkIdentifier::POS_TRACK_TAG |
            ChunkIdentifier::SCL_TRACK_TAG |
            ChunkIdentifier::COL_TRACK_TAG
        ) : {
            VectorKey data[count];
        }

        (
            ChunkIdentifier::ROT_TRACK_TAG
        ) : {
            RotationKey data[count];
        }
        
        (
            ChunkIdentifier::FOV_TRACK_TAG |
            ChunkIdentifier::ROLL_TRACK_TAG |
            ChunkIdentifier::HOT_TRACK_TAG |
            ChunkIdentifier::FALL_TRACK_TAG
        ) : {
            AngleKey data[count];
        }
        
        (
            ChunkIdentifier::MORPH_TRACK_TAG
        ) : {
            MorphKey data[count];
        }
        
        (
            ChunkIdentifier::HIDE_TRACK_TAG
        ) : {
            HideKey data[count];
        }
    }
};

enum TrackMode : u16 {
    MODE_SINGLE = 0,
    MODE_REPEAT = 1,
    MODE_LOOP   = 2,
};

bitfield TrackFlags {
    TrackMode Mode : 2;
    padding    : 1;
    Lock_X     : 1;
    Lock_Y     : 1;
    Lock_Z     : 1;
    padding    : 1;
    Unlink_X   : 1;
    Unlink_Y   : 1;
    Unlink_Z   : 1;
};

struct Chunk {
    ChunkIdentifier identifier;
    u32 chunkSize;
    u32 dataLength = chunkSize - 6 [[export]];
    u32 chunkEnd = $ + dataLength;
    
    if (chunkSize > 0) {
        std::print("{}", identifier);
        match (identifier) {
           (
                ChunkIdentifier::M3DMAGIC                |
                ChunkIdentifier::MDATA                   |
                ChunkIdentifier::N_TRI_OBJECT            |
                ChunkIdentifier::KFDATA                  |
                ChunkIdentifier::AMBIENT_NODE_TAG        |
                ChunkIdentifier::OBJECT_NODE_TAG         |
                ChunkIdentifier::CAMERA_NODE_TAG         |
                ChunkIdentifier::TARGET_NODE_TAG         |
                ChunkIdentifier::LIGHT_NODE_TAG          |
                ChunkIdentifier::L_TARGET_NODE_TAG       |
                ChunkIdentifier::SPOTLIGHT_NODE_TAG      |
                ChunkIdentifier::MAT_ENTRY               |
                ChunkIdentifier::MAT_AMBIENT             |
                ChunkIdentifier::MAT_DIFFUSE             |
                ChunkIdentifier::MAT_SPECULAR            |
                ChunkIdentifier::MAT_SHININESS           |
                ChunkIdentifier::MAT_SHIN2PCT            |
                ChunkIdentifier::MAT_SHIN3PCT            |
                ChunkIdentifier::MAT_TRANSPARENCY        |
                ChunkIdentifier::MAT_XPFALL              |
                ChunkIdentifier::MAT_REFBLUR             |
                ChunkIdentifier::MAT_SELF_ILPCT          |
                ChunkIdentifier::MAT_TEXMAP              |
                ChunkIdentifier::MAT_SPECMAP             |
                ChunkIdentifier::MAT_OPACMAP             |
                ChunkIdentifier::MAT_REFLMAP             |
                ChunkIdentifier::MAT_BUMPMAP             |
                ChunkIdentifier::MAT_BUMP_PERCENT        |
                ChunkIdentifier::MAT_TEX2MAP             |
                ChunkIdentifier::MAT_SHINMAP             |
                ChunkIdentifier::MAT_SELFIMAP            |
                ChunkIdentifier::MAT_TEXMASK             |
                ChunkIdentifier::MAT_TEX2MASK            |
                ChunkIdentifier::MAT_OPACMASK            |
                ChunkIdentifier::MAT_BUMPMASK            |
                ChunkIdentifier::MAT_SHINMASK            |
                ChunkIdentifier::MAT_SPECMASK            |
                ChunkIdentifier::MAT_SELFIMASK           |
                ChunkIdentifier::MAT_REFLMASK            |
                ChunkIdentifier::WORLD_VIEWPORT_DATA     |
                ChunkIdentifier::WORLD_VIEWPORT_DATA3    |
                ChunkIdentifier::WORLD_VIEWPORT_LAYOUT   |
                ChunkIdentifier::SOLID_BGND              |
                ChunkIdentifier::AMBIENT_LIGHT
            ): {
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::M3D_VERSION |
                ChunkIdentifier::MESH_VERSION
            ): {
                u32 version;
            }
            
            (
                ChunkIdentifier::LO_SHADOW_BIAS         |
                ChunkIdentifier::HI_SHADOW_BIAS         |
                ChunkIdentifier::SHADOW_FILTER          |
                ChunkIdentifier::RAY_BIAS               |
                ChunkIdentifier::FLOAT_PERCENTAGE       |
                ChunkIdentifier::MASTER_SCALE           |
                ChunkIdentifier::MAT_MAP_TEXBLUR        |
                ChunkIdentifier::MAT_MAP_USCALE         |
                ChunkIdentifier::MAT_MAP_VSCALE         |
                ChunkIdentifier::MAT_MAP_UOFFSET        |
                ChunkIdentifier::MAT_MAP_VOFFSET        |
                ChunkIdentifier::MAT_MAP_ANG            |
                ChunkIdentifier::MAT_WIRESIZE           |
                ChunkIdentifier::DL_SPOT_ROLL           |
                ChunkIdentifier::MORPH_SMOOTH
            ): {
                float value;
            }
            
            (
                ChunkIdentifier::V_GRADIENT
            ) : {
                float position;
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::NAMED_OBJECT
            ) : {
                char name[];
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::POINT_ARRAY
            ) : {
                u16 count;
                Vector3f vectices[count] [[hex::visualize("3d", this, null)]];
            }
            
            (
                ChunkIdentifier::TEX_VERTS
            ) : {
                u16 count;
                Vector2f coords[count];
            }
            
            (
                ChunkIdentifier::MESH_MATRIX
            ) : {
                Vector3f x, y, z, w;
            }
            
            (
                ChunkIdentifier::FACE_ARRAY
            ) : {
                u16 count;
                Face faces[count];
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::POINT_FLAG_ARRAY
            ) : {
                u16 count;
                VertexFlags flags[count];
            }
            
            (
                ChunkIdentifier::SMOOTH_GROUP
            ) : {
                u32 groups[dataLength / sizeof(u32)];
            }
            
            (
                ChunkIdentifier::MESH_COLOR
            ) : {
                u8 value;
            }
            
            (
                ChunkIdentifier::MSH_MAT_GROUP
            ) : {
                char name[];
                u16 count;
                u16 groups[count];
            }
            
            (
                ChunkIdentifier::KFHDR
            ) : {
                u16 revision;
                char name[];
                u32 animationLength;
            }
            
            (
                ChunkIdentifier::KFSEG
            ) : {
                u32 start, end;
            }
            
            (
                ChunkIdentifier::KFCURTIME
            ) : {
                u32 frameIndex;
            }
            
            (
                ChunkIdentifier::NODE_ID
            ) : {
                type::Hex<u16> id;
            }
            
            (
                ChunkIdentifier::NODE_HDR
            ) : {
                char name[];
                padding[1];
                KeyFlags1 flags1;
                KeyFlags2 flags2;
                type::Hex<u16> parentId;
            }
            
            (
                ChunkIdentifier::PIVOT
            ) : {
                Vector3f value;
            }
            
            (
                ChunkIdentifier::BOUNDBOX
            ) : {
                Vector3f min, max;
            }
           
            (
                ChunkIdentifier::COLOR_24 |
                ChunkIdentifier::LIN_COLOR_24
            ) : {
                RGB<u8> color;
            }
            
            (
                ChunkIdentifier::COLOR_F |
                ChunkIdentifier::LIN_COLOR_F
            ) : {
                RGB<float> color;
            }
            
            (
                ChunkIdentifier::INT_PERCENTAGE |
                ChunkIdentifier::MAT_BUMP_PERCENT
            ) : {
                u16 value;
            }
            
            (
                ChunkIdentifier::SHADOW_MAP_SIZE |
                ChunkIdentifier::MAT_SHADING
            ) : {
                u16 value;
            }
            
            (
                ChunkIdentifier::POS_TRACK_TAG    |
                ChunkIdentifier::ROT_TRACK_TAG    |
                ChunkIdentifier::SCL_TRACK_TAG    |
                ChunkIdentifier::FOV_TRACK_TAG    |
                ChunkIdentifier::ROLL_TRACK_TAG   |
                ChunkIdentifier::COL_TRACK_TAG    |
                ChunkIdentifier::MORPH_TRACK_TAG  |
                ChunkIdentifier::HOT_TRACK_TAG    |
                ChunkIdentifier::FALL_TRACK_TAG   |
                ChunkIdentifier::HIDE_TRACK_TAG 
            ) : {
                TrackFlags flags;
                u8 unknown[8];
                Keys<identifier> keys;
            }
            
            (
                ChunkIdentifier::INSTANCE_NAME |
                ChunkIdentifier::BIT_MAP       |
                ChunkIdentifier::DL_SPOT_PROJECTOR |
                ChunkIdentifier::MAT_NAME |
                ChunkIdentifier::MAT_MAPNAME
            ) : {
                char name[];
            }
            
            (
                ChunkIdentifier::MAT_MAP_TILING
            ) : {
                u16 tiling;
            }
            
            (
                ChunkIdentifier::WORLD_VIEWPORT_SIZE
            ) : {
                u16 x, y, w, h;
            }
            
            (
                ChunkIdentifier::N_DIRECT_LIGHT
            ) : {
                Vector3f position;
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::DL_SPOTLIGHT
            ) : {
                Vector3f target;
                float hotspot, falloff;
                Chunk chunks[while($ < chunkEnd)];
            }
            
            (
                ChunkIdentifier::N_CAMERA
            ) : {
                Vector3f position, target;
                float roll, fov;
            }
            
            
            
            (_) : {
                std::warning(std::format("Unhandled Chunk ID: {}, Skipping 0x{:04X} bytes", identifier, dataLength));
                $ += dataLength;
            }
        }
    }
};

Chunk chunk @ 0x00;