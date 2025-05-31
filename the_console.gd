extends Node
class_name TableGrid

@export var size: Vector2i = Vector2i(1, 1)  # 使用 Vector2i 表示列数和行数
var table: Array = []

func _ready():
	table.clear()
	for x in size.x:
		table.append([])
		for y in size.y:
			table[x].append([])
		
	
