## Research static utility (TRACK-004).
##
## Pure functions for research node management, unlock validation,
## and effect value lookup. No state.
class_name Research
extends RefCounted

# --- Branch names ---
const BRANCH_STRAIN_MASTERY := "strain_mastery"
const BRANCH_LAB_ENGINEERING := "lab_engineering"
const BRANCH_COMBAT_DOCTRINE := "combat_doctrine"

# --- Strain Mastery nodes ---
const SM_NODES: Array[String] = ["undead", "robotic", "draconic", "beast", "elemental", "aberrant"]

# --- Lab Engineering nodes ---
const LE_NODES: Array[String] = [
	"reinforced_genetics", "clinic_efficiency", "market_connections", "stability_serum"
]

# --- Combat Doctrine nodes ---
const CD_NODES: Array[String] = [
	"tactical_ai", "ability_tuning", "formation_mastery", "berserk_control"
]

# --- Max levels per branch ---
const MAX_LEVEL_STRAIN_MASTERY: int = 3
const MAX_LEVEL_LAB_ENGINEERING: int = 2
const MAX_LEVEL_COMBAT_DOCTRINE: int = 1

# --- Effect values per level ---
const STAT_BONUS_PER_LEVEL: float = 0.05
const LAB_REDUCTION_PER_LEVEL: float = 0.15

# --- Combat Doctrine effect values (at level 1) ---
const CD_TACTICAL_AI_VALUE: float = 0.10
const CD_ABILITY_TUNING_VALUE: float = 0.10
const CD_FORMATION_MASTERY_VALUE: float = 0.05
const CD_BERSERK_CONTROL_REDUCTION: float = 2.0

# --- Research cost ---
const RESEARCH_COST_PER_LEVEL: int = 1


## Check if a research node can be unlocked.
## [br]
## [param branch] - Research branch name[br]
## [param node] - Research node name[br]
## [param current_level] - Current unlock level of the node[br]
## [param available_points] - Available research points[br]
## [returns] True if the node can be unlocked
static func can_unlock(
	branch: String, node: String, current_level: int, available_points: int
) -> bool:
	var max_level := get_max_level(branch, node)
	if max_level == 0:
		return false
	if current_level >= max_level:
		return false
	return available_points >= get_research_cost(branch, node, current_level)


## Get the maximum unlock level for a research node.
## [br]
## [param branch] - Research branch name[br]
## [param node] - Research node name[br]
## [returns] Max level (3 for Strain Mastery, 2 for Lab Engineering, 1 for Combat Doctrine)
static func get_max_level(branch: String, node: String) -> int:
	match branch:
		BRANCH_STRAIN_MASTERY:
			if node in SM_NODES:
				return MAX_LEVEL_STRAIN_MASTERY
		BRANCH_LAB_ENGINEERING:
			if node in LE_NODES:
				return MAX_LEVEL_LAB_ENGINEERING
		BRANCH_COMBAT_DOCTRINE:
			if node in CD_NODES:
				return MAX_LEVEL_COMBAT_DOCTRINE
	return 0


## Get the effect value for a research node at a given level.
## [br]
## [param branch] - Research branch name[br]
## [param node] - Research node name[br]
## [param level] - Unlock level (clamped to max)[br]
## [returns] Cumulative effect value at the given level
static func get_effect_value(branch: String, node: String, level: int) -> float:
	var max_level := get_max_level(branch, node)
	if max_level == 0:
		return 0.0
	var clamped_level: int = min(level, max_level)
	if clamped_level <= 0:
		return 0.0
	match branch:
		BRANCH_STRAIN_MASTERY:
			return STAT_BONUS_PER_LEVEL * clamped_level
		BRANCH_LAB_ENGINEERING:
			return LAB_REDUCTION_PER_LEVEL * clamped_level
		BRANCH_COMBAT_DOCTRINE:
			return _get_combat_doctrine_value(node)
	return 0.0


## Get the research point cost to unlock the next level.
## [br]
## [param branch] - Research branch name[br]
## [param node] - Research node name[br]
## [param current_level] - Current unlock level[br]
## [returns] Cost in research points (0 if at max level)
static func get_research_cost(branch: String, node: String, current_level: int) -> int:
	var max_level := get_max_level(branch, node)
	if max_level == 0:
		return 0
	if current_level >= max_level:
		return 0
	return RESEARCH_COST_PER_LEVEL


## Get the effect value for a Combat Doctrine node (all single-level).
static func _get_combat_doctrine_value(node: String) -> float:
	match node:
		"tactical_ai":
			return CD_TACTICAL_AI_VALUE
		"ability_tuning":
			return CD_ABILITY_TUNING_VALUE
		"formation_mastery":
			return CD_FORMATION_MASTERY_VALUE
		"berserk_control":
			return CD_BERSERK_CONTROL_REDUCTION
	return 0.0
