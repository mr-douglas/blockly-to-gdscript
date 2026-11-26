extends "res://racing_laps.gd"

# The finished two-player racer, with the same track, cameras and laps. Only
# drive() changes: instead of setting the speed directly, it adds up forces,
# uses them to change the velocity, and keeps that velocity from one frame to
# the next. That gives the cars acceleration, momentum and sliding.
const MASS := 800.0           # kg
const ENGINE_FORCE := 4000.0  # newtons pushing the car forward
const BRAKE_FORCE := 8000.0   # newtons slowing the car when you press back
const REVERSE_FORCE := 2000.0 # newtons pushing the car backwards once stopped
const DRAG := 60.0            # air resistance: force = DRAG * speed * speed
const ROLLING := 80.0         # tyre rolling resistance: force = ROLLING * speed
const GRIP := 10.0            # how quickly the tyres stop a sideways slide
const WHEELBASE := 0.8        # metres from the front wheels to the back wheels
const REAR_AXLE := 0.46       # metres from the middle of the car to the back wheels
const MAX_STEER := 35.0       # degrees the front wheels can turn when stopped
const STEER_SPEED := 150.0    # degrees per second the front wheels turn
const WHEEL_RADIUS := 0.14    # metres
const WALL_BOUNCE := 0.35     # 0 = thud into the wall, 1 = perfect bounce
const CAR_BOUNCE := 0.6       # how bouncy car-to-car bumps are
var speedometer: Label

func _ready() -> void:
	super._ready()
	speedometer = label("")
	speedometer.position.y = 76
	for car in [car_a, car_b]:
		car.set_meta("steer", 0.0)  # front wheel angle in degrees
		car.set_meta("roll", 0.0)   # how far the wheels have rolled, in radians

func drive(car: CharacterBody3D, turn: float, throttle: float, delta: float) -> void:
	var forward := -car.transform.basis.z
	var forward_speed := car.velocity.dot(forward)

	# 1. Turn the front wheels towards where the player is steering. Like a
	#    real car, the wheels turn less at high speed, so it does not spin out.
	var lock := MAX_STEER / (1.0 + absf(forward_speed) / 5.0)
	var steer: float = move_toward(car.get_meta("steer"), turn * lock, STEER_SPEED * delta)
	car.set_meta("steer", steer)

	# 2. The front wheels pull the car round a circle while the back wheels
	#    follow them. Turning rate = speed * tan(wheel angle) / wheelbase.
	#    Turn around the back wheels, so the back of the car does not swing out.
	#    A stopped car cannot turn, and reversing turns the other way.
	var turn_rate := forward_speed * tan(deg_to_rad(steer)) / WHEELBASE
	var rear_wheels := car.position + car.transform.basis.z * REAR_AXLE
	car.rotate_y(turn_rate * delta)
	car.position = rear_wheels - car.transform.basis.z * REAR_AXLE
	forward = -car.transform.basis.z
	forward_speed = car.velocity.dot(forward)

	# 3. Add up every force on the car.
	var force := Vector3.ZERO
	if throttle > 0:
		force += forward * ENGINE_FORCE * throttle
	elif throttle < 0 and forward_speed > 0.5:
		force += forward * BRAKE_FORCE * throttle
	elif throttle < 0:
		force += forward * REVERSE_FORCE * throttle
	var speed := car.velocity.length()
	force -= car.velocity * (DRAG * speed + ROLLING)

	# 4. Newton's second law: acceleration = force / mass. The velocity is
	#    kept between frames, so the car carries its momentum.
	var acceleration := force / MASS
	car.velocity += acceleration * delta

	# 5. Tyre grip. Remove part of the sideways slide each frame. Low grip
	#    lets the car drift wide on corners.
	var right := car.transform.basis.x
	var slide := car.velocity.dot(right)
	car.velocity -= right * slide * minf(1.0, GRIP * delta)

	# 6. Move, then react to anything we hit.
	var before := car.velocity
	car.move_and_slide()
	for i in car.get_slide_collision_count():
		var hit := car.get_slide_collision(i)
		var normal := hit.get_normal()
		normal.y = 0
		normal = normal.normalized()
		if hit.get_collider() is CharacterBody3D:
			bump(car, hit.get_collider(), normal, before)
		else:
			bounce_off_wall(car, normal, before)
	turn_wheels(car, forward_speed, delta)

# Show the steering angle on the front wheels, and roll all four wheels
# along the road. A wheel rolls through (distance / radius) radians.
func turn_wheels(car: CharacterBody3D, forward_speed: float, delta: float) -> void:
	var roll: float = car.get_meta("roll") + forward_speed * delta / WHEEL_RADIUS
	car.set_meta("roll", wrapf(roll, 0.0, TAU))
	var steer := deg_to_rad(car.get_meta("steer"))
	for wheel_name in ["wheelFrontLeft", "wheelFrontRight"]:
		var wheel: Node3D = car.find_child(wheel_name, true, false)
		wheel.rotation = Vector3(roll, steer, 0)
	for wheel_name in ["wheelBackLeft", "wheelBackRight"]:
		var wheel: Node3D = car.find_child(wheel_name, true, false)
		wheel.rotation = Vector3(roll, 0, 0)

# Reverse the part of the velocity going into the wall, and shrink it.
func bounce_off_wall(car: CharacterBody3D, normal: Vector3, before: Vector3) -> void:
	var into_wall := before.dot(normal)
	if into_wall < 0:
		car.velocity = before - normal * into_wall * (1.0 + WALL_BOUNCE)

# Both cars have the same mass. Push them apart along the line between them
# with equal and opposite impulses, so their total momentum stays the same.
func bump(car: CharacterBody3D, other: CharacterBody3D, normal: Vector3, before: Vector3) -> void:
	var closing := (before - other.velocity).dot(normal)
	if closing < 0:
		var change := normal * closing * (1.0 + CAR_BOUNCE) / 2.0
		car.velocity = before - change
		other.velocity += change

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	speedometer.text = "Speed · Orange %.1f m/s    Green %.1f m/s" % [car_a.velocity.length(), car_b.velocity.length()]
