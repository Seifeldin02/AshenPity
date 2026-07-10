extends Node2D

const Route := preload("res://scripts/world/ShrineRoute.gd")

@export_enum("ground", "decals", "shadows", "foreground") var layer_kind := "ground"

var _rng := RandomNumberGenerator.new()
var _cracks: Array[PackedVector2Array] = []
var _ash: Array[Vector2] = []
var _floor_cells: Array[Dictionary] = []
var _textures := {}

func _ready() -> void:
	_rng.seed = 1717
	_load_textures()
	_build_marks()
	_build_floor_cells()
	queue_redraw()


func _draw() -> void:
	match layer_kind:
		"ground":
			_draw_ground()
		"decals":
			_draw_decals()
		"shadows":
			_draw_shadows()
		"foreground":
			_draw_foreground()


func _draw_ground() -> void:
	_draw_exterior_courtyard()
	for room in Route.ROOMS:
		if room.size.x <= 2.0 or room.size.y <= 2.0:
			continue
		_draw_room_floor(room)
	_draw_irregular_edges()
	_draw_room_trim(Route.ENTRANCE, Color("#413944"))
	_draw_room_trim(Route.PILGRIM_COURT, Color("#3d3636"))
	_draw_room_trim(Route.SOUTH_STEPS, Color("#463c3a"))
	_draw_room_trim(Route.SIDE_ALCOVE, Color("#3b333b"))
	_draw_room_trim(Route.LEFT_SIDE_PATH, Color("#332d36"))
	_draw_room_trim(Route.RIGHT_SIDE_PATH, Color("#332d36"))
	_draw_room_trim(Route.CENTRAL, Color("#493f43"))
	_draw_room_trim(Route.ALTAR, Color("#514347"))
	_draw_room_trim(Route.WEST_OSSUARY, Color("#3b3431"))
	_draw_room_trim(Route.WEST_DEEP_CRYPT, Color("#322c2b"))
	_draw_room_trim(Route.EAST_RELIQUARY, Color("#3c3740"))
	_draw_room_trim(Route.EAST_DEEP_CHAPEL, Color("#393540"))
	_draw_room_trim(Route.NORTH_NAVE, Color("#403940"))
	_draw_room_trim(Route.BOSS_SANCTUM, Color("#4a3537"))
	_draw_route_runners()
	_draw_stairs()
	_draw_landmark()
	_draw_room_landmarks()


func _draw_decals() -> void:
	for crack in _cracks:
		_draw_crack_shape(crack)
	for i in _ash.size():
		var point := _ash[i]
		if PerformanceStats.lightweight_mode and int(point.x + point.y) % 2 == 0:
			continue
		draw_circle(point, 1.0 + float(i % 3) * 0.35, Color(0.78, 0.70, 0.58, 0.075))
	for torch_pos in Route.TORCHES:
		_draw_light_pool(torch_pos, 145.0)


func _draw_shadows() -> void:
	for wall in Route.WALLS:
		var center: Vector2 = wall[1]
		var size: Vector2 = wall[2]
		draw_rect(Rect2(center - size * 0.5 + Vector2(10, 14), size), Color(0.02, 0.016, 0.020, 0.34))
	for obstacle in Route.OBSTACLES:
		var center: Vector2 = obstacle[1]
		var size: Vector2 = obstacle[2]
		draw_colored_polygon(_ellipse(center + Vector2(0, size.y * 0.54), size.x * 0.62, 14.0), Color(0.02, 0.016, 0.020, 0.42))
	draw_colored_polygon(PackedVector2Array([Vector2(-760, -220), Vector2(-610, -260), Vector2(-560, 220), Vector2(-770, 250)]), Color(0.02, 0.016, 0.02, 0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(610, -260), Vector2(760, -220), Vector2(770, 250), Vector2(560, 220)]), Color(0.02, 0.016, 0.02, 0.12))


func _draw_foreground() -> void:
	draw_rect(Rect2(-500, Route.CAMERA_LIMIT_TOP - 36, 1000, 48), Color("#100e13"))
	draw_line(Vector2(-440, Route.CAMERA_LIMIT_TOP + 12), Vector2(440, Route.CAMERA_LIMIT_TOP + 12), Color(0.52, 0.43, 0.35, 0.18), 4.0)


func _draw_room_floor(room: Rect2) -> void:
	var base_tint := Color("#2c2927")
	var texture_tint := Color(0.60, 0.56, 0.50, 0.82)
	if room == Route.ALTAR:
		base_tint = Color("#332b29")
		texture_tint = Color(0.68, 0.58, 0.52, 0.88)
	elif room == Route.PILGRIM_COURT or room == Route.SOUTH_STEPS:
		base_tint = Color("#2f2825")
		texture_tint = Color(0.64, 0.54, 0.46, 0.84)
	elif room == Route.SIDE_ALCOVE or room == Route.LEFT_SIDE_PATH or room == Route.RIGHT_SIDE_PATH:
		base_tint = Color("#29272b")
		texture_tint = Color(0.52, 0.52, 0.56, 0.82)
	elif room == Route.WEST_OSSUARY or room == Route.WEST_DEEP_CRYPT:
		base_tint = Color("#292622")
		texture_tint = Color(0.54, 0.49, 0.42, 0.82)
	elif room == Route.EAST_RELIQUARY or room == Route.EAST_DEEP_CHAPEL:
		base_tint = Color("#292932")
		texture_tint = Color(0.52, 0.53, 0.59, 0.82)
	elif room == Route.BOSS_SANCTUM:
		base_tint = Color("#332222")
		texture_tint = Color(0.70, 0.45, 0.42, 0.86)
	draw_rect(room.grow(24.0), Color("#17151b"))
	draw_rect(room, base_tint)
	_draw_tiled_texture(_room_floor_texture(room), room, texture_tint)
	draw_rect(room, Color(0.03, 0.026, 0.026, 0.20))
	_draw_floor_edge_shade(room)


func _draw_room_trim(room: Rect2, color: Color) -> void:
	var trim := Color(color.r, color.g, color.b, 0.22)
	draw_rect(room.grow(-2.0), trim, false, 2.0)


func _draw_exterior_courtyard() -> void:
	var bounds := Rect2(Vector2(Route.CAMERA_LIMIT_LEFT - 260, Route.CAMERA_LIMIT_TOP - 180), Vector2(Route.CAMERA_LIMIT_RIGHT - Route.CAMERA_LIMIT_LEFT + 520, Route.CAMERA_LIMIT_BOTTOM - Route.CAMERA_LIMIT_TOP + 360))
	draw_rect(bounds, Color("#151219"))
	var tile := 120.0
	var y := bounds.position.y
	while y < bounds.end.y:
		var x := bounds.position.x
		while x < bounds.end.x:
			var hash := int(abs(x * 5.0 + y * 11.0)) % 4
			var shade := 0.06 + float(hash) * 0.005
			draw_rect(Rect2(x, y, tile, tile), Color(shade, shade * 0.92, shade * 0.86, 1.0))
			draw_rect(Rect2(x + 3, y + 3, tile - 6, tile - 6), Color(0.02, 0.018, 0.022, 0.12), false, 2.0)
			x += tile
		y += tile
	for i in 10:
		var x_pos := Route.CAMERA_LIMIT_LEFT - 160.0 + float(i) * 520.0
		draw_rect(Rect2(x_pos, Route.CAMERA_LIMIT_TOP - 90.0, 180.0, Route.CAMERA_LIMIT_BOTTOM - Route.CAMERA_LIMIT_TOP + 180.0), Color(0.025, 0.022, 0.028, 0.18))


func _draw_irregular_edges() -> void:
	var left_apron := PackedVector2Array([Vector2(-1050, -165), Vector2(-790, -250), Vector2(-700, 80), Vector2(-805, 270), Vector2(-1045, 240)])
	var right_apron := PackedVector2Array([Vector2(790, -260), Vector2(1060, -165), Vector2(1065, 255), Vector2(815, 285), Vector2(710, 82)])
	var altar_apron := PackedVector2Array([Vector2(-600, -620), Vector2(600, -620), Vector2(520, -275), Vector2(210, -230), Vector2(0, -325), Vector2(-210, -230), Vector2(-520, -275)])
	draw_colored_polygon(left_apron, Color("#25232a"))
	draw_colored_polygon(right_apron, Color("#25232a"))
	draw_colored_polygon(altar_apron, Color("#2b252b"))
	draw_polyline(left_apron + PackedVector2Array([left_apron[0]]), Color(0.32, 0.29, 0.32, 0.22), 3.0)
	draw_polyline(right_apron + PackedVector2Array([right_apron[0]]), Color(0.32, 0.29, 0.32, 0.22), 3.0)
	draw_polyline(altar_apron + PackedVector2Array([altar_apron[0]]), Color(0.36, 0.31, 0.32, 0.22), 3.0)


func _draw_route_runners() -> void:
	_draw_runner(Rect2(-118, -620, 236, 1185), Color(0.16, 0.105, 0.085, 0.36))
	_draw_runner(Rect2(-650, -110, 1300, 220), Color(0.12, 0.095, 0.105, 0.28))
	_draw_runner(Rect2(-345, -585, 690, 155), Color(0.17, 0.12, 0.11, 0.32))
	for marker in [Vector2(0, 420), Vector2(0, -38), Vector2(0, -505)]:
		_draw_floor_medallion(marker)


func _draw_runner(rect: Rect2, tint: Color) -> void:
	draw_rect(rect, Color(0.025, 0.020, 0.022, tint.a * 0.52))
	_draw_tiled_texture(_textures.get("floor_warm"), rect.grow(-8.0), tint)
	draw_rect(rect.grow(-8.0), Color(0.03, 0.018, 0.016, 0.12))
	draw_line(rect.position + Vector2(10, 8), Vector2(rect.end.x - 10, rect.position.y + 8), Color(0.74, 0.50, 0.32, 0.10), 3.0)
	draw_line(Vector2(rect.position.x + 10, rect.end.y - 8), rect.end - Vector2(10, 8), Color(0.02, 0.014, 0.012, 0.24), 4.0)


func _draw_floor_medallion(center: Vector2) -> void:
	draw_colored_polygon(_ellipse(center + Vector2(18, 20), 138.0, 38.0), Color(0.02, 0.014, 0.013, 0.30))
	draw_arc(center, 82.0, 0.2, TAU - 0.2, 58, Color(0.72, 0.38, 0.18, 0.30), 8.0)
	draw_arc(center, 52.0, -0.7, PI * 1.28, 42, Color(0.90, 0.58, 0.26, 0.22), 4.0)
	var dir_a := Vector2.RIGHT.rotated(0.72)
	var dir_b := Vector2.RIGHT.rotated(-0.72)
	draw_line(center - dir_a * 70.0, center + dir_a * 70.0, Color(0.04, 0.025, 0.022, 0.44), 5.0)
	draw_line(center - dir_b * 70.0, center + dir_b * 70.0, Color(0.04, 0.025, 0.022, 0.44), 5.0)


func _draw_stairs() -> void:
	_draw_texture_centered(_textures.get("stairs"), Vector2(0, 300), Vector2(1.08, 0.58), Color(0.86, 0.78, 0.72, 0.82))
	_draw_texture_centered(_textures.get("stairs"), Vector2(0, -388), Vector2(1.12, 0.66), Color(0.95, 0.90, 0.86, 0.88))


func _draw_landmark() -> void:
	_draw_texture_centered(_textures.get("brazier"), Vector2(0, -42), Vector2(1.22, 1.22), Color.WHITE)


func _draw_room_landmarks() -> void:
	_draw_texture_centered(_textures.get("bone_debris"), Vector2(-650, -410), Vector2(0.82, 0.82), Color(0.90, 0.84, 0.78, 0.62))
	_draw_texture_centered(_textures.get("bone_debris"), Vector2(650, -410), Vector2(0.82, 0.82), Color(0.90, 0.84, 0.78, 0.62))
	_draw_texture_centered(_textures.get("reliquary"), Vector2(-708, 0), Vector2(0.58, 0.58), Color(0.88, 0.82, 0.76, 0.82))
	_draw_texture_centered(_textures.get("reliquary"), Vector2(708, 0), Vector2(0.58, 0.58), Color(0.88, 0.82, 0.76, 0.82))
	_draw_texture_centered(_textures.get("sealed_door"), Vector2(0, -775), Vector2(1.18, 0.96), Color(0.90, 0.78, 0.72, 0.92))
	_draw_texture_centered(_textures.get("brazier"), Vector2(0, -522), Vector2(0.94, 0.94), Color(1.0, 0.88, 0.78, 0.88))


func _draw_light_pool(center: Vector2, radius: float) -> void:
	for i in 5:
		var t := float(i) / 7.0
		draw_circle(center, radius * (1.0 - t * 0.12), Color(0.96, 0.42, 0.16, 0.020 * (1.0 - t)))


func _build_marks() -> void:
	for i in 18:
		var room: Rect2 = Route.ROOMS[_rng.randi_range(0, Route.ROOMS.size() - 1)]
		var origin := room.position + Vector2(_rng.randf_range(30.0, room.size.x - 30.0), _rng.randf_range(30.0, room.size.y - 30.0))
		var crack := PackedVector2Array()
		crack.append(origin)
		var direction := Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
		for s in range(1, _rng.randi_range(3, 6)):
			crack.append(origin + direction * float(s) * _rng.randf_range(15.0, 31.0) + Vector2(_rng.randf_range(-8, 8), _rng.randf_range(-8, 8)))
		_cracks.append(crack)
	for i in 150:
		var room: Rect2 = Route.ROOMS[_rng.randi_range(0, Route.ROOMS.size() - 1)]
		_ash.append(room.position + Vector2(_rng.randf_range(0.0, room.size.x), _rng.randf_range(0.0, room.size.y)))


func _build_floor_cells() -> void:
	_floor_cells.clear()
	var floor_rng := RandomNumberGenerator.new()
	floor_rng.seed = 42111
	for room in Route.ROOMS:
		var slab := 96.0
		var y: float = floor(room.position.y / slab) * slab
		while y < room.end.y:
			var row_offset := 0.0 if int(y / slab) % 2 == 0 else slab * 0.34
			var x: float = floor(room.position.x / slab) * slab - row_offset
			while x < room.end.x:
				var shrink := floor_rng.randf_range(1.0, 4.0)
				var rect := Rect2(Vector2(x, y), Vector2(slab + floor_rng.randf_range(-10.0, 18.0), slab + floor_rng.randf_range(-14.0, 12.0))).grow(-shrink).intersection(room)
				if rect.size.x > 18.0 and rect.size.y > 18.0:
					var roll := floor_rng.randf()
					var shade := floor_rng.randf_range(0.19, 0.245)
					var warm := floor_rng.randf_range(-0.006, 0.014)
					if room == Route.BOSS_SANCTUM:
						warm += 0.035
					elif room == Route.PILGRIM_COURT or room == Route.SOUTH_STEPS:
						warm += 0.018
					elif room == Route.EAST_RELIQUARY or room == Route.EAST_DEEP_CHAPEL:
						shade += 0.006
					elif room == Route.WEST_OSSUARY or room == Route.WEST_DEEP_CRYPT:
						shade -= 0.018
					_floor_cells.append({
						"room": room,
						"rect": rect,
						"color": Color(shade + warm, shade * floor_rng.randf_range(0.92, 0.98), shade * floor_rng.randf_range(0.84, 0.92), 0.88),
						"worn": floor_rng.randf() < 0.10 or roll > 0.94
					})
				x += slab
			y += slab


func _load_textures() -> void:
	_textures = {
		"floor_a": _load_texture("res://assets/environment/sbs_dungeon/floor_stone_a.png"),
		"floor_b": _load_texture("res://assets/environment/sbs_dungeon/floor_stone_b.png"),
		"floor_warm": _load_texture("res://assets/environment/sbs_dungeon/floor_stone_warm.png"),
		"floor_ash": _load_texture("res://assets/environment/sbs_dungeon/floor_ash_dirt.png"),
		"stairs": _load_texture("res://assets/environment/upgrade/altar_stairs.png"),
		"brazier": _load_texture("res://assets/environment/upgrade/ash_brazier.png"),
		"sealed_door": _load_texture("res://assets/environment/upgrade/sealed_door.png"),
		"bone_debris": _load_texture("res://assets/environment/upgrade/bone_debris.png"),
		"reliquary": _load_texture("res://assets/environment/upgrade/reliquary_shelf.png"),
	}


func _draw_tiled_texture(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	if texture == null:
		return
	draw_texture_rect(texture, rect, true, tint)


func _room_floor_texture(room: Rect2) -> Texture2D:
	if room == Route.WEST_OSSUARY or room == Route.WEST_DEEP_CRYPT:
		return _textures.get("floor_ash")
	if room == Route.ALTAR or room == Route.BOSS_SANCTUM:
		return _textures.get("floor_warm")
	if room == Route.EAST_RELIQUARY or room == Route.EAST_DEEP_CHAPEL:
		return _textures.get("floor_b")
	return _textures.get("floor_a")


func _draw_floor_edge_shade(room: Rect2) -> void:
	draw_rect(Rect2(room.position, Vector2(room.size.x, 28.0)), Color(0.03, 0.026, 0.024, 0.26))
	draw_rect(Rect2(Vector2(room.position.x, room.end.y - 30.0), Vector2(room.size.x, 30.0)), Color(0.01, 0.009, 0.011, 0.28))
	draw_rect(Rect2(room.position, Vector2(26.0, room.size.y)), Color(0.01, 0.009, 0.011, 0.20))
	draw_rect(Rect2(Vector2(room.end.x - 26.0, room.position.y), Vector2(26.0, room.size.y)), Color(0.01, 0.009, 0.011, 0.20))


func _draw_texture_centered(texture: Texture2D, center: Vector2, scale_value: Vector2, tint: Color) -> void:
	if texture == null:
		return
	var size := texture.get_size() * scale_value
	draw_texture_rect(texture, Rect2(center - size * 0.5, size), false, tint)


func _load_texture(path: String) -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 32:
		var angle := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points


func _draw_crack_shape(points: PackedVector2Array) -> void:
	if points.size() < 2:
		return
	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]
		var dir := (b - a).normalized()
		var side := dir.orthogonal()
		var width := 3.0 + float(i % 2)
		draw_colored_polygon(PackedVector2Array([
			a - side * width,
			a + side * width * 0.6,
			b + side * width,
			b - side * width * 0.5,
		]), Color(0.025, 0.022, 0.026, 0.32))
		if i % 2 == 0:
			var mid := a.lerp(b, 0.55)
			var chip := PackedVector2Array([
				mid,
				mid + side * width * 2.8 + dir * 7.0,
				mid + side * width * 1.2 - dir * 9.0,
			])
			draw_colored_polygon(chip, Color(0.09, 0.075, 0.064, 0.12))
