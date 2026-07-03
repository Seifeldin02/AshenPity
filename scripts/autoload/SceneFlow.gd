extends Node

const TITLE_SCENE := "res://scenes/menu/TitleScreen.tscn"
const ARENA_SCENE := "res://scenes/arena/ShrineArena.tscn"
const VICTORY_SCENE := "res://scenes/menu/VictoryScreen.tscn"

func go_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)


func start_game() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(ARENA_SCENE)


func victory() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(VICTORY_SCENE)
