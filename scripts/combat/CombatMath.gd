extends RefCounted
class_name CombatMath

static func normalized_input(vector: Vector2) -> Vector2:
	if vector.length() > 1.0:
		return vector.normalized()
	return vector


static func can_spend_stamina(current: float, cost: float) -> bool:
	return current >= cost


static func spend_stamina(current: float, cost: float) -> float:
	if current < cost:
		return current
	return maxf(current - cost, 0.0)


static func regenerate_stamina(current: float, maximum: float, regen_rate: float, delta: float) -> float:
	return minf(current + maxf(regen_rate, 0.0) * maxf(delta, 0.0), maximum)


static func apply_damage(current_health: float, damage: float, invulnerable: bool) -> float:
	if invulnerable:
		return current_health
	return maxf(current_health - maxf(damage, 0.0), 0.0)


static func aim_direction_from_world(actor_position: Vector2, world_target_position: Vector2, fallback: Vector2 = Vector2.RIGHT) -> Vector2:
	var aim := world_target_position - actor_position
	if aim.length() <= 0.001:
		return fallback.normalized()
	return aim.normalized()


static func is_dodge_invulnerable_at(elapsed: float, duration: float) -> bool:
	return elapsed >= 0.0 and elapsed <= duration


static func velocity_toward(current: Vector2, target: Vector2, acceleration: float, delta: float) -> Vector2:
	return current.move_toward(target, acceleration * delta)


static func is_attack_buffer_allowed(recovery_remaining: float, buffer_window: float) -> bool:
	return recovery_remaining >= 0.0 and recovery_remaining <= buffer_window


static func is_perfect_dodge(elapsed: float, perfect_window: float, dodge_duration: float) -> bool:
	return elapsed >= 0.0 and elapsed <= minf(perfect_window, dodge_duration)


static func ash_brand_hit_progress(current_hits: int, required_hits: int) -> int:
	return clampi(current_hits + 1, 0, max(required_hits, 1))


static func is_collect_ready(brand_hits: int, required_hits: int) -> bool:
	return brand_hits >= max(required_hits, 1)


static func restore_flask_charge(current: int, amount: int, maximum: int) -> int:
	return clampi(current + max(amount, 0), 0, maximum)
