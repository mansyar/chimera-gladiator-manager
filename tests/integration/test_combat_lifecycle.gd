## Integration tests for the combat lifecycle:
## start_match -> entity placement -> AI/combat execution -> end_match -> rewards -> save.
##
## NOTE: Full combat (AI, entity placement, abilities) is not yet implemented
## (comes in TRACK-005+). These tests cover the available combat-related systems:
## CombatState initialization, damage/heal, match rewards, and save persistence.
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
	var starters := PartDatabase.get_starter_chimeras()
	GameState.roster = []
	for starter in starters:
		var dup := starter.duplicate()
		dup.calculate_instability()
		dup.recalculate_stats()
		GameState.roster.append(dup)


# --- CombatState initialization (simulates match start) ---


func test_combat_state_initializes_from_chimera_data() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var combat_state := CombatState.new()
	combat_state.initialize(chimera, 0)
	assert_eq(combat_state.max_hp, chimera.max_hp, "max_hp should snapshot from ChimeraData")
	assert_eq(combat_state.attack, chimera.attack, "attack should snapshot from ChimeraData")
	assert_eq(combat_state.defense, chimera.defense, "defense should snapshot from ChimeraData")
	assert_eq(combat_state.speed, chimera.speed, "speed should snapshot from ChimeraData")
	assert_eq(combat_state.current_hp, chimera.max_hp, "current_hp should start at max_hp")
	assert_eq(combat_state.team, 0, "team should be set")
	assert_false(combat_state.is_dead, "should not be dead at start")


# --- Damage and healing (simulates combat execution) ---


func test_take_damage_reduces_hp_and_can_kill() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var combat_state := CombatState.new()
	combat_state.initialize(chimera, 0)
	var hp_before := combat_state.current_hp
	combat_state.take_damage(10.0)
	assert_lt(combat_state.current_hp, hp_before, "HP should decrease after damage")
	assert_false(combat_state.is_dead, "should not be dead from partial damage")
	# Lethal damage
	combat_state.take_damage(combat_state.current_hp)
	assert_eq(combat_state.current_hp, 0.0, "HP should be 0 after lethal damage")
	assert_true(combat_state.is_dead, "should be dead after lethal damage")


func test_heal_restores_hp_capped_at_max() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var combat_state := CombatState.new()
	combat_state.initialize(chimera, 0)
	combat_state.take_damage(20.0)
	var hp_after_damage := combat_state.current_hp
	combat_state.heal(10.0)
	assert_gt(combat_state.current_hp, hp_after_damage, "HP should increase after heal")
	# Overheal should cap at max_hp
	combat_state.heal(999.0)
	assert_eq(combat_state.current_hp, combat_state.max_hp, "HP should cap at max_hp")


func test_damage_does_not_go_negative() -> void:
	_setup_roster()
	var chimera := GameState.roster[0]
	var combat_state := CombatState.new()
	combat_state.initialize(chimera, 0)
	combat_state.take_damage(combat_state.max_hp + 100.0)
	assert_eq(combat_state.current_hp, 0.0, "HP should not go below 0")
	assert_true(combat_state.is_dead, "should be dead from overkill damage")


# --- Match rewards flow (simulates end_match -> rewards -> save) ---


func test_regular_win_rewards_flow_to_game_state_and_save() -> void:
	_setup_roster()
	GameState.gold = 0
	GameState.infamy = 0
	# Simulate end of match: player won a regular match
	var reward := Economy.calculate_match_reward("regular", true, 1, 0)
	GameState.add_gold(reward["gold"])
	GameState.add_infamy(reward["infamy"])
	# Record match history
	GameState.match_history.append({"result": "win", "gold": reward["gold"]})
	# Save
	SaveManager.save_game()
	assert_true(SaveManager.has_save(), "save should exist after match")
	# Clear and reload
	GameState.gold = 0
	GameState.infamy = 0
	GameState.match_history = []
	SaveManager.load_game()
	assert_eq(GameState.gold, reward["gold"], "gold should be preserved from rewards")
	assert_eq(GameState.infamy, reward["infamy"], "infamy should be preserved from rewards")
	assert_eq(GameState.match_history.size(), 1, "match history should have 1 entry")
	assert_eq(GameState.match_history[0]["result"], "win", "match result should be 'win'")


func test_tournament_win_rewards_scale_with_tier() -> void:
	_setup_roster()
	GameState.gold = 0
	GameState.infamy = 0
	# Simulate tournament win at tier 3
	var reward := Economy.calculate_match_reward("tournament", true, 3, 0)
	GameState.add_gold(reward["gold"])
	GameState.add_infamy(reward["infamy"])
	# Tournament tier 3: multiplier 4, base gold 50 -> 200 gold, base infamy 10 -> 40
	assert_eq(reward["gold"], 200, "tier 3 tournament win should give 200 gold")
	assert_eq(reward["infamy"], 40, "tier 3 tournament win should give 40 infamy")
	# Save and verify persistence
	SaveManager.save_game()
	GameState.gold = 0
	GameState.infamy = 0
	SaveManager.load_game()
	assert_eq(GameState.gold, 200, "gold should persist from tournament rewards")
	assert_eq(GameState.infamy, 40, "infamy should persist from tournament rewards")


func test_loss_gives_consolation_reward() -> void:
	GameState.gold = 0
	GameState.infamy = 0
	var reward := Economy.calculate_match_reward("regular", false, 1, 0)
	GameState.add_gold(reward["gold"])
	GameState.add_infamy(reward["infamy"])
	# Regular loss: 10 gold, 0 infamy
	assert_eq(GameState.gold, 10, "loss should give 10 gold consolation")
	assert_eq(GameState.infamy, 0, "loss should give 0 infamy")


# --- Full lifecycle: init -> damage -> heal -> end -> rewards -> save ---


func test_full_combat_lifecycle_to_rewards() -> void:
	_setup_roster()
	GameState.gold = 0
	GameState.infamy = 0
	var chimera := GameState.roster[0]
	# 1. Initialize combat state (start_match)
	var combat_state := CombatState.new()
	combat_state.initialize(chimera, 0)
	# 2. Simulate combat: take damage, heal, take more damage
	combat_state.take_damage(15.0)
	combat_state.heal(5.0)
	var hp_mid_combat := combat_state.current_hp
	assert_gt(hp_mid_combat, 0.0, "should still be alive")
	# 3. End match: player won
	var won := !combat_state.is_dead
	var reward := Economy.calculate_match_reward("regular", won, 1, 0)
	GameState.add_gold(reward["gold"])
	GameState.add_infamy(reward["infamy"])
	GameState.match_history.append({"result": "win" if won else "loss"})
	# 4. Save
	SaveManager.save_game()
	assert_true(SaveManager.has_save(), "save should exist after match")
	# 5. Load and verify
	GameState.gold = 0
	GameState.infamy = 0
	GameState.match_history = []
	SaveManager.load_game()
	assert_eq(GameState.gold, reward["gold"], "gold should match reward")
	assert_eq(GameState.match_history.size(), 1, "match history should have 1 entry")
