## Static database for looking up part and ability templates.
##
## Loads .tres resource files at startup and provides O(1) lookup
## for parts, abilities, behaviors, combos, and starters.
class_name PartDatabase

## Base path for Kenney Monster Builder Pack sprites.
const SPRITE_PATH_PREFIX := "res://assets/kenney-monster-builder-pack/PNG/Default/"

## Maps strain enum to Kenney sprite color name.
const STRAIN_TO_COLOR := {
	GameEnums.Strain.UNDEAD: "dark",
	GameEnums.Strain.ROBOTIC: "white",
	GameEnums.Strain.DRACONIC: "red",
	GameEnums.Strain.BEAST: "green",
	GameEnums.Strain.ELEMENTAL: "blue",
	GameEnums.Strain.ABERRANT: "yellow",
	GameEnums.Strain.NEUTRAL: "dark",
}

## Maps strain enum to strain name string (for combo key construction).
const STRAIN_NAMES := {
	GameEnums.Strain.UNDEAD: "undead",
	GameEnums.Strain.ROBOTIC: "robotic",
	GameEnums.Strain.DRACONIC: "draconic",
	GameEnums.Strain.BEAST: "beast",
	GameEnums.Strain.ELEMENTAL: "elemental",
	GameEnums.Strain.ABERRANT: "aberrant",
}

## Stat multipliers per rarity tier.
const RARITY_STAT_MULTIPLIERS := {
	GameEnums.Rarity.COMMON: 1.0,
	GameEnums.Rarity.UNCOMMON: 1.25,
	GameEnums.Rarity.RARE: 1.5,
	GameEnums.Rarity.LEGENDARY: 2.0,
}

## Cached part templates keyed by shape_id.
static var part_templates: Dictionary = {}

## Cached ability templates keyed by ability_id.
static var ability_templates: Dictionary = {}

## Cached behavior templates keyed by detail_type.
static var behavior_templates: Dictionary = {}

## Cached combo ability templates keyed by "{strain}_{tier}".
static var combo_templates: Dictionary = {}

## Cached starter chimera definitions.
static var starter_chimeras: Array[ChimeraData] = []

## Whether templates have been loaded from disk.
static var _loaded: bool = false


## Ensure all templates are loaded from .tres files.
## Called lazily on first lookup; idempotent.
static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	# Load part abilities
	for dir_path in [
		"res://resources/abilities/head/",
		"res://resources/abilities/torso/",
		"res://resources/abilities/arms/",
		"res://resources/abilities/legs/",
	]:
		for resource in _load_dir(dir_path):
			if resource is AbilityData:
				ability_templates[resource.id] = resource
	# Load combo abilities (into both dicts)
	for resource in _load_dir("res://resources/abilities/combos/"):
		if resource is AbilityData:
			ability_templates[resource.id] = resource
			combo_templates[resource.id] = resource
	# Load behavior modules
	for resource in _load_dir("res://resources/behaviors/"):
		if resource is BehaviorModuleData:
			behavior_templates[resource.detail_type] = resource
	# Load part templates
	for dir_path in [
		"res://resources/parts/head/",
		"res://resources/parts/torso/",
		"res://resources/parts/arms/",
		"res://resources/parts/legs/",
	]:
		for resource in _load_dir(dir_path):
			if resource is PartData:
				part_templates[resource.shape_id] = resource
	# Load starter chimeras
	for resource in _load_dir("res://resources/starters/"):
		if resource is ChimeraData:
			starter_chimeras.append(resource)


## Load all .tres files from a directory.
static func _load_dir(dir_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return resources
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load(dir_path + file_name)
			if resource != null:
				resources.append(resource)
		file_name = dir.get_next()
	dir.list_dir_end()
	return resources


## Retrieve a part by its shape, strain, and rarity.
##
## Returns a duplicate PartData with strain, rarity, and sprite_path set.
## Returns null if the shape_id is not found.
static func get_part(
	shape_id: String, strain: GameEnums.Strain, rarity: GameEnums.Rarity
) -> PartData:
	_ensure_loaded()
	var template: PartData = part_templates.get(shape_id)
	if template == null:
		return null
	var part := template.duplicate(true)
	part.strain = strain
	part.rarity = rarity
	part.sprite_path = get_sprite_path(shape_id, strain)
	# Apply rarity stat multipliers
	var multiplier: float = RARITY_STAT_MULTIPLIERS.get(rarity, 1.0)
	part.hp_bonus *= multiplier
	part.attack_bonus *= multiplier
	part.defense_bonus *= multiplier
	part.speed_bonus *= multiplier
	return part


## Retrieve an ability by its ID.
static func get_ability(ability_id: String) -> AbilityData:
	_ensure_loaded()
	return ability_templates.get(ability_id)


## Retrieve an ability with rarity potency modifiers applied.
##
## Returns a duplicate AbilityData with adjusted cooldown and effect amounts:
## - Rare: -15% cooldown
## - Legendary: -25% cooldown + +20% effect amount
static func get_ability_with_rarity(ability_id: String, rarity: GameEnums.Rarity) -> AbilityData:
	_ensure_loaded()
	var template: AbilityData = ability_templates.get(ability_id)
	if template == null:
		return null
	var ability := template.duplicate(true)
	match rarity:
		GameEnums.Rarity.RARE:
			ability.cooldown *= 0.85
		GameEnums.Rarity.LEGENDARY:
			ability.cooldown *= 0.75
			for effect in ability.effects:
				if effect.params.has("amount"):
					effect.params["amount"] = float(effect.params["amount"]) * 1.2
	return ability


## Retrieve base stats for a shape variant.
static func get_base_stats(shape_id: String) -> Dictionary:
	_ensure_loaded()
	var template: PartData = part_templates.get(shape_id)
	if template == null:
		return {}
	return {
		"hp_bonus": template.hp_bonus,
		"attack_bonus": template.attack_bonus,
		"defense_bonus": template.defense_bonus,
		"speed_bonus": template.speed_bonus,
	}


## Generate a random part for a slot and rarity weights.
##
## Picks a random shape from templates for the given slot,
## a weighted random rarity, and a random playable strain.
## Returns null if no templates exist for the slot.
static func generate_random_part(slot: GameEnums.PartSlot, rarity_weights: Dictionary) -> PartData:
	_ensure_loaded()
	# Collect shape_ids for the given slot
	var shape_ids: Array[String] = []
	for shape_id in part_templates:
		var template: PartData = part_templates[shape_id]
		if template.slot == slot:
			shape_ids.append(shape_id)
	if shape_ids.is_empty():
		return null
	# Pick random shape
	var shape_id: String = shape_ids[randi() % shape_ids.size()]
	# Pick weighted random rarity
	var rarity: GameEnums.Rarity = _pick_weighted_rarity(rarity_weights)
	# Pick random playable strain (0-5 = UNDEAD through ABERRANT, excluding NEUTRAL=6)
	var strain: GameEnums.Strain = randi() % 6
	return get_part(shape_id, strain, rarity)


## Pick a rarity based on weighted random selection.
##
## rarity_weights maps GameEnums.Rarity values to integer weights.
## Returns COMMON if weights are empty or sum to zero.
static func _pick_weighted_rarity(rarity_weights: Dictionary) -> GameEnums.Rarity:
	var total_weight := 0
	for weight in rarity_weights.values():
		total_weight += int(weight)
	if total_weight <= 0:
		return GameEnums.Rarity.COMMON
	var roll := randi() % total_weight
	var cumulative := 0
	for rarity_key in rarity_weights:
		cumulative += int(rarity_weights[rarity_key])
		if roll < cumulative:
			return rarity_key
	return GameEnums.Rarity.COMMON


## Retrieve the strain combo ability for a given tier.
##
## Returns null for NEUTRAL strain or unknown combos.
static func get_strain_combo(strain: GameEnums.Strain, tier: int) -> AbilityData:
	_ensure_loaded()
	if strain == GameEnums.Strain.NEUTRAL:
		return null
	var key := "%s_%d" % [STRAIN_NAMES[strain], tier]
	return combo_templates.get(key)


## Retrieve a behavior module by its detail type.
static func get_behavior_module(detail_type: String) -> BehaviorModuleData:
	_ensure_loaded()
	return behavior_templates.get(detail_type)


## Retrieve the 3 starter chimera definitions.
static func get_starter_chimeras() -> Array[ChimeraData]:
	_ensure_loaded()
	return starter_chimeras


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
