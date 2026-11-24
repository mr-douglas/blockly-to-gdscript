extends "res://racing_fixed.gd"

const PITCH_DEGREES := 50.0
const FRAME_MARGIN := 1.8
const MIN_DISTANCE := 7.0
const FOLLOW_SPEED := 4.0

func _ready() -> void:
	super._ready()
	race_camera.rotation = Vector3(-deg_to_rad(PITCH_DEGREES), 0, 0)
	race_camera.position = camera_target()

func _process(delta: float) -> void:
	# Glide towards the target instead of jumping, so the view feels smooth.
	var weight := 1.0 - exp(-FOLLOW_SPEED * delta)
	race_camera.position = race_camera.position.lerp(camera_target(), weight)

func camera_target() -> Vector3:
	var midpoint := (car_a.position + car_b.position) / 2.0
	var span := (car_a.position - car_b.position).abs()
	var pitch := deg_to_rad(PITCH_DEGREES)
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / maxf(1.0, viewport_size.y)

	# The tilted camera sees depth foreshortened by sin(pitch).
	var height_for_depth := span.z * sin(pitch) + 2.0 * FRAME_MARGIN
	var height_for_width := (span.x + 2.0 * FRAME_MARGIN) / maxf(0.01, aspect)
	var view_height := maxf(height_for_depth, height_for_width)

	# A perspective view is 2 * distance * tan(fov / 2) high at that distance.
	var distance := view_height / (2.0 * tan(deg_to_rad(race_camera.fov) / 2.0))
	distance = maxf(MIN_DISTANCE, distance)
	return midpoint + Vector3(0, sin(pitch), cos(pitch)) * distance
