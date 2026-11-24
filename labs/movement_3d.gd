extends "res://scene_3d.gd"

const SPEED := 4.1
const GRAVITY := 9.8
const START := Vector3(-4, 0.5, 2)
const GOAL := Vector3(4, 0.04, -2.1)
var player := CharacterBody3D.new()
var status: Label
var reached := false

func _ready() -> void:
	stage(Vector3(0, 12, 11), Vector3.ZERO, 14.5)
	block(Vector3(0, -0.25, 0), Vector3(12, 0.5, 8), Color("#386887"))
	var dot := BoxMesh.new()
	dot.size = Vector3(0.05, 0.01, 0.05)
	for x in range(-5, 6):
		for z in range(-3, 4):
			var marker := Node3D.new()
			marker.position = Vector3(x, 0.005, z)
			add_mesh(marker, dot, Color("#78a5ba"))
			add_child(marker)
	block(Vector3(-1.2, 0.55, 0.9), Vector3(0.8, 1.1, 3.2), Color("#cf759b"))
	block(Vector3(1.7, 0.45, -1.1), Vector3(2.4, 0.9, 0.7), Color("#cf759b"))
	var beacon := Node3D.new()
	beacon.position = GOAL
	add_child(beacon)
	var mesh := CylinderMesh.new()
	mesh.height = 0.08
	mesh.top_radius = 0.65
	mesh.bottom_radius = 0.65
	add_mesh(beacon, mesh, Color("#75ffbe"))
	player.position = START
	box(player, Vector3(0.72, 0.96, 0.7), Color("#ffd073"))
	add_child(player)
	status = label("Navigate to the green landing pad")

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	player.velocity.x = direction.x * SPEED
	player.velocity.z = direction.y * SPEED
	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	player.move_and_slide()

	if player.position.y < -3.0:
		player.position = START
		player.velocity = Vector3.ZERO
	if not reached and player.position.distance_to(GOAL) < 0.8:
		reached = true
		status.text = "Landing pad reached! Press R to restart."
