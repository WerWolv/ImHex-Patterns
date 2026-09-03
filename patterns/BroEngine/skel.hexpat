// SPDX-FileCopyrightText: 2026 Neptuwunium
//
// SPDX-License-Identifier: EUPL-1.2

#pragma once

#ifndef __BROENGINE_SKELETON_IMPORTED__
#pragma author Neptuwunium
#pragma description BroEngine Skeleton
#pragma filename *.skel
#pragma array_limit 0x1fffffff
#pragma pattern_limit 0x1fffffff
#endif

import std.sys;

#include "BroEngine/bro.hexinc"

struct BoneData<auto count> {
	Matrix4x4F matrices[count];
	PString32 names[count];
};

struct BoneChild {
	u32 relPtr;
	u32 boneId;
};

struct BoneInfo {
	u16 parentIndex;
	u16 unknown;
	u32 childCount;

	if (childCount > 0) {
		BoneChild children[childCount];
	}

	u32 parentOffset; // doesn't exist on the last one.
} [[inline]];

struct Skeleton {
	u32 version;
	std::assert(version <= 4, "version is too new");
	u16 boneCount;
	RelPtr<BoneData<boneCount>> boneData;
	u32 headerEnd = $ + 4;
	Ptr<BoneInfo, headerEnd> bones[boneCount];
	Ptr<BoneInfo, headerEnd> rootBone;
};

#ifndef __BROENGINE_SKELETON_IMPORTED__
Skeleton skel @ 0;
#endif
