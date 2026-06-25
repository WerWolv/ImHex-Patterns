// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.


#pragma once

#pragma endian little
#pragma magic [55 AA] @ 0x01FE

#pragma author Xavier "XJDHDR" du Hecquet de Rauville
#pragma description Master boot record - IBM


bitfield MbrPartitionAttributes
{
            Reserved: 7;
    bool    IsActiveOrBootable: 1;
};

struct MbrPartitionTableEntry
{
    MbrPartitionAttributes Attributes;
    u8 PartitionStartCylinder;
    u8 PartitionStartHead;
    u8 PartitionStartSector;
    u8 PartitionType;
    u8 PartitionEndCylinder;
    u8 PartitionEndHead;
    u8 PartitionEndSector;
    u32 PartitionStartLba;
    u32 PartitionSectorQty;
};

struct MBR
{
    u8 Bootstrap[440];
    u32 UniqueDiskId;
    u16 Reserved;
    
    if (Reserved != 0)
    {
        break;
    }
    
    MbrPartitionTableEntry FirstPartition;
    MbrPartitionTableEntry SecondPartition;
    MbrPartitionTableEntry ThirdPartition;
    MbrPartitionTableEntry FourthPartition;
    u16 MbrSignature;
};

MBR mbr @ 0x0;
