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


static func apply_damage(current_health: float, damage: float, invulnerable: bool) -> float:
	if invulnerable:
		return current_health
	return maxf(current_health - maxf(damage, 0.0), 0.0)
