## Widget that displays a part's sprite and slot label.
class_name PartSlot
extends Control

## The part data to display. Setting it updates the sprite and label.
@export var part_data: PartData:
	set(value):
		part_data = value
		if _is_ready:
			_update_display()

var _is_ready: bool = false
var _sprite_rect: TextureRect = null
var _slot_label: Label = null
var _sprite_path: String = ""


func _ready() -> void:
	_sprite_rect = TextureRect.new()
	_sprite_rect.name = "SpriteRect"
	add_child(_sprite_rect)

	_slot_label = Label.new()
	_slot_label.name = "SlotLabel"
	add_child(_slot_label)

	_is_ready = true
	_update_display()


## Returns the TextureRect displaying the part sprite.
func get_sprite_rect() -> TextureRect:
	return _sprite_rect


## Returns the Label displaying the slot name.
func get_slot_label() -> Label:
	return _slot_label


## Returns the current slot label text.
func get_slot_label_text() -> String:
	if _slot_label == null:
		return ""
	return _slot_label.text


## Returns the loaded sprite texture, or null if not loaded.
func get_sprite_texture() -> Texture2D:
	if _sprite_rect == null:
		return null
	return _sprite_rect.texture


## Returns the resource path of the loaded sprite.
func get_sprite_texture_path() -> String:
	return _sprite_path


func _update_display() -> void:
	if part_data == null:
		_slot_label.text = ""
		_sprite_rect.texture = null
		_sprite_path = ""
		return

	_slot_label.text = _get_slot_name(part_data.slot)
	_sprite_path = PartDatabase.get_sprite_path(part_data.shape_id, part_data.strain)
	if _sprite_path != "":
		_sprite_rect.texture = load(_sprite_path)
	else:
		_sprite_rect.texture = null


func _get_slot_name(slot: GameEnums.PartSlot) -> String:
	match slot:
		GameEnums.PartSlot.HEAD:
			return "HEAD"
		GameEnums.PartSlot.TORSO:
			return "TORSO"
		GameEnums.PartSlot.ARMS:
			return "ARMS"
		GameEnums.PartSlot.LEGS:
			return "LEGS"
		_:
			return ""
