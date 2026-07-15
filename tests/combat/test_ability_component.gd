extends GutTest

## Tests for AbilityComponent interface stub (FR-2: AbilityComponent interface stub).
## Verifies method signatures exist and return defaults without error.


func test_initialize_does_not_error() -> void:
	var component: AbilityComponent = AbilityComponent.new()
	add_child_autofree(component)
	var empty_abilities: Array[AbilityData] = []
	component.initialize(empty_abilities)
	assert_true(is_instance_valid(component), "initialize should not crash the component")


func test_is_off_cooldown_returns_false() -> void:
	var component: AbilityComponent = AbilityComponent.new()
	add_child_autofree(component)
	var result: bool = component.is_off_cooldown("test_ability")
	assert_eq(result, false, "is_off_cooldown should return false by default")


func test_get_ready_abilities_returns_empty() -> void:
	var component: AbilityComponent = AbilityComponent.new()
	add_child_autofree(component)
	var ready: Array[AbilityData] = component.get_ready_abilities()
	assert_eq(ready.size(), 0, "get_ready_abilities should return empty array by default")
