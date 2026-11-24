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
var edited_script: GDScript

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
	if OS.has_feature("web") and FileAccess.file_exists("/student.gd"):
		edited_script = GDScript.new()
		edited_script.source_code = FileAccess.get_file_as_string("/student.gd")
		if edited_script.reload() != OK:
			JavaScriptBridge.eval("reportPlaygroundReady(false)")
			return
		if not ClassDB.is_parent_class(edited_script.get_instance_base_type(), &"Node"):
			push_error("The playground script must extend a Node.")
			JavaScriptBridge.eval("reportPlaygroundReady(false)")
			return
	var loaded := _load_demo()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("reportPlaygroundReady(%s)" % ("true" if loaded else "false"))

func _unhandled_key_input(event: InputEvent) -> void:
	if is_instance_valid(demo) and event.is_action_pressed(&"reset") and not event.is_echo():
		_load_demo()
	if not OS.has_feature("web") and event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < DEMOS.size():
			selected = DEMOS.keys()[index]
			_load_demo()

func _load_demo() -> bool:
	if is_instance_valid(demo):
		remove_child(demo)
		demo.queue_free()
	var script: GDScript = edited_script if edited_script else DEMOS[selected]
	demo = script.new()
	if not is_instance_valid(demo):
		push_error("Could not create the playground from this script.")
		return false
	add_child(demo)
	return true
