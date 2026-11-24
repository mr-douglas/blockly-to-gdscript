extends "res://pixel_art_2d.gd"

const JUMP_SOUND := preload("res://art/audio/jump.ogg")
const COIN_SOUND := preload("res://art/audio/coin.ogg")
const LAND_SOUND := preload("res://art/audio/land.ogg")
const SPEED := 180.0
const JUMP_SPEED := 420.0
const GRAVITY := 980.0
const PITCH_VARIATION := 0.1

var player := CharacterBody2D.new()
var jump_sound: AudioStreamPlayer
var coin_sound: AudioStreamPlayer
var land_sound: AudioStreamPlayer
var was_on_floor := true
var coins := 0
var status: Label

func _ready() -> void:
	backdrop()
	block(Vector2(384, 371), Vector2(768, 40))
	block(Vector2(13, 249), Vector2(26, 204))
	block(Vector2(755, 249), Vector2(26, 204))
	for spot in [Vector2(220, 270), Vector2(384, 250), Vector2(548, 270)]:
		add_coin(spot)
	jump_sound = add_sound(JUMP_SOUND)
	coin_sound = add_sound(COIN_SOUND)
	land_sound = add_sound(LAND_SOUND)
	player.position = Vector2(384, 337)
	frog(player)
	add_box(player, Vector2(24, 28))
	add_child(player)
	status = label_at(Vector2(18, 12), "Run, jump and collect coins. Coins: 0")

## An AudioStreamPlayer plays one sound. It is not positioned in the level,
## so it sounds the same wherever the player is.
func add_sound(stream: AudioStream) -> AudioStreamPlayer:
	var sound := AudioStreamPlayer.new()
	sound.stream = stream
	add_child(sound)
	return sound

## Change the pitch a little each time so a repeated sound is less tiring.
func play_varied(sound: AudioStreamPlayer) -> void:
	sound.pitch_scale = randf_range(1.0 - PITCH_VARIATION, 1.0 + PITCH_VARIATION)
	sound.play()

func _physics_process(delta: float) -> void:
	player.velocity.x = Input.get_axis("left", "right") * SPEED
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("action") and player.is_on_floor():
		player.velocity.y = -JUMP_SPEED
		play_varied(jump_sound)
	player.move_and_slide()
	# Landing is the moment the player is on the floor but was not before.
	if player.is_on_floor() and not was_on_floor:
		land_sound.play()
	was_on_floor = player.is_on_floor()

func add_coin(spot: Vector2) -> void:
	var coin := Area2D.new()
	coin.position = spot
	coin.collision_layer = 0
	strip(coin, APPLE, 32)
	add_box(coin, Vector2(22, 24))
	coin.body_entered.connect(collect_coin.bind(coin))
	add_child(coin)

func collect_coin(body: Node2D, coin: Area2D) -> void:
	if body != player:
		return
	coins += 1
	status.text = "Run, jump and collect coins. Coins: %d" % coins
	play_varied(coin_sound)
	# Move the coin somewhere new once the physics step has finished.
	coin.set_deferred("position", Vector2(randf_range(60, 708), randf_range(250, 300)))
