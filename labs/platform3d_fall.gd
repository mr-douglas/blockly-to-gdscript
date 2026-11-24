extends "res://platform3d_walk.gd"

const GRAVITY := 14.0
const FALL_LIMIT := -5.0

func _ready() -> void:
	super._ready()
	player.position.y = 3.0

func respawn() -> void:
	player.position = START
	player.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	steer(delta)
	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	player.move_and_slide()
	if player.position.y < FALL_LIMIT:
		respawn()
