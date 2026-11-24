extends "res://scene_3d.gd"

const SPEED := 5.2
const TURN_SPEED := 2.55
var car_a: CharacterBody3D
var car_b: CharacterBody3D
var race_camera: Camera3D

func _ready() -> void:
	stage(Vector3(0, 16, 0.01), Vector3.ZERO, 12.0)
	race_camera = get_viewport().get_camera_3d()
	race_camera.rotation = Vector3(-PI / 2.0, 0, 0)
	race_camera.position = Vector3(0, 16, 0)

	build_track()
	car_a = make_car(Vector3(-5.35, 0.26, 3.45), Color("#ffe18a"))
	car_b = make_car(Vector3(-6.55, 0.26, 3.45), Color("#73dcfa"))
	label("Gold · Arrows    Blue · WASD    R · Restart")

func build_track() -> void:
	block(Vector3(0, -0.25, 0), Vector3(15.8, 0.5, 10.6), Color("#405678"))
	block(Vector3(0, 0.17, 0), Vector3(8.8, 0.34, 4.4), Color("#3a776f"))
	for z in [-5.0, 5.0]:
		block(Vector3(0, 0.23, z), Vector3(15.7, 0.46, 0.22), Color("#829cb9"))
	for x in [-7.7, 7.7]:
		block(Vector3(x, 0.23, 0), Vector3(0.22, 0.46, 10), Color("#829cb9"))
	for z in [-3.55, 3.55]:
		for x in range(-3, 4, 2):
			paint(Vector3(x, 0.01, z), Vector3(0.75, 0.02, 0.08), Color("#aebed8"))
	for lane in range(8):
		var color := Color("#e3edf9") if lane % 2 == 0 else Color("#26354e")
		paint(Vector3(-7.35 + lane * 0.37, 0.013, 2.45), Vector3(0.36, 0.025, 0.28), color)

func paint(at: Vector3, size: Vector3, color: Color) -> void:
	var marker := Node3D.new()
	marker.position = at
	var mesh := BoxMesh.new()
	mesh.size = size
	add_mesh(marker, mesh, color)
	add_child(marker)

func make_car(at: Vector3, color: Color) -> CharacterBody3D:
	var car := CharacterBody3D.new()
	car.position = at
	box(car, Vector3(0.63, 0.5, 1.02), color)
	var windshield := Node3D.new()
	windshield.position = Vector3(0, 0.27, -0.18)
	car.add_child(windshield)
	var glass := BoxMesh.new()
	glass.size = Vector3(0.45, 0.1, 0.28)
	add_mesh(windshield, glass, Color("#263851"))
	add_child(car)
	return car

func drive(car: CharacterBody3D, turn: float, throttle: float, delta: float) -> void:
	car.rotate_y(turn * TURN_SPEED * delta)
	car.velocity = -car.transform.basis.z * throttle * SPEED
	car.move_and_slide()

func _physics_process(delta: float) -> void:
	drive(car_a, Input.get_axis("right", "left"), Input.get_axis("down", "up"), delta)
	drive(car_b, Input.get_axis("p2_right", "p2_left"), Input.get_axis("p2_down", "p2_up"), delta)
