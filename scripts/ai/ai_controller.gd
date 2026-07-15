class_name AIController
extends Node

## Finite state machine controller for chimera combat AI.
## This is an interface stub — full FSM implementation in TRACK-006.
## (FR-2: AIController interface stub, TDD Section 7)
##
## Method signatures match TDD Section 7:
## - change_state(new_state: String) -> void
## - acquire_target() -> ChimeraEntity
## - _process(delta: float) -> void


func change_state(_new_state: String) -> void:
	pass


func acquire_target() -> ChimeraEntity:
	return null


func _process(_delta: float) -> void:
	pass
