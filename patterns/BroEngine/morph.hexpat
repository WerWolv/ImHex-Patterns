// SPDX-FileCopyrightText: 2026 Neptuwunium
//
// SPDX-License-Identifier: EUPL-1.2

#pragma once
#pragma author Neptuwunium
#pragma description BroEngine Morph
#pragma filename *.morph
#pragma array_limit 0x1fffffff
#pragma pattern_limit 0x1fffffff

#include "BroEngine/bro.hexinc"

struct MorphTarget {
	u32 vertex_start;
	u32 vertex_count;
	u32 unknown;
	PString32 name;
};

struct MorphVertex {
	u32 target_vertex;
	Vector3F position;
	Vector3F tangent;
	Vector3F normal;
	Vector3F bitangent;
};

struct MorpherLimit {
	float min;
	float max;
};

struct MorpherExtent {
	float extent;
	float amount;
	u32 flags;
};

struct MorpherTarget {
	PString32 name;
	u32 flags;
	u32 limit_count;
	MorpherLimit limits[limit_count];
	u32 extent_count;
	MorpherExtent extents[extent_count];
};

struct Morpher {
	PString32 name;
	u32 target_count;
	MorpherTarget targets[target_count];
};

struct MorphAnimation {
	u32 count;
	MorphTarget targets[count];

	u32 vertex_count;
	MorphVertex vertices[vertex_count];

	u32 morpher_count;
	Morpher morphers[morpher_count];
};

MorphAnimation morph @ 0;
