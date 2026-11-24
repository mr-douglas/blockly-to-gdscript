extends Node

func _ready() -> void:
	var source := FileAccess.get_file_as_string("/student.gd")
	var checker := GDScriptErrorChecker.new()
	if checker.set_source(source) != OK:
		for i in range(checker.get_error_count()):
			printerr("Line %d: %s" % [checker.get_error_line(i), checker.get_error(i)])
		_finish(1)
		return
	var script := GDScript.new()
	script.source_code = source
	if script.reload() != OK:
		_finish(1)
		return
	if not ClassDB.is_parent_class(script.get_instance_base_type(), &"Node"):
		printerr("The script must extend Node or a Node subclass.")
		_finish(1)
		return
	var student: Node = script.new()
	if student == null:
		_finish(1)
		return
	add_child(student)
	_finish(0)

func _finish(code: int) -> void:
	JavaScriptBridge.eval("finishStudentRun(%d)" % code)
	get_tree().quit(code)
