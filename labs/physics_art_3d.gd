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

## Point a thin arrow from `from` along `direction`, `length` long.
func point_arrow(arrow: MeshInstance3D, from: Vector3, direction: Vector3, length: float) -> void:
	var mesh := arrow.mesh as BoxMesh
	mesh.size = Vector3(0.08, 0.08, length)
	arrow.global_transform = Transform3D(Basis.looking_at(direction, Vector3.UP),
		from + direction.normalized() * length / 2)

## A thin yellow arrow for aiming. Move it with point_arrow().
func make_arrow() -> MeshInstance3D:
	var arrow := MeshInstance3D.new()
	arrow.mesh = BoxMesh.new()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#ffd23f")
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arrow.material_override = material
	arrow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(arrow)
	return arrow
