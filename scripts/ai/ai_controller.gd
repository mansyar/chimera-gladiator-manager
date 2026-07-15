class_name AIController
extends Node

## Finite state machine controller for chimera combat AI.
## Manages state transitions, target acquisition, and berserk checks.
## (FR-2: AIController node, TDD Section 7)

var current_state: AIState
var behavior_module: BehaviorModuleData
var combat_state: CombatState
var target: ChimeraEntity
var states: Dictionary = {}
var combat_context: CombatContext

@onready var entity: ChimeraEntity = get_parent() as ChimeraEntity


func _ready() -> void:
	# State scripts are registered in Task 7.
	# Set initial state to IDLE if available.
	if states.has("IDLE"):
		current_state = states["IDLE"]
		current_state.enter()


## Configures the AI with behavior module, combat state, and combat context.
## Called by the arena/match setup before combat begins.
func setup_ai(
	p_behavior_module: BehaviorModuleData,
	p_combat_state: CombatState,
	p_combat_context: CombatContext
) -> void:
	behavior_module = p_behavior_module
	combat_state = p_combat_state
	combat_context = p_combat_context


## Registers a state instance under the given name.
## Sets the ai_controller reference on the state.
func register_state(state_name: String, state: AIState) -> void:
	state.ai_controller = self
	states[state_name] = state


## Transitions to a new state by name.
## Calls exit() on the current state, swaps, and calls enter() on the new state.
func change_state(new_state: String) -> void:
	if current_state != null:
		current_state.exit()
	current_state = states.get(new_state)
	if current_state != null:
		current_state.enter()


## Acquires a target based on the behavior module's targeting mode.
## Full implementation in Phase 2 (FR-6).
func acquire_target() -> ChimeraEntity:
	return null


## Returns the move position for the given target based on positioning mode.
## Full implementation in Phase 2 (FR-5).
func get_move_position(_target: ChimeraEntity) -> Vector2:
	return Vector2.ZERO


## Returns the next ready ability based on priority ordering.
## Full implementation in Phase 3 (FR-7).
func get_next_ready_ability() -> AbilityData:
	return null


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)
	check_berserk(delta)


## Checks for berserk trigger. Full implementation in Phase 3 (FR-8).
func check_berserk(_delta: float) -> void:
	pass
