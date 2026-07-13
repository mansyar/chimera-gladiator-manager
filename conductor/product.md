# Product Definition

## Initial Concept

Chimera Gladiator Manager — an auto-battler / management simulation where players manage a dark-science monster lab, stitch together modular creature parts from distinct bio strains, and field their chimeras in automated arena championships.

## Executive Summary

- **Game Title:** Chimera Gladiator Manager
- **Genre:** Auto-Battler / Management Simulation / Monster Engineering
- **Target Platform:** PC (Steam / Itch.io)
- **Engine:** Godot 4.5+ (Compatibility renderer, OpenGL), GDScript
- **Primary Design Reference:** Gladiator Guild Manager

### Core Pitch

Manage a dark-science monster lab. Purchase or harvest modular body parts (head, torso, arms, legs) from six distinct bio strains. Engineer mutated Chimeras by combining parts — each combination produces unique stats, abilities, and visual appearance. Field your creations in cutthroat automated arena championships where pre-match tactical preparation dictates victory.

## Target Audience

**Primary:** Tactical management fans — players who enjoy Gladiator Guild Manager-style management depth combined with auto-battler combat. These players value:
- Pre-match strategic decision-making over real-time micro
- Economic tension between power and maintenance costs
- Deep theory-crafting in unit building and formation planning

**Secondary:** Monster engineering enthusiasts who enjoy creature customization and evolution systems. The modular part system and genetic instability mechanic provide the creative sandbox they seek.

## Core Differentiator: Genetic Instability

The defining mechanic that sets Chimera Gladiator Manager apart is **Genetic Instability** — the cascading penalty system for stitching disparate biological species together.

**Risk/Reward Tension:**
- **Purebreds** (all 4 parts same strain): Reliable, predictable, passive stat bonuses, zero berserk/decay risk — but limited to one strain's abilities.
- **Hybrids** (2+ strains): Access to cross-strain abilities and volatile power spikes — but risk berserk (attacking allies), genetic decay (permanent stat degradation requiring Gold repairs), and unpredictable combat behavior.

This creates the central economic and strategic tension: hybrids are stronger but cost more to maintain, while purebreds are cheaper but lack explosive potential. Every assembly decision is a calculated gamble.

## Key Features

### Modular Fusion Lab
- 4 equipment slots (HEAD, TORSO, ARMS, LEGS) from 6 bio strains
- 23 shape variants across slots, each granting a unique ability
- Visual sprite composition (layered body, arms, legs, head detail, cosmetics)
- Dynamic stat aggregation from equipped parts
- Strain combo abilities unlock when 2+ parts share a strain

### Hands-Off Tactical Combat
- Fully automated real-time combat — no player input during fights
- 7 AI behavior modules (determined by HEAD part) control targeting, ability priority, positioning
- 3x3 formation grid for pre-match positioning
- 60-second timer with HP% win condition
- Berserk system: unstable chimeras may attack allies

### Black Market Economy
- Two-tier inventory: always-available commons + rotating stock (refreshes per match)
- 4 rarity tiers: Common, Uncommon, Rare, Legendary
- Infamy-gated legendary parts
- Gold sink via decay repair costs at the clinic

### Campaign Progression
- Continuous campaign (no roguelike runs, no permadeath)
- 4 tournament tiers with escalating Infamy requirements and Gold entry fees
- Research and Ascension: retire legendary champions to unlock permanent campaign bonuses across 3 branches
- Fail-safe mechanics: regular matches always free, rubber-band difficulty, emergency salvage

## MVP Scope

**Full game** — All 6 milestones from the ROADMAP will be implemented:
1. Environment and Foundations (TRACK-001)
2. Data Layer and Core Infrastructure (TRACK-002 through TRACK-004)
3. Combat Core (TRACK-005 through TRACK-008)
4. UI and Management Screens (TRACK-009 through TRACK-012)
5. Arena and Match Flow (TRACK-013 through TRACK-014)
6. Progression and Meta Systems (TRACK-015 through TRACK-016)

Milestones 3 and 4 can be developed in parallel after TRACK-004 is complete.

## Success Criteria

**Primary Goal: Playable Prototype**
- Core gameplay loop functional: assemble chimeras, fight matches, earn rewards, upgrade parts, repeat
- Internal testing to validate the fun factor
- All 16 tracks from the ROADMAP implemented
- 80%+ test coverage via gd-tools
- Clean lint and format compliance

## Technology Stack

- **Engine:** Godot 4.5+ (Compatibility renderer, OpenGL)
- **Language:** GDScript
- **Testing:** gd-tools CLI (GUT 9.5.0, gdlint, gdformat, coverage reporting)
- **Assets:** 5 Kenney asset packs (monster builder, roguelike RPG, UI, UI RPG expansion, particle)
- **Save System:** JSON at user://saves/
- **Architecture:** Singleton/autoload pattern, Resource-based data models (.tres)

## Source Documents

| Document | Role |
|----------|------|
| docs/GDD.md | Game design (pure design — no code, no node structures) |
| docs/TDD.md | Technical architecture, data models, system design |
| docs/ROADMAP.md | 16 implementation tracks across 6 milestones with DoD gates |

These documents are the authoritative source of truth for design and implementation decisions.
