extends "res://kenney_art_3d.gd"

# Shared art for the 3D physics lessons. The crates, grass block, trees and
# flowers are from Platformer Kit by Kenney (CC0). art/physics3d/fetch.sh
# downloads them, and runner/build.sh runs it when the website is built.
# The helpers below only draw things: each lesson makes its own bodies and
# collision shapes.
const KIT := "res://art/physics3d/"

## A grassy island whose top is at y = 0, with trees and flowers round the edge.
func island(size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = Vector3(0, -size.y / 2, 0)
	var shape := BoxShape3D.new()
	shape.size = size
	add_shape(body, shape)
	kit_model(body, "block-grass-large", size)
	add_child(body)
	var half := Vector3(size.x / 2, 0, size.z / 2)
	decorate("tree", Vector3(-half.x + 0.6, 0, -half.z + 0.6), 1.6)
	decorate("tree", Vector3(half.x - 0.7, 0, -half.z + 0.5), 1.3)
	decorate("flowers", Vector3(-half.x + 1.4, 0, half.z - 0.5), 0.35)
	decorate("flowers", Vector3(half.x - 1.2, 0, half.z - 0.6), 0.35)
	return body

## For first-person views: a sky, a solid grass field at y = 0 out to the
## horizon, flowers nearby and trees in the distance. Call it after stage().
func outdoors() -> void:
	for child in get_children():
		if child is WorldEnvironment:
			var sky_material := ProceduralSkyMaterial.new()
			sky_material.sky_top_color = Color("#3d7fd1")
			sky_material.sky_horizon_color = Color("#cfe8f7")
			sky_material.ground_horizon_color = Color("#cfe8f7")
			sky_material.ground_bottom_color = Color("#4f8f4a")
			var sky := Sky.new()
			sky.sky_material = sky_material
			# The sky is only the background: the lights still come from stage().
			child.environment.background_mode = Environment.BG_SKY
			child.environment.sky = sky
		elif child is DirectionalLight3D:
			# Do not draw a sun disc in the sky for the sun and fill lights.
			child.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
	var field := StaticBody3D.new()
	add_shape(field, WorldBoundaryShape3D.new())
	var plane := PlaneMesh.new()
	plane.size = Vector2(300, 300)
	add_mesh(field, plane, Color("#5fbf6f"))
	add_child(field)
	var random := RandomNumberGenerator.new()
	random.seed = 7
	var placed := 0
	while placed < 40:
		var spot := Vector3(random.randf_range(-20.0, 45.0), 0, random.randf_range(-30.0, 30.0))
		if absf(spot.x) < 8.0 and absf(spot.z) < 5.0:
			continue
		decorate("tree", spot, random.randf_range(1.2, 2.6))
		placed += 1
	for spot: Vector3 in [Vector3(1.0, 0, -2.6), Vector3(5.5, 0, 2.2), Vector3(-0.5, 0, 2.8), Vector3(6.5, 0, -3.0)]:
		decorate("flowers", spot, 0.35)

## Draw a Kenney crate on `body`, stretched to `size`.
func crate_art(body: Node3D, size: Vector3, strong := false) -> Node3D:
	return kit_model(body, "crate-strong" if strong else "crate", size)

## Add a Platformer Kit model to `parent`, stretched to fill a box of `size`
## centred on the parent.
func kit_model(parent: Node, model_name: String, size: Vector3) -> Node3D:
	var art: Node3D = load(KIT + model_name + ".glb").instantiate()
	var box := bounds(art)
	art.scale = size / box.size
	art.position = -(box.position + box.size / 2) * art.scale
	parent.add_child(art)
	return art

## Stand a model `height` tall on the ground at `at`. It has no collision.
func decorate(model_name: String, at: Vector3, height: float) -> Node3D:
	var art: Node3D = load(KIT + model_name + ".glb").instantiate()
	var box := bounds(art)
	var factor := height / box.size.y
	art.scale = Vector3.ONE * factor
	art.position = at - Vector3(box.get_center().x, box.position.y, box.get_center().z) * factor
	add_child(art)
	return art
