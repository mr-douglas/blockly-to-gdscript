extends SceneTree

# Headless smoke test for the racing lessons, run by runner/build.sh.
# Each lesson must load, build its track, and let both cars drive forward.
const LESSONS := ["res://racing_fixed.gd", "res://racing_shared_camera.gd", "res://racing_laps.gd"]
const KEYS := [&"left", &"right", &"up", &"down", &"action", &"reset", &"view",
	&"p2_left", &"p2_right", &"p2_up", &"p2_down"]

func _initialize() -> void:
	for action: StringName in KEYS:
		InputMap.add_action(action)
	run.call_deferred()

func run() -> void:
	var failures := 0
	for path: String in LESSONS:
		var script: GDScript = load(path)
		if script == null:
			printerr("SMOKE FAIL could not load ", path)
			failures += 1
			continue
		var lesson = script.new()
		root.add_child(lesson)
		await physics_frame
		var start_a: Vector3 = lesson.car_a.global_position
		var start_b: Vector3 = lesson.car_b.global_position
		Input.action_press(&"up")
		Input.action_press(&"p2_up")
		for frame in 45:
			await physics_frame
		Input.action_release(&"up")
		Input.action_release(&"p2_up")
		var moved_a: float = lesson.car_a.global_position.distance_to(start_a)
		var moved_b: float = lesson.car_b.global_position.distance_to(start_b)
		if moved_a < 1.0 or moved_b < 1.0:
			printerr("SMOKE FAIL cars did not drive in %s (%.2f, %.2f)" % [path, moved_a, moved_b])
			failures += 1
		else:
			print("SMOKE OK %s · track %.1f m · cars moved %.2f and %.2f" % [path, lesson.track_length, moved_a, moved_b])
		lesson.queue_free()
		await process_frame
	if failures == 0:
		print("SMOKE PASSED")
	quit(1 if failures > 0 else 0)
