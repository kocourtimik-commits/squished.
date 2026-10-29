extends Node2D

const SPEED = 240.0
const GUY_W = 10.0
const GUY_H = 14.0
const FLOOR_H = 40.0
const DASH_TIME = 0.12
const DASH_COOLDOWN = 3.0

var palette = [
	Color("#dc9590"), Color("#deb08e"), Color("#dcd890"), Color("#96db90"),
	Color("#92b3da"), Color("#8f94d8"), Color("#b98fd8"), Color("#dd8fcb"),
	Color("#935a7c"), Color("#a06a6a"), Color("#6aa070"), Color("#009e8a"),
	Color("#5f739e"), Color("#3f5b9a"), Color("#4a62a8"), Color("#7058b0"),
]
var bg_color = Color("#2b282d")
var floor_color = Color("#4f4c49")
var guy_color = Color("#fefefe")
var text_color = Color("#d8d6d8")

var guy_x = 0.0
var walk = 0.0
var facing = 1.0
var dash_dir = 1.0
var dash_left = 0.0
var dash_cd = 0.0
var blocks = []
var timer = 0.0
var score = 0.0
var best = 0
var alive = true


func _ready():
	restart()


func restart():
	blocks.clear()
	score = 0.0
	timer = 0.5
	walk = 0.0
	dash_left = 0.0
	dash_cd = 0.0
	guy_x = get_viewport_rect().size.x / 2
	alive = true


func floor_y(area):
	return area.y - FLOOR_H


func guy_rect(area):
	return Rect2(guy_x - GUY_W / 2, floor_y(area) - GUY_H, GUY_W, GUY_H).grow(-1)


func _process(delta):
	queue_redraw()
	var area = get_viewport_rect().size

	if not alive:
		if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER):
			restart()
		return

	# ovladani: WASD + sipky
	var dir = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir += 1.0
	if dir != 0.0:
		facing = dir

	# dash: mezernik nebo shift
	dash_cd = maxf(0.0, dash_cd - delta)
	var dash_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_SHIFT)
	if dash_pressed and dash_cd <= 0.0 and dash_left <= 0.0:
		dash_left = DASH_TIME
		dash_cd = DASH_COOLDOWN
		dash_dir = facing

	if dash_left > 0.0:
		dash_left -= delta
		guy_x += dash_dir * (area.x / 8.0 / DASH_TIME) * delta
	else:
		guy_x += dir * SPEED * delta
	guy_x = wrapf(guy_x, 0.0, area.x)
	walk += absf(dir) * delta * 14.0

	score += delta * 10
	var fall = 220 + score * 2.5

	timer -= delta
	if timer <= 0:
		timer = maxf(0.35, 1.0 - score * 0.008)
		var w = randf_range(90, 260)
		var h = randf_range(70, 170)
		blocks.append({
			"rect": Rect2(randf_range(0, area.x - w), -h, w, h),
			"color": palette.pick_random(),
		})

	var guy = guy_rect(area)

	for i in range(blocks.size() - 1, -1, -1):
		var r = blocks[i]["rect"]
		r.position.y += fall * delta
		blocks[i]["rect"] = r
		if r.intersects(guy):
			alive = false
			best = max(best, int(score))
		elif r.end.y >= floor_y(area):
			blocks.remove_at(i)


func _draw():
	var area = get_viewport_rect().size
	var font = ThemeDB.fallback_font
	var fy = floor_y(area)

	draw_rect(Rect2(Vector2.ZERO, area), bg_color)
	draw_rect(Rect2(0, fy, area.x, FLOOR_H), floor_color)

	for b in blocks:
		draw_rect(b["rect"], b["color"])

	# panacek
	var gx = guy_x - GUY_W / 2
	var gy = fy - GUY_H
	var step = sin(walk) * 1.5
	if alive:
		draw_rect(Rect2(gx, gy, GUY_W, GUY_H - 4), guy_color)
		draw_rect(Rect2(gx + 1, fy - 4, 3, 4 + step * 0.5), guy_color)
		draw_rect(Rect2(gx + GUY_W - 4, fy - 4, 3, 4 - step * 0.5), guy_color)
		draw_rect(Rect2(gx + 2, gy + 3, 2, 2), bg_color)
		draw_rect(Rect2(gx + GUY_W - 4, gy + 3, 2, 2), bg_color)
	else:
		draw_rect(Rect2(gx - 3, fy - 3, GUY_W + 6, 3), guy_color)

	# cooldown dashe (prouzek pod zemi)
	var ready_amount = 1.0 - dash_cd / DASH_COOLDOWN
	draw_rect(Rect2(area.x / 2 - 40, fy + 16, 80, 4), bg_color)
	draw_rect(Rect2(area.x / 2 - 40, fy + 16, 80 * ready_amount, 4), guy_color)

	draw_string(font, Vector2(16, 32), "%d" % int(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, text_color)

	if not alive:
		draw_string(font, Vector2(0, area.y / 2), "squished.", HORIZONTAL_ALIGNMENT_CENTER, area.x, 48, text_color)
		draw_string(font, Vector2(0, area.y / 2 + 40), "best: %d   press enter" % best, HORIZONTAL_ALIGNMENT_CENTER, area.x, 22, text_color)
