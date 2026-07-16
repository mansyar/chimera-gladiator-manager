## Widget that displays a stat name and value as "StatName: Value".
class_name StatDisplay
extends Control

## The stat name shown before the colon.
@export var stat_name: String:
	set(value):
		stat_name = value
		if _is_ready:
			_update_display()

## The stat value shown after the colon.
@export var stat_value: float:
	set(value):
		stat_value = value
		if _is_ready:
			_update_display()

var _is_ready: bool = false
var _display_label: Label = null


func _ready() -> void:
	_display_label = Label.new()
	_display_label.name = "DisplayLabel"
	add_child(_display_label)

	_is_ready = true
	_update_display()


## Returns the Label node displaying the stat text.
func get_display_label() -> Label:
	return _display_label


## Returns the formatted display text.
func get_display_text() -> String:
	if _display_label == null:
		return ""
	return _display_label.text


func _update_display() -> void:
	_display_label.text = "%s: %s" % [stat_name, _format_value(stat_value)]


## Formats a float without trailing .0 for whole numbers.
func _format_value(value: float) -> String:
	if value == int(value):
		return str(int(value))
	return str(value)
