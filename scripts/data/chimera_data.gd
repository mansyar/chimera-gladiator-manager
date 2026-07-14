## Persistent campaign state for a single chimera.
##
## Stores equipped parts, derived stats, abilities, and
## persistent match data. Combat state is handled separately
## by CombatState (transient, per-match).
class_name ChimeraData
extends Resource

## Multiplier applied to all base stats when instability is 0 (purebred).
const PUREBRED_STAT_MULTIPLIER: float = 1.2

# --- Exported Properties (inspector-editable) ---

## Display name for this chimera.
@export var nickname: String

## Part equipped in the HEAD slot.
@export var head: PartData

## Part equipped in the TORSO slot.
@export var torso: PartData

## Part equipped in the ARMS slot.
@export var arms: PartData

## Part equipped in the LEGS slot.
@export var legs: PartData

# --- Derived Stats (recalculated on part change) ---

var max_hp: float
var attack: float
var defense: float
var speed: float
var attack_range: float
var instability: int
var strain_count: int
var dominant_strain: GameEnums.Strain

# --- Abilities (derived from parts) ---

## Abilities granted by equipped parts.
## Populated in TRACK-003 once PartDatabase.get_ability() is implemented.
var part_abilities: Array[AbilityData] = []
var combo_ability: AbilityData
var combo_tier: int = 0

# --- Persistent State ---

var current_hp: float
var decay_level: int = 0
var match_wins: int = 0


## Returns all four equipped parts in slot order: [head, torso, arms, legs].
func get_parts() -> Array[PartData]:
	return [head, torso, arms, legs]


## Returns the part equipped in the given slot, or null if not equipped.
func get_part(slot: GameEnums.PartSlot) -> PartData:
	match slot:
		GameEnums.PartSlot.HEAD:
			return head
		GameEnums.PartSlot.TORSO:
			return torso
		GameEnums.PartSlot.ARMS:
			return arms
		GameEnums.PartSlot.LEGS:
			return legs
	return null


## Recalculates derived stats from equipped parts.
## Call [method calculate_instability] first to update instability.
## [param research_bonuses] Optional stat multipliers keyed by stat name.
func recalculate_stats(research_bonuses: Dictionary = {}) -> void:
	var hp_sum: float = 0.0
	var attack_sum: float = 0.0
	var defense_sum: float = 0.0
	var speed_sum: float = 0.0

	for part in get_parts():
		if part == null:
			continue
		hp_sum += part.hp_bonus
		attack_sum += part.attack_bonus
		defense_sum += part.defense_bonus
		speed_sum += part.speed_bonus

	if instability == 0:
		hp_sum *= PUREBRED_STAT_MULTIPLIER
		attack_sum *= PUREBRED_STAT_MULTIPLIER
		defense_sum *= PUREBRED_STAT_MULTIPLIER
		speed_sum *= PUREBRED_STAT_MULTIPLIER

	if research_bonuses.has("max_hp"):
		hp_sum *= research_bonuses["max_hp"]
	if research_bonuses.has("attack"):
		attack_sum *= research_bonuses["attack"]
	if research_bonuses.has("defense"):
		defense_sum *= research_bonuses["defense"]
	if research_bonuses.has("speed"):
		speed_sum *= research_bonuses["speed"]

	max_hp = hp_sum
	attack = attack_sum
	defense = defense_sum
	speed = speed_sum

	if arms != null:
		attack_range = arms.attack_range


## Returns a Dictionary mapping each equipped part's strain to its occurrence count.
## Null parts are skipped.
func _count_strains() -> Dictionary:
	var strain_counts: Dictionary = {}
	for part in get_parts():
		if part == null:
			continue
		var s: int = part.strain
		strain_counts[s] = strain_counts.get(s, 0) + 1
	return strain_counts


## Calculates instability from strain diversity across equipped parts.
## Sets [member instability], [member strain_count], and [member dominant_strain].
func calculate_instability() -> void:
	var strain_counts: Dictionary = _count_strains()

	strain_count = strain_counts.size()
	if strain_count > 0:
		instability = strain_count - 1
	else:
		instability = 0

	var max_count: int = 0
	for s_key in strain_counts:
		var count: int = strain_counts[s_key]
		if count > max_count:
			max_count = count
			dominant_strain = s_key


## Determines combo ability based on strain synergy.
## Returns null if fewer than 2 parts share a strain.
## Sets [member combo_tier] based on dominant strain count.
func get_combo_ability() -> AbilityData:
	var strain_counts: Dictionary = _count_strains()

	var max_count: int = 0
	var dominant: int = 0
	for s_key in strain_counts:
		var count: int = strain_counts[s_key]
		if count > max_count:
			max_count = count
			dominant = s_key

	if max_count >= 2:
		combo_tier = max_count - 1
		return PartDatabase.get_strain_combo(dominant, combo_tier)

	combo_tier = 0
	return null
