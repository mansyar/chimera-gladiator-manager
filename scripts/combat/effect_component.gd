class_name EffectComponent
extends Node

## Tracks, ticks, and cleans up ActiveEffects on a ChimeraEntity during combat.
## The caller (ChimeraEntity in TRACK-005) is responsible for calling tick() each frame.

var active_effects: Array[ActiveEffect] = []
var stat_modifiers: Dictionary = {}


func add_effect(effect: ActiveEffect) -> void:
	active_effects.append(effect)
	recalculate_modifiers()


func tick(delta: float) -> void:
	var any_expired := false
	var remaining: Array[ActiveEffect] = []
	for effect in active_effects:
		if effect.tick(delta):
			any_expired = true
		else:
			remaining.append(effect)
	if any_expired:
		active_effects = remaining
		recalculate_modifiers()


func recalculate_modifiers() -> void:
	stat_modifiers.clear()
	for effect in active_effects:
		if (
			effect.effect_type == AbilityEffect.EffectType.BUFF_STAT
			or effect.effect_type == AbilityEffect.EffectType.DEBUFF_STAT
		):
			if stat_modifiers.has(effect.stat_name):
				stat_modifiers[effect.stat_name] += effect.amount
			else:
				stat_modifiers[effect.stat_name] = effect.amount


func get_modified_stat(stat_name: String, base_value: float) -> float:
	return base_value + stat_modifiers.get(stat_name, 0.0)


func cleanse() -> void:
	var remaining: Array[ActiveEffect] = []
	for effect in active_effects:
		if effect.effect_type != AbilityEffect.EffectType.DEBUFF_STAT:
			remaining.append(effect)
	active_effects = remaining
	recalculate_modifiers()
