extends CharacterBody2D

const SPEED = 200.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 1.0

var _is_dashing := false
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _dash_direction := Vector2.ZERO
var _last_direction := Vector2.DOWN


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	_tick_dash(delta)

	if _is_dashing:
		velocity = _dash_direction * DASH_SPEED
	else:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if direction != Vector2.ZERO:
			_last_direction = direction
		velocity = direction * SPEED

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_attack()
	elif event.is_action_pressed("skill"):
		_skill()
	elif event.is_action_pressed("dash"):
		_dash()


func _tick_dash(delta: float) -> void:
	if _dash_cooldown > 0.0:
		_dash_cooldown -= delta
	if _is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_is_dashing = false


func _dash() -> void:
	if _is_dashing or _dash_cooldown > 0.0:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	_dash_direction = direction if direction != Vector2.ZERO else _last_direction
	_is_dashing = true
	_dash_timer = DASH_DURATION
	_dash_cooldown = DASH_COOLDOWN


func _attack() -> void:
	var dir := (get_global_mouse_position() - global_position).normalized()
	print("ATTACK dir: ", dir)


func _skill() -> void:
	var dir := (get_global_mouse_position() - global_position).normalized()
	print("SKILL dir: ", dir)
