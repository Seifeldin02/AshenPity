extends Node

const MAX_SAMPLES := 240

var lightweight_mode := false
var _frame_times_ms: Array[float] = []

func _process(delta: float) -> void:
	_frame_times_ms.append(delta * 1000.0)
	if _frame_times_ms.size() > MAX_SAMPLES:
		_frame_times_ms.pop_front()


func set_lightweight_mode(value: bool) -> void:
	lightweight_mode = value


func average_frame_time_ms() -> float:
	if _frame_times_ms.is_empty():
		return 0.0
	var total := 0.0
	for value in _frame_times_ms:
		total += value
	return total / float(_frame_times_ms.size())


func p95_frame_time_ms() -> float:
	if _frame_times_ms.is_empty():
		return 0.0
	var sorted := _frame_times_ms.duplicate()
	sorted.sort()
	var index := clampi(int(ceil(float(sorted.size()) * 0.95)) - 1, 0, sorted.size() - 1)
	return sorted[index]


func display_refresh_rate() -> float:
	var rate := DisplayServer.screen_get_refresh_rate()
	return rate if rate > 0.0 else 0.0


func physics_tick_rate() -> int:
	return Engine.physics_ticks_per_second


func active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").filter(func(enemy: Node) -> bool: return is_instance_valid(enemy) and enemy.get("health") > 0.0).size()


func snapshot(player_state: String = "") -> Dictionary:
	return {
		"fps": Engine.get_frames_per_second(),
		"display_refresh_hz": display_refresh_rate(),
		"avg_frame_ms": average_frame_time_ms(),
		"p95_frame_ms": p95_frame_time_ms(),
		"physics_hz": physics_tick_rate(),
		"active_enemies": active_enemy_count(),
		"player_state": player_state,
		"lightweight_mode": lightweight_mode
	}
