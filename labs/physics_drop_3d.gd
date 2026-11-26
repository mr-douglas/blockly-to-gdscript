extends "res://physics_art_3d.gd"

var crate: RigidBody3D

func _ready() -> void:
	stage(Vector3(6, 6, 10), Vector3(0, 1.4, 0), 8.0)
	island(Vector3(8, 1, 6))
	# A RigidBody3D is moved by the physics engine, just like RigidBody2D.
	crate = RigidBody3D.new()
	crate.position = Vector3(0, 4.5, 0)
	# In 3D there are three angles: around the x, y and z axes.
	crate.rotation = Vector3(randf_range(0, TAU), randf_range(0, TAU), randf_range(0, TAU))
	var shape := BoxShape3D.new()
	shape.size = Vector3(1, 1, 1)
	add_shape(crate, shape)
	crate_art(crate, shape.size)
	add_child(crate)
	label("Press R to drop the crate again")
