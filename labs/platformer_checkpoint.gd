extends "res://platformer_hazards.gd"

const CHECKPOINT := Vector2(423, 337)
var spawn_point := START
var flag: Area2D

func _ready() -> void:
	super._ready()
	flag = Area2D.new()
	flag.position = CHECKPOINT
	flag.collision_layer = 0
	rectangle(flag, Vector2(0, -16), Vector2(4, 55), Color("#cce0ff"))
	rectangle(flag, Vector2(12, -35), Vector2(22, 16), Color("#70cbff"))
	add_box(flag, Vector2(33, 36))
	flag.body_entered.connect(activate_checkpoint)
	add_child(flag)

func activate_checkpoint(body: Node2D) -> void:
	if body == player and spawn_point != CHECKPOINT:
		spawn_point = CHECKPOINT
		flag.modulate = Color("#a3ffb1")
		status.text = "Checkpoint active"

func respawn() -> void:
	player.position = spawn_point
	player.velocity = Vector2.ZERO
