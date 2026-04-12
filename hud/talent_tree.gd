extends Node2D

const PANEL_W  := 760.0
const PANEL_H  := 520.0
const NODE_R   := 13.0   # passiva (círculo)
const NODE_SQ  := 15.0   # modificador de skill (quadrado, half-size)
const MASTER_R := 21.0   # master node (círculo grande)

const CORNER_COLORS := {
	"instinct": Color(0.2,  0.85, 0.2),
	"fury":     Color(0.95, 0.2,  0.2),
	"arcane":   Color(0.65, 0.2,  0.95),
}

# shape: "circle" = passiva  |  "square" = modifica skill  |  "master" = keystione
const NODES := {
	# ── Layer 1 — Identidade ───────────────────────────────────────────
	"i_l1_c": {"label": "Reflexo",         "desc": "+10% Atk Speed",       "cost": 1, "requires": [],                    "effect": {"atk_speed": 0.10},               "shape": "circle", "pos": Vector2(490, 105)},
	"i_l1_a": {"label": "Pulmao de Ferro", "desc": "+20 Folego maximo",    "cost": 1, "requires": [],                    "effect": {"folego_bonus": 20.0},            "shape": "circle", "pos": Vector2(590, 105)},
	"i_l1_b": {"label": "Mao Firme",       "desc": "+10 Dano Fisico",      "cost": 1, "requires": [],                    "effect": {"phys_dmg": 10},                  "shape": "circle", "pos": Vector2(680, 105)},
	# ── Layer 2 — Especializacao ────────────────────────────────────────
	"i_l2_d": {"label": "Precisao",        "desc": "+3% critico",          "cost": 1, "requires": [],            "effect": {"crit": 0.03},                    "shape": "circle", "pos": Vector2(430, 215)},
	"i_l2_c": {"label": "Alcance",         "desc": "+200 range",           "cost": 1, "requires": [], "effect": {"arrow_range": 200.0},            "shape": "circle", "pos": Vector2(510, 215)},
	"i_l2_a": {"label": "Recuperacao",     "desc": "Hit: +15 Folego",      "cost": 1, "requires": [],            "effect": {"folego_on_hit": 15.0},           "shape": "square", "pos": Vector2(590, 215)},
	"i_l2_b": {"label": "Flecha de Chama", "desc": "+25% fire no auto",    "cost": 1, "requires": [],            "effect": {"fire_chance": 0.25},             "shape": "square", "pos": Vector2(680, 215)},
	# ── Layer 3 — Limiar ────────────────────────────────────────────────
	"i_l3_b": {"label": "Artilheiro",      "desc": "+5% crit  +150 range", "cost": 2, "requires": [], "effect": {"crit": 0.05, "arrow_range": 150.0}, "shape": "square", "pos": Vector2(470, 335)},
	"i_l3_a": {"label": "Forca do Arco",   "desc": "+25 Dano Fisico",      "cost": 2, "requires": [], "effect": {"phys_dmg": 25},                  "shape": "square", "pos": Vector2(635, 335)},
	# ── Master Node ─────────────────────────────────────────────────────
	"i_master": {"label": "Perfuracao",    "desc": "Flechas atravessam\n+1 inimigo", "cost": 3, "requires": [], "effect": {"arrow_pierce": 1}, "shape": "master", "pos": Vector2(552, 445)},
}

# Nós visuais placeholder (sem efeito)
const PLACEHOLDERS := [
	{"pos": Vector2(85,  410), "corner": "fury"},
	{"pos": Vector2(145, 445), "corner": "fury"},
	{"pos": Vector2(85,  95),  "corner": "arcane"},
	{"pos": Vector2(145, 75),  "corner": "arcane"},
]

var _open     := false
var _player   : Node = null
var _unlocked := {}
var _node_rects := {}
var _hovered  := ""


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	_player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if not _open:
		return
	var mouse := get_viewport().get_mouse_position()
	var new_hover := ""
	for id in _node_rects:
		if _node_rects[id].has_point(mouse):
			new_hover = id
			break
	if new_hover != _hovered:
		_hovered = new_hover
		queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_Y:
			_open = not _open
			get_tree().paused = _open
			queue_redraw()
			return

	if _open and event is InputEventMouseButton \
			and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for id in _node_rects:
			if _node_rects[id].has_point(event.position):
				_try_unlock(id)
				return


func _try_unlock(id: String) -> void:
	if _unlocked.get(id, false):
		return
	var node: Dictionary = NODES[id]
	if _player == null or _player.talent_points < node["cost"]:
		return
	for req in node["requires"]:
		if not _unlocked.get(req, false):
			return
	_player.talent_points -= node["cost"]
	_unlocked[id] = true
	_apply_effect(node["effect"])
	queue_redraw()


func _apply_effect(effect: Dictionary) -> void:
	for key in effect:
		match key:
			"folego_bonus":  _player.talent_folego_bonus  += effect[key]
			"phys_dmg":      _player.talent_phys_dmg      += effect[key]
			"atk_speed":     _player.talent_atk_speed     += effect[key]
			"crit":          _player.talent_crit          += effect[key]
			"folego_on_hit": _player.talent_folego_on_hit += effect[key]
			"arrow_range":   _player.talent_arrow_range   += effect[key]
			"fire_chance":   _player.talent_fire_chance   += effect[key]
			"arrow_pierce":  _player.arrow_pierce         += effect[key]


# ─── DRAW ───────────────────────────────────────────────────────────────────

func _draw() -> void:
	if not _open or _player == null:
		return

	var font := ThemeDB.fallback_font
	var vp   := get_viewport_rect().size
	var ox   := (vp.x - PANEL_W) / 2.0
	var oy   := (vp.y - PANEL_H) / 2.0

	# Fundo
	draw_rect(Rect2(ox, oy, PANEL_W, PANEL_H), Color(0.06, 0.06, 0.1, 0.97))
	draw_rect(Rect2(ox, oy, PANEL_W, PANEL_H), Color(0.35, 0.35, 0.45), false, 1.5)

	# Header
	draw_string(font, Vector2(ox, oy + 22.0), "ARVORE DE TALENTOS",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 14, Color.WHITE)
	var pts_color := Color(0.6, 0.4, 0.9) if _player.talent_points > 0 else Color(0.4, 0.4, 0.4)
	draw_string(font, Vector2(ox, oy + 38.0), "Pontos disponveis: %d" % _player.talent_points,
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 10, pts_color)

	# Separador
	draw_line(Vector2(ox + 20, oy + 44), Vector2(ox + PANEL_W - 20, oy + 44),
			Color(0.2, 0.2, 0.28), 1.0)

	# Corner labels
	draw_string(font, Vector2(ox + 12, oy + 466), "FURIA",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, CORNER_COLORS["fury"])
	draw_string(font, Vector2(ox + 12, oy + 90), "ARCANO",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, CORNER_COLORS["arcane"])

	# Subtree label
	var inst_col: Color = CORNER_COLORS["instinct"]
	draw_string(font, Vector2(ox + 420, oy + 62), "INSTINTO  —  Arqueiro",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, inst_col)

	# Legend
	_draw_legend(font, ox, oy)

	# Layer labels
	var layer_x := ox + 18.0
	var lc := Color(0.28, 0.28, 0.35)
	draw_string(font, Vector2(layer_x, oy + 110), "Identidade",    HORIZONTAL_ALIGNMENT_LEFT, -1, 8, lc)
	draw_string(font, Vector2(layer_x, oy + 220), "Especializacao",HORIZONTAL_ALIGNMENT_LEFT, -1, 8, lc)
	draw_string(font, Vector2(layer_x, oy + 340), "Limiar",        HORIZONTAL_ALIGNMENT_LEFT, -1, 8, lc)
	draw_string(font, Vector2(layer_x, oy + 450), "Keystone",      HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.7, 0.6, 0.1))

	# Placeholders
	for ph in PLACEHOLDERS:
		var ppos: Vector2 = Vector2(ox, oy) + (ph as Dictionary)["pos"]
		var pcol: Color = CORNER_COLORS[(ph as Dictionary)["corner"]]
		draw_circle(ppos, NODE_R, Color(0.09, 0.09, 0.13))
		draw_arc(ppos, NODE_R, 0, TAU, 32, pcol.darkened(0.55), 1.0)
		draw_string(font, ppos + Vector2(-4, 4), "?",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, pcol.darkened(0.45))

	# Conexões (antes dos nós)
	for id in NODES:
		var node: Dictionary = NODES[id]
		var npos: Vector2 = Vector2(ox, oy) + (node["pos"] as Vector2)
		var nr: float = _shape_r(node["shape"] as String)
		for req in node["requires"]:
			var rnode: Dictionary = NODES[req]
			var rpos: Vector2 = Vector2(ox, oy) + (rnode["pos"] as Vector2)
			var rr: float = _shape_r(rnode["shape"] as String)
			var both: bool = _unlocked.get(id, false) and _unlocked.get(req, false)
			var req_done: bool = _unlocked.get(req, false)
			var line_col := Color(0.28, 0.65, 0.28, 0.9) if both \
					else (Color(0.22, 0.38, 0.22, 0.7) if req_done else Color(0.2, 0.2, 0.26, 0.8))
			_draw_arrow(rpos, npos, rr, nr, line_col)

	# Nós funcionais
	_node_rects.clear()
	for id in NODES:
		_draw_node(font, ox, oy, id)

	# Tooltip
	if _hovered != "":
		_draw_tooltip(font, ox, oy)

	# Footer
	draw_string(font, Vector2(ox, oy + PANEL_H - 8.0), "[Y] Fechar",
			HORIZONTAL_ALIGNMENT_CENTER, PANEL_W, 10, Color(0.28, 0.28, 0.36))


func _draw_legend(font: Font, ox: float, oy: float) -> void:
	var lx := ox + PANEL_W - 155.0
	var ly := oy + 60.0
	draw_string(font, Vector2(lx, ly), "Legenda:", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.45, 0.45, 0.5))
	# Círculo = passiva
	draw_circle(Vector2(lx + 7, ly + 14), 6.0, Color(0.12, 0.12, 0.18))
	draw_arc(Vector2(lx + 7, ly + 14), 6.0, 0, TAU, 24, Color(0.5, 0.5, 0.55), 1.0)
	draw_string(font, Vector2(lx + 17, ly + 18), "Passiva", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.55, 0.55, 0.6))
	# Quadrado = modificador
	draw_rect(Rect2(lx + 1, ly + 26, 12, 12), Color(0.12, 0.12, 0.18))
	draw_rect(Rect2(lx + 1, ly + 26, 12, 12), Color(0.5, 0.5, 0.55), false, 1.0)
	draw_string(font, Vector2(lx + 17, ly + 36), "Modificador", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.55, 0.55, 0.6))
	# Círculo dourado = keystone
	draw_circle(Vector2(lx + 7, ly + 56), 6.0, Color(0.12, 0.1, 0.05))
	draw_arc(Vector2(lx + 7, ly + 56), 6.0, 0, TAU, 24, Color(0.85, 0.7, 0.1), 1.0)
	draw_string(font, Vector2(lx + 17, ly + 60), "Keystone", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.75, 0.65, 0.2))


func _draw_arrow(from_pos: Vector2, to_pos: Vector2, r_from: float, r_to: float, color: Color) -> void:
	var dir := (to_pos - from_pos).normalized()
	var start := from_pos + dir * r_from
	var end   := to_pos   - dir * r_to
	if start.distance_to(end) < 4.0:
		return
	draw_line(start, end, color, 1.5)
	# Arrowhead
	var perp := Vector2(-dir.y, dir.x)
	var ah   := 6.0
	draw_line(end, end - dir * ah + perp * (ah * 0.45), color, 1.5)
	draw_line(end, end - dir * ah - perp * (ah * 0.45), color, 1.5)


func _draw_node(font: Font, ox: float, oy: float, id: String) -> void:
	var node: Dictionary  = NODES[id]
	var npos: Vector2     = Vector2(ox, oy) + (node["pos"] as Vector2)
	var shape: String     = node["shape"] as String
	var unlocked: bool    = _unlocked.get(id, false)
	var can_unlock: bool  = _can_unlock(id)
	var hovered: bool     = _hovered == id
	var base: Color       = CORNER_COLORS["instinct"]

	var fill: Color
	if unlocked:       fill = base.darkened(0.3)
	elif can_unlock:   fill = Color(0.1, 0.17, 0.1)
	else:              fill = Color(0.08, 0.08, 0.11)

	var border: Color
	if unlocked:       border = base
	elif can_unlock:   border = base.darkened(0.3)
	elif hovered:      border = Color(0.5, 0.5, 0.55)
	else:              border = Color(0.22, 0.22, 0.28)

	var r := _shape_r(shape)

	match shape:
		"circle", "master":
			draw_circle(npos, r, fill)
			if shape == "master":
				# Anel dourado externo
				var gold := Color(0.85, 0.7, 0.1) if unlocked else Color(0.45, 0.38, 0.08)
				draw_arc(npos, r + 4, 0, TAU, 64, gold, 1.5)
				draw_arc(npos, r + 6, 0, TAU, 64, gold.darkened(0.4), 1.0)
			draw_arc(npos, r, 0, TAU, 48, border, 1.5)
		"square":
			var rect := Rect2(npos - Vector2(r, r), Vector2(r * 2, r * 2))
			draw_rect(rect, fill)
			draw_rect(rect, border, false, 1.5)
			if hovered and not unlocked:
				draw_rect(rect.grow(2.0), border.lightened(0.2), false, 0.8)

	# Ícone de status
	if unlocked:
		draw_string(font, npos + Vector2(-4, 4), "V",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)
	elif shape == "master" and can_unlock:
		draw_string(font, npos + Vector2(-4, 5), "*",
				HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.8, 0.2))

	# Badge de custo
	if not unlocked:
		var cost: int = node["cost"] as int
		var bp: Vector2 = npos + Vector2(r, -r)
		draw_circle(bp, 7.5, Color(0.06, 0.06, 0.1))
		var badge_col := Color(0.7, 0.55, 0.0) if can_unlock else Color(0.35, 0.3, 0.08)
		draw_arc(bp, 7.5, 0, TAU, 16, badge_col, 1.0)
		draw_string(font, bp + Vector2(-3, 4), str(cost),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 8,
				Color(0.95, 0.8, 0.1) if can_unlock else Color(0.45, 0.4, 0.15))

	# Label abaixo
	var lc: Color
	if unlocked:       lc = base
	elif can_unlock:   lc = Color(0.75, 0.75, 0.8)
	else:              lc = Color(0.35, 0.35, 0.4)
	draw_string(font, Vector2(npos.x - 46, npos.y + r + 12), node["label"] as String,
			HORIZONTAL_ALIGNMENT_CENTER, 92.0, 8, lc)

	# Click rect
	_node_rects[id] = Rect2(npos - Vector2(r + 4, r + 4), Vector2((r + 4) * 2, (r + 4) * 2))


func _draw_tooltip(font: Font, ox: float, oy: float) -> void:
	var node: Dictionary  = NODES[_hovered]
	var npos: Vector2     = Vector2(ox, oy) + (node["pos"] as Vector2)
	var base: Color       = CORNER_COLORS["instinct"]
	var unlocked: bool    = _unlocked.get(_hovered, false)
	var can_unlock: bool  = _can_unlock(_hovered)
	var shape: String     = node["shape"] as String

	var type_str := "Passiva" if shape == "circle" else ("Keystone" if shape == "master" else "Modificador")
	var lines: Array = [node["label"] as String, "(%s)" % type_str, node["desc"] as String,
		"Custo: %d ponto%s" % [node["cost"], "s" if (node["cost"] as int) > 1 else ""]]
	if unlocked:
		lines.append("[ Desbloqueado ]")
	elif not can_unlock:
		lines.append("Sem pontos" if _player.talent_points < (node["cost"] as int) else "Requer nos anteriores")

	var TW := 160.0
	var TH := float(lines.size()) * 14.0 + 12.0
	var tx := clampf(npos.x - TW / 2.0, ox + 4.0, ox + PANEL_W - TW - 4.0)
	var ty := npos.y - TH - 12.0
	if ty < oy + 50.0:
		ty = npos.y + 30.0

	draw_rect(Rect2(tx, ty, TW, TH), Color(0.05, 0.05, 0.1, 0.96))
	draw_rect(Rect2(tx, ty, TW, TH), base.darkened(0.3) if not unlocked else base, false, 1.0)
	var cy := ty + 13.0
	for i in lines.size():
		var lc: Color
		if i == 0:    lc = base.lightened(0.1)
		elif i == 1:  lc = Color(0.45, 0.45, 0.5)
		elif i == 2:  lc = Color(0.85, 0.85, 0.9)
		else:         lc = Color(0.5, 0.5, 0.55)
		draw_string(font, Vector2(tx + 7, cy), lines[i] as String,
				HORIZONTAL_ALIGNMENT_LEFT, TW - 12.0, 9, lc)
		cy += 14.0


# ─── HELPERS ────────────────────────────────────────────────────────────────

func _shape_r(shape: String) -> float:
	match shape:
		"square": return NODE_SQ
		"master": return MASTER_R
		_:        return NODE_R


func _can_unlock(id: String) -> bool:
	if _unlocked.get(id, false):
		return false
	var node: Dictionary = NODES[id]
	if _player == null or _player.talent_points < (node["cost"] as int):
		return false
	for req in node["requires"]:
		if not _unlocked.get(req, false):
			return false
	return true
