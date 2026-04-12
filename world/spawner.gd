extends Node2D

const ENEMY_SCENE = preload("res://entities/enemies/basic_enemy/basic_enemy.tscn")

# Quantos inimigos vivos queremos por nivel do player
const BASE_COUNT  = 3
const PER_LEVEL   = 1      # +1 por level
const MAX_COUNT   = 12

# Distância de spawn em relação ao player
const SPAWN_MIN   = 350.0
const SPAWN_MAX   = 600.0

var _player: Node2D = null
var _check_timer := 0.0


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_fill_enemies()


func _process(delta: float) -> void:
	if _player == null or _player.dead:
		return
	_check_timer -= delta
	if _check_timer > 0.0:
		return
	_check_timer = 2.0  # checa a cada 2 segundos
	_fill_enemies()


func _fill_enemies() -> void:
	var target := _target_count()
	var current := get_tree().get_nodes_in_group("enemy").size()
	var missing := target - current
	for i in missing:
		_spawn_one()


func _target_count() -> int:
	var lvl: int = _player.level if _player != null else 1
	return clampi(BASE_COUNT + (lvl - 1) * PER_LEVEL, BASE_COUNT, MAX_COUNT)


func _spawn_one() -> void:
	var enemy: Node2D = ENEMY_SCENE.instantiate()
	get_parent().add_child(enemy)
	var angle := randf() * TAU
	var dist  := randf_range(SPAWN_MIN, SPAWN_MAX)
	var origin := _player.global_position if _player != null else Vector2.ZERO
	enemy.global_position = origin + Vector2(cos(angle), sin(angle)) * dist
