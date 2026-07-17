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


## Create a detailed card for a single chimera.
## Contains: nickname, ChimeraSprite preview, parts list, stat grid,
## instability label, strain chips, decay, wins, and abilities list.
func _create_card(chimera: ChimeraData, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Card%d" % index

	# Nickname
	var nickname := Label.new()
	nickname.name = "NicknameLabel"
	nickname.text = chimera.nickname
	card.add_child(nickname)

	# ChimeraSprite preview (part-derived layers populated)
	var sprite := ChimeraSprite.new()
	sprite.name = "ChimeraSprite"
	card.add_child(sprite)
	sprite.set_from_parts(chimera)

	# Equipped parts list
	var parts_container := VBoxContainer.new()
	parts_container.name = "PartsContainer"
	card.add_child(parts_container)
	var parts := chimera.get_parts()
	for j in parts.size():
		if parts[j] != null:
			parts_container.add_child(_create_part_entry(parts[j], j))

	# Derived stats
	var stats := VBoxContainer.new()
	stats.name = "StatsContainer"
	card.add_child(stats)
	_add_stat_label(stats, "HPLabel", str(int(chimera.max_hp)))
	_add_stat_label(stats, "AttackLabel", str(int(chimera.attack)))
	_add_stat_label(stats, "DefenseLabel", str(int(chimera.defense)))
	_add_stat_label(stats, "SpeedLabel", str(int(chimera.speed)))
	_add_stat_label(stats, "RangeLabel", str(int(chimera.attack_range)))

	# Instability label (reuses ChimeraCard's static helper)
	var instability := Label.new()
	instability.name = "InstabilityLabel"
	instability.text = ChimeraCard.get_instability_label(chimera.instability)
	card.add_child(instability)

	# Strain distribution chips (one per equipped part)
	var chips := HBoxContainer.new()
	chips.name = "StrainChipsContainer"
	card.add_child(chips)
	var chip_index := 0
	for part in chimera.get_parts():
		if part != null:
			var chip := _create_strain_chip(part.strain)
			chip.name = "Chip%d" % chip_index
			chips.add_child(chip)
			chip_index += 1

	# Decay level
	var decay := Label.new()
	decay.name = "DecayLabel"
	decay.text = "Decay: %d" % chimera.decay_level
	card.add_child(decay)

	# Match wins
	var wins := Label.new()
	wins.name = "WinsLabel"
	wins.text = "Wins: %d" % chimera.match_wins
	card.add_child(wins)

	# Abilities list (part abilities + combo if present)
	var abilities := VBoxContainer.new()
	abilities.name = "AbilitiesContainer"
	card.add_child(abilities)
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

	var part_sprite := TextureRect.new()
	part_sprite.name = "PartSprite"
	if not part.sprite_path.is_empty():
		part_sprite.texture = load(part.sprite_path)
	entry.add_child(part_sprite)

	var slot_label := Label.new()
	slot_label.name = "SlotLabel"
	slot_label.text = SLOT_DISPLAY_NAMES.get(part.slot, "")
	entry.add_child(slot_label)

	var strain_label := Label.new()
	strain_label.name = "StrainLabel"
	strain_label.text = STRAIN_DISPLAY_NAMES.get(part.strain, "")
	entry.add_child(strain_label)

	var rarity_label := Label.new()
	rarity_label.name = "RarityLabel"
	rarity_label.text = RARITY_DISPLAY_NAMES.get(part.rarity, "")
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

	var name_label := Label.new()
	name_label.name = "AbilityNameLabel"
	name_label.text = ability.name
	entry.add_child(name_label)

	var type_label := Label.new()
	type_label.name = "AbilityTypeLabel"
	type_label.text = ABILITY_TYPE_LABELS.get(ability.type, "")
	entry.add_child(type_label)

	return entry


## Create a combo ability entry showing name and tier label.
func _create_combo_entry(ability: AbilityData, tier: int) -> HBoxContainer:
	var entry := HBoxContainer.new()
	entry.name = "ComboAbility"

	var name_label := Label.new()
	name_label.name = "ComboNameLabel"
	name_label.text = ability.name
	entry.add_child(name_label)

	var tier_label := Label.new()
	tier_label.name = "ComboTierLabel"
	tier_label.text = COMBO_TIER_LABELS.get(tier, "")
	entry.add_child(tier_label)

	return entry


## Add a labeled stat to a stats container.
func _add_stat_label(container: VBoxContainer, label_name: String, text: String) -> void:
	var label := Label.new()
	label.name = label_name
	label.text = text
	container.add_child(label)


## Resolve a strain to its display Color via STRAIN_TO_COLOR → COLOR_NAME_TO_COLOR.
static func _get_strain_color(strain: GameEnums.Strain) -> Color:
	var color_name: String = ChimeraSprite.STRAIN_TO_COLOR.get(strain, "dark")
	return COLOR_NAME_TO_COLOR.get(color_name, Color.BLACK)


## Returns to Lab Hub on back button press.
func _on_back_button_pressed() -> void:
	get_parent().call("play_click")
	get_parent().call("change_screen", "lab_hub")
