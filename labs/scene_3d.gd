extends Node3D

func stage(camera_at: Vector3, target: Vector3, view_size: float) -> void:
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = view_size
	camera.position = camera_at
	add_child(camera)
	camera.look_at(target)
	camera.current = true

	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#132640")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c4e5ff")
	environment.ambient_light_energy = 0.7
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -32, 0)
	light.light_energy = 1.15
	add_child(light)

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
