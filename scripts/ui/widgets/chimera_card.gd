## Widget that displays a chimera's nickname, stats, and instability.
class_name ChimeraCard
extends Control

## The chimera data to display. Setting it updates all labels.
@export var chimera: ChimeraData:
	set(value):
		chimera = value
		if _is_ready:
			_update_display()

var _is_ready: bool = false
var _nickname_label: Label = null
var _hp_label: Label = null
var _attack_label: Label = null
var _defense_label: Label = null
var _speed_label: Label = null
var _instability_label: Label = null


## Returns the human-readable label for an instability level.
##
## 0=Pure, 1=Stable Hybrid, 2=Volatile Hybrid, 3=Chaotic.
static func get_instability_label(instability: int) -> String:
	match instability:
		0:
			return "Pure"
		1:
			return "Stable Hybrid"
		2:
			return "Volatile Hybrid"
		3:
			return "Chaotic"
		_:
			return ""


func _ready() -> void:
	_nickname_label = Label.new()
	_nickname_label.name = "NicknameLabel"
	add_child(_nickname_label)

	_hp_label = Label.new()
	_hp_label.name = "HPLabel"
	add_child(_hp_label)

	_attack_label = Label.new()
	_attack_label.name = "AttackLabel"
	add_child(_attack_label)

	_defense_label = Label.new()
	_defense_label.name = "DefenseLabel"
	add_child(_defense_label)

	_speed_label = Label.new()
	_speed_label.name = "SpeedLabel"
	add_child(_speed_label)

	_instability_label = Label.new()
	_instability_label.name = "InstabilityLabel"
	add_child(_instability_label)

	_is_ready = true
	_update_display()


## Returns the Label displaying the chimera nickname.
func get_nickname_label() -> Label:
	return _nickname_label


## Returns the Label displaying the HP value.
func get_hp_label() -> Label:
	return _hp_label


## Returns the Label displaying the Attack value.
func get_attack_label() -> Label:
	return _attack_label


## Returns the Label displaying the Defense value.
func get_defense_label() -> Label:
	return _defense_label


## Returns the Label displaying the Speed value.
func get_speed_label() -> Label:
	return _speed_label


## Returns the Label displaying the instability label.
func get_instability_label_node() -> Label:
	return _instability_label


## Returns the nickname text displayed on the card.
func get_nickname_text() -> String:
	if _nickname_label == null:
		return ""
	return _nickname_label.text


## Returns the HP text displayed on the card.
func get_hp_text() -> String:
	if _hp_label == null:
		return ""
	return _hp_label.text


## Returns the Attack text displayed on the card.
func get_attack_text() -> String:
	if _attack_label == null:
		return ""
	return _attack_label.text


## Returns the Defense text displayed on the card.
func get_defense_text() -> String:
	if _defense_label == null:
		return ""
	return _defense_label.text


## Returns the Speed text displayed on the card.
func get_speed_text() -> String:
	if _speed_label == null:
		return ""
	return _speed_label.text


## Returns the instability text displayed on the card.
func get_instability_text() -> String:
	if _instability_label == null:
		return ""
	return _instability_label.text


func _update_display() -> void:
	if chimera == null:
		_nickname_label.text = ""
		_hp_label.text = ""
		_attack_label.text = ""
		_defense_label.text = ""
		_speed_label.text = ""
		_instability_label.text = ""
		return

	_nickname_label.text = chimera.nickname
	_hp_label.text = str(int(chimera.max_hp))
	_attack_label.text = str(int(chimera.attack))
	_defense_label.text = str(int(chimera.defense))
	_speed_label.text = str(int(chimera.speed))
	_instability_label.text = get_instability_label(chimera.instability)
