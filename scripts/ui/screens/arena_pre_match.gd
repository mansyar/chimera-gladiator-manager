class_name ArenaPreMatchScreen
extends Control

## Stub screen for Arena Pre-Match. Returns to Lab Hub on back button press.


func _on_back_button_pressed() -> void:
	get_parent().call("play_click")
	get_parent().call("change_screen", "lab_hub")
