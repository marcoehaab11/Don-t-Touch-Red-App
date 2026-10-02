extends Node

var player: AudioStreamPlayer
var tones: Dictionary = {}

func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	for name in {"hit": 660.0, "hurt": 190.0, "reward": 880.0}:
		tones[name] = make_tone({"hit": 660.0, "hurt": 190.0, "reward": 880.0}[name])

func make_tone(hz: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.11)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var envelope := 1.0 - float(i) / count
		var sample := int(sin(TAU * hz * i / rate) * envelope * 10000.0)
		bytes.encode_s16(i * 2, sample)
	var wave := AudioStreamWAV.new()
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	wave.mix_rate = rate
	wave.stereo = false
	wave.data = bytes
	return wave

func play(name: String) -> void:
	if not AppState.data.get("sound", true) or not tones.has(name):
		return
	player.stream = tones[name]
	player.play()

func buzz() -> void:
	if AppState.data.get("vibration", true):
		Input.vibrate_handheld(70)
