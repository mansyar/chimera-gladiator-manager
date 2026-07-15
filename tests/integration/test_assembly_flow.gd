## Integration tests for the chimera assembly flow:
## equip part -> recalculate_stats -> update instability -> combo lookup -> save.
##
## Tests cross-system interaction between ChimeraData, PartDatabase,
## GameState, and SaveManager to verify the full assembly lifecycle.
extends GutTest


func before_each() -> void:
	SaveManager.delete_save()
	_reset_game_state()


func after_each() -> void:
	SaveManager.delete_save()
	_reset_game_state()


func _reset_game_state() -> void:
	GameState.gold = 200
	GameState.infamy = 0
	GameState.roster = []
	GameState.inventory = []
	GameState.market_stock = {}
	GameState.research_progress = {}
	GameState.research_points = 0
	GameState.hall_of_fame = []
	GameState.match_history = []
	GameState.losing_streak = 0
	GameState.current_tournament = {}


func _setup_roster() -> void:
	# Initialize roster with starter chimeras from PartDatabase
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = []
	for starter in starters:
		GameState.roster.append(starter.duplicate())


# --- Equip part -> recalculate -> save -> load ---


func test_equip_part_updates_stats_and_persists() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var original_attack := chimera.attack
	# Generate a new head part with different stats
	var new_head := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.LEGENDARY: 100}
	)
	assert_not_null(new_head, "should generate a head part")
	# Equip the new part
	chimera.head = new_head
	chimera.calculate_instability()
	chimera.recalculate_stats()
	# Stats should have changed
	var new_attack := chimera.attack
	# Save via replace_chimera (triggers SaveManager.save_game)
	GameState.replace_chimera(0, chimera)
	assert_true(SaveManager.has_save(), "save should exist after equip")
	# Clear and reload
	GameState.roster = []
	SaveManager.load_game()
	# Verify chimera has a head part (reconstructed from save by reference)
	assert_eq(GameState.roster.size(), 3, "roster should have 3 chimeras")
	assert_not_null(GameState.roster[0].head, "head should be equipped after load")
	assert_eq(GameState.roster[0].attack, new_attack, "attack should match post-equip value")


# --- Instability changes on part swap ---


func test_instability_changes_when_swapping_to_different_strain() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var instability_before := chimera.instability
	# Generate a part with a different strain (force UNDEAD)
	var new_head := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	# Override strain to ensure it's different from existing
	new_head.strain = GameEnums.Strain.ABERRANT
	chimera.head = new_head
	chimera.calculate_instability()
	# Instability should reflect the new strain diversity
	var instability_after := chimera.instability
	# Instability should change when swapping to a different strain.
	# ABERRANT strain in head slot changes the strain composition.
	assert_ne(
		instability_after,
		instability_before,
		"instability should change when swapping to a different strain"
	)


func test_purebred_chimera_has_zero_instability() -> void:
	# Create a purebred chimera (all parts same strain)
	var chimera := ChimeraData.new()
	chimera.nickname = "Purebred"
	# Get 4 parts of the same strain
	var head := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	var torso := PartDatabase.generate_random_part(
		GameEnums.PartSlot.TORSO, {GameEnums.Rarity.COMMON: 100}
	)
	var arms := PartDatabase.generate_random_part(
		GameEnums.PartSlot.ARMS, {GameEnums.Rarity.COMMON: 100}
	)
	var legs := PartDatabase.generate_random_part(
		GameEnums.PartSlot.LEGS, {GameEnums.Rarity.COMMON: 100}
	)
	# Force all to same strain
	head.strain = GameEnums.Strain.UNDEAD
	torso.strain = GameEnums.Strain.UNDEAD
	arms.strain = GameEnums.Strain.UNDEAD
	legs.strain = GameEnums.Strain.UNDEAD
	chimera.head = head
	chimera.torso = torso
	chimera.arms = arms
	chimera.legs = legs
	chimera.calculate_instability()
	assert_eq(chimera.instability, 0, "purebred should have 0 instability")
	assert_eq(chimera.strain_count, 1, "should have 1 strain")
	# Purebred gets stat multiplier
	chimera.recalculate_stats()
	var expected_hp := (head.hp_bonus + torso.hp_bonus + arms.hp_bonus + legs.hp_bonus) * 1.2
	assert_eq(chimera.max_hp, expected_hp, "purebred should get 1.2x stat multiplier")


# --- Combo ability lookup ---


func test_combo_ability_found_for_two_matching_strains() -> void:
	var chimera := ChimeraData.new()
	var head := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	var torso := PartDatabase.generate_random_part(
		GameEnums.PartSlot.TORSO, {GameEnums.Rarity.COMMON: 100}
	)
	var arms := PartDatabase.generate_random_part(
		GameEnums.PartSlot.ARMS, {GameEnums.Rarity.COMMON: 100}
	)
	var legs := PartDatabase.generate_random_part(
		GameEnums.PartSlot.LEGS, {GameEnums.Rarity.COMMON: 100}
	)
	# Set 2 parts to UNDEAD, 2 to BEAST
	head.strain = GameEnums.Strain.UNDEAD
	torso.strain = GameEnums.Strain.UNDEAD
	arms.strain = GameEnums.Strain.BEAST
	legs.strain = GameEnums.Strain.BEAST
	chimera.head = head
	chimera.torso = torso
	chimera.arms = arms
	chimera.legs = legs
	chimera.calculate_instability()
	var combo := chimera.get_combo_ability()
	# Should have a combo (2 parts share dominant strain)
	assert_not_null(combo, "should have combo ability with 2 matching strains")
	assert_eq(chimera.combo_tier, 1, "combo tier should be 1 (2 matching)")


func test_no_combo_when_all_different_strains() -> void:
	var chimera := ChimeraData.new()
	var head := PartDatabase.generate_random_part(
		GameEnums.PartSlot.HEAD, {GameEnums.Rarity.COMMON: 100}
	)
	var torso := PartDatabase.generate_random_part(
		GameEnums.PartSlot.TORSO, {GameEnums.Rarity.COMMON: 100}
	)
	var arms := PartDatabase.generate_random_part(
		GameEnums.PartSlot.ARMS, {GameEnums.Rarity.COMMON: 100}
	)
	var legs := PartDatabase.generate_random_part(
		GameEnums.PartSlot.LEGS, {GameEnums.Rarity.COMMON: 100}
	)
	# All different strains
	head.strain = GameEnums.Strain.UNDEAD
	torso.strain = GameEnums.Strain.ROBOTIC
	arms.strain = GameEnums.Strain.DRACONIC
	legs.strain = GameEnums.Strain.BEAST
	chimera.head = head
	chimera.torso = torso
	chimera.arms = arms
	chimera.legs = legs
	chimera.calculate_instability()
	var combo := chimera.get_combo_ability()
	assert_null(combo, "should have no combo with all different strains")
	assert_eq(chimera.combo_tier, 0, "combo tier should be 0")


# --- Full assembly flow: buy -> equip -> save -> load ---


func test_buy_equip_and_save_round_trip() -> void:
	_setup_roster()
	GameState.gold = 5000
	GameState.infamy = 50
	# Buy a part from generated market stock
	GameState.market_stock = Market.generate_initial_stock()
	var base_stock: Array = GameState.market_stock["base"]
	assert_true(base_stock.size() > 0, "market should have stock")
	var purchased_part: PartData = base_stock[0]
	var buy_result: bool = GameState.buy_part(purchased_part)
	assert_true(buy_result, "purchase should succeed")
	assert_eq(GameState.inventory.size(), 1, "part should be in inventory")
	# Equip the purchased part on a chimera
	var chimera := GameState.roster[0]
	var old_part := chimera.head
	chimera.head = purchased_part
	chimera.calculate_instability()
	chimera.recalculate_stats()
	var attack_after_equip := chimera.attack
	# Save (replace_chimera triggers save)
	GameState.replace_chimera(0, chimera)
	# Clear and reload
	GameState.roster = []
	GameState.inventory = []
	SaveManager.load_game()
	# Verify chimera has the equipped part
	assert_eq(GameState.roster.size(), 3, "roster should be restored")
	assert_not_null(GameState.roster[0].head, "equipped head should persist")
	assert_eq(GameState.roster[0].attack, attack_after_equip, "attack should match")


# --- Research bonuses apply to assembly ---


func test_research_bonuses_apply_to_chimera_stats() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	# Get baseline stats
	chimera.calculate_instability()
	chimera.recalculate_stats()
	var base_attack := chimera.attack
	# Apply research bonuses
	chimera.recalculate_stats({"attack": 1.5})
	assert_eq(chimera.attack, base_attack * 1.5, "attack should get 1.5x research bonus")
