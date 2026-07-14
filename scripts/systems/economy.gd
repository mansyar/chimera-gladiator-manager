## Economy static utility (TRACK-004).
##
## Pure functions for match rewards, tournament fees,
## multipliers, and infamy thresholds. No state.
class_name Economy
extends RefCounted

## Tournament tiers 1-4: entry fees in Gold.
const TOURNAMENT_ENTRY_FEES: Array[int] = [0, 100, 300, 1000]

## Tournament tiers 1-4: reward multipliers.
const TOURNAMENT_MULTIPLIERS: Array[int] = [1, 2, 4, 8]

## Tournament tiers 1-4: infamy thresholds to enter.
const TOURNAMENT_INFAMY_THRESHOLDS: Array[int] = [0, 50, 150, 400]

## Regular match win reward.
const REGULAR_WIN_GOLD: int = 30
const REGULAR_WIN_INFAMY: int = 2

## Regular match loss consolation.
const REGULAR_LOSS_GOLD: int = 10
const REGULAR_LOSS_INFAMY: int = 0

## Tournament win base reward (multiplied by tier multiplier).
const TOURNAMENT_WIN_BASE_GOLD: int = 50
const TOURNAMENT_WIN_BASE_INFAMY: int = 10

## Tournament loss reward (always 0).
const TOURNAMENT_LOSS_GOLD: int = 0
const TOURNAMENT_LOSS_INFAMY: int = 0


## Calculate match rewards based on match type, outcome, and tournament tier.
## [br]
## [param match_type] - "regular" or "tournament"[br]
## [param won] - Whether the player won[br]
## [param tournament_tier] - Tournament tier 1-4 (unused for regular matches)[br]
## [param losing_streak] - Current losing streak (reserved for future use)[br]
## [returns] Dictionary with "gold" and "infamy" keys
static func calculate_match_reward(
	match_type: String, won: bool, tournament_tier: int, losing_streak: int  # gdlint:ignore=unused-argument
) -> Dictionary:
	if match_type == "tournament":
		if won:
			var multiplier := get_tournament_multiplier(tournament_tier)
			return {
				"gold": TOURNAMENT_WIN_BASE_GOLD * multiplier,
				"infamy": TOURNAMENT_WIN_BASE_INFAMY * multiplier
			}
		return {"gold": TOURNAMENT_LOSS_GOLD, "infamy": TOURNAMENT_LOSS_INFAMY}
	# Regular match
	if won:
		return {"gold": REGULAR_WIN_GOLD, "infamy": REGULAR_WIN_INFAMY}
	return {"gold": REGULAR_LOSS_GOLD, "infamy": REGULAR_LOSS_INFAMY}


## Get the entry fee for a tournament tier.
## [param tier] - Tournament tier 1-4
## [returns] Entry fee in Gold
static func calculate_tournament_entry_fee(tier: int) -> int:
	return TOURNAMENT_ENTRY_FEES[tier - 1]


## Get the reward multiplier for a tournament tier.
## [param tier] - Tournament tier 1-4
## [returns] Multiplier (1, 2, 4, or 8)
static func get_tournament_multiplier(tier: int) -> int:
	return TOURNAMENT_MULTIPLIERS[tier - 1]


## Get the infamy threshold required to enter a tournament tier.
## [param tier] - Tournament tier 1-4
## [returns] Required infamy
static func get_tournament_infamy_threshold(tier: int) -> int:
	return TOURNAMENT_INFAMY_THRESHOLDS[tier - 1]
