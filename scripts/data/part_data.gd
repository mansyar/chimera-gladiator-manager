## A single equippable body part.
##
## Represents one of four equipment slots (HEAD, TORSO, ARMS, LEGS)
## with associated stat bonuses, strain, rarity, and ability reference.
class_name PartData
extends Resource

## Equipment slot this part occupies.
@export var slot: GameEnums.PartSlot

## Unique identifier for the part's shape variant.
@export var shape_id: String

## Bio strain of this part.
@export var strain: GameEnums.Strain

## Rarity tier of this part.
@export var rarity: GameEnums.Rarity

## Path to the sprite resource for this part.
@export var sprite_path: String

## Bonus HP granted by this part.
@export var hp_bonus: float = 0.0

## Bonus attack granted by this part.
@export var attack_bonus: float = 0.0

## Bonus defense granted by this part.
@export var defense_bonus: float = 0.0

## Bonus speed granted by this part.
@export var speed_bonus: float = 0.0

## Identifier for the ability granted by this part.
## Looked up via PartDatabase to avoid data duplication.
@export var ability_id: String

## AI behavior module (HEAD parts only, null otherwise).
@export var behavior_module: BehaviorModuleData

## Attack range in pixels (ARMS only, defaults to melee).
@export var attack_range: float = 32.0
