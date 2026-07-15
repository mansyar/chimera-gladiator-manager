# gdlint:ignore=max-public-methods
class_name AIController
extends Node

## Finite state machine controller for chimera combat AI.
## Manages state transitions, target acquisition, and berserk checks.
## (FR-2: AIController node, TDD Section 7)

const BERSERK_CHECK_INTERVAL: float = 5.0
const BERSERK_DURATION: float = 5.0

var current_state: AIState
var behavior_module: BehaviorModuleData
var combat_state: CombatState
var target: ChimeraEntity
var states: Dictionary = {}
var combat_context: CombatContext

@onready var entity: ChimeraEntity = get_parent() as ChimeraEntity


func _ready() -> void:
	# State scripts are registered in Task 7.
	# Set initial state to IDLE if available.
	if states.has("IDLE"):
		current_state = states["IDLE"]
		current_state.enter()


## Configures the AI with behavior module, combat state, and combat context.
## Called by the arena/match setup before combat begins.
func setup_ai(
	p_behavior_module: BehaviorModuleData,
	p_combat_state: CombatState,
	p_combat_context: CombatContext
) -> void:
	behavior_module = p_behavior_module
	combat_state = p_combat_state
	combat_context = p_combat_context


## Registers a state instance under the given name.
## Sets the ai_controller reference on the state.
func register_state(state_name: String, state: AIState) -> void:
	state.ai_controller = self
	states[state_name] = state


## Transitions to a new state by name.
## Calls exit() on the current state, swaps, and calls enter() on the new state.
func change_state(new_state: String) -> void:
	if current_state != null:
		current_state.exit()
	current_state = states.get(new_state)
	if current_state != null:
		current_state.enter()


## Acquires a target based on the behavior module's targeting mode.
## Dispatches to one of 6 targeting functions (FR-6, TDD Section 7).
func acquire_target() -> ChimeraEntity:
	var target_found: ChimeraEntity = null
	if combat_context != null and behavior_module != null and entity != null:
		var enemies: Array[ChimeraEntity] = combat_context.get_enemies_of(combat_state.team)
		match behavior_module.targeting:
			GameEnums.TargetingMode.NEAREST:
				target_found = find_nearest(enemies)
			GameEnums.TargetingMode.WEAKEST_ACCESSIBLE:
				target_found = find_lowest_hp_in_range(enemies, combat_state.attack_range)
			GameEnums.TargetingMode.HIGHEST_THREAT:
				target_found = find_highest_attack(enemies)
			GameEnums.TargetingMode.OPTIMAL_DISRUPT:
				target_found = find_highest_attack_targeting_ally(enemies)
			GameEnums.TargetingMode.ATTACKING_ALLIES:
				target_found = find_enemy_attacking_ally(enemies)
			GameEnums.TargetingMode.LOWEST_HP:
				target_found = find_lowest_hp(enemies)
	return target_found


## Finds the nearest enemy by distance to this entity.
func find_nearest(enemies: Array[ChimeraEntity]) -> ChimeraEntity:
	var nearest: ChimeraEntity = null
	var nearest_dist: float = INF
	for enemy in enemies:
		var dist: float = entity.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy
	return nearest


## Finds the enemy with the lowest HP within the given range.
func find_lowest_hp_in_range(enemies: Array[ChimeraEntity], p_range: float) -> ChimeraEntity:
	var weakest: ChimeraEntity = null
	var lowest_hp: float = INF
	for enemy in enemies:
		if entity.global_position.distance_to(enemy.global_position) <= p_range:
			if enemy.combat_state.current_hp < lowest_hp:
				lowest_hp = enemy.combat_state.current_hp
				weakest = enemy
	return weakest


## Finds the enemy with the highest Attack stat.
func find_highest_attack(enemies: Array[ChimeraEntity]) -> ChimeraEntity:
	var strongest: ChimeraEntity = null
	var highest_atk: float = -1.0
	for enemy in enemies:
		if enemy.combat_state.attack > highest_atk:
			highest_atk = enemy.combat_state.attack
			strongest = enemy
	return strongest


## Finds the highest-Attack enemy currently targeting an ally.
func find_highest_attack_targeting_ally(enemies: Array[ChimeraEntity]) -> ChimeraEntity:
	var best: ChimeraEntity = null
	var highest_atk: float = -1.0
	for enemy in enemies:
		if enemy.ai_controller and enemy.ai_controller.target:
			if enemy.ai_controller.target.team == combat_state.team:
				if enemy.combat_state.attack > highest_atk:
					highest_atk = enemy.combat_state.attack
					best = enemy
	return best


## Finds an enemy currently attacking (targeting) an ally.
func find_enemy_attacking_ally(enemies: Array[ChimeraEntity]) -> ChimeraEntity:
	for enemy in enemies:
		if enemy.ai_controller and enemy.ai_controller.target:
			if enemy.ai_controller.target.team == combat_state.team:
				return enemy
	return null


## Finds the enemy with the lowest current HP overall.
func find_lowest_hp(enemies: Array[ChimeraEntity]) -> ChimeraEntity:
	var weakest: ChimeraEntity = null
	var lowest_hp: float = INF
	for enemy in enemies:
		if enemy.combat_state.current_hp < lowest_hp:
			lowest_hp = enemy.combat_state.current_hp
			weakest = enemy
	return weakest


## Returns the move position for the given target based on positioning mode.
## FRONT: melee closes distance, ranged kites when too close.
## MID: ranged holds at 90% of attack range, melee approaches.
## BACK: ranged flees if approached, melee holds if front-line allies exist.
func get_move_position(target: ChimeraEntity) -> Vector2:
	if target == null or entity == null or behavior_module == null:
		return Vector2.ZERO
	var distance: float = entity.global_position.distance_to(target.global_position)
	var is_ranged: bool = combat_state.attack_range > ChimeraEntity.MELEE_THRESHOLD
	var pos: Vector2 = entity.global_position

	match behavior_module.positioning:
		GameEnums.Positioning.FRONT:
			if is_ranged and distance < combat_state.attack_range * 0.8:
				var direction: Vector2 = (
					(entity.global_position - target.global_position).normalized()
				)
				pos = target.global_position + direction * combat_state.attack_range
			else:
				pos = target.global_position

		GameEnums.Positioning.MID:
			if is_ranged:
				var direction: Vector2 = (
					(entity.global_position - target.global_position).normalized()
				)
				pos = (target.global_position + direction * combat_state.attack_range * 0.9)
			else:
				pos = target.global_position

		GameEnums.Positioning.BACK:
			if is_ranged:
				if distance < combat_state.attack_range * 0.7:
					var direction: Vector2 = (
						(entity.global_position - target.global_position).normalized()
					)
					pos = entity.global_position + direction * 100.0
				else:
					pos = entity.global_position
			elif has_front_line_allies():
				pos = entity.global_position
			else:
				pos = target.global_position

	return pos


## Checks if any allies (excluding self) have FRONT positioning.
func has_front_line_allies() -> bool:
	if combat_context == null:
		return false
	var allies: Array[ChimeraEntity] = combat_context.get_allies_of(combat_state.team)
	for ally in allies:
		if ally == entity:
			continue
		if ally.ai_controller and ally.ai_controller.behavior_module:
			if ally.ai_controller.behavior_module.positioning == GameEnums.Positioning.FRONT:
				return true
	return false


## Returns the next ready ability based on priority ordering.
## Iterates behavior_module.ability_priority categories and checks
## each ability (part_abilities + combo_ability) for category match
## and cooldown status via AbilityComponent (FR-7, TDD Section 7).
func get_next_ready_ability() -> AbilityData:
	if behavior_module == null or combat_state == null:
		return null
	if entity == null or entity.ability_component == null:
		return null
	var chimera_data: ChimeraData = combat_state.chimera_data
	if chimera_data == null:
		return null
	var all_abilities: Array[AbilityData] = chimera_data.part_abilities.duplicate()
	if chimera_data.combo_ability != null:
		all_abilities.append(chimera_data.combo_ability)
	for category in behavior_module.ability_priority:
		for ability in all_abilities:
			if ability.category == category and entity.ability_component.is_off_cooldown(ability):
				return ability
	return null


func _process(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)
	check_berserk(delta)


## Checks for berserk trigger based on instability level and accumulated modifiers.
## Purebreds (instability == 0) are immune. Every BERSERK_CHECK_INTERVAL seconds,
## rolls chance = base_probability + sum(modifiers). Modifiers cleared after roll.
## Called every frame from _process (FR-8, GDD Section 2.4).
func check_berserk(delta: float) -> void:
	if combat_state == null:
		return
	var chimera_data: ChimeraData = combat_state.chimera_data
	if chimera_data == null:
		return
	if chimera_data.instability == 0:
		return
	combat_state.berserk_check_timer += delta
	if combat_state.berserk_check_timer >= BERSERK_CHECK_INTERVAL:
		combat_state.berserk_check_timer = 0.0
		var chance: float = get_berserk_chance()
		combat_state.berserk_modifiers.clear()
		if randf() < chance:
			enter_berserk()


## Returns the current berserk probability: base + sum of event modifiers.
## Base: PURE=0%, STABLE=3%, VOLATILE=8%, CHAOTIC=15% (FR-8, GDD Section 2.4).
func get_berserk_chance() -> float:
	if combat_state == null or combat_state.chimera_data == null:
		return 0.0
	var base: float = 0.0
	match combat_state.chimera_data.instability:
		GameEnums.Instability.STABLE:
			base = 0.03
		GameEnums.Instability.VOLATILE:
			base = 0.08
		GameEnums.Instability.CHAOTIC:
			base = 0.15
		_:
			base = 0.0
	var modifier_sum: float = 0.0
	for value in combat_state.berserk_modifiers.values():
		modifier_sum += value
	return base + modifier_sum


## Adds a berserk modifier when HP drops below 30% (FR-8, GDD Section 2.4).
func on_hp_low() -> void:
	if combat_state != null:
		combat_state.berserk_modifiers["hp_low"] = 0.15


## Adds a berserk modifier when hit by a disruption ability (FR-8, GDD Section 2.4).
func on_disrupted() -> void:
	if combat_state != null:
		combat_state.berserk_modifiers["disrupted"] = 0.10


## Adds a berserk modifier when landing a killing blow (FR-8, GDD Section 2.4).
func on_killing_blow() -> void:
	if combat_state != null:
		combat_state.berserk_modifiers["killing_blow"] = 0.05


## Triggers an immediate berserk roll when an ally dies.
## Uses accumulated modifiers + base. Modifiers cleared after roll (FR-8).
func on_ally_death() -> void:
	if combat_state == null:
		return
	var chimera_data: ChimeraData = combat_state.chimera_data
	if chimera_data == null or chimera_data.instability == 0:
		return
	var chance: float = get_berserk_chance()
	combat_state.berserk_modifiers.clear()
	if randf() < chance:
		enter_berserk()


## Enters berserk state: sets is_berserk, berserk_timer, transitions to BERSERK
## state, and emits EventBus.berserk_triggered (FR-8, GDD Section 2.4).
func enter_berserk() -> void:
	if combat_state == null:
		return
	combat_state.is_berserk = true
	combat_state.berserk_timer = BERSERK_DURATION
	change_state("BERSERK")
	EventBus.berserk_triggered.emit(combat_state.chimera_data)
