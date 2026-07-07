extends Node

signal wave_started(index: int, label: String)
signal trial_completed
signal enemies_changed(enemies: Array[Node])

const WAVES := [
	{
		"label": "Wave 1",
		"spawns": [
			{"kind": "guardian", "pos": Vector2(-260, -80)},
			{"kind": "guardian", "pos": Vector2(285, -90)}
		]
	},
	{
		"label": "Wave 2",
		"spawns": [
			{"kind": "hound", "pos": Vector2(-330, 145)},
			{"kind": "guardian", "pos": Vector2(240, -130)}
		]
	},
	{
		"label": "Wave 3",
		"spawns": [
			{"kind": "archer", "pos": Vector2(430, -210)},
			{"kind": "guardian", "pos": Vector2(-260, 90)}
		]
	},
	{
		"label": "Final",
		"spawns": [
			{"kind": "bell_bearer", "pos": Vector2(0, -120)}
		]
	}
]

var guardian_scene: PackedScene
var actor_parent: Node
var player: Node2D
var active_enemies: Array[Node] = []
var wave_index := -1
var completed := false

func configure(scene: PackedScene, parent: Node, player_ref: Node2D) -> void:
	guardian_scene = scene
	actor_parent = parent
	player = player_ref


func start() -> void:
	completed = false
	wave_index = -1
	_start_next_wave()


func _process(_delta: float) -> void:
	if completed:
		return
	active_enemies = active_enemies.filter(func(enemy: Node) -> bool: return is_instance_valid(enemy) and enemy.get("health") > 0.0)
	if active_enemies.is_empty() and wave_index >= 0:
		if wave_index >= WAVES.size() - 1:
			completed = true
			trial_completed.emit()
		else:
			_start_next_wave.call_deferred()


func _start_next_wave() -> void:
	wave_index += 1
	if wave_index >= WAVES.size():
		return
	var wave: Dictionary = WAVES[wave_index]
	active_enemies.clear()
	for spawn_data in wave["spawns"]:
		var enemy: Node = guardian_scene.instantiate()
		enemy.set("enemy_kind", spawn_data["kind"])
		enemy.position = spawn_data["pos"]
		actor_parent.add_child(enemy)
		enemy.set("player", player)
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died.bind(enemy))
		active_enemies.append(enemy)
	wave_started.emit(wave_index, str(wave["label"]))
	enemies_changed.emit(active_enemies)


func _on_enemy_died(enemy: Node) -> void:
	active_enemies.erase(enemy)
	enemies_changed.emit(active_enemies)


func all_enemies() -> Array[Node]:
	return active_enemies.duplicate()
