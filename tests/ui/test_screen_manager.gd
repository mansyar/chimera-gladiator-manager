## Tests for ScreenManager screen loading and transition logic.
extends GutTest
# gdlint:ignore=max-public-methods

const SCREEN_NAMES := [
	"lab_hub",
	"assembly",
	"black_market",
	"arena_pre_match",
	"arena_combat",
	"roster",
	"clinic",
	"tournament",
	"hall_of_fame",
]


func test_screens_dictionary_has_9_entries() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	assert_eq(sm.screens.size(), 9)


func test_screens_dictionary_contains_all_screen_names() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	for screen_name in SCREEN_NAMES:
		assert_true(sm.screens.has(screen_name), "Expected screens to contain '%s'" % screen_name)


func test_screens_dictionary_values_are_packed_scenes() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	for screen_name in SCREEN_NAMES:
		assert_true(
			sm.screens[screen_name] is PackedScene,
			"Expected screens['%s'] to be a PackedScene" % screen_name
		)


func test_initial_screen_is_lab_hub() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is LabHubScreen)


func test_change_screen_loads_lab_hub() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("lab_hub")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is LabHubScreen)


func test_change_screen_loads_assembly() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("assembly")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is AssemblyScreen)


func test_change_screen_loads_black_market() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("black_market")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is BlackMarketScreen)


func test_change_screen_loads_arena_pre_match() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("arena_pre_match")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is ArenaPreMatchScreen)


func test_change_screen_loads_arena_combat() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("arena_combat")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is ArenaCombatScreen)


func test_change_screen_loads_roster() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("roster")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is RosterScreen)


func test_change_screen_loads_clinic() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("clinic")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is ClinicScreen)


func test_change_screen_loads_tournament() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("tournament")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is TournamentScreen)


func test_change_screen_loads_hall_of_fame() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	sm.change_screen("hall_of_fame")
	assert_not_null(sm.current_screen)
	assert_true(sm.current_screen is HallOfFameScreen)


func test_change_screen_frees_previous_screen() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	var initial := sm.current_screen
	sm.change_screen("assembly")
	assert_true(initial.is_queued_for_deletion())


func test_change_screen_emits_signal() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	watch_signals(EventBus)
	sm.change_screen("assembly")
	assert_signal_emitted(EventBus, "screen_change_requested")


func test_change_screen_invalid_name_does_nothing() -> void:
	var sm: ScreenManager = add_child_autofree(ScreenManager.new())
	var initial := sm.current_screen
	sm.change_screen("invalid_screen")
	assert_eq(sm.current_screen, initial)
