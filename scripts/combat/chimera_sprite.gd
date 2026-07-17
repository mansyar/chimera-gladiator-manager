class_name ChimeraSprite
extends Node2D

## Composition node managing 8-layer sprite rendering for a chimera entity.
## Z-order: Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7.
## (FR-6..FR-9: ChimeraSprite composition)

## Base path for Kenney Monster Builder Pack sprites.
const SPRITE_PATH_PREFIX := "res://assets/kenney-monster-builder-pack/PNG/Default/"

## Maps each strain to its color suffix used in Kenney Monster Builder sprite filenames.
const STRAIN_TO_COLOR: Dictionary = {
	GameEnums.Strain.UNDEAD: "dark",
	GameEnums.Strain.ROBOTIC: "white",
	GameEnums.Strain.DRACONIC: "red",
	GameEnums.Strain.BEAST: "green",
	GameEnums.Strain.ELEMENTAL: "blue",
	GameEnums.Strain.ABERRANT: "yellow",
	GameEnums.Strain.NEUTRAL: "dark",
}

# Layer z-order constants.
const Z_BODY := 0
const Z_LEGS := 1
const Z_ARMS := 2
const Z_DETAIL := 3
const Z_EYES := 4
const Z_MOUTH := 5
const Z_NOSE := 6
const Z_EYEBROWS := 7


func _ready() -> void:
	_create_layer("Body", Z_BODY)
	_create_layer("Legs", Z_LEGS)
	_create_layer("Arms", Z_ARMS)
	_create_layer("Detail", Z_DETAIL)
	_create_layer("Eyes", Z_EYES)
	_create_layer("Mouth", Z_MOUTH)
	_create_layer("Nose", Z_NOSE)
	_create_layer("Eyebrows", Z_EYEBROWS)


## Create a Sprite2D child layer with the given name and z-order.
func _create_layer(layer_name: String, z_order: int) -> Sprite2D:
	var layer := Sprite2D.new()
	layer.name = layer_name
	layer.z_index = z_order
	add_child(layer)
	return layer


## Populate part-derived layers from a ChimeraData's equipped parts.
## Body←TORSO, Legs←LEGS, Arms←ARMS, Detail←HEAD.
## Cosmetic layers (Eyes/Mouth/Nose/Eyebrows) are left empty (set in a future track).
func set_from_parts(chimera_data: ChimeraData) -> void:
	_set_layer_texture("Body", chimera_data.torso)
	_set_layer_texture("Legs", chimera_data.legs)
	_set_layer_texture("Arms", chimera_data.arms)
	_set_layer_texture("Detail", chimera_data.head)


## Load and assign a texture to a named layer based on a part's shape_id and strain.
func _set_layer_texture(layer_name: String, part: PartData) -> void:
	var layer: Sprite2D = get_node_or_null(layer_name)
	if layer == null:
		return
	if part == null or part.shape_id.is_empty():
		layer.texture = null
		return
	var path := get_sprite_path(part.shape_id, part.strain)
	if path.is_empty():
		push_warning(
			"ChimeraSprite: could not resolve sprite path for shape_id '%s'" % part.shape_id
		)
		layer.texture = null
		return
	layer.texture = load(path)


## Construct the sprite path for a shape and strain.
##
## Handles two Kenney naming patterns:
## 1. Details (HEAD): detail_{color}_{variant}.png
## 2. Body/Arm/Leg: {category}_{color}{Variant}.png
static func get_sprite_path(shape_id: String, strain: GameEnums.Strain) -> String:
	var color: String = STRAIN_TO_COLOR.get(strain, "dark")
	if shape_id.begins_with("detail_"):
		var variant := shape_id.substr(7)
		return "%sdetail_%s_%s.png" % [SPRITE_PATH_PREFIX, color, variant]
	var parts := shape_id.split("_")
	if parts.size() < 2:
		return ""
	var category := parts[0]
	var variant := parts[1].to_upper()
	return "%s%s_%s%s.png" % [SPRITE_PATH_PREFIX, category, color, variant]
