extends "res://scene_2d.gd"

const SPEED := 180.0
const START := Vector2(92, 337)
var player := CharacterBody2D.new()

func _ready() -> void:
	rectangle(self, Vector2(384, 216), Vector2(768, 432), Color("#232c55"))
	build_level()
	player.position = START
	rectangle(player, Vector2.ZERO, Vector2(24, 28), Color("#ffbc79"))
	rectangle(player, Vector2(4, -5), Vector2(10, 6), Color("#62395a"))
	add_player_shape()
	add_child(player)

func build_level() -> void:
	rectangle(self, Vector2(384, 371), Vector2(768, 40), Color("#538097"))

func add_player_shape() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	player.position.x += direction * SPEED * delta
