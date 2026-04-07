extends CharacterBody2D

const SPEED = 80.0
const DETECTION_RANGE = 350.0
const MAX_HEALTH = 30

var health := MAX_HEALTH
var _player: Node2D = null


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	if global_position.distance_to(_player.global_position) <= DETECTION_RANGE:
		velocity = (_player.global_position - global_position).normalized() * SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()


func _draw() -> void:
	var pts := PackedVector2Array([
		Vector2(0, -20),
		Vector2(16, 0),
		Vector2(0, 20),
		Vector2(-16, 0),
	])
	draw_colored_polygon(pts, Color(0.7, 0.1, 0.1))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(1.0, 0.3, 0.3), 1.5)
