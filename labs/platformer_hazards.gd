extends "res://platformer_coins.gd"

func _ready() -> void:
	super._ready()
	add_hazard(Vector2(526, 343), Vector2(46, 16))

func add_hazard(at: Vector2, size: Vector2) -> Area2D:
	var hazard := Area2D.new()
	hazard.position = at
	hazard.collision_layer = 0
	rectangle(hazard, Vector2.ZERO, size, Color("#ff8e9c"))
	add_box(hazard, size)
	hazard.body_entered.connect(on_hazard)
	add_child(hazard)
	return hazard

func on_hazard(body: Node2D) -> void:
	if body == player and not completed:
		respawn.call_deferred()
