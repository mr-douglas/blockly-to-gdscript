extends "res://platformer_move.gd"

func build_level() -> void:
	wall(Vector2(384, 371), Vector2(768, 40), Color("#538097"))
	wall(Vector2(396, 297), Vector2(36, 108), Color("#869fd8"))
	wall(Vector2(13, 249), Vector2(26, 204), Color("#538097"))

func add_player_shape() -> void:
	add_box(player, Vector2(24, 28))

func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	player.velocity.x = direction * SPEED
	player.move_and_slide()
