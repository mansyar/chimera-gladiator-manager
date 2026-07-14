# gdlint:ignore=max-public-methods
## Tests for Market static utility (TRACK-004).
extends GutTest

# --- Helper ---


static func _make_part(rarity: GameEnums.Rarity) -> PartData:
	var part := PartData.new()
	part.rarity = rarity
	part.shape_id = "body_a"
	part.strain = GameEnums.Strain.BEAST
	part.slot = GameEnums.PartSlot.TORSO
	return part


# --- validate_purchase() tests ---


func test_validate_purchase_sufficient_gold() -> void:
	var part := _make_part(GameEnums.Rarity.COMMON)
	var result := Market.validate_purchase(part, 200, 0)
	assert_true(result["valid"], "Should be valid with sufficient gold")
	assert_eq(result["reason"], "", "Reason should be empty on valid purchase")


func test_validate_purchase_insufficient_gold() -> void:
	var part := _make_part(GameEnums.Rarity.COMMON)
	var result := Market.validate_purchase(part, 10, 0)
	assert_false(result["valid"], "Should be invalid with insufficient gold")
	assert_true(result["reason"].length() > 0, "Reason should explain failure")


func test_validate_purchase_returns_price() -> void:
	var part := _make_part(GameEnums.Rarity.COMMON)
	var result := Market.validate_purchase(part, 500, 0)
	assert_true(result.has("price"), "Result should include price key")
	assert_true(result["price"] >= 50, "Price should be >= 50 for Common")
	assert_true(result["price"] <= 100, "Price should be <= 100 for Common")


func test_validate_purchase_legendary_with_sufficient_infamy() -> void:
	var part := _make_part(GameEnums.Rarity.LEGENDARY)
	var result := Market.validate_purchase(part, 5000, 50)
	assert_true(result["valid"], "Legendary should be valid with infamy >= 50")


func test_validate_purchase_legendary_with_insufficient_infamy() -> void:
	var part := _make_part(GameEnums.Rarity.LEGENDARY)
	var result := Market.validate_purchase(part, 5000, 49)
	assert_false(result["valid"], "Legendary should be invalid with infamy < 50")
	assert_true(result["reason"].length() > 0, "Reason should explain infamy gate")


func test_validate_purchase_legendary_exact_infamy_threshold() -> void:
	var part := _make_part(GameEnums.Rarity.LEGENDARY)
	var result := Market.validate_purchase(part, 5000, 50)
	assert_true(result["valid"], "Legendary should be valid at exactly 50 infamy")


# --- calculate_price() tests ---


func test_calculate_price_common_in_range() -> void:
	var part := _make_part(GameEnums.Rarity.COMMON)
	for i in range(10):
		var price := Market.calculate_price(part)
		assert_true(price >= 50, "Common price should be >= 50 (got %d)" % price)
		assert_true(price <= 100, "Common price should be <= 100 (got %d)" % price)


func test_calculate_price_uncommon_in_range() -> void:
	var part := _make_part(GameEnums.Rarity.UNCOMMON)
	for i in range(10):
		var price := Market.calculate_price(part)
		assert_true(price >= 150, "Uncommon price should be >= 150 (got %d)" % price)
		assert_true(price <= 300, "Uncommon price should be <= 300 (got %d)" % price)


func test_calculate_price_rare_in_range() -> void:
	var part := _make_part(GameEnums.Rarity.RARE)
	for i in range(10):
		var price := Market.calculate_price(part)
		assert_true(price >= 500, "Rare price should be >= 500 (got %d)" % price)
		assert_true(price <= 1000, "Rare price should be <= 1000 (got %d)" % price)


func test_calculate_price_legendary_in_range() -> void:
	var part := _make_part(GameEnums.Rarity.LEGENDARY)
	for i in range(10):
		var price := Market.calculate_price(part)
		assert_true(price >= 1500, "Legendary price should be >= 1500 (got %d)" % price)
		assert_true(price <= 3000, "Legendary price should be <= 3000 (got %d)" % price)


# --- generate_initial_stock() tests ---


func test_generate_initial_stock_returns_dict_with_base_and_rotating() -> void:
	var stock := Market.generate_initial_stock()
	assert_true(stock.has("base"), "Should have 'base' key")
	assert_true(stock.has("rotating"), "Should have 'rotating' key")


func test_generate_initial_stock_base_has_24_parts() -> void:
	var stock := Market.generate_initial_stock()
	var base: Array = stock["base"]
	assert_eq(base.size(), 24, "Base stock should have 24 parts (4 slots x 6 strains)")


func test_generate_initial_stock_base_all_common() -> void:
	var stock := Market.generate_initial_stock()
	var base: Array = stock["base"]
	for part in base:
		assert_eq(part.rarity, GameEnums.Rarity.COMMON, "All base parts should be Common rarity")


func test_generate_initial_stock_rotating_has_6_to_10_parts() -> void:
	var stock := Market.generate_initial_stock()
	var rotating: Array = stock["rotating"]
	assert_true(rotating.size() >= 6, "Rotating stock should have >= 6 parts")
	assert_true(rotating.size() <= 10, "Rotating stock should have <= 10 parts")


# --- generate_rotating_stock() tests ---


func test_generate_rotating_stock_returns_6_to_10_parts() -> void:
	var parts := Market.generate_rotating_stock()
	assert_true(parts.size() >= 6, "Rotating stock should have >= 6 parts")
	assert_true(parts.size() <= 10, "Rotating stock should have <= 10 parts")


func test_generate_rotating_stock_parts_are_valid() -> void:
	var parts := Market.generate_rotating_stock()
	for part in parts:
		assert_not_null(part, "Each part should not be null")
		assert_true(part is PartData, "Each item should be PartData")


# --- apply_market_connections_discount() tests ---


func test_apply_market_connections_discount_level_0_no_discount() -> void:
	var discounted := Market.apply_market_connections_discount(100, 0)
	assert_eq(discounted, 100, "Level 0 should have no discount")


func test_apply_market_connections_discount_level_1_15_percent_off() -> void:
	var discounted := Market.apply_market_connections_discount(100, 1)
	assert_eq(discounted, 85, "Level 1 should give 15% discount (100 -> 85)")


func test_apply_market_connections_discount_level_2_30_percent_off() -> void:
	var discounted := Market.apply_market_connections_discount(100, 2)
	assert_eq(discounted, 70, "Level 2 should give 30% discount (100 -> 70)")


func test_apply_market_connections_discount_capped_at_level_2() -> void:
	var discounted := Market.apply_market_connections_discount(100, 5)
	assert_eq(discounted, 70, "Discount should cap at level 2 (30% off)")


func test_validate_purchase_legendary_infamy_takes_priority_over_gold() -> void:
	var part := _make_part(GameEnums.Rarity.LEGENDARY)
	var result := Market.validate_purchase(part, 10, 0)
	assert_false(result["valid"], "Should be invalid when both infamy and gold are insufficient")
	assert_true(
		result["reason"].find("infamy") >= 0, "Infamy check should take priority over gold check"
	)
