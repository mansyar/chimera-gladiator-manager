# gdlint:ignore=max-public-methods
extends GutTest

## Tests for EffectComponent — tracks, ticks, and cleans up ActiveEffects.

var _effect_component: EffectComponent


func before_each() -> void:
	_effect_component = EffectComponent.new()


func after_each() -> void:
	_effect_component.free()


func _make_effect(
	effect_type: AbilityEffect.EffectType, stat_name: String, amount: float, duration: float
) -> ActiveEffect:
	var effect := ActiveEffect.new()
	effect.effect_type = effect_type
	effect.stat_name = stat_name
	effect.amount = amount
	effect.duration = duration
	return effect


func test_add_effect_appends_to_active_effects() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	_effect_component.add_effect(effect)
	assert_eq(_effect_component.active_effects.size(), 1)


func test_add_effect_updates_stat_modifiers_buff() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	_effect_component.add_effect(effect)
	assert_eq(_effect_component.stat_modifiers["attack"], 10.0)


func test_add_effect_updates_stat_modifiers_debuff() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "defense", -5.0, 5.0)
	_effect_component.add_effect(effect)
	assert_eq(_effect_component.stat_modifiers["defense"], -5.0)


func test_tick_removes_expired_effects() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 1.0)
	_effect_component.add_effect(effect)
	_effect_component.tick(2.0)
	assert_eq(_effect_component.active_effects.size(), 0)


func test_tick_recalculates_after_removing_expired() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 1.0)
	_effect_component.add_effect(effect)
	_effect_component.tick(2.0)
	assert_false(_effect_component.stat_modifiers.has("attack"))


func test_tick_does_not_recalculate_when_no_expired() -> void:
	var effect := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 10.0)
	_effect_component.add_effect(effect)
	_effect_component.stat_modifiers["attack"] = 999.0
	_effect_component.tick(1.0)
	assert_eq(_effect_component.stat_modifiers["attack"], 999.0)


func test_recalculate_sums_multiple_buffs_and_debuffs_for_same_stat() -> void:
	var buff := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	var debuff := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "attack", -3.0, 5.0)
	_effect_component.add_effect(buff)
	_effect_component.add_effect(debuff)
	assert_eq(_effect_component.stat_modifiers["attack"], 7.0)


func test_get_modified_stat_returns_base_plus_modifier() -> void:
	_effect_component.stat_modifiers["attack"] = 10.0
	var result := _effect_component.get_modified_stat("attack", 20.0)
	assert_eq(result, 30.0)


func test_get_modified_stat_returns_base_when_no_modifier() -> void:
	var result := _effect_component.get_modified_stat("speed", 15.0)
	assert_eq(result, 15.0)


func test_cleanse_removes_only_debuff_effects() -> void:
	var buff := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	var debuff := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "defense", -5.0, 5.0)
	_effect_component.add_effect(buff)
	_effect_component.add_effect(debuff)
	_effect_component.cleanse()
	assert_eq(_effect_component.active_effects.size(), 1)
	assert_eq(_effect_component.active_effects[0].effect_type, AbilityEffect.EffectType.BUFF_STAT)


func test_cleanse_keeps_buff_effects() -> void:
	var buff1 := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	var buff2 := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "speed", 5.0, 5.0)
	var debuff := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "defense", -5.0, 5.0)
	_effect_component.add_effect(buff1)
	_effect_component.add_effect(buff2)
	_effect_component.add_effect(debuff)
	_effect_component.cleanse()
	assert_eq(_effect_component.active_effects.size(), 2)
	for effect in _effect_component.active_effects:
		assert_ne(effect.effect_type, AbilityEffect.EffectType.DEBUFF_STAT)


func test_cleanse_recalculates_modifiers_after_removal() -> void:
	var buff := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	var debuff := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "defense", -5.0, 5.0)
	_effect_component.add_effect(buff)
	_effect_component.add_effect(debuff)
	_effect_component.cleanse()
	assert_false(_effect_component.stat_modifiers.has("defense"))
	assert_eq(_effect_component.stat_modifiers["attack"], 10.0)


func test_tick_with_mixed_expired_and_non_expired() -> void:
	var expired := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 1.0)
	var alive := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "defense", 5.0, 10.0)
	_effect_component.add_effect(expired)
	_effect_component.add_effect(alive)
	_effect_component.tick(2.0)
	assert_eq(_effect_component.active_effects.size(), 1, "Only non-expired effect should remain")
	assert_eq(
		_effect_component.active_effects[0].stat_name,
		"defense",
		"Remaining effect should be the defense buff"
	)
	assert_eq(_effect_component.stat_modifiers["defense"], 5.0, "defense modifier should remain")
	assert_false(
		_effect_component.stat_modifiers.has("attack"), "attack modifier should be removed"
	)


func test_tick_with_no_effects() -> void:
	_effect_component.tick(1.0)
	assert_eq(_effect_component.active_effects.size(), 0, "Should have no effects after tick")


func test_cleanse_with_no_effects() -> void:
	_effect_component.cleanse()
	assert_eq(_effect_component.active_effects.size(), 0, "Should have no effects after cleanse")
	assert_eq(_effect_component.stat_modifiers.size(), 0, "stat_modifiers should be empty")


func test_cleanse_does_not_remove_shield_effects() -> void:
	var shield := _make_effect(AbilityEffect.EffectType.SHIELD, "", 30.0, 5.0)
	var debuff := _make_effect(AbilityEffect.EffectType.DEBUFF_STAT, "defense", -5.0, 5.0)
	_effect_component.add_effect(shield)
	_effect_component.add_effect(debuff)
	_effect_component.cleanse()
	assert_eq(_effect_component.active_effects.size(), 1, "Only SHIELD should remain")
	assert_eq(
		_effect_component.active_effects[0].effect_type,
		AbilityEffect.EffectType.SHIELD,
		"Remaining effect should be SHIELD"
	)


# --- absorb_damage tests ---


func test_absorb_damage_no_shields_returns_full_amount() -> void:
	var remaining: float = _effect_component.absorb_damage(50.0)
	assert_eq(remaining, 50.0, "No shields should return full damage")


func test_absorb_damage_reduces_shield_amounts() -> void:
	var shield := _make_effect(AbilityEffect.EffectType.SHIELD, "", 30.0, 5.0)
	_effect_component.add_effect(shield)
	var remaining: float = _effect_component.absorb_damage(20.0)
	assert_eq(remaining, 0.0, "Shield should absorb all damage")
	assert_eq(
		_effect_component.active_effects[0].amount,
		10.0,
		"Shield amount should be reduced by absorbed damage"
	)


func test_absorb_damage_removes_depleted_shields() -> void:
	var shield := _make_effect(AbilityEffect.EffectType.SHIELD, "", 20.0, 5.0)
	_effect_component.add_effect(shield)
	var remaining: float = _effect_component.absorb_damage(30.0)
	assert_eq(remaining, 10.0, "Excess damage beyond shield should be returned")
	assert_eq(_effect_component.active_effects.size(), 0, "Depleted shield should be removed")


func test_absorb_damage_multiple_shields() -> void:
	var shield1 := _make_effect(AbilityEffect.EffectType.SHIELD, "", 15.0, 5.0)
	var shield2 := _make_effect(AbilityEffect.EffectType.SHIELD, "", 25.0, 5.0)
	_effect_component.add_effect(shield1)
	_effect_component.add_effect(shield2)
	var remaining: float = _effect_component.absorb_damage(30.0)
	assert_eq(remaining, 0.0, "Two shields should absorb 40 total damage")
	assert_eq(_effect_component.active_effects.size(), 1, "First shield depleted, second remains")
	assert_eq(_effect_component.active_effects[0].amount, 10.0, "Second shield reduced by 15")


func test_absorb_damage_preserves_non_shield_effects() -> void:
	var shield := _make_effect(AbilityEffect.EffectType.SHIELD, "", 20.0, 5.0)
	var buff := _make_effect(AbilityEffect.EffectType.BUFF_STAT, "attack", 10.0, 5.0)
	_effect_component.add_effect(shield)
	_effect_component.add_effect(buff)
	_effect_component.absorb_damage(25.0)
	assert_eq(_effect_component.active_effects.size(), 1, "Only buff should remain")
	assert_eq(
		_effect_component.active_effects[0].effect_type,
		AbilityEffect.EffectType.BUFF_STAT,
		"Remaining effect should be the buff"
	)
