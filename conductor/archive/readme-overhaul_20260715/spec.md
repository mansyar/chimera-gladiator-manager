# Track: README Overhaul — Player-Facing Game README

## Overview

The current `README.md` is heavily development-focused, containing sections like Tech Stack, Setup, Running Tests, Project Structure, and Development Workflow. This track overhauls the README into a clean, player-facing game README and relocates all development information to a new `DEVELOPMENT.md` file at the repository root.

## Background

The project is in active development (TRACK-005+ pending). The existing README doubles as both a project landing page and a developer onboarding doc. For a game project, the README should present the game to players, not describe the toolchain.

## Functional Requirements

### FR-1: Player-Facing README
The new `README.md` must be a clean, player-focused game landing page containing:
- Game title and a one-line tagline/pitch.
- A **Features & Gameplay** section covering the core mechanics (aligned with GDD.md / product.md):
  - Modular Fusion Lab (stitch head/torso/arms/legs from 6 bio strains).
  - Genetic Instability (purebred reliability vs hybrid volatility — berserk, genetic decay).
  - Hands-Off Tactical Combat (fully automated, 3x3 formation, pre-match prep).
  - Black Market Economy (rotating stock, 4 rarity tiers, infamy-gated legendaries).
  - Campaign Progression (4 tournament tiers, research/ascension, fail-safe mechanics).

### FR-2: Remove Development & Status Content from README
The README must NOT contain:
- Tech Stack / engine details.
- Setup / installation / running tests commands.
- Project Structure tree.
- Development Workflow / Conductor methodology.
- Current Status / Roadmap / track table (removed entirely).

### FR-3: Relocate Development Content to DEVELOPMENT.md
A new `DEVELOPMENT.md` file must be created at the repository root, containing all development-focused content removed from the README:
- Tech Stack.
- Source Documents table (GDD, TDD, ROADMAP).
- Project Structure.
- Setup / Prerequisites / Installation.
- Running Tests.
- Development Workflow (Conductor methodology + ROADMAP link).
- Current Status / track table (dev-relevant status moved here).

### FR-4: Cross-Links
- The README must include a brief link to `DEVELOPMENT.md` for contributors.
- DEVELOPMENT.md may link back to the README.

### FR-5: License
- Keep the existing "License" section (currently "TBD") in the README.

## Non-Functional Requirements

- **Tone:** Player-friendly and evocative, not technical. Match the dark-science / monster-lab theme.
- **Accuracy:** All gameplay descriptions must align with `docs/GDD.md` and `conductor/product.md` (no fabricated mechanics).
- **Style:** Well-formed Markdown matching existing formatting conventions.

## Acceptance Criteria

1. `README.md` contains only player-facing content: title, tagline, Features & Gameplay, license, and a link to DEVELOPMENT.md.
2. `README.md` contains NO tech stack, setup, test, project structure, workflow, or status/roadmap sections.
3. `DEVELOPMENT.md` exists at repo root and contains all relocated development content (Tech Stack, Source Documents, Project Structure, Setup, Running Tests, Development Workflow, Status table).
4. All gameplay descriptions in the README are consistent with GDD.md / product.md.
5. A contributor link from README → DEVELOPMENT.md is present.

## Out of Scope

- Adding screenshots, GIFs, or key art (not requested).
- Adding "How to Play" / controls section (not requested).
- Adding download/install instructions for players / Steam / Itch.io placeholders (not requested).
- Changes to any source code, scenes, or data files.
- Changes to GDD.md, TDD.md, or ROADMAP.md content.
