extends Area2D

var direction := Vector2.RIGHT
var speed := 430.0
var damage := 12.0
var knockback := 180.0
var lifetime := 2.4
var source_enemy: Node

var _age := 0.0
var _hit := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	global_position += direction.normalized() * speed * delta


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var dir := direction.normalized() if direction.length() > 0.001 else Vector2.RIGHT
	var side := dir.orthogonal()
	draw_colored_polygon(PackedVector2Array([
		dir * 25.0,
		-dir * 10.0 + side * 7.0,
		-dir * 22.0,
		-dir * 10.0 - side * 7.0,
	]), Color(0.92, 0.58, 0.22, 0.86))
	draw_colored_polygon(PackedVector2Array([
		dir * 15.0,
		-dir * 5.0 + side * 3.0,
		-dir * 12.0,
		-dir * 5.0 - side * 3.0,
	]), Color(1.0, 0.86, 0.48, 0.76))


func _on_body_entered(body: Node) -> void:
	if _hit:
		return
	var brand_source := source_enemy if is_instance_valid(source_enemy) else self
	if body.has_method("try_parry") and body.try_parry(brand_source, global_position):
		_hit = true
		queue_free()
		return
	if body.has_method("try_perfect_dodge") and body.try_perfect_dodge(brand_source, global_position):
		_hit = true
		queue_free()
		return
	if body.has_method("take_damage"):
		_hit = true
		body.take_damage(damage, global_position, knockback)
		queue_free()
