extends GutTest

## Tests for ActiveEffect (FR-8).
## Verifies duration ticking and expiry detection.


func test_tick_decrements_duration() -> void:
	var effect := ActiveEffect.new()
	effect.duration = 5.0
	effect.tick(2.0)
	assert_eq(effect.duration, 3.0, "tick should decrement duration by delta")


func test_tick_returns_false_when_not_expired() -> void:
	var effect := ActiveEffect.new()
	effect.duration = 5.0
	var expired: bool = effect.tick(2.0)
	assert_false(expired, "tick should return false when duration > 0")


func test_tick_returns_true_when_expired() -> void:
	var effect := ActiveEffect.new()
	effect.duration = 3.0
	var expired: bool = effect.tick(3.0)
	assert_true(expired, "tick should return true when duration reaches 0")


func test_tick_returns_true_when_duration_goes_negative() -> void:
	var effect := ActiveEffect.new()
	effect.duration = 2.0
	var expired: bool = effect.tick(5.0)
	assert_true(expired, "tick should return true when duration goes below 0")


func test_tick_with_zero_duration() -> void:
	var effect := ActiveEffect.new()
	effect.duration = 0.0
	var expired: bool = effect.tick(1.0)
	assert_true(expired, "tick should return true when starting at 0 duration")
