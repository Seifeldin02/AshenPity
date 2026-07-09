extends RefCounted
class_name ShrineRoute

const CAMERA_LIMIT_LEFT := -2320
const CAMERA_LIMIT_TOP := -1680
const CAMERA_LIMIT_RIGHT := 2320
const CAMERA_LIMIT_BOTTOM := 1320
const CAMERA_ZOOM := Vector2(1.18, 1.18)

const PLAYER_START := Vector2(0, 930)
const GUARDIAN_SPAWNS := [Vector2(-280, -80), Vector2(310, -120), Vector2(120, 160)]

const ENTRANCE := Rect2(-620, 270, 850, 330)
const SOUTH_STEPS := Rect2(-230, 580, 460, 130)
const PILGRIM_COURT := Rect2(-560, 700, 1120, 430)
const SIDE_ALCOVE := Rect2(-875, 340, 290, 170)
const LOWER_PASSAGE := Rect2(-210, 145, 420, 140)
const CENTRAL := Rect2(-820, -305, 1640, 610)
const LEFT_SIDE_PATH := Rect2(-1060, -155, 320, 380)
const RIGHT_SIDE_PATH := Rect2(740, -170, 320, 395)
const UPPER_PASSAGE := Rect2(-210, -365, 420, 115)
const ALTAR := Rect2(-520, -620, 1040, 310)
const WEST_OSSUARY := Rect2(-1420, -650, 560, 500)
const WEST_PASSAGE := Rect2(-900, -455, 360, 180)
const WEST_DEEP_PASSAGE := Rect2(-1590, -505, 190, 220)
const WEST_DEEP_CRYPT := Rect2(-2140, -665, 560, 520)
const EAST_RELIQUARY := Rect2(860, -660, 600, 505)
const EAST_PASSAGE := Rect2(540, -455, 360, 180)
const EAST_DEEP_PASSAGE := Rect2(1400, -505, 190, 220)
const EAST_DEEP_CHAPEL := Rect2(1580, -665, 560, 520)
const NORTH_NAVE := Rect2(-690, -1015, 1380, 360)
const BOSS_SANCTUM := Rect2(-510, -1460, 1020, 390)
const SANCTUM_PASSAGE := Rect2(-235, -1120, 470, 160)

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
	Vector2(-470, 520),
	Vector2(0, 930),
	Vector2(0, 645),
	Vector2(140, 520),
	Vector2(-665, 430),
	Vector2(-900, 0),
	Vector2(900, 0),
	Vector2(0, -35),
	Vector2(-430, -520),
	Vector2(430, -520),
	Vector2(-1240, -420),
	Vector2(-1900, -430),
	Vector2(1240, -425),
	Vector2(1900, -430),
	Vector2(0, -850),
	Vector2(0, -1320)
]

const WALLS := [
	["PilgrimSouth", Vector2(0, 1164), Vector2(1180, 72)],
	["PilgrimWest", Vector2(-598, 920), Vector2(72, 480)],
	["PilgrimEast", Vector2(598, 920), Vector2(72, 480)],
	["PilgrimNorthLeft", Vector2(-360, 666), Vector2(420, 64)],
	["PilgrimNorthRight", Vector2(360, 666), Vector2(420, 64)],
	["EntranceSouthLeft", Vector2(-455, 638), Vector2(330, 70)],
	["EntranceSouthRight", Vector2(280, 638), Vector2(360, 70)],
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
	["CentralNorthLeft", Vector2(-300, -322), Vector2(360, 70)],
	["CentralNorthRight", Vector2(300, -322), Vector2(360, 70)],
	["AltarNorthLeft", Vector2(-410, -664), Vector2(360, 72)],
	["AltarNorthRight", Vector2(410, -664), Vector2(360, 72)],
	["AltarSouthLeft", Vector2(-250, -286), Vector2(190, 70)],
	["AltarSouthRight", Vector2(250, -286), Vector2(190, 70)],
	["WestPassageNorth", Vector2(-720, -504), Vector2(370, 58)],
	["WestPassageSouth", Vector2(-720, -246), Vector2(370, 58)],
	["WestOssuaryWestUpper", Vector2(-1468, -570), Vector2(70, 150)],
	["WestOssuaryWestLower", Vector2(-1468, -235), Vector2(70, 215)],
	["WestOssuaryNorth", Vector2(-1140, -690), Vector2(620, 66)],
	["WestOssuarySouth", Vector2(-1170, -124), Vector2(560, 66)],
	["EastPassageNorth", Vector2(720, -510), Vector2(370, 58)],
	["EastPassageSouth", Vector2(720, -246), Vector2(370, 58)],
	["WestDeepWest", Vector2(-2188, -405), Vector2(72, 540)],
	["WestDeepNorth", Vector2(-1860, -706), Vector2(620, 66)],
	["WestDeepSouth", Vector2(-1870, -110), Vector2(590, 66)],
	["WestDeepPassageNorth", Vector2(-1498, -535), Vector2(190, 58)],
	["WestDeepPassageSouth", Vector2(-1498, -255), Vector2(190, 58)],
	["EastReliquaryEastUpper", Vector2(1510, -570), Vector2(70, 150)],
	["EastReliquaryEastLower", Vector2(1510, -235), Vector2(70, 215)],
	["EastReliquaryNorth", Vector2(1160, -700), Vector2(650, 66)],
	["EastReliquarySouth", Vector2(1170, -124), Vector2(575, 66)],
	["EastDeepEast", Vector2(2188, -405), Vector2(72, 540)],
	["EastDeepNorth", Vector2(1860, -706), Vector2(620, 66)],
	["EastDeepSouth", Vector2(1870, -110), Vector2(590, 66)],
	["EastDeepPassageNorth", Vector2(1498, -535), Vector2(190, 58)],
	["EastDeepPassageSouth", Vector2(1498, -255), Vector2(190, 58)],
	["NaveWest", Vector2(-736, -830), Vector2(72, 370)],
	["NaveEast", Vector2(736, -830), Vector2(72, 370)],
	["NaveNorthLeft", Vector2(-455, -1056), Vector2(560, 66)],
	["NaveNorthRight", Vector2(455, -1056), Vector2(560, 66)],
	["SanctumPassageWest", Vector2(-282, -1040), Vector2(58, 190)],
	["SanctumPassageEast", Vector2(282, -1040), Vector2(58, 190)],
	["BossWest", Vector2(-560, -1265), Vector2(74, 420)],
	["BossEast", Vector2(560, -1265), Vector2(74, 420)],
	["BossNorth", Vector2(0, -1502), Vector2(1120, 72)],
	["BossSouthLeft", Vector2(-315, -1094), Vector2(410, 66)],
	["BossSouthRight", Vector2(315, -1094), Vector2(410, 66)]
]

const OBSTACLES := [
	["PillarA", Vector2(-560, -165), Vector2(58, 82), "pillar"],
	["PillarB", Vector2(560, -165), Vector2(58, 82), "pillar"],
	["PillarC", Vector2(-520, 185), Vector2(58, 82), "pillar"],
	["PillarD", Vector2(520, 185), Vector2(58, 82), "pillar"],
	["BrokenWallA", Vector2(255, 202), Vector2(155, 38), "broken_wall"],
	["BrokenWallB", Vector2(-760, 10), Vector2(145, 38), "broken_wall"],
	["BrokenWallC", Vector2(760, 4), Vector2(145, 38), "broken_wall"],
	["AltarBlock", Vector2(0, -514), Vector2(250, 68), "altar"],
	["OssuaryShelfA", Vector2(-1278, -486), Vector2(130, 46), "broken_wall"],
	["OssuaryShelfB", Vector2(-1018, -292), Vector2(150, 46), "broken_wall"],
	["ReliquaryShelfA", Vector2(1020, -490), Vector2(150, 46), "broken_wall"],
	["ReliquaryShelfB", Vector2(1300, -315), Vector2(150, 46), "broken_wall"],
	["NavePillarA", Vector2(-470, -830), Vector2(58, 82), "pillar"],
	["NavePillarB", Vector2(470, -830), Vector2(58, 82), "pillar"],
	["BossPillarA", Vector2(-330, -1240), Vector2(70, 92), "pillar"],
	["BossPillarB", Vector2(330, -1240), Vector2(70, 92), "pillar"],
	["BossAltar", Vector2(0, -1370), Vector2(250, 70), "altar"],
	["PilgrimBrokenA", Vector2(-300, 870), Vector2(175, 42), "broken_wall"],
	["PilgrimBrokenB", Vector2(330, 965), Vector2(170, 42), "broken_wall"],
	["DeepCryptBoneA", Vector2(-1950, -500), Vector2(150, 44), "broken_wall"],
	["DeepCryptBoneB", Vector2(-1740, -280), Vector2(150, 44), "broken_wall"],
	["DeepChapelShelfA", Vector2(1760, -500), Vector2(150, 44), "broken_wall"],
	["DeepChapelShelfB", Vector2(1980, -300), Vector2(150, 44), "broken_wall"]
]

const TORCHES := [
	Vector2(-545, 330),
	Vector2(-410, 1015),
	Vector2(410, 1015),
	Vector2(0, 690),
	Vector2(165, 310),
	Vector2(-780, 390),
	Vector2(-820, -55),
	Vector2(820, -80),
	Vector2(-660, -225),
	Vector2(660, -225),
	Vector2(-330, -555),
	Vector2(335, -555),
	Vector2(-1340, -570),
	Vector2(-2050, -520),
	Vector2(-1690, -225),
	Vector2(-910, -235),
	Vector2(940, -560),
	Vector2(1690, -225),
	Vector2(2050, -520),
	Vector2(1370, -250),
	Vector2(-610, -900),
	Vector2(610, -900),
	Vector2(-405, -1380),
	Vector2(405, -1380)
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
