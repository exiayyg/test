extends Node
# 全局单例类，在项目中自动加载

@export var level_difficulty: int = 0
# 关卡难度
var player_position: Vector2
# 玩家全局位置
var is_special_enemy_present = false
var inverted_controls = false
var special_enemy_count = 0  # 添加特殊敌人计数器

signal controls_inverted_changed(inverted)

# 注册特殊敌人（当特殊敌人出现时调用）
func register_special_enemy():
	special_enemy_count += 1
	print("特殊敌人注册，当前数量: ", special_enemy_count)
	
	if special_enemy_count == 1:
		is_special_enemy_present = true
		inverted_controls = true
		controls_inverted_changed.emit(true)
		print("玩家操作已反转")

# 注销特殊敌人（当特殊敌人消失时调用）
func unregister_special_enemy():
	special_enemy_count -= 1
	
	if special_enemy_count < 0:
		special_enemy_count = 0
	
	print("特殊敌人注销，当前数量: ", special_enemy_count)
	
	if special_enemy_count == 0:
		is_special_enemy_present = false
		inverted_controls = false
		controls_inverted_changed.emit(false)
		print("玩家操作已恢复正常")

func get_special_enemy_count() -> int:
	return special_enemy_count

# 重置所有状态（切换关卡或重新开始时使用）
func reset_game_state():
	level_difficulty = 0
	player_position = Vector2.ZERO
	is_special_enemy_present = false
	inverted_controls = false
	special_enemy_count = 0
	print("游戏状态已重置")
