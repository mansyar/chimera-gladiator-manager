# gdlint:ignore=max-public-methods
extends GutTest

## Tests for CombatManager autoload stub (TRACK-004).
##
## Verifies the stub has match_active defaulting to false
## and _process() returns early when inactive.

# --- Property tests ---


func test_match_active_defaults_false() -> void:
	assert_false(CombatManager.match_active, "match_active should default to false")


func test_match_active_can_be_set_true() -> void:
	CombatManager.match_active = true
	assert_true(CombatManager.match_active, "match_active should be settable to true")
	# Reset to default
	CombatManager.match_active = false


# --- _process tests ---


func test_process_does_not_crash_when_inactive() -> void:
	CombatManager.match_active = false
	CombatManager._process(0.016)
	assert_false(CombatManager.match_active, "Should remain inactive after _process")


func test_process_does_not_crash_when_active() -> void:
	CombatManager.match_active = true
	CombatManager._process(0.016)
	assert_true(CombatManager.match_active, "Should remain active after _process")
	# Reset to default
	CombatManager.match_active = false
