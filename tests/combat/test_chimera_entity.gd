# gdlint:ignore=max-public-methods
extends GutTest

## Tests for ChimeraEntity combat state and effect ticking.
## (FR-2: Chimera entity scene)


func test_combat_state_can_be_set_and_get():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	var state := CombatState.new()
	entity.combat_state = state
	assert_eq(entity.combat_state, state)


func test_process_ticks_effect_component():
	var entity := ChimeraEntity.new()
	var effect_comp := EffectComponent.new()
	effect_comp.name = "EffectComponent"
	entity.add_child(effect_comp)
	add_child_autofree(entity)
	var effect := ActiveEffect.new()
	effect.duration = 2.0
	effect_comp.add_effect(effect)
	entity._process(1.0)
	assert_eq(effect.duration, 1.0, "Effect duration should decrease by delta")


func test_process_without_effect_component_does_not_error():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity._process(0.016)
	assert_true(is_instance_valid(entity), "_process should not crash without EffectComponent")


func test_process_calls_ability_component_update_cooldowns():
	var entity := ChimeraEntity.new()
	var ability_comp := AbilityComponent.new()
	ability_comp.name = "AbilityComponent"
	entity.add_child(ability_comp)
	add_child_autofree(entity)
	ability_comp.cooldowns["test_ability"] = 5.0
	entity._process(2.0)
	assert_almost_eq(
		ability_comp.cooldowns["test_ability"],
		3.0,
		0.01,
		"Cooldown should decrement by delta via _process"
	)


func test_move_toward_target_sets_velocity_horizontal():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity.global_position = Vector2(0, 0)
	var state := CombatState.new()
	state.speed = 100.0
	entity.combat_state = state
	entity.move_toward_target(Vector2(100, 0))
	# direction = (1, 0), velocity = (1, 0) * 100 = (100, 0)
	# NOT multiplied by delta — move_and_slide applies delta internally
	assert_eq(entity.velocity, Vector2(100, 0))


func test_move_toward_target_sets_velocity_diagonal():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity.global_position = Vector2(0, 0)
	var state := CombatState.new()
	state.speed = 200.0
	entity.combat_state = state
	entity.move_toward_target(Vector2(100, 100))
	# direction = (1, 1).normalized() ≈ (0.707, 0.707)
	# velocity = (0.707, 0.707) * 200 ≈ (141.42, 141.42)
	assert_almost_eq(entity.velocity.x, 141.42, 0.1)
	assert_almost_eq(entity.velocity.y, 141.42, 0.1)


# --- Damage Resolution Tests (FR-6) ---


func _make_entity(attack: float, defense: float) -> ChimeraEntity:
	var entity := ChimeraEntity.new()
	entity.combat_state = CombatState.new()
	entity.combat_state.attack = attack
	entity.combat_state.defense = defense
	entity.effect_component = EffectComponent.new()
	return entity


func test_calculate_damage_normal():
	var attacker := _make_entity(50.0, 30.0)
	var defender := _make_entity(40.0, 20.0)
	# damage = max(1.0, 50 - 20) = 30
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 30.0)


func test_calculate_damage_min_one():
	var attacker := _make_entity(10.0, 5.0)
	var defender := _make_entity(5.0, 50.0)
	# damage = max(1.0, 10 - 50) = 1.0
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 1.0)


func test_calculate_damage_berserk_attacker():
	var attacker := _make_entity(50.0, 30.0)
	attacker.combat_state.is_berserk = true
	var defender := _make_entity(40.0, 20.0)
	# berserk: +50% attack → 50 * 1.5 = 75
	# damage = max(1.0, 75 - 20) = 55
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 55.0)


func test_calculate_damage_berserk_defender():
	var attacker := _make_entity(50.0, 30.0)
	var defender := _make_entity(40.0, 20.0)
	defender.combat_state.is_berserk = true
	# berserk: -30% defense → 20 * 0.7 = 14
	# damage = max(1.0, 50 - 14) = 36
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 36.0)


func test_calculate_damage_both_berserk():
	var attacker := _make_entity(50.0, 30.0)
	attacker.combat_state.is_berserk = true
	var defender := _make_entity(40.0, 20.0)
	defender.combat_state.is_berserk = true
	# attacker: 50 * 1.5 = 75
	# defender: 20 * 0.7 = 14
	# damage = max(1.0, 75 - 14) = 61
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 61.0)


func test_calculate_damage_with_effect_modifiers():
	var attacker := _make_entity(50.0, 30.0)
	# Add +10 attack buff
	var atk_buff := ActiveEffect.new()
	atk_buff.effect_type = AbilityEffect.EffectType.BUFF_STAT
	atk_buff.stat_name = "attack"
	atk_buff.amount = 10.0
	atk_buff.duration = 5.0
	attacker.effect_component.add_effect(atk_buff)

	var defender := _make_entity(40.0, 20.0)
	# Add -5 defense debuff
	var def_debuff := ActiveEffect.new()
	def_debuff.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	def_debuff.stat_name = "defense"
	def_debuff.amount = -5.0
	def_debuff.duration = 5.0
	defender.effect_component.add_effect(def_debuff)

	# base_damage = 50 (no berserk), +10 buff → 60
	# defense = 20 (no berserk), -5 debuff → 15
	# damage = max(1.0, 60 - 15) = 45
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 45.0)


func test_calculate_damage_berserk_and_effect_modifiers_combined():
	var attacker := _make_entity(50.0, 30.0)
	attacker.combat_state.is_berserk = true
	# Add +10 attack buff (applied AFTER berserk)
	var atk_buff := ActiveEffect.new()
	atk_buff.effect_type = AbilityEffect.EffectType.BUFF_STAT
	atk_buff.stat_name = "attack"
	atk_buff.amount = 10.0
	atk_buff.duration = 5.0
	attacker.effect_component.add_effect(atk_buff)

	var defender := _make_entity(40.0, 20.0)
	defender.combat_state.is_berserk = true
	# Add -5 defense debuff (applied AFTER berserk)
	var def_debuff := ActiveEffect.new()
	def_debuff.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	def_debuff.stat_name = "defense"
	def_debuff.amount = -5.0
	def_debuff.duration = 5.0
	defender.effect_component.add_effect(def_debuff)

	# berserk first: attack 50 * 1.5 = 75, then +10 buff → 85
	# berserk first: defense 20 * 0.7 = 14, then -5 debuff → 9
	# damage = max(1.0, 85 - 9) = 76
	assert_eq(ChimeraEntity.calculate_damage(attacker, defender), 76.0)


# --- Attack Cadence Tests (FR-7) ---


func test_get_attack_interval():
	# speed=10 → interval = 1.0 / (10 * 0.1) = 1.0
	assert_eq(ChimeraEntity.get_attack_interval(10.0), 1.0)
	# speed=20 → interval = 1.0 / (20 * 0.1) = 0.5
	assert_eq(ChimeraEntity.get_attack_interval(20.0), 0.5)
	# speed=5 → interval = 1.0 / (5 * 0.1) = 2.0
	assert_eq(ChimeraEntity.get_attack_interval(5.0), 2.0)


func test_can_attack_initially_true():
	var entity := ChimeraEntity.new()
	assert_true(entity.can_attack())


func test_reset_attack_timer_makes_can_attack_false():
	var entity := _make_entity(50.0, 30.0)
	entity.combat_state.speed = 10.0
	entity.reset_attack_timer()
	assert_false(entity.can_attack())


func test_attack_timer_resets_after_interval():
	var entity := _make_entity(50.0, 30.0)
	entity.combat_state.speed = 10.0
	entity.reset_attack_timer()
	# interval = 1.0 / (10 * 0.1) = 1.0
	# tick for 1.0 seconds
	entity._process(1.0)
	assert_true(entity.can_attack())


# --- AI/AbilityComponent/CombatContext References (FR-11) ---


func test_ai_controller_onready_reference():
	var entity := ChimeraEntity.new()
	var ai := AIController.new()
	ai.name = "AIController"
	entity.add_child(ai)
	add_child_autofree(entity)
	assert_not_null(entity.ai_controller, "ai_controller should be set via @onready")
	assert_eq(entity.ai_controller, ai)


func test_ai_controller_null_when_no_node():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	assert_null(
		entity.ai_controller, "ai_controller should be null when no AIController child exists"
	)


func test_ability_component_onready_reference():
	var entity := ChimeraEntity.new()
	var ability := AbilityComponent.new()
	ability.name = "AbilityComponent"
	entity.add_child(ability)
	add_child_autofree(entity)
	assert_not_null(entity.ability_component, "ability_component should be set via @onready")
	assert_eq(entity.ability_component, ability)


func test_ability_component_null_when_no_node():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	assert_null(entity.ability_component, "ability_component should be null when no child exists")


func test_team_property_can_be_set():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	entity.team = 1
	assert_eq(entity.team, 1)


func test_team_default_zero():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	assert_eq(entity.team, 0, "team should default to 0")


func test_combat_context_property_can_be_set():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	var ctx := CombatContext.new()
	entity.combat_context = ctx
	assert_eq(entity.combat_context, ctx)


func test_died_signal_emitted():
	var entity := ChimeraEntity.new()
	add_child_autofree(entity)
	watch_signals(entity)
	entity.died.emit(entity)
	assert_signal_emitted(entity, "died", "died signal should be emitted")
