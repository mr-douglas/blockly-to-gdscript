extends Node

const DEMOS := {
	"top-down": preload("res://top_down.gd"),
	"platformer": preload("res://platformer.gd"),
	"movement-3d": preload("res://movement_3d.gd"),
	"physics-3d": preload("res://physics_3d.gd"),
	"landing-pad-follow": preload("res://landing_pad_follow.gd"),
}

var demo: Node
var selected := "top-down"

func _ready() -> void:
	var keys := {&"left": KEY_LEFT, &"right": KEY_RIGHT, &"up": KEY_UP,
		&"down": KEY_DOWN, &"action": KEY_SPACE, &"reset": KEY_R}
	for key in keys:
		InputMap.add_action(key)
		var event := InputEventKey.new()
		event.physical_keycode = keys[key]
		InputMap.action_add_event(key, event)

	for arg in OS.get_cmdline_user_args():
		if DEMOS.has(arg):
			selected = arg
	_load_demo()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reset") and not event.is_echo():
		_load_demo()
	if not OS.has_feature("web") and event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < DEMOS.size():
			selected = DEMOS.keys()[index]
			_load_demo()

func _load_demo() -> void:
	if is_instance_valid(demo):
		remove_child(demo)
		demo.queue_free()
	demo = DEMOS[selected].new()
	add_child(demo)
