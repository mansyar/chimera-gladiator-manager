# gdlint:ignore=max-public-methods
## Tests for SaveManager autoload.
extends GutTest

# --- load_game ---


func test_load_game_returns_false_when_no_save() -> void:
	assert_false(SaveManager.load_game())
