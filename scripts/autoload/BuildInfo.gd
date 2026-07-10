extends Node

const VERSION := "Ashen Pity - Shrine Design Pass v0.5.6"
const FALLBACK_COMMIT := "unknown"

var commit_short := FALLBACK_COMMIT

func _ready() -> void:
	commit_short = _read_git_commit()


func label() -> String:
	return "%s  %s" % [VERSION, commit_short]


func _read_git_commit() -> String:
	var git_dir := ProjectSettings.globalize_path("res://.git")
	var head_path := git_dir.path_join("HEAD")
	if not FileAccess.file_exists(head_path):
		return FALLBACK_COMMIT
	var head := FileAccess.get_file_as_string(head_path).strip_edges()
	if head.begins_with("ref:"):
		var ref_path := git_dir.path_join(head.trim_prefix("ref:").strip_edges())
		if FileAccess.file_exists(ref_path):
			var value := FileAccess.get_file_as_string(ref_path).strip_edges()
			return value.substr(0, 7)
		return FALLBACK_COMMIT
	return head.substr(0, 7) if head.length() >= 7 else FALLBACK_COMMIT
