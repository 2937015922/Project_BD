class_name Base extends Area3D
var pos: Vector2i = Vector2i(0, 0)
var active: bool

func _ready() -> void:	
	self.name = "Base"
	self.scale = Vector3(0.33, 0.33, 0.33)
	if not has_node("CollisionShape3D"):
		var shape := CollisionShape3D.new()
		shape.name = "CollisionShape3D"
		shape.shape = BoxShape3D.new()  # 保证和Sprite重合
		add_child(shape)

func _input_event(camera, event, position, normal, shape_idx):
	active = true
	for i in get_node("/root/Node3D/TableGrid").table[pos.x][pos.y]:
		if i is Diamond:
			active = false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and active:
		print("Base at %s clicked!" % pos)
		var selector = get_tree().get_root().get_node("/root/Node3D/Selector")
		var nearby_diamonds = selector.get_surrounding_diamonds(self.pos)
		print("Nearby diamonds:", nearby_diamonds)

		var type_occur = {}
		for d in nearby_diamonds:
			if d.type in type_occur:
				type_occur[d.type] += 1
			else:
				type_occur[d.type] = 1

		# 筛选出重复类型（出现次数 > 1）
		var duplicated_types := []
		for t in type_occur.keys():
			if type_occur[t] > 1:
				duplicated_types.append(t)

		# 删除重复类型的钻石
		for d in nearby_diamonds:
			if d.type in duplicated_types:
				d.to_vanish(self.position, 0.1)
				
					
					
