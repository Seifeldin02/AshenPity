extends Node

signal wave_started(index: int, label: String)
signal trial_completed
signal enemies_changed(enemies: Array[Node])

const WAVES := [
	{
		"label": "Stage 1 - Shrine Wake",
		"spawns": [
			{"kind": "guardian", "pos": Vector2(-210, -40)},
			{"kind": "hound", "pos": Vector2(230, 20)}
		]
	},
	{
		"label": "Stage 2 - Reliquary Pressure",
		"spawns": [
			{"kind": "archer", "pos": Vector2(420, -120)},
			{"kind": "guardian", "pos": Vector2(-380, 130)}
		]
	},
	{
		"label": "Final - Bell-Bearer Trial",
		"spawns": [
			{"kind": "bell_bearer", "pos": Vector2(0, -365)},
			{"kind": "hound", "pos": Vector2(-290, -190)}
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


func wave_count() -> int:
	return WAVES.size()
