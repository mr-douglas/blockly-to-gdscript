extends "res://platformer_checkpoint.gd"

const PATROL_LEFT := 576.0
const PATROL_RIGHT := 622.0
const PATROL_SPEED := 52.0

var enemy: Area2D
var target_x := PATROL_RIGHT

func _ready() -> void:
	super._ready()
	enemy = add_hazard(Vector2(PATROL_LEFT, 338), Vector2(20, 25), false)
	strip(enemy, SAW, 38).scale = Vector2(0.7, 0.7)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	enemy.position.x = move_toward(enemy.position.x, target_x, PATROL_SPEED * delta)
	if is_equal_approx(enemy.position.x, target_x):
		target_x = PATROL_LEFT if target_x == PATROL_RIGHT else PATROL_RIGHT
