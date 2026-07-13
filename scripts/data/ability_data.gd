## Definition of a single ability.
##
## A composable collection of effects that can be triggered in combat.
## Referenced by parts via ability_id and looked up via PartDatabase.
class_name AbilityData
extends Resource

## Unique identifier for this ability.
@export var id: String

## Display name of the ability.
@export var name: String

## User-facing description of what the ability does.
@export var description: String

## Whether the ability is active (triggered) or passive (always-on).
@export var type: GameEnums.AbilityType

## Functional category of the ability.
@export var category: GameEnums.AbilityCategory

## Cooldown in seconds between activations.
@export var cooldown: float = 0.0

## Targeting pattern (SELF, TARGET, AOE_ENEMIES, AOE_ALLIES, ALL_ENEMIES).
@export var targeting: String

## Effective range in pixels.
@export var range: float = 0.0

## Composable effects that make up this ability.
@export var effects: Array[AbilityEffect]
