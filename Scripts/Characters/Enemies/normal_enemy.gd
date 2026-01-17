class_name Enemy
extends CharacterBody2D
#敌人脚本

@export var speed: float = 100 #移动速度
@export var health: float = 100 #生命值
@export var damage: float = 10 #伤害

const is_enemy: bool = true #是否为敌人

var direction: Vector2 = Vector2(0, 0) #敌人朝向玩家的方向

func _physics_process(_delta: float) -> void:
	EnemyMovement()
	if health <= 0:#如果生命值小于零，则死亡
		died()

#敌人受伤逻辑
func hurt():
	health -= damage

#敌人死亡逻辑
func died():
	queue_free()

#碰撞玩家逻辑
func _on_attack_area_body_entered(body: Node2D) -> void:
	if "is_player" in body:
		body.hurt(damage)

#敌人移动逻辑
func EnemyMovement():
	direction = (Global.player_position - global_position).normalized()
	velocity = speed * direction
	move_and_slide()
	#敌人朝向玩家直线移动
