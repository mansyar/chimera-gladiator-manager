class_name RosterScreen
extends Control

## Detailed read-only chimera viewer screen.
##
## Displays one card per chimera in GameState.roster with full details:
## sprite preview, equipped parts, derived stats, instability, strain chips,
## decay, match wins, and abilities (including combo if present).
## (FR-10..FR-14: Roster Screen)

## Maps strain enum to display name string.
const STRAIN_DISPLAY_NAMES := {
	GameEnums.Strain.UNDEAD: "Undead",
	GameEnums.Strain.ROBOTIC: "Robotic",
	GameEnums.Strain.DRACONIC: "Draconic",
	GameEnums.Strain.BEAST: "Beast",
	GameEnums.Strain.ELEMENTAL: "Elemental",
	GameEnums.Strain.ABERRANT: "Aberrant",
	GameEnums.Strain.NEUTRAL: "Neutral",
}

## Maps rarity enum to display name string.
const RARITY_DISPLAY_NAMES := {
	GameEnums.Rarity.COMMON: "Common",
	GameEnums.Rarity.UNCOMMON: "Uncommon",
	GameEnums.Rarity.RARE: "Rare",
	GameEnums.Rarity.LEGENDARY: "Legendary",
}

## Maps part slot enum to display label.
const SLOT_DISPLAY_NAMES := {
	GameEnums.PartSlot.HEAD: "HEAD",
	GameEnums.PartSlot.TORSO: "TORSO",
	GameEnums.PartSlot.ARMS: "ARMS",
	GameEnums.PartSlot.LEGS: "LEGS",
}

## Maps combo tier to display label.
const COMBO_TIER_LABELS := {
	1: "Basic",
	2: "Enhanced",
	3: "Ultimate",
}

## Maps ability type enum to display label.
const ABILITY_TYPE_LABELS := {
	GameEnums.AbilityType.ACTIVE: "Active",
	GameEnums.AbilityType.PASSIVE: "Passive",
}

## Maps Kenney color name to actual Color value for strain chips.
const COLOR_NAME_TO_COLOR := {
	"dark": Color(0.2, 0.2, 0.2),
	"white": Color(1.0, 1.0, 1.0),
	"red": Color(0.8, 0.2, 0.2),
	"green": Color(0.2, 0.8, 0.2),
	"blue": Color(0.2, 0.2, 0.8),
	"yellow": Color(0.8, 0.8, 0.2),
}


func _ready() -> void:
	_populate_roster_cards()


## Build one detailed card per chimera in GameState.roster.
func _populate_roster_cards() -> void:
	var container := get_node_or_null("RosterContainer")
	if container == null:
		return
	for i in GameState.roster.size():
		var chimera: ChimeraData = GameState.roster[i]
		var card := _create_card(chimera, i)
		container.add_child(card)
		# set_from_parts must run after the card enters the SceneTree so
		# ChimeraSprite._ready() has created the 8 Sprite2D layers.
		var sprite := (
			card.get_node_or_null("Content/SpriteContainer/SubViewport/ChimeraSprite")
			as ChimeraSprite
		)
		if sprite != null:
			sprite.set_from_parts(chimera)


## Create a detailed card for a single chimera.
## Contains: nickname, ChimeraSprite preview, parts list, stat grid,
## instability label, strain chips, decay, wins, and abilities list.
func _create_card(chimera: ChimeraData, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Card%d" % index
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	card_style.border_color = Color(0.4, 0.4, 0.4, 1.0)
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left = 12
	card_style.content_margin_right = 12
	card_style.content_margin_top = 12
	card_style.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", card_style)

	# All content is placed in a VBoxContainer so PanelContainer layouts correctly.
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 8)
	card.add_child(content)

	# Nickname
	var nickname := Label.new()
	nickname.name = "NicknameLabel"
	nickname.text = chimera.nickname
	nickname.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nickname.add_theme_font_size_override("font_size", 18)
	nickname.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 1.0))
	content.add_child(nickname)

	# ChimeraSprite preview is rendered into a SubViewport so the Node2D sprite is
	# clipped to the preview area and cannot overlap other card content.
	var sprite_container := SubViewportContainer.new()
	sprite_container.name = "SpriteContainer"
	sprite_container.custom_minimum_size = Vector2(100, 120)
	sprite_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sprite_container.stretch = true
	content.add_child(sprite_container)

	var viewport := SubViewport.new()
	viewport.name = "SubViewport"
	viewport.size = Vector2(100, 120)
	sprite_container.add_child(viewport)

	var sprite_bg := ColorRect.new()
	sprite_bg.name = "SpriteBackground"
	sprite_bg.color = Color(0.1, 0.1, 0.1, 1.0)
	sprite_bg.size = Vector2(100, 120)
	viewport.add_child(sprite_bg)

	var sprite := ChimeraSprite.new()
	sprite.name = "ChimeraSprite"
	sprite.scale = Vector2(0.25, 0.25)
	sprite.position = Vector2(50, 60)
	viewport.add_child(sprite)

	# Equipped parts list
	var parts_container := VBoxContainer.new()
	parts_container.name = "PartsContainer"
	content.add_child(parts_container)
	var parts := chimera.get_parts()
	for j in parts.size():
		if parts[j] != null:
			parts_container.add_child(_create_part_entry(parts[j], j))

	# Derived stats in a 2-column grid: name on the left, value on the right.
	var stats := GridContainer.new()
	stats.name = "StatsContainer"
	stats.columns = 2
	stats.add_theme_constant_override("h_separation", 8)
	stats.add_theme_constant_override("v_separation", 4)
	content.add_child(stats)
	_add_stat_pair(stats, "HP", "HPLabel", str(int(chimera.max_hp)))
	_add_stat_pair(stats, "ATK", "AttackLabel", str(int(chimera.attack)))
	_add_stat_pair(stats, "DEF", "DefenseLabel", str(int(chimera.defense)))
	_add_stat_pair(stats, "SPD", "SpeedLabel", str(int(chimera.speed)))
	_add_stat_pair(stats, "RNG", "RangeLabel", str(int(chimera.attack_range)))

	# Instability label (reuses ChimeraCard's static helper)
	var instability := Label.new()
	instability.name = "InstabilityLabel"
	instability.text = ChimeraCard.get_instability_label(chimera.instability)
	instability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instability.add_theme_font_size_override("font_size", 14)
	content.add_child(instability)

	# Strain distribution chips (one per equipped part)
	var chips := HBoxContainer.new()
	chips.name = "StrainChipsContainer"
	chips.add_theme_constant_override("separation", 6)
	chips.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(chips)
	var chip_index := 0
	for part in chimera.get_parts():
		if part != null:
			var chip := _create_strain_chip(part.strain)
			chip.name = "Chip%d" % chip_index
			chips.add_child(chip)
			chip_index += 1

	# Decay level and match wins in a compact horizontal row.
	var record_row := HBoxContainer.new()
	record_row.name = "RecordRow"
	record_row.add_theme_constant_override("separation", 16)
	record_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(record_row)

	var decay := Label.new()
	decay.name = "DecayLabel"
	decay.text = "Decay: %d" % chimera.decay_level
	record_row.add_child(decay)

	var wins := Label.new()
	wins.name = "WinsLabel"
	wins.text = "Wins: %d" % chimera.match_wins
	record_row.add_child(wins)

	# Abilities list (part abilities + combo if present)
	var abilities := VBoxContainer.new()
	abilities.name = "AbilitiesContainer"
	abilities.add_theme_constant_override("separation", 4)
	content.add_child(abilities)
	for j in chimera.part_abilities.size():
		var ability: AbilityData = chimera.part_abilities[j]
		if ability != null:
			abilities.add_child(_create_ability_entry(ability, j))
	if chimera.combo_ability != null:
		abilities.add_child(_create_combo_entry(chimera.combo_ability, chimera.combo_tier))

	return card


## Create a part list entry showing slot, strain, and rarity.
func _create_part_entry(part: PartData, index: int) -> HBoxContainer:
	var entry := HBoxContainer.new()
	entry.name = "Part%d" % index
	entry.add_theme_constant_override("separation", 6)
	entry.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var part_sprite := TextureRect.new()
	part_sprite.name = "PartSprite"
	part_sprite.custom_minimum_size = Vector2(32, 32)
	part_sprite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	part_sprite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	part_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	part_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if not part.sprite_path.is_empty():
		var tex := load(part.sprite_path)
		if tex == null:
			push_warning("Roster: failed to load part sprite at '%s'" % part.sprite_path)
		part_sprite.texture = tex
	entry.add_child(part_sprite)

	var slot_label := Label.new()
	slot_label.name = "SlotLabel"
	slot_label.text = SLOT_DISPLAY_NAMES.get(part.slot, "")
	slot_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	entry.add_child(slot_label)

	var strain_label := Label.new()
	strain_label.name = "StrainLabel"
	strain_label.text = STRAIN_DISPLAY_NAMES.get(part.strain, "")
	entry.add_child(strain_label)

	var rarity_label := Label.new()
	rarity_label.name = "RarityLabel"
	rarity_label.text = RARITY_DISPLAY_NAMES.get(part.rarity, "")
	rarity_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.5, 1.0))
	entry.add_child(rarity_label)

	return entry


## Create a color-coded strain chip for the strain distribution row.
func _create_strain_chip(strain: GameEnums.Strain) -> ColorRect:
	var chip := ColorRect.new()
	chip.color = _get_strain_color(strain)
	chip.custom_minimum_size = Vector2(20, 20)
	return chip


## Create an ability entry showing name and type (active/passive).
func _create_ability_entry(ability: AbilityData, index: int) -> HBoxContainer:
	var entry := HBoxContainer.new()
	entry.name = "Ability%d" % index
	entry.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.name = "AbilityNameLabel"
	name_label.text = ability.name
	entry.add_child(name_label)

	var type_label := Label.new()
	type_label.name = "AbilityTypeLabel"
	type_label.text = "[%s]" % ABILITY_TYPE_LABELS.get(ability.type, "")
	type_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1.0))
	entry.add_child(type_label)

	return entry


## Create a combo ability entry showing name and tier label.
func _create_combo_entry(ability: AbilityData, tier: int) -> HBoxContainer:
	var entry := HBoxContainer.new()
	entry.name = "ComboAbility"
	entry.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.name = "ComboNameLabel"
	name_label.text = ability.name
	name_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3, 1.0))
	entry.add_child(name_label)

	var tier_label := Label.new()
	tier_label.name = "ComboTierLabel"
	tier_label.text = "(%s)" % COMBO_TIER_LABELS.get(tier, "")
	tier_label.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2, 1.0))
	entry.add_child(tier_label)

	return entry


## Add a stat name/value pair to a stats grid.
func _add_stat_pair(
	container: GridContainer, stat_name: String, label_name: String, value: String
) -> void:
	var name_label := Label.new()
	name_label.text = stat_name + ":"
	name_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	container.add_child(name_label)

	var value_label := Label.new()
	value_label.name = label_name
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	container.add_child(value_label)


## Resolve a strain to its display Color via STRAIN_TO_COLOR → COLOR_NAME_TO_COLOR.
static func _get_strain_color(strain: GameEnums.Strain) -> Color:
	var color_name: String = ChimeraSprite.STRAIN_TO_COLOR.get(strain, "dark")
	return COLOR_NAME_TO_COLOR.get(color_name, Color.BLACK)


## Returns to Lab Hub on back button press.
func _on_back_button_pressed() -> void:
	get_parent().call("play_click")
	get_parent().call("change_screen", "lab_hub")
