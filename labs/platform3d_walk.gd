extends "res://scene_3d.gd"

const SPEED := 4.4
const TURN_RATE := 2.1
const START := Vector3(0, 0.55, 2.8)
var player := CharacterBody3D.new()
var player_art := Node3D.new()

func _ready() -> void:
	stage(Vector3(8, 12, 13), Vector3(0, 0, -2), 13.0)
	build_level()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.65, 1.1, 0.65)
	add_shape(player, shape)
	player.add_child(player_art)
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	add_mesh(player_art, mesh, Color("#ffcb79"))
	var nose := Node3D.new()
	nose.position = Vector3(0, 0.21, -0.34)
	player_art.add_child(nose)
	var panel := BoxMesh.new()
	panel.size = Vector3(0.4, 0.18, 0.06)
	add_mesh(nose, panel, Color("#794f89"))
	player.position = START
	add_child(player)
	label("Left / Right: turn   Up / Down: move")

func build_level() -> void:
	block(Vector3(0, -0.25, -1.8), Vector3(7, 0.5, 11), Color("#386887"))
	block(Vector3(0, 0.36, 0.1), Vector3(1.5, 0.72, 0.6), Color("#cf759b"))
	block(Vector3(-2.8, 0.32, -3.5), Vector3(0.52, 0.65, 5), Color("#729fba"))
	block(Vector3(2.8, 0.32, -3.5), Vector3(0.52, 0.65, 5), Color("#729fba"))

func steer(delta: float) -> void:
	var turn := Input.get_axis("right", "left")
	player.rotate_y(turn * TURN_RATE * delta)
	var forward := -player.transform.basis.z
	var throttle := Input.get_axis("down", "up")
	player.velocity.x = forward.x * throttle * SPEED
	player.velocity.z = forward.z * throttle * SPEED

func _physics_process(delta: float) -> void:
	steer(delta)
	player.move_and_slide()
