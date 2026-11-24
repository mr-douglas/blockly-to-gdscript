extends "res://pixel_art_2d.gd"

const SPEED := 205.0
const JUMP_SPEED := 440.0
const GRAVITY := 980.0
const START := Vector2(54, 342)
const GOAL := Vector2(708, 240)
var player := CharacterBody2D.new()
var status: Label
var won := false

func _ready() -> void:
	backdrop()
	block(Vector2(85, 378), Vector2(170, 32))
	block(Vector2(241, 331), Vector2(85, 20))
	block(Vector2(373, 283), Vector2(100, 20))
	block(Vector2(513, 328), Vector2(110, 20))
	block(Vector2(680, 269), Vector2(135, 20))
	strip(self, TROPHY, 64).position = GOAL + Vector2(0, -13)
	status = label_at(Vector2(18, 12), "Reach the trophy on the far platform")
	player.position = START
	frog(player)
	add_box(player, Vector2(24, 29))
	add_child(player)

func _physics_process(delta: float) -> void:
	player.velocity.x = Input.get_axis("left", "right") * SPEED
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("action") and player.is_on_floor():
		player.velocity.y = -JUMP_SPEED
	player.move_and_slide()

	if player.position.y > 475 or player.position.x < -30 or player.position.x > 798:
		player.position = START
		player.velocity = Vector2.ZERO
	if not won and player.position.distance_to(GOAL) < 30:
		won = true
		status.text = "Trophy reached! Press R to restart."
