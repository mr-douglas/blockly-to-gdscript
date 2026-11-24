extends "res://pixel_art_2d.gd"

const SPEED := 180.0
const START := Vector2(92, 337)
var player := CharacterBody2D.new()

func _ready() -> void:
	backdrop()
	build_level()
	player.position = START
	frog(player)
	add_player_shape()
	add_child(player)

func build_level() -> void:
	terrain(self, Vector2(384, 371), Vector2(768, 40))

func add_player_shape() -> void:
	pass

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	player.position.x += direction * SPEED * delta
