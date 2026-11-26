extends Node3D

# Shared set-up for the 3D lessons. Students never see this file: their lesson
# scripts just call stage(). The lighting here is a small "three point" rig:
# a warm sun that casts soft shadows, a weak cool fill light from the other
# side so shadowed faces are not black, and a gentle sky-blue ambient. Filmic
# tonemapping keeps bright colours from clipping to flat white in the browser.
const SUN_COLOR := Color("#fff0d6")
const FILL_COLOR := Color("#bcd6ff")
const AMBIENT_COLOR := Color("#b4cde6")

func stage(camera_at: Vector3, target: Vector3, view_size: float) -> void:
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = view_size
	camera.position = camera_at
	add_child(camera)
	camera.look_at(target)
	camera.current = true

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#132640")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = AMBIENT_COLOR
	environment.ambient_light_energy = 0.36
	finish_environment(environment)
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	# The sun shines from the front-left, so shadows fall to the right of
	# things where the camera can see them. Keeping the reach tight keeps the
	# shadow map sharp. A larger depth bias stops striped "shadow acne" on the
	# big flat floors seen by the orthographic camera.
	var reach: float = camera_at.distance_to(target) + view_size
	var sun := add_sun(Vector3(-50, -68, 0), 1.3, maxf(reach, 12.0))
	sun.shadow_bias = 0.25
	sun.shadow_normal_bias = 1.5
	add_fill(Vector3(-30, 125, 0), 0.2)

## Settings shared by every 3D scene: tonemapping and no sky reflections
## (which wash the browser renderer out).
func finish_environment(environment: Environment) -> void:
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.05
	environment.tonemap_white = 5.0

## The key light. It casts soft shadows.
func add_sun(angles: Vector3, energy: float, shadow_reach: float) -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = angles
	sun.light_color = SUN_COLOR
	sun.light_energy = energy
	sun.shadow_enabled = true
	sun.shadow_blur = 0.8
	sun.shadow_bias = 0.15
	sun.shadow_normal_bias = 1.6
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_split_1 = 0.35
	sun.directional_shadow_blend_splits = true
	sun.directional_shadow_max_distance = shadow_reach
	add_child(sun)
	return sun

## A weak, cool light from the opposite side. It does not cast shadows.
func add_fill(angles: Vector3, energy: float) -> DirectionalLight3D:
	var fill := DirectionalLight3D.new()
	fill.name = "Fill"
	fill.rotation_degrees = angles
	fill.light_color = FILL_COLOR
	fill.light_energy = energy
	fill.light_specular = 0.0
	add_child(fill)
	return fill

func box(body: CollisionObject3D, size: Vector3, color: Color) -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	add_shape(body, shape)
	var mesh := BoxMesh.new()
	mesh.size = size
	add_mesh(body, mesh, color)

func block(at: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	box(body, size, color)
	add_child(body)
	return body

func add_shape(body: CollisionObject3D, shape: Shape3D) -> void:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

func add_mesh(parent: Node3D, mesh: Mesh, color: Color) -> void:
	var art := MeshInstance3D.new()
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	art.material_override = material
	art.mesh = mesh
	parent.add_child(art)

func label(text: String) -> Label:
	var layer := CanvasLayer.new()
	add_child(layer)
	var status := Label.new()
	status.position = Vector2(18, 12)
	status.add_theme_font_size_override(&"font_size", 20)
	status.text = text
	layer.add_child(status)
	return status
