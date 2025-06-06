extends Button
class_name click_button
@export var type: int

func _ready() -> void:
	# 将按钮的 pressed 信号连接到本脚本的回调方法
	pressed.connect(self._on_button_pressed)
	#self.anchor_left   = 1
	#self.anchor_top    = 0
	#self.anchor_right  = 1
	#self.anchor_bottom = 0
#
	## 3. 设置偏移（Margin）让它距离“右边 10px，顶边 10px”
	##    注意：在 Godot 4 中，Margin 属性叫 offset_*，旧版 Godot 3 中叫 margin_*
	#self.offset_right = -40
	#self.offset_top   = 10
	## 要固定宽高，可以用以下两行（例如宽度 120，高度 30）
	#self.offset_left   = -10 - 120  # = (-10) - btn_width
	#self.offset_bottom = 10 + 30    # = offset_top + btn_height

func _on_button_pressed() -> void:
	function()

func function() -> void:
	if type == 1:
		get_tree().reload_current_scene()
	if type == 2:
		get_node("/root/Node3D/TableGrid").on_regret_button_pressed()
