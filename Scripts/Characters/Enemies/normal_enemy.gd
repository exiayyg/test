class_name Enemy
extends CharacterBody2D
#敌人脚本

@export var speed: float = 100 #移动速度
@export var health: float = 100 #生命值
@export var damage: float = 1 #伤害
@onready var sprite_2d: Sprite2D = $Sprite2D


const is_enemy: bool = true #是否为敌人

var target_position: Vector2 = Vector2(0, 0)#寻路导航下一目标位置
var direction: Vector2 = Vector2(0, 0) #敌人朝向玩家的方向
var look_direction: Vector2

func _ready() -> void:
	$NavigationAgent2D.target_position = Global.player_position#在敌人初始化时将玩家位置设为目标位置

func _physics_process(_delta: float) -> void:
	EnemyMovement()
	UpdateSpriteRotation()
	if health <= 0:#如果生命值小于零，则死亡
		died()

func UpdateSpriteRotation():
	if look_direction.length() > 10:
		var move_angle = look_direction.angle()
		sprite_2d.rotation = lerp(sprite_2d.rotation, move_angle, 0.1)
	else:
		pass

#敌人受伤逻辑
func hurt(bullet_damage: float):
	health -= bullet_damage

#敌人死亡逻辑
func died():
	queue_free()

#碰撞玩家逻辑
func _on_attack_area_body_entered(body: Node2D) -> void:
	if "is_player" in body:
		body.hurt(damage)

#敌人移动逻辑
func EnemyMovement():
	target_position = $NavigationAgent2D.get_next_path_position()#获取导航下一个位置
	direction = (target_position - global_position).normalized()#根据导航的下一位置修改移动
	velocity = speed * direction
	look_direction = direction
	look_at(target_position)#敌人始终看向移动方向
	move_and_slide()
	#敌人朝向玩家直线移动


func _on_catch_player_position_timeout() -> void:
	$NavigationAgent2D.target_position = Global.player_position#倒计时结束时获取将当前玩家位置设置为导航的下一个位置
