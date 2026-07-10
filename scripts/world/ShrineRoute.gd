extends RefCounted
class_name ShrineRoute

const CAMERA_LIMIT_LEFT := -1080
const CAMERA_LIMIT_TOP := -890
const CAMERA_LIMIT_RIGHT := 1080
const CAMERA_LIMIT_BOTTOM := 760
const CAMERA_ZOOM := Vector2(1.24, 1.24)

const PLAYER_START := Vector2(0, 565)
const GUARDIAN_SPAWNS := [Vector2(-260, -80), Vector2(260, -110), Vector2(0, -365)]

const ENTRANCE := Rect2(-360, 350, 720, 260)
const SOUTH_STEPS := Rect2(-230, 255, 460, 115)
const PILGRIM_COURT := Rect2(-520, 610, 1040, 120)
const SIDE_ALCOVE := Rect2(-850, 145, 280, 300)
const LOWER_PASSAGE := Rect2(-180, 125, 360, 150)
const CENTRAL := Rect2(-720, -260, 1440, 520)
const LEFT_SIDE_PATH := Rect2(-890, -125, 240, 250)
const RIGHT_SIDE_PATH := Rect2(650, -125, 240, 250)
const UPPER_PASSAGE := Rect2(-190, -385, 380, 145)
const ALTAR := Rect2(-470, -650, 940, 280)
const WEST_OSSUARY := Rect2(-850, -610, 300, 300)
const WEST_PASSAGE := Rect2(-590, -500, 170, 160)
const WEST_DEEP_PASSAGE := Rect2(-850, -610, 1, 1)
const WEST_DEEP_CRYPT := Rect2(-850, -610, 1, 1)
const EAST_RELIQUARY := Rect2(550, -610, 300, 300)
const EAST_PASSAGE := Rect2(420, -500, 170, 160)
const EAST_DEEP_PASSAGE := Rect2(850, -610, 1, 1)
const EAST_DEEP_CHAPEL := Rect2(850, -610, 1, 1)
const NORTH_NAVE := Rect2(-260, -800, 520, 170)
const BOSS_SANCTUM := Rect2(-470, -820, 940, 210)
const SANCTUM_PASSAGE := Rect2(-150, -670, 300, 90)

const ROOMS := [
	ENTRANCE,
	SOUTH_STEPS,
	PILGRIM_COURT,
	SIDE_ALCOVE,
	LOWER_PASSAGE,
	CENTRAL,
	LEFT_SIDE_PATH,
	RIGHT_SIDE_PATH,
	UPPER_PASSAGE,
	ALTAR,
	WEST_PASSAGE,
	WEST_OSSUARY,
	WEST_DEEP_PASSAGE,
	WEST_DEEP_CRYPT,
	EAST_PASSAGE,
	EAST_RELIQUARY,
	EAST_DEEP_PASSAGE,
	EAST_DEEP_CHAPEL,
	NORTH_NAVE,
	SANCTUM_PASSAGE,
	BOSS_SANCTUM
]

const TEST_VISIBILITY_POINTS := [
	Vector2(-300, 520),
	Vector2(0, 565),
	Vector2(0, 315),
	Vector2(140, 210),
	Vector2(-700, 300),
	Vector2(-760, 0),
	Vector2(760, 0),
	Vector2(0, -35),
	Vector2(-430, -520),
	Vector2(430, -520),
	Vector2(-690, -460),
	Vector2(690, -460),
	Vector2(0, -700)
]

const WALLS := [
	["EntranceSouth", Vector2(0, 750), Vector2(1060, 72)],
	["EntranceWest", Vector2(-555, 485), Vector2(72, 450)],
	["EntranceEast", Vector2(555, 485), Vector2(72, 450)],
	["EntranceGateLeft", Vector2(-340, 318), Vector2(390, 64)],
	["EntranceGateRight", Vector2(340, 318), Vector2(390, 64)],
	["ArenaSouthLeft", Vector2(-440, 292), Vector2(520, 70)],
	["ArenaSouthRight", Vector2(440, 292), Vector2(520, 70)],
	["ArenaWestLower", Vector2(-760, 145), Vector2(72, 270)],
	["ArenaWestUpper", Vector2(-760, -145), Vector2(72, 270)],
	["ArenaEastLower", Vector2(760, 145), Vector2(72, 270)],
	["ArenaEastUpper", Vector2(760, -145), Vector2(72, 270)],
	["ArenaNorthLeft", Vector2(-420, -294), Vector2(520, 70)],
	["ArenaNorthRight", Vector2(420, -294), Vector2(520, 70)],
	["WestCoverOuter", Vector2(-925, 0), Vector2(70, 360)],
	["EastCoverOuter", Vector2(925, 0), Vector2(70, 360)],
	["AltarSouthLeft", Vector2(-345, -365), Vector2(250, 62)],
	["AltarSouthRight", Vector2(345, -365), Vector2(250, 62)],
	["AltarWest", Vector2(-515, -505), Vector2(70, 280)],
	["AltarEast", Vector2(515, -505), Vector2(70, 280)],
	["AltarNorth", Vector2(0, -690), Vector2(960, 70)],
	["BossSouthLeft", Vector2(-385, -610), Vector2(205, 58)],
	["BossSouthRight", Vector2(385, -610), Vector2(205, 58)],
	["BossWest", Vector2(-515, -720), Vector2(72, 245)],
	["BossEast", Vector2(515, -720), Vector2(72, 245)],
	["BossNorth", Vector2(0, -846), Vector2(1040, 70)]
]

const OBSTACLES := [
	["PillarA", Vector2(-465, -115), Vector2(66, 92), "pillar"],
	["PillarB", Vector2(465, -115), Vector2(66, 92), "pillar"],
	["PillarC", Vector2(-420, 165), Vector2(58, 86), "pillar"],
	["PillarD", Vector2(420, 165), Vector2(58, 86), "pillar"],
	["WestCover", Vector2(-650, 8), Vector2(130, 42), "broken_wall"],
	["EastCover", Vector2(650, 8), Vector2(130, 42), "broken_wall"],
	["CentralReliquary", Vector2(0, -32), Vector2(210, 54), "altar"],
	["AltarBlock", Vector2(0, -525), Vector2(280, 72), "altar"]
]

const TORCHES := [
	Vector2(-430, 515),
	Vector2(430, 515),
	Vector2(-640, 175),
	Vector2(640, 175),
	Vector2(-610, -205),
	Vector2(610, -205),
	Vector2(-310, -555),
	Vector2(310, -555),
	Vector2(-405, -760),
	Vector2(405, -760)
]

const LOOT_SHRINES := [
	{"id": "ash_burst", "pos": Vector2(0, 420)}
]

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
