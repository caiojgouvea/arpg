extends Area2D

const SPEED = 600.0
const MAX_RANGE = 900.0
const DAMAGE = 10

var _direction := Vector2.RIGHT
var _traveled := 0.0
var _color := Color(0.75, 0.75, 0.75)
var _dot_type := ""
var _dot_chance := 0.0
var _on_hit := Callable()


func init(dir: Vector2, color: Color = Color(0.75, 0.75, 0.75), dot_type: String = "", dot_chance: float = 0.0, on_hit: Callable = Callable()) -> void:
	_direction = dir
	_color = color
	_dot_type = dot_type
	_dot_chance = dot_chance
	_on_hit = on_hit
	rotation = dir.angle()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var dmg_type := _dot_type if _dot_type != "" else "physical"
		body.take_damage(DAMAGE, dmg_type)
		if _dot_type != "" and randf() < _dot_chance and body.has_method("apply_dot"):
			body.apply_dot(_dot_type)
		if _on_hit.is_valid():
			_on_hit.call()
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
