extends "res://physics_art_3d.gd"

# First person: you stand still at EYE, turn your head with the arrow keys
# and shoot balls straight ahead, wherever the camera is looking.
const EYE := Vector3(-3, 1.3, 0)
const SPEED := 14.0
const LOOK_SPEED := 45.0  # degrees per second
const CRATE := 0.8
const FLIGHT_TIME := 4.0
var look_up := 3.0
var look_left := 0.0
var eye: Camera3D
var shots := 0
var crates: Array[RigidBody3D] = []
var status: Label

func _ready() -> void:
	stage(EYE, Vector3(3, 1, 0), 12.0)  # Lights.
	outdoors()  # Sky, fields and distant trees.
	# A perspective camera at head height. Things further away look smaller.
	eye = Camera3D.new()
	eye.fov = 60.0
	eye.position = EYE
	add_child(eye)
	eye.current = true
	island(Vector3(14, 1, 7))
	# A pyramid of crates: 3 on the bottom, then 2, then 1. Two rows deep.
	for row in 3:
		for i in 3 - row:
			for depth in 2:
				var z := (i - (2 - row) / 2.0) * CRATE * 1.05
				add_crate(Vector3(3 + depth * CRATE * 1.05, CRATE / 2 + row * CRATE, z), row == 0)
	add_crosshair()
	status = label("")

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

# A "+" in the middle of the screen shows where the camera is pointing.
func add_crosshair() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var mark := Label.new()
	mark.text = "+"
	mark.add_theme_font_size_override(&"font_size", 40)
	mark.add_theme_color_override(&"font_outline_color", Color.BLACK)
	mark.add_theme_constant_override(&"outline_size", 6)
	mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(mark)

func _physics_process(delta: float) -> void:
	# Turn the head, but only so far: you cannot look behind you.
	look_left = clampf(look_left + Input.get_axis("right", "left") * LOOK_SPEED * delta, -45, 45)
	look_up = clampf(look_up + Input.get_axis("down", "up") * LOOK_SPEED * delta, -15, 60)
	# A camera looks along -z. Turning it -90 degrees makes it look along +x,
	# towards the crates.
	eye.rotation_degrees = Vector3(look_up, look_left - 90, 0)
	if Input.is_action_just_pressed("action"):
		shoot()
	var knocked := 0
	for crate in crates:
		if crate.position.distance_to(crate.get_meta("start")) > CRATE / 2:
			knocked += 1
	status.text = "Arrows: look around   Space: shoot\nShots: %d   Crates knocked: %d / %d" % [shots, knocked, crates.size()]

func shoot() -> void:
	shots += 1
	# The camera's forward direction is minus its local z axis.
	var aim := -eye.global_transform.basis.z
	var ball := RigidBody3D.new()
	ball.position = EYE + aim * 0.6
	ball.mass = 2.0
	ball.continuous_cd = true
	var sphere := SphereShape3D.new()
	sphere.radius = 0.25
	add_shape(ball, sphere)
	var mesh := SphereMesh.new()
	mesh.radius = sphere.radius
	mesh.height = sphere.radius * 2
	add_mesh(ball, mesh, Color("#e8574a"))
	add_child(ball)
	ball.apply_central_impulse(aim * SPEED * ball.mass)
	# Tidy up: remove the ball a few seconds later.
	get_tree().create_timer(FLIGHT_TIME).timeout.connect(ball.queue_free)
