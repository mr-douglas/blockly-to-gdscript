extends "res://platformer_collision.gd"

const GRAVITY := 980.0

func _ready() -> void:
	super._ready()
	player.position.y = 110

func build_level() -> void:
	wall(Vector2(384, 371), Vector2(768, 40), Color("#538097"))
	wall(Vector2(13, 249), Vector2(26, 204), Color("#538097"))
	wall(Vector2(755, 249), Vector2(26, 204), Color("#538097"))

func apply_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta

func _physics_process(delta: float) -> void:
	player.velocity.x = Input.get_axis("left", "right") * SPEED
	apply_gravity(delta)
	player.move_and_slide()
