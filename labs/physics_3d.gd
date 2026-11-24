extends "res://scene_3d.gd"

const IMPULSE := Vector3(10.5, 0, 0)
var ball: RigidBody3D
var status: Label
var launched := false

func _ready() -> void:
	stage(Vector3(5.0, 8.5, 14), Vector3(0, 0.9, 0), 14.0)
	block(Vector3(0, -0.25, 0), Vector3(13, 0.5, 7), Color("#365675"))
	var ramp := block(Vector3(-2.7, 0.78, 0), Vector3(5.7, 0.25, 1.9), Color("#5b9fa4"))
	ramp.rotation_degrees.z = -14
	for lane in [-0.9, 0.0, 0.9]:
		for height in [0.36, 1.065, 1.77]:
			var crate := RigidBody3D.new()
			crate.position = Vector3(2.15, height, lane)
			crate.mass = 0.35
			box(crate, Vector3(0.67, 0.7, 0.65), Color("#e89369") if height > 1.7 else Color("#d8ae63"))
			add_child(crate)
	ball = RigidBody3D.new()
	ball.position = Vector3(-4.8, 2.55, 0.22)
	ball.mass = 1.25
	ball.freeze = true
	ball.continuous_cd = true
	var sphere := SphereShape3D.new()
	sphere.radius = 0.45
	add_shape(ball, sphere)
	var mesh := SphereMesh.new()
	mesh.radius = sphere.radius
	mesh.height = sphere.radius * 2
	add_mesh(ball, mesh, Color("#82fff2"))
	add_child(ball)
	status = label("Press Space to release the ball")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") and not launched:
		launched = true
		ball.freeze = false
		ball.apply_central_impulse(IMPULSE)
		status.text = "Watch the collisions. Press R to reset."
