extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/Bullets/bullet.tscn")
#预加载子弹场景
@export var normal_enemy_scene: PackedScene = preload("res://Scenes/characters/Enemies/normal_enemy.tscn")
#预加载普通敌人场景
@onready var player: CharacterBody2D = $Player


func _physics_process(_delta: float) -> void:
	Global.player_position = player.global_position#实时更新玩家全局位置

func _on_player_shoot_string(player_position: Vector2, mouse_position: Vector2) -> void:
	var bullet = bullet_scene.instantiate()#在关卡中创建子弹实例
	bullet.global_position = player_position#设置子弹实例化时的位置
	var bullet_direction = (mouse_position - player_position).normalized()#获取子弹发射方向
	bullet.set_direction(bullet_direction)#设置子弹发射方向
	$Bullets.add_child(bullet)#将实例化的子弹场景存入Bullers节点中

func create_enemies(spwan_position: Vector2):#创建敌人方法，需要传入敌人生成位置（spwan_position）
	var normal_enemy = normal_enemy_scene.instantiate()#在关卡中创建普通敌人实例
	normal_enemy.global_position = spwan_position#获取敌人生成位置
	$Enemies.add_child(normal_enemy)#将实例化的敌人场景存入Enemies节点中
