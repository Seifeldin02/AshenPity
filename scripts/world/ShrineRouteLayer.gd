extends Node2D

const Route := preload("res://scripts/world/ShrineRoute.gd")

@export_enum("ground", "decals", "shadows", "foreground") var layer_kind := "ground"

var _rng := RandomNumberGenerator.new()
var _cracks: Array[PackedVector2Array] = []
var _ash: Array[Vector2] = []

func _ready() -> void:
	_rng.seed = 1717
	_build_marks()
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
	draw_rect(Rect2(Vector2(Route.CAMERA_LIMIT_LEFT - 220, Route.CAMERA_LIMIT_TOP - 160), Vector2(Route.CAMERA_LIMIT_RIGHT - Route.CAMERA_LIMIT_LEFT + 440, Route.CAMERA_LIMIT_BOTTOM - Route.CAMERA_LIMIT_TOP + 320)), Color("#17141a"))
	for room in Route.ROOMS:
		_draw_room_floor(room)
	_draw_room_trim(Route.ENTRANCE, Color("#37313a"))
	_draw_room_trim(Route.SIDE_ALCOVE, Color("#302a31"))
	_draw_room_trim(Route.CENTRAL, Color("#3b343b"))
	_draw_room_trim(Route.ALTAR, Color("#463c40"))
	_draw_stairs()
	_draw_landmark()


func _draw_decals() -> void:
	for crack in _cracks:
		draw_polyline(crack, Color(0.035, 0.030, 0.034, 0.78), 3.0)
		draw_polyline(crack, Color(0.56, 0.49, 0.39, 0.12), 1.0)
	for point in _ash:
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


func _draw_foreground() -> void:
	draw_rect(Rect2(-430, Route.CAMERA_LIMIT_TOP - 40, 860, 52), Color("#121015"))
	draw_line(Vector2(-395, Route.CAMERA_LIMIT_TOP + 14), Vector2(395, Route.CAMERA_LIMIT_TOP + 14), Color(0.52, 0.43, 0.35, 0.22), 4.0)


func _draw_room_floor(room: Rect2) -> void:
	var tile := 80.0
	var start_x: float = floor(room.position.x / tile) * tile
	var end_x: float = room.end.x
	var start_y: float = floor(room.position.y / tile) * tile
	var end_y: float = room.end.y
	draw_rect(room.grow(20.0), Color("#211e25"))
	var y: float = start_y
	while y < end_y:
		var x: float = start_x
		while x < end_x:
			var rect := Rect2(x, y, tile, tile).intersection(room)
			if rect.size.x > 1.0 and rect.size.y > 1.0:
				var hash := int(abs(x * 3.0 + y * 7.0)) % 5
				var shade := 0.145 + float(hash) * 0.008
				draw_rect(rect, Color(shade, shade * 0.96, shade * 0.91, 1.0))
				draw_rect(rect.grow(-2.0), Color(0.02, 0.018, 0.021, 0.18), false, 2.0)
			x += tile
		y += tile


func _draw_room_trim(room: Rect2, color: Color) -> void:
	draw_rect(room, color, false, 8.0)
	draw_rect(room.grow(-12.0), Color(0.08, 0.07, 0.08, 0.45), false, 3.0)


func _draw_stairs() -> void:
	for i in 5:
		var y := -310.0 - float(i) * 26.0
		var width := 340.0 - float(i) * 24.0
		draw_rect(Rect2(-width * 0.5, y, width, 18), Color(0.20, 0.18, 0.20, 1.0))
		draw_line(Vector2(-width * 0.5, y), Vector2(width * 0.5, y), Color(0.48, 0.42, 0.36, 0.23), 2.0)


func _draw_landmark() -> void:
	draw_colored_polygon(_ellipse(Vector2(0, -28), 112.0, 54.0), Color("#252229"))
	draw_colored_polygon(_ellipse(Vector2(0, -35), 70.0, 32.0), Color("#3b3130"))
	draw_arc(Vector2(0, -35), 64.0, 0.2, TAU - 0.4, 42, Color(0.80, 0.45, 0.23, 0.36), 7.0)
	draw_line(Vector2(-38, -70), Vector2(22, 4), Color("#17141a"), 5.0)
	draw_line(Vector2(42, -61), Vector2(-12, -4), Color("#17141a"), 4.0)


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


func _ellipse(center: Vector2, radius_x: float, radius_y: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 32:
		var angle := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
