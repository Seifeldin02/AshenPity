extends Node

const SAMPLE_RATE := 22050

var _library := {}

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return
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
