extends Node

const PLAYER_MAX_HEALTH := 100.0
const PLAYER_MAX_STAMINA := 100.0
const PLAYER_MOVE_SPEED := 398.0
const PLAYER_ACCELERATION := 4300.0
const PLAYER_DECELERATION := 4700.0
const PLAYER_ATTACK_COST := 18.0
const PLAYER_HEAVY_COST := 34.0
const PLAYER_COLLECT_COST := 22.0
const PLAYER_DODGE_COST := 34.0
const PLAYER_PARRY_COST := 18.0
const PLAYER_ATTACK_DAMAGE := 28.0
const PLAYER_HEAVY_DAMAGE := 48.0
const PLAYER_COLLECT_DAMAGE := 72.0
const PLAYER_ATTACK_KNOCKBACK := 280.0
const PLAYER_HEAVY_KNOCKBACK := 390.0
const PLAYER_COLLECT_KNOCKBACK := 560.0
const PLAYER_ATTACK_WINDUP_TIME := 0.08
const PLAYER_ATTACK_ACTIVE_TIME := 0.10
const PLAYER_ATTACK_RECOVERY_TIME := 0.15
const PLAYER_HEAVY_WINDUP_TIME := 0.22
const PLAYER_HEAVY_ACTIVE_TIME := 0.14
const PLAYER_HEAVY_RECOVERY_TIME := 0.26
const PLAYER_COLLECT_WINDUP_TIME := 0.05
const PLAYER_COLLECT_ACTIVE_TIME := 0.16
const PLAYER_COLLECT_RECOVERY_TIME := 0.12
const PLAYER_ATTACK_BUFFER_WINDOW := 0.13
const PLAYER_HEAVY_BUFFER_WINDOW := 0.10
const PLAYER_HEAVY_CHAIN_WINDOW := 1.15
const PLAYER_HEAVY_CHAIN_COST_STEP := 18.0
const PLAYER_HEAVY_CHAIN_MAX := 2
const PLAYER_DODGE_SPEED := 900.0
const PLAYER_DODGE_TIME := 0.245
const PLAYER_DODGE_INVULN_TIME := 0.155
const PLAYER_PERFECT_DODGE_WINDOW := 0.16
const PLAYER_DODGE_RECOVERY := 0.065
const PLAYER_DODGE_CANCEL_AFTER := 0.055
const PLAYER_DODGE_ATTACK_BUFFER_WINDOW := 0.045
const PLAYER_PERFECT_DODGE_STAMINA_RESTORE := 18.0
const PLAYER_PARRY_STARTUP := 0.055
const PLAYER_PARRY_ACTIVE := 0.145
const PLAYER_PARRY_RECOVERY := 0.24
const PLAYER_PARRY_STAMINA_RESTORE := 24.0
const PLAYER_PARRY_STAGGER := 4.2
const PLAYER_PARRY_DAMAGE := 12.0
const PLAYER_PARRY_KNOCKBACK := 210.0
const PLAYER_HEAL_AMOUNT := 38.0
const PLAYER_HEAL_TIME := 0.75
const PLAYER_STAMINA_REGEN := 78.0
const PLAYER_STAMINA_REGEN_DELAY := 0.24
const PLAYER_HURT_TIME := 0.22
const COUNTER_HIT_DAMAGE_MULTIPLIER := 1.22
const COUNTER_HIT_STAGGER_MULTIPLIER := 1.45
const REAR_HIT_DAMAGE_MULTIPLIER := 1.16
const REAR_HIT_STAGGER_BONUS := 0.55
const RECOVERY_PUNISH_STAGGER_BONUS := 0.35
const BOSS_PARRY_STAGGER_RESIST := 0.55

const ENEMY_MAX_HEALTH := 86.0
const HOUND_MAX_HEALTH := 58.0
const ARCHER_MAX_HEALTH := 64.0
const BELL_BEARER_MAX_HEALTH := 260.0
const ENEMY_MOVE_SPEED := 165.0
const ENEMY_DETECT_RANGE := 620.0
const ENEMY_ATTACK_RANGE := 104.0
const ENEMY_ATTACK_DAMAGE := 18.0
const ENEMY_ATTACK_KNOCKBACK := 260.0
const ENEMY_WINDUP_TIME := 0.52
const ENEMY_ACTIVE_TIME := 0.16
const ENEMY_RECOVERY_TIME := 0.68
const ENEMY_STAGGER_HITS := 3
const ENEMY_STAGGER_TIME := 0.42
const ENEMY_PATROL_RADIUS := 80.0
const ASH_BRAND_DURATION := 5.0
const ASH_BRAND_HITS_TO_COLLECT := 2
const COLLECT_TARGET_RANGE := 720.0

const LIGHT_COMBO := [
	{
		"name": "light_1",
		"windup": 0.07,
		"active": 0.09,
		"recovery": 0.115,
		"damage": 20.0,
		"stagger": 1.0,
		"stamina": 14.0,
		"knockback": 235.0,
		"range": 62.0,
		"width": 78.0,
		"height": 48.0,
		"lunge": 120.0
	},
	{
		"name": "light_2",
		"windup": 0.08,
		"active": 0.10,
		"recovery": 0.13,
		"damage": 24.0,
		"stagger": 1.15,
		"stamina": 16.0,
		"knockback": 260.0,
		"range": 68.0,
		"width": 92.0,
		"height": 52.0,
		"lunge": 150.0
	},
	{
		"name": "light_3",
		"windup": 0.10,
		"active": 0.12,
		"recovery": 0.18,
		"damage": 34.0,
		"stagger": 1.55,
		"stamina": 20.0,
		"knockback": 330.0,
		"range": 78.0,
		"width": 108.0,
		"height": 56.0,
		"lunge": 215.0
	}
]

const HEAVY_ATTACK := {
	"name": "heavy",
	"windup": 0.22,
	"active": 0.16,
	"recovery": 0.29,
	"damage": 52.0,
	"stagger": 3.0,
	"stamina": PLAYER_HEAVY_COST,
	"knockback": PLAYER_HEAVY_KNOCKBACK,
	"range": 86.0,
	"width": 116.0,
	"height": 70.0,
	"lunge": 135.0
}

const PARRY_COUNTER := {
	"name": "parry",
	"damage": PLAYER_PARRY_DAMAGE,
	"stagger": PLAYER_PARRY_STAGGER,
	"knockback": PLAYER_PARRY_KNOCKBACK,
}

const COLLECT_ATTACK := {
	"name": "collect",
	"windup": 0.05,
	"active": 0.16,
	"recovery": 0.12,
	"damage": PLAYER_COLLECT_DAMAGE,
	"stagger": 6.0,
	"stamina": PLAYER_COLLECT_COST,
	"knockback": PLAYER_COLLECT_KNOCKBACK,
	"range": 96.0,
	"width": 132.0,
	"height": 78.0,
	"lunge": 920.0
}

const ENEMY_CONFIGS := {
	"guardian": {
		"display_name": "Shrine Guardian",
		"max_health": ENEMY_MAX_HEALTH,
		"move_speed": 165.0,
		"detect_range": 620.0,
		"attack_range": 104.0,
		"attack_damage": 18.0,
		"attack_knockback": 260.0,
		"windup": 0.52,
		"active": 0.16,
		"recovery": 0.68,
		"stagger_threshold": 3.0,
		"attack_style": "melee"
	},
	"hound": {
		"display_name": "Ashbound Hound",
		"max_health": HOUND_MAX_HEALTH,
		"move_speed": 250.0,
		"detect_range": 680.0,
		"attack_range": 82.0,
		"attack_damage": 14.0,
		"attack_knockback": 230.0,
		"windup": 0.24,
		"active": 0.12,
		"recovery": 0.38,
		"stagger_threshold": 2.0,
		"attack_style": "hound"
	},
	"archer": {
		"display_name": "Reliquary Archer",
		"max_health": ARCHER_MAX_HEALTH,
		"move_speed": 120.0,
		"detect_range": 780.0,
		"attack_range": 520.0,
		"attack_damage": 15.0,
		"attack_knockback": 210.0,
		"windup": 0.62,
		"active": 0.08,
		"recovery": 0.72,
		"stagger_threshold": 2.5,
		"attack_style": "ranged"
	},
	"bell_bearer": {
		"display_name": "Bell-Bearer",
		"max_health": BELL_BEARER_MAX_HEALTH,
		"move_speed": 105.0,
		"detect_range": 820.0,
		"attack_range": 132.0,
		"attack_damage": 27.0,
		"attack_knockback": 360.0,
		"windup": 0.76,
		"active": 0.22,
		"recovery": 0.86,
		"stagger_threshold": 7.0,
		"attack_style": "elite"
	},
	"ashen_judicator": {
		"display_name": "Ashen Judicator",
		"max_health": 420.0,
		"move_speed": 118.0,
		"detect_range": 980.0,
		"attack_range": 150.0,
		"attack_damage": 31.0,
		"attack_knockback": 430.0,
		"windup": 0.68,
		"active": 0.22,
		"recovery": 0.72,
		"stagger_threshold": 12.0,
		"attack_style": "boss"
	}
}

const ARENA_HALF_SIZE := Vector2(760.0, 390.0)
