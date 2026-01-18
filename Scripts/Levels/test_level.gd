extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/Bullets/bullet.tscn")
#预加载子弹场景
@export var normal_enemy_scene: PackedScene = preload("res://Scenes/characters/Enemies/normal_enemy.tscn")
@export var special_enemy_scene: PackedScene = preload("res://Scenes/characters/Enemies/Special_enemy.tscn")
#预加载普通敌人场景
@onready var player: CharacterBody2D = $Player

@export var player_avater: Texture = preload("res://Assets/Player/player_avater.png")
@export var max_enemies_count: int = 150
@export var max_special_enemies_count: int = 1
@export var current_enemies_count: int = 0

#设置生成地图的边界
@export var map_width: float = 1450.0
@export var map_height: float = 930.0
@export var spawn_margin: float = 50.0
@export var map_center: Vector2 = Vector2(576, 324)

func _ready() -> void:
	# 方法1：检查并确保 EventAnnouncer 存在
	ensure_event_announcer()
	
	# 方法2：直接显示测试消息
	test_announcer()
	
	# ... 其他代码 ...

func ensure_event_announcer():
	# 如果单例不存在，创建并添加
	if not EventAnnouncer.instance:
		print("创建 EventAnnouncer...")
		var announcer_scene = preload("res://Scenes/UI/Event_Announcer/EventAnnouncer.tscn")
		var announcer = announcer_scene.instantiate()
		get_tree().root.add_child(announcer)
		# 等待一帧让 EventAnnouncer 初始化
		await get_tree().process_frame

func test_announcer():
	if EventAnnouncer.instance:
		print("测试广播...")
		EventAnnouncer.instance.show_warning("ALARGESUMOFBUGS", "检测到大量bugs正在接近！")
		await get_tree().create_timer(2.0).timeout
		EventAnnouncer.instance.show_warning("SUPERBOSS", "键盘映射有点问题，怎么回事？")
	else:
		print("EventAnnouncer 仍然不存在")

#func _ready() -> void:
#	print("EventAnnouncer.instance 是否存在:", EventAnnouncer.instance != null)
#	if EventAnnouncer.instance:
#		EventAnnouncer.instance.show_warning("Trojan", "检测到恶意软件！")
#		print("abs")
#	GameHUD.instance.setup_player("Player", 1, player.health, player_avater)
#	Global.current_kill_count = 0
	
func _physics_process(_delta: float) -> void:
	Global.player_position = player.global_position#实时更新玩家全局位置
	
	#测试用，打印当前杀敌数
	#print(Global.current_kill_count)
	#测试用，打印当前杀敌数
	
	#判断是否胜利
	if Global.current_kill_count >= 20:
		victory()

#发送子弹
func _on_player_shoot_string(player_position: Vector2, mouse_position: Vector2) -> void:
	var bullet = bullet_scene.instantiate()#在关卡中创建子弹实例
	bullet.global_position = player_position#设置子弹实例化时的位置
	var bullet_direction = (mouse_position - player_position).normalized()#获取子弹发射方向
	bullet.set_direction(bullet_direction)#设置子弹发射方向
	$Bullets.add_child(bullet)#将实例化的子弹场景存入Bullers节点中
	

#生成敌人，没有给确切的生成位置就随机出生点生成
func create_enemies(spawn_position: Vector2 = Vector2(0, 0)):#创建敌人方法，需要传入敌人生成位置（spawn_position）
	if current_enemies_count < max_enemies_count:
		var normal_enemy = normal_enemy_scene.instantiate()#在关卡中创建普通敌人实例
		if spawn_position == Vector2.ZERO:
			spawn_position = GetRandomSpawnPositionOutsideMap()
		normal_enemy.global_position = spawn_position#获取敌人生成位置
		$Enemies.add_child(normal_enemy)#将实例化的敌人场景存入Enemies节点中
		current_enemies_count += 1
		
func create_special_enemies(spawn_position: Vector2 = Vector2(0, 0)):
	if Global.special_enemy_count < max_special_enemies_count:
		var special_enemy = special_enemy_scene.instantiate()
		if spawn_position == Vector2.ZERO:
			spawn_position = GetRandomSpawnPositionInsideMap()
		special_enemy.global_position = spawn_position
		$Enemies.add_child(special_enemy)
		EventAnnouncer.instance.show_warning("SUPERBOSS", "特殊BUG已出现！")
		#Global.register_special_enemy()
		#测试用，打印生成敌人数量
		#print(current_enemies_count)
		#测试用，打印生成敌人数量
		
#随机获取一个地图外的出生点
func GetRandomSpawnPositionOutsideMap() -> Vector2:
	var side = randi() % 4#0，1，2，3
	var spawn_pos: Vector2 = Vector2.ZERO
	
	match side:
		0:#上边
			spawn_pos.x = randf_range(0, map_width)
			spawn_pos.y = 0
		1:#右边
			spawn_pos.x = map_width
			spawn_pos.y = randf_range(0, map_height)
		2:#下边
			spawn_pos.x = randf_range(0, map_width)
			spawn_pos.y = map_height
		3:#左边
			spawn_pos.x = 0 - spawn_margin
			spawn_pos.y = randf_range(0, map_height)
	return spawn_pos

func GetRandomSpawnPositionInsideMap() -> Vector2:
	var spawn_pos: Vector2 = Vector2.ZERO
	
	spawn_pos.x = randf_range(20, map_width)
	spawn_pos.y = randf_range(20, map_height)

	return spawn_pos

func victory():
	#测试用,打印是否胜利
	#print("success")
	#测试用,打印是否胜利
	Global.current_kill_count = 0
	SuccessScreen.instance.show_success()


#Test_Level节点下SpawnTimer生成敌人时间信号
func _on_spawn_timer_timeout() -> void:
	create_enemies()



func _on_player_player_died() -> void:#玩家死亡信号
	pass

func _on_special_spawn_timer_timeout() -> void:
	create_special_enemies()
