extends Area2D

@export var damage: float
@export var speed: float
@export var direction: Vector2

func _physics_process(delta: float) -> void:
	position += speed * direction * delta

func _on_body_entered(body: Node2D) -> void:
	if "is_enemy" in body:
		body.queue_free()
		queue_free()
