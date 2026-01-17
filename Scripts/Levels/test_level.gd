extends Node2D

@export var bullet_scene: PackedScene = preload("res://Scenes/Bullets/bullet.tscn")
@export var normal_enemy_scene: PackedScene = preload("res://Scenes/characters/Enemies/normal_enemy.tscn")

@onready var player: CharacterBody2D = $Player


func _physics_process(_delta: float) -> void:
	Global.player_position = player.global_position

func _on_player_shoot_string(player_position: Vector2, mouse_position: Vector2) -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = player_position
	var bullet_position = (mouse_position - player_position).normalized()
	bullet.set_direction(bullet_position)
	$Bullets.add_child(bullet)

func create_enemies(spwan_position: Vector2):
	var normal_enemy = normal_enemy_scene.instantiate()
	normal_enemy.global_position = spwan_position
	$Enemies.add_child(normal_enemy)
