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


# --- Roster Management ---


## Get a chimera from the roster by index.[br]
## Returns [code]null[/code] if index is out of bounds.[br]
## [param index] The roster slot index (0-2).
func get_chimera(index: int) -> ChimeraData:
	if index < 0 or index >= roster.size():
		return null
	return roster[index]


## Replace a chimera in the roster.[br]
## Does nothing if index is out of bounds.[br]
## [param index] The roster slot index.[br]
## [param new_chimera] The new ChimeraData to place in the slot.[br]
## Emits [signal EventBus.chimera_modified].
func replace_chimera(index: int, new_chimera: ChimeraData) -> void:
	if index < 0 or index >= roster.size():
		return
	roster[index] = new_chimera
	EventBus.chimera_modified.emit(new_chimera)
	SaveManager.save_game()


# --- Inventory Management ---


## Add a part to the player's inventory.[br]
## [param part] The PartData to add.
func add_part(part: PartData) -> void:
	inventory.append(part)


## Remove a part from the player's inventory.[br]
## Does nothing if the part is not in inventory.[br]
## [param part] The PartData to remove.
func remove_part(part: PartData) -> void:
	inventory.erase(part)


# --- Initialization ---


## Auto-initialize on boot.[br]
## Attempts to load save game. If no save exists, starts a new game.
func _ready() -> void:
	if not SaveManager.load_game():
		_init_new_game()


## Initialize a new game with starting state.[br]
## Sets gold=200, infamy=0, roster=3 starter chimeras from PartDatabase,[br]
## empty inventory, generated market stock, and empty campaign progress.
func _init_new_game() -> void:
	gold = 200
	infamy = 0
	roster.clear()
	var starters := PartDatabase.get_starter_chimeras()
	for starter in starters:
		roster.append(starter.duplicate())
	inventory = []
	market_stock = Market.generate_initial_stock()
	research_progress = {}
	research_points = 0
	hall_of_fame = []
	current_tournament = {}
	match_history = []
	losing_streak = 0


# --- Market Delegation ---


## Buy a part from the market.[br]
## Validates purchase via [class Market], deducts gold, adds part to inventory,[br]
## and emits [signal EventBus.part_purchased].[br]
## [param part] The PartData to purchase.[br]
## [returns] [code]true[/code] if purchase succeeded, [code]false[/code] if invalid.
func buy_part(part: PartData) -> bool:
	var result := Market.validate_purchase(part, gold, infamy)
	if not result["valid"]:
		return false
	var price: int = result["price"]
	spend_gold(price)
	add_part(part)
	EventBus.part_purchased.emit(part)
	SaveManager.save_game()
	return true


## Refresh the market's rotating stock.[br]
## Generates new rotating parts via [class Market] and emits[br]
## [signal EventBus.market_refreshed].
func refresh_market() -> void:
	market_stock["rotating"] = Market.generate_rotating_stock()
	EventBus.market_refreshed.emit()
	SaveManager.save_game()


# --- Ascension ---


## Check if a chimera is eligible for ascension.[br]
## A chimera can ascend when it has 10 or more match wins.[br]
## [param chimera] The chimera to check.[br]
## [returns] [code]true[/code] if eligible, [code]false[/code] otherwise.
func can_ascend(chimera: ChimeraData) -> bool:
	return chimera.match_wins >= 10


## Ascend a chimera to the hall of fame.[br]
## Moves the chimera to hall_of_fame, grants 1 research point, replaces the[br]
## roster slot with a free common starter, and emits[br]
## [signal EventBus.chimera_ascended].[br]
## [param chimera] The chimera to ascend.[br]
## [returns] Research points gained (1 on success, 0 if chimera not in roster).
func ascend_chimera(chimera: ChimeraData) -> int:
	var slot_index := -1
	for i in range(roster.size()):
		if roster[i] == chimera:
			slot_index = i
			break
	if slot_index == -1:
		return 0
	hall_of_fame.append(chimera)
	research_points += 1
	var starters := PartDatabase.get_starter_chimeras()
	roster[slot_index] = starters[randi() % starters.size()].duplicate()
	EventBus.chimera_ascended.emit(chimera)
	SaveManager.save_game()
	return 1


# --- Research ---


## Get the current research level for a node.[br]
## Returns 0 if the node has not been unlocked.[br]
## [param branch] The research branch (e.g. "strain_mastery").[br]
## [param node] The node name within the branch.[br]
## [returns] The current research level (0 if not unlocked).
func get_research_level(branch: String, node: String) -> int:
	if not research_progress.has(branch):
		return 0
	var branch_progress: Dictionary = research_progress[branch]
	if not branch_progress.has(node):
		return 0
	return branch_progress[node]


## Spend a research point to unlock or upgrade a node.[br]
## Validates via [class Research], deducts 1 RP, increments the level,[br]
## and emits [signal EventBus.research_unlocked].[br]
## [param branch] The research branch.[br]
## [param node] The node name within the branch.[br]
## [returns] [code]true[/code] if successful, [code]false[/code] if invalid.
func spend_research_point(branch: String, node: String) -> bool:
	var current_level: int = get_research_level(branch, node)
	if not Research.can_unlock(branch, node, current_level, research_points):
		return false
	research_points -= 1
	var new_level: int = current_level + 1
	if not research_progress.has(branch):
		research_progress[branch] = {}
	research_progress[branch][node] = new_level
	EventBus.research_unlocked.emit(branch, node, new_level)
	SaveManager.save_game()
	return true


# --- Match Results ---


## Record the outcome of a completed match.[br]
## Updates losing streak, appends to match history, applies rewards,[br]
## refreshes the market, and triggers a save.[br]
## [param won] Whether the player won the match.[br]
## [param match_type] The match type ("regular" or "tournament").[br]
## [param rewards] Dictionary with "gold" and "infamy" keys from Economy.
## (FR-6: Post-Match Economy Integration)
func record_match_result(won: bool, _match_type: String, rewards: Dictionary) -> void:
	if won:
		losing_streak = 0
	else:
		losing_streak += 1
	match_history.append({"result": "win" if won else "loss", "gold": rewards["gold"]})
	add_gold(rewards["gold"])
	add_infamy(rewards["infamy"])
	refresh_market()
	SaveManager.save_game()
