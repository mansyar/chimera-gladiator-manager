## Tracks, ticks, and cleans up ActiveEffects on a ChimeraEntity during combat.
## The caller (ChimeraEntity in TRACK-005) is responsible for calling tick() each frame.
class_name EffectComponent
extends Node

var active_effects: Array[ActiveEffect] = []
var stat_modifiers: Dictionary = {}


## Appends [param effect] to [member active_effects] and recalculates stat modifiers.
func add_effect(effect: ActiveEffect) -> void:
	active_effects.append(effect)
	recalculate_modifiers()


## Ticks all active effects by [param delta], removing expired ones.
## Recalculates modifiers only if any effects expired.
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


## Sums all BUFF_STAT and DEBUFF_STAT amounts per stat name into [member stat_modifiers].
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


## Returns [param base_value] plus the modifier for [param stat_name], if any.
func get_modified_stat(stat_name: String, base_value: float) -> float:
	return base_value + stat_modifiers.get(stat_name, 0.0)


## Removes all DEBUFF_STAT effects from [member active_effects] and recalculates modifiers.
func cleanse() -> void:
	var remaining: Array[ActiveEffect] = []
	for effect in active_effects:
		if effect.effect_type != AbilityEffect.EffectType.DEBUFF_STAT:
			remaining.append(effect)
	active_effects = remaining
	recalculate_modifiers()
