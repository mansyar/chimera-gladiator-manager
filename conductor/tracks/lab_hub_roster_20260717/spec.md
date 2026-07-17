# Specification: TRACK-010 — Lab Hub & Roster Screens

## Overview

Implement the full **Lab Hub** screen (main navigation hub) and **Roster** screen (detailed read-only chimera viewer) for the management UI. This track also builds the reusable **ChimeraSprite composition node** — the 8-layer composited sprite renderer driven by a chimera's equipped parts — which the Roster preview uses and TRACK-011 (Assembly) will reuse for live updates.

This is a **Feature** track. Dependencies: TRACK-009 (UI framework/widgets), TRACK-004 (GameState singleton), TRACK-002 (ChimeraData/PartData models).

**Context Anchors:**
- GDD Section 5 (Lab Hub — roster overview, navigation; Roster — view 3 chimeras, stats, decay, equipment, no bench)
- GDD Section 4.1 (Starting State — 3 chimeras, 200G)
- GDD Section 2.2 (Instability labels: Pure / Stable Hybrid / Volatile Hybrid / Chaotic)
- TDD Section 10 (UI Architecture — Screen Flow, ChimeraSprite composition, STRAIN_TO_COLOR)

## Functional Requirements

### Lab Hub Screen
- **FR-1:** Lab Hub displays 3 chimera summary cards (one per chimera in `GameState.roster`) using the existing `chimera_card` widget (nickname, HP, Attack, Defense, Speed, instability label).
- **FR-2:** Lab Hub provides navigation buttons to all 7 other screens: Assembly, Black Market, Roster, Clinic, Tournament, Hall of Fame, and Arena Pre-Match.
- **FR-3:** Lab Hub provides a "Quick Match" (Regular Match) button that navigates to the `arena_pre_match` screen via `ScreenManager.change_screen("arena_pre_match")`. (Full formation flow is TRACK-013; this track only wires the navigation stub.)
- **FR-4:** Lab Hub does NOT render its own Gold/Infamy display — it relies entirely on the persistent `TopBar` (TRACK-009), which already listens to `EventBus.gold_changed` / `infamy_changed`.
- **FR-5:** All Lab Hub navigation buttons play the UI click sound (via `ScreenManager.play_click()`) and transition through `ScreenManager.change_screen()`.

### ChimeraSprite Composition Node
- **FR-6:** A reusable `ChimeraSprite` node composites up to 8 layered `Sprite2D` children with fixed z-order: Body=0, Legs=1, Arms=2, Detail=3, Eyes=4, Mouth=5, Nose=6, Eyebrows=7.
- **FR-7:** `ChimeraSprite` exposes a method to set its visual from a `ChimeraData`'s equipped parts (TORSO→Body, LEGS→Legs, ARMS→Arms, HEAD→Detail), constructing each sprite path via the existing `STRAIN_TO_COLOR` + `get_sprite_path()` helper. Each layer loads its texture from the Monster Builder Pack and applies the correct z-order.
- **FR-8:** The node supports all 8 layers for reusability, but in TRACK-010 only the 4 part-derived layers (Body/Legs/Arms/Detail) are populated. Cosmetic layers (Eyes/Mouth/Nose/Eyebrows) remain empty (no cosmetic data source exists yet — deferred to TRACK-011). Empty layers show no sprite.
- **FR-9:** `ChimeraSprite` is decoupled from combat logic — it is a pure visual `Node2D` usable inside Control-based UI screens (e.g., placed under a `TextureRect`/`SubViewport` or directly in a `Control` with appropriate positioning). It does not depend on `CombatState` or `ChimeraEntity`.

### Roster Screen
- **FR-10:** Roster displays 3 detailed chimera cards (one per chimera in `GameState.roster`). The screen is **view-only** — no editing, no drag-and-drop.
- **FR-11:** Each Roster card displays:
  - Chimera nickname
  - Full `ChimeraSprite` preview (8-layer composited, part-derived layers populated)
  - 4 equipped parts listed with: part sprite, slot label (HEAD/TORSO/ARMS/LEGS), strain name, rarity
  - Derived stats: HP, Attack, Defense, Speed, Attack Range
  - Instability label (Pure / Stable Hybrid / Volatile Hybrid / Chaotic) per GDD 2.2
  - Strain distribution as color-coded strain chips (one chip per equipped part, colored per `STRAIN_TO_COLOR`, labeled with strain name)
  - Decay level (0 on fresh chimeras)
  - Match wins
  - Abilities list: 4 part abilities (name + type: active/passive) + combo ability if present
- **FR-12:** Instability label is derived from the count of distinct strains across the 4 parts (1 distinct strain=Pure/0, 2=Stable Hybrid/1, 3=Volatile Hybrid/2, 4=Chaotic/3) matching GDD Section 2.2 exactly.
- **FR-13:** Combo ability is displayed only when 2+ parts share a strain (i.e., `ChimeraData.combo_ability` is non-null). Combo tier (Basic/Enhanced/Ultimate) is shown alongside.
- **FR-14:** Roster provides a back button returning to Lab Hub via `ScreenManager.change_screen("lab_hub")` with click sound.

## Non-Functional Requirements

- **NFR-1:** Test coverage ≥ 80% for new source code with testable logic (`gd-tools test --coverage --min 80` exits 0).
- **NFR-2:** `gd-tools lint` exits 0 (no linting errors).
- **NFR-3:** `gd-tools format --check` exits 0 (gdformat compliant).
- **NFR-4:** `ChimeraSprite` node is reusable and decoupled — usable in both UI screens (Roster) and later Assembly without modification.
- **NFR-5:** Screens use the existing Godot `Theme` (Kenney Future font, NinePatchRect panels/buttons) consistent with TRACK-009 styling.
- **NFR-6:** Type safety enforced (typed variables and return types in GDScript). Public functions documented with `##` doc comments.

## Acceptance Criteria

- **AC-1:** Lab Hub shows exactly 3 chimera summary cards with nicknames + stats sourced from `GameState.roster`.
- **AC-2:** On a new game, TopBar shows Gold=200G, Infamy=0 (Lab Hub adds no duplicate display).
- **AC-3:** All 7 Lab Hub navigation buttons transition to the correct screen.
- **AC-4:** Quick Match button transitions to the `arena_pre_match` screen.
- **AC-5:** Roster shows full detail for 3 chimeras: composited sprite, equipped parts, derived stats, instability labels, decay=0, match wins, abilities.
- **AC-6:** `ChimeraSprite` renders part-derived layers (Body/Legs/Arms/Detail) with correct z-order and strain colors.
- **AC-7:** Instability label matches distinct-strain count per GDD 2.2 (Pure/Stable Hybrid/Volatile Hybrid/Chaotic).
- **AC-8:** Combo ability is displayed when 2+ same-strain parts exist; absent otherwise.
- **AC-9:** Strain distribution displayed as color-coded chips (one per part).
- **AC-10:** Roster is strictly view-only (no mutation of `ChimeraData` or `GameState`).
- **AC-11:** Automated tests pass: (1) Lab Hub shows 3 cards from `GameState.roster`, (2) Gold/Infamy labels match GameState, (3) Roster stats match ChimeraData, (4) instability label matches strain count, (5) combo ability displayed when 2+ same-strain.

## Out of Scope

- Part editing / drag-and-drop assembly (TRACK-011)
- Black Market purchasing (TRACK-012)
- Clinic repair / salvage (TRACK-012)
- Tournament bracket logic (TRACK-015)
- Arena Pre-Match formation interaction (TRACK-013) — only the navigation stub is wired
- Combat HUD / VFX (TRACK-014)
- Enemy generation (TRACK-008)
- Cosmetic face customization UI (TRACK-011) — ChimeraSprite node supports cosmetic layers but TRACK-010 does not populate them
- Lab Hub "available tournaments" panel (GDD mentions tournaments in Hub; tournament display deferred to TRACK-015)
