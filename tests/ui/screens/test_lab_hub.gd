# gdlint:ignore=max-public-methods
## Tests for LabHubScreen — navigation hub with roster cards and nav buttons.
extends GutTest

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
	part.hp_bonus = hp
	part.attack_bonus = atk
	part.defense_bonus = def_val
	part.speed_bonus = spd
	part.attack_range = 32.0
	return part


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
	return chimera


func before_each() -> void:
	_saved_roster = GameState.roster.duplicate()


func after_each() -> void:
	GameState.roster = _saved_roster


func _create_hub(parent: _MockParent) -> LabHubScreen:
	var hub: LabHubScreen = preload("res://scenes/ui/screens/lab_hub.tscn").instantiate()
	parent.add_child(hub)
	return hub


func _create_hub_with_roster(parent: _MockParent) -> LabHubScreen:
	GameState.roster = [
		_make_chimera(
			"Alpha",
			[
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
				GameEnums.Strain.BEAST,
			]
		),
		_make_chimera(
			"Beta",
			[
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.UNDEAD,
				GameEnums.Strain.DRACONIC,
				GameEnums.Strain.UNDEAD,
			]
		),
		_make_chimera(
			"Gamma",
			[
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ELEMENTAL,
				GameEnums.Strain.ELEMENTAL,
			]
		),
	]
	return _create_hub(parent)


func _get_chimera_cards(hub: LabHubScreen) -> Array:
	var container := hub.get_node_or_null("RosterContainer")
	if container == null:
		return []
	var cards: Array = []
	for child in container.get_children():
		if child is ChimeraCard:
			cards.append(child)
	return cards


# --- Roster card population tests ---


func test_lab_hub_creates_3_chimera_cards_from_roster() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(cards.size(), 3, "Should populate 3 chimera cards from roster")


func test_cards_display_correct_nicknames() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(cards[0].get_nickname_text(), "Alpha", "Card 0 should show Alpha")
	assert_eq(cards[1].get_nickname_text(), "Beta", "Card 1 should show Beta")
	assert_eq(cards[2].get_nickname_text(), "Gamma", "Card 2 should show Gamma")


func test_cards_display_correct_hp() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(
		cards[0].get_hp_text(),
		str(int(GameState.roster[0].max_hp)),
		"Card 0 HP should match chimera max_hp"
	)
	assert_eq(
		cards[1].get_hp_text(),
		str(int(GameState.roster[1].max_hp)),
		"Card 1 HP should match chimera max_hp"
	)
	assert_eq(
		cards[2].get_hp_text(),
		str(int(GameState.roster[2].max_hp)),
		"Card 2 HP should match chimera max_hp"
	)


func test_cards_display_correct_attack() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(
		cards[0].get_attack_text(),
		str(int(GameState.roster[0].attack)),
		"Card 0 attack should match chimera attack"
	)


func test_cards_display_correct_defense() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(
		cards[0].get_defense_text(),
		str(int(GameState.roster[0].defense)),
		"Card 0 defense should match chimera defense"
	)


func test_cards_display_correct_speed() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(
		cards[0].get_speed_text(),
		str(int(GameState.roster[0].speed)),
		"Card 0 speed should match chimera speed"
	)


func test_cards_display_correct_instability_label() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub_with_roster(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	# Alpha: 4 BEAST → Pure (1 strain)
	assert_eq(cards[0].get_instability_text(), "Pure", "Alpha should be Pure")
	# Beta: 3 UNDEAD + 1 DRACONIC → Stable Hybrid (2 strains)
	assert_eq(cards[1].get_instability_text(), "Stable Hybrid", "Beta should be Stable Hybrid")
	# Gamma: 4 ELEMENTAL → Pure (1 strain)
	assert_eq(cards[2].get_instability_text(), "Pure", "Gamma should be Pure")


func test_lab_hub_creates_cards_matching_roster_count() -> void:
	# When roster has fewer than 3, only create cards for existing chimeras.
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
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(cards.size(), 1, "Should create 1 card for 1 chimera in roster")


func test_lab_hub_creates_no_cards_when_roster_empty() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	GameState.roster = []
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var cards := _get_chimera_cards(hub)
	assert_eq(cards.size(), 0, "Should create 0 cards when roster is empty")


# --- Navigation button tests ---


func test_lab_hub_has_exactly_7_nav_buttons() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var nav := hub.get_node_or_null("NavContainer")
	assert_not_null(nav, "NavContainer should exist")
	var button_count := 0
	for child in nav.get_children():
		if child is Button:
			button_count += 1
	assert_eq(button_count, 7, "Should have exactly 7 nav buttons")


func test_nav_button_assembly_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("assembly")
	assert_eq(parent.screen_changes, ["assembly"], "Should navigate to assembly")
	assert_eq(parent.click_count, 1, "Should play click sound")


func test_nav_button_black_market_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("black_market")
	assert_eq(parent.screen_changes, ["black_market"])
	assert_eq(parent.click_count, 1)


func test_nav_button_roster_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("roster")
	assert_eq(parent.screen_changes, ["roster"])
	assert_eq(parent.click_count, 1)


func test_nav_button_clinic_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("clinic")
	assert_eq(parent.screen_changes, ["clinic"])
	assert_eq(parent.click_count, 1)


func test_nav_button_tournament_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("tournament")
	assert_eq(parent.screen_changes, ["tournament"])
	assert_eq(parent.click_count, 1)


func test_nav_button_hall_of_fame_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("hall_of_fame")
	assert_eq(parent.screen_changes, ["hall_of_fame"])
	assert_eq(parent.click_count, 1)


func test_nav_button_arena_pre_match_calls_change_screen() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	hub._on_nav_button_pressed("arena_pre_match")
	assert_eq(parent.screen_changes, ["arena_pre_match"])
	assert_eq(parent.click_count, 1)


# --- Quick Match button tests ---


func test_quick_match_button_exists() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var btn := hub.get_node_or_null("QuickMatchButton")
	assert_not_null(btn, "Quick Match button should exist")
	assert_true(btn is Button, "QuickMatchButton should be a Button")


func test_quick_match_button_navigates_to_arena_pre_match() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var btn := hub.get_node("QuickMatchButton") as Button
	btn.emit_signal("pressed")
	assert_eq(
		parent.screen_changes, ["arena_pre_match"], "Quick Match should go to arena_pre_match"
	)
	assert_eq(parent.click_count, 1, "Quick Match should play click sound")


# --- No Gold/Infamy labels tests ---


func test_lab_hub_has_no_gold_label() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var gold_label := hub.get_node_or_null("GoldLabel")
	assert_null(gold_label, "Lab Hub should NOT have its own Gold label (relies on TopBar)")


func test_lab_hub_has_no_infamy_label() -> void:
	var parent := _MockParent.new()
	add_child_autofree(parent)
	_create_hub(parent)
	var hub := parent.get_child(0) as LabHubScreen
	var infamy_label := hub.get_node_or_null("InfamyLabel")
	assert_null(infamy_label, "Lab Hub should NOT have its own Infamy label (relies on TopBar)")
