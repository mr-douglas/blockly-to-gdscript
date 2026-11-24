extends "res://scene_2d.gd"

const SPEED := 205.0
const JUMP_SPEED := 440.0
const GRAVITY := 980.0
const START := Vector2(54, 342)
const GOAL := Vector2(708, 240)
var player := CharacterBody2D.new()
var status: Label
var won := false

func _ready() -> void:
	rectangle(self, Vector2(384, 216), Vector2(768, 432), Color("#232c55"))
	for x in range(32, 768, 46):
		rectangle(self, Vector2(x, 100 + (x * 11) % 220), Vector2(3, 3), Color("#58749a"))
	wall(Vector2(85, 378), Vector2(170, 32), Color("#538097"))
	wall(Vector2(241, 331), Vector2(85, 20), Color("#538097"))
	wall(Vector2(373, 283), Vector2(100, 20), Color("#538097"))
	wall(Vector2(513, 328), Vector2(110, 20), Color("#538097"))
	wall(Vector2(680, 269), Vector2(135, 20), Color("#658bc1"))
	rectangle(self, GOAL + Vector2(0, -8), Vector2(24, 38), Color("#65ebc9"))
	status = label_at(Vector2(18, 12), "Reach the far platform")
	player.position = START
	rectangle(player, Vector2.ZERO, Vector2(24, 29), Color("#f8ac76"))
	rectangle(player, Vector2(4, -5), Vector2(12, 7), Color("#613958"))
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
		status.text = "Platform reached! Press R to restart."
