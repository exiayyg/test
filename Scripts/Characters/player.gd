extends CharacterBody2D

@export var speed: float = 200 #玩家速度
@export var direction: Vector2 = Vector2(0, 0) #玩家移动方向
@export var health: float = 100 #生命值
signal shoot_string(player_position: Vector2) #射击信号

const is_player: bool = true

func _physics_process(_delta: float) -> void:
	PlayerMovement()
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot"):
		Shoot()

#射击逻辑
func Shoot():
	shoot_string.emit(global_position, get_global_mouse_position())
	print("shoot")

#玩家伤害逻辑
func hurt(damage: float):
	health -= damage

#玩家移动逻辑
func PlayerMovement():
	direction = Input.get_vector("Left","Right","Up","Down")
	velocity = speed * direction
	move_and_slide()
