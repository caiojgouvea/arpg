extends CharacterBody2D

const ARROW_SCENE = preload("res://skills/arrow/arrow.tscn")

const BASE_SPEED = 200.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 1.0
const BASE_ATTACK_COOLDOWN = 0.3
const SKILL_FOLEGO_COST = 30.0
const SKILL_COOLDOWNS := {"fire": 1.5, "poison": 0.25}

const BASE_HEALTH = 100
const BASE_FOLEGO = 100.0
const BASE_MANA = 100.0
const FOLEGO_REGEN = 25.0
const MANA_REGEN = 5.0

# Atributos
var fury := 0
var instinct := 0
var arcane := 0
var attribute_points := 5
var level := 1
var talent_points := 0
var xp := 0
var xp_to_next := 30

# Stats derivados — calculados em tempo real
var MAX_HEALTH: int:
	get: return BASE_HEALTH + fury * 5
var MAX_FOLEGO: float:
	get: return BASE_FOLEGO + instinct * 5.0
var MAX_MANA: float:
	get: return BASE_MANA + arcane * 5.0
var move_speed: float:
	get: return BASE_SPEED * (1.0 + instinct * 0.005)
var attack_speed: float:
	get: return 1.0 + instinct * 0.02
var physical_damage: int:
	get: return fury * 2
var magic_damage: int:
	get: return arcane * 2
var crit_chance: float:
	get: return instinct * 0.003

var health := BASE_HEALTH
var folego := BASE_FOLEGO
var mana := BASE_MANA

var dead := false

var _is_dashing := false
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _dash_direction := Vector2.ZERO
var _last_direction := Vector2.DOWN
var _attack_cooldown := 0.0
var _skill_cooldowns := {"fire": 0.0, "poison": 0.0}
var _skill_bar: Node = null
var _hit_flash := 0.0
var _level_up_flash := 0.0


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	look_at(get_global_mouse_position())
	_tick_timers(delta)
	_update_folego(delta)

	if _is_dashing:
		velocity = _dash_direction * DASH_SPEED
	else:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if direction != Vector2.ZERO:
			_last_direction = direction
		velocity = direction * move_speed

	if Input.is_action_pressed("attack") and _attack_cooldown <= 0.0:
		_attack()

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if dead:
		return
	if event.is_action_pressed("skill"):
		_skill()
	elif event.is_action_pressed("dash"):
		_dash()


func _tick_timers(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta
	for key in _skill_cooldowns:
		if _skill_cooldowns[key] > 0.0:
			_skill_cooldowns[key] -= delta
	if _dash_cooldown > 0.0:
		_dash_cooldown -= delta
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false
	if _level_up_flash > 0.0:
		_level_up_flash -= delta
		modulate = Color(1.0, 1.0, 0.0) if int(_level_up_flash * 8) % 2 == 0 else Color.WHITE
		if _level_up_flash <= 0.0:
			modulate = Color.WHITE
	elif _hit_flash > 0.0:
		_hit_flash -= delta
		modulate = Color(1.0, 0.25, 0.25) if _hit_flash > 0.0 else Color.WHITE


func take_damage(amount: int, _type: String = "physical") -> void:
	if dead:
		return
	health = max(health - amount, 0)
	_hit_flash = 0.15
	modulate = Color(1.0, 0.25, 0.25)
	if health <= 0:
		_die()


func _die() -> void:
	dead = true
	modulate = Color(0.4, 0.0, 0.0, 0.6)


func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		_level_up()


func _level_up() -> void:
	level += 1
	attribute_points += 5
	talent_points += 1
	xp_to_next = 30 * level
	_level_up_flash = 1.5


func _update_folego(delta: float) -> void:
	if velocity.length() > 10.0:
		folego = minf(folego + FOLEGO_REGEN * delta, MAX_FOLEGO)
	mana = minf(mana + MANA_REGEN * delta, MAX_MANA)


func _attack() -> void:
	_attack_cooldown = BASE_ATTACK_COOLDOWN / attack_speed
	var dir := (get_global_mouse_position() - global_position).normalized()
	var arrow := ARROW_SCENE.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	arrow.init(dir, Color(0.75, 0.75, 0.75), "", 0.0, _on_arrow_hit)


func _on_arrow_hit() -> void:
	folego = minf(folego + 10.0, MAX_FOLEGO)


func _dash() -> void:
	if _is_dashing or _dash_cooldown > 0.0:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_dash_direction = direction if direction != Vector2.ZERO else _last_direction
	_is_dashing = true
	_dash_timer = DASH_DURATION
	_dash_cooldown = DASH_COOLDOWN


func _skill() -> void:
	if _skill_bar == null:
		_skill_bar = get_tree().get_first_node_in_group("skill_bar")
	var selected: String = _skill_bar.get_selected_skill() if _skill_bar != null else "fire"

	if _skill_cooldowns.get(selected, 0.0) > 0.0 or folego < SKILL_FOLEGO_COST:
		return
	var base_cd: float = SKILL_COOLDOWNS.get(selected, 1.5)
	_skill_cooldowns[selected] = base_cd / attack_speed
	folego -= SKILL_FOLEGO_COST

	match selected:
		"fire":   _cast_fire_arrows()
		"poison": _cast_poison_arrow()


func _cast_fire_arrows() -> void:
	var mouse_pos := get_global_mouse_position()
	var base_dir := (mouse_pos - global_position).normalized()
	var dist := global_position.distance_to(mouse_pos)
	var spread := clampf(remap(dist, 40.0, 600.0, 0.2, 0.003), 0.003, 0.2)
	for angle in [-spread, 0.0, spread]:
		var arrow := ARROW_SCENE.instantiate()
		get_parent().add_child(arrow)
		arrow.global_position = global_position
		arrow.init(base_dir.rotated(angle), Color(1.0, 0.35, 0.05), "fire", 0.25)


func _cast_poison_arrow() -> void:
	var dir := (get_global_mouse_position() - global_position).normalized()
	var arrow := ARROW_SCENE.instantiate()
	get_parent().add_child(arrow)
	arrow.global_position = global_position
	arrow.init(dir, Color(0.2, 0.85, 0.15), "poison", 0.35)
