# Chimera Gladiator Manager
## Game Design Document (DRAFT)

> **Status:** Draft v2 — combat model specified, evaluation gaps resolved. Ready for implementation planning.
> Last updated: 2026-07-13

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Core Pillars & Mechanics](#2-core-pillars--mechanics)
3. [Kenney Asset Mapping Index](#3-kenney-asset-mapping-index)
4. [Progression Loop & Economy](#4-progression-loop--economy)
5. [UI/UX Design](#5-uiux-design)

---

## 1. Executive Summary

- **Game Title:** Chimera Gladiator Manager
- **Genre:** Auto-Battler / Management Simulation / Monster Engineering
- **Target Platform:** PC (Steam / Itch.io)
- **Target Audience:** Fans of tactical management, monster creation, and hands-off tactical combat (e.g., *Gladiator Guild Manager*, *Palworld*, *Digimon World Next Order*).
- **Primary Design Reference:** *Gladiator Guild Manager* — closest mechanical match for management + automated combat balance.
- **Core Pitch:** Manage a dark-science monster lab. Stitch together limbs, heads, and bodies from distinct fantasy/sci-fi creatures using black-market DNA, engineer your mutated Chimeras, and field them in cutthroat automated arena championships.

---

## 2. Core Pillars & Mechanics

### 2.1 Modular Fusion (The Lab Phase)

Players do not recruit premade gladiators. Instead, they purchase or harvest modular parts across **four gameplay slots**:

| Slot | Asset Category | Primary Stat | Special Role |
| :--- | :--- | :--- | :--- |
| **HEAD** | `detail` (horns, ears, antenna) | Minor bonuses | Determines AI behavior module |
| **TORSO** | `body` | HP | Foundation of the chimera |
| **ARMS** | `arm` | Attack | Damage output |
| **LEGS** | `leg` | Speed | Movement / initiative |

- Every individual part carries a visual sprite, a bio strain, stat modifiers, and (for heads) a combat behavior module.
- Assembling components updates the creature's visual stack and dynamically aggregates its base attribute layout.
- **Face elements** (eyes, mouth, nose, eyebrows) are cosmetic-only player customization with no gameplay effect.

#### Bio Strains

Six bio strains, mapped 1:1 to the Kenney Monster Builder Pack's color palette:

| Strain | Asset Color | Identity |
| :--- | :--- | :--- |
| **Undead** | `dark` | Shadowy, corpse-like |
| **Robotic** | `white` | Sterile, metallic |
| **Draconic** | `red` | Reptilian, fiery |
| **Beast** | `green` | Feral, organic |
| **Elemental** | `blue` | Ethereal, aquatic |
| **Aberrant** | `yellow` | Mutant, unstable |

Each part carries exactly one strain. The strain determines the part's visual color and feeds directly into the Genetic Instability system.

### 2.2 Genetic Instability (The Twist)

Stitching disparate biological species together causes a cascading penalty known as **Genetic Instability**.

Instability is calculated as the **count of distinct strains across the chimera's 4 parts**:

| Instability | Distinct Strains | Label | Effects |
| :--- | :--- | :--- | :--- |
| 0 | 1 (all same) | **Pure** | +passive stat bonus, fully predictable AI, zero risk |
| 1 | 2 | **Stable Hybrid** | Small chance of volatile damage spikes, low berserk risk |
| 2 | 3 | **Volatile Hybrid** | Moderate volatile spikes, ally-attack risk, minor decay risk |
| 3 | 4 (all different) | **Chaotic** | High volatile spikes, high berserk/ally-attack risk, significant decay risk |

- **Purebreds** trade explosive potential for reliability and passive bonuses.
- **Hybrids** trade stability for volatile power spikes and access to cross-strain ability combinations.
- There is **no formal elemental type chart**. The purebred downside is simply the lack of volatile hybrid power — not a weakness to specific elements.
- **Purebred vs Hybrid balance:** Purebreds gain the Ultimate strain combo and passive stat bonuses, but have access to only one strain's abilities. Hybrids access abilities from multiple strains and volatile damage spikes, but risk berserk, decay, and maintenance costs. Both are viable builds.

### 2.3 Abilities System

Chimera abilities are determined during the **Lab Phase** (assembly) and executed automatically by the AI during the **Arena Phase**. The system has two layers: **part abilities** and **strain combo abilities**.

#### Part Abilities

Each equipped part grants **one ability**, determined by the part's shape variant. Abilities are a mix of **active** (triggered by the AI during combat, on cooldown or conditional triggers) and **passive** (always-on effects). A chimera with 4 parts has 4 part abilities. There is **no cap** — all abilities are active simultaneously.

The HEAD part's behavior module (see [Section 2.4](#24-hands-off-tactical-automation-the-arena-phase)) determines **ability priority** — which active abilities the chimera uses first or most frequently during combat.

| Slot | Shape Variants | Ability Theme |
| :--- | :--- | :--- |
| **HEAD** | 7 detail types | Utility & disruption — ability is thematically linked to its behavior module (see [Section 2.4](#24-hands-off-tactical-automation-the-arena-phase)) |
| **TORSO** | 6 body shapes | Defense & sustain — shields, regen, damage mitigation, thorns, HP thresholds |
| **ARMS** | 5 arm shapes | Offense — attack modifiers, cleave, armor pierce, counter-attacks, critical triggers |
| **LEGS** | 5 leg shapes | Mobility & positioning — repositioning, initiative boosts, charge attacks, retreat |

#### Strain Combo Abilities

When **2 or more parts share the same strain**, a strain-specific combo ability unlocks as a **5th ability** on top of the 4 part abilities. Combo power scales with the number of matching-strain parts:

| Matching Parts | Combo Tier | Effect |
| :--- | :--- | :--- |
| 2 same-strain | **Basic** | Unlocks the strain's signature ability at base power |
| 3 same-strain | **Enhanced** | Signature ability at increased power + a secondary passive effect |
| 4 same-strain (Pure) | **Ultimate** | Full-power signature ability + a powerful persistent aura |

Each strain has a distinct combo theme:

| Strain | Combo Theme | Direction |
| :--- | :--- | :--- |
| **Undead** | Necrotic drain | Life steal on attacks, reanimate briefly on death |
| **Robotic** | System overcharge | Periodic damage burst, stat overclock with tradeoff |
| **Draconic** | Dragon fury | AoE fire breath, enrage mechanic on low HP |
| **Beast** | Feral savagery | Attack speed surge, lifesteal on critical hits |
| **Elemental** | Elemental surge | Chain damage between enemies, elemental shields |
| **Aberrant** | Mutant chaos | Randomized powerful effects, mid-combat stat mutation |

> Specific ability effects, values, and cooldowns are deferred to implementation and balancing.

### 2.4 Hands-Off Tactical Automation (The Arena Phase)

Combat is fully simulated. Pre-match tactical preparation dictates victory.

#### Combat Model

Combat is **real-time and fully automated**. Once the player confirms their formation, chimeras act independently — no player input during combat.

- **Movement:** Chimeras start in their assigned grid cells but move freely through the arena once combat begins. The 3×3 formation grid is pre-match positioning only. Movement speed is governed by the Speed stat (LEGS).
- **Attack Range:** Determined by the ARMS part shape. Some arms are melee (short range, chimera must close in), others are ranged (can attack from distance). This creates natural kite/chase dynamics between behavior modules.
- **Attack Cadence:** Chimeras auto-attack on an interval governed by Speed (higher Speed = more attacks per second). Active abilities trigger automatically when off cooldown, sequenced by the behavior module's ability priority.
- **Damage Resolution:** Damage per hit = Attacker's Attack − Defender's Defense (minimum 1). Defense is a secondary stat found on TORSO and HEAD parts.
- **Win Condition:** Combat ends when all chimeras on one side are defeated, OR when the **60-second timer** expires. If both sides survive to the time limit, the side with the higher total HP percentage wins.

#### Formation Grid

Each side has its own **3×3 formation grid**. The player owns exactly 3 chimeras and fields all 3 every match — there is no bench or substitution system. Each chimera is placed in 1 of 9 cells:

```
Player Side              Enemy Side
┌───┬───┬───┐            ┌───┬───┬───┐
│   │   │   │  BACK      │   │   │   │
├───┼───┼───┤            ├───┼───┼───┤
│   │   │   │  MID       │   │   │   │
├───┼───┼───┤            ├───┼───┼───┤
│   │   │   │  FRONT     │   │   │   │
└───┴───┴───┘            └───┴───┴───┘
 ←──── engagement zone ────→
```

- **Row** (front/mid/back): Determines melee reach, who gets attacked first, ranged safety.
- **Column** (left/center/right): Targeting lanes, flanking potential.

#### Enemy Scouting

The player has **full intel** — they see the enemy's full formation and chimera composition before positioning their own. This rewards game knowledge and counter-positioning.

#### Behavior Modules

Each **HEAD part** carries one fixed FSM AI behavior module. The player chooses which head to equip — no per-match customization beyond equipment selection. The asset pack has 7 detail types (antenna_large, antenna_small, ear, ear_round, eye, horn_large, horn_small), giving 7 distinct behavior modules.

The behavior module governs **ability priority** — which active abilities the chimera uses first and how it sequences them during combat. A chimera with offensive abilities but a cautious behavior module will play defensively but still deploy its offensive kit when the AI deems it appropriate.

Each module defines three things: **targeting behavior** (who the chimera attacks), **ability priority** (which ability types it uses first), and **positioning tendency** (how it navigates the 3×3 grid):

| Detail Type | Module | Targeting | Ability Priority | Positioning |
| :--- | :--- | :--- | :--- | :--- |
| `horn_large` | **Charger** | Nearest enemy | Offense > Mobility > Utility > Defense | Rushes front, engages immediately |
| `horn_small` | **Skirmisher** | Weakest accessible enemy | Mobility > Offense > Utility > Defense | Hit-and-run, repositions after attacks |
| `antenna_large` | **Caster** | Highest-threat enemy | Utility > Offense > Defense > Mobility | Stays back row, attacks from safety |
| `antenna_small` | **Controller** | Enemy in optimal disrupt position | Utility > Mobility > Defense > Offense | Mid row, focuses on debuffs and repositioning |
| `ear` | **Sentinel** | Enemy attacking allies | Defense > Utility > Offense > Mobility | Holds position, protects allies |
| `ear_round` | **Guardian** | Enemy attacking itself (taunt) | Defense > Utility > Mobility > Offense | Front row, absorbs damage, bodyblocks |
| `eye` | **Stalker** | Lowest-HP enemy (execute) | Offense > Utility > Mobility > Defense | Flanks, waits for kill opportunities |

This creates natural counter-dynamics in formation planning: Chargers rush Casters, Guardians intercept Chargers, Stalkers exploit weakened units, Controllers disrupt formations, and Sentinels protect vulnerable allies.

#### Targeting Definitions

The behavior modules reference several targeting terms. Each has a concrete meaning:

| Term | Definition |
| :--- | :--- |
| **Nearest enemy** | Closest enemy by distance |
| **Weakest accessible** | Lowest current HP among enemies within attack range |
| **Highest-threat** | Enemy with the highest current Attack stat |
| **Optimal disrupt target** | Highest-Attack enemy currently targeting an ally |
| **Enemy attacking allies** | Enemy currently dealing damage to any ally chimera |
| **Lowest-HP enemy** | Enemy with lowest current HP (Stalker moves to reach them) |

Attack range is determined by the ARMS part shape — some arms are melee (short range), others are ranged (can attack from distance). A chimera's behavior module determines how it navigates toward or away from targets within and outside its range.

#### Berserk

Berserk is a **temporary loss of control** — the wild card that makes high-instability hybrids dangerous to their own team. A berserk chimera ignores its behavior module and attacks the nearest target (friend or foe) with enhanced damage but reduced defense. The state lasts **5 seconds**, after which the chimera returns to normal. Purebreds (Instability 0) are immune to berserk.

Every **5 seconds**, the game rolls a **berserk check** against the chimera's base probability (set by instability level). Combat events modify this probability for the next check:

| Trigger | Effect on Berserk Chance |
| :--- | :--- |
| Base (per check, every 5s) | Set by instability level (see below) |
| HP drops below 30% | +15% for the next check |
| An ally dies | Immediate berserk check |
| Hit by a disruption ability | +10% for the next check |
| Landing a killing blow | +5% for the next check (bloodlust) |

Base probability per check by instability:

| Instability | Berserk Chance per Check |
| :--- | :--- |
| 0 (Pure) | 0% (immune) |
| 1 (Stable) | 3% |
| 2 (Volatile) | 8% |
| 3 (Chaotic) | 15% |

While berserk (5 seconds):

- **Ignores behavior module** — targets the nearest entity (ally or enemy)
- **+50% attack damage** — berserk chimeras hit harder
- **−30% defense** — but take more damage in return
- **Active abilities fire randomly** — trigger on cooldown regardless of priority logic, targeting whoever is nearest
- **Passive abilities remain active** — they do not shut off

---

## 3. Kenney Asset Mapping Index

The game uses **five** Kenney asset packs. Each is mapped to a specific game layer, with compatible color palettes enabling strain-themed visual consistency.

| # | Pack | Folder | Game Layer | Key Assets |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Monster Builder Pack | `kenney-monster-builder-pack/` | Chimera Assembly | 178 body/arm/leg/detail sprites × 6 colors + cosmetic face elements |
| 2 | Roguelike/RPG Pack | `kenney-roguelike-rpg-pack/` | Arena Environments | 1,700+ 16×16 tiles: floors, walls, banners, flags, furniture |
| 3 | UI Pack | `kenney-ui-pack/` | Lab / Management UI | 400+ sprites (buttons, panels, sliders, checkboxes) × 5 colors + font + sounds |
| 4 | UI Pack (RPG Expansion) | `kenney-ui-pack-rpg-expansion/` | Combat UI | 87 sprites: health/mana bars, RPG panels, cursors |
| 5 | Particle Pack | `kenney-particle-pack/` | VFX & Abilities | 80 particle sprites: slash, fire, magic, spark, smoke, etc. |

### 3.1 Monster Builder Pack → Chimera Assembly

See [Section 2.1](#21-modular-fusion-the-lab-phase) for the full part-slot-to-asset-category mapping. Summary:

| Part Slot | Asset Category | Variants × Colors | Total |
| :--- | :--- | :--- | :--- |
| HEAD | `detail` (horns, ears, antenna) | 7 types × 6 colors | 42 |
| TORSO | `body` | 6 shapes × 6 colors | 36 |
| ARMS | `arm` | 5 shapes × 6 colors | 30 |
| LEGS | `leg` | 5 shapes × 6 colors | 30 |
| Cosmetic | `eye`, `mouth`, `eyebrow`, `nose`, `snot` | 40 types | 40 |

### 3.2 Roguelike/RPG Pack → Arena Environments

- **Format:** Single spritesheet (transparent + magenta versions), 16×16px tiles with 1px margin
- **Tile count:** 1,700+
- **Game uses:**
  - Floor tiles → Arena ground textures
  - Wall tiles → Arena barriers and boundaries
  - Flags and banners → Arena decorations, faction markers
  - Furniture → Lab background dressing (optional)
- 2 sample TMX maps included (indoor + outdoor) for reference

### 3.3 UI Pack → Lab / Management UI

- **Format:** Individual PNGs organized by color, each in Default + Double resolution
- **Colors:** Blue, Green, Grey, Red, Yellow (5 variants)
- **Per color (~82 sprites):**
  - Buttons: rectangle, round, square — each with 9 style variants (border, depth_flat, depth_gloss, depth_gradient, depth_line, flat, gloss, gradient, line)
  - Arrows: basic and decorative, 4 directions, small and large
  - Checkboxes: round and square, multiple states
  - Sliders: horizontal and vertical, color and grey variants
  - Stars: filled, outline, and depth
- **Extra (24 sprites):** dividers, input fields, arrow/play/repeat icons
- **Font:** Kenney Future + Kenney Future Narrow (TTF)
- **Sounds:** 6 UI sounds — click (×2), switch (×2), tap (×2) in OGG format

### 3.4 UI Pack (RPG Expansion) → Combat UI

- **Format:** Individual PNGs (87 total) + spritesheet + vector source
- **Elements:**
  - **Bars:** Horizontal and vertical, 4 colors (blue, green, red, yellow), with back pieces — HP/status bars
  - **Buttons:** Long, round, and square in 4 styles (beige, blue, brown, grey) with pressed states
  - **Panels:** Regular and inset, 4 colors — character info frames
  - **Cursors:** Gauntlet, hand, and sword variants
  - **Icons:** Check, circle, cross

### 3.5 Particle Pack → VFX & Abilities

- **Format:** Individual transparent PNGs (80 total) + rotated variants + black background versions
- **Elements by game use:**

| Game Use | Sprites |
| :--- | :--- |
| Melee hit VFX | slash (4), scratch (1), scorch (3) |
| Draconic strain VFX | fire (2), flame (6) |
| Elemental strain VFX | magic (5), twirl (3), star (9) |
| Robotic strain VFX | spark (7), muzzle (5) |
| Mutation / Aberrant VFX | smoke (10) |
| Generic glow / light | circle (5), light (3), flare (1), trace (7), symbol (2) |
| Environmental | dirt (3), window (4) |

### 3.6 Color Palette Alignment

The asset packs share compatible color palettes, enabling consistent UI theming per strain:

| Strain | Monster Builder Color | UI Pack Color | RPG UI Color | Particle Theme |
| :--- | :--- | :--- | :--- | :--- |
| Undead | dark | Grey | brown | smoke |
| Robotic | white | Grey | grey | spark, muzzle |
| Draconic | red | Red | — | fire, flame |
| Beast | green | Green | — | dirt, spark |
| Elemental | blue | Blue | blue | magic, twirl |
| Aberrant | yellow | Yellow | yellow | star, twirl |

---

## 4. Progression Loop & Economy

### 4.1 The Loop

The game is a **continuous campaign** — no roguelike runs, no permadeath. Your lab persists indefinitely as you climb through increasingly prestigious tournament tiers.

**Starting State:** A new campaign begins with 3 pre-assembled common-rarity chimeras (filling tank, DPS, and utility roles) and a starting Gold stipend of 200G. The player can immediately fight Regular Matches and visit the Black Market to begin upgrading.

1. **Acquisition:** Win matches to earn **Gold** and **Infamy**. Use Gold to buy parts on the black market, purchase experimental tech expansions, and pay clinic repair costs. Use Infamy to unlock higher-tier tournament invitations.
2. **Maintenance:** Unstable chimeras risk **genetic decay** per match — permanent stat degradation until repaired at the clinic for Gold. Purebreds (Instability 0) never decay. This creates the core economic tension: hybrids are stronger but cost more to maintain.
3. **Ascension:** Retire legendary chimeric champions into your permanent hall of fame, unlocking passive research tracks that persist across your entire campaign.

### 4.2 Genetic Decay

| Instability | Decay Risk per Match | Repair Cost |
| :--- | :--- | :--- |
| 0 (Pure) | None | — |
| 1 (Stable) | Low chance, minor stat loss | Low |
| 2 (Volatile) | Moderate chance, moderate stat loss | Medium |
| 3 (Chaotic) | High chance, significant stat loss | High |

Decay is **repairable** at the clinic for Gold. Unrepaired decay accumulates across matches. This makes high-instability hybrids a calculated economic gamble — more power, but ongoing maintenance costs.

### 4.3 Resources

| Resource | Earned From | Spent On |
| :--- | :--- | :--- |
| **Gold** | Match winnings, bounties | Parts (black market), tech expansions, clinic repairs, serums |
| **Infamy** | Match victories, tournament placement | Unlocking higher-tier tournament invitations |

### 4.4 Tournament Tiers

#### Match Types

Two types of combat engagements are available:

- **Regular Matches:** Always available. Fight generated opponents for Gold and small Infamy. No entry fee. The primary income source for maintaining chimeras.
- **Tournaments:** Special bracket events. Entry requires meeting Infamy thresholds and paying Gold entry fees at higher tiers. The main vehicle for Infamy progression and large Gold payouts.

#### Tournament Tiers

| Tier | Name | Infamy Threshold | Entry Fee (Gold) | Format | Reward Multiplier |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | **Underground Brawls** | 0 | Free | 4-participant bracket | 1× |
| 2 | **Provincial Arena** | 50 | 100 | 4-participant bracket | 2× |
| 3 | **Grand Colosseum** | 150 | 300 | 8-participant bracket | 4× |
| 4 | **Champion's Circle** | 400 | 1,000 | 8-participant bracket | 8× |

Entry fees create a Gold sink and ensure commitment — losing early in a high-tier tournament hurts economically. The reward multiplier applies to both Gold and Infamy earned from the tournament.

> Infamy thresholds, entry fees, and reward multipliers are starting values for balancing.

### 4.5 Research Tracks (Ascension)

#### Ascension

A chimera becomes eligible for Ascension after winning **10 matches** (lifetime total). Retiring an eligible chimera to the Hall of Fame grants **1 Research Point**. This is a meaningful sacrifice — the player loses a proven fighter in exchange for a permanent campaign bonus. Since the player always fields exactly 3 chimeras, a retired chimera is immediately replaced by a **free common-rarity starter chimera** (pre-assembled, random role). The player can then customize or swap parts on the replacement via the Assembly screen and Black Market.

#### Research Branches

Research points are spent across three branches, each offering a distinct investment strategy:

| Branch | Focus | Structure |
| :--- | :--- | :--- |
| **Strain Mastery** | Enhance specific strains | 6 tracks (one per strain), 3 levels each |
| **Lab Engineering** | Economy & maintenance | Universal nodes, each with 2 levels |
| **Combat Doctrine** | Combat performance | Universal nodes, single-level |

**Branch 1: Strain Mastery** — 6 tracks (one per strain), 3 levels each. Each level enhances that strain's combo ability power and grants a small stat bonus to all parts of that strain. Retiring a chimera that includes that strain gives bonus progress toward that strain's track. This rewards players who commit to a strain identity.

**Branch 2: Lab Engineering** — Universal nodes, 2 levels each:
- **Reinforced Genetics:** Reduced decay rate per level
- **Clinic Efficiency:** Reduced repair costs per level
- **Market Connections:** Better black market prices per level
- **Stability Serum:** Reduced berserk chance per level

**Branch 3: Combat Doctrine** — Universal nodes, single-level:
- **Tactical AI:** Improved behavior module decision-making
- **Ability Tuning:** Reduced ability cooldowns
- **Formation Mastery:** Stat bonus when correctly positioned in the grid
- **Berserk Control:** Berserk duration reduced to 3 seconds

> Specific values for each research node are deferred to implementation and balancing.

### 4.6 Fail State & Recovery

The campaign is truly continuous — there is **no game over** state. Multiple mechanics prevent soft locks:

1. **Regular Matches are always free** — Even if the player can't afford tournament entry fees, they can always play Regular Matches to earn Gold.
2. **Rubber-band difficulty** — Regular Match opponents scale to the player's roster strength. If the player is on a losing streak, opponents get progressively weaker, ensuring the player can always eventually win and earn Gold.
3. **Emergency Salvage** — If all chimeras are decayed beyond viability (all stats below a minimum threshold), the player can salvage them at the lab for free: break down decayed chimeras into base parts. Salvaged parts become **Neutral** — a pseudo-strain with no color, no combo ability, and no strain bonuses. All Neutral parts count as the same strain for instability purposes, so a chimera assembled from all Neutral parts is Pure (Instability 0). This allows the player to reassemble a stable but weak chimera with no combo abilities.
4. **No negative Gold** — Gold can't go below zero. The player simply can't make purchases until they earn more.

The real consequence of poor management is **time** — being stuck grinding low-tier Regular Matches while rebuilding, rather than progressing through tournaments. The economic tension is preserved (decay, repair costs, and entry fees all matter), but the player is never trapped in an unwinnable state.

### 4.7 Black Market Economy

#### Market Structure

The Black Market has a **two-tier inventory**:

1. **Base Stock (always available):** Common-rarity parts in all categories (HEAD, TORSO, ARMS, LEGS) across all 6 strains. Low stats, basic abilities. Stable prices. The player can always buy basic parts to fill gaps or rebuild after salvage.

2. **Rotating Stock (refreshes after each match):** 6–10 randomly selected parts at varying rarities. This is where the player finds upgrades and rare finds. Each match played (Regular or Tournament) triggers a market refresh — giving the player a reason to check the market between every match.

#### Rarity Tiers

| Rarity | Availability | Stat Quality | Price Range (Gold) |
| :--- | :--- | :--- | :--- |
| **Common** | Base stock | Standard | 50–100 |
| **Uncommon** | Rotating stock | +25% stats | 150–300 |
| **Rare** | Rotating stock (uncommon) | +50% stats, enhanced ability | 500–1,000 |
| **Legendary** | Rotating stock (very rare) | +100% stats, unique ability variant | 1,500–3,000 |

**What rarity affects:**
- **Stat modifiers** — higher rarity = better stat bonuses
- **Ability potency** — higher rarity = stronger ability effects (larger AoE, shorter cooldowns, stronger passives)
- **Shape variant** still determines the ability *theme* — rarity determines *potency*

**Legendary parts** may require a minimum Infamy threshold to purchase, representing the black market's willingness to deal premium goods only to established managers.

> Specific prices, stat scaling, and Infamy thresholds are starting values for balancing.

---

## 5. UI/UX Design

### 5.1 Key Screens

| Screen | Purpose |
| :--- | :--- |
| **Lab Hub** | Main hub. Displays roster overview, current Gold/Infamy, and available tournaments. Navigation to all other screens. |
| **Chimera Assembly** | Build and modify chimeras. Four equipment slots (HEAD, TORSO, ARMS, LEGS), cosmetic face customization, live stat preview, and instability meter. |
| **Black Market** | Browse and purchase parts. Filterable by part type, strain, and price. |
| **Arena Pre-Match** | Formation grid (3×3) placement screen with full enemy intel display. Shows enemy composition and formation before you position. |
| **Arena Combat** | Automated combat simulation. HUD shows chimera HP bars, status effects, and instability events (berserk, volatile spikes) as they trigger. |
| **Roster** | View your 3 chimeras, their current stats, decay status, and equipment. The player owns exactly 3 chimeras at all times — no bench or substitution system. |
| **Clinic** | Repair decayed chimeras for Gold. Shows current decay level and repair costs per chimera. |
| **Tournament Bracket** | View upcoming tournaments, entry requirements (Infamy thresholds), and reward tiers. |
| **Hall of Fame** | View retired champions and unlocked passive research tracks. |

---
