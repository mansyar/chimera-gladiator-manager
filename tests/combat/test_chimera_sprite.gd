## Tests for ChimeraSprite composition (FR-6..FR-9).
## Verifies strain-to-color mapping, sprite path construction, layer composition, and z-order.
extends GutTest
# gdlint:ignore=max-public-methods

const SPRITE_PATH_PREFIX := "res://assets/kenney-monster-builder-pack/PNG/Default/"

# --- Helpers ---


func _make_part(
	slot: GameEnums.PartSlot,
	strain: GameEnums.Strain,
	shape_id: String = "",
	hp: float = 10.0,
	atk: float = 5.0,
	def_val: float = 3.0,
	spd: float = 7.0
) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	part.shape_id = shape_id
	part.hp_bonus = hp
	part.attack_bonus = atk
	part.defense_bonus = def_val
	part.speed_bonus = spd
	part.attack_range = 32.0
	return part


func _make_chimera_with_shapes(
	head_shape: String,
	torso_shape: String,
	arms_shape: String,
	legs_shape: String,
	strain: GameEnums.Strain = GameEnums.Strain.UNDEAD
) -> ChimeraData:
	var chimera := ChimeraData.new()
	chimera.nickname = "TestSprite"
	chimera.head = _make_part(GameEnums.PartSlot.HEAD, strain, head_shape)
	chimera.torso = _make_part(GameEnums.PartSlot.TORSO, strain, torso_shape)
	chimera.arms = _make_part(GameEnums.PartSlot.ARMS, strain, arms_shape)
	chimera.legs = _make_part(GameEnums.PartSlot.LEGS, strain, legs_shape)
	chimera.calculate_instability()
	chimera.recalculate_stats()
	return chimera


# --- STRAIN_TO_COLOR tests ---


func test_strain_to_color_maps_all_strains() -> void:
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.UNDEAD],
		"dark",
		"UNDEAD should map to 'dark'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.ROBOTIC],
		"white",
		"ROBOTIC should map to 'white'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.DRACONIC],
		"red",
		"DRACONIC should map to 'red'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.BEAST],
		"green",
		"BEAST should map to 'green'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.ELEMENTAL],
		"blue",
		"ELEMENTAL should map to 'blue'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.ABERRANT],
		"yellow",
		"ABERRANT should map to 'yellow'"
	)
	assert_eq(
		ChimeraSprite.STRAIN_TO_COLOR[GameEnums.Strain.NEUTRAL],
		"dark",
		"NEUTRAL should map to 'dark' (no grey assets exist)"
	)


# --- get_sprite_path tests ---


func test_get_sprite_path_body_parts() -> void:
	var path: String = ChimeraSprite.get_sprite_path("body_a", GameEnums.Strain.UNDEAD)
	assert_eq(
		path,
		SPRITE_PATH_PREFIX + "body_darkA.png",
		"Body part path should follow {category}_{color}{Variant}.png format"
	)


func test_get_sprite_path_for_each_strain() -> void:
	var shape_id: String = "arm_a"
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.UNDEAD),
		SPRITE_PATH_PREFIX + "arm_darkA.png",
		"UNDEAD path should use 'dark'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ROBOTIC),
		SPRITE_PATH_PREFIX + "arm_whiteA.png",
		"ROBOTIC path should use 'white'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.DRACONIC),
		SPRITE_PATH_PREFIX + "arm_redA.png",
		"DRACONIC path should use 'red'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.BEAST),
		SPRITE_PATH_PREFIX + "arm_greenA.png",
		"BEAST path should use 'green'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ELEMENTAL),
		SPRITE_PATH_PREFIX + "arm_blueA.png",
		"ELEMENTAL path should use 'blue'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ABERRANT),
		SPRITE_PATH_PREFIX + "arm_yellowA.png",
		"ABERRANT path should use 'yellow'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.NEUTRAL),
		SPRITE_PATH_PREFIX + "arm_darkA.png",
		"NEUTRAL path should use 'dark' (no grey assets exist)"
	)


func test_get_sprite_path_detail_parts() -> void:
	assert_eq(
		ChimeraSprite.get_sprite_path("detail_ear", GameEnums.Strain.UNDEAD),
		SPRITE_PATH_PREFIX + "detail_dark_ear.png",
		"Detail part path should follow detail_{color}_{variant}.png format"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path("detail_horn_small", GameEnums.Strain.BEAST),
		SPRITE_PATH_PREFIX + "detail_green_horn_small.png",
		"Multi-word detail variant should preserve full variant name"
	)


func test_get_sprite_path_invalid_shape_returns_empty() -> void:
	assert_eq(
		ChimeraSprite.get_sprite_path("invalid", GameEnums.Strain.UNDEAD),
		"",
		"Shape ID without underscore should return empty string"
	)


# --- Layer z-order tests ---


func test_has_eight_sprite_layers() -> void:
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	var expected_names := ["Body", "Legs", "Arms", "Detail", "Eyes", "Mouth", "Nose", "Eyebrows"]
	for layer_name in expected_names:
		assert_not_null(
			sprite.get_node_or_null(layer_name), "Layer '%s' should exist as a child" % layer_name
		)


func test_layer_z_order() -> void:
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	assert_eq(sprite.get_node("Body").z_index, 0, "Body z_index should be 0")
	assert_eq(sprite.get_node("Legs").z_index, 1, "Legs z_index should be 1")
	assert_eq(sprite.get_node("Arms").z_index, 2, "Arms z_index should be 2")
	assert_eq(sprite.get_node("Detail").z_index, 3, "Detail z_index should be 3")
	assert_eq(sprite.get_node("Eyes").z_index, 4, "Eyes z_index should be 4")
	assert_eq(sprite.get_node("Mouth").z_index, 5, "Mouth z_index should be 5")
	assert_eq(sprite.get_node("Nose").z_index, 6, "Nose z_index should be 6")
	assert_eq(sprite.get_node("Eyebrows").z_index, 7, "Eyebrows z_index should be 7")


# --- set_from_parts tests ---


func test_set_from_parts_populates_body_from_torso() -> void:
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	var chimera := _make_chimera_with_shapes("detail_ear", "body_a", "arm_a", "leg_a")
	sprite.set_from_parts(chimera)
	var body: Sprite2D = sprite.get_node("Body")
	var expected_path := ChimeraSprite.get_sprite_path("body_a", GameEnums.Strain.UNDEAD)
	assert_not_null(body.texture, "Body layer should have a texture after set_from_parts")
	assert_eq(
		body.texture.resource_path,
		expected_path,
		"Body layer texture should match TORSO part's sprite path"
	)


func test_set_from_parts_populates_all_four_part_layers() -> void:
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	var chimera := _make_chimera_with_shapes("detail_ear", "body_a", "arm_a", "leg_a")
	sprite.set_from_parts(chimera)
	var body: Sprite2D = sprite.get_node("Body")
	var legs: Sprite2D = sprite.get_node("Legs")
	var arms: Sprite2D = sprite.get_node("Arms")
	var detail: Sprite2D = sprite.get_node("Detail")
	assert_not_null(body.texture, "Body layer (TORSO) should have a texture")
	assert_not_null(legs.texture, "Legs layer (LEGS) should have a texture")
	assert_not_null(arms.texture, "Arms layer (ARMS) should have a texture")
	assert_not_null(detail.texture, "Detail layer (HEAD) should have a texture")
	assert_eq(
		body.texture.resource_path,
		ChimeraSprite.get_sprite_path("body_a", GameEnums.Strain.UNDEAD),
		"Body should use TORSO shape_id"
	)
	assert_eq(
		legs.texture.resource_path,
		ChimeraSprite.get_sprite_path("leg_a", GameEnums.Strain.UNDEAD),
		"Legs should use LEGS shape_id"
	)
	assert_eq(
		arms.texture.resource_path,
		ChimeraSprite.get_sprite_path("arm_a", GameEnums.Strain.UNDEAD),
		"Arms should use ARMS shape_id"
	)
	assert_eq(
		detail.texture.resource_path,
		ChimeraSprite.get_sprite_path("detail_ear", GameEnums.Strain.UNDEAD),
		"Detail should use HEAD shape_id"
	)


func test_set_from_parts_leaves_cosmetic_layers_empty() -> void:
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	var chimera := _make_chimera_with_shapes("detail_ear", "body_a", "arm_a", "leg_a")
	sprite.set_from_parts(chimera)
	assert_null(sprite.get_node("Eyes").texture, "Eyes should have no texture (cosmetic, unset)")
	assert_null(sprite.get_node("Mouth").texture, "Mouth should have no texture (cosmetic, unset)")
	assert_null(sprite.get_node("Nose").texture, "Nose should have no texture (cosmetic, unset)")
	assert_null(
		sprite.get_node("Eyebrows").texture, "Eyebrows should have no texture (cosmetic, unset)"
	)


func test_chimera_sprite_is_pure_visual() -> void:
	# ChimeraSprite should work with just a ChimeraData — no CombatState or ChimeraEntity needed.
	var sprite: ChimeraSprite = add_child_autofree(ChimeraSprite.new())
	var chimera := _make_chimera_with_shapes("detail_ear", "body_a", "arm_a", "leg_a")
	sprite.set_from_parts(chimera)
	assert_not_null(
		sprite.get_node("Body").texture,
		"Sprite should render with just ChimeraData, no combat dependency"
	)
