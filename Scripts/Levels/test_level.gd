extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/Bullets/bullet.tscn")
#预加载子弹场景
@export var normal_enemy_scene: PackedScene = preload("res://Scenes/characters/Enemies/normal_enemy.tscn")
#预加载普通敌人场景
@onready var player: CharacterBody2D = $Player

@export var player_avater: Texture = preload("res://Assets/Player/player.png")
#设置生成地图的边界
@export var map_width: float = 1450.0
@export var map_height: float = 930.0
@export var spawn_margin: float = 50.0
@export var map_center: Vector2 = Vector2(576, 324)

func _ready() -> void:
	GameHUD.instance.setup_player("Player", 1, 3)

func _physics_process(_delta: float) -> void:
	Global.player_position = player.global_position#实时更新玩家全局位置

#发送子弹
func _on_player_shoot_string(player_position: Vector2, mouse_position: Vector2) -> void:
	var bullet = bullet_scene.instantiate()#在关卡中创建子弹实例
	bullet.global_position = player_position#设置子弹实例化时的位置
	var bullet_direction = (mouse_position - player_position).normalized()#获取子弹发射方向
	bullet.set_direction(bullet_direction)#设置子弹发射方向
	$Bullets.add_child(bullet)#将实例化的子弹场景存入Bullers节点中

#生成敌人，没有给确切的生成位置就随机出生点生成
func create_enemies(spawn_position: Vector2 = Vector2(0, 0)):#创建敌人方法，需要传入敌人生成位置（spawn_position）
	var normal_enemy = normal_enemy_scene.instantiate()#在关卡中创建普通敌人实例
	if spawn_position == Vector2.ZERO:
		spawn_position = GetRandomSpawnPositionOutsideMap()
	normal_enemy.global_position = spawn_position#获取敌人生成位置
	$Enemies.add_child(normal_enemy)#将实例化的敌人场景存入Enemies节点中

#随机获取一个地图外的出生点
func GetRandomSpawnPositionOutsideMap() -> Vector2:
	var side = randi() % 4#0，1，2，3
	var spawn_pos: Vector2 = Vector2.ZERO
	
	match side:
		0:#上边
			spawn_pos.x = randf_range(0, map_width)
			spawn_pos.y = 0 - spawn_margin
		1:#右边
			spawn_pos.x = map_width + spawn_margin
			spawn_pos.y = randf_range(0, map_height)
		2:#下边
			spawn_pos.x = randf_range(0, map_width)
			spawn_pos.y = map_height + spawn_margin
		3:#左边
			spawn_pos.x = 0 - spawn_margin
			spawn_pos.y = randf_range(0, map_height)
	return spawn_pos

#Test_Level节点下SpawnTimer生成敌人时间信号
func _on_spawn_timer_timeout() -> void:
	create_enemies()
