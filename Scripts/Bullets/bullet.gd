extends Area2D

@export var damage: float
@export var speed: float = 400
@export var direction: Vector2

func _physics_process(delta: float) -> void:
	position += speed * direction * delta

func set_direction(bullet_position: Vector2):
	direction = bullet_position


func _on_body_entered(body: Node2D) -> void:
	if "is_enemy" in body:
		body.queue_free()
		queue_free()
