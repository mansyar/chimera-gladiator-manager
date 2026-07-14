## Genetic decay logic for chimera maintenance.[br]
##
## Static utility providing decay checking, stat reduction, repair cost
## calculation, and emergency salvage. All functions are pure — GameState
## calls them and stores results.[br]
##
## @tutorial Decay table:
## | Instability | Chance | Stat Loss | Repair Cost |
## |-------------|--------|-----------|-------------|
## | 0 (Pure)    | 0%     | 0%        | 0G          |
## | 1 (Stable)  | 15%    | 5%        | 50G         |
## | 2 (Volatile)| 30%    | 10%       | 100G        |
## | 3 (Chaotic) | 50%    | 15%       | 200G        |
class_name Decay
extends RefCounted

# --- Decay Chances ---

const DECAY_CHANCE_PURE: float = 0.0
const DECAY_CHANCE_STABLE: float = 0.15
const DECAY_CHANCE_VOLATILE: float = 0.30
const DECAY_CHANCE_CHAOTIC: float = 0.50

# --- Stat Loss Percentages ---

const STAT_LOSS_PURE: int = 0
const STAT_LOSS_STABLE: int = 5
const STAT_LOSS_VOLATILE: int = 10
const STAT_LOSS_CHAOTIC: int = 15

# --- Repair Costs ---

const REPAIR_COST_PURE: int = 0
const REPAIR_COST_STABLE: int = 50
const REPAIR_COST_VOLATILE: int = 100
const REPAIR_COST_CHAOTIC: int = 200

# --- Reinforced Genetics ---

const DISCOUNT_PER_LEVEL: float = 0.15
const MAX_DISCOUNT_LEVEL: int = 2


## Returns the decay chance for the given instability level.
static func _get_decay_chance(instability: int) -> float:
	match instability:
		0:
			return DECAY_CHANCE_PURE
		1:
			return DECAY_CHANCE_STABLE
		2:
			return DECAY_CHANCE_VOLATILE
		3:
			return DECAY_CHANCE_CHAOTIC
	return 0.0


## Returns the stat loss percentage for the given instability level.
static func _get_stat_loss_percent(instability: int) -> int:
	match instability:
		0:
			return STAT_LOSS_PURE
		1:
			return STAT_LOSS_STABLE
		2:
			return STAT_LOSS_VOLATILE
		3:
			return STAT_LOSS_CHAOTIC
	return 0


## Returns the base repair cost for the given instability level.
static func _get_base_repair_cost(instability: int) -> int:
	match instability:
		0:
			return REPAIR_COST_PURE
		1:
			return REPAIR_COST_STABLE
		2:
			return REPAIR_COST_VOLATILE
		3:
			return REPAIR_COST_CHAOTIC
	return 0


## Rolls against the decay chance for this chimera.[br]
## Purebreds (instability 0) never decay.[br]
## [param chimera] The chimera to check.[br]
## [returns] Dictionary with keys: "decayed" (bool), "stat_loss_percent" (int), "reason" (String).
static func check_decay(chimera: ChimeraData) -> Dictionary:
	if chimera.instability == 0:
		return {"decayed": false, "stat_loss_percent": 0, "reason": "purebred"}

	var chance: float = _get_decay_chance(chimera.instability)
	if randf() < chance:
		return {
			"decayed": true,
			"stat_loss_percent": _get_stat_loss_percent(chimera.instability),
			"reason": "decay_triggered"
		}
	return {"decayed": false, "stat_loss_percent": 0, "reason": "decay_resisted"}


## Reduces ALL derived stats by the decay percentage and increments decay_level.[br]
## [param chimera] The chimera to apply decay to.[br]
## [returns] Stat loss percentage as a string (e.g. "5%"), or empty string for purebreds.
static func apply_decay(chimera: ChimeraData) -> String:
	if chimera.instability == 0:
		return ""

	var stat_loss: int = _get_stat_loss_percent(chimera.instability)
	var multiplier: float = 1.0 - (float(stat_loss) / 100.0)

	chimera.max_hp *= multiplier
	chimera.attack *= multiplier
	chimera.defense *= multiplier
	chimera.speed *= multiplier
	chimera.decay_level += 1

	return str(stat_loss) + "%"


## Calculates repair cost based on instability and research level.[br]
## [param chimera] The chimera to repair.[br]
## [param research_level] Reinforced Genetics research level (0-2+).[br]
## [returns] Repair cost in Gold.
static func calculate_repair_cost(chimera: ChimeraData, research_level: int) -> int:
	var base_cost: int = _get_base_repair_cost(chimera.instability)
	if base_cost == 0:
		return 0

	var effective_level: int = min(research_level, MAX_DISCOUNT_LEVEL)
	var discount: float = float(effective_level) * DISCOUNT_PER_LEVEL
	return int(float(base_cost) * (1.0 - discount))


## Resets decay_level to 0 and recalculates stats from parts.[br]
## [param chimera] The chimera to repair.
static func repair_chimera(chimera: ChimeraData) -> void:
	chimera.decay_level = 0
	chimera.calculate_instability()
	chimera.recalculate_stats()


## Applies Reinforced Genetics discount to a base decay chance.[br]
## [param base_chance] The original decay chance (0.0 to 1.0).[br]
## [param research_level] Reinforced Genetics research level (0-2+).[br]
## [returns] Reduced decay chance.
static func apply_reinforced_genetics_reduction(base_chance: float, research_level: int) -> float:
	var effective_level: int = min(research_level, MAX_DISCOUNT_LEVEL)
	var reduction: float = float(effective_level) * DISCOUNT_PER_LEVEL
	return base_chance * (1.0 - reduction)


## Breaks a chimera down into Neutral parts, retaining base stats.[br]
## All-Neutral parts count as the same strain, resulting in Pure instability.[br]
## [param chimera] The chimera to salvage.[br]
## [returns] Array of PartData with strain set to NEUTRAL.
static func salvage_chimera(chimera: ChimeraData) -> Array[PartData]:
	var salvaged: Array[PartData] = []
	for part in chimera.get_parts():
		if part == null:
			continue
		var neutral_part: PartData = part.duplicate()
		neutral_part.strain = GameEnums.Strain.NEUTRAL
		salvaged.append(neutral_part)
	return salvaged
