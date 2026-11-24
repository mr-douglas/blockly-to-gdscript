extends "res://platform3d_cameras.gd"

var finished := false
var finish_label: Label

func build_level() -> void:
	block(Vector3(0, -0.25, 2.1), Vector3(5, 0.5, 5.2), Color("#386887"))
	block(Vector3(0, -0.25, -4.65), Vector3(5, 0.5, 5.3), Color("#538b98"))
	for x in [-1.8, 1.8]:
		block(Vector3(x, 0.6, -5.8), Vector3(0.24, 1.2, 0.24), Color("#75ffbe"))

func _ready() -> void:
	super._ready()
	var goal := Area3D.new()
	goal.position = Vector3(0, 0, -5.8)
	goal.collision_layer = 0
	var trigger := BoxShape3D.new()
	trigger.size = Vector3(2, 1.7, 1.05)
	add_shape(goal, trigger)
	var pad := BoxMesh.new()
	pad.size = Vector3(2, 0.06, 1.05)
	add_mesh(goal, pad, Color("#75ffbe"))
	goal.body_entered.connect(reach_goal)
	add_child(goal)
	finish_label = label("Jump the gap and reach the green pad")
	finish_label.position.y = 72

func reach_goal(body: Node3D) -> void:
	if body == player and not finished:
		finished = true
		finish_label.text = "Course complete! Press R to restart."
