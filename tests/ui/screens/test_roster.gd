# gdlint:ignore=max-public-methods
## Tests for RosterScreen — detailed read-only chimera viewer.
extends GutTest

# --- Expected strain chip colors (must match roster.gd COLOR_NAME_TO_COLOR) ---

const _STRAIN_CHIP_COLORS := {
	GameEnums.Strain.UNDEAD: Color(0.2, 0.2, 0.2),
	GameEnums.Strain.ROBOTIC: Color(1.0, 1.0, 1.0),
	GameEnums.Strain.DRACONIC: Color(0.8, 0.2, 0.2),
	GameEnums.Strain.BEAST: Color(0.2, 0.8, 0.2),
	GameEnums.Strain.ELEMENTAL: Color(0.2, 0.2, 0.8),
	GameEnums.Strain.ABERRANT: Color(0.8, 0.8, 0.2),
	GameEnums.Strain.NEUTRAL: Color(0.2, 0.2, 0.2),
}

# --- Mock parent that records change_screen / play_click calls ---


class _MockParent:
	extends Control
	var screen_changes: Array = []
	var click_count: int = 0

	func change_screen(screen_name: String) -> void:
		screen_changes.append(screen_name)

	func play_click() -> void:
		click_count += 1


var _saved_roster: Array = []

# --- Helpers ---


func _make_part(
	slot: GameEnums.PartSlot,
	strain: GameEnums.Strain,
	hp: float = 10.0,
	atk: float = 5.0,
	def_val: float = 3.0,
	spd: float = 7.0
) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	part.rarity = GameEnums.Rarity.COMMON
	match slot:
		GameEnums.PartSlot.HEAD:
			part.shape_id = "detail_horn_small"
		GameEnums.PartSlot.TORSO:
			part.shape_id = "body_a"
		GameEnums.PartSlot.ARMS:
			part.shape_id = "arm_a"
		GameEnums.PartSlot.LEGS:
			part.shape_id = "leg_a"
	part.sprite_path = ChimeraSprite.get_sprite_path(part.shape_id, strain)
	part.hp_bonus = hp
	part.attack_bonus = atk
	part.defense_bonus = def_val
	part.speed_bonus = spd
	part.attack_range = 32.0
	part.ability_id = "test_ability"
	return part


func _make_ability(id: String, ability_name: String, type: GameEnums.AbilityType) -> AbilityData:
	var ability := AbilityData.new()
	ability.id = id
	ability.name = ability_name
	ability.type = type
	return ability


func _make_chimera(
	nickname: String,
	strains: Array,
	hp: float = 10.0,
	atk: float = 5.0,
	def_val: float = 3.0,
	spd: float = 7.0
) -> ChimeraData:
	var chimera := ChimeraData.new()
	chimera.nickname = nickname
	chimera.head = _make_part(GameEnums.PartSlot.HEAD, strains[0], hp, atk, def_val, spd)
	chimera.torso = _make_part(GameEnums.PartSlot.TORSO, strains[1], hp, atk, def_val, spd)
	chimera.arms = _make_part(GameEnums.PartSlot.ARMS, strains[2], hp, atk, def_val, spd)
	chimera.legs = _make_part(GameEnums.PartSlot.LEGS, strains[3], hp, atk, def_val, spd)
	chimera.calculate_instability()
	chimera.recalculate_stats()
	chimera.part_abilities = [
		_make_ability("a1", "Bite", GameEnums.AbilityType.ACTIVE),
		_make_ability("a2", "Claw", GameEnums.AbilityType.PASSIVE),
		_make_ability("a3", "Stomp", GameEnums.AbilityType.ACTIVE),
		_make_ability("a4", "Roar", GameEnums.AbilityType.PASSIVE),
	]
	return chimera


func _make_chimera_with_combo(
	nickname: String,
	strains: Array,
	combo_tier: int,
	hp: float = 10.0,
	atk: float = 5.0,
	def_val: float = 3.0,
	spd: float = 7.0
) -> ChimeraData:
	var chimera := _make_chimera(nickname, strains, hp, atk, def_val, spd)
	chimera.combo_ability = _make_ability("combo", "Synergy Strike", GameEnums.AbilityType.ACTIVE)
	chimera.combo_tier = combo_tier
	return chimera


func before_each() -> void:
	_saved_roster = GameState.roster.duplicate()


func after_each() -> void:
	GameState.roster = _saved_roster


func _create_roster(parent: _MockParent) -> RosterScreen:
	var screen: RosterScreen = preload("res://scenes/ui/screens/roster.tscn").instantiate()
	parent.add_child(screen)
	return screen


func _create_roster_with_chimeras(parent: _MockParent) -> RosterScreen:
	GameState.roster = [
		_make_chimera_with_combo(
			"Alpha",
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
			],
			3
		),
		_make_chimera_with_combo(
			"Beta",
			[
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.UNDEAD,
			],
			2
		),
		_make_chimera(
			"Gamma",
			[
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.ROBOTIC,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.BEAST,
			]
		),
	]
	return _create_roster(parent)


func _get_cards(screen: RosterScreen) -> Array:
	var container := screen.get_node_or_null("RosterContainer")
	if container == null:
		return []
	var cards: Array = []
	for child in container.get_children():
		if child is PanelContainer:
			cards.append(child)
	return cards


# --- Card population tests ---


func test_roster_creates_3_cards_from_roster() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	assert_eq(cards.size(), 3, "Should populate 3 detailed cards from roster")


func test_roster_creates_cards_matching_roster_count() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	GameState.roster = [
		_make_chimera(
			"Solo",
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
			]
		),
	]
	_create_roster(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	assert_eq(cards.size(), 1, "Should create 1 card for 1 chimera")


func test_roster_creates_no_cards_when_empty() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	GameState.roster = []
	_create_roster(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	assert_eq(cards.size(), 0, "Should create 0 cards when roster is empty")


func test_cards_display_correct_nicknames() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	assert_eq(cards[0].get_node("Content/NicknameLabel").text, "Alpha")
	assert_eq(cards[1].get_node("Content/NicknameLabel").text, "Beta")
	assert_eq(cards[2].get_node("Content/NicknameLabel").text, "Gamma")


func test_card_has_chimera_sprite_preview() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var sprite: Node = cards[i].get_node_or_null(
			"Content/SpriteContainer/SubViewport/ChimeraSprite"
		)
		assert_not_null(sprite, "Card %d should have a ChimeraSprite preview" % i)
		assert_true(
			sprite is ChimeraSprite, "Card %d ChimeraSprite should be ChimeraSprite type" % i
		)


func test_chimera_sprite_preview_has_textures() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var sprite := (
			cards[i].get_node("Content/SpriteContainer/SubViewport/ChimeraSprite") as ChimeraSprite
		)
		var body := sprite.get_node("Body") as Sprite2D
		assert_not_null(
			body.texture, "Card %d Body layer should have a texture after set_from_parts" % i
		)


# --- Stat label tests ---


func test_card_displays_correct_hp() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var label := cards[i].get_node("Content/StatsContainer/HPLabel") as Label
		assert_eq(
			label.text,
			str(int(GameState.roster[i].max_hp)),
			"Card %d HP should match chimera max_hp" % i
		)


func test_card_displays_correct_attack() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var label := cards[i].get_node("Content/StatsContainer/AttackLabel") as Label
		assert_eq(label.text, str(int(GameState.roster[i].attack)), "Card %d attack mismatch" % i)


func test_card_displays_correct_defense() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var label := cards[i].get_node("Content/StatsContainer/DefenseLabel") as Label
		assert_eq(label.text, str(int(GameState.roster[i].defense)), "Card %d defense mismatch" % i)


func test_card_displays_correct_speed() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var label := cards[i].get_node("Content/StatsContainer/SpeedLabel") as Label
		assert_eq(label.text, str(int(GameState.roster[i].speed)), "Card %d speed mismatch" % i)


func test_card_displays_correct_attack_range() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var label := cards[i].get_node("Content/StatsContainer/RangeLabel") as Label
		assert_eq(
			label.text, str(int(GameState.roster[i].attack_range)), "Card %d range mismatch" % i
		)


# --- Instability label tests ---


func test_instability_label_pure() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Alpha: 4 BEAST → 1 distinct strain → Pure
	var label := cards[0].get_node("Content/InstabilityLabel") as Label
	assert_eq(label.text, "Pure", "Alpha (1 strain) should be Pure")


func test_instability_label_stable_hybrid() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Beta: 3 UNDEAD + 1 DRACONIC → 2 distinct strains → Stable Hybrid
	var label := cards[1].get_node("Content/InstabilityLabel") as Label
	assert_eq(label.text, "Stable Hybrid", "Beta (2 strains) should be Stable Hybrid")


func test_instability_label_volatile_hybrid() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	GameState.roster = [
		_make_chimera(
			"Delta",
			[
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.ROBOTIC,
				GameEnums.Strain.DRACONIC,
			]
		),
	]
	_create_roster(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# 3 distinct strains → Volatile Hybrid
	var label := cards[0].get_node("Content/InstabilityLabel") as Label
	assert_eq(label.text, "Volatile Hybrid", "Delta (3 strains) should be Volatile Hybrid")


func test_instability_label_chaotic() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Gamma: UNDEAD, ROBOTIC, DRACONIC, BEAST → 4 distinct strains → Chaotic
	var label := cards[2].get_node("Content/InstabilityLabel") as Label
	assert_eq(label.text, "Chaotic", "Gamma (4 strains) should be Chaotic")


# --- Combo ability tests ---


func test_combo_ability_displayed_when_present() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Alpha has combo_ability set
	var combo: Node = cards[0].get_node_or_null("Content/AbilitiesContainer/ComboAbility")
	assert_not_null(combo, "Alpha should display combo ability")


func test_combo_ability_absent_when_null() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Gamma has no combo_ability
	var combo: Node = cards[2].get_node_or_null("Content/AbilitiesContainer/ComboAbility")
	assert_null(combo, "Gamma should NOT display combo ability")


func test_combo_tier_label_ultimate() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Alpha: combo_tier=3 → Ultimate
	var label := (
		cards[0].get_node("Content/AbilitiesContainer/ComboAbility/ComboTierLabel") as Label
	)
	assert_eq(label.text, "(Ultimate)", "Alpha combo tier 3 should be Ultimate")


func test_combo_tier_label_enhanced() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Beta: combo_tier=2 → Enhanced
	var label := (
		cards[1].get_node("Content/AbilitiesContainer/ComboAbility/ComboTierLabel") as Label
	)
	assert_eq(label.text, "(Enhanced)", "Beta combo tier 2 should be Enhanced")


func test_combo_tier_label_basic() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	GameState.roster = [
		_make_chimera_with_combo(
			"Epsilon",
			[
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ROBOTIC,
				GameEnums.Strain.ABERRANT,
			],
			1
		),
	]
	_create_roster(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	var label := (
		cards[0].get_node("Content/AbilitiesContainer/ComboAbility/ComboTierLabel") as Label
	)
	assert_eq(label.text, "(Basic)", "combo tier 1 should be Basic")


# --- Strain chip tests ---


func test_strain_chips_count_is_4() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	for i in cards.size():
		var chips: Array = cards[i].get_node("Content/StrainChipsContainer").get_children()
		assert_eq(chips.size(), 4, "Card %d should have 4 strain chips" % i)


func test_strain_chips_colored_per_strain() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Alpha: all 4 BEAST → all chips green
	var alpha_chips: Array = cards[0].get_node("Content/StrainChipsContainer").get_children()
	for j in alpha_chips.size():
		var chip := alpha_chips[j] as ColorRect
		assert_eq(
			chip.color,
			_STRAIN_CHIP_COLORS[GameEnums.Strain.BEAST],
			"Alpha chip %d should be Beast color (green)" % j
		)
	# Gamma: UNDEAD, ROBOTIC, DRACONIC, BEAST → dark, white, red, green
	var gamma_chips: Array = cards[2].get_node("Content/StrainChipsContainer").get_children()
	var gamma_strains := [
		GameEnums.Strain.UNDEAD,
		GameEnums.Strain.ROBOTIC,
		GameEnums.Strain.DRACONIC,
		GameEnums.Strain.BEAST,
	]
	for j in gamma_chips.size():
		var chip := gamma_chips[j] as ColorRect
		assert_eq(
			chip.color,
			_STRAIN_CHIP_COLORS[gamma_strains[j]],
			"Gamma chip %d color should match strain" % j
		)


# --- Parts list tests ---


func test_parts_listed_with_slot_strain_rarity() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Check Alpha's 4 parts
	var parts: Array = cards[0].get_node("Content/PartsContainer").get_children()
	assert_eq(parts.size(), 4, "Should list 4 equipped parts")
	var slot_names := ["HEAD", "TORSO", "ARMS", "LEGS"]
	var strain_names := ["Beast", "Beast", "Beast", "Beast"]
	for j in parts.size():
		var slot_label := parts[j].get_node("SlotLabel") as Label
		var strain_label := parts[j].get_node("StrainLabel") as Label
		var rarity_label := parts[j].get_node("RarityLabel") as Label
		assert_eq(slot_label.text, slot_names[j], "Part %d slot label" % j)
		assert_eq(strain_label.text, strain_names[j], "Part %d strain label" % j)
		assert_eq(rarity_label.text, "Common", "Part %d rarity label" % j)


# --- Abilities list tests ---


func test_abilities_list_shows_4_part_abilities() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	var abilities: Array = cards[0].get_node("Content/AbilitiesContainer").get_children()
	# 4 part abilities + 1 combo = 5 for Alpha
	assert_eq(abilities.size(), 5, "Alpha should show 4 part abilities + 1 combo")
	# Gamma: 4 part abilities, no combo
	var gamma_abilities: Array = cards[2].get_node("Content/AbilitiesContainer").get_children()
	assert_eq(gamma_abilities.size(), 4, "Gamma should show 4 part abilities (no combo)")


func test_ability_entries_show_name_and_type() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	# Alpha's first ability: "Bite" (ACTIVE)
	var ability0: Node = cards[0].get_node("Content/AbilitiesContainer/Ability0")
	var name_label := ability0.get_node("AbilityNameLabel") as Label
	var type_label := ability0.get_node("AbilityTypeLabel") as Label
	assert_eq(name_label.text, "Bite", "First ability name should be Bite")
	assert_eq(type_label.text, "[Active]", "First ability type should be Active")


# --- Decay and wins tests ---


func test_decay_label_shows_decay_level() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	var label := cards[0].get_node("Content/RecordRow/DecayLabel") as Label
	assert_eq(label.text, "Decay: 0", "Fresh chimera should show decay 0")


func test_wins_label_shows_match_wins() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	var screen := parent.get_child(0) as RosterScreen
	var cards := _get_cards(screen)
	var label := cards[0].get_node("Content/RecordRow/WinsLabel") as Label
	assert_eq(label.text, "Wins: 0", "Fresh chimera should show 0 wins")


# --- Back button test ---


func test_back_button_calls_change_screen_lab_hub() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster(parent)
	var screen := parent.get_child(0) as RosterScreen
	var btn := screen.get_node("BackButton") as Button
	btn.emit_signal("pressed")
	assert_eq(parent.screen_changes, ["lab_hub"], "Back should navigate to lab_hub")
	assert_eq(parent.click_count, 1, "Back should play click sound")


# --- View-only test ---


func test_roster_is_view_only() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_roster_with_chimeras(parent)
	# Verify no mutation occurred to any chimera after roster display
	for i in GameState.roster.size():
		var chimera := GameState.roster[i] as ChimeraData
		assert_eq(chimera.nickname, ["Alpha", "Beta", "Gamma"][i], "Nickname unchanged")
		assert_eq(chimera.decay_level, 0, "Decay level unchanged")
		assert_eq(chimera.match_wins, 0, "Match wins unchanged")
		# Verify stats still match original values (4 parts × 10 hp = 40, ×1.2 for pure = 48)
		if i == 0:
			assert_eq(int(chimera.max_hp), 48, "Alpha max_hp unchanged")
		else:
			assert_eq(int(chimera.max_hp), 40, "Non-pure max_hp unchanged")
