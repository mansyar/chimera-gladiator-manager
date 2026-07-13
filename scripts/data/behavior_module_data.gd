## Configuration for an AI behavior module.
##
## Determines how a chimera selects targets, prioritizes abilities,
## and positions itself in formation. Assigned to HEAD parts.
class_name BehaviorModuleData
extends Resource

## Display name of the behavior module.
@export var module_name: String

## Identifier for the head detail type that grants this module.
@export var detail_type: String

## How the chimera selects its combat target.
@export var targeting: GameEnums.TargetingMode

## Priority order for ability categories.
@export var ability_priority: Array[GameEnums.AbilityCategory]

## Preferred formation position.
@export var positioning: GameEnums.Positioning
