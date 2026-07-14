class_name CombatState
extends RefCounted

## Transient combat state for a chimera during a single match.
## Snapshots stats from ChimeraData at initialization; tracks HP, berserk,
## cooldowns, and active effects for the duration of the fight.

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


func initialize(data: ChimeraData, team_id: int) -> void:
	chimera_data = data
	max_hp = data.max_hp
	attack = data.attack
	defense = data.defense
	speed = data.speed
	current_hp = max_hp
	team = team_id


func take_damage(amount: float) -> void:
	current_hp = maxf(current_hp - amount, 0.0)
	if current_hp <= 0.0:
		is_dead = true


func heal(amount: float) -> void:
	current_hp = minf(current_hp + amount, max_hp)
