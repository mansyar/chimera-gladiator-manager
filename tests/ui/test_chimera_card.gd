## Tests for ChimeraCard widget — displays chimera nickname, stats, instability.
extends GutTest
# gdlint:ignore=max-public-methods

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


# --- Node creation tests ---


func test_chimera_card_creates_nickname_label() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	assert_not_null(widget.get_nickname_label(), "Nickname label should exist")


func test_chimera_card_creates_stat_labels() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	assert_not_null(widget.get_hp_label(), "HP label should exist")
	assert_not_null(widget.get_attack_label(), "Attack label should exist")
	assert_not_null(widget.get_defense_label(), "Defense label should exist")
	assert_not_null(widget.get_speed_label(), "Speed label should exist")


func test_chimera_card_creates_instability_label() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	assert_not_null(widget.get_instability_label_node(), "Instability label should exist")


# --- Nickname display tests ---


func test_displays_chimera_nickname() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"TestChimera",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_nickname_text(), "TestChimera", "Should display nickname")


# --- Stat display tests ---


func test_displays_hp_value() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"TestChimera",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_hp_text(), str(int(chimera.max_hp)), "Should display max_hp value")


func test_displays_attack_value() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"TestChimera",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_attack_text(), str(int(chimera.attack)), "Should display attack value")


func test_displays_defense_value() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"TestChimera",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_defense_text(), str(int(chimera.defense)), "Should display defense value")


func test_displays_speed_value() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"TestChimera",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_speed_text(), str(int(chimera.speed)), "Should display speed value")


# --- Instability label tests ---


func test_instability_label_pure() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"Purebred",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_instability_text(), "Pure", "Purebred should show 'Pure'")


func test_instability_label_stable_hybrid() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"StableHybrid",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
		]
	)
	widget.chimera = chimera
	assert_eq(
		widget.get_instability_text(), "Stable Hybrid", "2 strains should show 'Stable Hybrid'"
	)


func test_instability_label_volatile_hybrid() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"VolatileHybrid",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.DRACONIC,
		]
	)
	widget.chimera = chimera
	assert_eq(
		widget.get_instability_text(), "Volatile Hybrid", "3 strains should show 'Volatile Hybrid'"
	)


func test_instability_label_chaotic() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	var chimera := _make_chimera(
		"Chaotic",
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.UNDEAD,
			GameEnums.Strain.ELEMENTAL,
		]
	)
	widget.chimera = chimera
	assert_eq(widget.get_instability_text(), "Chaotic", "4 strains should show 'Chaotic'")


# --- Instability label helper tests ---


func test_get_instability_label_pure() -> void:
	assert_eq(ChimeraCard.get_instability_label(0), "Pure")


func test_get_instability_label_stable() -> void:
	assert_eq(ChimeraCard.get_instability_label(1), "Stable Hybrid")


func test_get_instability_label_volatile() -> void:
	assert_eq(ChimeraCard.get_instability_label(2), "Volatile Hybrid")


func test_get_instability_label_chaotic() -> void:
	assert_eq(ChimeraCard.get_instability_label(3), "Chaotic")


# --- Edge cases ---


func test_no_crash_when_chimera_null() -> void:
	var widget: ChimeraCard = add_child_autofree(ChimeraCard.new())
	widget.chimera = null
	assert_eq(widget.get_nickname_text(), "", "Nickname should be empty when chimera is null")
