extends Node

signal wave_started(index: int, label: String)
signal trial_completed
signal enemies_changed(enemies: Array[Node])

const WAVES := [
	{
		"label": "Stage 1 - Pilgrim Court",
		"spawns": [
			{"kind": "guardian", "pos": Vector2(140, 850)}
		]
	},
	{
		"label": "Stage 2 - Entrance Lesson",
		"spawns": [
			{"kind": "guardian", "pos": Vector2(-210, 150)},
			{"kind": "hound", "pos": Vector2(85, 390)}
		]
	},
	{
		"label": "Stage 3 - Central Shrine",
		"spawns": [
			{"kind": "guardian", "pos": Vector2(-320, -85)},
			{"kind": "guardian", "pos": Vector2(310, -100)},
			{"kind": "hound", "pos": Vector2(55, 155)}
		]
	},
	{
		"label": "Stage 4 - Deep Ossuary",
		"spawns": [
			{"kind": "hound", "pos": Vector2(-1880, -430)},
			{"kind": "hound", "pos": Vector2(-1720, -245)},
			{"kind": "guardian", "pos": Vector2(-1240, -420)},
			{"kind": "archer", "pos": Vector2(-2020, -555)}
		]
	},
	{
		"label": "Stage 5 - Reliquary Crossfire",
		"spawns": [
			{"kind": "archer", "pos": Vector2(1050, -520)},
			{"kind": "archer", "pos": Vector2(1900, -525)},
			{"kind": "archer", "pos": Vector2(1310, -330)},
			{"kind": "guardian", "pos": Vector2(1770, -265)}
		]
	},
	{
		"label": "Stage 6 - Bell Gate",
		"spawns": [
			{"kind": "bell_bearer", "pos": Vector2(0, -830)},
			{"kind": "hound", "pos": Vector2(-380, -820)},
			{"kind": "archer", "pos": Vector2(410, -880)}
		]
	},
	{
		"label": "Final - Ashen Judicator",
		"spawns": [
			{"kind": "ashen_judicator", "pos": Vector2(0, -1295)},
			{"kind": "guardian", "pos": Vector2(-315, -1170)},
			{"kind": "guardian", "pos": Vector2(315, -1170)}
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
