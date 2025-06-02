class_name Diamond extends Area3D

@export var color: Color = Color(1, 1, 1)  # 默认白色，可在Inspector中修改
@export var value: int = 10  # 钻石的得分值
@export var type: int = 1
var pos: Vector2 = Vector2(0, 0)


func _ready() -> void:	

	if get_node_or_null("Sprite3D") == null:
		var the_show:= Sprite3D.new()
		var texture_path := "res://diamonds/%d.png" % type
		var texture = load(texture_path)
		if texture:
			the_show.texture = texture
		else:
			push_warning("Texture not found at path: " + texture_path)
		global_position = Vector3(pos.x, 0, pos.y)
		the_show.rotation_degrees = Vector3(-90, 0, 0)
		add_child(the_show)
		
	if not has_node("CollisionShape3D"):
		var shape := CollisionShape3D.new()
		shape.shape = BoxShape3D.new()
		shape.shape.size = Vector3(0.33, 0.33, 0.33)  # 可根据需要缩放
		add_child(shape)
		

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Diamond at %s clicked! Now removing..." % pos)
		to_vanish(Vector3(0,0,0),0.15)
		
func to_vanish(target_position: Vector3, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_callback(Callable(self, "queue_free"))  # 在移动结束后删除自己
