extends "res://platformer_jump.gd"

const FALL_LIMIT := 480.0

func _ready() -> void:
	super._ready()
	respawn()

func build_level() -> void:
	wall(Vector2(130, 371), Vector2(260, 40), Color("#538097"))
	wall(Vector2(559, 371), Vector2(418, 40), Color("#79b2ab"))

func respawn() -> void:
	player.position = START
	player.velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if player.position.y > FALL_LIMIT:
		respawn()
