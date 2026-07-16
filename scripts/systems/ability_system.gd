## AbilitySystem static utility (TRACK-007).
##
## Pure functions for executing ability effects against targets.
## No state — all state lives on the ChimeraEntity/CombatState/EffectComponent.
class_name AbilitySystem
extends RefCounted


## Execute an ability effect against one or more targets.
## Dispatches to the appropriate handler based on effect_type.
## [param effect] - The AbilityEffect to execute
## [param source] - The ChimeraEntity casting the ability
## [param targets] - Array of ChimeraEntity targets
## [param all_effects] - All effects in the parent ability (needed for RANDOM_EFFECT)
static func execute_effect(
	effect: AbilityEffect,
	source: ChimeraEntity,
	targets: Array,
	all_effects: Array[AbilityEffect] = []
) -> void:
	# RANDOM_EFFECT is special — it picks one effect and executes against all targets,
	# so it must not be inside the per-target loop.
	if effect.effect_type == AbilityEffect.EffectType.RANDOM_EFFECT:
		_execute_random_effect(source, targets, all_effects)
		return
	for target in targets:
		match effect.effect_type:
			AbilityEffect.EffectType.DAMAGE:
				_execute_damage(effect, source, target)
			AbilityEffect.EffectType.HEAL:
				_execute_heal(effect, target)
			AbilityEffect.EffectType.BUFF_STAT:
				_execute_buff_stat(effect, source, target)
			AbilityEffect.EffectType.DEBUFF_STAT:
				_execute_debuff_stat(effect, source, target)
			AbilityEffect.EffectType.REPOSITION:
				_execute_reposition(effect, source, target)
			AbilityEffect.EffectType.SHIELD:
				_execute_shield(effect, target)
			AbilityEffect.EffectType.CLEANSE:
				_execute_cleanse(target)
			AbilityEffect.EffectType.REVIVE:
				_execute_revive(effect, target)
			AbilityEffect.EffectType.ENRAGE:
				_execute_enrage(effect, target)
			AbilityEffect.EffectType.STAT_MUTATION:
				_execute_stat_mutation(effect, target)


static func _execute_damage(
	effect: AbilityEffect, source: ChimeraEntity, target: ChimeraEntity
) -> void:
	var amount: float = effect.params.get("amount", 0.0) * source.combat_state.attack
	if target.effect_component:
		amount = target.effect_component.absorb_damage(amount)
	target.combat_state.take_damage(amount)


static func _execute_heal(effect: AbilityEffect, target: ChimeraEntity) -> void:
	var amount: float = effect.params.get("amount", 0.0)
	target.combat_state.heal(amount)


static func _execute_buff_stat(
	effect: AbilityEffect, source: ChimeraEntity, target: ChimeraEntity
) -> void:
	if target.effect_component == null:
		return
	var ae := ActiveEffect.new()
	ae.effect_type = AbilityEffect.EffectType.BUFF_STAT
	ae.stat_name = effect.params.get("stat", "")
	ae.amount = effect.params.get("amount", 0.0)
	ae.duration = effect.params.get("duration", 0.0)
	ae.source_id = _get_source_id(source)
	target.effect_component.add_effect(ae)


static func _execute_debuff_stat(
	effect: AbilityEffect, source: ChimeraEntity, target: ChimeraEntity
) -> void:
	if target.effect_component == null:
		return
	var ae := ActiveEffect.new()
	ae.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	ae.stat_name = effect.params.get("stat", "")
	ae.amount = -effect.params.get("amount", 0.0)
	ae.duration = effect.params.get("duration", 0.0)
	ae.source_id = _get_source_id(source)
	target.effect_component.add_effect(ae)


static func _execute_reposition(
	effect: AbilityEffect, source: ChimeraEntity, target: ChimeraEntity
) -> void:
	var distance: float = effect.params.get("distance", 0.0)
	var direction: Vector2
	if target == source:
		# SELF targeting: push toward nearest living enemy
		if source.combat_context == null:
			return
		var nearest := _find_nearest_enemy(source)
		if nearest == null:
			return
		direction = (nearest.global_position - source.global_position).normalized()
	else:
		direction = (target.global_position - source.global_position).normalized()
	target.global_position += direction * distance


static func _execute_shield(effect: AbilityEffect, target: ChimeraEntity) -> void:
	if target.effect_component == null:
		return
	var ae := ActiveEffect.new()
	ae.effect_type = AbilityEffect.EffectType.SHIELD
	ae.amount = effect.params.get("amount", 0.0)
	ae.duration = effect.params.get("duration", 0.0)
	target.effect_component.add_effect(ae)


static func _execute_cleanse(target: ChimeraEntity) -> void:
	if target.effect_component == null:
		return
	target.effect_component.cleanse()


static func _execute_revive(effect: AbilityEffect, target: ChimeraEntity) -> void:
	if not target.combat_state.is_dead:
		return
	target.combat_state.is_dead = false
	var hp_percent: float = effect.params.get("hp_percent", 0.0)
	target.combat_state.current_hp = target.combat_state.max_hp * hp_percent


static func _execute_enrage(effect: AbilityEffect, target: ChimeraEntity) -> void:
	if target.ai_controller == null:
		return
	target.ai_controller.enter_berserk()
	target.combat_state.berserk_timer = effect.params.get("duration", 0.0)


static func _execute_stat_mutation(effect: AbilityEffect, target: ChimeraEntity) -> void:
	var stat_name: String = effect.params.get("stat", "")
	var amount: float = effect.params.get("amount", 0.0)
	var current_value: float = target.combat_state.get(stat_name)
	target.combat_state.set(stat_name, current_value + amount)


static func _execute_random_effect(
	source: ChimeraEntity, targets: Array, all_effects: Array[AbilityEffect]
) -> void:
	# Collect all effects except RANDOM_EFFECT entries
	var other_effects: Array[AbilityEffect] = []
	for e in all_effects:
		if e.effect_type != AbilityEffect.EffectType.RANDOM_EFFECT:
			other_effects.append(e)
	if other_effects.is_empty():
		return
	var picked: AbilityEffect = other_effects[randi() % other_effects.size()]
	execute_effect(picked, source, targets, all_effects)


static func _get_source_id(source: ChimeraEntity) -> String:
	if source.ability_component:
		return source.ability_component.current_ability_id
	return ""


static func _find_nearest_enemy(source: ChimeraEntity) -> ChimeraEntity:
	var enemies: Array[ChimeraEntity] = source.combat_context.get_enemies_of(
		source.combat_state.team
	)
	var nearest: ChimeraEntity = null
	var nearest_dist: float = INF
	for enemy in enemies:
		if enemy.combat_state.is_dead:
			continue
		var dist: float = source.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest
