# gdlint:ignore=max-public-methods
extends GutTest


# Mock AbilityComponent that returns configurable cooldown results.
class MockAbilityComponent:
	extends AbilityComponent
	var off_cooldown_abilities: Array[AbilityData] = []

	func is_off_cooldown(ability: AbilityData) -> bool:
		return ability in off_cooldown_abilities


func test_get_next_ready_ability_returns_null_without_setup() -> void:
	var controller: AIController = AIController.new()
	autofree(controller)
	assert_eq(controller.get_next_ready_ability(), null)


func test_get_next_ready_ability_returns_null_when_no_abilities() -> void:
	var controller: AIController = _create_controller([], null, [], [])
	assert_eq(controller.get_next_ready_ability(), null)


func test_get_next_ready_ability_returns_null_when_none_off_cooldown() -> void:
	var ability: AbilityData = _create_ability("a1", GameEnums.AbilityCategory.OFFENSE)
	var controller: AIController = _create_controller(
		[ability], null, [GameEnums.AbilityCategory.OFFENSE], []
	)
	assert_eq(controller.get_next_ready_ability(), null)


func test_get_next_ready_ability_returns_first_off_cooldown() -> void:
	var ability: AbilityData = _create_ability("a1", GameEnums.AbilityCategory.OFFENSE)
	var controller: AIController = _create_controller(
		[ability], null, [GameEnums.AbilityCategory.OFFENSE], [ability]
	)
	var result: AbilityData = controller.get_next_ready_ability()
	assert_eq(result, ability)


func test_get_next_ready_ability_respects_priority_ordering() -> void:
	var offense_ability: AbilityData = _create_ability("offense", GameEnums.AbilityCategory.OFFENSE)
	var mobility_ability: AbilityData = _create_ability(
		"mobility", GameEnums.AbilityCategory.MOBILITY
	)
	var priority: Array = [GameEnums.AbilityCategory.MOBILITY, GameEnums.AbilityCategory.OFFENSE]
	var controller: AIController = _create_controller(
		[offense_ability, mobility_ability], null, priority, [offense_ability, mobility_ability]
	)
	var result: AbilityData = controller.get_next_ready_ability()
	assert_eq(result, mobility_ability)


func test_get_next_ready_ability_checks_combo_ability() -> void:
	var part_ability: AbilityData = _create_ability("part", GameEnums.AbilityCategory.OFFENSE)
	var combo: AbilityData = _create_ability("combo", GameEnums.AbilityCategory.UTILITY)
	var controller: AIController = _create_controller(
		[part_ability], combo, [GameEnums.AbilityCategory.UTILITY], [combo]
	)
	var result: AbilityData = controller.get_next_ready_ability()
	assert_eq(result, combo)


func test_get_next_ready_ability_returns_null_when_priority_empty() -> void:
	var ability: AbilityData = _create_ability("a1", GameEnums.AbilityCategory.OFFENSE)
	var controller: AIController = _create_controller([ability], null, [], [ability])
	assert_eq(controller.get_next_ready_ability(), null)


func test_get_next_ready_ability_skips_wrong_category() -> void:
	var offense_ability: AbilityData = _create_ability("offense", GameEnums.AbilityCategory.OFFENSE)
	var defense_ability: AbilityData = _create_ability("defense", GameEnums.AbilityCategory.DEFENSE)
	var controller: AIController = _create_controller(
		[offense_ability, defense_ability],
		null,
		[GameEnums.AbilityCategory.DEFENSE],
		[offense_ability]
	)
	assert_eq(controller.get_next_ready_ability(), null)


func test_get_next_ready_ability_returns_null_without_ability_component() -> void:
	var ability: AbilityData = _create_ability("a1", GameEnums.AbilityCategory.OFFENSE)
	var chimera_data: ChimeraData = ChimeraData.new()
	chimera_data.part_abilities = [ability]
	var combat_state: CombatState = CombatState.new()
	combat_state.chimera_data = chimera_data
	var behavior_module: BehaviorModuleData = BehaviorModuleData.new()
	var typed_priority: Array[GameEnums.AbilityCategory] = [GameEnums.AbilityCategory.OFFENSE]
	behavior_module.ability_priority = typed_priority
	var entity: ChimeraEntity = ChimeraEntity.new()
	add_child_autofree(entity)
	var controller: AIController = AIController.new()
	controller.behavior_module = behavior_module
	controller.combat_state = combat_state
	entity.add_child(controller)
	autofree(controller)
	assert_eq(controller.get_next_ready_ability(), null)


# --- Helpers ---


func _create_ability(id: String, category: int) -> AbilityData:
	var ability: AbilityData = AbilityData.new()
	ability.id = id
	ability.category = category
	return ability


func _create_controller(
	abilities: Array[AbilityData],
	combo: AbilityData,
	priority: Array,
	off_cooldown: Array[AbilityData]
) -> AIController:
	var chimera_data: ChimeraData = ChimeraData.new()
	chimera_data.part_abilities = abilities
	if combo != null:
		chimera_data.combo_ability = combo

	var combat_state: CombatState = CombatState.new()
	combat_state.chimera_data = chimera_data

	var behavior_module: BehaviorModuleData = BehaviorModuleData.new()
	var typed_priority: Array[GameEnums.AbilityCategory] = []
	for cat in priority:
		typed_priority.append(cat)
	behavior_module.ability_priority = typed_priority

	var entity: ChimeraEntity = ChimeraEntity.new()

	var mock_component: MockAbilityComponent = MockAbilityComponent.new()
	var typed_off_cooldown: Array[AbilityData] = []
	for ab in off_cooldown:
		typed_off_cooldown.append(ab)
	mock_component.off_cooldown_abilities = typed_off_cooldown
	mock_component.name = "AbilityComponent"
	entity.add_child(mock_component)

	var controller: AIController = AIController.new()
	controller.behavior_module = behavior_module
	controller.combat_state = combat_state
	entity.add_child(controller)
	autofree(controller)

	add_child_autofree(entity)

	return controller
