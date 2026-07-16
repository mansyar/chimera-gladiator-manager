class_name LabHubScreen
extends Control

## Lab Hub screen. Central navigation hub with buttons to all other screens.


func _on_nav_button_pressed(screen_name: String) -> void:
	get_parent().call("play_click")
	get_parent().call("change_screen", screen_name)
