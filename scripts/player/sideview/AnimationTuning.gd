class_name SideViewAnimationTuning
extends Resource

@export_group("Movement")
@export var movement_speed := 520.0
@export var acceleration := 4200.0
@export var deceleration := 5200.0
@export var world_min_x := -1200.0
@export var world_max_x := 1200.0

@export_group("Locomotion Animation")
@export_range(12.0, 30.0, 1.0) var idle_fps := 14.0
@export_range(12.0, 30.0, 1.0) var run_fps := 24.0

@export_group("Action Playback")
@export_range(12.0, 30.0, 1.0) var normal_fps := 24.0
@export_range(12.0, 30.0, 1.0) var heavy_fps := 24.0
@export_range(12.0, 30.0, 1.0) var parry_fps := 24.0
@export_range(24.0, 30.0, 1.0) var skill_fps := 28.0
@export_range(12.0, 30.0, 1.0) var hurt_fps := 24.0
@export_range(12.0, 30.0, 1.0) var death_fps := 24.0
@export_range(0.05, 0.18, 0.01) var input_buffer_window := 0.11

# Holds are measured in animation frames. They create anticipation and recovery
# without duplicating artwork or decoupling the state lock from the visible action.
@export var idle_frame_holds := PackedFloat32Array([1.0, 1.2, 1.0, 1.2])
@export var run_frame_holds := PackedFloat32Array([1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
@export var normal_frame_holds := PackedFloat32Array([1.0, 1.6, 0.8, 0.55, 1.0, 1.4, 1.8])
@export var heavy_frame_holds := PackedFloat32Array([1.0, 2.0, 1.8, 1.0, 0.6, 1.4, 2.0, 2.4])
@export var parry_frame_holds := PackedFloat32Array([1.0, 1.2, 0.65, 0.5, 1.0, 1.6])
@export var skill_frame_holds := PackedFloat32Array([1.5, 0.7, 0.55, 0.7, 0.55, 1.1, 1.5, 2.0])
@export var hurt_frame_holds := PackedFloat32Array([1.0, 2.0])
@export var death_frame_holds := PackedFloat32Array([1.0, 1.2, 1.1, 1.4, 1.5, 2.5])

@export_group("Movement During Actions")
@export_range(0.0, 1.0, 0.05) var normal_movement_scale := 0.25
@export_range(0.0, 1.0, 0.05) var heavy_movement_scale := 0.08
@export_range(0.0, 1.0, 0.05) var parry_movement_scale := 0.0
@export_range(0.0, 1.0, 0.05) var skill_movement_scale := 0.12

@export_group("Weapon Motion")
@export_range(8.0, 60.0, 1.0) var weapon_follow_speed := 36.0
