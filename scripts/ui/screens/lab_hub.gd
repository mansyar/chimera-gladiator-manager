class_name LabHubScreen
extends Control

## Lab Hub screen. Central navigation hub with buttons to all other screens.
## Displays chimera cards from GameState.roster and provides navigation
## to all game screens. Relies on TopBar for Gold/Infamy display.


func _ready() -> void:
	_populate_roster_cards()


## Populate chimera cards from GameState.roster into the RosterContainer.
## Creates one ChimeraCard per chimera in the roster.
func _populate_roster_cards() -> void:
	var container := get_node_or_null("RosterContainer")
	if container == null:
		return
	for chimera in GameState.roster:
		var card := ChimeraCard.new()
		container.add_child(card)
		card.chimera = chimera


## Handle nav button presses. Plays click sound and transitions to the
## target screen.
func _on_nav_button_pressed(screen_name: String) -> void:
	get_parent().call("play_click")
	get_parent().call("change_screen", screen_name)
