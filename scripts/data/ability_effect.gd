## A single composable effect within an ability.
##
## Each ability is made up of one or more AbilityEffect instances,
## each defining a type of effect and its parameters.
class_name AbilityEffect
extends Resource

## Types of effects an ability can apply.
enum EffectType {
	DAMAGE,
	HEAL,
	BUFF_STAT,
	DEBUFF_STAT,
	REPOSITION,
	SHIELD,
	CLEANSE,
	REVIVE,
	ENRAGE,
	STAT_MUTATION,
	RANDOM_EFFECT,
}

## The category of effect to apply.
@export var effect_type: EffectType

## Parameters for the effect, keyed by parameter name.
@export var params: Dictionary
