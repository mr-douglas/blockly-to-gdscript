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
const GRIP := 6.0             # how quickly the tyres stop a sideways slide
const STEERING := 2.6         # how fast the car turns at full lock
const WALL_BOUNCE := 0.35     # 0 = thud into the wall, 1 = perfect bounce
const CAR_BOUNCE := 0.6       # how bouncy car-to-car bumps are
var speedometer: Label

func _ready() -> void:
	super._ready()
	speedometer = label("")
	speedometer.position.y = 76

func drive(car: CharacterBody3D, turn: float, throttle: float, delta: float) -> void:
	var forward := -car.transform.basis.z
	var forward_speed := car.velocity.dot(forward)

	# 1. Steering. A car turns by rolling its wheels, so it cannot turn when
	#    it is stopped, and it steers the other way when reversing.
	var steer := clampf(forward_speed / 3.0, -1.0, 1.0)
	car.rotate_y(turn * STEERING * steer * delta)
	forward = -car.transform.basis.z
	forward_speed = car.velocity.dot(forward)

	# 2. Add up every force on the car.
	var force := Vector3.ZERO
	if throttle > 0:
		force += forward * ENGINE_FORCE * throttle
	elif throttle < 0 and forward_speed > 0.5:
		force += forward * BRAKE_FORCE * throttle
	elif throttle < 0:
		force += forward * REVERSE_FORCE * throttle
	var speed := car.velocity.length()
	force -= car.velocity * (DRAG * speed + ROLLING)

	# 3. Newton's second law: acceleration = force / mass. The velocity is
	#    kept between frames, so the car carries its momentum.
	var acceleration := force / MASS
	car.velocity += acceleration * delta

	# 4. Tyre grip. Remove part of the sideways slide each frame. Low grip
	#    lets the car drift wide on corners.
	var right := car.transform.basis.x
	var slide := car.velocity.dot(right)
	car.velocity -= right * slide * minf(1.0, GRIP * delta)

	# 5. Move, then react to anything we hit.
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
