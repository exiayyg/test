extends CanvasLayer
class_name SuccessScreen

# --- 全局静态单例 ---
# 这样你可以在任何地方通过 SuccessScreen.instance.show_success() 调用
static var instance: SuccessScreen

# --- 内部变量 ---
# 用于存储下一关的路径，默认为空，可以在 show_success 时传入
var _next_level_path: String = ""

# --- 生命周期 ---

func _enter_tree() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()

func _exit_tree() -> void:
	if instance == self:
		instance = null

func _ready() -> void:
	# 1. 初始状态隐藏
	self.visible = false

# --- 公共 API (Public Methods) ---

## 显示胜利界面
## @param next_scene_path: (可选) 下一关的场景文件路径，例如 "res://Scenes/Levels/level_2.tscn"
func show_success(next_scene_path: String = "") -> void:
	if self.visible:
		return
		
	print("胜利！显示结算界面")
	_next_level_path = next_scene_path
	self.visible = true
	
	# 2. 【关键】暂停游戏
	# 停止怪物行动、计时器等，营造"定格"效果
	get_tree().paused = true
	
	# 3. 确保鼠标可见
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# --- 按钮回调逻辑 ---

func _on_next_screen_button_pressed() -> void:
	print("进入下一关")
	
	# 4. 【关键】切换场景前必须取消暂停！
	get_tree().paused = false
	
	
	if _next_level_path != "":
		# 如果传入了具体的下一关路径，则跳转
		get_tree().change_scene_to_file(_next_level_path)
	else:
		# Game Jam 常用技巧：
		# 如果还没做下一关，暂时先"重新加载当前关卡"作为演示
		# 或者跳转回这一关的测试场景
		print("未指定下一关，重新加载当前场景...")
		
		get_tree().reload_current_scene()


func _on_title_game_button_pressed() -> void:
	print("返回标题页")
	
	# 同样需要取消暂停
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Start_Screen/Start_Screen.tscn")
