extends Node

func _ready() -> void:
	SceneFlow.go_to_title.call_deferred()
