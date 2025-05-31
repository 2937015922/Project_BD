class_name Diamond extends StaticBody3D

@export var color: Color = Color(1, 1, 1)  # 默认白色，可在Inspector中修改
@export var value: int = 10  # 钻石的得分值

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready():
	update_color()

func update_color():
	if mesh_instance and mesh_instance.material_override:
		var mat := mesh_instance.material_override.duplicate()
		mat.albedo_color = color
		mesh_instance.material_override = mat

func on_collected():
	queue_free()
