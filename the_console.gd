extends Node3D
class_name TableGrid
var rng = RandomNumberGenerator.new()

@export var size: Vector2i  # 使用 Vector2i 表示列数和行数
@export var num_diamonds: int
## UI clearance, expressed in *screen pixels* at this design reference
## resolution (matching responsive_canvas.gd's DESIGN_W/DESIGN_H), then
## scaled by the same min(win_w/DESIGN_W, win_h/DESIGN_H) factor the 2D UI
## itself uses — so the reserved area always matches the actual UI size
## regardless of window size, instead of being a fixed amount of 3D world
## space (which drifted out of sync with the UI whenever the board also
## had to shrink for width).
const DESIGN_W: float = 1920.0
const DESIGN_H: float = 1080.0
const TOP_PAD_PX: float = 100.0
const BOTTOM_PAD_PX: float = 25.0

var table: Array = []
var has_not_diamonds: Array = []
var regret_lists = []
var odd_diamonds = {}
var last_click_base: Object
var all_diamonds: Array
var alarm: Object
func _enter_tree() -> void:
	if size.x <= 0:
		return

	alarm = get_node("/root/Node3D/TableGrid/AudioStreamPlayer")

	_refit()
	
	
	for x in size.x:
		table.append([])
		for y in size.y:
			has_not_diamonds.append([x,y])
			table[x].append([])
			put_base(x, y)
	var lists_to_put = random_split_array_two(num_diamonds)
	for i in lists_to_put:
		if i[0] == 2:
			try_put_diamonds_two(i[1])
	print(table)

func _ready() -> void:
	get_tree().root.size_changed.connect(_refit)
	# The window/viewport isn't always settled on the very first frame
	# (mobile in particular may report a stale size before the real screen
	# dimensions apply). Re-fit once that happens so the board doesn't stay
	# mis-scaled or clipped from startup.
	await get_tree().process_frame
	_refit()

func _refit() -> void:
	var cam := get_node("/root/Node3D/Camera3D")
	var board_w: float = (size.x - 1) * 0.5
	var board_h: float = (size.y - 1) * 0.5

	# Use the actual OS window size (not the viewport's canvas-transformed
	# rect) so this always matches real screen pixels, regardless of the
	# project's 2D stretch/canvas settings.
	var win_size := get_window().size
	var win_w: float = float(win_size.x)
	var win_h: float = float(win_size.y)

	var ui_scale: float = minf(win_w / DESIGN_W, win_h / DESIGN_H)
	var top_pad_px: float = TOP_PAD_PX * ui_scale
	var bottom_pad_px: float = BOTTOM_PAD_PX * ui_scale

	# Fit the (never-distorted) board into whatever pixel box remains after
	# reserving the UI strip — whichever axis is tighter sets the pixel
	# density, so the board touches the screen edges on that axis; the
	# other axis is left with any unavoidable leftover space.
	var avail_w_px: float = win_w
	var avail_h_px: float = maxf(win_h - top_pad_px - bottom_pad_px, 1.0)
	var px_per_unit: float = minf(avail_w_px / board_w, avail_h_px / board_h)-18

	# Camera3D.size (orthogonal, KEEP_HEIGHT) is the FULL world-height that
	# maps to the full window height — derive it from the chosen density so
	# 1 world unit always maps to px_per_unit screen pixels. The board
	# itself is never scaled; only the camera zoom changes.
	cam.size = win_h / px_per_unit
	var top_pad_world: float = top_pad_px / px_per_unit
	var bottom_pad_world: float = bottom_pad_px / px_per_unit
	# When one axis has leftover slack (e.g. board is width-bound so it
	# doesn't use the full height), center the board in that slack instead
	# of pinning it right under the top pad and dumping all the extra space
	# at the bottom. Any slack cancels out of this center-point formula, so
	# it still gives the exact same placement as before when there's no
	# slack (height exactly binding).
	cam.transform.origin = Vector3(board_w * 0.5, 6.0, (board_h + bottom_pad_world - top_pad_world) * 0.5)

func _process(delta: float) -> void:
	all_diamonds = count_all_diamonds()

func odd_alarm():
	var should_play = false
	for i in odd_diamonds:
		if odd_diamonds.get(i):
			should_play = true
	alarm_play(should_play)

func alarm_play(checker: bool):
	if checker:
		# 如果要循环播放，确保它在播放中
		if not alarm.playing:
			alarm.play()
	else:
		# 如果不需要，直接停止（静音且重置进度）
		if alarm.playing:
			alarm.stop()

func recover_mark_grey_click_point():
	if last_click_base is Base:
		last_click_base.set_color()

func on_regret_button_pressed() -> void:
	if regret_lists.size() == 0:
		return
	var score_recorder = get_node("/root/Node3D/CanvasLayer/ScoreValue")
	for i in regret_lists.back():
		put_diamond(i[0].x, i[0].y, i[1])
		score_recorder.text = str(int(score_recorder.text) - 1)
		update_odds_notice()
	if len(regret_lists.back()) == 3:
		score_recorder.text = str(int(score_recorder.text) - 2)
	regret_lists.erase(regret_lists.back())
	print(regret_lists)

func count_all_diamonds() -> Array:
	var result = []
	for column in table:
		for cell_contents in column:
			for obj in cell_contents:
				if obj is Diamond:
					result.append(obj)
	return result
				
				
func try_put_diamonds_two(type: int) -> void:
	if has_not_diamonds.is_empty():
		push_warning("No empty positions available.")
		return

	has_not_diamonds.shuffle()
	var center = has_not_diamonds[0]
	var x = center[0]
	var y = center[1]

	var directions := [
		Vector2i(0, -1),  # 上
		Vector2i(0, 1),   # 下
		Vector2i(-1, 0),  # 左
		Vector2i(1, 0)    # 右
	]

	var valid_blocks := []
	for i in directions:
		var pos = random_choose_by_dir(x, y, i)
		if pos != null:
			valid_blocks.append(pos)

	# 移除重复位置（有可能重复）
	var deduped := []
	for v in valid_blocks:
		if not v in deduped:
			deduped.append(v)

	if deduped.size() < 2:
		return

	deduped.shuffle()
	var pos0 = deduped[0]
	var pos1 = deduped[1]

	put_diamond(pos0.x, pos0.y, type)
	put_diamond(pos1.x, pos1.y, type)
	has_not_diamonds.erase([pos0.x, pos0.y])
	has_not_diamonds.erase([pos1.x, pos1.y])
		
func update_odds_notice():
	check_odd_diamonds()
	var cam = get_node("/root/Node3D/Camera3D")
	var board_w: float = (size.x - 1) * 0.5
	# Place hints in the pad strip above the board (world z < 0), derived
	# from the camera's *actual current* frustum top edge rather than a
	# fixed fraction of cam.size — cam.size's meaning/value now depends on
	# window aspect (see _refit()), so a fixed fraction of it no longer
	# reliably lands inside the visible area.
	var frustum_top: float = cam.transform.origin.z - cam.size * 0.5
	var y_pos: float = frustum_top * 0.3
	var start_x: float = board_w * 0.05
	var spacing: float = board_w * 0.09
	for i in range(1, 10):
		var node_name := str(i)
		if not has_node(node_name):
			if odd_diamonds.get(i):
				var hint := Sprite3D.new()
				var texture_path := "res://diamonds/%d.png" % i
				var texture = load(texture_path)
				hint.name = node_name
				hint.texture = texture
				hint.rotation_degrees = Vector3(-90, 0, 0)
				add_child(hint)
				hint.global_position = Vector3(start_x + i * spacing, 2, y_pos)
		elif has_node(node_name):
			if not odd_diamonds.get(i):
				get_node(node_name).queue_free()
			
func check_odd_diamonds():
	all_diamonds = count_all_diamonds()
	var type_to_nums = {}
	for i in all_diamonds:
		if i.type not in type_to_nums:
			type_to_nums[i.type] = 1
		else :
			type_to_nums[i.type] += 1
	for i in type_to_nums:
		if type_to_nums[i]%2 == 1:
			odd_diamonds[i] = true
		else:
			odd_diamonds[i] = false
	odd_alarm()
		
	
		
func put_diamond(x: int, y: int, type: int):
	var new_diamond := Diamond.new()
	new_diamond.pos = Vector2i(x, y)
	new_diamond.type = type
	add_child(new_diamond)
	new_diamond.global_position = Vector3(x * 0.5, 0, y * 0.5)
	table[x][y].append(new_diamond)

func put_base(x: int, y: int):
	var new_base := Base.new()
	new_base.pos = Vector2i(x, y)
	add_child(new_base)
	new_base.global_position = Vector3(x * 0.5, 0, y * 0.5)
	table[x][y].append(new_base)
	new_base.set_background()
	
func random_choose_by_dir(x: int, y: int, dir: Vector2i):
	var valid_blocks = []
	var cur = Vector2i(x, y) + dir
	while inscreen(cur):
		if not has_diamond(cur.x, cur.y):
			valid_blocks.append(cur)
		cur += dir
	valid_blocks.shuffle()
	if not valid_blocks.is_empty():
		return valid_blocks[0]
	
func inscreen(loc: Vector2i):
	if loc.x >= size.x or loc.x < 0:
		return false
	if loc.y >= size.y or loc.y < 0:
		return false
	return true
	
func has_diamond(x: int, y: int):
	for i in table[x][y]:
		if i is Diamond:
			return true
	return false

func random_split_array_two(n: int):
	var result = []
	if n%2 != 0:
		return
	var num = int(n/2)
	for i in range (0, num):
		result.append([2, rng.randi_range(1, 9)])
	return result

func random_split_array(n: int) -> Array:
	var result: Array = []
	if n <= 1:
		return result
	
	# 收集所有合法的 (a, b) 组合，满足 2*a + 3*b = n
	var valid_combinations: Array = []
	var max_b := n / 3
	for b in range(int(max_b) + 1):
		var remaining := n - 3 * b
		if remaining % 2 == 0:
			var a := remaining / 2
			valid_combinations.append([int(a), int(b)])
	
	if valid_combinations.is_empty():
		return result
	
	# 随机选一个 (a, b)
	var idx := randi() % valid_combinations.size()
	var combo: Array = valid_combinations[idx]
	var a = combo[0]
	var b = combo[1]
	
	# 构造包含 a 个 2 和 b 个 3 的数组
	for i in range(a):
		result.append([2, rng.randi_range(1, 9)])
	for i in range(b):
		result.append([3, rng.randi_range(1, 9)])
	
	# 打乱顺序
	result.shuffle()
	return result
	
