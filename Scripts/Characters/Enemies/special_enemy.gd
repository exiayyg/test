extends Enemy

# =============================================
# 特殊敌人行为说明：
# 1. 此敌人设定了一个围绕玩家的“安全圆环”（内径 min, 外径 max）
# 2. 当敌人位于圆环外（距离 > max）时，会朝向玩家移动（追击）
# 3. 当敌人位于圆环内（距离 < min）时，会远离玩家移动（逃跑）
# 4. 当敌人在圆环内（min ≤ 距离 ≤ max）时，会进行智能随机徘徊
#    徘徊时会尝试避开障碍物，并有倾向性地保持在安全距离附近
# =============================================
@export var keep_away_from_player_max: float = 550.0  # 安全圆环的最大半径（外径），超出此距离将触发追击
@export var keep_away_from_player_min: float = 350.0  # 安全圆环的最小半径（内径），小于此距离将触发逃跑
@export var wander_speed: float = 80.0                # 徘徊状态下的移动速度（通常低于追击/逃跑速度）
@export var wander_direction_change_time: float = 1.2 # 徘徊时，方向改变的基本时间间隔（秒）
@export var obstacle_check_ray_length: float = 60.0   # 用于检测前方障碍物的射线长度
@export var boundary_avoidance_strength: float = 0.6  # 边界回避强度 (0.0-1.0)。值越高，徘徊时越倾向于朝“安全环中心”调整方向，防止越界抖动。

# 新增：避障探测的参数
@export var avoidance_angle_step: float = 30.0 # 每次尝试偏转的角度
@export var max_avoidance_attempts: int = 5    # 向左/向右最多尝试几次

var distance_to_player: Vector2
var current_wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

@onready var game_state = get_node("/root/Global")

func _process(_delta):
	SpecialUpdateSpriteRotation()
	if health <= 0:#如果生命值小于零，则死亡
		died()

func _physics_process(delta: float) -> void:
	SpecialEnemyMovement(delta)

# ============================================
# Sprite2D随着敌人转向
# ============================================
func SpecialUpdateSpriteRotation():
	# 只有在有移动速度时才更新旋转
	if velocity.length() > 10:  # 设置一个最小速度阈值，避免抖动
		# 计算移动方向的角度
		var move_angle = velocity.angle()
		# 平滑旋转（可选，使旋转更平滑）
		sprite_2d.rotation = lerp_angle(sprite_2d.rotation, move_angle, 0.1)
	else:
		# 如果没有移动，保持当前方向
		pass

# =============================================
# 特殊敌人的核心移动逻辑
# 根据与玩家的距离，在三种状态间切换：追击、逃跑、徘徊
# =============================================
func SpecialEnemyMovement(delta: float) -> void:
	distance_to_player = Global.player_position - global_position
	var dist_len = distance_to_player.length()
	
	var desired_velocity = Vector2.ZERO
	var current_speed = speed # 默认追击/逃跑速度
	
	if dist_len > keep_away_from_player_max:
		# --- 状态1: 追击 (在圈外) ---
		# 理想方向：指向玩家
		var ideal_dir = distance_to_player.normalized()
		# 获取避障后的实际方向
		var safe_dir = get_obstacle_safe_direction(ideal_dir)
		desired_velocity = safe_dir * speed
		
	elif dist_len < keep_away_from_player_min:
		# --- 状态2: 逃跑 (在圈内) ---
		# 理想方向：背离玩家
		var ideal_dir = -distance_to_player.normalized()
		# 获取避障后的实际方向
		var safe_dir = get_obstacle_safe_direction(ideal_dir)
		desired_velocity = safe_dir * speed
		
	else:
		# --- 状态3: 徘徊 (在安全环内) ---
		Wander(delta)
		move_and_slide()
		return

	# 应用移动 (追击和逃跑状态)
	velocity = desired_velocity
	move_and_slide()

# =============================================
# 智能徘徊函数
# 负责在安全距离内产生看似随机但有边界意识的移动
# =============================================
func Wander(delta: float) -> void:
	wander_timer -= delta
	
	# 如果计时结束 或 当前方向撞墙，更换方向
	if wander_timer <= 0 or check_direction_blocked(current_wander_direction):
		var new_direction: Vector2
		
		if check_direction_blocked(current_wander_direction):
			# 撞墙回避逻辑：基于当前角度大幅度转向
			var current_angle = current_wander_direction.angle()
			var turn_direction = 1.0 if randf() > 0.5 else -1.0
			# 转向 90~150 度，避免擦墙走
			var avoid_angle = current_angle + turn_direction * deg_to_rad(randf_range(90, 150))
			new_direction = Vector2(cos(avoid_angle), sin(avoid_angle))
			wander_timer = 0.5 # 撞墙后快速重置计时
		else:
			# 自然随机逻辑
			new_direction = Vector2(cos(randf_range(0, TAU)), sin(randf_range(0, TAU)))
			wander_timer = wander_direction_change_time * randf_range(0.8, 1.2)
		
		# 应用“安全回归”偏置
		current_wander_direction = MakeDirectionSafe(new_direction).normalized()
	
	velocity = current_wander_direction * wander_speed

# =============================================
# 通用智能避障方向获取器
# 输入：想要去的方向
# 输出：避开了障碍物的最佳方向
# =============================================
func get_obstacle_safe_direction(target_dir: Vector2) -> Vector2:
	# 1. 如果直连方向没有阻挡，直接走
	if not check_direction_blocked(target_dir):
		return target_dir
	
	# 2. 如果被阻挡，开始向左/向右探测
	# 尝试角度：30, -30, 60, -60, 90, -90 ...
	for i in range(1, max_avoidance_attempts + 1):
		var angle_offset = deg_to_rad(avoidance_angle_step * i)
		
		# 尝试向正向偏转
		var check_dir_pos = target_dir.rotated(angle_offset)
		if not check_direction_blocked(check_dir_pos):
			return check_dir_pos
			
		# 尝试向负向偏转
		var check_dir_neg = target_dir.rotated(-angle_offset)
		if not check_direction_blocked(check_dir_neg):
			return check_dir_neg
	
	# 3. 如果所有尝试都失败（例如掉进了死胡同），保持原方向尝试滑行=
	return target_dir

# =============================================
# 射线检测底层函数
# =============================================
func check_direction_blocked(dir: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + dir * obstacle_check_ray_length
	)
	
	query.exclude = [self.get_rid()]
	query.collision_mask = 16 
	
	var result = space_state.intersect_ray(query)
	return not result.is_empty()

# =============================================
# 方向安全化函数
# 将输入方向向量，朝着“理想安全点”的方向进行一定程度的偏转。
# “理想安全点”：位于玩家身后，与玩家保持理想安全距离的一个虚拟点。
# 这样，当敌人过于靠近或远离玩家时，其随机移动会有“回归”安全区域的趋势。
# =============================================
func MakeDirectionSafe(input_direction: Vector2) -> Vector2:
	var safe_center_distance = (keep_away_from_player_min + keep_away_from_player_max) / 2.0
	var to_player = Global.player_position - global_position
	var desired_offset_vector = to_player.normalized() * safe_center_distance
	var safe_target_point = Global.player_position - desired_offset_vector
	var direction_to_safe_center = (safe_target_point - global_position).normalized()
	return input_direction.lerp(direction_to_safe_center, boundary_avoidance_strength).normalized()

func _ready():
	game_state.register_special_enemy()

func _exit_tree():
	game_state.unregister_special_enemy()
	print("hello")
