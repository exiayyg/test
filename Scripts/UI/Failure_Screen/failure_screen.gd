extends CanvasLayer

func _ready() -> void:
	# 1. 游戏开始时，确保界面是隐藏的
	self.visible = false
	
	# 2. 连接 GameHUD 的信号
	# 注意：我们要确保 GameHUD 实例存在
	if GameHUD.instance:
		GameHUD.instance.health_changed.connect(_on_health_changed)
	else:
		printerr("错误: FailureScreen 没找到 GameHUD 实例，无法监听血量变化！")

# --- 信号回调逻辑 ---

func _on_health_changed(current_hp: int, _max_hp: int) -> void:
	# 3. 检测血量是否归零
	if current_hp <= 0:
		show_failure_screen()

func show_failure_screen() -> void:
	# 如果已经显示了，就不要重复触发
	if self.visible:
		return
		
	print("玩家死亡，显示失败界面")
	self.visible = true
	
	# 4. 【关键】暂停整个游戏树
	# 这样敌人会停止移动，子弹会定在半空，给玩家一种"定格"感
	get_tree().paused = true
	
	# 5. 确保鼠标可见 (如果是FPS游戏或者原本隐藏了鼠标)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# --- 按钮逻辑 ---

func _on_restart_game_button_pressed() -> void:
	print("重新开始")
	# 6. 【非常重要】切换场景前必须取消暂停！
	# 否则新场景加载出来后，游戏依然是静止的
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")

func _on_title_game_button_pressed() -> void:
	print("返回标题页")
	# 同样需要取消暂停
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Start_Screen/Start_Screen.tscn")
