# Product Guidelines

## Code Style

### Language & Formatting
- **Language:** GDScript (Godot 4.5+)
- **Formatter:** gdformat (enforced via `gd-tools format --check`)
- **Linter:** gdlint (enforced via `gd-tools lint`)
- No manual formatting — gdformat is the source of truth for style

### Naming Conventions
- **Files:** snake_case (e.g., `game_state.gd`, `combat_state.gd`)
- **Classes:** PascalCase with `class_name` declaration (e.g., `class_name GameState`)
- **Variables/Functions:** snake_case (e.g., `current_hp`, `take_damage()`)
- **Constants:** SCREAMING_SNAKE_CASE (e.g., `ATTACK_RATE_CONSTANT`)
- **Enums:** PascalCase enum names, SCREAMING_SNAKE_CASE values (e.g., `Strain.UNDEAD`)

### Strict Typing (Enforced)
- All variables must have explicit types: `var current_hp: float = 0.0`
- All function parameters must be typed: `func take_damage(amount: float) -> void:`
- All return types must be declared: `func get_part(slot: GameEnums.PartSlot) -> PartData:`
- Typed arrays: `var roster: Array[ChimeraData] = []`
- No untyped variables or dynamic typing unless explicitly required by Godot API

### Documentation
- Use `##` doc comments above all public functions, classes, and exported variables
- Godot's built-in documentation system parses these for the inspector and docs
- Example:
  ```gdscript
  ## Calculates genetic instability from equipped parts.
  ## Returns 0 (Pure) to 3 (Chaotic) based on distinct strain count.
  func calculate_instability() -> int:
  ```

## Architecture Patterns

### Established Conventions (from AGENTS.md)
- **ChimeraData vs CombatState:** ChimeraData is persistent (campaign state). CombatState is transient (created/destroyed per match). Never mix.
- **Part slots:** Use 4 separate `@export var` (head/torso/arms/legs). Do NOT use typed Dictionary exports.
- **PartData abilities:** Parts reference abilities by `ability_id: String` (looked up via PartDatabase). Do NOT embed AbilityData in PartData.
- **Movement:** `velocity = direction * speed` then `move_and_slide()`. Do NOT multiply by delta.
- **Autoload order:** EventBus -> GameState -> SaveManager -> CombatManager.
- **System scripts:** Static utility classes with pure functions — no state. GameState calls them and stores results.
- **Signals:** EventBus for global cross-system. Direct signals for local parent-child.
- **Saves:** JSON at `user://saves/`. Parts saved by reference (shape_id + strain + rarity).

### File Organization
- Scripts in `scripts/` with subdirectories matching TDD Section 2
- Scenes in `scenes/` mirroring script structure
- Data resources (.tres) in `resources/`
- Tests in `tests/` mirroring `scripts/` structure
- Assets in `assets/` (read-only — never modify Kenney pack contents)

## UI/UX Design

### Visual Direction: Dark-Science Lab Aesthetic
- Dark UI panels with strain-colored accents
- Clinical/mechanical feel matching the monster lab theme
- Kenney UI Pack assets as base, themed with strain color palette
- Strain-to-color mapping (fixed): Undead=dark/Grey, Robotic=white/Grey, Draconic=red/Red, Beast=green/Green, Elemental=blue/Blue, Aberrant=yellow/Yellow

### Pixel Art Standards
- Texture filtering: Nearest (no smoothing)
- Snap 2D transforms to pixel: Enabled
- Compression: Lossless
- Mipmaps: Off
- Stretch mode: canvas_items with aspect keep

### UI Principles
- Clarity over decoration: stats, prices, and combat info must be readable
- Strain color coding for instant visual identification
- ChimeraSprite composition: 8 layers with correct z-order (Body=0 through Eyebrows=7)
- Kenney Future font as default

## Testing Standards

### Coverage Requirement
- Minimum 80% test coverage enforced via `gd-tools test --coverage --min 80`
- Verification order per track DoD: `gd-tools lint` -> `gd-tools format --check` -> `gd-tools test --coverage --min 80`

### Testing Approach (Three Layers)

1. **Unit Tests for All Systems**
   - Every static utility function (economy.gd, market.gd, decay.gd, research.gd) has dedicated tests
   - Every data model method (ChimeraData.recalculate_stats, CombatState.take_damage, etc.) is tested
   - Every combat function (calculate_damage, check_berserk, etc.) is tested in isolation

2. **Integration Tests for Combat Flow**
   - Full match lifecycle: start_match -> entity placement -> AI/combat execution -> end_match -> rewards -> save
   - Economy flow: buy_part -> gold deduction -> inventory add -> save -> load -> verify
   - Assembly flow: equip part -> recalculate_stats -> update instability -> combo lookup -> save

3. **Edge Case Coverage**
   - Berserk: purebred immunity, event modifier accumulation/reset, 5s duration transition
   - Decay: accumulation across matches, repair resets, purebred immunity
   - Combo tiers: 2=Basic, 3=Enhanced, 4=Ultimate, null for all-different
   - Save/load: round-trip preserves all state, PartDatabase reconstruction works
   - Formation grid: all 9 cells map to correct world positions

### Test File Location
- Tests live in `res://tests/`, mirroring `scripts/` structure
- Test file naming: `test_<script_name>.gd` (e.g., `test_combat_state.gd`)

## Error Handling

### Strict Typing as First Defense
- Compiler catches type mismatches at edit time
- No untyped variables, parameters, or return types
- Typed arrays prevent runtime type errors

### Runtime Error Reporting
- Use `push_error()` for truly unexpected states (should never occur in valid game flow)
- Use `push_warning()` for recoverable issues (missing data, fallback used)
- Use `assert()` for development-time invariant checks (removed in release builds)
- Never silently swallow errors — always log or assert

## Quality Gates

Per the ROADMAP, each track must pass:
1. `gd-tools lint` — exits 0 (no linting errors)
2. `gd-tools format --check` — exits 0 (gdformat compliant)
3. `gd-tools test --coverage --min 80` — exits 0 (all tests pass, coverage >= 80%)
4. Manual checkpoint verification
5. Conductor review
