extends "res://scene_3d.gd"

# Shared 3D art for the Landing Pad, Ramp and crates and the 3D platformer
# lessons. The models are from Kenney's Starter Kit 3D Platformer (CC0).
# art/platformer3d/fetch.sh downloads them, and runner/build.sh runs it when
# the website is built. The helpers below only draw things: each lesson still
# makes its own bodies and collision shapes, so the physics is unchanged.
const MODELS := "res://art/platformer3d/"
const SKY := Color("#9ed4f5")
# Kenney's character faces +z. Turn it round so it faces the body's forward (-z).
const MODEL_YAW := PI

func stage(camera_at: Vector3, target: Vector3, view_size: float) -> void:
	super.stage(camera_at, target, view_size)
	for child in get_children():
		if child is WorldEnvironment:
			child.environment.background_color = SKY

## A solid block drawn with a Kenney model stretched to the same size as its
## collision box. Try "platform-large", "brick" or "block-coin".
func solid(at: Vector3, size: Vector3, model_name := "platform-large") -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	var shape := BoxShape3D.new()
	shape.size = size
	add_shape(body, shape)
	fit(body, model_name, size)
	add_child(body)
	return body

## Place a model at its own size, standing on `at`.
func prop(parent: Node, model_name: String, at: Vector3) -> Node3D:
	var art: Node3D = load(MODELS + model_name + ".glb").instantiate()
	art.position = at
	parent.add_child(art)
	return art

## Add a model to `parent`, stretched so it exactly fills a box of `size`
## centred on the parent.
func fit(parent: Node, model_name: String, size: Vector3) -> Node3D:
	var art: Node3D = load(MODELS + model_name + ".glb").instantiate()
	var box := bounds(art)
	art.scale = size / box.size
	art.position = -(box.position + box.size / 2) * art.scale
	parent.add_child(art)
	return art

## The box around every mesh in a model, measured from the model's origin.
func bounds(root: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		var to_root := Transform3D.IDENTITY
		var step: Node = mesh_node
		while step != root:
			to_root = (step as Node3D).transform * to_root
			step = step.get_parent()
		var part: AABB = to_root * mesh_node.get_aabb()
		box = part if first else box.merge(part)
		first = false
	return box

## Give a body Kenney's animated character, `height` tall and centred on the
## body. It plays idle, walk or jump by itself. With `face_motion` it also
## turns to face the way the body is moving.
func character(parent: Node3D, body: CharacterBody3D, height: float, face_motion := false) -> Node3D:
	var art: Node3D = load(MODELS + "character.glb").instantiate()
	var box := bounds(art)
	var scale_factor := height / box.size.y
	art.scale = Vector3.ONE * scale_factor
	art.position = Vector3(0, -height / 2 - box.position.y * scale_factor, 0)
	art.rotation.y = MODEL_YAW
	parent.add_child(art)
	var animations: AnimationPlayer = art.find_children("*", "AnimationPlayer", true, false)[0]
	for clip in [&"idle", &"walk"]:
		animations.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	animations.play(&"idle")
	get_tree().physics_frame.connect(animate_character.bind(body, art, animations, face_motion))
	return art

func animate_character(body: CharacterBody3D, art: Node3D, animations: AnimationPlayer,
		face_motion: bool) -> void:
	if not is_instance_valid(body):
		return
	var ground_speed := Vector2(body.velocity.x, body.velocity.z).length()
	var clip := &"idle"
	if absf(body.velocity.y) > 0.5 and not body.is_on_floor():
		clip = &"jump"
	elif ground_speed > 0.2:
		clip = &"walk"
	if animations.current_animation != clip:
		animations.play(clip, 0.15)
	if face_motion and ground_speed > 0.2:
		art.global_rotation.y = atan2(body.velocity.x, body.velocity.z)
