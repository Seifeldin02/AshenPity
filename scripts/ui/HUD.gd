extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var flask_label: Label = %FlaskLabel
@onready var enemy_panel: Control = %EnemyPanel
@onready var enemy_bar: ProgressBar = %EnemyBar
@onready var enemy_label: Label = %EnemyLabel
@onready var hints: Label = %Hints
@onready var brand_label: Label = %BrandLabel
@onready var boon_label: Label = %BoonLabel
@onready var pickup_label: Label = %PickupLabel
@onready var wave_label: Label = %WaveLabel
@onready var death_panel: Control = %DeathPanel
@onready var pause_panel: Control = %PausePanel
@onready var trial_panel: Control = %TrialPanel
@onready var build_label: Label = %BuildLabel

var _player: Node
var _enemies: Array[Node] = []
var _hint_timer := 7.0
var _wave_timer := 0.0
var _pickup_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	death_panel.hide()
	pause_panel.hide()
	trial_panel.hide()
	enemy_panel.hide()
	build_label.text = BuildInfo.label()
	brand_label.text = "Ash Brand: -"
	boon_label.text = "Boons: -"
	pickup_label.hide()
	wave_label.hide()


func bind(player: Node, enemies: Array[Node]) -> void:
	_player = player
	_enemies = enemies
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
	if player.has_signal("stamina_changed"):
		player.stamina_changed.connect(_on_player_stamina_changed)
	if player.has_signal("flask_changed"):
		player.flask_changed.connect(_on_flask_changed)
	if player.has_signal("ash_brand_changed"):
		player.ash_brand_changed.connect(_on_ash_brand_changed)
	if player.has_signal("boons_changed"):
		player.boons_changed.connect(_on_boons_changed)
	for enemy in enemies:
		if enemy.has_signal("health_changed"):
			enemy.health_changed.connect(_on_enemy_health_changed.bind(enemy))
	_on_player_health_changed(player.get("health"), GameBalance.PLAYER_MAX_HEALTH)
	_on_player_stamina_changed(player.get("stamina"), GameBalance.PLAYER_MAX_STAMINA)
	_on_flask_changed(player.get("flask_charges"), 2)
	_on_ash_brand_changed(player.get("branded_enemy"), player.get("collect_ready"))
	_on_boons_changed(player.get("boons"))


func bind_enemies(enemies: Array[Node]) -> void:
	_enemies = enemies
	for enemy in enemies:
		if enemy.has_signal("health_changed") and not enemy.health_changed.is_connected(_on_enemy_health_changed.bind(enemy)):
			enemy.health_changed.connect(_on_enemy_health_changed.bind(enemy))


func _process(delta: float) -> void:
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0:
			hints.hide()
	if _wave_timer > 0.0:
		_wave_timer -= delta
		if _wave_timer <= 0.0:
			wave_label.hide()
	if _pickup_timer > 0.0:
		_pickup_timer -= delta
		if _pickup_timer <= 0.0:
			pickup_label.hide()
	_update_enemy_panel()


func show_death_prompt() -> void:
	death_panel.show()


func set_pause_visible(value: bool) -> void:
	pause_panel.visible = value


func show_wave(label: String) -> void:
	wave_label.text = label
	wave_label.show()
	_wave_timer = 2.4


func show_pickup(label: String) -> void:
	pickup_label.text = label
	pickup_label.show()
	_pickup_timer = 3.0


func show_trial_complete() -> void:
	trial_panel.show()


func _on_player_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_player_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current


func _on_flask_changed(current: int, maximum: int) -> void:
	flask_label.text = "F  Flask %d/%d" % [current, maximum]


func _on_ash_brand_changed(enemy: Node, collect_ready: bool) -> void:
	if is_instance_valid(enemy):
		var name: String = str(enemy.get("display_name"))
		brand_label.text = "Ash Brand: %s  %s" % [name, "Q COLLECT" if collect_ready else "strike to prime"]
		brand_label.modulate = Color(1.0, 0.78, 0.32, 1.0) if collect_ready else Color(1.0, 0.43, 0.20, 0.92)
	else:
		brand_label.text = "Ash Brand: -"
		brand_label.modulate = Color(0.78, 0.72, 0.64, 0.82)


func _on_boons_changed(boons: Dictionary) -> void:
	if boons.is_empty():
		boon_label.text = "Boons: -"
		boon_label.modulate = Color(0.78, 0.72, 0.64, 0.76)
		return
	var names: Array[String] = []
	for boon_id in boons.keys():
		var data: Dictionary = GameBalance.BOON_DATA.get(str(boon_id), {})
		names.append(str(data.get("display_name", boon_id)))
	boon_label.text = "Boons: %s" % ", ".join(PackedStringArray(names))
	boon_label.modulate = Color(0.92, 0.74, 0.43, 0.92)


func _on_enemy_health_changed(current: float, maximum: float, enemy: Node) -> void:
	enemy_panel.show()
	enemy_label.text = str(enemy.get("display_name")) if is_instance_valid(enemy) else "Enemy"
	enemy_bar.max_value = maximum
	enemy_bar.value = current
	if current <= 0.0:
		await get_tree().create_timer(0.35).timeout
		_update_enemy_panel()


func _update_enemy_panel() -> void:
	var living := _enemies.filter(func(enemy: Node) -> bool: return is_instance_valid(enemy) and enemy.get("health") > 0.0)
	if living.is_empty():
		enemy_panel.hide()
		return
	var target: Node = living[0]
	enemy_panel.show()
	enemy_label.text = str(target.get("display_name"))
	enemy_bar.max_value = target.get("max_health")
	enemy_bar.value = target.get("health")


func _on_restart_pressed() -> void:
	SceneFlow.start_game()


func _on_title_pressed() -> void:
	SceneFlow.go_to_title()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	set_pause_visible(false)


func _on_replay_pressed() -> void:
	SceneFlow.start_game()
