extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 启动游戏,切换进入test_level
func _on_start_button_pressed() -> void:
	print("Start Game!")
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")
	pass # Replace with function body.

# 退出游戏
func _on_exit_button_pressed() -> void:
	print("Game END")
	get_tree().quit()
	pass # Replace with function body.
