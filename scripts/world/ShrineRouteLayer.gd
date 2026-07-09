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
		_draw_room_floor(room)
	_draw_irregular_edges()
	_draw_room_trim(Route.ENTRANCE, Color("#413944"))
	_draw_room_trim(Route.SIDE_ALCOVE, Color("#3b333b"))
	_draw_room_trim(Route.LEFT_SIDE_PATH, Color("#332d36"))
	_draw_room_trim(Route.RIGHT_SIDE_PATH, Color("#332d36"))
	_draw_room_trim(Route.CENTRAL, Color("#493f43"))
	_draw_room_trim(Route.ALTAR, Color("#514347"))
	_draw_room_trim(Route.WEST_OSSUARY, Color("#3b3431"))
	_draw_room_trim(Route.EAST_RELIQUARY, Color("#3c3740"))
	_draw_room_trim(Route.NORTH_NAVE, Color("#403940"))
	_draw_room_trim(Route.BOSS_SANCTUM, Color("#4a3537"))
	_draw_stairs()
	_draw_landmark()
	_draw_room_landmarks()


func _draw_decals() -> void:
	for crack in _cracks:
		draw_polyline(crack, Color(0.035, 0.030, 0.034, 0.78), 3.0)
		draw_polyline(crack, Color(0.56, 0.49, 0.39, 0.12), 1.0)
	for point in _ash:
		if PerformanceStats.lightweight_mode and int(point.x + point.y) % 2 == 0:
			continue
		draw_circle(point, _rng.randf_range(1.0, 2.2), Color(0.75, 0.70, 0.62, 0.13))
	for torch_pos in Route.TORCHES:
		_draw_light_pool(torch_pos, 170.0)


func _draw_shadows() -> void:
	for wall in Route.WALLS:
		var center: Vector2 = wall[1]
		var size: Vector2 = wall[2]
		draw_rect(Rect2(center - size * 0.5 + Vector2(10, 14), size), Color(0.02, 0.016, 0.020, 0.34))
	for obstacle in Route.OBSTACLES:
		var center: Vector2 = obstacle[1]
		var size: Vector2 = obstacle[2]
		draw_colored_polygon(_ellipse(center + Vector2(0, size.y * 0.54), size.x * 0.62, 14.0), Color(0.02, 0.016, 0.020, 0.42))
	draw_colored_polygon(PackedVector2Array([Vector2(-1030, -170), Vector2(-760, -260), Vector2(-720, 230), Vector2(-1025, 230)]), Color(0.02, 0.016, 0.02, 0.12))
	draw_colored_polygon(PackedVector2Array([Vector2(760, -275), Vector2(1030, -190), Vector2(1025, 245), Vector2(720, 230)]), Color(0.02, 0.016, 0.02, 0.12))


func _draw_foreground() -> void:
	draw_rect(Rect2(-430, Route.CAMERA_LIMIT_TOP - 40, 860, 52), Color("#121015"))
	draw_line(Vector2(-395, Route.CAMERA_LIMIT_TOP + 14), Vector2(395, Route.CAMERA_LIMIT_TOP + 14), Color(0.52, 0.43, 0.35, 0.22), 4.0)


func _draw_room_floor(room: Rect2) -> void:
	var base_tint := Color(0.70, 0.66, 0.64, 0.82)
	if room == Route.ALTAR:
		base_tint = Color(0.82, 0.72, 0.66, 0.90)
	elif room == Route.SIDE_ALCOVE or room == Route.LEFT_SIDE_PATH or room == Route.RIGHT_SIDE_PATH:
		base_tint = Color(0.58, 0.55, 0.58, 0.82)
	elif room == Route.WEST_OSSUARY:
		base_tint = Color(0.60, 0.55, 0.49, 0.86)
	elif room == Route.EAST_RELIQUARY:
		base_tint = Color(0.64, 0.60, 0.66, 0.84)
	elif room == Route.BOSS_SANCTUM:
		base_tint = Color(0.76, 0.56, 0.54, 0.90)
	draw_rect(room.grow(24.0), Color("#17151b"))
	_draw_tiled_texture(_textures.get("floor_a"), room, Color(base_tint.r, base_tint.g, base_tint.b, 0.28))
	for cell in _floor_cells:
		if cell["room"] != room:
			continue
		var rect: Rect2 = cell["rect"]
		draw_rect(rect, cell["color"])
		draw_rect(rect.grow(-2.0), Color(0.02, 0.018, 0.020, 0.075), false, 1.0)
		if bool(cell["worn"]):
			_draw_tiled_texture(_textures.get("floor_c"), rect, Color(0.72, 0.68, 0.60, 0.055))
	for i in 3:
		var band_y := room.position.y + room.size.y * (0.28 + float(i) * 0.20)
		draw_line(Vector2(room.position.x + 25, band_y), Vector2(room.end.x - 25, band_y + sin(float(i) * 1.8) * 18.0), Color(0.50, 0.42, 0.32, 0.022), 18.0)


func _draw_room_trim(room: Rect2, color: Color) -> void:
	draw_rect(room, color, false, 8.0)
	draw_rect(room.grow(-12.0), Color(0.08, 0.07, 0.08, 0.45), false, 3.0)


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
			if hash == 1:
				_draw_tiled_texture(_textures.get("floor_b"), Rect2(x, y, tile, tile), Color(0.36, 0.34, 0.36, 0.18))
			draw_rect(Rect2(x + 3, y + 3, tile - 6, tile - 6), Color(0.02, 0.018, 0.022, 0.12), false, 2.0)
			x += tile
		y += tile
	for i in 18:
		var x_pos := -1120.0 + float(i) * 132.0
		draw_line(Vector2(x_pos, Route.CAMERA_LIMIT_TOP - 140), Vector2(x_pos + 76.0, Route.CAMERA_LIMIT_BOTTOM + 125), Color(0.04, 0.035, 0.042, 0.42), 2.0)


func _draw_irregular_edges() -> void:
	var left_apron := PackedVector2Array([Vector2(-1050, -165), Vector2(-790, -250), Vector2(-700, 80), Vector2(-805, 270), Vector2(-1045, 240)])
	var right_apron := PackedVector2Array([Vector2(790, -260), Vector2(1060, -165), Vector2(1065, 255), Vector2(815, 285), Vector2(710, 82)])
	var altar_apron := PackedVector2Array([Vector2(-600, -620), Vector2(600, -620), Vector2(520, -275), Vector2(210, -230), Vector2(0, -325), Vector2(-210, -230), Vector2(-520, -275)])
	draw_colored_polygon(left_apron, Color("#25232a"))
	draw_colored_polygon(right_apron, Color("#25232a"))
	draw_colored_polygon(altar_apron, Color("#2b252b"))
	draw_polyline(left_apron + PackedVector2Array([left_apron[0]]), Color("#4a4149"), 5.0)
	draw_polyline(right_apron + PackedVector2Array([right_apron[0]]), Color("#4a4149"), 5.0)
	draw_polyline(altar_apron + PackedVector2Array([altar_apron[0]]), Color("#56484c"), 6.0)
	draw_line(Vector2(-640, 0), Vector2(-300, 0), Color(0.78, 0.58, 0.32, 0.12), 10.0)
	draw_line(Vector2(300, 0), Vector2(640, 0), Color(0.78, 0.58, 0.32, 0.12), 10.0)


func _draw_stairs() -> void:
	_draw_texture_centered(_textures.get("stairs"), Vector2(0, -360), Vector2(1.18, 0.72), Color(0.95, 0.90, 0.86, 0.90))
	_draw_texture_centered(_textures.get("stairs"), Vector2(0, -1125), Vector2(1.35, 0.78), Color(0.95, 0.84, 0.78, 0.92))


func _draw_landmark() -> void:
	_draw_texture_centered(_textures.get("brazier"), Vector2(0, -36), Vector2(1.2, 1.2), Color.WHITE)


func _draw_room_landmarks() -> void:
	_draw_texture_centered(_textures.get("bone_debris"), Vector2(-1260, -410), Vector2(1.0, 1.0), Color(0.90, 0.84, 0.78, 0.78))
	_draw_texture_centered(_textures.get("bone_debris"), Vector2(-1040, -540), Vector2(0.78, 0.78), Color(0.80, 0.76, 0.70, 0.62))
	_draw_texture_centered(_textures.get("reliquary"), Vector2(1095, -470), Vector2(1.05, 1.05), Color(0.84, 0.80, 0.88, 0.86))
	_draw_texture_centered(_textures.get("reliquary"), Vector2(1325, -305), Vector2(0.90, 0.90), Color(0.82, 0.78, 0.86, 0.82))
	_draw_texture_centered(_textures.get("sealed_door"), Vector2(0, -1405), Vector2(1.35, 1.15), Color(0.90, 0.78, 0.72, 0.92))
	_draw_texture_centered(_textures.get("brazier"), Vector2(0, -1260), Vector2(0.92, 0.92), Color(1.0, 0.88, 0.78, 0.88))


func _draw_light_pool(center: Vector2, radius: float) -> void:
	for i in 7:
		var t := float(i) / 7.0
		draw_circle(center, radius * (1.0 - t * 0.1), Color(0.96, 0.42, 0.16, 0.026 * (1.0 - t)))


func _build_marks() -> void:
	for i in 46:
		var room: Rect2 = Route.ROOMS[_rng.randi_range(0, Route.ROOMS.size() - 1)]
		var origin := room.position + Vector2(_rng.randf_range(30.0, room.size.x - 30.0), _rng.randf_range(30.0, room.size.y - 30.0))
		var crack := PackedVector2Array()
		crack.append(origin)
		var direction := Vector2.RIGHT.rotated(_rng.randf_range(-PI, PI))
		for s in range(1, _rng.randi_range(3, 6)):
			crack.append(origin + direction * float(s) * _rng.randf_range(15.0, 31.0) + Vector2(_rng.randf_range(-8, 8), _rng.randf_range(-8, 8)))
		_cracks.append(crack)
	for i in 260:
		var room: Rect2 = Route.ROOMS[_rng.randi_range(0, Route.ROOMS.size() - 1)]
		_ash.append(room.position + Vector2(_rng.randf_range(0.0, room.size.x), _rng.randf_range(0.0, room.size.y)))


func _build_floor_cells() -> void:
	_floor_cells.clear()
	var floor_rng := RandomNumberGenerator.new()
	floor_rng.seed = 42111
	for room in Route.ROOMS:
		var y: float = room.position.y
		while y < room.end.y - 12.0:
			var row_height: float = floor_rng.randf_range(68.0, 118.0)
			var x: float = room.position.x
			while x < room.end.x - 12.0:
				var width: float = floor_rng.randf_range(72.0, 132.0)
				var jitter := Vector2(floor_rng.randf_range(-7.0, 7.0), floor_rng.randf_range(-5.0, 5.0))
				var rect := Rect2(Vector2(x, y) + jitter, Vector2(width, row_height)).intersection(room.grow(-8.0))
				if rect.size.x > 20.0 and rect.size.y > 20.0:
					var shade: float = floor_rng.randf_range(0.19, 0.255)
					var warm: float = floor_rng.randf_range(-0.006, 0.010)
					if room == Route.ALTAR:
						warm += 0.010
					elif room == Route.SIDE_ALCOVE or room == Route.LEFT_SIDE_PATH or room == Route.RIGHT_SIDE_PATH:
						shade *= 0.88
					elif room == Route.WEST_OSSUARY:
						shade *= 0.86
					elif room == Route.BOSS_SANCTUM:
						warm += 0.018
					_floor_cells.append({
						"room": room,
						"rect": rect,
						"color": Color(shade + warm, shade * floor_rng.randf_range(0.92, 0.98), shade * floor_rng.randf_range(0.86, 0.94), 0.46),
						"worn": floor_rng.randf() < 0.18
					})
				x += width + floor_rng.randf_range(-8.0, 12.0)
			y += row_height + floor_rng.randf_range(-8.0, 12.0)


func _load_textures() -> void:
	_textures = {
		"floor_a": _load_texture("res://assets/environment/upgrade/floor_stone_a.png"),
		"floor_b": _load_texture("res://assets/environment/upgrade/floor_stone_b.png"),
		"floor_c": _load_texture("res://assets/environment/upgrade/floor_stone_c.png"),
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
