class_name EnemyGenerator

## Static utility for procedural enemy generation with rubber-band difficulty.
##
## Generates enemy rosters with rarity distributions scaled by match type,
## losing streak (rubber-band), and tournament tier.
## (TRACK-008: FR-5 — Enemy Generation)

# --- Difficulty Tier Rarity Weight Tables (FR-5) ---
#
# Weighted rarity distributions per difficulty tier.
# Keys are GameEnums.Rarity values, values are integer weights.
const DIFFICULTY_WEIGHTS: Dictionary = {
	"weak":
	{
		GameEnums.Rarity.COMMON: 80,
		GameEnums.Rarity.UNCOMMON: 18,
		GameEnums.Rarity.RARE: 2,
		GameEnums.Rarity.LEGENDARY: 0,
	},
	"normal":
	{
		GameEnums.Rarity.COMMON: 60,
		GameEnums.Rarity.UNCOMMON: 30,
		GameEnums.Rarity.RARE: 9,
		GameEnums.Rarity.LEGENDARY: 1,
	},
	"tough":
	{
		GameEnums.Rarity.COMMON: 45,
		GameEnums.Rarity.UNCOMMON: 35,
		GameEnums.Rarity.RARE: 18,
		GameEnums.Rarity.LEGENDARY: 2,
	},
	"strong":
	{
		GameEnums.Rarity.COMMON: 30,
		GameEnums.Rarity.UNCOMMON: 40,
		GameEnums.Rarity.RARE: 25,
		GameEnums.Rarity.LEGENDARY: 5,
	},
}

# --- Difficulty Tier Selection (FR-5) ---


## Returns the difficulty tier string for the given match parameters.
## Regular: "normal" (default) or "weak" if losing_streak >= 3 (rubber-band).
## Tournament: "tough" for tiers 1-2, "strong" for tiers 3-4.
## (FR-5: Enemy Generation — GDD 4.6 Rubber-band difficulty)
static func _get_difficulty_tier(
	match_type: String, losing_streak: int, tournament_tier: int
) -> String:
	if match_type == "tournament":
		if tournament_tier >= 3:
			return "strong"
		return "tough"
	if losing_streak >= 3:
		return "weak"
	return "normal"


# --- Enemy Chimera Generation (FR-5) ---


## Generates a single enemy chimera with 4 parts at the given rarity distribution.
## Assembles a ChimeraData and recalculates stats.
## (FR-5: Enemy Generation — each enemy gets 4 parts, recalculate_stats after assembly)
static func _generate_enemy_chimera(rarity_weights: Dictionary) -> ChimeraData:
	var chimera := ChimeraData.new()
	chimera.head = PartDatabase.generate_random_part(GameEnums.PartSlot.HEAD, rarity_weights)
	chimera.torso = PartDatabase.generate_random_part(GameEnums.PartSlot.TORSO, rarity_weights)
	chimera.arms = PartDatabase.generate_random_part(GameEnums.PartSlot.ARMS, rarity_weights)
	chimera.legs = PartDatabase.generate_random_part(GameEnums.PartSlot.LEGS, rarity_weights)
	chimera.calculate_instability()
	chimera.recalculate_stats()
	return chimera
