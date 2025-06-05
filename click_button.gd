extends Button
class_name click_button
@export var type = 1

func _ready() -> void:
	# 将按钮的 pressed 信号连接到本脚本的回调方法
	pressed.connect(self._on_button_pressed)

func _on_button_pressed() -> void:
	function()

func function() -> void:
	get_tree().reload_current_scene()
