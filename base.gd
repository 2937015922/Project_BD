class_name Base extends Area3D
var pos: Vector2i = Vector2i(0, 0)
var active: bool
var background: Object
var mat: Object

func _ready() -> void:	
	self.name = "Base"
	self.scale = Vector3(0.495, 0.495, 0.495)
	if not has_node("CollisionShape3D"):
		var shape := CollisionShape3D.new()
		shape.name = "CollisionShape3D"
		shape.shape = BoxShape3D.new()  # 保证和Sprite重合
		add_child(shape)
		
func set_background():
	background = MeshInstance3D.new()
	background.mesh = BoxMesh.new()
	add_child(background)
	mat = StandardMaterial3D.new()
	if (pos.x + pos.y)%2 == 0:
		mat.albedo_color = Color(0.0588, 0.0431, 0.0431)  # 这里用红色作示例，换成你想要的纯色
	else:
		mat.albedo_color = Color(0.225, 0.15, 0.15)  # 这里用红色作示例，换成你想要的纯色
	background.material_override = mat
	background.scale = Vector3(1, 1, 1)       # 使立方体边长变为 2 个单位
	background.transform.origin = Vector3(0,-3,0)

func set_color():
	if (pos.x + pos.y)%2 == 0:
		mat.albedo_color = Color(0.0588, 0.0431, 0.0431)  # 这里用红色作示例，换成你想要的纯色
	else:
		mat.albedo_color = Color(0.225, 0.15, 0.15)  # 这里用红色作示例，换成你想要的纯色

func mark_base():
	mat.albedo_color = Color(0.2, 0.2, 0.2)

func _input_event(camera, event, position, normal, shape_idx):
	# ① 判断格子里是否已有 Diamond
	var cell_contents = get_node("/root/Node3D/TableGrid").table[pos.x][pos.y]
	var active = true
	for i in cell_contents:
		if i is Diamond:
			active = false
			break

	# ② 只有当 active 且点击左键时才继续
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and active:
		get_node(("/root/Node3D/TableGrid")).recover_mark_grey_click_point()
		get_node(("/root/Node3D/TableGrid")).last_click_base = self
		mark_base()
		
		print("Base at %s clicked!" % pos)
		var selector = get_tree().get_root().get_node("/root/Node3D/Selector")
		var nearby_diamonds = selector.get_surrounding_diamonds(pos)
		print("Nearby diamonds:", nearby_diamonds)

		# ③ 统计类型出现次数
		var type_occur = {}
		for d in nearby_diamonds:
			if d.type in type_occur:
				type_occur[d.type] += 1
			else:
				type_occur[d.type] = 1

		# ④ 筛选出出现次数 > 1 的类型
		var duplicated_types = []
		for t in type_occur.keys():
			if type_occur[t] > 1:
				duplicated_types.append(t)
		if duplicated_types == []:
			var score_recorder = get_node("/root/Node3D/CanvasLayer/Label")
			score_recorder.text = str(int(score_recorder.text) - 1)

		# ⑤ 对这些需要销毁的 Diamond，调用 to_vanish 并传入 Base 的全局位置
		var regret_group = []
		for d in nearby_diamonds:
			if d.type in duplicated_types:
				d.to_vanish(self.global_position, 0.1)
				regret_group.append([d.pos, d.type])
		get_parent().regret_lists.append(regret_group)
		print(get_parent().regret_lists)
					
					
