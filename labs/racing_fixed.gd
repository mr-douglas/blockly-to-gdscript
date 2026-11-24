extends "res://racing_track.gd"

const SPEED := 5.2
const TURN_SPEED := 2.55
const CAMERA_AT := Vector3(0, 12, 11.5)
const LOOK_AT := Vector3(0, 0, 1.3)
var car_a: CharacterBody3D
var car_b: CharacterBody3D
var race_camera: Camera3D

func _ready() -> void:
	build_world()

	# A perspective camera above and behind the track, tilted down at it.
	race_camera = Camera3D.new()
	race_camera.fov = 50.0
	race_camera.position = CAMERA_AT
	add_child(race_camera)
	race_camera.look_at(LOOK_AT)
	race_camera.current = true

	car_a = make_car(ORANGE_CAR, grid_slot(0))
	car_b = make_car(GREEN_CAR, grid_slot(1))
	label("Orange · Arrows    Green · WASD    R · Restart")

func make_car(model: PackedScene, start: Transform3D) -> CharacterBody3D:
	var car := CharacterBody3D.new()
	car.transform = start
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.56, 0.5, 1.3)
	add_shape(car, shape)
	# The Kenney cars face +Z. Turn them half a circle to face Godot's forward, -Z.
	add_model(car, model, Vector3.ZERO, PI)
	add_child(car)
	return car

func drive(car: CharacterBody3D, turn: float, throttle: float, delta: float) -> void:
	car.rotate_y(turn * TURN_SPEED * delta)
	car.velocity = -car.transform.basis.z * throttle * SPEED
	car.move_and_slide()

func _physics_process(delta: float) -> void:
	drive(car_a, Input.get_axis("right", "left"), Input.get_axis("down", "up"), delta)
	drive(car_b, Input.get_axis("p2_right", "p2_left"), Input.get_axis("p2_down", "p2_up"), delta)
