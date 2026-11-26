extends "res://physics_art_2d.gd"

const WOOD_MASS := 1.0
const STONE_MASS := 4.0
const FRICTION := 0.8
var dropped := false
var status: Label

func _ready() -> void:
	backdrop()
	ground()
	# Build two storeys. Each storey is two posts with a plank on top.
	var base_y := FLOOR_Y
	for storey in 2:
		add_block(Vector2(330, base_y - 55), Vector2(35, 110), "wood", WOOD_MASS)
		add_block(Vector2(438, base_y - 55), Vector2(35, 110), "wood", WOOD_MASS)
		add_block(Vector2(384, base_y - 127.5), Vector2(160, 35), "wood", WOOD_MASS)
		base_y -= 145
	status = label_at(Vector2(18, 12), "Press Space to drop a heavy stone block")

func add_block(at: Vector2, size: Vector2, kind: String, block_mass: float) -> RigidBody2D:
	var body := RigidBody2D.new()
	body.position = at
	body.mass = block_mass
	# A PhysicsMaterial sets how grippy (friction) and bouncy (bounce) it is.
	var surface := PhysicsMaterial.new()
	surface.friction = FRICTION
	surface.bounce = 0.0
	body.physics_material_override = surface
	add_box(body, size)
	block_art(body, size, kind)
	add_child(body)
	return body

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("action") and not dropped:
		dropped = true
		add_block(Vector2(384, -40), Vector2(70, 70), "stone", STONE_MASS)
		status.text = "Look out below! Press R to rebuild the tower."
