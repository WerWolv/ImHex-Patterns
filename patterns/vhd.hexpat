// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.


#pragma once

#pragma endian big
#pragma magic [63 6F 6E 65 63 74 69 78] @ -0x0200
#pragma MIME application/x-vhd

#pragma author Xavier "XJDHDR" du Hecquet de Rauville
#pragma description Virtual Hard Disk file - Connectix / Microsoft


import std.mem;
import std.time;

import * from fs.mbr as MBR;


enum VhdFeatures : u32
{
    None = 0x0,
    TemporaryDisk = 0x1,
    Reserved = 0x2,
};

enum VhdCreatorApplication : u32
{
    Disk2vhd = 0x64327620,
    Qemu = 0x71656D75,
    VirtualPC = 0x76706320,
    VirtualServer = 0x76732020,
    WindowsDiskManagement = 0x77696E20,
};

enum VhdCreatorHostOs : u32
{
    Macintosh = 0x4D616320,
    Windows = 0x5769326B,
};

enum VhdDiskType : u32
{
    None = 0,
    Reserved = 1,
    FixedHardDisk = 2,
    DynamicHardDisk = 3,
    DifferentialHardDisk = 4,
    Reserved2 = 5,
    Reserved3 = 6,
};

struct VhdFooter
{
    $ = std::mem::size() - 512;
    
    char magicNumber[8];
    if (magicNumber != "conectix")
    {
        break;
    }
    
    VhdFeatures features;
    u16 formatVersionMajor;
    u16 formatVersionMinor;
    u64 nextMetadataOffset;
    std::time::EpochTime modificationTime;// [[format("TimeFormatter")]];
    VhdCreatorApplication creatorApplication;
    u16 creatorAppVersionMajor;
    u16 creatorAppVersionMinor;
    VhdCreatorHostOs creatorHostOs;
    u64 diskSize;
    u64 diskSizeAgain;
    u16 CylinderQty;
    u8 HeadQty;
    u8 SectorsPerTrack;
    VhdDiskType diskType;
    u32 checksum;
    u128 uuid;
    u8 isInSavedState;
    u8 Reserved[427];
    
    $ = 0;
};

fn TimeFormatter(std::time::EpochTime Epoch2000Time)
{
//    std::time::EpochTime unixEpochTime = Epoch2000Time + 946684800;
//    return std::time::format(std::time::to_local(unixEpochTime), "%c");
    return std::time::format(std::time::to_local(Epoch2000Time), "%c");
};

struct VHD
{
    VhdFooter footer;
    
    try
    {
        MBR Mbr @ 0x0;
    }
};

VHD vhd @ 0x00;
