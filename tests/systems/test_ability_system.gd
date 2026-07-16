# gdlint:ignore=max-public-methods
extends GutTest

## Tests for AbilitySystem static utility (TRACK-007 Phase 2).
## Verifies all 11 EffectType handlers in execute_effect().

# --- Helpers ---


func _make_entity(
	hp: float = 100.0,
	attack: float = 20.0,
	defense: float = 10.0,
	team: int = 0,
	with_ai: bool = false
) -> ChimeraEntity:
	var entity := ChimeraEntity.new()
	entity.combat_state = CombatState.new()
	entity.combat_state.max_hp = hp
	entity.combat_state.current_hp = hp
	entity.combat_state.attack = attack
	entity.combat_state.defense = defense
	entity.combat_state.team = team
	entity.combat_state.chimera_data = ChimeraData.new()
	entity.team = team
	var ec := EffectComponent.new()
	ec.name = "EffectComponent"
	entity.add_child(ec)
	var ac := AbilityComponent.new()
	ac.name = "AbilityComponent"
	entity.add_child(ac)
	if with_ai:
		var ai := AIController.new()
		ai.name = "AIController"
		entity.add_child(ai)
	add_child_autofree(entity)
	if with_ai:
		entity.ai_controller.combat_state = entity.combat_state
	return entity


func _make_effect(effect_type: AbilityEffect.EffectType, params: Dictionary = {}) -> AbilityEffect:
	var effect := AbilityEffect.new()
	effect.effect_type = effect_type
	effect.params = params
	return effect


func _make_combat_context(entities: Array) -> CombatContext:
	var ctx := CombatContext.new()
	for e in entities:
		ctx.register_entity(e)
	return ctx


# --- DAMAGE tests ---


func test_damage_reduces_target_hp() -> void:
	var source := _make_entity(100.0, 20.0)
	var target := _make_entity(100.0, 10.0)
	var effect := _make_effect(AbilityEffect.EffectType.DAMAGE, {"amount": 2.0})
	AbilitySystem.execute_effect(effect, source, [target])
	# damage = 2.0 * 20.0 = 40.0
	assert_eq(
		target.combat_state.current_hp, 60.0, "DAMAGE should reduce HP by amount * source.attack"
	)


func test_damage_multiple_targets() -> void:
	var source := _make_entity(100.0, 10.0)
	var target_a := _make_entity(100.0, 10.0)
	var target_b := _make_entity(100.0, 10.0)
	var effect := _make_effect(AbilityEffect.EffectType.DAMAGE, {"amount": 3.0})
	AbilitySystem.execute_effect(effect, source, [target_a, target_b])
	# damage = 3.0 * 10.0 = 30.0 each
	assert_eq(target_a.combat_state.current_hp, 70.0)
	assert_eq(target_b.combat_state.current_hp, 70.0)


# --- HEAL tests ---


func test_heal_increases_hp() -> void:
	var source := _make_entity(100.0, 20.0)
	var target := _make_entity(100.0, 10.0)
	target.combat_state.current_hp = 50.0
	var effect := _make_effect(AbilityEffect.EffectType.HEAL, {"amount": 30.0})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.combat_state.current_hp, 80.0)


func test_heal_capped_at_max_hp() -> void:
	var source := _make_entity(100.0, 20.0)
	var target := _make_entity(100.0, 10.0)
	target.combat_state.current_hp = 90.0
	var effect := _make_effect(AbilityEffect.EffectType.HEAL, {"amount": 30.0})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.combat_state.current_hp, 100.0, "HEAL should cap at max_hp")


# --- BUFF_STAT tests ---


func test_buff_stat_creates_positive_active_effect() -> void:
	var source := _make_entity()
	source.ability_component.current_ability_id = "buff_ability"
	var target := _make_entity()
	var effect := _make_effect(
		AbilityEffect.EffectType.BUFF_STAT, {"stat": "attack", "amount": 15.0, "duration": 5.0}
	)
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects.size(), 1, "Should create 1 ActiveEffect")
	var ae := target.effect_component.active_effects[0]
	assert_eq(ae.effect_type, AbilityEffect.EffectType.BUFF_STAT)
	assert_eq(ae.stat_name, "attack")
	assert_eq(ae.amount, 15.0)
	assert_eq(ae.duration, 5.0)
	assert_eq(ae.source_id, "buff_ability")


# --- DEBUFF_STAT tests ---


func test_debuff_stat_creates_negative_active_effect() -> void:
	var source := _make_entity()
	source.ability_component.current_ability_id = "debuff_ability"
	var target := _make_entity()
	var effect := _make_effect(
		AbilityEffect.EffectType.DEBUFF_STAT, {"stat": "defense", "amount": 10.0, "duration": 3.0}
	)
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects.size(), 1)
	var ae := target.effect_component.active_effects[0]
	assert_eq(ae.effect_type, AbilityEffect.EffectType.DEBUFF_STAT)
	assert_eq(ae.amount, -10.0, "DEBUFF amount should be negative")


func test_debuff_stat_source_id_matches_current_ability_id() -> void:
	var source := _make_entity()
	source.ability_component.current_ability_id = "debuff_id"
	var target := _make_entity()
	var effect := _make_effect(
		AbilityEffect.EffectType.DEBUFF_STAT, {"stat": "attack", "amount": 5.0, "duration": 3.0}
	)
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects[0].source_id, "debuff_id")


# --- SHIELD tests ---


func test_shield_creates_shield_active_effect() -> void:
	var source := _make_entity()
	var target := _make_entity()
	var effect := _make_effect(AbilityEffect.EffectType.SHIELD, {"amount": 50.0, "duration": 10.0})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects.size(), 1)
	var ae := target.effect_component.active_effects[0]
	assert_eq(ae.effect_type, AbilityEffect.EffectType.SHIELD)
	assert_eq(ae.amount, 50.0)
	assert_eq(ae.duration, 10.0)


# --- CLEANSE tests ---


func test_cleanse_removes_debuffs() -> void:
	var source := _make_entity()
	var target := _make_entity()
	# Add a debuff
	var debuff := ActiveEffect.new()
	debuff.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	debuff.stat_name = "attack"
	debuff.amount = -10.0
	debuff.duration = 5.0
	target.effect_component.add_effect(debuff)
	# Add a buff (should survive cleanse)
	var buff := ActiveEffect.new()
	buff.effect_type = AbilityEffect.EffectType.BUFF_STAT
	buff.stat_name = "defense"
	buff.amount = 5.0
	buff.duration = 5.0
	target.effect_component.add_effect(buff)
	var effect := _make_effect(AbilityEffect.EffectType.CLEANSE, {})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects.size(), 1, "Should remove debuff, keep buff")
	assert_eq(
		target.effect_component.active_effects[0].effect_type, AbilityEffect.EffectType.BUFF_STAT
	)


func test_cleanse_leaves_shields() -> void:
	var source := _make_entity()
	var target := _make_entity()
	# Add a debuff
	var debuff := ActiveEffect.new()
	debuff.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	debuff.stat_name = "attack"
	debuff.amount = -10.0
	debuff.duration = 5.0
	target.effect_component.add_effect(debuff)
	# Add a shield (should survive cleanse)
	var shield := ActiveEffect.new()
	shield.effect_type = AbilityEffect.EffectType.SHIELD
	shield.amount = 50.0
	shield.duration = 10.0
	target.effect_component.add_effect(shield)
	var effect := _make_effect(AbilityEffect.EffectType.CLEANSE, {})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.effect_component.active_effects.size(), 1, "Should remove debuff, keep shield")
	assert_eq(
		target.effect_component.active_effects[0].effect_type, AbilityEffect.EffectType.SHIELD
	)


# --- REVIVE tests ---


func test_revive_resurrects_dead_target() -> void:
	var source := _make_entity()
	var target := _make_entity(200.0, 10.0)
	target.combat_state.is_dead = true
	target.combat_state.current_hp = 0.0
	var effect := _make_effect(AbilityEffect.EffectType.REVIVE, {"hp_percent": 0.5})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_false(target.combat_state.is_dead, "Target should be alive")
	assert_eq(target.combat_state.current_hp, 100.0, "HP should be 50% of max_hp")


func test_revive_no_effect_on_living() -> void:
	var source := _make_entity()
	var target := _make_entity(100.0, 10.0)
	target.combat_state.current_hp = 50.0
	var effect := _make_effect(AbilityEffect.EffectType.REVIVE, {"hp_percent": 0.5})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_false(target.combat_state.is_dead, "Target should still be alive")
	assert_eq(target.combat_state.current_hp, 50.0, "HP should be unchanged")


# --- ENRAGE tests ---


func test_enrage_triggers_berserk() -> void:
	var source := _make_entity()
	var target := _make_entity(100.0, 20.0, 10.0, 1, true)
	var effect := _make_effect(AbilityEffect.EffectType.ENRAGE, {"duration": 8.0})
	AbilitySystem.execute_effect(effect, source, [target])
	assert_true(target.combat_state.is_berserk, "ENRAGE should trigger berserk")


func test_enrage_overrides_berserk_timer() -> void:
	var source := _make_entity()
	var target := _make_entity(100.0, 20.0, 10.0, 1, true)
	var effect := _make_effect(AbilityEffect.EffectType.ENRAGE, {"duration": 8.0})
	AbilitySystem.execute_effect(effect, source, [target])
	# enter_berserk sets timer to BERSERK_DURATION (5.0), then ENRAGE overrides to 8.0
	assert_eq(target.combat_state.berserk_timer, 8.0, "ENRAGE should override berserk_timer")


# --- REPOSITION tests ---


func test_reposition_displaces_target_away_from_source() -> void:
	var source := _make_entity()
	source.global_position = Vector2(0, 0)
	var target := _make_entity()
	target.global_position = Vector2(100, 0)
	var effect := _make_effect(AbilityEffect.EffectType.REPOSITION, {"distance": 50.0})
	AbilitySystem.execute_effect(effect, source, [target])
	# Target pushed 50px away from source along (1,0) direction
	assert_eq(target.global_position, Vector2(150, 0))


func test_reposition_self_targeting_pushes_toward_enemy() -> void:
	var source := _make_entity(100.0, 20.0, 10.0, 0)
	source.global_position = Vector2(0, 0)
	var enemy := _make_entity(100.0, 20.0, 10.0, 1)
	enemy.global_position = Vector2(100, 0)
	var ctx := _make_combat_context([source, enemy])
	source.combat_context = ctx
	var effect := _make_effect(AbilityEffect.EffectType.REPOSITION, {"distance": 50.0})
	AbilitySystem.execute_effect(effect, source, [source])
	# Source pushed 50px toward enemy along (1,0) direction
	assert_eq(source.global_position, Vector2(50, 0))


# --- STAT_MUTATION tests ---


func test_stat_mutation_permanently_modifies_stat() -> void:
	var source := _make_entity()
	var target := _make_entity(100.0, 15.0)
	var effect := _make_effect(
		AbilityEffect.EffectType.STAT_MUTATION, {"stat": "attack", "amount": 10.0}
	)
	AbilitySystem.execute_effect(effect, source, [target])
	assert_eq(target.combat_state.attack, 25.0, "STAT_MUTATION should add 10 to attack")


func test_stat_mutation_not_cleansable() -> void:
	var source := _make_entity()
	var target := _make_entity(100.0, 15.0)
	var effect := _make_effect(
		AbilityEffect.EffectType.STAT_MUTATION, {"stat": "attack", "amount": 10.0}
	)
	AbilitySystem.execute_effect(effect, source, [target])
	target.effect_component.cleanse()
	assert_eq(target.combat_state.attack, 25.0, "STAT_MUTATION should not be cleansed")


# --- RANDOM_EFFECT tests ---


func test_random_effect_picks_and_executes_other_effect() -> void:
	var source := _make_entity(100.0, 20.0)
	var target := _make_entity(100.0, 10.0)
	var damage_effect := _make_effect(AbilityEffect.EffectType.DAMAGE, {"amount": 2.0})
	var random_effect := _make_effect(AbilityEffect.EffectType.RANDOM_EFFECT, {})
	var all_effects: Array[AbilityEffect] = [damage_effect, random_effect]
	AbilitySystem.execute_effect(random_effect, source, [target], all_effects)
	# Only 1 other effect (DAMAGE), so it must be picked
	# damage = 2.0 * 20.0 = 40.0
	assert_eq(target.combat_state.current_hp, 60.0, "RANDOM_EFFECT should execute DAMAGE")
