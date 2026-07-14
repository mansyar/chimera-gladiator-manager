# gdlint:ignore=max-public-methods
## Edge case tests for berserk state in CombatState.
##
## NOTE: Full berserk logic (trigger conditions, processing, duration
## countdown, modifier accumulation/reset) is NOT yet implemented.
## CombatState currently has berserk state FIELDS only (is_berserk,
## berserk_timer, berserk_check_timer, berserk_modifiers) — the actual
## trigger/processing methods will be added in TRACK-005 (Combat).
##
## These tests verify the available state fields and document expected
## behavior for when the berserk system is implemented.
extends GutTest

const PART_HP := 100.0
const PART_ATTACK := 50.0
const PART_DEFENSE := 30.0
const PART_SPEED := 20.0
const PART_RANGE := 32.0


func _make_part(strain: GameEnums.Strain, slot: GameEnums.PartSlot) -> PartData:
	var part := PartData.new()
	part.slot = slot
	part.strain = strain
	part.rarity = GameEnums.Rarity.COMMON
	part.hp_bonus = PART_HP
	part.attack_bonus = PART_ATTACK
	part.defense_bonus = PART_DEFENSE
	part.speed_bonus = PART_SPEED
	part.attack_range = PART_RANGE
	return part


func _make_chimera(strains: Array) -> ChimeraData:
	var chimera := ChimeraData.new()
	var slots: Array[GameEnums.PartSlot] = [
		GameEnums.PartSlot.HEAD,
		GameEnums.PartSlot.TORSO,
		GameEnums.PartSlot.ARMS,
		GameEnums.PartSlot.LEGS,
	]
	chimera.head = _make_part(strains[0], slots[0])
	chimera.torso = _make_part(strains[1], slots[1])
	chimera.arms = _make_part(strains[2], slots[2])
	chimera.legs = _make_part(strains[3], slots[3])
	chimera.calculate_instability()
	chimera.recalculate_stats()
	return chimera


func _make_pure_chimera() -> ChimeraData:
	var s := GameEnums.Strain.BEAST
	return _make_chimera([s, s, s, s])


func _make_chaotic_chimera() -> ChimeraData:
	return _make_chimera(
		[
			GameEnums.Strain.BEAST,
			GameEnums.Strain.DRACONIC,
			GameEnums.Strain.ELEMENTAL,
			GameEnums.Strain.UNDEAD,
		]
	)


# --- Default berserk state ---


func test_berserk_state_defaults_after_initialize() -> void:
	var chimera := _make_pure_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	assert_false(state.is_berserk, "is_berserk should default to false")
	assert_eq(state.berserk_timer, 0.0, "berserk_timer should default to 0.0")
	assert_eq(state.berserk_check_timer, 0.0, "berserk_check_timer should default to 0.0")
	assert_eq(state.berserk_modifiers.size(), 0, "berserk_modifiers should be empty")


# --- Purebred immunity ---


func test_purebred_has_zero_instability() -> void:
	## Purebreds (all parts same strain) have instability=0, which
	## will prevent berserk triggering once the logic is implemented.
	var chimera := _make_pure_chimera()
	assert_eq(chimera.instability, 0, "Purebred should have instability 0")


func test_purebred_combat_state_has_no_berserk_risk() -> void:
	## A purebred chimera entering combat should not be at risk of berserk.
	## Once berserk logic is implemented, instability=0 should prevent triggering.
	var chimera := _make_pure_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	assert_eq(chimera.instability, 0, "Purebred should have instability 0")
	assert_false(state.is_berserk, "Should not be berserk on initialization")


# --- Berserk modifier accumulation and reset (state simulation) ---


func test_berserk_modifiers_can_accumulate() -> void:
	## Simulates modifier accumulation: berserk_modifiers is a Dictionary
	## that will hold stat modifiers when berserk is active.
	## Full accumulation logic (from events) is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_modifiers = {"attack": 1.5, "speed": 1.3}
	assert_eq(state.berserk_modifiers["attack"], 1.5)
	assert_eq(state.berserk_modifiers["speed"], 1.3)


func test_berserk_modifiers_can_be_reset() -> void:
	## Simulates modifier reset: clearing berserk_modifiers back to empty.
	## Full reset logic (on berserk expiry) is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_modifiers = {"attack": 1.5, "speed": 1.3}
	state.berserk_modifiers.clear()
	assert_eq(state.berserk_modifiers.size(), 0, "Modifiers should be cleared")


# --- 5s duration transition (state simulation) ---


func test_berserk_timer_can_be_set() -> void:
	## Simulates setting the berserk duration timer.
	## Full trigger logic (setting timer on berserk start) is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_timer = 5.0
	assert_eq(state.berserk_timer, 5.0, "berserk_timer should be set to 5.0")


func test_berserk_timer_can_be_decremented() -> void:
	## Simulates the 5s duration countdown.
	## Full tick logic (decrementing in _process or combat tick) is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_timer = 5.0
	# Simulate 3 seconds of ticking
	state.berserk_timer -= 3.0
	assert_almost_eq(state.berserk_timer, 2.0, 0.01, "Timer should be at 2.0s after 3s tick")


func test_berserk_timer_reaches_zero() -> void:
	## Simulates berserk expiry: timer reaches 0.0.
	## Full expiry logic (clearing is_berserk, resetting modifiers) is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_timer = 5.0
	state.berserk_timer -= 5.0
	assert_almost_eq(state.berserk_timer, 0.0, 0.01, "Timer should be at 0.0 after 5s tick")


# --- Berserk check timer ---


func test_berserk_check_timer_defaults_to_zero() -> void:
	var chimera := _make_pure_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	assert_eq(state.berserk_check_timer, 0.0)


func test_berserk_check_timer_can_track_interval() -> void:
	## berserk_check_timer will be used to throttle berserk trigger checks
	## (e.g., check every 1s instead of every frame).
	## Full check interval logic is TRACK-005+.
	var chimera := _make_chaotic_chimera()
	var state := CombatState.new()
	state.initialize(chimera, 0)
	state.berserk_check_timer = 1.0
	state.berserk_check_timer -= 0.5
	assert_almost_eq(state.berserk_check_timer, 0.5, 0.01)
