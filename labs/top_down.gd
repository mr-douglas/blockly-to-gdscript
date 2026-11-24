extends "res://scene_2d.gd"

const SPEED := 180.0
const GOAL := Vector2(680, 351)
var player := CharacterBody2D.new()
var crystals: Array[Polygon2D] = []
const TOTAL := 3
var finished := false
var status: Label

func _ready() -> void:
	rectangle(self, Vector2(384, 216), Vector2(768, 432), Color("#13524e"))
	for x in range(38, 768, 36):
		for y in range(70, 432, 36):
			rectangle(self, Vector2(x, y), Vector2(2, 2), Color("#398074"))
	rectangle(self, GOAL, Vector2(54, 54), Color("#37748a"))
	label_at(GOAL + Vector2(-18, -14), "EXIT", 16)
	for at in [Vector2(216, 134), Vector2(480, 108), Vector2(322, 342)]:
		var gem := Polygon2D.new()
		gem.polygon = PackedVector2Array([Vector2(0, -13), Vector2(10, 0), Vector2(0, 13), Vector2(-10, 0)])
		gem.color = Color("#60f9e4")
		gem.position = at
		add_child(gem)
		crystals.append(gem)

	wall(Vector2(384, 50), Vector2(768, 12), Color("#0b3541"))
	wall(Vector2(384, 426), Vector2(768, 12), Color("#0b3541"))
	wall(Vector2(6, 236), Vector2(12, 380), Color("#0b3541"))
	wall(Vector2(762, 236), Vector2(12, 380), Color("#0b3541"))
	wall(Vector2(350, 185), Vector2(50, 155), Color("#247d75"))
	wall(Vector2(513, 284), Vector2(145, 42), Color("#247d75"))
	wall(Vector2(580, 120), Vector2(48, 107), Color("#247d75"))
	status = label_at(Vector2(18, 10), "Crystals: 0 / 3")
	player.position = Vector2(85, 132)
	rectangle(player, Vector2.ZERO, Vector2(23, 25), Color("#ffc06c"))
	rectangle(player, Vector2(0, -6), Vector2(17, 12), Color("#623362"))
	rectangle(player, Vector2(0, -1), Vector2(12, 7), Color("#ffe8b1"))
	rectangle(player, Vector2(-3, -1), Vector2(2, 3), Color("#30344d"))
	rectangle(player, Vector2(3, -1), Vector2(2, 3), Color("#30344d"))
	add_box(player, Vector2(23, 25))
	add_child(player)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	player.velocity = direction * SPEED
	player.move_and_slide()

	for index in range(crystals.size() - 1, -1, -1):
		if player.position.distance_to(crystals[index].position) < 24:
			crystals[index].queue_free()
			crystals.remove_at(index)
			status.text = "Crystals: %d / %d" % [TOTAL - crystals.size(), TOTAL]
	if crystals.is_empty() and not finished:
		if player.position.distance_to(GOAL) < 24:
			finished = true
			status.text = "Route complete! Press R to restart."
		else:
			status.text = "All crystals found. Head to the exit."
