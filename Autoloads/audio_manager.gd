extends Node

const MASTER_BUS: String = "Master"
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"

const MAX_SFX : int = 8

var active_sfx : int = 0

var music_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	#music_player
	add_child(music_player)

#region VOLUME

func set_master_volume(volume: float) -> void:
	_set_bus_volume(MASTER_BUS, volume)


func set_music_volume(volume: float) -> void:
	_set_bus_volume(MUSIC_BUS, volume)


func set_sfx_volume(volume: float) -> void:
	_set_bus_volume(SFX_BUS, volume)


func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(bus, volume)

#endregion

#region MUTE

func set_master_muted(muted: bool) -> void:
	_set_bus_muted(MASTER_BUS, muted)


func set_music_muted(muted: bool) -> void:
	_set_bus_muted(MUSIC_BUS, muted)


func set_sfx_muted(muted: bool) -> void:
	_set_bus_muted(SFX_BUS, muted)


func _set_bus_muted(bus_name: String, muted: bool) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus, muted)

#endregion

#region MUSIC
func play_music(stream: AudioStream) -> void:
	music_player.stream = stream
	music_player.play()


func stop_music() -> void:
	music_player.stop()

#region SFX

func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if active_sfx >= MAX_SFX:
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS
	player.pitch_scale = pitch_scale

	add_child(player)

	active_sfx += 1

	player.finished.connect(func():
		active_sfx -= 1
		player.queue_free()
	)

	player.play()

	#endregion
