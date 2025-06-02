extends Node
class_name TableGrid
var rng = RandomNumberGenerator.new()

@export var size: Vector2i = Vector2i(2, 2)  # 使用 Vector2i 表示列数和行数
var table: Array = []

func _enter_tree() -> void:
	var cam := get_node("/root/Node3D/Camera3D")
	cam.size = float(size.x)/3  # 控制可视范围
	cam.transform.origin = Vector3(size.x/4, 1, size.y/4)
	
	for x in size.x:
		table.append([])
		for y in size.y:
			table[x].append([])
			put_base(x, y)
			if rng.randi_range(-1, 2) == 2:
				put_diamond(x, y)
		
func put_diamond(x: int, y: int):
	var new_diamond := Diamond.new()
	new_diamond.pos = Vector2(x*0.5, y*0.5)
	add_child(new_diamond)
	new_diamond.global_position = Vector3(x * 0.5, 0, y * 0.5)
	table[x][y].append(new_diamond)

func put_base(x: int, y: int):
	var new_base := Base.new()
	new_base.pos = Vector2(x*0.5, y*0.5)
	add_child(new_base)
	new_base.global_position = Vector3(x * 0.5, 0, y * 0.5)
	table[x][y].append(new_base)


	
