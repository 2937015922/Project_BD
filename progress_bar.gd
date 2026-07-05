extends ProgressBar
class_name TwoMinuteCountdownBar

# 总时长 120 秒（2 分钟）
@export var duration: float = 120

var _elapsed: float = 0.0
var _finished: bool = false

func _ready() -> void:
	# 将进度条范围设置为 0..100，并从 100 开始
	min_value = 0
	max_value = 100
	value = max_value

	# 启用每帧更新
	set_process(true)

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
	if the_console.all_diamonds.size() == 0:
		_show_overlay()
		_finished = true


func _show_overlay() -> void:
	# 1. 找到场景中已经存在的 CanvasLayer
	var ui_layer = get_node("/root/Node3D/CanvasLayer") as CanvasLayer
	if not ui_layer:
		push_warning("找不到名称为 CanvasLayer 的节点，无法添加蒙版。")
		return

	# 2. 创建一个 ColorRect 作为全屏蒙版
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)  # 半透明灰色

	# 3. 让它铺满父容器（CanvasLayer）整个视窗
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	# 4. 把蒙版添加到这个已存在的 CanvasLayer 下
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(overlay)
	freeze_node_tree(get_node("/root/Node3D/TableGrid"))

	# 5. 获取 responsive canvas 的缩放信息
	var responsive: ResponsiveCanvas = ui_layer as ResponsiveCanvas
	var scale_factor: float = 1.0
	if responsive:
		scale_factor = responsive.get_ui_scale()

	var final_score = Label.new()
	var score_text = get_node("/root/Node3D/CanvasLayer/ScoreValue").text
	final_score.text = "得分：" + str(int(score_text) + int(duration - _elapsed))
	final_score.z_index = 1024
	final_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Use anchors to center on screen (viewport-independent)
	final_score.anchor_left = 0.5
	final_score.anchor_top = 0.5
	final_score.anchor_right = 0.5
	final_score.anchor_bottom = 0.5
	final_score.offset_left = -300 * scale_factor
	final_score.offset_top = -100 * scale_factor
	final_score.offset_right = 300 * scale_factor
	final_score.offset_bottom = 100 * scale_factor

	var font_size = maxi(int(55 * scale_factor), 18)
	final_score.add_theme_font_size_override("font_size", font_size)
	ui_layer.add_child(final_score)

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
