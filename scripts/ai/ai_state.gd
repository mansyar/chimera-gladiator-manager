class_name AIState
extends RefCounted

## Base class for AI finite state machine states.
##
## Each state implements enter(), update(delta), and exit() to define
## its behavior. The ai_controller reference provides access to the
## parent AIController and its entity, combat_state, and target.
## (FR-3: AIState Base Class, TDD Section 7)

## Reference to the parent AIController that owns this state.
var ai_controller: AIController


## Called when this state becomes the active state.
func enter() -> void:
	pass


## Called every frame while this state is active.
func update(_delta: float) -> void:
	pass


## Called when this state is being exited (before the new state enters).
func exit() -> void:
	pass
