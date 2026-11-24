extends "res://platform3d_jump.gd"

var first_person := false
var eyes: Camera3D
var chase: Camera3D
var view_label: Label

func _ready() -> void:
	super._ready()
	eyes = Camera3D.new()
	eyes.position = Vector3(0, 0.37, -0.24)
	eyes.near = 0.08
	player.add_child(eyes)

	var arm := SpringArm3D.new()
	arm.position = Vector3(0, 0.9, 0)
	arm.rotation.x = -0.35
	arm.spring_length = 4.6
	var probe := SphereShape3D.new()
	probe.radius = 0.16
	arm.shape = probe
	arm.add_excluded_object(player.get_rid())
	player.add_child(arm)
	chase = Camera3D.new()
	arm.add_child(chase)
	view_label = label("")
	view_label.position.y = 42
	set_first_person(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("view"):
		set_first_person(not first_person)

func set_first_person(enabled: bool) -> void:
	first_person = enabled
	player_art.visible = not first_person
	var camera := eyes if first_person else chase
	camera.make_current()
	view_label.text = "C · First person" if first_person else "C · Third person"
