extends CharacterBody2D

const DAMAGE_NUMBER_SCENE = preload("res://ui/damage_number/damage_number.tscn")

const SPEED = 80.0
const DETECTION_RANGE = 350.0
const MAX_HEALTH = 1000
const BURN_DURATION = 3.0
const BURN_TICK_RATE = 1.0 / 3.0
const MAX_BURN_STACKS = 10

var health := MAX_HEALTH
var _player: Node2D = null
var _burn_stacks := 0
var _burn_timer := 0.0
var _burn_remaining := 0.0


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _player != null and global_position.distance_to(_player.global_position) <= DETECTION_RANGE:
		velocity = (_player.global_position - global_position).normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if _burn_remaining > 0.0:
		_burn_remaining -= delta
		_burn_timer += delta
		while _burn_timer >= BURN_TICK_RATE:
			_burn_timer -= BURN_TICK_RATE
			take_damage(_burn_stacks)
		if _burn_remaining <= 0.0:
			_burn_stacks = 0
			_burn_remaining = 0.0
			_burn_timer = 0.0
			queue_redraw()


func take_damage(amount: int) -> void:
	health -= amount
	queue_redraw()
	_spawn_damage_number(amount)
	if health <= 0:
		queue_free()


func apply_burn() -> void:
	_burn_stacks = mini(_burn_stacks + 1, MAX_BURN_STACKS)
	_burn_remaining = BURN_DURATION
	queue_redraw()


func _spawn_damage_number(amount: int) -> void:
	var dn := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-8.0, 8.0), -25.0)
	dn.init(amount)


func _draw() -> void:
	var font := ThemeDB.fallback_font
	const FONT_SIZE := 9

	# Outline do contorno varia com stacks de fogo
	var outline := Color(1.0, 0.3, 0.3)
	var outline_w := 1.5
	if _burn_stacks > 0:
		var t := float(_burn_stacks) / float(MAX_BURN_STACKS)
		outline = Color(1.0, 0.45 + t * 0.55, t * 0.3)
		outline_w = 1.5 + t * 2.5

	var pts := PackedVector2Array([
		Vector2(0, -20), Vector2(16, 0), Vector2(0, 20), Vector2(-16, 0),
	])
	draw_colored_polygon(pts, Color(0.7, 0.1, 0.1))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), outline, outline_w)

	# Barra de HP
	const BAR_W := 44.0
	const BAR_H := 7.0
	var bx := -BAR_W / 2.0
	var by := -34.0
	var fill := (float(health) / float(MAX_HEALTH)) * BAR_W
	draw_rect(Rect2(bx, by, BAR_W, BAR_H), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(bx, by, fill, BAR_H), Color(0.2, 0.85, 0.2))
	draw_rect(Rect2(bx, by, BAR_W, BAR_H), Color(0, 0, 0), false, 1.0)

	var hp_text := "%d/%d" % [health, MAX_HEALTH]
	draw_string(font, Vector2(bx, by + BAR_H - 1.0), hp_text,
			HORIZONTAL_ALIGNMENT_CENTER, BAR_W, FONT_SIZE, Color.BLACK)

	# Quadradinho de stacks de fogo
	if _burn_stacks > 0:
		const SQ := 14.0
		var sq_pos := Vector2(BAR_W / 2.0 + 4.0, by)
		draw_rect(Rect2(sq_pos, Vector2(SQ, SQ)), Color(0.15, 0.15, 0.15))
		draw_rect(Rect2(sq_pos, Vector2(SQ, SQ)), Color(1.0, 0.5, 0.0), false, 1.0)
		draw_string(font, Vector2(sq_pos.x, sq_pos.y + SQ - 2.0), str(_burn_stacks),
				HORIZONTAL_ALIGNMENT_CENTER, SQ, FONT_SIZE, Color(1.0, 0.8, 0.0))
