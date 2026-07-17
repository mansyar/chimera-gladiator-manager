class_name ChimeraSprite
extends Node2D

## Composition node managing 11-layer sprite rendering for a chimera entity.
## Z-order: Body=0, LeftLeg=1, RightLeg=2, LeftArm=3, RightArm=4,
## LeftDetail=5, RightDetail=6, Eyes=7, Mouth=8, Nose=9, Eyebrows=10.
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
const Z_LEFT_LEG := 1
const Z_RIGHT_LEG := 2
const Z_LEFT_ARM := 3
const Z_RIGHT_ARM := 4
const Z_LEFT_DETAIL := 5
const Z_RIGHT_DETAIL := 6
const Z_EYES := 7
const Z_MOUTH := 8
const Z_NOSE := 9
const Z_EYEBROWS := 10

## Position offset for each part layer relative to the body center.
const POSITION_OFFSETS := {
	"Body": Vector2(0, 0),
	"LeftLeg": Vector2(-25, 100),
	"RightLeg": Vector2(25, 100),
	"LeftArm": Vector2(-90, 0),
	"RightArm": Vector2(90, 0),
	"LeftDetail": Vector2(-20, -80),
	"RightDetail": Vector2(20, -80),
	"Eyes": Vector2(0, -20),
	"Mouth": Vector2(0, 10),
	"Nose": Vector2(0, -5),
	"Eyebrows": Vector2(0, -35),
}


func _ready() -> void:
	_create_layer("Body", Z_BODY)
	_create_layer("LeftLeg", Z_LEFT_LEG)
	_create_layer("RightLeg", Z_RIGHT_LEG)
	_create_layer("LeftArm", Z_LEFT_ARM)
	_create_layer("RightArm", Z_RIGHT_ARM)
	_create_layer("LeftDetail", Z_LEFT_DETAIL)
	_create_layer("RightDetail", Z_RIGHT_DETAIL)
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
## Body←TORSO, legs mirrored to LeftLeg/RightLeg, arms mirrored to LeftArm/RightArm,
## detail mirrored to LeftDetail/RightDetail.
## Cosmetic layers (Eyes/Mouth/Nose/Eyebrows) are left empty (set in a future track).
func set_from_parts(chimera_data: ChimeraData) -> void:
	_set_layer("Body", chimera_data.torso, false)
	_set_layer("LeftLeg", chimera_data.legs, true)
	_set_layer("RightLeg", chimera_data.legs, false)
	_set_layer("LeftArm", chimera_data.arms, true)
	_set_layer("RightArm", chimera_data.arms, false)
	_set_layer("LeftDetail", chimera_data.head, true)
	_set_layer("RightDetail", chimera_data.head, false)
	_set_layer("Eyes", null, false)
	_set_layer("Mouth", null, false)
	_set_layer("Nose", null, false)
	_set_layer("Eyebrows", null, false)


## Set texture, position, and horizontal flip for a named layer from a part.
func _set_layer(layer_name: String, part: PartData, flip_h: bool) -> void:
	_set_layer_texture(layer_name, part)
	_set_layer_position(layer_name)
	_set_layer_flip(layer_name, flip_h)


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


## Apply the configured position offset for a named layer.
func _set_layer_position(layer_name: String) -> void:
	var layer: Sprite2D = get_node_or_null(layer_name)
	if layer == null:
		return
	layer.position = POSITION_OFFSETS.get(layer_name, Vector2.ZERO)


## Apply horizontal flip for a named layer.
func _set_layer_flip(layer_name: String, flip_h: bool) -> void:
	var layer: Sprite2D = get_node_or_null(layer_name)
	if layer == null:
		return
	layer.flip_h = flip_h


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
