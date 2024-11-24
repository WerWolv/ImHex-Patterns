#pragma author nullptr
#pragma description Minecraft LCE .pck files

import std.io;
import std.array;
import std.core;
import std.sys;
import std.string;
import std.mem;
import type.size;

bool littleEndian in;

if (littleEndian)
    std::core::set_endian(std::mem::Endian::Little);
else
	std::core::set_endian(std::mem::Endian::Big);

namespace format
{
    // TODO: find a way to access look up table differently
    fn look_up_str(s32 index)
    {
        return pck.lut.table[index].value;
    };

    fn property(ref auto p)
    {
        return std::format("{}: {}", format::look_up_str(p.key), p.value);
    };

    fn assets(ref auto assets)
    {
        return std::format("Assets: {}", assets.count);
    };

    fn properties(ref auto p)
    {
        return std::format("count: {}", p.propertyCount);
    };

    fn string(ref auto string)
    {
        return std::string::to_string(string.value);
    };

    fn asset_entry(ref auto e)
    {
        return std::string::to_string(e.type);
    };
}

namespace transform
{
    fn assets(ref auto asstes)
    {
        std::unimplemented();
    };
}

struct string
{
    std::string::SizedString16<s32> value;
    padding[4];
} [[sealed, format("format::string"), transform("format::string")]];

struct LookUpTableValue
{
    s32 index;
    string value;
} [[sealed, name(value), value(index)]];

struct LookUpTable
{
    s32 count;
    LookUpTableValue table[count];
} [[sealed]];

fn lutContains(ref LookUpTable lut, str value)
{
    for (s32 i = 0, i < lut.count, i = i + 1)
    {
        if (std::string::contains(lut.table[i].value, value))
            return true;
    }
    return false;
};

enum AssetType : s32
{
    SkinFile = 0,  // *.png
    CapeFile = 1,  // *.png
    TextureFile = 2,  // *.png
    //! Unused !
    UIDataFile = 3,
    //! "0" file
    InfoFile = 4,
    //! (x16|x32|x64)Info.pck
    TexturePackInfoFile = 5,
    //! languages.loc/localisation.loc
    LocalisationFile = 6,
    //! GameRules.grf
    GameRulesFile = 7,
    //! audio.pck
    AudioFile = 8,
    //! colours.col
    ColourTableFile = 9,
    //! GameRules.grh
    GameRulesHeader = 10,
    //! Skins.pck
    SkinDataFile = 11,
    //! models.bin
	ModelsFile = 12,
    //! behaviours.bin
    BehavioursFile = 13,
    //! entityMaterials.bin
    MaterialFile = 14,
};

struct Property
{
    s32 key [[format("format::look_up_str")]];
    string value;
} [[format("format::property")]];

struct AssetProperties
{
    s32 propertyCount[[hidden]];
    Property properties[propertyCount] [[inline]];
} [[inline, format("format::properties")]];

struct AssetEntry
{
    type::Size32 size;
    AssetType type;
    string path;
} [[sealed, name(path), format("format::asset_entry")]];

struct AssetVisualizer<auto size, auto visualizer_name>
{
    u8 data[size] [[hidden]];
} [[sealed, hex::visualize(visualizer_name, data)]];

using AssetTexture<auto size> = AssetVisualizer<size, "image">;

using Pck;
struct Asset
{
    u64 index = std::core::array_index();
    AssetProperties properties;
    s32 size = parent.assetEntries[index].size;
    AssetType type = parent.assetEntries[index].type;
    match (parent.assetEntries[index].type)
    {
        (AssetType::SkinFile | AssetType::CapeFile | AssetType::TextureFile): AssetTexture<size> data;
        (AssetType::TexturePackInfoFile | AssetType::SkinDataFile): Pck data;
        (_): u8 data[size]; // hex::visualize("hex_viewer", data); causes crash ._.
    }
} [[name(std::string::to_string(parent.assetEntries[index].path)), format("format::asset_entry")]];

struct Assets
{
    s32 count [[hidden]];
    AssetEntry assetEntries[count] [[hidden]];
    Asset assetData[count] [[inline]];
} [[format("format::assets"), transform_entities("transform::assets")]];

struct Pck
{
    s32 version;
    if (version >> 24 & 0xff != 0)
    {
        if (!littleEndian)
            std::warning("pck is likely to be little endian. Enable 'littleEndian' in the 'settings' tab");
        else
            std::warning("pck is likely to be big endian. Disable 'littleEndian' in the 'settings' tab");
        break;
    }
    LookUpTable lut [[hidden]];
    if (lutContains(lut, "XMLVERSION"))
    {
        s32 xmlVersion;
    }
    Assets assets;
};

Pck pck @ 0x00;