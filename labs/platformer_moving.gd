extends "res://platformer_patrol.gd"

const CYCLE_SECONDS := 3.0
var platform: AnimatableBody2D
var elapsed := 0.0

func _ready() -> void:
	super._ready()
	platform = AnimatableBody2D.new()
	platform.position = Vector2(285, 364)
	planks(platform, Vector2(80, 16))
	add_box(platform, Vector2(80, 16))
	add_child(platform)

func _physics_process(delta: float) -> void:
	elapsed = fposmod(elapsed + delta, CYCLE_SECONDS)
	var blend := 0.5 - 0.5 * cos(TAU * elapsed / CYCLE_SECONDS)
	platform.position.x = lerpf(285.0, 328.0, blend)
	super._physics_process(delta)
