extends "res://platform3d_fall.gd"

const JUMP_SPEED := 5.9

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("action") and player.is_on_floor():
		player.velocity.y = JUMP_SPEED
	super._physics_process(delta)
