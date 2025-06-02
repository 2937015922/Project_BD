class_name Base extends Area3D
var pos: Vector2 = Vector2(0, 0)

func _ready() -> void:	
	self.scale = Vector3(0.33, 0.33, 0.33)
	if not has_node("CollisionShape3D"):
		var shape := CollisionShape3D.new()
		shape.name = "CollisionShape3D"
		shape.shape = BoxShape3D.new()
		self.transform.origin = Vector3(pos.x, 0, pos.y)  # 保证和Sprite重合
		add_child(shape)

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Base at %s clicked!" % pos)
