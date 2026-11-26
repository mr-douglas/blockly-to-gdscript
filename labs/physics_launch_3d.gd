extends "res://physics_art_3d.gd"

const LAUNCH_AT := Vector3(-5, 1, 0)
const SPEED := 11.0
const CRATE := 0.8
const FLIGHT_TIME := 4.0
var angle := 20.0
var turn := 0.0
var ball: RigidBody3D
var launched := false
var flight := 0.0
var shots := 0
var crates: Array[RigidBody3D] = []
var arrow: MeshInstance3D
var status: Label

func _ready() -> void:
	# The camera looks from behind the thrower's left shoulder.
	stage(Vector3(-9, 7.7, 9), Vector3(0, 1.5, 0), 11.0)
	island(Vector3(14, 1, 7))
	# A pyramid of crates: 3 on the bottom, then 2, then 1. Two rows deep.
	for row in 3:
		for i in 3 - row:
			for depth in 2:
				var z := (i - (2 - row) / 2.0) * CRATE * 1.05
				add_crate(Vector3(3 + depth * CRATE * 1.05, CRATE / 2 + row * CRATE, z), row == 0)
	arrow = make_arrow()
	status = label("")
	new_ball()

func add_crate(at: Vector3, strong: bool) -> void:
	var crate := RigidBody3D.new()
	crate.position = at
	crate.mass = 0.5
	crate.set_meta("start", at)
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * CRATE
	add_shape(crate, shape)
	crate_art(crate, shape.size, strong)
	add_child(crate)
	crates.append(crate)

func new_ball() -> void:
	ball = RigidBody3D.new()
	ball.position = LAUNCH_AT
	ball.mass = 2.0
	ball.freeze = true
	ball.continuous_cd = true
	var sphere := SphereShape3D.new()
	sphere.radius = 0.35
	add_shape(ball, sphere)
	var mesh := SphereMesh.new()
	mesh.radius = sphere.radius
	mesh.height = sphere.radius * 2
	add_mesh(ball, mesh, Color("#e8574a"))
	add_child(ball)
	launched = false
	arrow.visible = true

# Start pointing along +x, tip it up by `angle`, then turn it by `turn`.
func launch_direction() -> Vector3:
	var up := deg_to_rad(angle)
	var direction := Vector3(cos(up), sin(up), 0)
	return direction.rotated(Vector3.UP, deg_to_rad(turn))

func _physics_process(delta: float) -> void:
	if launched:
		flight += delta
		if flight > FLIGHT_TIME:
			ball.queue_free()
			new_ball()
	else:
		angle = clampf(angle + Input.get_axis("down", "up") * 30 * delta, 0, 70)
		turn = clampf(turn + Input.get_axis("right", "left") * 30 * delta, -30, 30)
		point_arrow(arrow, LAUNCH_AT, launch_direction(), 2.5)
		if Input.is_action_just_pressed("action"):
			throw_ball()
	var knocked := 0
	for crate in crates:
		if crate.position.distance_to(crate.get_meta("start")) > CRATE / 2:
			knocked += 1
	status.text = "Up/Down: angle %d   Left/Right: turn %d   Space: throw\nShots: %d   Crates knocked: %d / %d" % [angle, turn, shots, knocked, crates.size()]

func throw_ball() -> void:
	launched = true
	flight = 0.0
	shots += 1
	arrow.visible = false
	ball.freeze = false
	ball.apply_central_impulse(launch_direction() * SPEED * ball.mass)
