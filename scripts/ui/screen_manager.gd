class_name ScreenManager
extends Control

## Manages screen transitions. Preloads all screen PackedScenes and handles
## switching between them. Lab Hub is the default initial screen.

const INITIAL_SCREEN := "lab_hub"

var screens: Dictionary = {}
var current_screen: Control = null


func _ready() -> void:
	_preload_screens()
	change_screen(INITIAL_SCREEN)


func _preload_screens() -> void:
	screens["lab_hub"] = preload("res://scenes/ui/screens/lab_hub.tscn")
	screens["assembly"] = preload("res://scenes/ui/screens/assembly.tscn")
	screens["black_market"] = preload("res://scenes/ui/screens/black_market.tscn")
	screens["arena_pre_match"] = preload("res://scenes/ui/screens/arena_pre_match.tscn")
	screens["arena_combat"] = preload("res://scenes/ui/screens/arena_combat.tscn")
	screens["roster"] = preload("res://scenes/ui/screens/roster.tscn")
	screens["clinic"] = preload("res://scenes/ui/screens/clinic.tscn")
	screens["tournament"] = preload("res://scenes/ui/screens/tournament.tscn")
	screens["hall_of_fame"] = preload("res://scenes/ui/screens/hall_of_fame.tscn")


## Transition to a new screen by name. Frees the current screen via
## queue_free, instantiates the requested screen, and emits
## screen_change_requested on EventBus. Does nothing if the screen
## name is not found in the preloaded screens dictionary.
func change_screen(screen_name: String) -> void:
	if not screens.has(screen_name):
		return
	if current_screen:
		current_screen.queue_free()
	var screen_instance: Control = screens[screen_name].instantiate()
	add_child(screen_instance)
	current_screen = screen_instance
	EventBus.screen_change_requested.emit(screen_name)


## Plays the 'click' UI sound if a UISounds sibling node is available.
## Called by screen button handlers before navigation.
func play_click() -> void:
	var ui_sounds: Node = get_parent().get_node_or_null("UISounds")
	if ui_sounds and ui_sounds.has_method("play_sound"):
		ui_sounds.play_sound("click")
