# Implementation Plan: README Overhaul — Player-Facing Game README

## Phase 1: Relocate Development Content to DEVELOPMENT.md

- [ ] Task: Create `DEVELOPMENT.md` at repository root containing all development-focused content moved out of README.md
    - [ ] Create `DEVELOPMENT.md` with a top-level heading and intro linking back to the README
    - [ ] Move the Tech Stack section (engine, language, testing, assets, save system, architecture)
    - [ ] Move the Source Documents table (GDD, TDD, ROADMAP)
    - [ ] Move the Project Structure tree
    - [ ] Move the Setup section (Prerequisites, Installation, Running Tests, verification order note)
    - [ ] Move the Development Workflow section (Conductor methodology + ROADMAP link)
    - [ ] Move the Current Status / track table
- [ ] Task: Verify relocated content is complete and internally consistent in DEVELOPMENT.md
    - [ ] Confirm all seven dev sections are present and none were dropped
    - [ ] Confirm internal links (docs/ROADMAP.md, conductor/workflow.md, etc.) resolve correctly
- [ ] Task: Conductor - User Manual Verification 'Relocate Development Content to DEVELOPMENT.md' (Protocol in workflow.md)

## Phase 2: Rewrite README.md as Player-Facing Game README

- [ ] Task: Replace README.md with a clean, player-facing game landing page
    - [ ] Add game title and a one-line tagline/pitch
    - [ ] Add a "Features & Gameplay" section describing the five core mechanics (Modular Fusion Lab, Genetic Instability, Hands-Off Tactical Combat, Black Market Economy, Campaign Progression)
    - [ ] Add a brief contributor link to `DEVELOPMENT.md`
    - [ ] Keep the "License" section (TBD)
- [ ] Task: Verify README contains no development-focused content
    - [ ] Confirm no Tech Stack, Setup, Running Tests, Project Structure, Workflow, or Status sections remain
    - [ ] Confirm all gameplay descriptions are consistent with `docs/GDD.md` and `conductor/product.md`
- [ ] Task: Conductor - User Manual Verification 'Rewrite README.md as Player-Facing Game README' (Protocol in workflow.md)
