## Persistent top bar displaying Gold and Infamy.
##
## Reads initial values from GameState on _ready and updates
## live when EventBus.gold_changed or EventBus.infamy_changed fire.
class_name TopBar
extends Control

var _gold_label: Label
var _infamy_label: Label


func _ready() -> void:
	var container := HBoxContainer.new()
	container.name = "StatsContainer"
	add_child(container)

	_gold_label = Label.new()
	_gold_label.name = "GoldLabel"
	container.add_child(_gold_label)

	_infamy_label = Label.new()
	_infamy_label.name = "InfamyLabel"
	container.add_child(_infamy_label)

	_update_gold(GameState.gold)
	_update_infamy(GameState.infamy)

	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.infamy_changed.connect(_on_infamy_changed)


## Called when EventBus.gold_changed fires with the new total.
func _on_gold_changed(amount: int) -> void:
	_update_gold(amount)


## Called when EventBus.infamy_changed fires with the new total.
func _on_infamy_changed(amount: int) -> void:
	_update_infamy(amount)


func _update_gold(amount: int) -> void:
	_gold_label.text = "Gold: %d" % amount


func _update_infamy(amount: int) -> void:
	_infamy_label.text = "Infamy: %d" % amount


## Returns the Gold label node.
func get_gold_label() -> Label:
	return _gold_label


## Returns the Infamy label node.
func get_infamy_label() -> Label:
	return _infamy_label


## Returns the current Gold label text.
func get_gold_text() -> String:
	return _gold_label.text


## Returns the current Infamy label text.
func get_infamy_text() -> String:
	return _infamy_label.text
