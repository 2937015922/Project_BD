extends ProgressBar
class_name TwoMinuteCountdownBar

# 总时长 120 秒（2 分钟）
@export var duration: float = 2

var _elapsed: float = 0.0
var _finished: bool = false

func _ready() -> void:
	# 将进度条范围设置为 0..100，并从 100 开始
	min_value = 0
	max_value = 100
	value = max_value

	# 启用每帧更新
	set_process(true)
	self.anchor_left   = 1
	self.anchor_top    = 1
	self.anchor_right  = 0
	self.anchor_bottom = 0

	# 3. 设置偏移（Margin）让它距离“右边 10px，顶边 10px”
	#    注意：在 Godot 4 中，Margin 属性叫 offset_*，旧版 Godot 3 中叫 margin_*
	#self.offset_right = -40
	self.offset_top   = 10
	# 要固定宽高，可以用以下两行（例如宽度 120，高度 30）
	#self.offset_left   = -10 - 120  # = (-10) - btn_width
	self.offset_bottom = 10 + 30    # = offset_top + btn_height

func _process(delta: float) -> void:
	var the_console = get_node("/root/Node3D/TableGrid")
	if _finished:
		return

	_elapsed += delta
	# 计算当前剩余百分比（从 1.0 线性减少到 0.0）
	var pct = clamp(1.0 - _elapsed / duration, 0.0, 1.0)
	value = pct * max_value

	if _elapsed >= duration:
		# 到达 2 分钟，停止更新并执行打印
		value = 0
		_finished = true
		_show_overlay()
	if _no_diamonds_left(the_console):
		_show_overlay()


func _show_overlay() -> void:
	# 1. 找到场景中已经存在的 CanvasLayer（假设它的名字就是 "CanvasLayer"）
	var ui_layer = get_node("/root/Node3D/CanvasLayer") as CanvasLayer
	if not ui_layer:
		push_warning("找不到名称为 CanvasLayer 的节点，无法添加蒙版。")
		return

	# 2. 创建一个 ColorRect 作为全屏蒙版
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)  # 半透明灰色

	# 3. 让它铺满父容器（CanvasLayer）整个视窗
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	# 注意：因为它直接添加到 CanvasLayer 下，Control.PRESET_FULL_RECT 会让它的大小自动匹配整个 Viewport。

	# 4. 把蒙版添加到这个已存在的 CanvasLayer 下
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(overlay)
	freeze_node_tree(get_node("/root/Node3D/TableGrid"))
	
	var final_score = Label.new()
	final_score.text = "得分：" + str(get_node("/root/Node3D/CanvasLayer/Label").text)
	final_score.z_index = 1024
	final_score.scale = Vector2(4,4)
	final_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_score.add_theme_font_size_override("font_size", 55)
	final_score.set_position(get_viewport().size * 0.5 - Vector2(400,200))
	add_child(final_score)
	
func _no_diamonds_left(table_grid) -> bool:
	# table_grid.table 是一个二维数组：table[x][y] = [ ... 节点 ... ]
	for column in table_grid.table:
		for cell_contents in column:
			for obj in cell_contents:
				if obj is Diamond:
					return false
	return true
	
func freeze_node_tree(node: Node) -> void:
	# 停止自身处理函数
	if node.has_method("set_process"):
		node.set_process(false)
	if node.has_method("set_physics_process"):
		node.set_physics_process(false)

	# 停止输入处理（可选）
	if node.has_method("set_process_input"):
		node.set_process_input(false)
	if node.has_method("set_process_unhandled_input"):
		node.set_process_unhandled_input(false)

	# 如果是刚体，则改为静态模式

	# 如果是碰撞体，则禁用其 CollisionShape
	if node is CollisionObject3D:
		for child in node.get_children():
			if child is CollisionShape3D:
				child.disabled = true

	for child in node.get_children():
		freeze_node_tree(child)
