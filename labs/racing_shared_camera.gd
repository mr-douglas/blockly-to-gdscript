extends "res://racing_fixed.gd"

const FRAME_MARGIN := 1.65
const MIN_VIEW := 5.4

func _ready() -> void:
	super._ready()
	race_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	frame_both_cars()

func _process(_delta: float) -> void:
	frame_both_cars()

func frame_both_cars() -> void:
	var midpoint := (car_a.position + car_b.position) / 2.0
	race_camera.position.x = midpoint.x
	race_camera.position.z = midpoint.z

	var span := (car_a.position - car_b.position).abs()
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect := viewport_size.x / maxf(1.0, viewport_size.y)
	var height_for_depth := span.z + 2.0 * FRAME_MARGIN
	var height_for_width := (span.x + 2.0 * FRAME_MARGIN) / maxf(0.01, aspect)
	race_camera.size = maxf(MIN_VIEW, maxf(height_for_depth, height_for_width))
