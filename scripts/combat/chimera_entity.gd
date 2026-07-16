class_name ChimeraEntity
extends CharacterBody2D

## Combat entity representing a chimera in the arena.
## Orchestrates components and ticks EffectComponent each frame.
## (FR-2: Chimera entity scene)

signal died(entity: ChimeraEntity)

const ATTACK_RATE_CONSTANT: float = 0.1
const MELEE_THRESHOLD: float = 48.0

var combat_state: CombatState
var attack_timer: float = 0.0
var team: int = 0
var combat_context: CombatContext

@onready var effect_component: EffectComponent = get_node_or_null("EffectComponent")
@onready var ai_controller: AIController = get_node_or_null("AIController")
@onready var ability_component: AbilityComponent = get_node_or_null("AbilityComponent")


func _process(delta: float) -> void:
	if effect_component:
		effect_component.tick(delta)
	if ability_component:
		ability_component.update_cooldowns(delta)
	if combat_state and attack_timer > 0.0:
		attack_timer -= delta


## Moves toward [param target_position] at [member CombatState.speed].
## Sets [member velocity] to direction * speed (NO delta multiplication —
## [method move_and_slide] applies delta internally).
## (FR-4: Movement)
func move_toward_target(target_position: Vector2) -> void:
	var direction: Vector2 = (target_position - global_position).normalized()
	velocity = direction * combat_state.speed
	move_and_slide()


## Calculates damage from [param attacker] to [param defender].
## Formula: max(1.0, effective_attack - effective_defense).
## Berserk: attacker +50% attack, defender -30% defense.
## EffectComponent modifiers applied to both stats after berserk.
## (FR-6: Damage Resolution)
static func calculate_damage(attacker: ChimeraEntity, defender: ChimeraEntity) -> float:
	var base_damage: float = attacker.combat_state.attack
	if attacker.combat_state.is_berserk:
		base_damage *= 1.5
	var defense: float = defender.combat_state.defense
	if defender.combat_state.is_berserk:
		defense *= 0.7
	if attacker.effect_component:
		base_damage = attacker.effect_component.get_modified_stat("attack", base_damage)
	if defender.effect_component:
		defense = defender.effect_component.get_modified_stat("defense", defense)
	return maxf(1.0, base_damage - defense)


## Returns the attack interval in seconds for a given [param speed].
## Formula: 1.0 / (speed * ATTACK_RATE_CONSTANT).
## (FR-7: Attack Cadence)
static func get_attack_interval(speed: float) -> float:
	return 1.0 / (speed * ATTACK_RATE_CONSTANT)


## Returns true when the attack timer has elapsed and the entity can attack.
## (FR-7: Attack Cadence)
func can_attack() -> bool:
	return attack_timer <= 0.0


## Resets the attack timer to the interval based on [member CombatState.speed].
## (FR-7: Attack Cadence)
func reset_attack_timer() -> void:
	attack_timer = get_attack_interval(combat_state.speed)
