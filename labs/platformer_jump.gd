extends "res://platformer_gravity.gd"

const JUMP_SPEED := 440.0

func build_level() -> void:
	super.build_level()
	wall(Vector2(420, 315), Vector2(134, 24), Color("#79b2ab"))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and player.is_on_floor():
		player.velocity.y = -JUMP_SPEED
	super._physics_process(delta)
