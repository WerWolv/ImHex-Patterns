// SPDX-FileCopyrightText: 2026 Neptuwunium
//
// SPDX-License-Identifier: GPL-2

#pragma once
#pragma author Neptuwunium
#pragma description BroEngine DDS Texture
#pragma array_limit 0x1fffffff
#pragma pattern_limit 0x1fffffff

#include "dds.hexpat"

if (header.reserved0[0] == 0x4477) {
	u32 compressedMipSizes[dds.mipMapCount];
}
