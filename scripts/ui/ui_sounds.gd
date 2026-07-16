## UI sound system — loads and plays UI feedback sounds.
##
## Loads 6 OGG files (click ×2, switch ×2, tap ×2) from the Kenney UI Pack
## and plays them via an AudioStreamPlayer child node. Listens to
## [signal EventBus.screen_change_requested] to play 'switch' on transitions.
class_name UISounds
extends Node

const _SOUND_PATHS: Dictionary = {
	"click":
	[
		"res://assets/kenney-ui-pack/Sounds/click-a.ogg",
		"res://assets/kenney-ui-pack/Sounds/click-b.ogg",
	],
	"switch":
	[
		"res://assets/kenney-ui-pack/Sounds/switch-a.ogg",
		"res://assets/kenney-ui-pack/Sounds/switch-b.ogg",
	],
	"tap":
	[
		"res://assets/kenney-ui-pack/Sounds/tap-a.ogg",
		"res://assets/kenney-ui-pack/Sounds/tap-b.ogg",
	],
}

var _player: AudioStreamPlayer = null
var _sounds: Dictionary = {}


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)
	_load_sounds()
	EventBus.screen_change_requested.connect(_on_screen_change)


## Loads all 6 OGG files into the [_sounds] dictionary.
func _load_sounds() -> void:
	for sound_name: String in _SOUND_PATHS.keys():
		var paths: Array = _SOUND_PATHS[sound_name]
		var streams: Array = []
		for path: String in paths:
			streams.append(load(path))
		_sounds[sound_name] = streams


## Plays a UI sound by name (e.g. "click", "switch", "tap").
##
## Picks a random variant if multiple are loaded.
## Does nothing if [param sound_name] is not recognised.
func play_sound(sound_name: String) -> void:
	if not _sounds.has(sound_name):
		return
	var streams: Array = _sounds[sound_name]
	_player.stream = streams[randi() % streams.size()]
	_player.play()


## Returns the [AudioStreamPlayer] child used for playback.
func get_player() -> AudioStreamPlayer:
	return _player


## Returns the dictionary of loaded sounds (keys: "click", "switch", "tap").
func get_sounds() -> Dictionary:
	return _sounds


## Handles screen transitions — plays the 'switch' sound.
func _on_screen_change(_screen: String) -> void:
	play_sound("switch")
