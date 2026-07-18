class_name SideViewAnimationTuning
extends Resource

@export_group("Movement")
@export var movement_speed := 520.0
@export var acceleration := 4200.0
@export var deceleration := 5200.0
@export var world_min_x := -1200.0
@export var world_max_x := 1200.0

@export_group("Locomotion Animation")
@export_range(12.0, 30.0, 1.0) var idle_fps := 12.0
@export_range(12.0, 30.0, 1.0) var run_fps := 16.0

@export_group("Action Locks")
@export_range(0.2, 0.6, 0.01) var normal_attack_duration := 0.33
@export_range(0.3, 0.8, 0.01) var heavy_attack_duration := 0.50
@export_range(0.2, 0.5, 0.01) var parry_duration := 0.28
@export_range(0.25, 0.6, 0.01) var skill_duration := 0.333
@export_range(0.2, 0.5, 0.01) var hurt_duration := 0.25
@export_range(0.4, 1.0, 0.01) var death_duration := 0.50

@export_group("Movement During Actions")
@export_range(0.0, 1.0, 0.05) var normal_movement_scale := 0.25
@export_range(0.0, 1.0, 0.05) var heavy_movement_scale := 0.08
@export_range(0.0, 1.0, 0.05) var parry_movement_scale := 0.0
@export_range(0.0, 1.0, 0.05) var skill_movement_scale := 0.12
