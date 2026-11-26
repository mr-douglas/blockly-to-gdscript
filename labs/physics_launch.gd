extends "res://physics_art_2d.gd"

const LAUNCH_AT := Vector2(110, 300)
const BALL_RADIUS := 22.0
const MIN_POWER := 300.0
const MAX_POWER := 1000.0
var angle := 40.0
var power := 650.0
var ball: RigidBody2D
var launched := false
var shots := 0
var targets: Array[RigidBody2D] = []
var aim: Line2D
var status: Label

func _ready() -> void:
	backdrop()
	ground()
	var stand := Node2D.new()
	stand.position = Vector2(LAUNCH_AT.x, FLOOR_Y - 35)
	block_art(stand, Vector2(24, 70), "wood")
	add_child(stand)
	build_tower(560)
	aim = Line2D.new()
	aim.width = 5
	aim.default_color = Color(1, 0.85, 0.25, 0.8)
	add_child(aim)
	status = label_at(Vector2(18, 12), "")
	new_ball()

func build_tower(x: float) -> void:
	add_block(Vector2(x - 55, FLOOR_Y - 55), Vector2(30, 110), "wood")
	add_block(Vector2(x + 55, FLOOR_Y - 55), Vector2(30, 110), "wood")
	add_block(Vector2(x, FLOOR_Y - 127.5), Vector2(170, 35), "wood")
	add_target(Vector2(x, FLOOR_Y - 25))
	add_block(Vector2(x - 45, FLOOR_Y - 180), Vector2(30, 70), "stone")
	add_block(Vector2(x + 45, FLOOR_Y - 180), Vector2(30, 70), "stone")
	add_block(Vector2(x, FLOOR_Y - 230), Vector2(130, 30), "stone")
	add_target(Vector2(x, FLOOR_Y - 170))

func add_block(at: Vector2, size: Vector2, kind: String) -> void:
	var body := RigidBody2D.new()
	body.position = at
	body.mass = 3.0 if kind == "stone" else 1.0
	add_box(body, size)
	block_art(body, size, kind)
	add_child(body)

# A target is knocked out when it moves well away from where it started.
func add_target(at: Vector2) -> void:
	var target := RigidBody2D.new()
	target.position = at
	target.set_meta("start", at)
	add_box(target, Vector2(50, 50))
	alien_art(target, 25, "pink")
	add_child(target)
	targets.append(target)

func new_ball() -> void:
	ball = RigidBody2D.new()
	ball.position = LAUNCH_AT
	ball.mass = 2.0
	# Frozen bodies ignore gravity until we let go of them.
	ball.freeze = true
	ball.continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	var circle := CollisionShape2D.new()
	circle.shape = CircleShape2D.new()
	circle.shape.radius = BALL_RADIUS
	ball.add_child(circle)
	alien_art(ball, BALL_RADIUS, "green")
	add_child(ball)
	launched = false

func launch_velocity() -> Vector2:
	# Angles in Godot go clockwise, so "up" is a negative angle.
	return Vector2.from_angle(deg_to_rad(-angle)) * power

func _physics_process(delta: float) -> void:
	if not launched:
		angle = clampf(angle + Input.get_axis("down", "up") * 40 * delta, 5, 80)
		power = clampf(power + Input.get_axis("left", "right") * 300 * delta, MIN_POWER, MAX_POWER)
		draw_aim()
		if Input.is_action_just_pressed("action"):
			throw_ball()
	var knocked := 0
	for target in targets:
		if target.position.distance_to(target.get_meta("start")) > 30:
			knocked += 1
	if knocked == targets.size():
		status.text = "All aliens knocked out in %d shots! Press R to play again." % shots
	else:
		status.text = "Angle %d (Up/Down)   Power %d (Left/Right)   Space to throw\nShots: %d   Aliens knocked out: %d / %d" % [angle, power, shots, knocked, targets.size()]

# Show the first part of the ball's path: position = start + velocity * t + gravity * t * t / 2
func draw_aim() -> void:
	var gravity := Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var points := PackedVector2Array()
	for step in 12:
		var t := step * 0.05
		points.append(LAUNCH_AT + launch_velocity() * t + gravity * t * t / 2)
	aim.points = points

func throw_ball() -> void:
	launched = true
	shots += 1
	aim.points = PackedVector2Array()
	ball.freeze = false
	# An impulse is a sudden push. Multiply by mass so the ball leaves at
	# exactly launch_velocity() however heavy it is.
	ball.apply_central_impulse(launch_velocity() * ball.mass)
	await get_tree().create_timer(4.0).timeout
	ball.queue_free()
	new_ball()
