// SPDX-FileCopyrightText: 2026 Neptuwunium
//
// SPDX-License-Identifier: EUPL-1.2

#pragma once
#pragma author Neptuwunium
#pragma description BroEngine Animation
#pragma filename *.anim
#pragma array_limit 0x1fffffff
#pragma pattern_limit 0x1fffffff

#include "BroEngine/bro.hexinc"
#define __BROENGINE_SKELETON_IMPORTED__
#include "BroEngine/skel.hexpat"

struct Track {
	u32 frame_count = parent.frame_count;

	bool rot_is_const;
	Vector4F rotation[rot_is_const ? 1 : frame_count];

	bool pos_is_const;
	Vector3F position[pos_is_const ? 1 : frame_count];

	bool scale_is_const;
	float scale[scale_is_const ? 1 : frame_count];
};

struct SkeletalAnimation {
	u16 bone_count;
	u32 frame_count;
	float duration;

	Track prefab;
	Track bones[bone_count];
	Skeleton skeleton;
};

SkeletalAnimation anim @ 0;
