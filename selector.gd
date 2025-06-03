extends Node3D
class_name Selector

var current_base: Base = null
var table: Array = []  # 外部传入的 diamond 网格
var size := Vector2i(10, 10)  # 表示 grid 大小，供边界判断

func _ready():
	# 可加 Sprite3D 表示自己
	pass

func get_surrounding_diamonds(base_pos: Vector2i) -> Array:
	if self.table == []:
		self.table = get_node("/root/Node3D/TableGrid").table
	
	var diamonds := []
	var directions = [
		Vector2i(0, -1),  # 上
		Vector2i(0, 1),   # 下
		Vector2i(-1, 0),  # 左
		Vector2i(1, 0)    # 右
	]

	for dir in directions:
		var current = base_pos
		var found := false  # ✅ 用于标记该方向是否命中 diamond
		while true:
			current += dir
		# 边界检查
			if current.x < 0 or current.x >= table.size():
				break
			if current.y < 0 or current.y >= table[current.x].size():
				break

			for item in table[current.x][current.y]:
				if item is Diamond:
					diamonds.append(item)
					found = true
					break
			if found:
				break  # ✅ 正确退出该方向，不受其他方向干扰
	return diamonds
