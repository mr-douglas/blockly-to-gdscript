extends "res://physics_art_2d.gd"

const CRATE_SIZE := Vector2(70, 70)
var crate: RigidBody2D

func _ready() -> void:
	backdrop()
	ground()
	# A RigidBody2D is moved by the physics engine: gravity pulls it down and
	# it bounces, slides and tips over when it hits things.
	crate = RigidBody2D.new()
	crate.position = Vector2(384, 60)
	# Pick a random angle between 0 and a full turn (TAU radians = 360 degrees).
	crate.rotation = randf_range(0, TAU)
	add_box(crate, CRATE_SIZE)
	block_art(crate, CRATE_SIZE, "wood")
	add_child(crate)
	label_at(Vector2(18, 12), "Starting angle: %d degrees. Press R to drop it again." % rad_to_deg(crate.rotation))
