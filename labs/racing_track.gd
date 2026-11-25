extends "res://scene_3d.gd"

# Shared world for the racing lessons: sky, curved track, barriers and scenery.
# The 3D models come from Kenney's Racing Kit (CC0). runner/build.sh downloads
# them into art/racing. For a local copy of the project, run art/racing/fetch.sh.
const ORANGE_CAR := preload("res://art/racing/raceCarOrange.glb")
const GREEN_CAR := preload("res://art/racing/raceCarGreen.glb")
const TREE_LARGE := preload("res://art/racing/treeLarge.glb")
const TREE_SMALL := preload("res://art/racing/treeSmall.glb")
const GANTRY := preload("res://art/racing/overheadLights.glb")
const BANNER_TOWER := preload("res://art/racing/bannerTowerRed.glb")
const LIGHT_POST := preload("res://art/racing/lightPostLarge.glb")
const TENT := preload("res://art/racing/tent.glb")
const FLAG := preload("res://art/racing/flagCheckers.glb")
const PYLON := preload("res://art/racing/pylon.glb")

# Points the centre line passes through, as (x, z), in racing order.
# A smooth Catmull-Rom curve joins them, so every corner is rounded.
const TRACK_SHAPE := [
	Vector2(-7.0, 1.6), Vector2(-7.0, -1.2), Vector2(-5.6, -3.7), Vector2(-3.2, -4.8),
	Vector2(0.0, -4.7), Vector2(3.2, -4.9), Vector2(5.7, -4.0), Vector2(7.1, -1.8),
	Vector2(6.8, 0.9), Vector2(5.4, 3.5), Vector2(3.3, 4.4), Vector2(0.4, 4.0),
	Vector2(-2.6, 4.8), Vector2(-5.0, 4.6), Vector2(-6.4, 3.4),
]
const SUBDIVISIONS := 24
const SAMPLE_STEP := 0.25
const ROAD_WIDTH := 2.5
const KERB_WIDTH := 0.3
const WALL_GAP := 0.4
const WALL_HEIGHT := 0.32
const KERB_CURVE := 0.22

var track_points := PackedVector3Array()
var track_length := 0.0

func build_world() -> void:
	add_sky_and_sun()
	build_track_path()
	add_ground()
	add_road()
	add_barriers()
	add_scenery()

func add_sky_and_sun() -> void:
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#2f6fc4")
	sky_material.sky_horizon_color = Color("#b9dcf5")
	sky_material.ground_horizon_color = Color("#b9dcf5")
	sky_material.ground_bottom_color = Color("#3f6b3a")
	var sky := Sky.new()
	sky.sky_material = sky_material
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	# The sky is only the background. Lighting the scene from the bright blue sky
	# washes everything out in the browser renderer, so use a soft, neutral
	# ambient colour and switch off sky reflections instead. Sun plus ambient
	# stays a little under full brightness on surfaces facing the sun, so the
	# grass, white kerbs and pale models do not glare.
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#d9e1e8")
	environment.ambient_light_energy = 0.3
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -35, 0)
	sun.light_color = Color("#fff4e0")
	sun.light_energy = 0.75
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 45.0
	add_child(sun)

func label(text: String) -> Label:
	var status: Label = super(text)
	status.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.75))
	status.add_theme_constant_override(&"outline_size", 6)
	return status

# --- Track shape ---------------------------------------------------------------

func catmull_rom(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2
		+ (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3)

func build_track_path() -> void:
	var dense: Array[Vector3] = []
	var count: int = TRACK_SHAPE.size()
	for i in count:
		var p0: Vector2 = TRACK_SHAPE[posmod(i - 1, count)]
		var p1: Vector2 = TRACK_SHAPE[i]
		var p2: Vector2 = TRACK_SHAPE[(i + 1) % count]
		var p3: Vector2 = TRACK_SHAPE[(i + 2) % count]
		for step in SUBDIVISIONS:
			var point: Vector2 = catmull_rom(p0, p1, p2, p3, float(step) / SUBDIVISIONS)
			dense.append(Vector3(point.x, 0.0, point.y))
	dense.append(dense[0])

	# Resample so the points are evenly spaced along the road.
	var pieces: Array[float] = []
	track_length = 0.0
	for i in dense.size() - 1:
		var piece: float = dense[i].distance_to(dense[i + 1])
		pieces.append(piece)
		track_length += piece
	var samples: int = maxi(8, roundi(track_length / SAMPLE_STEP))
	var spacing: float = track_length / samples
	var index := 0
	var walked := 0.0
	track_points.clear()
	for k in samples:
		var wanted: float = k * spacing
		while index < pieces.size() - 1 and walked + pieces[index] < wanted:
			walked += pieces[index]
			index += 1
		var weight: float = clampf((wanted - walked) / pieces[index], 0.0, 1.0)
		track_points.append(dense[index].lerp(dense[index + 1], weight))

func track_point(i: int) -> Vector3:
	return track_points[posmod(i, track_points.size())]

func track_forward(i: int) -> Vector3:
	return (track_point(i + 1) - track_point(i - 1)).normalized()

func track_right(i: int) -> Vector3:
	return track_forward(i).cross(Vector3.UP)

func track_index(lap_fraction: float) -> int:
	return roundi(fposmod(lap_fraction, 1.0) * track_points.size()) % track_points.size()

## A position on the road that faces the racing direction.
## lap_fraction 0.0 is the finish line and 0.5 is halfway round.
## sideways moves right (positive) or left (negative) of the centre line.
func track_frame(lap_fraction: float, sideways := 0.0) -> Transform3D:
	var i := track_index(lap_fraction)
	var at: Vector3 = track_point(i) + track_right(i) * sideways
	return Transform3D(Basis.looking_at(track_forward(i), Vector3.UP), at)

## Starting positions just behind the finish line, side by side.
func grid_slot(slot: int) -> Transform3D:
	var sideways := -0.6 if slot == 0 else 0.6
	return track_frame(-1.4 / track_length, sideways)

func heading(forward: Vector3) -> float:
	return atan2(-forward.x, -forward.z)

func corner_strength() -> Array[float]:
	var raw: Array[float] = []
	var count := track_points.size()
	for i in count:
		var turn: float = track_forward(i - 1).signed_angle_to(track_forward(i + 1), Vector3.UP)
		raw.append(absf(turn) / (2.0 * SAMPLE_STEP))
	var smooth: Array[float] = []
	for i in count:
		var total := 0.0
		for offset in range(-2, 3):
			total += raw[posmod(i + offset, count)]
		smooth.append(total / 5.0)
	return smooth

# --- Ground, road, kerbs and barriers ----------------------------------------------

func add_ground() -> void:
	var grass := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(90, 90)
	grass.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#5d9e4f")
	material.roughness = 1.0
	grass.material_override = material
	add_child(grass)

func add_road() -> void:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := ROAD_WIDTH / 2.0
	var corners := corner_strength()
	var red := Color("#d8433b")
	var white := Color("#f2f2f2")
	for i in track_points.size():
		road_strip(tool, i, -half, half, 0.02, Color("#4b4f58"))
		road_strip(tool, i, -half + 0.06, -half + 0.12, 0.025, white)
		road_strip(tool, i, half - 0.12, half - 0.06, 0.025, white)
		if corners[i] > KERB_CURVE:
			var stripe: Color = red if posmod(i, 4) < 2 else white
			road_strip(tool, i, -half - KERB_WIDTH, -half, 0.035, stripe)
			road_strip(tool, i, half, half + KERB_WIDTH, 0.035, stripe)
	add_finish_line(tool)

	var road := MeshInstance3D.new()
	road.mesh = tool.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	road.material_override = material
	add_child(road)

func road_strip(tool: SurfaceTool, i: int, from: float, to: float, height: float, color: Color) -> void:
	var lift := Vector3(0, height, 0)
	var a := track_point(i)
	var b := track_point(i + 1)
	var right_a := track_right(i)
	var right_b := track_right(i + 1)
	add_quad(tool, [a + right_a * from + lift, a + right_a * to + lift,
		b + right_b * to + lift, b + right_b * from + lift], color)

## Corners go left-back, right-back, right-front, left-front, seen from above.
func add_quad(tool: SurfaceTool, corners: Array, color: Color) -> void:
	for index in [0, 2, 1, 0, 3, 2]:
		tool.set_color(color)
		tool.set_normal(Vector3.UP)
		tool.add_vertex(corners[index])

func add_finish_line(tool: SurfaceTool) -> void:
	var start := track_point(0)
	var forward := track_forward(0)
	var right := track_right(0)
	var columns := 10
	var square: float = ROAD_WIDTH / columns
	for row in 2:
		for column in columns:
			var color: Color = Color("#f7f7f7") if (row + column) % 2 == 0 else Color("#1d1d22")
			var side: float = -ROAD_WIDTH / 2.0 + column * square
			var along: float = (row - 1) * square
			var origin: Vector3 = start + right * side + forward * along + Vector3(0, 0.03, 0)
			add_quad(tool, [origin, origin + right * square,
				origin + right * square + forward * square, origin + forward * square], color)

func add_barriers() -> void:
	var offset := ROAD_WIDTH / 2.0 + KERB_WIDTH + WALL_GAP
	var walls := StaticBody3D.new()
	add_child(walls)
	var placements: Array[Transform3D] = []
	var count := track_points.size()
	for side: float in [-1.0, 1.0]:
		for i in range(0, count, 2):
			var a: Vector3 = track_point(i) + track_right(i) * side * offset
			var b: Vector3 = track_point(i + 2) + track_right(i + 2) * side * offset
			var along: Vector3 = b - a
			# Inside a tight bend the offset line can fold back. Skip those pieces.
			if along.dot(track_forward(i + 1)) <= 0.01:
				continue
			var centre: Vector3 = (a + b) / 2.0 + Vector3(0, WALL_HEIGHT / 2.0, 0)
			var facing := Basis.looking_at(along.normalized(), Vector3.UP)
			var size := Vector3(0.2, WALL_HEIGHT, along.length() + 0.08)
			var shape := BoxShape3D.new()
			shape.size = size
			var collision := CollisionShape3D.new()
			collision.shape = shape
			collision.transform = Transform3D(facing, centre)
			walls.add_child(collision)
			placements.append(Transform3D(facing * Basis.from_scale(size), centre))

	var blocks := MultiMesh.new()
	blocks.transform_format = MultiMesh.TRANSFORM_3D
	blocks.use_colors = true
	blocks.mesh = BoxMesh.new()
	blocks.instance_count = placements.size()
	for i in placements.size():
		blocks.set_instance_transform(i, placements[i])
		blocks.set_instance_color(i, Color("#d8433b") if i % 2 == 0 else Color("#f2f2f2"))
	var art := MultiMeshInstance3D.new()
	art.multimesh = blocks
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	art.material_override = material
	add_child(art)

# --- Imported models -------------------------------------------------------------

## Instance an imported model, stand it on the ground with its footprint centred
## on `at`, turn it by `yaw` radians and add it to `parent`.
func add_model(parent: Node3D, scene: PackedScene, at := Vector3.ZERO, yaw := 0.0, size := 1.0) -> Node3D:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = yaw
	holder.scale = Vector3.ONE * size
	var model := scene.instantiate() as Node3D
	var bounds := model_bounds(model)
	var centre := bounds.get_center()
	model.position = Vector3(-centre.x, -bounds.position.y, -centre.z)
	holder.add_child(model)
	parent.add_child(holder)
	return holder

func model_bounds(model: Node3D) -> AABB:
	var bounds := AABB()
	var first := true
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		var to_model := Transform3D.IDENTITY
		var current: Node = mesh_instance
		while current != model:
			to_model = (current as Node3D).transform * to_model
			current = current.get_parent()
		var box: AABB = to_model * mesh_instance.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds

func add_scenery() -> void:
	var wall := ROAD_WIDTH / 2.0 + KERB_WIDTH + WALL_GAP
	var start := track_index(0.0)
	var across := heading(track_right(start))

	# Start gantry over the finish line, with chequered flags beside it.
	add_model(self, GANTRY, track_point(start), heading(track_forward(start)), (ROAD_WIDTH + 1.6) / 1.26)
	add_model(self, FLAG, track_frame(0.0, -wall - 0.6).origin, across, 1.6)
	add_model(self, FLAG, track_frame(0.03, -wall - 0.6).origin, across, 1.6)

	# Floodlights and sponsor towers round the outside of the circuit.
	for lap_fraction: float in [0.12, 0.37, 0.62, 0.87]:
		var facing_track := heading(-track_right(track_index(lap_fraction)))
		add_model(self, LIGHT_POST, track_frame(lap_fraction, -wall - 0.8).origin, facing_track, 2.2)
	for lap_fraction: float in [0.2, 0.45, 0.7, 0.95]:
		var facing_track := heading(-track_right(track_index(lap_fraction)))
		add_model(self, BANNER_TOWER, track_frame(lap_fraction, -wall - 1.5).origin, facing_track, 1.8)

	# Cones on the grass inside a few corners.
	for lap_fraction: float in [0.09, 0.27, 0.55, 0.78]:
		add_model(self, PYLON, track_frame(lap_fraction, wall - 0.2).origin, 0.0, 2.0)

	# A small paddock of tents in the infield beside the start.
	for i in 3:
		var spot: Vector3 = track_frame(-0.04 + i * 0.045, ROAD_WIDTH / 2.0 + 2.8).origin
		add_model(self, TENT, spot, across, 1.4)

	add_trees()

func add_trees() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 2026
	var clearance := ROAD_WIDTH / 2.0 + KERB_WIDTH + WALL_GAP + 1.0
	var paddock: Vector3 = track_point(0) + track_right(0) * 4.1
	var placed := 0
	var tries := 0
	while placed < 34 and tries < 600:
		tries += 1
		var spot := Vector3(random.randf_range(-12.5, 12.5), 0, random.randf_range(-9.5, 8.5))
		if distance_to_track(spot) < clearance or spot.distance_to(paddock) < 2.6:
			continue
		var model: PackedScene = TREE_LARGE if random.randf() < 0.55 else TREE_SMALL
		add_model(self, model, spot, random.randf_range(0.0, TAU), random.randf_range(1.4, 2.1))
		placed += 1

func distance_to_track(spot: Vector3) -> float:
	var nearest := INF
	for point: Vector3 in track_points:
		nearest = minf(nearest, point.distance_to(spot))
	return nearest
