extends "res://platformer_jump.gd"

const FALL_LIMIT := 480.0

func _ready() -> void:
	super._ready()
	respawn()

func build_level() -> void:
	block(Vector2(130, 371), Vector2(260, 40))
	block(Vector2(559, 371), Vector2(418, 40))

func respawn() -> void:
	player.position = START
	player.velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if player.position.y > FALL_LIMIT:
		respawn()
