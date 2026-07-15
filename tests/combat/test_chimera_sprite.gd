extends GutTest

## Tests for ChimeraSprite composition (FR-3).
## Verifies strain-to-color mapping and sprite path construction.


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
		"grey",
		"NEUTRAL should map to 'grey'"
	)


func test_get_sprite_path_constructs_correct_format() -> void:
	var path: String = ChimeraSprite.get_sprite_path("body_a", GameEnums.Strain.UNDEAD)
	assert_eq(
		path,
		"res://assets/kenney-monster-builder-pack/PNG/Default/body_a_dark.png",
		"Path should follow {shape_id}_{color}.png format"
	)


func test_get_sprite_path_for_each_strain() -> void:
	var shape_id: String = "arm_a"
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.UNDEAD),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_dark.png",
		"UNDEAD path should use 'dark'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ROBOTIC),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_white.png",
		"ROBOTIC path should use 'white'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.DRACONIC),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_red.png",
		"DRACONIC path should use 'red'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.BEAST),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_green.png",
		"BEAST path should use 'green'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ELEMENTAL),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_blue.png",
		"ELEMENTAL path should use 'blue'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.ABERRANT),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_yellow.png",
		"ABERRANT path should use 'yellow'"
	)
	assert_eq(
		ChimeraSprite.get_sprite_path(shape_id, GameEnums.Strain.NEUTRAL),
		"res://assets/kenney-monster-builder-pack/PNG/Default/arm_a_grey.png",
		"NEUTRAL path should use 'grey'"
	)
