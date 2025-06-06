extends Node
class_name TableGrid
var rng = RandomNumberGenerator.new()

@export var size: Vector2i  # 使用 Vector2i 表示列数和行数
@export var num_diamonds: int
var table: Array = []
var has_not_diamonds: Array = []
var regret_lists = []


func _enter_tree() -> void:

	
	var cam := get_node("/root/Node3D/Camera3D")
	cam.size = float(size.x)/3  # 控制可视范围
	cam.transform.origin = Vector3(size.x/4, 1, size.y/4+0.25)
	
	
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

func on_regret_button_pressed() -> void:
	if regret_lists.size() == 0:
		return
	for i in regret_lists.back():
		put_diamond(i[0].x, i[0].y, i[1])
		var score_recorder = get_node("/root/Node3D/CanvasLayer/Label")
		score_recorder.text = str(int(score_recorder.text) - 1)
		print(233)

				
				
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
	
