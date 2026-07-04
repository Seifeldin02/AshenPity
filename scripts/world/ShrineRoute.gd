extends RefCounted
class_name ShrineRoute

const CAMERA_LIMIT_LEFT := -940
const CAMERA_LIMIT_TOP := -650
const CAMERA_LIMIT_RIGHT := 940
const CAMERA_LIMIT_BOTTOM := 650

const PLAYER_START := Vector2(-330, 420)
const GUARDIAN_SPAWNS := [Vector2(-230, -40), Vector2(250, -90), Vector2(80, 155)]

const ENTRANCE := Rect2(-520, 250, 720, 330)
const SIDE_ALCOVE := Rect2(-720, 355, 210, 150)
const LOWER_PASSAGE := Rect2(-150, 155, 300, 110)
const CENTRAL := Rect2(-690, -250, 1380, 500)
const UPPER_PASSAGE := Rect2(-165, -330, 330, 100)
const ALTAR := Rect2(-430, -585, 860, 275)

const ROOMS := [ENTRANCE, SIDE_ALCOVE, LOWER_PASSAGE, CENTRAL, UPPER_PASSAGE, ALTAR]

const TEST_VISIBILITY_POINTS := [
	Vector2(-470, 520),
	Vector2(140, 520),
	Vector2(-665, 430),
	Vector2(-610, -195),
	Vector2(610, -195),
	Vector2(0, -35),
	Vector2(-340, -500),
	Vector2(340, -500)
]

const WALLS := [
	["EntranceSouth", Vector2(-160, 616), Vector2(770, 72)],
	["EntranceWestLower", Vector2(-565, 540), Vector2(72, 170)],
	["EntranceWestUpper", Vector2(-565, 284), Vector2(72, 105)],
	["EntranceEast", Vector2(236, 418), Vector2(72, 340)],
	["EntranceNorthLeft", Vector2(-372, 220), Vector2(300, 72)],
	["EntranceNorthRight", Vector2(370, 220), Vector2(420, 72)],
	["AlcoveWest", Vector2(-760, 430), Vector2(72, 180)],
	["AlcoveNorth", Vector2(-625, 318), Vector2(260, 72)],
	["AlcoveSouth", Vector2(-622, 542), Vector2(240, 72)],
	["CentralWest", Vector2(-735, 0), Vector2(82, 500)],
	["CentralEast", Vector2(735, 0), Vector2(82, 500)],
	["CentralSouthLeft", Vector2(-420, 292), Vector2(570, 76)],
	["CentralSouthRight", Vector2(430, 292), Vector2(570, 76)],
	["CentralNorthLeft", Vector2(-430, -292), Vector2(560, 76)],
	["CentralNorthRight", Vector2(430, -292), Vector2(560, 76)],
	["AltarWest", Vector2(-476, -450), Vector2(76, 300)],
	["AltarEast", Vector2(476, -450), Vector2(76, 300)],
	["AltarNorth", Vector2(0, -628), Vector2(930, 76)],
	["AltarSouthLeft", Vector2(-318, -274), Vector2(310, 74)],
	["AltarSouthRight", Vector2(318, -274), Vector2(310, 74)]
]

const OBSTACLES := [
	["PillarA", Vector2(-390, -112), Vector2(58, 82), "pillar"],
	["PillarB", Vector2(365, -105), Vector2(58, 82), "pillar"],
	["PillarC", Vector2(-260, 128), Vector2(58, 82), "pillar"],
	["BrokenWallA", Vector2(260, 145), Vector2(140, 42), "broken_wall"],
	["BrokenWallB", Vector2(-505, 65), Vector2(170, 42), "broken_wall"],
	["AltarBlock", Vector2(0, -484), Vector2(210, 64), "altar"]
]

const TORCHES := [Vector2(-455, 310), Vector2(140, 300), Vector2(-610, 388), Vector2(-635, -180), Vector2(635, -180), Vector2(-260, -535), Vector2(265, -535)]

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
