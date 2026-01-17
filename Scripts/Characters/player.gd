extends CharacterBody2D

@export var speed: float = 200#玩家移动速度
@export var direction: Vector2 = Vector2(0, 0)#玩家移动方向
@export var health: float = 3#玩家生命值
@onready var game_state = get_node("/root/Global")


var can_shoot: bool = true#判断是否处于开火冷却
var can_hurt: bool = true#判断是否处于可受伤状态，true为可受伤，false为无敌状态
signal shoot_string(player_position: Vector2, mouse_position: Vector2)#发射子弹信号,需要传入发射点位置和鼠标点击位置

const is_player: bool = true#判断是否是玩家



func _physics_process(_delta: float) -> void:
	PlayerMovement()
	look_at(get_global_mouse_position())#玩家看向鼠标位置
	if Input.is_action_pressed("Shoot") and can_shoot:#当鼠标左键被按住，且可发射子弹为真时
		Shoot()
		can_shoot = false#发射子弹后，将可发射子弹设置为假
		$Timer_node/shoot_cooldown.start()#发射冷却开始倒计时
	if health <= 0:#判断玩家是否死亡
		died()

#射击逻辑
func Shoot():
	shoot_string.emit(global_position, get_global_mouse_position())
	#发送发射子弹信号，在level脚本调用
	#print("shoot")

func died():#玩家死亡逻辑
	print("player died")
	pass

#伤害逻辑
func hurt(damage: float):
	if can_hurt:
		health -= damage
		print("player hurted", health)
		can_hurt = false
		$Timer_node/can_hurt_cooldown.start()
	#玩家受伤逻辑

#玩家移动逻辑
func PlayerMovement():
	if game_state.inverted_controls:
		# 反转控制：左右互换，上下互换
		direction.x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
		direction.y = Input.get_action_strength("Up") - Input.get_action_strength("Down")
	else:
		# 正常控制
		direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
		direction.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	direction = direction.normalized()
	velocity = speed * direction#修改玩家移动速度大小及方向
	move_and_slide()#控制玩家移动

func _on_shoot_cooldown_timeout() -> void:#可发射子弹倒计时
	can_shoot = true#冷却结束，将是否可发射设置为真


func _on_can_hurt_cooldown_timeout() -> void:#可受伤倒计时
	can_hurt = true#冷却结束，将是否可受伤设置为真
