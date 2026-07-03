extends RefCounted
class_name EnemyBrain

enum State { IDLE, PATROL, CHASE, WINDUP, ACTIVE, RECOVERY, STAGGER, DYING, DEAD }

static func should_chase(distance_to_player: float, detect_range: float) -> bool:
	return distance_to_player <= detect_range


static func should_attack(distance_to_player: float, attack_range: float) -> bool:
	return distance_to_player <= attack_range


static func next_awareness_state(distance_to_player: float, detect_range: float, attack_range: float) -> int:
	if should_attack(distance_to_player, attack_range):
		return State.WINDUP
	if should_chase(distance_to_player, detect_range):
		return State.CHASE
	return State.PATROL
