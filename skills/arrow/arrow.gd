extends Area2D

const SPEED = 600.0
const MAX_RANGE = 900.0
const DAMAGE = 10
const BURN_CHANCE = 0.25

var _direction := Vector2.RIGHT
var _traveled := 0.0
var _color := Color(0.75, 0.75, 0.75)
var _is_fire := false


func init(dir: Vector2, color: Color = Color(0.75, 0.75, 0.75), is_fire: bool = false) -> void:
	_direction = dir
	_color = color
	_is_fire = is_fire
	rotation = dir.angle()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		if _is_fire and randf() < BURN_CHANCE and body.has_method("apply_burn"):
			body.apply_burn()
		queue_free()


func _process(delta: float) -> void:
	var step := _direction * SPEED * delta
	global_position += step
	_traveled += step.length()
	if _traveled >= MAX_RANGE:
		queue_free()


func _draw() -> void:
	draw_line(Vector2(-14, 0), Vector2(8, 0), _color, 2.0)
	draw_line(Vector2(5, -4), Vector2(12, 0), _color, 2.0)
	draw_line(Vector2(5,  4), Vector2(12, 0), _color, 2.0)
	draw_line(Vector2(-10, 0), Vector2(-14, -4), _color, 1.5)
	draw_line(Vector2(-10, 0), Vector2(-14,  4), _color, 1.5)
