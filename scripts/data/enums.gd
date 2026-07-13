## Central enum definitions shared across the entire project.
##
## Contains all game enumerations used by data models, combat,
## AI, and UI systems.
class_name GameEnums

## Bio strains that parts and chimeras can belong to.
enum Strain { UNDEAD, ROBOTIC, DRACONIC, BEAST, ELEMENTAL, ABERRANT, NEUTRAL }

## Rarity tiers for parts and loot.
enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY }

## Equipment slots on a chimera.
enum PartSlot { HEAD, TORSO, ARMS, LEGS }

## Genetic instability levels derived from strain diversity.
enum Instability { PURE, STABLE, VOLATILE, CHAOTIC }

## Whether an ability is active (triggered) or passive (always-on).
enum AbilityType { ACTIVE, PASSIVE }

## Functional category of an ability.
enum AbilityCategory { OFFENSE, MOBILITY, UTILITY, DEFENSE }

## AI targeting modes for selecting combat targets.
enum TargetingMode {
	NEAREST,
	WEAKEST_ACCESSIBLE,
	HIGHEST_THREAT,
	OPTIMAL_DISRUPT,
	ATTACKING_ALLIES,
	LOWEST_HP,
}

## AI positioning tendencies within a formation.
enum Positioning { FRONT, MID, BACK }
