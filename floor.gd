extends Node2D

const TILE_W := 64
const TILE_H := 32
const COLS := 30
const ROWS := 30

const COLOR_FILL := Color(0.12, 0.12, 0.18)
const COLOR_EDGE := Color(0.25, 0.25, 0.35)

func _draw() -> void:
	var offset_y := -(COLS + ROWS - 2) * TILE_H / 4.0
	for row in ROWS:
		for col in COLS:
			var cx := (col - row) * TILE_W / 2.0
			var cy := (col + row) * TILE_H / 2.0 + offset_y
			var pts := PackedVector2Array([
				Vector2(cx, cy - TILE_H / 2.0),
				Vector2(cx + TILE_W / 2.0, cy),
				Vector2(cx, cy + TILE_H / 2.0),
				Vector2(cx - TILE_W / 2.0, cy),
			])
			draw_colored_polygon(pts, COLOR_FILL)
			draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), COLOR_EDGE, 1.0)
