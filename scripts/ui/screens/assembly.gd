class_name AssemblyScreen
extends Control

## Stub screen for Assembly. Returns to Lab Hub on back button press.


func _on_back_button_pressed() -> void:
	get_parent().call("change_screen", "lab_hub")
