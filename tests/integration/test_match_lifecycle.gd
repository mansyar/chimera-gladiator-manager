# gdlint:ignore=max-public-methods
extends GutTest

## Integration tests for the full match lifecycle via CombatManager.
##
## Verifies that start_match -> combat resolution -> end_match correctly
## integrates with Economy (rewards), GameState (gold/infamy/history),
## SaveManager (persistence), and EventBus (signals).


func before_each() -> void:
	_reset_game_state()
	_reset_combat_manager()


func after_each() -> void:
	_reset_combat_manager()
	_reset_game_state()
	SaveManager.delete_save()


func _reset_game_state() -> void:
	GameState.gold = 200
	GameState.infamy = 0
	GameState.match_history.clear()
	GameState.losing_streak = 0


func _reset_combat_manager() -> void:
	CombatManager.match_active = false
	CombatManager.combat_entities.clear()
	CombatManager.combat_context = null
	CombatManager.player_formation.clear()
	CombatManager.enemy_formation.clear()
	CombatManager.timer = 0.0
	CombatManager.match_result = {}
	CombatManager.match_type = ""
	CombatManager.tournament_tier = 0
	for child in CombatManager.get_children():
		CombatManager.remove_child(child)
		child.free()


func _setup_roster() -> Array[ChimeraData]:
	var starters := PartDatabase.get_starter_chimeras()
	var roster: Array[ChimeraData] = []
	for starter in starters:
		var dup := starter.duplicate()
		dup.calculate_instability()
		dup.recalculate_stats()
		roster.append(dup)
	return roster


func _setup_formations() -> Array:
	return [
		[Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 2)],
		[Vector2i(0, 2), Vector2i(1, 1), Vector2i(2, 0)],
	]


func _kill_team(team_id: int) -> void:
	for entity in CombatManager.combat_entities:
		if entity.combat_state.team == team_id:
			entity.combat_state.is_dead = true


func _revive_team(team_id: int) -> void:
	for entity in CombatManager.combat_entities:
		if entity.combat_state.team == team_id:
			entity.combat_state.is_dead = false
			entity.combat_state.current_hp = entity.combat_state.max_hp


func _start_match(match_type: String = "regular", tier: int = 0) -> void:
	var player_roster := _setup_roster()
	var enemy_roster := _setup_roster()
	var formations := _setup_formations()
	CombatManager.start_match(player_roster, enemy_roster, formations, match_type, tier)


# --- Complete match flow: player win ---


func test_complete_match_flow_player_win() -> void:
	GameState.losing_streak = 3
	_start_match("regular", 0)
	_revive_team(0)
	_kill_team(1)
	watch_signals(EventBus)
	CombatManager.check_win_condition()
	# CombatManager should be idle
	assert_false(CombatManager.match_active, "Match should be inactive after end")
	assert_eq(CombatManager.combat_entities.size(), 0, "Entities should be cleared")
	# Rewards applied to GameState
	assert_eq(GameState.gold, 230, "Gold should be 200 + 30 (regular win reward)")
	assert_eq(GameState.infamy, 2, "Infamy should be 2 (regular win reward)")
	assert_eq(GameState.losing_streak, 0, "Losing streak should reset on win")
	# Match history recorded
	assert_eq(GameState.match_history.size(), 1, "match_history should have 1 entry")
	# Market refreshed and save triggered
	assert_signal_emitted(EventBus, "market_refreshed", "Market should refresh after match")
	assert_true(SaveManager.has_save(), "Save should exist after match")


# --- Player-loss scenario ---


func test_player_loss_scenario() -> void:
	GameState.losing_streak = 0
	_start_match("regular", 0)
	_revive_team(1)
	_kill_team(0)
	CombatManager.check_win_condition()
	# Consolation rewards (regular loss: 10 gold, 0 infamy)
	assert_eq(GameState.gold, 210, "Gold should be 200 + 10 (regular loss consolation)")
	assert_eq(GameState.infamy, 0, "Infamy should be 0 on loss")
	assert_eq(GameState.losing_streak, 1, "Losing streak should increment on loss")
	assert_eq(
		CombatManager.match_result.get("won", true), false, "Result should record player loss"
	)


# --- Timer expiry scenario ---


func test_timer_expiry_determines_winner_by_hp() -> void:
	_start_match("regular", 0)
	# Set player team to full HP, enemy team to half HP
	for entity in CombatManager.combat_entities:
		if entity.combat_state.team == 0:
			entity.combat_state.is_dead = false
			entity.combat_state.current_hp = entity.combat_state.max_hp
		else:
			entity.combat_state.is_dead = false
			entity.combat_state.current_hp = entity.combat_state.max_hp * 0.5
	CombatManager._on_timer_expired()
	assert_eq(
		CombatManager.match_result.get("winner", -1),
		0,
		"Player should win on timer expiry with higher HP%"
	)
	assert_true(
		CombatManager.match_result.get("won", false),
		"won should be true when player wins on timer expiry"
	)
