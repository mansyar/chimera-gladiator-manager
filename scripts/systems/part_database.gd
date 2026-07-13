## Static database for looking up part and ability templates.
##
## This is a stub implementation — all methods return null or empty.
## Full implementation with data population is in TRACK-003.
class_name PartDatabase

## Cached part templates keyed by "shape_id:strain:rarity".
static var part_templates: Dictionary = {}

## Cached ability templates keyed by ability_id.
static var ability_templates: Dictionary = {}


## Retrieve a part by its shape, strain, and rarity.
##
## Returns null in this stub — full implementation in TRACK-003.
## [br]
## [param _shape_id] Unique shape identifier.[br]
## [param _strain] Bio strain of the part.[br]
## [param _rarity] Rarity tier of the part.
static func get_part(
	_shape_id: String, _strain: GameEnums.Strain, _rarity: GameEnums.Rarity
) -> PartData:
	return null


## Retrieve an ability by its ID.
##
## Returns null in this stub — full implementation in TRACK-003.
## [br]
## [param _ability_id] Unique ability identifier.
static func get_ability(_ability_id: String) -> AbilityData:
	return null


## Retrieve base stats for a shape variant.
##
## Returns an empty Dictionary in this stub.
## [br]
## [param _shape_id] Unique shape identifier.
static func get_base_stats(_shape_id: String) -> Dictionary:
	return {}


## Generate a random part for a slot and rarity weights.
##
## Returns null in this stub — full implementation in TRACK-003.
## [br]
## [param _slot] Equipment slot for the generated part.[br]
## [param _rarity_weights] Weighted rarity distribution.
static func generate_random_part(
	_slot: GameEnums.PartSlot, _rarity_weights: Dictionary
) -> PartData:
	return null


## Retrieve the strain combo ability for a given tier.
##
## Returns null in this stub — full implementation in TRACK-003.
## [br]
## [param _strain] Bio strain of the combo.[br]
## [param _tier] Combo tier (1=basic, 2=enhanced, 3=ultimate).
static func get_strain_combo(_strain: GameEnums.Strain, _tier: int) -> AbilityData:
	return null
