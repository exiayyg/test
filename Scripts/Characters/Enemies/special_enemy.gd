extends Enemy

@export var keep_away_form_player: float = 500.0
var distance_to_player: Vector2

func _physics_process(delta: float) -> void:
	EnemyMovement()

func EnemyMovement():
	direction = (Global.player_position - global_position).normalized()
	distance_to_player = Global.player_position - global_position
	if distance_to_player.length() > keep_away_form_player:
		velocity = speed * direction
	else:
		velocity = speed * -direction
	move_and_slide()
