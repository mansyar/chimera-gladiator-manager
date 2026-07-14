## Global signal hub for cross-system communication.
##
## All global signals that need to be emitted or listened to
## across different game systems should be defined here.
## This autoload contains no state and no logic — only signal declarations.
extends Node

# --- Currency signals ---

## Emitted when the player's gold amount changes.
signal gold_changed(amount: int)

## Emitted when the player's infamy amount changes.
signal infamy_changed(amount: int)

# --- Chimera signals ---

## Emitted when a part is purchased from the market.
signal part_purchased(part: PartData)

## Emitted when a chimera's assembly is modified.
signal chimera_modified(chimera: ChimeraData)

## Emitted when a chimera undergoes genetic decay.
signal chimera_decayed(chimera: ChimeraData, stat_lost: String)

## Emitted when a chimera is ascended to the hall of fame.
signal chimera_ascended(chimera: ChimeraData)

## Emitted when a chimera enters berserk state.
signal berserk_triggered(chimera: ChimeraData)

# --- Combat signals ---

## Emitted when a combat match begins.
signal match_started(player_roster: Array, enemy_roster: Array)

## Emitted when a combat match ends.
signal match_ended(result: Dictionary)

# --- Market signals ---

## Emitted when the market rotating stock is refreshed.
signal market_refreshed

# --- Research signals ---

## Emitted when a research node is unlocked.
signal research_unlocked(branch: String, node: String, level: int)

# --- UI signals ---

## Emitted when a screen change is requested.
signal screen_change_requested(screen: String)

# --- Logging signals ---

## Emitted to log a combat message for display.
signal combat_log(message: String)
