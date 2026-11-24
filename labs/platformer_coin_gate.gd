extends "res://platformer_moving.gd"

const REQUIRED_COINS := 3

func _ready() -> void:
	super._ready()
	status.text = "Collect %d coins to unlock the exit" % REQUIRED_COINS

func _on_goal_entered(body: Node2D) -> void:
	if body != player or completed:
		return
	if coins < REQUIRED_COINS:
		status.text = "Locked. Find %d more." % (REQUIRED_COINS - coins)
		return
	super._on_goal_entered(body)
