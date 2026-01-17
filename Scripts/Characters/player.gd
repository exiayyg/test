extends CharacterBody2D

@export var speed: float = 200#玩家移动速度
@export var direction: Vector2 = Vector2(0, 0)#玩家移动方向
@export var health: float = 3#玩家生命值
signal shoot_string(player_position: Vector2, mouse_position: Vector2)#发射子弹信号,需要传入发射点位置和鼠标点击位置

const is_player: bool = true#判断是否是玩家

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("Left","Right","Up","Down")#获取移动方向
	velocity = speed * direction#修改玩家移动速度大小及方向
	move_and_slide()#控制玩家移动
	look_at(get_global_mouse_position())#玩家看向鼠标位置
	if Input.is_action_just_pressed("Shoot"):#鼠标左键发射子弹
		Shoot()

func Shoot():
	shoot_string.emit(global_position, get_global_mouse_position())
	#发送发射子弹信号，在level脚本调用
	#print("shoot")
	
func hurt(damage: float):
	health -= damage
	#玩家受伤逻辑
