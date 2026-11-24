extends "res://movement_3d.gd"

# Radians per second.
const TURN_SPEED := 2.2

func _ready() -> void:
	super._ready()
	var arm := SpringArm3D.new()
	arm.position = Vector3(0, 0.9, 0)
	arm.rotation.x = -0.35
	arm.spring_length = 4.6
	var probe := SphereShape3D.new()
	probe.radius = 0.18
	arm.shape = probe
	arm.add_excluded_object(player.get_rid())
	player.add_child(arm)

	var camera := Camera3D.new()
	arm.add_child(camera)
	camera.make_current()

func _physics_process(delta: float) -> void:
	var turn := Input.get_axis("right", "left")
	player.rotate_y(turn * TURN_SPEED * delta)

	var throttle := Input.get_axis("down", "up")
	var forward := -player.transform.basis.z
	var motion := forward * throttle * SPEED
	player.velocity.x = motion.x
	player.velocity.z = motion.z
	move_player(delta)
