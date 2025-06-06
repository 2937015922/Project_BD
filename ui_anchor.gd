extends Control

class_name ui_anchor

# 导出四个可视化参数：右侧边距、顶端边距、控件宽度、高度
@export var lock_left_top_x: float
@export var lock_right_down_x: float
@export var lock_left_top_y: float
@export var lock_right_down_y: float

@export var left_top_x:    int
@export var right_down_x:   int
@export var left_top_y: int
@export var right_down_y:   int
var the_control := get_parent()
func _ready() -> void:
	# 目标控件就是 self（如果脚本挂在 Button/Control 上）
	the_control = get_parent()

	# 1. 设置锚点：anchor_left 和 anchor_right 都设为 1（靠右），
	#    anchor_top 和 anchor_bottom 都设为 0（靠上）
	the_control.anchor_left   = lock_left_top_x
	the_control.anchor_right  = lock_right_down_x
	the_control.anchor_top    = lock_left_top_y
	the_control.anchor_bottom = lock_right_down_y

	# 2. 计算偏移（offset），注意 Godot 4 里用 offset_* 替代旧版 margin_*
	#    offset_right 为负值，表示从父节点右边向左缩进 margin_right 像素
	the_control.offset_right  = right_down_x
	the_control.offset_top    = left_top_y
	the_control.offset_left   = left_top_x
	the_control.offset_bottom = right_down_y
	
		
