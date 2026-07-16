## Tests for PartSlot widget — displays part sprite and slot label.
extends GutTest
# gdlint:ignore=max-public-methods

# --- Helpers ---


func _make_part(
	slot: GameEnums.PartSlot,
	shape_id: String = "body_a",
	strain: GameEnums.Strain = GameEnums.Strain.BEAST
) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.shape_id = shape_id
	part.strain = strain
	return part


# --- Node creation tests ---


func test_part_slot_creates_sprite_rect() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	assert_not_null(widget.get_sprite_rect(), "SpriteRect should exist after _ready")


func test_part_slot_creates_slot_label() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	assert_not_null(widget.get_slot_label(), "SlotLabel should exist after _ready")


# --- Slot label tests ---


func test_slot_label_shows_head() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(GameEnums.PartSlot.HEAD)
	assert_eq(widget.get_slot_label_text(), "HEAD", "Should show HEAD")


func test_slot_label_shows_torso() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(GameEnums.PartSlot.TORSO)
	assert_eq(widget.get_slot_label_text(), "TORSO", "Should show TORSO")


func test_slot_label_shows_arms() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(GameEnums.PartSlot.ARMS)
	assert_eq(widget.get_slot_label_text(), "ARMS", "Should show ARMS")


func test_slot_label_shows_legs() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(GameEnums.PartSlot.LEGS)
	assert_eq(widget.get_slot_label_text(), "LEGS", "Should show LEGS")


# --- Sprite texture tests ---


func test_sprite_loaded_when_part_data_set() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(GameEnums.PartSlot.TORSO, "body_a", GameEnums.Strain.BEAST)
	assert_not_null(widget.get_sprite_texture(), "Texture should be loaded")


func test_sprite_path_matches_part_database() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	var part := _make_part(GameEnums.PartSlot.TORSO, "body_a", GameEnums.Strain.BEAST)
	widget.part_data = part
	var expected_path := PartDatabase.get_sprite_path(part.shape_id, part.strain)
	assert_eq(
		widget.get_sprite_texture_path(),
		expected_path,
		"Sprite path should match PartDatabase.get_sprite_path"
	)


func test_sprite_updates_with_different_strain() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	var part_draconic := _make_part(GameEnums.PartSlot.TORSO, "body_a", GameEnums.Strain.DRACONIC)
	widget.part_data = part_draconic
	var expected := PartDatabase.get_sprite_path("body_a", GameEnums.Strain.DRACONIC)
	assert_eq(widget.get_sprite_texture_path(), expected, "Sprite path should use draconic color")


func test_sprite_loaded_for_detail_head() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = _make_part(
		GameEnums.PartSlot.HEAD, "detail_horn_large", GameEnums.Strain.UNDEAD
	)
	assert_not_null(widget.get_sprite_texture(), "Detail sprite should load for HEAD")


# --- Edge cases ---


func test_no_crash_when_part_data_null() -> void:
	var widget: PartSlot = add_child_autofree(PartSlot.new())
	widget.part_data = null
	assert_eq(widget.get_slot_label_text(), "", "Label should be empty when part_data is null")
