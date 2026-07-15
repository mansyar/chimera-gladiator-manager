class_name ChimeraSprite
extends Node2D

## Composition node managing 8-layer sprite rendering for a chimera entity.
## Z-order: Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7.
## (FR-3: ChimeraSprite composition)

## Maps each strain to its color suffix used in Kenney Monster Builder sprite filenames.
const STRAIN_TO_COLOR: Dictionary = {
	GameEnums.Strain.UNDEAD: "dark",
	GameEnums.Strain.ROBOTIC: "white",
	GameEnums.Strain.DRACONIC: "red",
	GameEnums.Strain.BEAST: "green",
	GameEnums.Strain.ELEMENTAL: "blue",
	GameEnums.Strain.ABERRANT: "yellow",
	GameEnums.Strain.NEUTRAL: "grey",
}


## Returns the sprite path for a given shape_id and strain.
## Format: res://assets/kenney-monster-builder-pack/PNG/Default/{shape_id}_{color}.png
static func get_sprite_path(shape_id: String, strain: GameEnums.Strain) -> String:
	var color_name: String = STRAIN_TO_COLOR[strain]
	return "res://assets/kenney-monster-builder-pack/PNG/Default/%s_%s.png" % [shape_id, color_name]
