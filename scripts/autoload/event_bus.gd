## Global signal bus for cross-system communication.
##
## All global signals that need to be emitted or listened to
## across different game systems should be defined here.
extends Node


func _ready() -> void:
	print("EventBus ready")
