extends CharacterBody2D

@export var speed: float = 200
@export var direction: Vector2 = Vector2(0, 0)
@export var health: float = 100
signal shoot_string(player_position: Vector2)

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("Left","Right","Up","Down")
	velocity = speed * direction
	move_and_slide()
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("Shoot"):
		Shoot()

func Shoot():
	shoot_string.emit(global_position)
	print("shoot")
	
func hurt():
	pass
