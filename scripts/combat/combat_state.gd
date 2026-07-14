## Transient combat state for a chimera during a single match.
## Snapshots stats from ChimeraData at initialization; tracks HP, berserk,
## cooldowns, and active effects for the duration of the fight.
class_name CombatState
extends RefCounted

var chimera_data: ChimeraData
var current_hp: float
var max_hp: float
var attack: float
var defense: float
var speed: float
var is_berserk: bool = false
var berserk_timer: float = 0.0
var berserk_check_timer: float = 0.0
var berserk_modifiers: Dictionary = {}
var ability_cooldowns: Dictionary = {}
var active_effects: Array[ActiveEffect] = []
var is_dead: bool = false
var team: int


## Snapshots stats from [param data] and initializes combat state for team [param team_id].
## Sets [member current_hp] to [member max_hp].
func initialize(data: ChimeraData, team_id: int) -> void:
	chimera_data = data
	max_hp = data.max_hp
	attack = data.attack
	defense = data.defense
	speed = data.speed
	current_hp = max_hp
	team = team_id


## Reduces [member current_hp] by [param amount], floored at 0.
## Sets [member is_dead] when HP reaches 0.
func take_damage(amount: float) -> void:
	current_hp = maxf(current_hp - amount, 0.0)
	if current_hp <= 0.0:
		is_dead = true


## Increases [member current_hp] by [param amount], capped at [member max_hp].
func heal(amount: float) -> void:
	current_hp = minf(current_hp + amount, max_hp)
