extends CharacterBody2D

const DAMAGE_NUMBER_SCENE = preload("res://ui/damage_number/damage_number.tscn")

const SPEED = 80.0
const DETECTION_RANGE = 350.0
const MAX_HEALTH = 100
const ATTACK_RANGE = 35.0
const ATTACK_DAMAGE = 20
const ATTACK_COOLDOWN = 1.5
const XP_REWARD = 25

# Configuração de cada tipo de DOT: tick_rate, duration, max_stacks, color, label
const DAMAGE_COLORS := {
	"physical": Color(1.0, 1.0, 1.0),
	"fire":     Color(1.0, 0.4, 0.1),
	"poison":   Color(0.2, 0.9, 0.2),
}

const DOT_CONFIG := {
	"fire":   {"tick_rate": 1.0 / 3.0, "duration": 3.0, "max_stacks": 10, "color": Color(1.0, 0.5, 0.0),  "label": "F"},
	"poison": {"tick_rate": 0.5,        "duration": 5.0, "max_stacks": 20, "color": Color(0.2, 0.85, 0.15), "label": "V"},
}

var health := MAX_HEALTH
var _player: Node2D = null
var _dots := {}  # { type: {stacks, remaining, timer} }
var _attack_cd := 0.0
var _attack_flash := 0.0


func _ready() -> void:
	add_to_group("enemy")
	_player = get_tree().get_first_node_in_group("player")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _attack_cd > 0.0:
		_attack_cd -= delta
	if _attack_flash > 0.0:
		_attack_flash -= delta
		if _attack_flash <= 0.0:
			queue_redraw()

	if _player != null:
		var dist := global_position.distance_to(_player.global_position)
		if dist <= ATTACK_RANGE:
			velocity = Vector2.ZERO
			if _attack_cd <= 0.0:
				_attack_player()
		elif dist <= DETECTION_RANGE:
			velocity = (_player.global_position - global_position).normalized() * SPEED
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_tick_dots(delta)


func _attack_player() -> void:
	_attack_cd = ATTACK_COOLDOWN
	_attack_flash = 0.12
	queue_redraw()
	if _player.has_method("take_damage"):
		_player.take_damage(ATTACK_DAMAGE)


func _tick_dots(delta: float) -> void:
	var expired := []
	for type in _dots:
		var dot: Dictionary = _dots[type]
		var cfg: Dictionary = DOT_CONFIG[type]
		dot["remaining"] -= delta
		dot["timer"] += delta
		while dot["timer"] >= cfg["tick_rate"]:
			dot["timer"] -= cfg["tick_rate"]
			take_damage(dot["stacks"], type)
		if dot["remaining"] <= 0.0:
			expired.append(type)
	for type in expired:
		_dots.erase(type)
	if expired.size() > 0:
		queue_redraw()


func take_damage(amount: int, type: String = "physical") -> void:
	health -= amount
	queue_redraw()
	var color: Color = DAMAGE_COLORS.get(type, Color.WHITE)
	_spawn_damage_number(amount, color)
	if health <= 0:
		_die()


func _die() -> void:
	if _player != null and _player.has_method("gain_xp"):
		_player.gain_xp(XP_REWARD)
	queue_free()


func apply_dot(type: String) -> void:
	if not DOT_CONFIG.has(type):
		return
	if not _dots.has(type):
		_dots[type] = {"stacks": 0, "remaining": 0.0, "timer": 0.0}
	var cfg: Dictionary = DOT_CONFIG[type]
	_dots[type]["stacks"] = mini(_dots[type]["stacks"] + 1, cfg["max_stacks"])
	_dots[type]["remaining"] = cfg["duration"]
	queue_redraw()


func _spawn_damage_number(amount: int, color: Color = Color.WHITE) -> void:
	var dn := DAMAGE_NUMBER_SCENE.instantiate()
	get_parent().add_child(dn)
	dn.global_position = global_position + Vector2(randf_range(-8.0, 8.0), -25.0)
	dn.init(amount, color)


func _draw() -> void:
	var font := ThemeDB.fallback_font
	const FONT_SIZE := 9

	# Outline — muda de cor com o DOT mais pesado ativo
	var outline := Color(1.0, 0.3, 0.3)
	var outline_w := 1.5
	for type in _dots:
		var dot: Dictionary = _dots[type]
		if dot["stacks"] > 0:
			var t := float(dot["stacks"]) / float(DOT_CONFIG[type]["max_stacks"])
			outline = DOT_CONFIG[type]["color"]
			outline_w = 1.5 + t * 2.5

	var pts := PackedVector2Array([
		Vector2(0, -20), Vector2(16, 0), Vector2(0, 20), Vector2(-16, 0),
	])
	var body_color := Color(1.0, 0.9, 0.9) if _attack_flash > 0.0 else Color(0.7, 0.1, 0.1)
	draw_colored_polygon(pts, body_color)
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
	draw_string(font, Vector2(bx, by + BAR_H - 1.0), "%d/%d" % [health, MAX_HEALTH],
			HORIZONTAL_ALIGNMENT_CENTER, BAR_W, FONT_SIZE, Color.BLACK)

	# Quadradinhos de DOT ativos
	const SQ := 14.0
	var sq_x := BAR_W / 2.0 + 4.0
	for type in _dots:
		var dot: Dictionary = _dots[type]
		if dot["stacks"] == 0:
			continue
		var cfg: Dictionary = DOT_CONFIG[type]
		var sq_pos := Vector2(sq_x, by)
		draw_rect(Rect2(sq_pos, Vector2(SQ, SQ)), Color(0.1, 0.1, 0.1))
		draw_rect(Rect2(sq_pos, Vector2(SQ, SQ)), cfg["color"], false, 1.0)
		draw_string(font, Vector2(sq_pos.x, sq_pos.y + SQ - 2.0), str(dot["stacks"]),
				HORIZONTAL_ALIGNMENT_CENTER, SQ, FONT_SIZE, cfg["color"].lightened(0.4))
		sq_x += SQ + 3.0
