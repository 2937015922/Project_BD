extends Node3D
class_name Selector

var current_base: Base = null
var map: Array = []  # 外部传入的 diamond 网格
var size := Vector2i(10, 10)  # 表示 grid 大小，供边界判断

func _ready():
	map = get_node("/root/Node3D/TableGrid").table

func get_surrounding_diamonds(base_pos: Vector2i) -> Array:
	var map = get_node("/root/Node3D/TableGrid").table
	var diamonds := []
	var directions := [
		Vector2i(0, -1),  # 上
		Vector2i(0, 1),   # 下
		Vector2i(-1, 0),  # 左
		Vector2i(1, 0)    # 右
	]

	for dir in directions:
		var current := base_pos          # ❶ 先设为自身
		var found := false
		while current.x >= 0 and current.x < map.size() \
				and current.y >= 0 and current.y < map[current.x].size() \
				and not found:
			# 向当前格子里找 Diamond
			for item in map[current.x][current.y]:
				if item is Diamond:
					diamonds.append(item)
					found = true
					break           # 该方向命中，退出 while
			current += dir           # ❷ 最后再迈向下一格
	return diamonds
