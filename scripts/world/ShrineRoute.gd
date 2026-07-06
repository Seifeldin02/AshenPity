extends RefCounted
class_name ShrineRoute

const CAMERA_LIMIT_LEFT := -1720
const CAMERA_LIMIT_TOP := -1020
const CAMERA_LIMIT_RIGHT := 1720
const CAMERA_LIMIT_BOTTOM := 1020
const CAMERA_ZOOM := Vector2(1.20, 1.20)

const PLAYER_START := Vector2(-360, 430)
const GUARDIAN_SPAWNS := [Vector2(-280, -80), Vector2(310, -120), Vector2(120, 160)]

const ENTRANCE := Rect2(-620, 270, 850, 330)
const SIDE_ALCOVE := Rect2(-875, 340, 290, 170)
const LOWER_PASSAGE := Rect2(-210, 145, 420, 140)
const CENTRAL := Rect2(-760, -280, 1520, 560)
const LEFT_SIDE_PATH := Rect2(-980, -120, 260, 310)
const RIGHT_SIDE_PATH := Rect2(720, -155, 270, 335)
const UPPER_PASSAGE := Rect2(-210, -365, 420, 115)
const ALTAR := Rect2(-520, -620, 1040, 310)

const ROOMS := [ENTRANCE, SIDE_ALCOVE, LOWER_PASSAGE, CENTRAL, LEFT_SIDE_PATH, RIGHT_SIDE_PATH, UPPER_PASSAGE, ALTAR]

const TEST_VISIBILITY_POINTS := [
	Vector2(-470, 520),
	Vector2(140, 520),
	Vector2(-665, 430),
	Vector2(-900, 0),
	Vector2(900, 0),
	Vector2(0, -35),
	Vector2(-430, -520),
	Vector2(430, -520)
]

const WALLS := [
	["EntranceSouth", Vector2(-200, 638), Vector2(920, 70)],
	["EntranceWestLower", Vector2(-675, 555), Vector2(72, 185)],
	["EntranceWestUpper", Vector2(-675, 288), Vector2(72, 96)],
	["EntranceEast", Vector2(276, 425), Vector2(72, 345)],
	["EntranceNorthLeft", Vector2(-440, 226), Vector2(340, 70)],
	["EntranceNorthRight", Vector2(420, 226), Vector2(470, 70)],
	["AlcoveWest", Vector2(-1032, 420), Vector2(72, 230)],
	["AlcoveNorth", Vector2(-790, 306), Vector2(410, 70)],
	["AlcoveSouth", Vector2(-790, 548), Vector2(420, 70)],
	["LeftOuter", Vector2(-1020, 18), Vector2(72, 330)],
	["RightOuter", Vector2(1030, 18), Vector2(72, 360)],
	["CentralSouthLeft", Vector2(-500, 315), Vector2(570, 70)],
	["CentralSouthRight", Vector2(540, 315), Vector2(620, 70)],
	["CentralNorthLeft", Vector2(-520, -322), Vector2(600, 70)],
	["CentralNorthRight", Vector2(520, -322), Vector2(600, 70)],
	["AltarWest", Vector2(-574, -464), Vector2(74, 310)],
	["AltarEast", Vector2(574, -464), Vector2(74, 310)],
	["AltarNorth", Vector2(0, -664), Vector2(1160, 72)],
	["AltarSouthLeft", Vector2(-400, -286), Vector2(370, 70)],
	["AltarSouthRight", Vector2(400, -286), Vector2(370, 70)]
]

const OBSTACLES := [
	["PillarA", Vector2(-610, 95), Vector2(58, 82), "pillar"],
	["PillarB", Vector2(475, -128), Vector2(58, 82), "pillar"],
	["PillarC", Vector2(-315, 142), Vector2(58, 82), "pillar"],
	["PillarD", Vector2(350, 122), Vector2(58, 82), "pillar"],
	["BrokenWallA", Vector2(205, 176), Vector2(132, 38), "broken_wall"],
	["BrokenWallB", Vector2(-570, 32), Vector2(145, 38), "broken_wall"],
	["BrokenWallC", Vector2(785, -12), Vector2(122, 38), "broken_wall"],
	["AltarBlock", Vector2(0, -514), Vector2(250, 68), "altar"]
]

const TORCHES := [Vector2(-545, 330), Vector2(165, 310), Vector2(-780, 390), Vector2(-820, -55), Vector2(820, -80), Vector2(-660, -225), Vector2(660, -225), Vector2(-330, -555), Vector2(335, -555)]

static func is_inside_route(point: Vector2) -> bool:
	for room in ROOMS:
		if room.has_point(point):
			return true
	return false


static func clamped_to_camera_limits(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, float(CAMERA_LIMIT_LEFT), float(CAMERA_LIMIT_RIGHT)),
		clampf(point.y, float(CAMERA_LIMIT_TOP), float(CAMERA_LIMIT_BOTTOM))
	)


static func camera_rect_at(point: Vector2, viewport_size: Vector2, zoom: Vector2) -> Rect2:
	var center := clamped_to_camera_limits(point)
	var size := viewport_size / zoom
	return Rect2(center - size * 0.5, size)
