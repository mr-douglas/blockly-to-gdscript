extends SceneTree

# Loads every playground and lesson, plays a few seconds of simulated input,
# and fails on missing objects. runner/build.sh runs it headless as a smoke
# test. .github/workflows/screenshots.yml runs it in a window with
#   -- --shots=<folder>
# to save a PNG of each scene, so changes to the art can be reviewed.
const SCENES := [
	"res://platformer_move.gd", "res://platformer_collision.gd", "res://platformer_gravity.gd",
	"res://platformer_jump.gd", "res://platformer_respawn.gd", "res://platformer_goal.gd",
	"res://platformer_coins.gd", "res://platformer_hazards.gd", "res://platformer_checkpoint.gd",
	"res://platformer_patrol.gd", "res://platformer_moving.gd", "res://platformer_coin_gate.gd",
	"res://platformer.gd", "res://top_down.gd", "res://art_sprite_2d.gd",
	"res://movement_3d.gd", "res://landing_pad_follow.gd", "res://physics_3d.gd",
	"res://platform3d_walk.gd", "res://platform3d_fall.gd", "res://platform3d_jump.gd",
	"res://platform3d_cameras.gd", "res://platform3d_goal.gd", "res://art_character_3d.gd",
	"res://racing_fixed.gd", "res://racing_shared_camera.gd", "res://racing_laps.gd",
	"res://ui_hud.gd", "res://ui_health.gd", "res://ui_game_over.gd",
	"res://ui_start_menu.gd", "res://ui_win_screen.gd",
	"res://art_sound_effects.gd", "res://art_music.gd",
	"res://physics_drop.gd", "res://physics_stack.gd", "res://physics_launch.gd",
	"res://physics_drop_3d.gd", "res://physics_launch_3d.gd",
]
const KEYS := [&"left", &"right", &"up", &"down", &"action", &"reset", &"view",
	&"p2_left", &"p2_right", &"p2_up", &"p2_down"]

var shots := ""
var failures := 0

func _initialize() -> void:
	for action: StringName in KEYS:
		InputMap.add_action(action)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shots="):
			shots = arg.trim_prefix("--shots=")
			DirAccess.make_dir_recursive_absolute(shots)
	run.call_deferred()

func run() -> void:
	for path: String in SCENES:
		await visit(path)
	if failures == 0:
		print("TOUR PASSED")
	quit(1 if failures > 0 else 0)

func visit(path: String) -> void:
	var script: GDScript = load(path)
	if script == null:
		fail("could not load " + path)
		return
	var scene: Node = script.new()
	root.add_child(scene)
	var label := path.get_file().get_basename()
	await wait(40)
	await shoot(label + "-1")
	# Lessons with a start menu wait, paused, until Play is pressed.
	if scene.has_method(&"start_game"):
		scene.call(&"start_game")
	var player = scene.get(&"player")
	var start: Vector3 = position_of(player)
	# Drive forward or right, with a jump part of the way through.
	for action in [&"right", &"up", &"p2_up"]:
		Input.action_press(action)
	for frame in 50:
		if frame == 20:
			Input.action_press(&"action")
		elif frame == 21:
			Input.action_release(&"action")
		await physics_frame
	if player is Node and position_of(player).distance_to(start) < 1.0:
		fail("the player did not move in " + path)
	await shoot(label + "-2")
	for action in [&"right", &"up", &"p2_up"]:
		Input.action_release(action)
	# Show the raised checkpoint flag in the lessons that have one.
	if scene.get(&"flag") is Area2D and player is Node2D:
		var lesson = scene
		player.position = lesson.CHECKPOINT
		await wait(60)
		await shoot(label + "-3")
	# Show the end screen in the interface lessons.
	if scene.has_method(&"win"):
		scene.call(&"win")
		await wait(5)
		await shoot(label + "-4")
	elif scene.has_method(&"out_of_health"):
		scene.call(&"out_of_health")
		await wait(5)
		await shoot(label + "-4")
	elif scene.has_method(&"throw_ball"):
		# Show where the thrown ball ends up in the physics lessons.
		await wait(90)
		await shoot(label + "-3")
	paused = false
	print("TOUR OK ", path)
	scene.queue_free()
	await process_frame

func position_of(node) -> Vector3:
	if node is Node2D:
		return Vector3(node.global_position.x, node.global_position.y, 0)
	if node is Node3D:
		return node.global_position
	return Vector3.ZERO

func wait(frames: int) -> void:
	for frame in frames:
		await physics_frame

func shoot(file: String) -> void:
	if shots.is_empty():
		return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		fail("no image for " + file)
		return
	image.save_png(shots.path_join(file + ".png"))

func fail(message: String) -> void:
	failures += 1
	printerr("TOUR FAIL ", message)
