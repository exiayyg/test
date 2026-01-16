class_name Enemy
extends CharacterBody2D

@export var speed: float = 100
@export var health: float = 100
@export var damage: float = 10

const is_enemy: bool = true

var direction: Vector2 = Vector2(0, 0)

func _physics_process(_delta: float) -> void:
	direction = (Global.player_position - global_position).normalized()
	velocity = speed * direction
	move_and_slide()
	if health <= 0:
		died()

func hurt():
	health -= damage

func died():
	queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if "is_player" in body:
		body.hurt(damage)
