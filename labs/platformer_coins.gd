extends "res://platformer_goal.gd"

const COIN_VALUE := 1

var coins := 0
var coin_label: Label

func _ready() -> void:
	super._ready()
	coin_label = label_at(Vector2(18, 43), "Coins: 0")
	for spot in [Vector2(169, 324), Vector2(300, 249), Vector2(475, 324)]:
		add_coin(spot)

func add_coin(spot: Vector2) -> void:
	var coin := Area2D.new()
	coin.position = spot
	coin.collision_layer = 0
	strip(coin, APPLE, 32)
	add_box(coin, Vector2(22, 24))
	coin.body_entered.connect(collect_coin.bind(coin))
	add_child(coin)

func collect_coin(body: Node2D, coin: Area2D) -> void:
	if body != player or coin.is_queued_for_deletion():
		return
	coins += COIN_VALUE
	coin_label.text = "Coins: %d" % coins
	coin.queue_free()
