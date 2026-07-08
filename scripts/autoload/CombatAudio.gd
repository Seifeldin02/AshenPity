extends Node

const SAMPLE_RATE := 22050

const CUE_PATHS := {
	"sword_whoosh": "res://assets/audio/kenney/sword_swing.ogg",
	"light_hit": "res://assets/audio/kenney/hit.ogg",
	"heavy_hit": "res://assets/audio/kenney/heavy_hit.ogg",
	"armor_hit": "res://assets/audio/kenney/armor_hit.ogg",
	"enemy_stagger": "res://assets/audio/kenney/heavy_hit.ogg",
	"perfect_dodge": "res://assets/audio/kenney/dodge.ogg",
	"ash_brand": "res://assets/audio/kenney/ash_brand.ogg",
	"collect": "res://assets/audio/kenney/collect.ogg",
	"player_hurt": "res://assets/audio/kenney/player_hurt.ogg",
	"dodge": "res://assets/audio/kenney/dodge.ogg",
	"flask": "res://assets/audio/kenney/ash_brand.ogg",
	"enemy_death": "res://assets/audio/kenney/enemy_death.ogg",
}

var _library := {}

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_load_external_cues()
	if _library.is_empty():
		_load_procedural_fallback()


func _exit_tree() -> void:
	_library.clear()


func play(cue: String, volume_db: float = -8.0) -> void:
	if not _library.has(cue):
		return
	var player := AudioStreamPlayer.new()
	player.stream = _library[cue]
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _load_external_cues() -> void:
	for cue in CUE_PATHS:
		var path := str(CUE_PATHS[cue])
		if not FileAccess.file_exists(path):
			continue
		var stream := AudioStreamOggVorbis.load_from_file(path)
		if stream != null:
			_library[cue] = stream


func _load_procedural_fallback() -> void:
	_library = {
		"sword_whoosh": _make_tone(190.0, 0.08, 0.20, 0.10),
		"light_hit": _make_tone(420.0, 0.07, 0.34, 0.22),
		"heavy_hit": _make_tone(190.0, 0.12, 0.42, 0.28),
		"armor_hit": _make_tone(110.0, 0.11, 0.32, 0.35),
		"enemy_stagger": _make_tone(82.0, 0.16, 0.42, 0.42),
		"perfect_dodge": _make_tone(720.0, 0.10, 0.32, 0.08),
		"ash_brand": _make_tone(520.0, 0.16, 0.38, 0.14),
		"collect": _make_tone(860.0, 0.18, 0.48, 0.18),
		"player_hurt": _make_tone(120.0, 0.13, 0.38, 0.30),
		"dodge": _make_tone(260.0, 0.07, 0.18, 0.12),
		"flask": _make_tone(360.0, 0.18, 0.24, 0.07),
		"enemy_death": _make_tone(70.0, 0.32, 0.42, 0.45)
	}


func _make_tone(frequency: float, duration: float, gain: float, noise: float) -> AudioStreamWAV:
	var sample_count := int(SAMPLE_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(frequency * 1000.0 + duration * 100000.0)
	for i in sample_count:
		var t := float(i) / float(SAMPLE_RATE)
		var fade := 1.0 - (float(i) / maxf(float(sample_count - 1), 1.0))
		var sine := sin(TAU * frequency * t)
		var grit := rng.randf_range(-1.0, 1.0) * noise
		var sample := int(clampf((sine * (1.0 - noise) + grit) * gain * fade, -1.0, 1.0) * 32767.0)
		if sample < 0:
			sample = 65536 + sample
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
