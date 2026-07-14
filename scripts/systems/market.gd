## Market static utility (TRACK-004).
##
## Pure functions for purchase validation, price calculation,
## stock generation, and market discounts. No state.
class_name Market
extends RefCounted

## Minimum infamy required to purchase Legendary parts.
const LEGENDARY_INFAMY_THRESHOLD: int = 50

## Discount percentage per Market Connections research level.
const DISCOUNT_PER_LEVEL: float = 0.15

## Maximum Market Connections research level (capped discount).
const MAX_DISCOUNT_LEVEL: int = 2

## Minimum number of rotating stock parts.
const ROTATING_STOCK_MIN: int = 6

## Maximum number of rotating stock parts.
const ROTATING_STOCK_MAX: int = 10

## Rarity weights for rotating stock generation.
const ROTATING_RARITY_WEIGHTS: Dictionary = {
	GameEnums.Rarity.COMMON: 50,
	GameEnums.Rarity.UNCOMMON: 30,
	GameEnums.Rarity.RARE: 15,
	GameEnums.Rarity.LEGENDARY: 5,
}

## All part slots for base stock generation.
const ALL_SLOTS: Array[GameEnums.PartSlot] = [
	GameEnums.PartSlot.HEAD,
	GameEnums.PartSlot.TORSO,
	GameEnums.PartSlot.ARMS,
	GameEnums.PartSlot.LEGS,
]

## All playable strains (excluding NEUTRAL) for base stock generation.
const PLAYABLE_STRAINS: Array[GameEnums.Strain] = [
	GameEnums.Strain.UNDEAD,
	GameEnums.Strain.ROBOTIC,
	GameEnums.Strain.DRACONIC,
	GameEnums.Strain.BEAST,
	GameEnums.Strain.ELEMENTAL,
	GameEnums.Strain.ABERRANT,
]

## Price ranges per rarity tier [min, max].
const PRICE_RANGES: Dictionary = {
	GameEnums.Rarity.COMMON: [50, 100],
	GameEnums.Rarity.UNCOMMON: [150, 300],
	GameEnums.Rarity.RARE: [500, 1000],
	GameEnums.Rarity.LEGENDARY: [1500, 3000],
}

## Rarity weights for base stock (all Common).
const BASE_RARITY_WEIGHTS: Dictionary = {
	GameEnums.Rarity.COMMON: 100,
}


## Validate whether a part can be purchased with the given gold and infamy.
## [br]
## [param part] - The PartData to purchase[br]
## [param gold] - Available gold[br]
## [param infamy] - Current infamy rating[br]
## [returns] Dictionary with "valid" (bool), "reason" (String), "price" (int)
static func validate_purchase(part: PartData, gold: int, infamy: int) -> Dictionary:
	var price := calculate_price(part)
	if part.rarity == GameEnums.Rarity.LEGENDARY and infamy < LEGENDARY_INFAMY_THRESHOLD:
		return {
			"valid": false,
			"reason":
			"Insufficient infamy for Legendary part (need %d)" % LEGENDARY_INFAMY_THRESHOLD,
			"price": price,
		}
	if gold < price:
		return {
			"valid": false,
			"reason": "Insufficient gold (have %d, need %d)" % [gold, price],
			"price": price,
		}
	return {"valid": true, "reason": "", "price": price}


## Calculate a random price for a part based on its rarity.
## [br]
## [param part] - The PartData to price[br]
## [returns] Price in Gold within the rarity's range
static func calculate_price(part: PartData) -> int:
	var range: Array = PRICE_RANGES[part.rarity]
	return randi_range(range[0], range[1])


## Generate the initial market stock with base and rotating sections.
## [br]
## [returns] Dictionary with "base" (Array[PartData]) and "rotating" (Array[PartData])
static func generate_initial_stock() -> Dictionary:
	var base: Array[PartData] = []
	# Generate 24 common parts: 4 slots x 6 strains
	for slot in ALL_SLOTS:
		for strain in PLAYABLE_STRAINS:
			var part := PartDatabase.generate_random_part(slot, BASE_RARITY_WEIGHTS)
			if part != null:
				# Override strain to match the exact slot x strain pair
				part.strain = strain
				base.append(part)
	var rotating := generate_rotating_stock()
	return {"base": base, "rotating": rotating}


## Generate rotating stock: 6-10 random parts with rarity weights.
## [br]
## [returns] Array of PartData parts
static func generate_rotating_stock() -> Array[PartData]:
	var count := randi_range(ROTATING_STOCK_MIN, ROTATING_STOCK_MAX)
	var parts: Array[PartData] = []
	for i in count:
		var slot: GameEnums.PartSlot = ALL_SLOTS[randi() % ALL_SLOTS.size()]
		var part := PartDatabase.generate_random_part(slot, ROTATING_RARITY_WEIGHTS)
		if part != null:
			parts.append(part)
	return parts


## Apply Market Connections research discount to a price.
## [br]
## [param price] - Original price[br]
## [param research_level] - Market Connections research level (0-2, capped)[br]
## [returns] Discounted price in Gold
static func apply_market_connections_discount(price: int, research_level: int) -> int:
	var effective_level: int = min(research_level, MAX_DISCOUNT_LEVEL)
	var discount: float = effective_level * DISCOUNT_PER_LEVEL
	return int(price * (1.0 - discount))
