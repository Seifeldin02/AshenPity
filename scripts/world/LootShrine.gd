extends Area2D

signal collected(boon_id: String, display_name: String)

@export var boon_id := "ember_step"

var _display_name := ""
var _description := ""
var _picked := false
var _pulse := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 38.0
	shape.shape = circle
	add_child(shape)
	var data: Dictionary = GameBalance.BOON_DATA.get(boon_id, {})
	_display_name = str(data.get("display_name", "Ash Boon"))
	_description = str(data.get("description", ""))
	queue_redraw()


func _process(delta: float) -> void:
	if _picked:
		return
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	var glow := 0.38 + sin(_pulse * 4.0) * 0.08
	draw_colored_polygon(_ellipse(Vector2(0, 18), 46.0, 15.0, 28), Color(0.02, 0.015, 0.014, 0.42))
	draw_circle(Vector2.ZERO, 36.0, Color(0.72, 0.34, 0.12, glow * 0.18))
	draw_circle(Vector2.ZERO, 25.0, Color(0.10, 0.075, 0.060, 0.92))
	draw_arc(Vector2.ZERO, 29.0, _pulse * 1.4, _pulse * 1.4 + PI * 1.45, 30, Color(1.0, 0.58, 0.20, 0.78), 3.0)
	draw_arc(Vector2.ZERO, 18.0, -_pulse * 1.9, -_pulse * 1.9 + PI * 1.2, 24, Color(0.86, 0.76, 0.56, 0.58), 2.0)
	var sigil := _sigil_points()
	draw_colored_polygon(sigil, Color(0.94, 0.55, 0.20, 0.88))
	draw_polyline(sigil + PackedVector2Array([sigil[0]]), Color(1.0, 0.86, 0.48, 0.62), 2.0)


func _on_body_entered(body: Node) -> void:
	if _picked or not body.has_method("apply_boon"):
		return
	if not body.apply_boon(boon_id):
		return
	_picked = true
	set_deferred("monitoring", false)
	collected.emit(boon_id, _display_name)
	var audio := get_node_or_null("/root/CombatAudio")
	if audio != null and audio.has_method("play"):
		audio.play("ash_brand", -6.0)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.45, 1.45), 0.12)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.18)
	tween.tween_callback(queue_free)


func _sigil_points() -> PackedVector2Array:
	match boon_id:
		"grave_guard":
			return PackedVector2Array([Vector2(-13, 2), Vector2(0, -18), Vector2(13, 2), Vector2(7, 18), Vector2(-7, 18)])
		"reaper_vow":
			return PackedVector2Array([Vector2(-18, -2), Vector2(-2, -18), Vector2(17, -8), Vector2(10, 12), Vector2(-10, 18)])
		_:
			return PackedVector2Array([Vector2(0, -20), Vector2(15, -2), Vector2(4, 19), Vector2(-16, 3)])


func _ellipse(center: Vector2, radius_x: float, radius_y: float, count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in count:
		var angle := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points
