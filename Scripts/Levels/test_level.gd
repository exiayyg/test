extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/Bullets/bullet.tscn")

func _on_player_shoot_string(player_position: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = player_position
	$Bullets.add_child(bullet)
