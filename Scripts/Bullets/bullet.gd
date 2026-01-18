extends Area2D

@export var damage: float#子弹可造成的伤害值
@export var speed: float = 400#子弹移动速度
@export var direction: Vector2#子弹移动方向
@onready var sprite_2d: Sprite2D = $Sprite2D

func _process(delta: float) -> void:
	sprite_2d.rotation = lerp(sprite_2d.rotation, direction.angle(), 0.1)
#子弹移动逻辑
func _physics_process(delta: float) -> void:
	position += speed * direction * delta#子弹移动逻辑

func set_direction(bullet_direction: Vector2):
	#设置子弹移动方向，在level脚本中实例化子弹时调用，需要传入子弹移动方向bullet_direction
	direction = bullet_direction


func _on_body_entered(body: Node2D) -> void:#子弹碰撞信号
	if "is_enemy" in body:#如果碰撞对象是敌人
		body.queue_free()#销毁敌人
		Global.current_kill_count += 1
	queue_free()#销毁子弹
