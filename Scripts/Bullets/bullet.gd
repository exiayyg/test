extends Area2D

@export var damage: float #子弹伤害
@export var speed: float = 400 #子弹速度
@export var direction: Vector2 #子弹方向

#子弹移动逻辑
func _physics_process(delta: float) -> void:
	position += speed * direction * delta

#设置子弹朝向
func set_direction(bullet_position: Vector2):
	direction = bullet_position

#击中敌人逻辑
func _on_body_entered(body: Node2D) -> void:
	if "is_enemy" in body:
		body.queue_free()
		queue_free()
