extends "res://platformer_respawn.gd"

var completed := false
var status: Label

func _ready() -> void:
	super._ready()
	status = label_at(Vector2(18, 12), "Jump the gap and reach the trophy")
	var goal := Area2D.new()
	goal.position = Vector2(654, 325)
	goal.collision_layer = 0
	strip(goal, TROPHY, 64).position.y = -6
	add_box(goal, Vector2(36, 52))
	goal.body_entered.connect(_on_goal_entered)
	add_child(goal)

func _on_goal_entered(body: Node2D) -> void:
	if body != player or completed:
		return
	completed = true
	status.text = "Level complete! Press R to play again."
