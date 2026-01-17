extends Enemy

# =============================================
# 特殊敌人行为说明：
# 1. 此敌人设定了一个围绕玩家的“安全圆环”（内径 min, 外径 max）
# 2. 当敌人位于圆环外（距离 > max）时，会朝向玩家移动（追击）
# 3. 当敌人位于圆环内（距离 < min）时，会远离玩家移动（逃跑）
# 4. 当敌人在圆环内（min ≤ 距离 ≤ max）时，会进行智能随机徘徊
#    徘徊时会尝试避开障碍物，并有倾向性地保持在安全距离附近
# =============================================
@export var keep_away_from_player_max: float = 550.0 # 安全圆环的最大半径（外径），超出此距离将触发追击
@export var keep_away_from_player_min: float = 350.0 # 安全圆环的最小半径（内径），小于此距离将触发逃跑
@export var wander_speed: float = 80.0               # 徘徊状态下的移动速度（通常低于追击/逃跑速度）
@export var wander_direction_change_time: float = 1.2# 徘徊时，方向改变的基本时间间隔（秒）
@export var obstacle_check_ray_length: float = 20.0  # 用于检测前方障碍物的射线长度
#@export var ray_angle_range:float = 45.0
@export var boundary_avoidance_strength: float = 0.6 # 边界回避强度 (0.0-1.0)。值越高，徘徊时越倾向于朝“安全环中心”调整方向，防止越界抖动。
#@export var prediction_distance: float = 80.0

var distance_to_player: Vector2
var current_wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
@onready var game_state = get_node("/root/Global")



func _physics_process(delta: float) -> void:
	SpecialEnemyMovement(delta)

# =============================================
# 特殊敌人的核心移动逻辑
# 根据与玩家的距离，在三种状态间切换：追击、逃跑、徘徊
# =============================================
func SpecialEnemyMovement(delta: float) -> void:
	direction = (Global.player_position - global_position).normalized()
	distance_to_player = Global.player_position - global_position
	if distance_to_player.length() > keep_away_from_player_max:
		velocity = speed * direction
	elif distance_to_player.length() < keep_away_from_player_min:
		velocity = speed * -direction
	else:
		Wander(delta)
	move_and_slide()

# =============================================
# 智能徘徊函数
# 负责在安全距离内产生看似随机但有边界意识的移动
# =============================================
func Wander(delta: float) -> void:
	wander_timer -= delta
	
	if wander_timer <= 0 or IsPathBlocked():
		var new_direction: Vector2
		#var base_direction = Vector2(cos(randf_range(0, TAU)), sin(randf_range(0, TAU)))
		#var safe_direction = MakeDirectionSafe(base_direction)
		#var random_angle = randf_range(0, TAU)
		
		if IsPathBlocked():
			var current_angle = current_wander_direction.angle()
			var turn_direction = 1.0 if randf() > 0.5 else -1.0
			var avoid_angle = current_angle + turn_direction * deg_to_rad(randf_range(60,120))
			new_direction = Vector2(cos(avoid_angle), sin(avoid_angle))
		else:
			new_direction = Vector2(cos(randf_range(0, TAU)), sin(randf_range(0, TAU)))
		current_wander_direction = MakeDirectionSafe(new_direction).normalized()
		#current_wander_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
		wander_timer = wander_direction_change_time * randf_range(0.8, 1.2)
	
	velocity = current_wander_direction * wander_speed

# =============================================
# 路径阻挡检测函数
# 使用射线检测（RayCast）判断当前移动方向前方是否有障碍物
# =============================================
func IsPathBlocked() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + current_wander_direction * obstacle_check_ray_length
	)
	
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	return result.has("collider")

# =============================================
# 方向安全化函数 (防止在安全区边界频繁抖动)
# 核心思想：将输入方向向量，朝着“理想安全点”的方向进行一定程度的偏转。
# “理想安全点”：位于玩家身后，与玩家保持理想安全距离的一个虚拟点。
# 这样，当敌人过于靠近或远离玩家时，其随机移动会有“回归”安全区域的趋势。
# =============================================
func MakeDirectionSafe(input_direction: Vector2) -> Vector2:
	var safe_center_distance = (keep_away_from_player_min + keep_away_from_player_max) / 2.0
	var to_player = Global.player_position - global_position
	var player_dist = to_player.length()
	var desired_offset_vector = to_player.normalized() * safe_center_distance
	var safe_target_point = Global.player_position - desired_offset_vector
	var direction_to_safe_center = (safe_target_point - global_position).normalized()
	var biased_direction = input_direction.lerp(direction_to_safe_center, boundary_avoidance_strength).normalized()
	
	return biased_direction


func _ready():
	game_state.register_special_enemy()

func _exit_tree():
	game_state.unregister_special_enemy()
