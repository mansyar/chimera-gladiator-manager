## Persistent campaign state manager.
##
## Stores and manages all persistent game data including:
## - Player's chimera roster
## - Inventory and currency
## - Campaign progress
extends Node

# --- Currency ---

## Player's gold. Starts at 200, never goes below 0.
var gold: int = 200

## Player's infamy score. Starts at 0.
var infamy: int = 0

# --- Roster & Inventory ---

## Player's chimera roster. Always exactly 3 slots.
var roster: Array[ChimeraData] = []

## Player's spare parts inventory.
var inventory: Array[PartData] = []

# --- Market ---

## Market stock: {base: Array[PartData], rotating: Array[PartData]}.
var market_stock: Dictionary = {}

# --- Research ---

## Research progress: {branch: {node: level}}.
var research_progress: Dictionary = {}

## Available research points.
var research_points: int = 0

# --- Campaign Progress ---

## Ascended chimeras hall of fame.
var hall_of_fame: Array[ChimeraData] = []

## Current tournament data.
var current_tournament: Dictionary = {}

## Match history records.
var match_history: Array[Dictionary] = []

## Current losing streak (for rubber-band scaling).
var losing_streak: int = 0

# --- Currency Management ---


## Add gold to the treasury.[br]
## Clamps to 0 if result would be negative.[br]
## [param amount] The amount to add (can be negative).[br]
## Emits [signal EventBus.gold_changed].
func add_gold(amount: int) -> void:
	gold += amount
	if gold < 0:
		gold = 0
	EventBus.gold_changed.emit(gold)


## Spend gold if sufficient.[br]
## Returns [code]false[/code] if not enough gold (gold never goes below 0).[br]
## [param amount] The amount to spend.[br]
## [returns] [code]true[/code] if successful, [code]false[/code] if insufficient.
func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	EventBus.gold_changed.emit(gold)
	return true


## Add infamy to the player's reputation.[br]
## [param amount] The amount to add.[br]
## Emits [signal EventBus.infamy_changed].
func add_infamy(amount: int) -> void:
	infamy += amount
	EventBus.infamy_changed.emit(infamy)
