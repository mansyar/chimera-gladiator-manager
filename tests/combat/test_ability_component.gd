# gdlint:ignore=max-public-methods
extends GutTest

## Tests for AbilityComponent (TRACK-007 Phase 1).
## Verifies initialization, cooldown tracking, and ready-ability querying.

# --- Helpers ---


func _make_ability(
	id: String, atype: GameEnums.AbilityType = GameEnums.AbilityType.ACTIVE, cooldown: float = 5.0
) -> AbilityData:
	var ability := AbilityData.new()
	ability.id = id
	ability.name = id
	ability.type = atype
	ability.cooldown = cooldown
	return ability


func _make_part(slot: GameEnums.PartSlot, strain: GameEnums.Strain) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	return part


func _make_combat_state(chimera: ChimeraData) -> CombatState:
	var cs := CombatState.new()
	cs.initialize(chimera, 0)
	return cs


func _setup_chimera_with_abilities(abilities: Array[AbilityData], strains: Array) -> CombatState:
	var chimera := ChimeraData.new()
	chimera.part_abilities = abilities
	chimera.head = _make_part(GameEnums.PartSlot.HEAD, strains[0])
	chimera.torso = _make_part(GameEnums.PartSlot.TORSO, strains[1])
	chimera.arms = _make_part(GameEnums.PartSlot.ARMS, strains[2])
	chimera.legs = _make_part(GameEnums.PartSlot.LEGS, strains[3])
	return _make_combat_state(chimera)


# --- initialize() tests ---


func test_initialize_populates_abilities_from_part_abilities() -> void:
	var ability_a := _make_ability("fire_blast")
	var ability_b := _make_ability("ice_shard")
	var combat_state := _setup_chimera_with_abilities(
		[ability_a, ability_b],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	assert_eq(
		component.abilities.size(),
		2,
		"Should have 2 part abilities (no combo — all different strains)"
	)


func test_initialize_adds_combo_ability_for_same_strain() -> void:
	var ability_a := _make_ability("fire_blast")
	var combat_state := _setup_chimera_with_abilities(
		[ability_a],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	# 1 part ability + 1 combo ability
	assert_eq(component.abilities.size(), 2, "Should have 1 part ability + 1 combo ability")


func test_initialize_no_combo_for_all_different_strains() -> void:
	var ability_a := _make_ability("fire_blast")
	var ability_b := _make_ability("ice_shard")
	var combat_state := _setup_chimera_with_abilities(
		[ability_a, ability_b],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	# No combo — all different strains
	assert_eq(component.abilities.size(), 2, "Should have 2 part abilities, no combo")


func test_initialize_sets_cooldowns_to_zero() -> void:
	var ability_a := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var ability_b := _make_ability("heal_self", GameEnums.AbilityType.ACTIVE, 8.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability_a, ability_b],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	assert_almost_eq(
		component.cooldowns["fire_blast"], 0.0, 0.01, "fire_blast cooldown should be 0.0"
	)
	assert_almost_eq(
		component.cooldowns["heal_self"], 0.0, 0.01, "heal_self cooldown should be 0.0"
	)


# --- is_off_cooldown() tests ---


func test_is_off_cooldown_true_for_fresh_ability() -> void:
	var ability := _make_ability("fire_blast")
	var combat_state := _setup_chimera_with_abilities(
		[ability],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	assert_true(component.is_off_cooldown(ability), "Fresh ability should be off cooldown")


func test_is_off_cooldown_false_after_execute_sets_cooldown() -> void:
	var ability := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(ability, null)
	assert_false(component.is_off_cooldown(ability), "Ability should be on cooldown after execute")


# --- update_cooldowns() tests ---


func test_update_cooldowns_decrements_all() -> void:
	var ability_a := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var ability_b := _make_ability("ice_shard", GameEnums.AbilityType.ACTIVE, 8.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability_a, ability_b],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(ability_a, null)
	component.execute_ability(ability_b, null)
	component.update_cooldowns(3.0)
	assert_almost_eq(component.cooldowns["fire_blast"], 2.0, 0.01, "fire_blast should be 5-3=2.0")
	assert_almost_eq(component.cooldowns["ice_shard"], 5.0, 0.01, "ice_shard should be 8-3=5.0")


func test_update_cooldowns_floors_at_zero() -> void:
	var ability := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 3.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(ability, null)
	component.update_cooldowns(10.0)
	assert_almost_eq(component.cooldowns["fire_blast"], 0.0, 0.01, "Cooldown should floor at 0.0")


func test_is_off_cooldown_true_after_cooldown_expires() -> void:
	var ability := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 3.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(ability, null)
	component.update_cooldowns(3.0)
	assert_true(component.is_off_cooldown(ability), "Ability should be off cooldown after expiry")


# --- get_ready_abilities() tests ---


func test_get_ready_abilities_returns_active_off_cooldown() -> void:
	var active_a := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var active_b := _make_ability("ice_shard", GameEnums.AbilityType.ACTIVE, 8.0)
	var passive := _make_ability("regen", GameEnums.AbilityType.PASSIVE, 0.0)
	var combat_state := _setup_chimera_with_abilities(
		[active_a, active_b, passive],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	var ready := component.get_ready_abilities()
	assert_eq(ready.size(), 2, "Should return 2 ACTIVE abilities off cooldown (passive excluded)")


func test_get_ready_abilities_excludes_on_cooldown() -> void:
	var active_a := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var active_b := _make_ability("ice_shard", GameEnums.AbilityType.ACTIVE, 8.0)
	var combat_state := _setup_chimera_with_abilities(
		[active_a, active_b],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(active_a, null)
	var ready := component.get_ready_abilities()
	assert_eq(ready.size(), 1, "Should return 1 ability (fire_blast on cooldown)")
	assert_eq(ready[0].id, "ice_shard", "Should return ice_shard")


func test_get_ready_abilities_excludes_passives() -> void:
	var passive := _make_ability("regen", GameEnums.AbilityType.PASSIVE, 0.0)
	var combat_state := _setup_chimera_with_abilities(
		[passive],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	var ready := component.get_ready_abilities()
	assert_eq(ready.size(), 0, "Should return 0 — passive abilities are never ready")


# --- execute_ability() sets current_ability_id ---


func test_execute_ability_sets_current_ability_id() -> void:
	var ability := _make_ability("fire_blast", GameEnums.AbilityType.ACTIVE, 5.0)
	var combat_state := _setup_chimera_with_abilities(
		[ability],
		[
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ROBOTIC,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.BEAST,
		]
	)
	var component := AbilityComponent.new()
	add_child_autofree(component)
	component.initialize(combat_state)
	component.execute_ability(ability, null)
	assert_eq(
		component.current_ability_id,
		"fire_blast",
		"current_ability_id should match executed ability"
	)


# --- _resolve_targets() tests (Phase 3) ---


func _make_entity_with_component(team: int = 0, pos: Vector2 = Vector2.ZERO) -> ChimeraEntity:
	var entity := ChimeraEntity.new()
	entity.combat_state = CombatState.new()
	entity.combat_state.team = team
	entity.combat_state.chimera_data = ChimeraData.new()
	entity.team = team
	entity.global_position = pos
	var ec := EffectComponent.new()
	ec.name = "EffectComponent"
	entity.add_child(ec)
	var ac := AbilityComponent.new()
	ac.name = "AbilityComponent"
	entity.add_child(ac)
	add_child_autofree(entity)
	return entity


func test_resolve_targets_self_returns_source() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	source.ability_component.initialize(source.combat_state)
	var targets := source.ability_component._resolve_targets("SELF", null, 0.0)
	assert_eq(targets.size(), 1, "SELF should return 1 target")
	assert_eq(targets[0], source, "SELF target should be the source entity")


func test_resolve_targets_target_returns_primary() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	var target := _make_entity_with_component(1, Vector2(100, 0))
	source.ability_component.initialize(source.combat_state)
	var targets := source.ability_component._resolve_targets("TARGET", target, 0.0)
	assert_eq(targets.size(), 1, "TARGET should return 1 target")
	assert_eq(targets[0], target, "TARGET should return the primary target")


func test_resolve_targets_aoe_enemies_within_range() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	var enemy_a := _make_entity_with_component(1, Vector2(50, 0))
	var enemy_b := _make_entity_with_component(1, Vector2(200, 0))
	var ally := _make_entity_with_component(0, Vector2(30, 0))
	var ctx := CombatContext.new()
	ctx.register_entity(source)
	ctx.register_entity(enemy_a)
	ctx.register_entity(enemy_b)
	ctx.register_entity(ally)
	source.combat_context = ctx
	source.ability_component.initialize(source.combat_state)
	# Range 100 from primary_target (source at 0,0): enemy_a at 50 is in, enemy_b at 200 is out
	var targets := source.ability_component._resolve_targets("AOE_ENEMIES", source, 100.0)
	assert_eq(targets.size(), 1, "Should return 1 enemy within range")
	assert_eq(targets[0], enemy_a, "Should return enemy_a (within range)")


func test_resolve_targets_aoe_allies_within_range() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	var ally := _make_entity_with_component(0, Vector2(30, 0))
	var enemy := _make_entity_with_component(1, Vector2(50, 0))
	var ctx := CombatContext.new()
	ctx.register_entity(source)
	ctx.register_entity(ally)
	ctx.register_entity(enemy)
	source.combat_context = ctx
	source.ability_component.initialize(source.combat_state)
	# Range 100 from primary_target (source at 0,0): source + ally within range
	var targets := source.ability_component._resolve_targets("AOE_ALLIES", source, 100.0)
	assert_eq(targets.size(), 2, "Should return source + ally within range")
	assert_true(targets.has(source), "Should include source")
	assert_true(targets.has(ally), "Should include ally")


func test_resolve_targets_all_enemies_no_range_limit() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	var enemy_a := _make_entity_with_component(1, Vector2(50, 0))
	var enemy_b := _make_entity_with_component(1, Vector2(500, 0))
	var ctx := CombatContext.new()
	ctx.register_entity(source)
	ctx.register_entity(enemy_a)
	ctx.register_entity(enemy_b)
	source.combat_context = ctx
	source.ability_component.initialize(source.combat_state)
	var targets := source.ability_component._resolve_targets("ALL_ENEMIES", null, 0.0)
	assert_eq(targets.size(), 2, "Should return all enemies regardless of range")


# --- execute_ability() integration tests (Phase 3) ---


func test_execute_ability_resolves_targets_and_executes_effects() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	source.combat_state.attack = 20.0
	var target := _make_entity_with_component(1, Vector2(100, 0))
	target.combat_state.max_hp = 100.0
	target.combat_state.current_hp = 100.0
	var ctx := CombatContext.new()
	ctx.register_entity(source)
	ctx.register_entity(target)
	source.combat_context = ctx
	source.ability_component.initialize(source.combat_state)
	var ability := _make_ability("fire_blast")
	ability.targeting = "TARGET"
	ability.range = 100.0
	var effect := AbilityEffect.new()
	effect.effect_type = AbilityEffect.EffectType.DAMAGE
	effect.params = {"amount": 2.0}
	ability.effects = [effect]
	source.ability_component.execute_ability(ability, target)
	# damage = 2.0 * 20.0 = 40.0
	assert_eq(target.combat_state.current_hp, 60.0, "execute_ability should deal damage to target")
	assert_eq(
		source.ability_component.current_ability_id, "fire_blast", "Should set current_ability_id"
	)
	assert_false(source.ability_component.is_off_cooldown(ability), "Ability should be on cooldown")


func test_execute_ability_executes_multiple_effects() -> void:
	var source := _make_entity_with_component(0, Vector2(0, 0))
	source.combat_state.attack = 20.0
	var target := _make_entity_with_component(1, Vector2(100, 0))
	target.combat_state.max_hp = 100.0
	target.combat_state.current_hp = 100.0
	var ctx := CombatContext.new()
	ctx.register_entity(source)
	ctx.register_entity(target)
	source.combat_context = ctx
	source.ability_component.initialize(source.combat_state)
	var ability := _make_ability("combo_strike")
	ability.targeting = "TARGET"
	ability.range = 100.0
	var damage_effect := AbilityEffect.new()
	damage_effect.effect_type = AbilityEffect.EffectType.DAMAGE
	damage_effect.params = {"amount": 2.0}
	var debuff_effect := AbilityEffect.new()
	debuff_effect.effect_type = AbilityEffect.EffectType.DEBUFF_STAT
	debuff_effect.params = {"stat": "attack", "amount": 5.0, "duration": 3.0}
	ability.effects = [damage_effect, debuff_effect]
	source.ability_component.execute_ability(ability, target)
	# damage = 2.0 * 20.0 = 40.0
	assert_eq(target.combat_state.current_hp, 60.0, "Should deal damage")
	assert_eq(target.effect_component.active_effects.size(), 1, "Should apply debuff")
	assert_eq(target.effect_component.active_effects[0].stat_name, "attack")
