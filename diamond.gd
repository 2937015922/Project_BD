class_name Diamond extends Area3D

@export var color: Color = Color(1, 1, 1)  # 默认白色，可在Inspector中修改
@export var value: int = 10  # 钻石的得分值
@export var type: int = 1
var pos: Vector2i = Vector2i(0, 0)


func _ready() -> void:	
	self.name = "Diamond"
	if get_node_or_null("Sprite3D") == null:
		var the_show:= Sprite3D.new()
		var texture_path := "res://diamonds/%d.png" % type
		var texture = load(texture_path)
		if texture:
			the_show.texture = texture
		else:
			push_warning("Texture not found at path: " + texture_path)
		the_show.rotation_degrees = Vector3(-90, 0, 0)
		add_child(the_show)
		
	#if not has_node("CollisionShape3D"):
		#var shape := CollisionShape3D.new()
		#shape.shape = BoxShape3D.new()
		#shape.shape.size = Vector3(0.33, 0.33, 0.33)  # 可根据需要缩放
		#add_child(shape)
		

#func _input_event(camera, event, position, normal, shape_idx):
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print("Diamond at %s clicked! Now removing..." % pos)
		#to_vanish(Vector3(0,0,0),0.15)
		
func to_vanish(target_position: Vector3, duration: float) -> void:
	# 先把自己从 TableGrid.table 中移除，避免后续被再次检测到
	var table_node = get_node("/root/Node3D/TableGrid")
	if table_node:
		table_node.table[pos.x][pos.y].erase(self)
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_callback(Callable(self, "queue_free"))
	var score_recorder = get_node("/root/Node3D/CanvasLayer/Label")
	score_recorder.text = str(int(score_recorder.text) + 1)
	
