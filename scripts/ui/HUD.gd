extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var flask_label: Label = %FlaskLabel
@onready var enemy_panel: Control = %EnemyPanel
@onready var enemy_bar: ProgressBar = %EnemyBar
@onready var enemy_label: Label = %EnemyLabel
@onready var hints: Label = %Hints
@onready var death_panel: Control = %DeathPanel
@onready var pause_panel: Control = %PausePanel

var _player: Node
var _enemies: Array[Node] = []
var _hint_timer := 7.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	death_panel.hide()
	pause_panel.hide()
	enemy_panel.hide()


func bind(player: Node, enemies: Array[Node]) -> void:
	_player = player
	_enemies = enemies
	if player.has_signal("health_changed"):
		player.health_changed.connect(_on_player_health_changed)
	if player.has_signal("stamina_changed"):
		player.stamina_changed.connect(_on_player_stamina_changed)
	if player.has_signal("flask_changed"):
		player.flask_changed.connect(_on_flask_changed)
	for enemy in enemies:
		if enemy.has_signal("health_changed"):
			enemy.health_changed.connect(_on_enemy_health_changed.bind(enemy))
	_on_player_health_changed(player.get("health"), GameBalance.PLAYER_MAX_HEALTH)
	_on_player_stamina_changed(player.get("stamina"), GameBalance.PLAYER_MAX_STAMINA)
	_on_flask_changed(player.get("flask_charges"), 2)


func _process(delta: float) -> void:
	if _hint_timer > 0.0:
		_hint_timer -= delta
		if _hint_timer <= 0.0:
			hints.hide()
	_update_enemy_panel()


func show_death_prompt() -> void:
	death_panel.show()


func set_pause_visible(value: bool) -> void:
	pause_panel.visible = value


func _on_player_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_player_stamina_changed(current: float, maximum: float) -> void:
	stamina_bar.max_value = maximum
	stamina_bar.value = current


func _on_flask_changed(current: int, maximum: int) -> void:
	flask_label.text = "Flask %d/%d" % [current, maximum]


func _on_enemy_health_changed(current: float, maximum: float, enemy: Node) -> void:
	enemy_panel.show()
	enemy_label.text = "Shrine Guardian"
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
	enemy_label.text = "Shrine Guardian"
	enemy_bar.max_value = GameBalance.ENEMY_MAX_HEALTH
	enemy_bar.value = target.get("health")


func _on_restart_pressed() -> void:
	SceneFlow.start_game()


func _on_title_pressed() -> void:
	SceneFlow.go_to_title()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	set_pause_visible(false)
