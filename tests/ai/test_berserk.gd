# gdlint:ignore=max-public-methods
extends GutTest


func test_check_berserk_purebreds_never_berserk() -> void:
	var controller: AIController = _create_controller(0)
	controller.check_berserk(5.0)
	assert_eq(controller.combat_state.berserk_check_timer, 0.0)
	assert_false(controller.combat_state.is_berserk)


func test_check_berserk_timer_accumulates() -> void:
	var controller: AIController = _create_controller(1)
	controller.check_berserk(2.0)
	assert_eq(controller.combat_state.berserk_check_timer, 2.0)


func test_check_berserk_no_roll_before_interval() -> void:
	var controller: AIController = _create_controller(1)
	controller.combat_state.berserk_modifiers["hp_low"] = 0.15
	controller.check_berserk(3.0)
	assert_true(controller.combat_state.berserk_modifiers.has("hp_low"))


func test_check_berserk_roll_at_interval_resets_timer() -> void:
	var controller: AIController = _create_controller(1)
	controller.check_berserk(5.0)
	assert_eq(controller.combat_state.berserk_check_timer, 0.0)


func test_check_berserk_roll_at_interval_clears_modifiers() -> void:
	var controller: AIController = _create_controller(1)
	controller.combat_state.berserk_modifiers["hp_low"] = 0.15
	controller.combat_state.berserk_modifiers["disrupted"] = 0.10
	controller.check_berserk(5.0)
	assert_true(controller.combat_state.berserk_modifiers.is_empty())


func test_get_berserk_chance_pure() -> void:
	var controller: AIController = _create_controller(0)
	assert_eq(controller.get_berserk_chance(), 0.0)


func test_get_berserk_chance_stable() -> void:
	var controller: AIController = _create_controller(1)
	assert_eq(controller.get_berserk_chance(), 0.03)


func test_get_berserk_chance_volatile() -> void:
	var controller: AIController = _create_controller(2)
	assert_eq(controller.get_berserk_chance(), 0.08)


func test_get_berserk_chance_chaotic() -> void:
	var controller: AIController = _create_controller(3)
	assert_eq(controller.get_berserk_chance(), 0.15)


func test_get_berserk_chance_with_modifiers() -> void:
	var controller: AIController = _create_controller(3)
	controller.combat_state.berserk_modifiers["hp_low"] = 0.15
	controller.combat_state.berserk_modifiers["disrupted"] = 0.10
	controller.combat_state.berserk_modifiers["killing_blow"] = 0.05
	assert_almost_eq(controller.get_berserk_chance(), 0.45, 0.0001)


func test_on_hp_low_adds_modifier() -> void:
	var controller: AIController = _create_controller(1)
	controller.on_hp_low()
	assert_eq(controller.combat_state.berserk_modifiers["hp_low"], 0.15)


func test_on_disrupted_adds_modifier() -> void:
	var controller: AIController = _create_controller(1)
	controller.on_disrupted()
	assert_eq(controller.combat_state.berserk_modifiers["disrupted"], 0.10)


func test_on_killing_blow_adds_modifier() -> void:
	var controller: AIController = _create_controller(1)
	controller.on_killing_blow()
	assert_eq(controller.combat_state.berserk_modifiers["killing_blow"], 0.05)


func test_on_ally_death_clears_modifiers() -> void:
	var controller: AIController = _create_controller(1)
	controller.combat_state.berserk_modifiers["hp_low"] = 0.15
	controller.on_ally_death()
	assert_true(controller.combat_state.berserk_modifiers.is_empty())


func test_on_ally_death_purebreds_immune() -> void:
	var controller: AIController = _create_controller(0)
	controller.combat_state.berserk_modifiers["hp_low"] = 0.15
	controller.on_ally_death()
	assert_true(controller.combat_state.berserk_modifiers.has("hp_low"))
	assert_false(controller.combat_state.is_berserk)


func test_enter_berserk_sets_is_berserk() -> void:
	var controller: AIController = _create_controller_with_berserk_state(1)
	controller.enter_berserk()
	assert_true(controller.combat_state.is_berserk)


func test_enter_berserk_sets_berserk_timer() -> void:
	var controller: AIController = _create_controller_with_berserk_state(1)
	controller.enter_berserk()
	assert_eq(controller.combat_state.berserk_timer, 5.0)


func test_enter_berserk_changes_state_to_berserk() -> void:
	var controller: AIController = _create_controller_with_berserk_state(1)
	controller.enter_berserk()
	assert_eq(controller.current_state, controller.states["BERSERK"])


func test_enter_berserk_emits_berserk_triggered_signal() -> void:
	var controller: AIController = _create_controller_with_berserk_state(1)
	watch_signals(EventBus)
	controller.enter_berserk()
	assert_signal_emitted(EventBus, "berserk_triggered")


func test_berserk_duration_constant_is_5_seconds() -> void:
	assert_eq(AIController.BERSERK_DURATION, 5.0)


# --- Helpers ---


func _create_controller(instability: int = 1) -> AIController:
	var chimera_data: ChimeraData = ChimeraData.new()
	chimera_data.instability = instability
	var combat_state: CombatState = CombatState.new()
	combat_state.chimera_data = chimera_data
	combat_state.team = 0
	var controller: AIController = AIController.new()
	controller.combat_state = combat_state
	autofree(controller)
	return controller


func _create_controller_with_berserk_state(instability: int = 1) -> AIController:
	var controller: AIController = _create_controller(instability)
	var berserk_state: BerserkState = BerserkState.new()
	controller.register_state("BERSERK", berserk_state)
	return controller
